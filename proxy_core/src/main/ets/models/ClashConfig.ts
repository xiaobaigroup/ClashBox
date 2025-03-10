import { LogLevel, ProxyMode } from "./Common"

export interface  UpdateConfigParams{
  "profile-id": string
  config: ClashConfig
  params: ConfigExtendedParams
}
export interface  ConfigExtendedParams{
  "is-patch": boolean
  "is-compatible": boolean
  "selected-map": Record<string, string>
  "override-dns": boolean
  "test-url": string
}

export enum TunnelState {
  Direct = "direct", Global = "global", Rule = "rule", Script = "script", None = "None"
}


const defaultGeoXMap = {
  "mmdb":  "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb",
  "asn": "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb",
  "geoip": "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat",
  "geosite": "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
} as GeoXUrl

const defaultMixedPort = 7890;
const defaultKeepAliveInterval = 30;

export const defaultBypassPrivateRouteAddress = [
  "1.0.0.0/8",
  "2.0.0.0/7",
  "4.0.0.0/6",
  "8.0.0.0/7",
  "11.0.0.0/8",
  "12.0.0.0/6",
  "16.0.0.0/4",
  "32.0.0.0/3",
  "64.0.0.0/3",
  "96.0.0.0/4",
  "112.0.0.0/5",
  "120.0.0.0/6",
  "124.0.0.0/7",
  "126.0.0.0/8",
  "128.0.0.0/3",
  "160.0.0.0/5",
  "168.0.0.0/8",
  "169.0.0.0/9",
  "169.128.0.0/10",
  "169.192.0.0/11",
  "169.224.0.0/12",
  "169.240.0.0/13",
  "169.248.0.0/14",
  "169.252.0.0/15",
  "169.255.0.0/16",
  "170.0.0.0/7",
  "172.0.0.0/12",
  "172.32.0.0/11",
  "172.64.0.0/10",
  "172.128.0.0/9",
  "173.0.0.0/8",
  "174.0.0.0/7",
  "176.0.0.0/4",
  "192.0.0.0/9",
  "192.128.0.0/11",
  "192.160.0.0/13",
  "192.169.0.0/16",
  "192.170.0.0/15",
  "192.172.0.0/14",
  "192.176.0.0/12",
  "192.192.0.0/10",
  "193.0.0.0/8",
  "194.0.0.0/7",
  "196.0.0.0/6",
  "200.0.0.0/5",
  "208.0.0.0/4",
  "240.0.0.0/5",
  "248.0.0.0/6",
  "252.0.0.0/7",
  "254.0.0.0/8",
  "255.0.0.0/9",
  "255.128.0.0/10",
  "255.192.0.0/11",
  "255.224.0.0/12",
  "255.240.0.0/13",
  "255.248.0.0/14",
  "255.252.0.0/15",
  "255.254.0.0/16",
  "255.255.0.0/17",
  "255.255.128.0/18",
  "255.255.192.0/19",
  "255.255.224.0/20",
  "255.255.240.0/21",
  "255.255.248.0/22",
  "255.255.252.0/23",
  "255.255.254.0/24",
  "255.255.255.0/25",
  "255.255.255.128/26",
  "255.255.255.192/27",
  "255.255.255.224/28",
  "255.255.255.240/29",
  "255.255.255.248/30",
  "255.255.255.252/31",
  "255.255.255.254/32",
  "::/1",
  "8000::/2",
  "c000::/3",
  "e000::/4",
  "f000::/5",
  "f800::/6",
  "fe00::/9",
  "fec0::/10"
];

export class  ClashConfig {
  "socks-port"?: number;
  "redir-port"?: number;
  "tproxy-port"?: number;
  "mixed-port"?: number = defaultMixedPort;
  "geodata-loader": string = "memconservative" // standard,
  authentication?: string[];
  "allow-lan": boolean = true;
  "bind-address"?: string;
  mode?: ProxyMode = ProxyMode.Rule;
  "log-level"?: LogLevel = LogLevel.Info;
  ipv6: boolean = false;
  "external-controller"?: string;
  "external-controller-tls"?: string;
  "external-controller-cors"?: string;
  secret?: string;
  hosts?: Record<string, string>;
  "keep-alive-interval"?: number = defaultKeepAliveInterval
  "unified-delay"?: boolean = true;
  "geodata-mode"?: boolean;
  "tcp-concurrent"?: boolean;
  "find-process-mode"?: FindProcessMode = FindProcessMode.Off;
  "route-address"?: string[]
  "route-mode"?: RouteMode = RouteMode.Config
  "global-ua": string
  dns?: Dns = new Dns();
  app?: App;
  tun?: Tun = new Tun();
  sniffer?: Sniffer;
  "geox-url"?: GeoXUrl = defaultGeoXMap;
  constructor(ua: string = "clash.meta/1.18.7") {
    this["global-ua"] = ua
  }
}
export enum TunStack { Gvisor = "gVisor", System = "System", Mixed = "Mixed" }

