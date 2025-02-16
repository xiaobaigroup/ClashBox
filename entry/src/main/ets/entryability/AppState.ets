import { ClashConfig,  IpInfo, ProxyGroup, ProxyMode, ProxySort, Traffic, } from "proxy_core";
import { CustomThemeName } from "../common/AppTheme";
import { ANIMATION_DURATION_300, showHomeCard } from "../common/Constants";
import { ProxyItem } from "../common/ProxyData";
import { resourcesBlankData, theResouresData } from "../components/More/Resources";
import ClashViewModel from "./ClashViewModel";
import { bundleManager } from "@kit.AbilityKit";
import { EventHub, EventKey } from "../common/EventHub";

export enum ProxyGroupType{
  Tabs,
  List
}
export enum ProxyCardSize{
  Mini,
  Small,
  Large
}

export enum SwitchModeCard{
  Global ="GLOBAL",
  Rule = "RULE",
  Direct = "DIRECT"
}
export enum ClashCore{
  ClashMeta,
  FlClash,
  ClashRs,
}
export class AppFlowingState{
  traffics: TrafficQueue = new TrafficQueue(12)
  totalTraffic: Traffic = new Traffic(0, 0)
  localIp: string = ""
  removeIp: IpInfo | null = null

}

export class AppConfig{
  currentProfileId?: string
  currentProxyName?: string
  currentProfileName?: string
  currentProxyItem?: ProxyItem
  proxySort: ProxySort = ProxySort.Default
  proxyGroupType: ProxyGroupType = ProxyGroupType.Tabs
  proxyCardSize: ProxyCardSize = ProxyCardSize.Mini
  enableLogger: boolean = false
  testUrl: string = ""
  overrideDns: boolean = false
  clashCore: ClashCore = ClashCore.FlClash
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

export class UIConfig{
  // 主页问候语
  isGreeting?: boolean = true
  // 主题色
  themeColor: CustomThemeName = 'blueAppTheme'
  // 主题色序号
  themeColorIndex: number = 0
  // 深色模式序号
  darkModeIndex: number = 0
  // 按钮位置序号
  buttonPositionIndex: number = 0
  // 动画速度序号
  animationSpeedIndex: number = 1
  // 背景模糊变量
  isBlurr: boolean = true
  // 实验功能显示变量
  isShowExperimentalFunction: boolean = false
  // 主页卡片显示变量
  isShowHomeCard: string = JSON.stringify(showHomeCard)
  // 用户选择的语言
  userLanguage: string = "default"
  // 震动反馈变量
  isVibrate: boolean = true
  // 声音反馈变量
  isSound: boolean = true
  // 通知总开关
  Enablednotice: boolean = false
  // 是否进行过通知授权
  isRequestNotification: boolean = false
  // 后台运行启用变量
  Enablebackgrounder: boolean = false
  // 模拟定位启用变量
  backgroundLocateModel: boolean = false
  // 模拟画中画启用变量
  backgroundPiPModel: boolean = false
  /* 主页小卡片相关 */
  //分流模式小卡片  平移属性参数
  translateY:number|string='-100%'
  //快捷方式小卡片
  inputTitle1: string = ''
  inputTitle2: string = ''
  inputTitle3: string = ''
  inputWeb1: string = ''
  inputWeb2: string = ''
  inputWeb3: string = ''
  //流量统计小卡片
  inputTotal: number = 0
  switchUnit: TrafficUnit = TrafficUnit.MB
  cellularDataIndex: number = 1
  dataTotal: number = 0
  dataTotalLast: number = 0
  //动画速度
  animationSpeed:number = ANIMATION_DURATION_300
  isAnimation:boolean=true
  // 代理启动按钮状态
  proxyEnabled: boolean = false
  // 高级功能启用状态
  enabledADvanced: boolean = false
  // 是否第一次启动
  isFirstStart: boolean = true
  resourcesData: string = JSON.stringify(theResouresData)
  resourcesHideData: string = JSON.stringify(resourcesBlankData)
  constructor() {
  }
}

export function isEnd(length: number, i: number){
  return length -1 == i
}

export function getPackageInfo(){
  return bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
}

@Observed
// use @StorageLink('appConfig')
export class AppState {
  static externalController = "127.0.0.1:9090"
  static globalUA = "ClashNext/v0.0.0"
  static versionName = ""
  static coreVersion = "Prerelease-Alpha"
  static async init(){

    PersistentStorage.persistProp("appConfig", new AppConfig())
    PersistentStorage.persistProp("favoriteProfiles", new Map<string, string>([]))
    PersistentStorage.persistProp("favoriteProxys", new Map<string, string[][]>([]))

    PersistentStorage.persistProp("clashConfig", new ClashConfig(AppState.globalUA))
    PersistentStorage.persistProp("uiConfig", new UIConfig())
    AppStorage.setOrCreate<AppFlowingState>("appFlowingState", new AppFlowingState())
  }
  // 还原覆写配置
  static  ResetClashConfig(){
    AppStorage.set("clashConfig", new ClashConfig(AppState.globalUA))
    AppStorage.set("appConfig", new AppConfig())
  }
  // 清理数据 还原默认值
  static ResetConfig(){
    ClashViewModel.StopVpn()
    AppState.ResetClashConfig()
    AppStorage.set("appConfig", new AppConfig())
    AppStorage.set("favoriteProfiles", new Map<string, string>([]))
    AppStorage.set("favoriteProxys", new Map<string, string>([]))
    AppStorage.set("uiConfig",  new UIConfig())
    AppStorage.set("appFlowingState", new AppFlowingState())
    AppStorage.set("proxyGroups", [])
    ClashViewModel.profileRepo.ClearAll()
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

