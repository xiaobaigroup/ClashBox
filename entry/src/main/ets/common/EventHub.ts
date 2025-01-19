import { emitter } from "@kit.BasicServicesKit";

export enum EventKey{
  FetchProxyGroup = 10000,
  FetchProfile = 10001,
  ProxySort = 10002,
  ChangeProxy = 10003,
  TestDelayAll = 10004,
  StartLog = 10005,
  SwitchModeCard = 10006
}

export class EventHub{
  static sendEvent(key: EventKey, data: any = null){
    emitter.emit({eventId: key}, {data: data})
  }
  static on(key: EventKey, callback: (data: any)=>void){
    emitter.off(key)
    emitter.on({eventId: key},(data)=>{
      callback(data.data)
    })
  }
}