export class Tun {
  enable: boolean = true
  device: string = ""
  stack: TunStack.Gvisor
  "dns-hijack": string[] = ["any:53"]
}

export enum  RouteMode{
  Config,
  BypassPrivate, // route-address is defaultBypassPrivateRouteAddress
}
export class Dns {
  enable?: boolean = false;
  "prefer-h3"?: boolean = false;
  listen?: string;
  ipv6?: boolean = false;
  "use-hosts"?: boolean = true;
  "use-system-hosts"?: boolean = true;
  "respect-rules"?: boolean = false;
  "enhanced-mode"?: DnsEnhancedMode = DnsEnhancedMode.FakeIp;
  "default-nameserver"?: string[] = ["223.5.5.5"]
  nameserver?: string[] = [
    "https://doh.pub/dns-query",
    "https://dns.alidns.com/dns-query",
  ];
  fallback?: string[] = [
    "tls://8.8.4.4",
    "tls://1.1.1.1",
  ];
  "fake-ip-range"?: string = "198.18.0.1/16"
  "fake-ip-filter"?: string[] = [
    "*.lan",
    "localhost.ptlogin2.qq.com",
  ];
  "fake-ip-filter-mode"?: string[];
  "proxy-server-nameserver"?:string[]=[
    "https://doh.pub/dns-query",
  ]
  "fallback-filter": DnsFallbackFilter =  new DnsFallbackFilter();
  "nameserver-policy"?: Record<string, string> = {
    "www.baidu.com": "114.114.114.114",
    "+.internal.crop.com": "10.0.0.1",
    "geosite:cn": "https://doh.pub/dns-query"
  };
}

export class DnsFallbackFilter {
  geoIp?: boolean = true;
  geoIpCode?: string = "CN";
  geosite?: string[] = ["gfw"]
  ipcidr?: string[] = ["240.0.0.0/4"];
  domain?: string[] = [
    "+.google.com",
    "+.facebook.com",
    "+.youtube.com",
  ];
}

export interface App {
  appendSystemDns?: boolean;
}

export enum FindProcessMode {
  Off = "off",
  Strict = "strict",
  Always = "always",
}

export enum DnsEnhancedMode {
  None = "normal",
  Mapping = "redir-host",
  FakeIp = "fake-ip",
}

export class SnifferDefault {
  enable?: boolean = false;
  sniffing?: string[] = [];
  "force-dns-mapping"?: boolean = true;
  "parse-pure-ip"?: boolean = true;
  "override-destination"?: boolean = true;
  "force-domain"?: string[] = [];
  "skip-domain"?: string[] = [];
  "port-whitelist"?: string[] = [];
  "sniff"?: Record<string, Sniff> = {
    "HTTP": {
      ports: ["80", "8080-8880"],
      'override-destination': true
    },
    "TLS": {
      ports: ["443", "8443"]
    },
    "QUIC": {
      ports: ["443", "8443"]
    },
  }
}

export interface  Sniffer {
  enable?: boolean;
  sniffing?: string[];
  "force-dns-mapping"?: boolean;
  "parse-pure-ip"?: boolean;
  "override-destination"?: boolean;
  "force-domain"?: string[];
  "skip-domain"?: string[];
  "port-whitelist"?: string[];
  "sniff"?:Record<string, Sniff>
}
export interface Sniff{
  ports: string[],
  'override-destination'?: boolean
}

export interface GeoXUrl {
  geoip?: string;
  mmdb?: string;
  geosite?: string;
  asn?: string
}

export { LogLevel }

function getPackageInfo() {
  throw new Error("Function not implemented.")
}
