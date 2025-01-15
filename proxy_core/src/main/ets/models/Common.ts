
export enum ProxySort {
  Default = "Default", Title = "Title", Delay = "Delay"
}

export enum UsedProxy { GLOBAL = "GLOBAL", DIRECT = "DIRECT", REJECT = "REJECT" }
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
  name: string;
  type: ProxyType;
  text: string
  latency: number
  id: string
  isShowFavoriteProxy: boolean
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
export class Traffic{
  private value: number;

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

