import { ClashConfig,  IpInfo, ProxyGroup, ProxyMode, ProxySort, SnifferDefault, Traffic, } from "proxy_core";
import { ANIMATION_DURATION_300, showHomeCard } from "../common/entity/Constants";
import { ProxyItem } from "../common/datasources/ProxyData";
import { resourcesBlankData, theResourcesData } from "../components/More/Resources";
import ClashViewModel from "./ClashViewModel";
import { bundleManager } from "@kit.AbilityKit";
import { EventHub, EventKey } from "../common/EventHub";
import { CustomThemeName } from "xb_components/src/main/ets/utils/AppThemeManager";
import { TabStyle, Xb_PreferenceUtil } from "xb_components";

export enum ProxyGroupType {
  Tabs,
  List
}
export enum ProxyCardSize {
  Mini,
  Small,
  Large
}

export enum SwitchModeCard{
  Global ="GLOBAL",
  Rule = "RULE",
  Direct = "DIRECT"
}
export enum ClashCore {
  mihomo,
  // 非mihomo用于开发调试， ui进程运行vpn核心；调试vpn核心崩溃和杀进程问题
  ClashMeta,
  ClashRs,
}
export class AppFlowingState{
  traffics: TrafficQueue = new TrafficQueue(12)
  totalTraffic: Traffic = new Traffic(0, 0)
  localIp: string = ""
  removeIp: IpInfo | null = null

}

export class AppConfig {
  currentProfileId?: string
  currentProxyName?: string
  currentProfileName?: string
  currentProxyItem?: ProxyItem
  accessControlMode: string = 'RejectSelected'
  accessControlSort: 'name' | 'time' = 'name'
  accessControlAppInfo: string = JSON.stringify([])
  accessControlAcceptList: string = JSON.stringify([])
  accessControlRejectList: string = JSON.stringify([])
  proxySort: ProxySort = ProxySort.Default
  proxyGroupType: ProxyGroupType = ProxyGroupType.Tabs
  proxyCardSize: ProxyCardSize = ProxyCardSize.Mini
  enableLogger: boolean = false
  enableRequest: boolean = false
  enableConnect: boolean = false
  accessControl: boolean = false
  testUrl: string = "https://www.gstatic.com/generate204"
  clashCore: ClashCore = ClashCore.ClashMeta
  switchMode: ProxyMode = ProxyMode.Rule
  constructor() {
  }
}
export enum TrafficUnit{
  KB = "KB",
  MB = "MB",
  GB = "GB",
  TB = "TB",
}

export class UIConfig {
  // 主页问候语
  isGreeting?: boolean = true
  // 历史版本名
  oldVersionCode: number = 1006056
  // 主题色
  themeColor: CustomThemeName = 'blueAppTheme'
  // 主题色序号
  themeColorIndex: number = 0
  // 颜色模式
  darkMode: ThemeColorMode = ThemeColorMode.SYSTEM
  // 按钮位置序号
  buttonPositionIndex: number = 0
  // 动画速度序号
  animationSpeedIndex: number = 1
  // 字符显示权重序号
  stringDisplayIndex: number = 1
  /** 退出窗口模式 1为直接退出，0为进入托盘*/
  exitWindowMode: number = 0
  // 背景模糊变量
  isBlurr: boolean = true
  // 实验功能显示变量
  isShowExperimentalFunction: boolean = false
  // 是否启用云备份配置
  isShowCloudBackupConfig: boolean = false
  // 主页卡片显示变量
  isShowHomeCard: string = JSON.stringify(showHomeCard)
  // 用户选择的语言
  userLanguage: string = "default"
  // 导航栏样式
  tabStyle: TabStyle = 'float'
  // 系统语言
  systemLanguage: string = ''
  // 震动反馈变量
  isVibrate: boolean = true
  // 声音反馈变量
  isSound: boolean = true
  // 通知总开关
  Enablednotice: boolean = true
  // 启用代理页开关
  needProxyStart: boolean = false
  // 适人握持(动作感知)开关
  isHoldingHand: boolean = false
  // 适人握持切换时浮动按钮可见性
  isFloatButtonVisible: boolean = true
  // 编辑器自动换行
  editWordWrap: boolean = true
  // 常驻通知开关
  EnabledPermanentnotice: boolean = true
  // 常驻状态栏开关
  EnabledStatusNotice: boolean = false
  // 允行通知共存
  EnabledCoexistNotice: boolean = false
  // 是否进行过通知授权
  isRequestNotification: boolean = false
  // 后台运行启用变量
  Enablebackgrounder: boolean = false
  // 模拟定位启用变量
  backgroundLocateModel: boolean = true
  // 后台保持变量
  backgroundKeepTask: boolean = false
  // 模拟下载启用变量
  backgroundDownModel: boolean = false
  // 模拟画中画启用变量
  backgroundPiPModel: boolean = false
  /* 主页小卡片相关 */
  // 分流模式小卡片  平移属性参数
  translateY: number | string = '-100%'
  // 快捷方式小卡片
  inputTitle1: string = ''
  inputTitle2: string = ''
  inputTitle3: string = ''
  inputWeb1: string = ''
  inputWeb2: string = ''
  inputWeb3: string = ''
  // 流量统计小卡片
  inputTotal: number = 0
  switchUnit: TrafficUnit = TrafficUnit.MB
  cellularDataIndex: number = 1
  dataTotal: number = 0
  dataTotalLast: number = 0
  // 动画速度
  animationSpeed:number = ANIMATION_DURATION_300
  isAnimation:boolean=true
  // 代理启动按钮状态
  proxyEnabled: boolean = false
  // 高级功能启用状态
  enabledADvanced: boolean = false
  // 是否第一次启动应用 TODO debug时为 false release时为 true
  isFirstStart: boolean = true
  // 应用使用时间记录
  useTime: number = new Date().getTime()
  // 代理启动按钮提示气泡
  ShowStartPop: boolean = false
  // 长按配置列表提示气泡
  ShowConfigPop: boolean = false
  // 长按代理节点列表提示气泡
  ShowProxyPop: boolean = false
  // 延迟统一测速提示气泡
  ShowDelayPop: boolean = false
  // 自动检查更新
  autoCheckUpdate: boolean = false
  // 配置自动更新时间
  autoUpdateTimeUtils?: number
  // 是否第一次导入配置
  isFirstImportConfig: boolean = true
  resourcesData: string = JSON.stringify(theResourcesData)
  resourcesHideData: string = JSON.stringify(resourcesBlankData)
  // 日志时间排序
  LogSortTime: number = 0
  constructor() {
  }
}

