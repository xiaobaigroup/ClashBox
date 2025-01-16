import { ClashConfig, Dns, ProxyGroup, ProxySort } from "proxy_core";
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