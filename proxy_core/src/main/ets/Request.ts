import { rcp } from "@kit.RemoteCommunicationKit";
import { JSON } from "@kit.ArkTS";
import { http } from "@kit.NetworkKit";
import { IpQualityInfo } from "./models/Common";

// ==================== 旧代码已注释，保留作为参考 ====================
// TODO 可添加其他来源
/*const IpCountryList: IpResolver[] = [*//*{
  url: "https://api.vore.top/api/IPdata?ip=",
  resolve: (json, text)=>{
    return json["ipdata"]["info1"] as string
  }
}*//*,{
  url: "https://api.myip.com/",
  resolve: (json, text)=>{
    return json["country"] as string
  }
},{
  url: "https://ipapi.co/json",
  resolve: (json, text)=>{
    return json["country_name"] as string
  }
},{
  url: "https://ident.me/json",
  resolve: (json, text)=>{
    return json["country"] as string
  }
},{
  url: "http://ip-api.com/json",
  resolve: (json, text)=>{
    return json["country"] as string
  }
},{
  url: "https://api.ip.sb/geoip",
  resolve: (json, text)=>{
    return json["country"] as string
  }
},{
  url: "https://ipinfo.io/json",
  resolve: (json, text)=>{
    return json["country"] as string
  }
}]*/
/*const ipInfoSources: IpResolver[]  = [
  // {
  //   url: "https://api.vore.top/api/IPdata?ip=",
  //   resolve: (json, text)=>{
  //     return json["ipinfo"]["text"] as string
  //   }
  // },
  {
    url: "https://api.myip.com/",
    resolve: (json, text)=>{
      return json["ip"] as string
    }
  },
  {
    url:  "https://ipinfo.io/ip",
    resolve: (json, text)=>{
      return text
    }
  },
  {
    url: "https://ifconfig.me/ip/",
    resolve: (json, text)=>{
      return json["ip"] as string
    }
  },,{
  url: "https://ipapi.co/json",
  resolve: (json, text)=>{
    return json["ip"] as string
  }
},{
  url: "https://ident.me/json",
  resolve: (json, text)=>{
    return json["ip"] as string
  }
},{
  url: "http://ip-api.com/json",
  resolve: (json, text)=>{
    return json["query"] as string
  }
},{
  url: "https://api.ip.sb/geoip",
  resolve: (json, text)=>{
    return json["ip"] as string
  }
},{
  url: "https://ipinfo.io/json",
  resolve: (json, text)=>{
    return json["ip"] as string
  }
}
];*/

/*const ipInfoSources: IpResolver[] = [
  {
    url: "https://api.myip.com/",
    resolve: (json, text)=>{
      return json["country"] as string
    }
  },{
  url: "https://ipapi.co/json",
  resolve: (json, text)=>{
    return json["country_name"] as string
  }
},{
  url: "https://ident.me/json",
  resolve: (json, text)=>{
    return json["country"] as string
  }
},{
  url: "http://ip-api.com/json",
  resolve: (json, text)=>{
    return json["country"] as string
  }
},{
  url: "https://api.ip.sb/geoip",
  resolve: (json, text)=>{
    return json["country"] as string
  }
},{
  url: "https://ipinfo.io/json",
  resolve: (json, text)=>{
    return json["country"] as string
  }
}]*/

