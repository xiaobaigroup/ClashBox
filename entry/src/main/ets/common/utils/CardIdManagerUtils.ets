import { Context } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { formBindingData, formProvider } from '@kit.FormKit';

/**
 * @author: SummerKaze
 * @description: 卡片ID持久化管理
 */
class CardIdManager {
  private ctx?: Context
  private store?: preferences.Preferences
  private storeName: string = 'cardPreference'
  private key: string = 'formId'

  /** @description 初始化 */
  init(context: Context) {
    this.ctx = context
    this.store = preferences.getPreferencesSync(this.ctx, { name: this.storeName })
  }

  /** @description 获取卡片ID列表 */
  getCardIdList() {
    if (this.store) {
      return this.store.getSync(this.key, []) as string []
    }
    return []
  }

  /** @description 添加卡片ID */
  addCardId(formId: string) {
    if (this.store) {
      const list = this.getCardIdList()
      list.push(formId)
      this.store.putSync(this.key, list)
      this.store.flushSync()
    }
  }

  /** @description 删除卡片ID */
  delCardId(formId: string) {
    if (this.store) {
      const list = this.getCardIdList()
      const index = list.indexOf(formId)
      if (index > -1) {
        list.splice(index, 1)
        this.store.putSync(this.key, list)
        this.store.flushSync()
      }
    }
  }

  /** @description 推送内容到所有卡片 */
  pushCartProxyMode(proxyEnabled: boolean) {
    // 创建推送数据
    const data = formBindingData.createFormBindingData({
      proxyEnabled
    })
    this.getCardIdList().forEach(formId => {
      // 推送到卡片
      formProvider.updateForm(formId, data)
    })
  }
}

export const cardIdManager = new CardIdManager()