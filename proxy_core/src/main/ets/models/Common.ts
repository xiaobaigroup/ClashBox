
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
  payload : string
}
export enum TrafficUnit{
  KB,
  MB,
  GB,
  TB
}
export class TrafficValue{
  value: string
  unit: TrafficUnit
}

export class Traffic{

  private value: number;
  up: TrafficValue
  down: TrafficValue

  constructor(value: number) {
    this.value = value;
  }

  trafficUpload(): string {
    return this.trafficString(this.scaleTraffic(this.value >>> 32));
  }

  trafficDownload(): string {
    return this.trafficString(this.scaleTraffic(this.value & 0xFFFFFFFF));
  }

  trafficTotal(): string {
    const upload = this.scaleTraffic(this.value >>> 32);
    const download = this.scaleTraffic(this.value & 0xFFFFFFFF);

    return this.trafficString(upload + download);
  }

  private trafficString(scaled: number): string {
    if (scaled > 1024 * 1024 * 1024 * 100) {
      const data = scaled / 1024 / 1024 / 1024;
      return `${(data / 100).toFixed(2)} GiB`;
    } else if (scaled > 1024 * 1024 * 100) {
      const data = scaled / 1024 / 1024;
      return `${(data / 100).toFixed(2)} MiB`;
    } else if (scaled > 1024 * 100) {
      const data = scaled / 1024;
      return `${(data / 100).toFixed(2)} KiB`;
    } else {
      return `${scaled} Bytes`;
    }
  }

  private scaleTraffic(value: number): number {
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