/*export async function CallIpResolver(ip: string | undefined, resolver: IpResolver | string): Promise<string | null>{
  let httpRequest = http.createHttp()
  const url = typeof resolver == "string" ? resolver as string : resolver.url
  console.log(`IPtest #CallIpResolver 即将请求的原始链接: ${url}`)
  let json = null
  try {
    console.log(`IPtest #CallIpResolver 即将请求的ip: ${ip}, 链接: ${url + (ip != undefined ? ip : '')}`)
    const resp = await httpRequest.request(url + (ip ?? ''), {connectTimeout: 5000, readTimeout: 2000})
    if(resp.responseCode !== 200)
      return null;
    if (typeof resolver == "string" ){
      console.error("CallIpResolver result ", url, resp)
      return resp.result.toString()
    }
    json = resp.result
    console.error("CallIpResolver result ", url, json)
    let result = resolver.resolve(JSON.parse(json), json.toString())
    httpRequest.destroy()
    return result;
  } catch (e) {
    console.error("CallIpResolver error: ", url, e.message, JSON.stringify(e))
    httpRequest.destroy()
    return null
  } finally {
    httpRequest.destroy()
  }
}*/
/*export async function queryIpInfo(ip: string){
  for (let resolver of IpCountryList) {
    const result = await CallIpResolver(ip, resolver)
    console.log(`IPtest #queryIpInfo result: ${result}`)
    if (!result)
      continue
    return result
  }
  return "";
}*/
/*export async function checkIp() {
  for (let source of ipInfoSources) {
    console.log(`IPtest #checkIp source: ${JSON.stringify(source)}`)
    const result = await CallIpResolver(undefined, source)
    console.log(`IPtest #checkIp result: ${result}`)
    if (!result || result == "")
      continue
    return result
  }
  return "Unknown"
}*/

/*export interface IpResolver{
    url: string
    resolve: (json: object, text: string) => string
}*/

// ==================== 新重构的代码 ====================

export interface IpInfo {
  ip: string;
  country: string;
  ipv6?: string;
}

type IpInfoParser = (json: Record<string, any>) => IpInfo | null;

/** IP 信息来源配置 */
const ipInfoSources: Record<string, IpInfoParser> = {
  'https://ipapi.co/json': fromIpApiCoJson, // 此源支持 IPv6 的查询
  'https://api.vore.top/api/IPdata': fromIpDataJson, // 此源是之前默认的源
  'https://ipwho.is': fromIpWhoIsJson,
  'https://api.myip.com': fromMyIpJson,
  'https://ident.me/json': fromIdentMeJson,
  'http://ip-api.com/json': fromIpAPIJson,
  'https://api.ip.sb/geoip': fromIpSbJson,
  'https://ipinfo.io/json': fromIpInfoIoJson,
};

/** IPv6 专用 IP 信息来源（仅查询 IPv6 地址） */
const ipv6Sources: Record<string, IpInfoParser> = {
  'https://api6.ipify.org?format=json': fromIpOnlyJson,
  'https://v6.ident.me/json': fromIdentMeJson,
};

/** 仅解析 IP 地址（无国家信息），用于 api6.ipify.org 等纯 IP 接口 */
function fromIpOnlyJson(json: Record<string, any>): IpInfo | null {
  try {
    const ip = json['ip'] as string;
    if (ip) {
      return { ip, country: '' };
    }
  } catch (e) {
    console.error('fromIpOnlyJson error:', e);
  }
  return null;
}

function fromIpDataJson(json: Record<string, any>): IpInfo | null {
  try {
    const ip = json['ipinfo']['text'] as string;
    const ipdata = json['ipdata'] as object;

    let country = '';
    if (ipdata['info3']) {
      country = ipdata['info3'] as string;
    } else if (ipdata['info2']) {
      country = ipdata['info2'] as string;
    } else if (ipdata['info1']) {
      country = ipdata['info1'] as string;
    }

    if (ip && country) {
      return { ip, country };
    }
  } catch (e) {
    console.error('fromIpWhoIsJson error:', e);
  }
  return null;
}

function fromIpInfoIoJson(json: Record<string, any>): IpInfo | null {
  try {
    const ip = json['ip'] as string;
    const country = json['country'] as string;
    if (ip && country) {
      return { ip, country };
    }
  } catch (e) {
    console.error('fromIpInfoIoJson error:', e);
  }
  return null;
}

