import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { systemShare, harmonyShare } from '@kit.ShareKit';
import { Xb_GetResourceString } from './ResourceStringUtil';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Xb_ToastUtil } from './ToastUtils';

/**
 * 隔空投送和碰一碰分享工具，需要软件最高api为20才能使用，5.1系统可用
 * 需在module.json5将 "exported"改为true,
 * 在可投送页面导入信息和上下文
 * 在可投送页面增加监听取消监听即可
 */

@ObservedV2
class Share{
  private uiContext?: UIContext
  // 隔空投送数据，需要首先在软件内填入此数据，才能正确投送相关内容
  @Trace shareData: ShareData = {
    content: 'https://sharekitdemo.drcn.agconnect.link/ZB3p',
    title: '隔空传送分享卡片标题',
    description: '隔空传送分享卡片描述',
    utd: utd.UniformDataType.HYPERLINK,
    label: '',
    thumbnail: undefined,
    thumbnailUri: '',
    uri: '',
    extraData: undefined
  }

  // 先导入上下文及需要用到内容
  inputInfo(ctx: UIContext){
    this.uiContext = ctx
  }

  private immersiveCallback = async (sharableTarget: harmonyShare.SharableTarget) => {
   // let contextFaker: Context = this.uiContext!.getHostContext() as Context;
   // let filePath = contextFaker.filesDir + this.shareData.thumbnailUri; // 仅为示例 请替换正确的文件路径
    // 构建appLink直达分享data
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: this.shareData.utd,//更改投送的文件类型
      content: this.shareData.content,//如需直达应用 此处应改为appLink
      thumbnailUri: this.shareData.thumbnailUri,//fileUri.getUriFromPath(filePath),
      title: Xb_GetResourceString(this.shareData.title, this.uiContext!),//'隔空传送分享卡片标题',//投送标题
      description: Xb_GetResourceString(this.shareData.description, this.uiContext!),//'隔空传送分享卡片描述'//投送卡描述
      extraData: this.shareData.extraData,
      uri: this.shareData.uri,
      thumbnail: this.shareData.thumbnail,
      label: this.shareData.label
    });
    try{
     await sharableTarget.share(shareData)
    }catch(error){
      Xb_ToastUtil.showToast({ message: `分享失败: ${error.message}` })
      console.error(`ShareController show error. code: ${error.code}, message: ${error.message}`);
    }

  }

  // 分享监听
  public immersiveListening(witchOne: string) {
    if (witchOne === 'gesturesShare') {
      // 隔空投送监听
      harmonyShare.on('gesturesShare', this.immersiveCallback);
    }else if (witchOne === 'knockShare'){
      // 碰一碰监听
      harmonyShare.on('knockShare', this.immersiveCallback);
    }else if (witchOne === 'all'){
      // 两种分享都监听
      harmonyShare.on('gesturesShare', this.immersiveCallback);
      harmonyShare.on('knockShare', this.immersiveCallback);
    }
  }

  // 取消分享监听
  public immersiveDisablingListening(witchOne: string) {
    if (witchOne === 'gesturesShare') {
      // 取消隔空投送监听
      harmonyShare.off('gesturesShare', this.immersiveCallback);
    }else if (witchOne === 'knockShare'){
      // 取消碰一碰监听
      harmonyShare.off('knockShare', this.immersiveCallback);
    }else if (witchOne === 'all'){
      harmonyShare.off('gesturesShare', this.immersiveCallback);
      harmonyShare.off('knockShare', this.immersiveCallback);
    }
  }

  // 华为分享面板分享控制器
  async sharePlant(context: common.UIAbilityContext) {
    // 构造ShareData，需配置一条有效数据信息
    let shareData: systemShare.SharedData = new systemShare.SharedData({
      utd: this.shareData.utd,//更改投送的文件类型
      content: this.shareData.content,//如需直达应用 此处应改为appLink
      thumbnailUri: this.shareData.thumbnailUri,//fileUri.getUriFromPath(filePath),
      title: Xb_GetResourceString(this.shareData.title, this.uiContext!),//'隔空传送分享卡片标题',//投送标题
      description: Xb_GetResourceString(this.shareData.description, this.uiContext!),//'隔空传送分享卡片描述'//投送卡描述
      extraData: this.shareData.extraData,
      uri: this.shareData.uri,
      thumbnail: this.shareData.thumbnail,
      label: this.shareData.label
    });
    // 进行分享面板显示
    let controller: systemShare.ShareController = new systemShare.ShareController(shareData);
    if (canIUse("SystemCapability.Collaboration.SystemShare")) {
      controller.show(context, {
        previewMode: systemShare.SharePreviewMode.DEFAULT,
        selectionMode: systemShare.SelectionMode.SINGLE
      }).then(() => {
        console.info('ShareController show success.');
      }).catch((error: BusinessError) => {
        console.error(`ShareController show error. code: ${error.code}, message: ${error.message}`);
      });
    } else {
      // Fallback for unsupported SystemCapability
    }
  }
}

export const Xb_Share: Share = new Share()


/**
 * 具体使用 查看 此网址 https://developer.huawei.com/consumer/cn/doc/harmonyos-references/share-system-share#section20696483813
 */
export interface ShareData{
  utd: string //数据类型
  content: string //应用直达连接
  title: ResourceStr //如果是文本、链接等内容，建议填入title标识其标题。缺省时，若分享内容为文本类型，则文本内容作为title字段；若分享内容为文件类型，则文件名作为title字段。
  description: ResourceStr //数据记录的描述。缺省为空字符串。
  label: string //标识当前数据记录类型的标签，在单选模式时生效。缺省为UniformDataType类型相应的标签。
  thumbnail?: Uint8Array //数据记录缩略图。缺省时使用与分享内容类型匹配的图标作为缩略图。建议开发者传入符合数据记录的缩略图，如无，可传入应用图标。
  thumbnailUri: string //数据记录缩略图的uri。缺省时使用与分享内容类型匹配的图标作为缩略图。支持的uri类型：应用文件uri，参见：应用文件分享 // 用户文件uri，参见：用户文件uri介绍
  uri: string //数据记录的uri。支持的uri类型：应用文件uri，参见：应用文件分享用户文件uri，参见：用户文件uri介绍
  extraData?: Record<string, string | number | boolean | Array<string | number | boolean>>//扩展数据，用于向目标应用/设备分享自定义的扩展内容。
}