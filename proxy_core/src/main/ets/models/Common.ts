
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
  static GetTotal(info: SubscriptionInfo): TrafficValue{
    if(!info)
      return
    return new TrafficValue(info["Total"] ?? info.total ?? 0)
  }
  static GetUsed(info: SubscriptionInfo): TrafficValue{
    if (!info)
      return
    return new TrafficValue((info["Upload"] ?? info.upload) + (info["Download"] ?? info.download ?? 0))
  }
  static getExpire(info: SubscriptionInfo): number{
    if(!info)
      return
    var expire =  (info["Expire"] ?? info.expire);
    if(isTimestampInSeconds(expire)){
      return expire * 1000
    }else
      return expire;
  }

}


function isTimestampInSeconds(timestamp) {
  // 将时间戳转为数字
  const ts = Number(timestamp);

  // 获取当前时间戳（毫秒）
  const nowMs = Date.now();
  const nowS = Math.floor(nowMs / 1000);

  // 计算时间差（绝对值）
  const diffToNowMs = Math.abs(nowMs - ts);
  const diffToNowS = Math.abs(nowS - ts);

  // 如果与当前毫秒时间戳的差距更小，则判断为毫秒
  // 或者如果时间戳大于 10^12（常见毫秒时间戳阈值）
  if (ts > 1e12) {
    return false; // 毫秒
  } else if (ts < 1e10) {
    return true;  // 秒
  }

  // 模糊判断：看哪个更接近当前时间
  return diffToNowS < diffToNowMs;
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
  display: string
  name: string
  type: ProxyType;
  latency?: number
  id?: string
  g?: string
  icon?: string
}

export interface ProxyGroup {
  type: ProxyType
  name: string
  display: string
  proxies: Array<Proxy>
  now: string
  id?: string
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
  KB = "KB",
  MB= "MB",
  GB= "GB",
  TB= "TB",
  B = "B"
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
export interface Snapshot{
  downloadTotal: number
  uploadTotal: number
  connections: ConnectionInfo
  memory: number
}
export  interface Metadata{
  uid: number
  network: string
  sourceIP: string
  sourcePort: string
  destinationIP: string
  destinationPort: string
  host: string
  process: string
  remoteDestination: string
}
export interface ConnectionInfo{
  id: string
  metadata : Metadata
  upload : number
  download : number
  start: number
  chains: string[]
  rule : string
  rulePayload : string
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

  total(): TrafficValue{
    return new TrafficValue(this.upRaw + this.downRaw)
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
  ipv6?: string
}

/**
 * IP 质量信息（来源 ip.net.coffee /api/ip/lookup/{ip}）
 * 用于主页节点信息大卡片展示：家宽/机房识别、ASN、信任评分、风险标记等
 */
export class IpQualityInfo {
  ip: string
  /** 信任评分 0-100，越高越可信 */
  trustScore: number = -1
  /** 是否机房/数据中心 IP */
  isDatacenter: boolean = false
  /** 是否住宅 IP（家宽） */
  isResidential: boolean = false
  /** 是否 VPN 出口 */
  isVpn: boolean = false
  /** 是否代理出口 */
  isProxy: boolean = false
  /** 是否 Tor 出口 */
  isTor: boolean = false
  /** 是否爬虫/滥用 */
  isCrawler: boolean = false
  isAbuser: boolean = false
  isMobile: boolean = false
  /** 机构类型：hosting / isp / education / business 等 */
  companyType: string = ''
  /** 机构名称 */
  companyName: string = ''
  /** ASN 编号 */
  asn: number = 0
  /** ASN 机构名 */
  asOrganization: string = ''
  /** 国家码（小写） */
  countryCode: string = ''
  country: string = ''
  region: string = ''
  city: string = ''
  /** 反向 DNS */
  rdns: string = ''
  /** CIDR 段 */
  cidr: string = ''
}