function fromIpApiCoJson(json: Record<string, any>): IpInfo | null {
  try {
    const ip = json['ip'] as string;
    const country = json['country_name'] as string;
    if (ip && country) {
      return { ip, country };
    }
  } catch (e) {
    console.error('fromIpApiCoJson error:', e);
  }
  return null;
}

function fromIpSbJson(json: Record<string, any>): IpInfo | null {
  try {
    const ip = json['ip'] as string;
    const country = json['country'] as string;
    if (ip && country) {
      return { ip, country };
    }
  } catch (e) {
    console.error('fromIpSbJson error:', e);
  }
  return null;
}

function fromIpWhoIsJson(json: Record<string, any>): IpInfo | null {
  try {
    const ip = json['ip'] as string;
    const country = json['country'] as string;
    if (ip && country) {
      return { ip, country };
    }
  } catch (e) {
    console.error('fromIpWhoIsJson error:', e);
  }
  return null;
}

function fromMyIpJson(json: Record<string, any>): IpInfo | null {
  try {
    const ip = json['ip'] as string;
    const country = json['country'] as string;
    if (ip && country) {
      return { ip, country };
    }
  } catch (e) {
    console.error('fromMyIpJson error:', e);
  }
  return null;
}

function fromIpAPIJson(json: Record<string, any>): IpInfo | null {
  try {
    const ip = json['query'] as string;
    const country = json['country'] as string;
    if (ip && country) {
      return { ip, country };
    }
  } catch (e) {
    console.error('fromIpAPIJson error:', e);
  }
  return null;
}

function fromIdentMeJson(json: Record<string, any>): IpInfo | null {
  try {
    const ip = json['ip'] as string;
    const country = json['country'] as string;
    if (ip && country) {
      return { ip, country };
    }
  } catch (e) {
    console.error('fromIdentMeJson error:', e);
  }
  return null;
}

/**
 * 请求 IP 信息
 * @param url API 地址
 * @param parser JSON 解析函数
 * @returns IpInfo 或 null
 */
async function requestIpInfo(url: string, parser: IpInfoParser): Promise<IpInfo | null> {
  const httpRequest = http.createHttp();
  try {
    console.log(`IPtest #requestIpInfo 请求 URL: ${url}`);
    const resp = await httpRequest.request(url, {
      connectTimeout: 5000,
      readTimeout: 3000
    });

    if (resp.responseCode !== 200) {
      console.warn(`IPtest #requestIpInfo 请求失败，状态码: ${resp.responseCode}`);
      return null;
    }

    const jsonStr = resp.result.toString();
    const json = JSON.parse(jsonStr) as Record<string, any>;
    console.log(`IPtest #requestIpInfo 响应数据: ${jsonStr}`);

    const result = parser(json);
    if (result) {
      console.log(`IPtest #requestIpInfo 解析成功: IP=${result.ip}, Country=${result.country}`);
    } else {
      console.warn(`IPtest #requestIpInfo 解析失败，JSON 格式不匹配`);
    }

    return result;
  } catch (e) {
    console.error(`IPtest #requestIpInfo 请求异常: ${url}`, e.message);
    return null;
  } finally {
    httpRequest.destroy();
  }
}

/**
 * 查询当前 IP 信息（包含 IP 地址和国家代码）
 * 优化：并行请求所有来源，竞速返回最快结果，同时降低超时时间
 * 额外查询 IPv6 专用来源，获取 IPv6 地址
 * @returns IpInfo 或 null
 */
