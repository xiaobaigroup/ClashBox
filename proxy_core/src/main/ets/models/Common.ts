
export interface Provider {
  name: string;
  type: ProviderType;
  path: string
  "subscription-info": SubscriptionInfo,
  "vehicle-type": VehicleType;
  "update-at": number;
}
export enum ProviderType {
  Proxy = "Proxy",
  Rule = "Rule"
}
export enum VehicleType {
  HTTP = "HTTP",
  File = "File",
  Compatible = "Compatible"
}


export class SubscriptionInfo{
  upload = 0
  download = 0
  total = 0
  expire = 0
  static formHString(info: string | undefined): SubscriptionInfo{
    const si = new SubscriptionInfo()
    if (!info)
      return si
    const list = info.split(";");
    const map = {} as  Record<string, number>;
    for (let i of list) {
      const keyValue = i.trim().split("=");
      map[keyValue[0]] = parseInt(keyValue[1]);
    }
    si.upload = map["upload"] ?? 0
    si.download = map["download"] ?? 0
    si.total = map["total"] ?? 0
    si.expire = map["expire"] ?? 0
    return si
  }
}

export enum ProxySort {
  Default = "Default", Title = "Title", Delay = "Delay"
}

export enum ProxyMode { Global ="GLOBAL", Rule = "RULE", Direct = "DIRECT" }
export enum ProxyType {
  Direct = "Direct",
  Reject = "Reject",
  RejectDrop = "RejectDrop",
  Compatible = "Compatible",
  Pass = "Pass",

  Shadowsocks = "Shadowsocks",
  ShadowsocksR = "ShadowsocksR",
  Snell = "Snell",
  Socks5 = "Socks5",
  Http = "Http",
  Vmess = "Vmess",
  Vless = "Vless",
  Trojan = "Trojan",
  Hysteria = "Hysteria",
  Hysteria2 = "Hysteria2",
  Tuic = "Tuic",
  WireGuard = "WireGuard",
  Dns = "Dns",
  Ssh = "Ssh",

  Relay = "Relay",
  Selector = "Selector",
  Fallback = "Fallback",
  URLTest = "URLTest",
  LoadBalance = "LoadBalance",

  Unknown = "Unknown"
}
export interface Proxy {
  name: string
  type: ProxyType;
  latency?: number
  id?: string
  g?: string
  isShowFavoriteProxy?: boolean
}

export interface ProxyGroup{
  type: ProxyType
  name: string
  proxies: Array<Proxy>
  now: string
  hidden?: boolean
  icon?: string
}
export enum OverrideSlot{
  Persist, Session
}

export interface FetchInfo{
  type: string
  value: string
}

export enum LogLevel {
  Debug = "debug",
  Info = "info",
  Warning = "warning",
  Error = "error",
  Silent = "silent",
  Unknown = "unknown"
}
export class LogInfo{
  logLevel: LogLevel
  payload: string
  time: number
}
export enum TrafficUnit{
  KB = "kb",
  MB= "m",
  GB= "g",
  TB= "t",
  B = "b"
}
export class TrafficValue{
  value: number
  show: number
  unit: TrafficUnit
  constructor(value: number) {
    this.value = value ?? 0
    if (this.value > Math.pow(1024, 4)) {
      this.show = (this.value / Math.pow(1024, 4))
      this.unit = TrafficUnit.TB
    }else if (this.value > Math.pow(1024, 3)) {
      this.show = (this.value / Math.pow(1024, 3))
      this.unit = TrafficUnit.GB
    }else if (this.value > Math.pow(1024, 2)) {
      this.show = (this.value / Math.pow(1024, 2))
      this.unit = TrafficUnit.MB
    }else if (this.value > Math.pow(1024, 1)) {
      this.show = (this.value / Math.pow(1024, 1))
      this.unit = TrafficUnit.KB
    } else{
      this.show = this.value
      this.unit = TrafficUnit.B
    }
  }
  toString(){
    return this.show.toFixed(0)  + " " + this.unit
  }

}

export class Traffic{
  upRaw: number;
  downRaw: number;
  up: TrafficValue
  down: TrafficValue

  constructor(up: number, down: number) {
    this.upRaw = up ?? 0;
    this.downRaw = down ?? 0;
    this.up = new TrafficValue(up)
    this.down = new TrafficValue(down)
  }

  static FetchUp(value: number){
      return Traffic.ScaleTraffic(value >>> 32)
  }
  static FetchDown(value: number){
    return Traffic.ScaleTraffic(value & 0xFFFFFFFF)
  }
  static ScaleTraffic(value: number): number {
    const type = (value >>> 30) & 0x3;
    const data = value & 0x3FFFFFFF;

    switch (type) {
      case 0:
        return data;
      case 1:
        return data * 1024;
      case 2:
        return data * 1024 * 1024;
      case 3:
        return data * 1024 * 1024 * 1024;
      default:
        throw new Error("Invalid value type");
    }
  }
}
export class IpInfo {
  ip: string
  country: string
}



