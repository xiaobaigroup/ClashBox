import { ClashConfig, Dns } from "proxy_core";

export class AppConfig{
  currentProfileId?: string
  favoriteProxys: string[] = []
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