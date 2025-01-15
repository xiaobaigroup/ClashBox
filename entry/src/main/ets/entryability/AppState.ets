import { ClashConfig, Dns, ProxySort } from "proxy_core";

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
  proxySort?: ProxySort = ProxySort.Default
  proxyGroupType?: ProxyGroupType = ProxyGroupType.Tabs
  proxyCardSize?: ProxyCardSize = ProxyCardSize.Mini
}

export function isEnd(length: number, i: number){
  return length -1 == i
}
// use @StorageLink('appConfig')
export class AppState {

  static init(){
    PersistentStorage.persistProp("appConfig", new AppConfig())
    PersistentStorage.persistProp("favoriteProfiles", new Map<string, string>([]))
    PersistentStorage.persistProp("favoriteProxys", new Map<string, string>([]))
    PersistentStorage.persistProp("clashConfig", new ClashConfig())
  }
}