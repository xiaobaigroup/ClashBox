import { emitter } from "@kit.BasicServicesKit";

export enum Xb_EventKey{
  exportLogs = 1100000,
}


/**
 * "泛型"事件中心类
 * @param key number、string 类型
 */
export class EventHub<T> {
  static sendEvent<T>(key: number | string, data: T = null) {
    if (typeof key == 'string') {
      emitter.emit(key, {data: data})
      return
    }
    emitter.emit({eventId: key as number}, {data: data})
  }

  static on<T>(key: number | string, callback: (data: T) => void, once: boolean = true) {
    if (once) {
      emitter.off(key as number)
    }
    if (typeof key == 'string') {
      emitter.on(key, (data)=>{
        callback(data.data as T)
      })
      return
    }
    emitter.on({eventId: key as number},(data)=>{
      callback(data.data as T)
    })
  }

  static off<T>(key: number | string) {
    if (typeof key == 'string') {
      emitter.off(key)
      return
    }
    emitter.off(key as number)
  }
}
