import { ClashConfig, Dns, ProxyGroup, ProxySort } from "proxy_core";
import { CustomThemeName } from "../common/AppTheme";
import { showHomeCard } from "../common/Constants";
import { Item } from "../common/ProxyData";

export enum ProxyGroupType{
  Tabs,
  List
}
export enum ProxyCardSize{
  Mini,
  Small,
  Large
}

export class AppConfig{
  currentProfileId?: string
  currentProxyName?: string
  currentProxyItem?: Item
  proxySort?: ProxySort = ProxySort.Default
  proxyGroupType?: ProxyGroupType = ProxyGroupType.Tabs
  proxyCardSize?: ProxyCardSize = ProxyCardSize.Mini
  enableLogger?: boolean = false
  testUrl?: string = ""
  overrideDns?: boolean = false
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
  // 背景模糊变量
  isBlurr: boolean = true
  // 实验功能显示变量
  isShowExperimentalFunction: boolean = true
  // 主页卡片显示变量
  isShowHomeCard: string = JSON.stringify(showHomeCard)
  isShowSpeed? :boolean = true

  /*主页小卡片相关 */
  //快捷方式小卡片
  inputTitle1?:string
  inputTitle2?:string
  inputTitle3?:string
  inputWeb1?:string
  inputWeb2?:string
  inputWeb3?:string

  constructor() {
  }
}

export function isEnd(length: number, i: number){
  return length -1 == i
}

// use @StorageLink('appConfig')
export class AppState {

  static init(){
    PersistentStorage.persistProp("appConfig", new AppConfig())
    PersistentStorage.persistProp("favoriteProfiles", new Map<string, string>([]))
    PersistentStorage.persistProp("favoriteProxys", new Map<string, string[][]>([]))
    PersistentStorage.persistProp("clashConfig", new ClashConfig())
  }

  static fetchFavoriteProxys(favoriteProxys: Map<string, string>, proxyGroups: ProxyGroup[]):string[][] {
    let favoriteList: string[][] = []
    for(let g of proxyGroups){
      for (let p of g.proxies){
        if(favoriteProxys.has(g.name + "|" + p.text)){
          favoriteList.push([g.name, p.text])
        }
      }
    }
    return favoriteList
  }
  static fetchProxyItem(proxyGroups: ProxyGroup[], g: string, p: string): Item {
    let group = proxyGroups.find((p: ProxyGroup) => p.name == g)
    return group?.proxies.find((ps)=> ps.text == p) as Item
  }
}
// PersistentStorage 不支持嵌套对象，修改属性需要copy 更新引用来触发持久化更新
export function copy<T>(obj: T): T {
  return JSON.parse(JSON.stringify(obj));
}