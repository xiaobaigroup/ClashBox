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

export const defaultMixedPort = 7890;
export const defaultKeepAliveInterval = 30;

/**
 * 默认 hosts 映射(与 entry 层 updateData 共用同一常量, 避免两处重复定义不一致)。
 * ★ 预设已全部移除, hosts 完全交给用户自定义; 新配置 hosts 为空, 不再注入任何内置条目。
 */
export const DEFAULT_HOSTS: Record<string, string> = {};

/**
 * ★ 历史内置 hosts 预设 key 列表(仅供升级迁移清理用)。
 * 旧版本 updateData 曾把这些预设注入配置, 现预设已移除, 升级时据此从用户配置中删除残留条目。
 */
export const LEGACY_HOSTS_KEYS: string[] = [
  'epdg.epc.mnc010.mcc234.pub.3gppnetwork.org',
  'services.googleapis.cn',
  'cn.bing.com',
  'dns.alidns.com',
  'doh.pub',
  'dns.google',
  'cloudflare-dns.com',
  'dns.quad9.net'
];

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
  // "port"?: number = defaultMixedPort;
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
  "external-controller"?: string = '';
  "external-ui" : string = 'ui';
  "external-UIURL" : string = '';
  "external-controller-tls"?: string;
  "external-controller-cors"?: string;
  secret?: string;
  hosts?: Record<string, string> = { ...DEFAULT_HOSTS };
  "keep-alive-interval"?: number = defaultKeepAliveInterval
  "only-proxy"?: boolean = true;
  "unified-delay"?: boolean = true;
  "geodata-mode"?: boolean;
  "tcp-concurrent"?: boolean = false;
  "find-process-mode"?: FindProcessMode = FindProcessMode.Off;
  "route-mode"?: RouteMode = RouteMode.Config
  "global-ua": string
  dns?: Dns = new Dns();
  app?: App;
  tun?: Tun = new Tun();
  sniffer?: Sniffer;
  /** 流量转发隧道列表: 与 mihomo 内核 tunnels 段一致(仿 bettbox Tunnel 功能) */
  tunnels?: TunnelEntry[] = [];
  "geox-url"?: GeoXUrl = defaultGeoXMap;
  overrideDns: boolean = false
  overwriteNetwork: boolean = true
  /** 覆写 Sniffer: 开启后应用 UI 的 sniffer 配置(与 overrideDns 同模式) */
  overrideSniffer: boolean = false
  snifferDefault?: SnifferDefault = new SnifferDefault()
  constructor(ua: string = "clash-verge/v2.5.1") {
    this["global-ua"] = ua
    this.sniffer = this.snifferDefault
  }
}

export enum TunStack { Gvisor = "gVisor", System = "System", Mixed = "Mixed" }

export class Tun {
  enable: boolean = true
  "tun-ip": string = "172.19.0.1/30"
  device: string = ""
  stack: TunStack = TunStack.Mixed
  "auto-route": boolean = true
  "auto-detect-interface": boolean = true
  /** 仅代理模式：TUN 只处理代理流量，直连（DIRECT）流量直接放行（mihomo 专用参数，须在 tun 段） */
  "only-proxy"?: boolean = true
  "strict-route": boolean = false
  "route-address"?: string[] = ["0.0.0.0/1","128.0.0.0/1","::/1","8000::/1"]
  "dns-hijack"?: string[] = ["any:53", "tcp://any:53"]
  /** 最大传输单元: 默认 1400 与 VPN 层 VpnConfig.mtu 保持一致, 范围 1280-65535 */
  mtu: number = 1400
  /** 禁用 ICMP 转发: false=启用转发(ping 经 TUN 代理), true=禁用(防止 ICMP 环回, ping 显示真实延迟) */
  "disable-icmp-forwarding": boolean = false
  /** NAT 增强(Endpoint Independent NAT): 独立映射/过滤, 提升 UDP 等场景的 NAT 兼容性 */
  "endpoint-independent-nat": boolean = false
}