export async function queryCurrentIpInfo(enableIpv6: boolean = true): Promise<IpInfo | null> {
  const entries = Object.entries(ipInfoSources);
  const CONCURRENT_RACE_TIMEOUT = 2000;

  // ★ 并行发起 IPv6 查询：不阻塞主 IP 返回，避免 IPv6 源无响应时拖慢整个查询
  // 基础-ipv6(clashConfig.ipv6)与网络-ipv6(UIConfig.vpnIpv6)都未开启时 enableIpv6=false,
  // 跳过 IPv6 专用来源查询, 避免未启用 IPv6 仍向外网查询 IPv6 地址
  const ipv6Promise = enableIpv6 ? queryIpv6Info() : Promise.resolve(null);

  const result = await new Promise<IpInfo | null>((resolve) => {
    let settled = false;
    let failedCount = 0;
    const total = entries.length;

    for (const [url, parser] of entries) {
      requestIpInfoFast(url, parser, 1500).then((info: IpInfo | null) => {
        if (settled) return;
        if (info) {
          settled = true;
          resolve(info);
        } else {
          failedCount++;
          if (failedCount >= total) {
            resolve(null);
          }
        }
      });
    }

    setTimeout(() => {
      if (!settled) {
        settled = true;
        resolve(null);
      }
    }, CONCURRENT_RACE_TIMEOUT);
  });

  if (result) {
    // 主 IP 已到手：IPv6 若已在主 IP 竞速期间返回则补充字段，否则立即返回不等待
    const ipv6 = await Promise.race([
      ipv6Promise,
      new Promise<IpInfo | null>((resolve) => {
        setTimeout(() => resolve(null), 0);
      })
    ]);
    if (ipv6 && ipv6.ip) {
      result.ipv6 = ipv6.ip;
    }
    return result;
  }
  console.warn('IPtest #queryCurrentIpInfo 所有来源请求失败');
  return null;
}

/** 查询 IPv6 地址（仅查询 IPv6 专用来源） */
async function queryIpv6Info(): Promise<IpInfo | null> {
  const entries = Object.entries(ipv6Sources);
  for (const [url, parser] of entries) {
    const info = await requestIpInfoFast(url, parser, 1500);
    if (info && info.ip) {
      console.log(`IPtest #queryIpv6Info 获取到 IPv6: ${info.ip}`);
      return info;
    }
  }
  return null;
}

async function requestIpInfoFast(url: string, parser: IpInfoParser, timeout: number): Promise<IpInfo | null> {
  const httpRequest = http.createHttp();
  try {
    const resp = await httpRequest.request(url, {
      connectTimeout: timeout,
      readTimeout: 2000
    });
    if (resp.responseCode !== 200) {
      return null;
    }
    const jsonStr = resp.result.toString();
    const json = JSON.parse(jsonStr) as Record<string, any>;
    return parser(json);
  } catch (e) {
    return null;
  } finally {
    httpRequest.destroy();
  }
}

/**
 * 打断 HTTP 连接复用，确保后续请求使用新的代理节点出口。
 * HarmonyOS 的 HTTP 客户端会基于域名复用已有 TCP 连接（HTTP/1.1 keep-alive），
 * 切换代理节点后如果不打断，IP 查询请求仍走旧节点的出口。
 * 解决方案：对目标域名发起一个超短超时(1ms)请求，超时后会结束复用的 TCP 流，
 * 后续请求将重新建立连接，走新代理节点。
 * 优化：限制并发数 + 整体 300ms 兜底超时，避免 VPN 代理链路下 1ms 请求
 * 实际等待过久，拖慢切换节点后的 IP 查询。
 */
export async function flushHttpConnections(): Promise<void> {
  const urls = Object.keys(ipInfoSources);
  const CONCURRENCY = 3;
  const OVERALL_TIMEOUT = 300;
  let index = 0;
  const worker = async (): Promise<void> => {
    while (index < urls.length) {
      const url = urls[index];
      index++;
      const req = http.createHttp();
      try {
        // 预期会超时失败：仅用于结束该域名的 keep-alive 复用连接
        await req.request(url, { connectTimeout: 1, readTimeout: 1 });
      } catch (e) {
        // 忽略：超时即达到打断目的
      } finally {
        req.destroy();
      }
    }
  };
  const workers: Array<Promise<void>> = [];
  const workerCount = urls.length < CONCURRENCY ? urls.length : CONCURRENCY;
  for (let i = 0; i < workerCount; i++) {
    workers.push(worker());
  }
  await Promise.race([
    Promise.allSettled(workers),
    new Promise<void>((resolve) => {
      setTimeout(resolve, OVERALL_TIMEOUT);
    })
  ]);
}

