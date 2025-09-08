import { Context } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { formBindingData, formProvider } from '@kit.FormKit';
import { ClashConfig, IpInfo, Profile } from 'proxy_core';
import { AppConfig } from '../../entryability/AppState';

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
class CardManager {
  private ctx?: Context
  private store?: preferences.Preferences
  private storeName: string = 'cardPreference'
  private formIdKey: string = 'formId'
  private selectedProxyNodeKey: string = 'selectedProxyNode'
  private appConfigKey: string = 'appConfig'
  private clashConfigKey: string = 'clashConfig'

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
      if (!list.includes(formId)) {
        list.push(formId)
        this.store.putSync(this.formIdKey, list)
        this.store.flushSync()
      }
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

  /** @description 推送代理状态到所有卡片 */
  pushCartProxyMode(proxyEnabled: boolean, tips: string = '') {
    // 创建推送数据
    const data = formBindingData.createFormBindingData({
      proxyEnabled,
      loading: false,
      tips,
    })
    this.getCardIdList().forEach(formId => {
      // 推送到卡片
      formProvider.updateForm(formId, data)
    })
  }
  
  /** @description 推送loading状态到所有卡片 */
  pushCartLoading(loading: boolean) {
    // 创建推送数据
    const data = formBindingData.createFormBindingData({
      loading,
    })
    this.getCardIdList().forEach(formId => {
      // 推送到卡片
      formProvider.updateForm(formId, data)
    })
  }

  /** @description 推送IP地址到所有卡片 */
  pushCartProxyIpInfo(remoteIp: IpInfo) {
    // 创建推送数据
    const data = formBindingData.createFormBindingData({
      remoteIp
    })
    this.getCardIdList().forEach(formId => {
      // 推送到卡片
      formProvider.updateForm(formId, data)
    })
  }

  /** @description 推送当前节点名称到所有卡片 */
  pushCartCurrentProxyName(currentProxyName: string) {
    const data = formBindingData.createFormBindingData({
      currentProxyName
    })
    this.getCardIdList().forEach(formId => {
      // 推送到卡片
      formProvider.updateForm(formId, data)
    })
  }

  /** @description 推送VPN服务运行时间到所有卡片 */
  pushCartVpnServiceTime(proxyStartingDuration: string) {
    const data = formBindingData.createFormBindingData({
      proxyStartingDuration
    })

    this.getCardIdList().forEach(formId => {
      // 推送到卡片
      formProvider.updateForm(formId, data)
    })
  }

  /** @description 推送主题色到所有卡片 */
  pushCartThemeColor(themeColor: ResourceColor) {
    const data = formBindingData.createFormBindingData({
      themeColor
    })

    this.getCardIdList().forEach(formId => {
      // 推送到卡片
      formProvider.updateForm(formId, data)
    })
  }

  /** @description 推送延迟 */
  pushCartDelay(delay: number) {
    const data = formBindingData.createFormBindingData({
      delay
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
  setSelectedProxyNode(profile: Profile, g: string, p: string) {
    if (this.store) {
      const newInfo = new changeProxyParams(profile, g, p)
      let proxyNodeInfo = this.getSelectedProxyNode()
      proxyNodeInfo = newInfo
      this.store.putSync(this.selectedProxyNodeKey, proxyNodeInfo)
      this.store.flushSync()
    }
  }

  // 适配层 -> 适配 appConfig 和 clashConfig 持久化的问题
  /** @description 获取App配置 */
  getAppConfig() {
    if (this.store) {
      return this.store.getSync(this.appConfigKey, new AppConfig()) as AppConfig
    }
    return null
  }

  /** @description 存储App配置 */
  setAppConfig(appConfig: AppConfig) {
    if (this.store) {
      let newConfig = new AppConfig()
      newConfig = appConfig
      this.store.putSync(this.appConfigKey, newConfig)
      this.store.flushSync()
    }
  }

  /** @description 获取Clash配置 */
  getClashConfig() {
    if (this.store) {
      return this.store.getSync(this.clashConfigKey, new ClashConfig()) as ClashConfig
    }
    return null
  }

  /** @description 存储Clash配置 */
  setClashConfig(clashConfig: ClashConfig) {
    if (this.store) {
      let newConfig = new ClashConfig()
      newConfig = clashConfig
      this.store.putSync(this.clashConfigKey, newConfig)
      this.store.flushSync()
    }
  }
}

export const cardManager = new CardManager()