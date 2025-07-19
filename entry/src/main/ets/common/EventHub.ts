import { emitter } from "@kit.BasicServicesKit";

export enum EventKey{
  FetchProxyGroup = 10000,
  FetchProfile = 10001,
  ProxySort = 10002,
  ChangeProxy = 10003,
  TestDelay = 10004,
  StartLog = 10005,
  SwitchModeCard = 10006,
  ClearLog = 10007,
  ExportLog = 10008,
  ArrayConfigChanged = 10009,
  StartedClash = 10010,
  StopedClash = 10011,
  checkIpInfo = 10012,
  LoadClashConfig = 10013,
  CardChangeProxy = 10014,
}

export class EventHub{
  static sendEvent(key: EventKey, data: any = null){
    emitter.emit({eventId: key}, {data: data})
  }
  static on(key: EventKey,callback: (data: any)=>void, once: boolean = true){
    if(once)
      emitter.off(key)
    emitter.on({eventId: key},(data)=>{
      callback(data.data)
    })
  }
  static off(key: EventKey) {
    emitter.off(key)
  }
}