/**
 * 仅查询 IP 地址（向后兼容旧接口）
 * @deprecated 建议使用 queryCurrentIpInfo() 获取完整信息
 * @param enableIpv6 两开关(基础-ipv6/网络-ipv6)都未开启时传 false, 禁止 IPv6 专用地址查询
 */
export async function checkIp(enableIpv6: boolean = true): Promise<string> {
  const result = await queryCurrentIpInfo(enableIpv6);
  return result ? result.ip : 'Unknown';
}

/**
 * 仅查询国家代码（向后兼容旧接口）
 * @param ip IP 地址（新版本中此参数不再使用）
 * @deprecated 建议使用 queryCurrentIpInfo() 获取完整信息
 */
export async function queryIpInfo(ip: string): Promise<string> {
  const result = await queryCurrentIpInfo();
  return result ? result.country : '';
}

/**
 * 查询当前出口 IP 的质量信息（来源 ip.net.coffee /api/iprisk/{ip}）
 * 返回：家宽/机房识别、ASN、信任评分、VPN/代理/Tor/滥用标记、反向 DNS 等。
 * 该接口无鉴权且 CORS 全开（access-control-allow-origin: *），可客户端直连；
 * CDN 缓存 10 分钟，失败返回 null，不影响主 IP 查询链路。
 * @param ip 待查询的 IP（缺省时先获取当前出口 IP 再查询）
 * @param enableIpv6 两开关(基础-ipv6/网络-ipv6)都未开启时传 false, 禁止 IPv6 专用地址查询
 */
export async function queryIpQuality(ip?: string, enableIpv6: boolean = true): Promise<IpQualityInfo | null> {
  const httpRequest = http.createHttp();
  try {
    // 无参时先获取当前出口 IP
    let targetIp = ip;
    if (!targetIp) {
      const info = await queryCurrentIpInfo(enableIpv6);
      targetIp = info ? info.ip : '';
    }
    if (!targetIp) {
      return null;
    }
    const url = `https://ip.net.coffee/api/iprisk/${encodeURIComponent(targetIp)}`
    const resp = await httpRequest.request(url, {
      connectTimeout: 5000,
      readTimeout: 4000
    });
    if (resp.responseCode !== 200) {
      return null;
    }
    const json = JSON.parse(resp.result.toString()) as Record<string, string | number | boolean>;
    const quality = new IpQualityInfo();
    quality.ip = (json['ip'] as string) ?? '';
    quality.trustScore = json['trust_score'] as number ?? -1;
    quality.isDatacenter = json['is_datacenter'] === true;
    quality.isResidential = json['isResidential'] === true;
    quality.isVpn = json['is_vpn'] === true;
    quality.isProxy = json['is_proxy'] === true;
    quality.isTor = json['is_tor'] === true;
    quality.isCrawler = json['is_crawler'] === true;
    quality.isAbuser = json['is_abuser'] === true;
    quality.isMobile = json['is_mobile'] === true;
    quality.companyType = (json['company_type'] as string) ?? '';
    quality.companyName = (json['company_name'] as string) ?? '';
    quality.asn = json['asn'] as number ?? 0;
    quality.asOrganization = (json['asOrganization'] as string) ?? '';
    quality.countryCode = (json['countryCode'] as string) ?? '';
    quality.country = (json['country'] as string) ?? '';
    quality.region = (json['region'] as string) ?? '';
    quality.city = (json['city'] as string) ?? '';
    quality.rdns = (json['rdns'] as string) ?? '';
    quality.cidr = (json['cidr'] as string) ?? '';
    return quality;
  } catch (e) {
    console.error('IPtest #queryIpQuality 查询失败:', (e as Error).message);
    return null;
  } finally {
    httpRequest.destroy();
  }
}

