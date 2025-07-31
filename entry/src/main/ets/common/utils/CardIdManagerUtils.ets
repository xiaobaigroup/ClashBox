import { Context } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { formBindingData, formProvider } from '@kit.FormKit';
import { Profile } from 'proxy_core';

/** @description 切换代理参数 */
class changeProxyParams {
  profile: Profile;
  g: string;
  p: string;

  constructor(profile: Profile, g: string, p: string) {
    this.profile = profile;
    this.g = g;
    this.p = p;
  }
}

/**
 * @author: SummerKaze
 * @description: 卡片ID持久化管理
 */
class CardIdManager {
  private ctx?: Context
  private store?: preferences.Preferences
  private storeName: string = 'cardPreference'
  private formIdKey: string = 'formId'
  private selectedProxyNodeKey: string = 'selectedProxyNode'

  /** @description 初始化 */
  init(context: Context) {
    this.ctx = context
    this.store = preferences.getPreferencesSync(this.ctx, { name: this.storeName })
  }

  /** @description 获取卡片ID列表 */
  getCardIdList() {
    if (this.store) {
      return this.store.getSync(this.formIdKey, []) as string []
    }
    return []
  }

  /** @description 添加卡片ID */
  addCardId(formId: string) {
    if (this.store) {
      const list = this.getCardIdList()
      list.push(formId)
      this.store.putSync(this.formIdKey, list)
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
        this.store.putSync(this.formIdKey, list)
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

  /** @description 获取选中的代理节点信息 */
  getSelectedProxyNode() {
    if (this.store) {
      return this.store.getSync(this.selectedProxyNodeKey, new changeProxyParams(null, '', '')) as changeProxyParams
    }
    return null
  }

  /** @description 存储选中的代理节点信息 */
  addSelectedProxyNode(profile: Profile, g: string, p: string) {
    if (this.store) {
      const newInfo = new changeProxyParams(profile, g, p)
      let proxyNodeInfo = this.getSelectedProxyNode()
      proxyNodeInfo = newInfo
      this.store.putSync(this.selectedProxyNodeKey, proxyNodeInfo)
      this.store.flushSync()
    }
  }
}

export const cardIdManager = new CardIdManager()