export function isEnd(length: number, i: number) {
  return length -1 == i
}

export function getPackageInfo() {
  return bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
}

@Observed
// use @StorageLink('appConfig')
export class AppState {
  static externalController = "0.0.0.0:9090"
  static globalUA = "clash.meta/1.19.5"
  static versionName = ''
  static versionCode = 1006056
  static coreVersion = "Prerelease-Alpha"
  static appProvisionType = 'release'
  static async init() {

    PersistentStorage.persistProp("appConfig", new AppConfig())
    PersistentStorage.persistProp("favoriteProfiles", new Map<string, string>([]))
    PersistentStorage.persistProp("favoriteProxys", new Map<string, string[][]>([]))

    PersistentStorage.persistProp("clashConfig", new ClashConfig(AppState.globalUA))
    PersistentStorage.persistProp("uiConfig", new UIConfig())
    AppStorage.setOrCreate<AppFlowingState>("appFlowingState", new AppFlowingState())
    // 获取打包类型
    AppState.getAppProvisionType()
  }
  // 还原覆写配置
  static  ResetClashConfig(){
    AppStorage.set("clashConfig", new ClashConfig(AppState.globalUA))
  }
  // 清理数据 还原默认值
  static async ResetConfig(context: Context) {
    ClashViewModel.StopVpn()
    AppState.ResetClashConfig()
    AppStorage.set("appConfig", new AppConfig())
    AppStorage.set("favoriteProfiles", new Map<string, string>([]))
    AppStorage.set("favoriteProxys", new Map<string, string>([]))
    AppStorage.set("uiConfig",  new UIConfig())
    AppStorage.set("appFlowingState", new AppFlowingState())
    AppStorage.set("proxyGroups", [])
    await ClashViewModel.profileRepo.ClearAll(context)
    // 清空配置排序表
    await Xb_PreferenceUtil.delete('config_sort')
    EventHub.sendEvent(EventKey.FetchProfile)
    // TODO 还原其他配置
  }

  static fetchFavoriteProxys(favoriteProxys: Map<string, string>, proxyGroups: ProxyGroup[]):string[][] {
    let favoriteList: string[][] = []
    for(let g of proxyGroups){
      for (let p of g.proxies){
        if(favoriteProxys.has(g.name + "|" + p.name)){
          favoriteList.push([g.name, p.name])
        }
      }
    }
    return favoriteList
  }
  static fetchProxyItem(proxyGroups: ProxyGroup[], g: string, p: string): ProxyItem {
    let group = proxyGroups.find((p: ProxyGroup) => p.name == g)
    return group?.proxies.find((ps)=> ps.name == p) as ProxyItem
  }

  static getAppProvisionType() {
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION | bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_METADATA;
    try {
      bundleManager.getBundleInfoForSelf(bundleFlags).then((data) => {
        console.info('getBundleInfoForSelf successfully. Data: %{public}s', JSON.stringify(data));
        AppState.appProvisionType = data.appInfo.appProvisionType
      }).catch((err: BusinessError) => {
        console.error('getBundleInfoForSelf failed. Cause: %{public}s', err.message);
      });
    } catch (err) {
      let message = (err as BusinessError).message;
      console.error('getBundleInfoForSelf failed: %{public}s', message);
    }
  }

}
// PersistentStorage 不支持嵌套对象，修改属性需要copy 更新引用来触发持久化更新
export function copy<T>(obj: T): T {
  return JSON.parse(JSON.stringify(obj));
}


export function getLast<T>(list: T[]): T{
  return list[list.length -1]
}

export class TrafficQueue{
  queue: Traffic[]
  maxSize: number
  constructor(maxSize = 12) {
    this.queue = Array(maxSize).fill(new Traffic(0, 0)); // 初始化一个全是 0 的队列
    this.maxSize = maxSize;
  }
  // 入队操作
  enqueue(item: Traffic) {
    // 将新元素添加到队列的最后一个位置，并循环更新队列
    if (this.queue.length >= this.maxSize){
      this.queue.shift()
    }
    this.queue.push(item)
  }
  getLast(): Traffic{
    return getLast(this.queue)
  }
  // 获取当前队列内容
  getData() {
    return this.queue.map((q) => q.upRaw + q.downRaw);
  }
}