// ==================== 国家名统一映射 ====================

/** 英文国家名 / ISO 国家码 → 中文（用于通知标题显示 IP 地区） */
const COUNTRY_ZH_MAP: Record<string, string> = {
  'China': '中国', 'CN': '中国',
  'United States': '美国', 'USA': '美国', 'US': '美国',
  'Japan': '日本', 'JP': '日本',
  'Korea': '韩国', 'South Korea': '韩国', 'KR': '韩国',
  'Singapore': '新加坡', 'SG': '新加坡',
  'Hong Kong': '中国香港', 'HK': '中国香港',
  'Taiwan': '中国台湾', 'TW': '中国台湾',
  'Macao': '中国澳门', 'Macau': '中国澳门', 'MO': '中国澳门',
  'Russia': '俄罗斯', 'RU': '俄罗斯',
  'United Kingdom': '英国', 'UK': '英国', 'GB': '英国',
  'Germany': '德国', 'DE': '德国',
  'France': '法国', 'FR': '法国',
  'Australia': '澳大利亚', 'AU': '澳大利亚',
  'Canada': '加拿大', 'CA': '加拿大',
  'Netherlands': '荷兰', 'NL': '荷兰',
  'India': '印度', 'IN': '印度',
  'Malaysia': '马来西亚', 'MY': '马来西亚',
  'Vietnam': '越南', 'VN': '越南',
  'Thailand': '泰国', 'TH': '泰国',
  'Indonesia': '印度尼西亚', 'ID': '印度尼西亚',
  'Philippines': '菲律宾', 'PH': '菲律宾',
  'United Arab Emirates': '阿联酋', 'UAE': '阿联酋',
  'Turkey': '土耳其', 'TR': '土耳其',
  'Italy': '意大利', 'IT': '意大利',
  'Spain': '西班牙', 'ES': '西班牙',
  'Brazil': '巴西', 'BR': '巴西',
  'Poland': '波兰', 'PL': '波兰',
  'Ukraine': '乌克兰', 'UA': '乌克兰',
  'Norway': '挪威', 'NO': '挪威',
  'Sweden': '瑞典', 'SE': '瑞典',
  'Finland': '芬兰', 'FI': '芬兰',
  'Switzerland': '瑞士', 'CH': '瑞士',
  'Ireland': '爱尔兰', 'IE': '爱尔兰',
  'Austria': '奥地利', 'AT': '奥地利',
  'Belgium': '比利时', 'BE': '比利时',
  'New Zealand': '新西兰', 'NZ': '新西兰',
  'Mexico': '墨西哥', 'MX': '墨西哥',
  'Argentina': '阿根廷', 'AR': '阿根廷',
  'Israel': '以色列', 'IL': '以色列',
  'South Africa': '南非', 'ZA': '南非',
  'Saudi Arabia': '沙特阿拉伯', 'SA': '沙特阿拉伯',
  'Egypt': '埃及', 'EG': '埃及',
  'Kazakhstan': '哈萨克斯坦', 'KZ': '哈萨克斯坦',
  'Mongolia': '蒙古', 'MN': '蒙古'
};

/**
 * 将国家名统一为中文显示（供通知标题等场景使用）
 * - 已是中文则原样返回
 * - 英文国家名 / ISO 国家码通过映射表转换
 * - 无法识别的原样返回
 */
export function countryToChinese(country: string): string {
  if (!country) return ''
  const trimmed = country.trim()
  if (!trimmed) return ''
  // 已含中文字符直接返回（如 vore.top 返回的中文地区）
  if (/[\u4e00-\u9fa5]/.test(trimmed)) return trimmed
  return COUNTRY_ZH_MAP[trimmed] ?? trimmed
}