import { common } from "@kit.AbilityKit"
import { iap } from "@kit.IAPKit"
import { util } from '@kit.ArkTS';
import { PurchaseOrderPayload } from "./IapModel";
import { Xb_ToastUtil } from "./ToastUtils";


const TAG: string = 'JWSUtil';
const BASE64_PADDING_MOD: number = 4;
const BASE64_PADDING_INVALID: number = 1;

export class JWSUtil {
  public static decodeJwsObj(data: string): string {
    const jws: string[] = data.split('.');
    let result: string = '';
    if (jws.length < 3) {
      return result;
    }
    try {
      const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const base64 = new util.Base64Helper();
      let payload = jws[1];
      const centerLineRegex: RegExp = new RegExp('-', 'g');
      const underLineRegex: RegExp = new RegExp('_', 'g');
      payload = payload.replace(centerLineRegex, '+').replace(underLineRegex, '/');
      const pad = payload.length % BASE64_PADDING_MOD;
      if (pad) {
        if (pad === BASE64_PADDING_INVALID) {
          throw new Error('InvalidLengthError: Input base64 string is the wrong length to determine padding');
        }
        payload += new Array(BASE64_PADDING_MOD - pad + 1).join('=');
      }
      result = textDecoder.decodeToString(base64.decodeSync(payload));
    } catch (err) {
      console.error(TAG, `decodeJwsObj parse err: ${JSON.stringify(err)}`);
    }
    return result;
  }
}

export interface PayProduct{
  id: string
  type: iap.ProductType
  timeDay: number | undefined
  reBuy: boolean
}

class ProductsUtils{
  context: common.UIAbilityContext | undefined
  init(context: common.UIAbilityContext){
    this.context = context
  }
  async isSandboxActivated() {
    try {
      console.info(`Succeeded in checking the sandbox status. is activate: ${await iap.isSandboxActivated(this.context).then()}`);
      return await iap.isSandboxActivated(this.context)
    }catch (err) {
      // 服务未激活
      console.error(`Failed to query products. Code is ${err.code}, message is ${err.message}`);
    }
    return false;
  }
  async queryEnvironmentStatus(){
    try {
      await iap.queryEnvironmentStatus(this.context)
      return true
    }catch (e) {
      return false;
    }
  }
  async queryProduct(product: PayProduct): Promise<iap.Product | undefined> {
    let list = await this.queryProducts([product.id], product.type)
    return list[0]
  }

  async queryProducts(ids: string[] = ['VIP0000000000001'], productType: number = iap.ProductType.NONCONSUMABLE): Promise<iap.Product[]> {
    try {
      const queryProductParam: iap.QueryProductsParameter = {
        productType: productType,
        // productIds中的商品需要替换成开发者在AppGallery Connect网站配置的商品
        productIds: ids
      };
      let list = await (iap.queryProducts(this.context, queryProductParam) as Promise<iap.Product[]>);
      return list
    }catch (err) {
      console.error(`Failed to query products. Code is ${err.code}, message is ${err.message}`);
    }
    return [];
  }
  // isFinished后可以重复购买,queryPurchases将查询不到
  async createPurchase(products: PayProduct | iap.Product, isFinished = false) {
    const createPurchaseParam: iap.PurchaseParameter = {
      // iap.ProductType.NONRENEWABLE：非续期订阅商品
      productType: products.type,
      // productId需要替换成开发者在AppGallery Connect网站配置商品信息时设置的“商品ID”
      productId: products.id,
    };
    try {
      let result = await (iap.createPurchase(this.context, createPurchaseParam) as Promise<iap.CreatePurchaseResult>)

      if (isFinished){
        await this.finishPurchase(this.parsePurchase(result.purchaseData))
      }
    } catch (err) {
      if (err.code == iap.IAPErrorCode.PRODUCT_OWNED){
        Xb_ToastUtil.showToast({message:"请勿重复购买!"})
      } else if (err.code == iap.IAPErrorCode.USER_CANCELED) {
        Xb_ToastUtil.showToast({message:"已取消购买"})
      } else {
        Xb_ToastUtil.showToast({message:"购买失败: " + err.message})
      }
      console.error(`createPurchase. Code is ${err.code}, message is ${err.message}`);
    }
  }
  // 解密jws 并完成购买
   parsePurchase(result: string): PurchaseOrderPayload{
    const jwsPurchaseOrder: string = JSON.parse(result).jwsPurchaseOrder;
    const purchaseStr = JWSUtil.decodeJwsObj(jwsPurchaseOrder);
    return JSON.parse(purchaseStr) as PurchaseOrderPayload;
  }
  async finishPurchase(payload: PurchaseOrderPayload): Promise<void> {
    await iap.finishPurchase(this.context, {
      productType: payload.productType,
      purchaseToken: payload.purchaseToken,
      purchaseOrderId: payload.purchaseOrderId
    })
  }
  async GetProductPurchase(product: PayProduct | iap.Product): Promise<PurchaseOrderPayload[]>{
     let list = await this.queryPurchases(product.type)
     return list.filter(s => s.productId == product.id)
  }
  async checkProductPurchase(purchase: PurchaseOrderPayload, limitDay: number = 3, isAgainBuy: boolean = true){
    const now = Date.now();
    const sevenDaysInMs = limitDay * 24 * 60 * 60 * 1000; // 3天的毫秒数
    const isOver7Days = (now - purchase.purchaseTime) <= sevenDaysInMs;
    if (isOver7Days){
        return true
    } else {
      // 账单过期, 完成账单后可购买
      if (isAgainBuy) {
        // 没有后端持久化目前通过purchase来验证是否购买
        // finished后可重复购买,但是会查询不到账单, 同类型不能含有未finished账单,否者服务购买
         this.finishPurchase(purchase)
      }
      return false
    }

  }
  // 查询购买商品
  // TODO 不支持订阅
  async queryPurchases(productType: iap.ProductType = iap.ProductType.NONCONSUMABLE): Promise<PurchaseOrderPayload[]>{
    const createPurchaseParam: iap.QueryPurchasesParameter = {
      productType: productType,
      queryType: iap.PurchaseQueryType.ALL
    };
    let productIds: PurchaseOrderPayload[] = []
    try {
      let result  = await (iap.queryPurchases(this.context, createPurchaseParam) as Promise<iap.QueryPurchaseResult>)
      const purchaseDataList: string[] = result.purchaseDataList;

      if (purchaseDataList === undefined || purchaseDataList.length <= 0) {
        return [];
      }
      for (let i = 0; i < purchaseDataList.length; i++) {
        if (!purchaseDataList[i]) {
          continue;
        }
        try {
          const payload = this.parsePurchase(purchaseDataList[i])
          if(payload){
            productIds.push(payload)
          }
        }catch (err) {
          console.error(`queryPurchases. Code is ${err.code}, message is ${err.message}`);
        }
      }
      console.error(`queryPurchases  ${JSON.stringify(productIds)}`);
      return productIds
    }catch (err) {
      // 服务未激活
      console.error(`queryPurchases. Code is ${err.code}, message is ${err.message}`);
    }
    return []
  }

}



export const productsUtils = new ProductsUtils()