export enum  RouteMode{
  Config,
  BypassPrivate, // route-address is defaultBypassPrivateRouteAddress
}
export class Dns {
  enable?: boolean = false;
  "prefer-h3"?: boolean = false;
  ipv6?: boolean = false;
  "listen"?: string = "0.0.0.0:1053"
  "use-hosts"?: boolean = true;
  "use-system-hosts"?: boolean = true;
  "respect-rules"?: boolean = false;
  "enhanced-mode"?: DnsEnhancedMode = DnsEnhancedMode.FakeIp;
  "default-nameserver"?: string[] = ["223.5.5.5", "119.29.29.29"]
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
  /** mihomo 枚举: blacklist | whitelist | rule */
  "fake-ip-filter-mode"?: string;
  "proxy-server-nameserver"?:string[]=[
    "https://doh.pub/dns-query",
    "https://cloudflare-dns.com/dns-query",
    "8.8.8.8",
    "1.1.1.1"
  ]
  "fallback-filter": DnsFallbackFilter =  new DnsFallbackFilter();
  /** 值支持单个 DNS 字符串或 DNS 数组(mihomo nameserver-policy 值不按逗号拆分, 多 DNS 必须用数组) */
  "nameserver-policy"?: Record<string, string | string[]> = {
    "www.baidu.com": "114.114.114.114",
    "+.internal.crop.com": "10.0.0.1",
    "geosite:cn": "https://doh.pub/dns-query"
  };
  "direct-nameserver"?: string[] = [];
  "direct-nameserver-follow-policy"?: boolean = false;
  /** 缓存算法: mihomo 枚举 lru | lfu | arc (默认 lru) */
  "cache-algorithm"?: string = "lru";
  /** Fake-IP IPv6 范围: 仅 dns.ipv6=true 时生效, 缺省由内核推导 */
  "fake-ip-range6"?: string = "";
  /** fake-ip 有效时间(秒): 默认 1 */
  "fake-ip-ttl"?: number = 1;
  /** fallback 懒查询: false=并发查询(UI 显示"fallback并发"), true=懒查询 */
  "fallback-lazy-query"?: boolean = false;
}

export class DnsFallbackFilter {
  geoip?: boolean = true;
  "geoip-code"?: string = "CN";
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
  enable?: boolean = true;
  sniffing?: string[] = [];
  "force-dns-mapping"?: boolean = true;
  "parse-pure-ip"?: boolean = true;
  "override-destination"?: boolean = false;
  /** 对齐 bettbox: 强制嗅探域名 */
  "force-domain"?: string[] = ['+.v2ex.com'];
  /** 对齐 bettbox: 跳过域名 */
  "skip-domain"?: string[] = ['Mijia Cloud', '+.push.apple.com'];
  /** 对齐 bettbox: 跳过来源 IP */
  "skip-src-address"?: string[] = ['192.168.0.3/32'];
  /** 对齐 bettbox: 跳过目标 IP(Telegram 网段) */
  "skip-dst-address"?: string[] = [
    '91.108.56.0/22',
    '91.108.4.0/22',
    '91.108.8.0/22',
    '91.108.16.0/22',
    '91.108.12.0/22',
    '149.154.160.0/20',
    '91.105.192.0/23',
    '91.108.20.0/22',
    '185.76.151.0/24',
    '2001:b28:f23d::/48',
    '2001:b28:f23f::/48',
    '2001:67c:4e8::/48',
    '2001:b28:f23c::/48',
    '2a0a:f280::/32',
  ];
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
  "skip-src-address"?: string[];
  "skip-dst-address"?: string[];
  "port-whitelist"?: string[];
  "sniff"?:Record<string, Sniff>
}
export interface Sniff{
  ports: string[],
  'override-destination'?: boolean
}

/**
 * 流量转发隧道条目(与 mihomo 内核 tunnels 段字段对齐):
 * network/address/target/proxy 与内核 json key 一致, id 仅用于 UI 列表标识
 */
export class TunnelEntry {
  id: string = ''
  network?: string[] = []
  address?: string = ''
  target?: string = ''
  proxy?: string = ''
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
