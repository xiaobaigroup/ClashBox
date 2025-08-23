import { rcp } from "@kit.RemoteCommunicationKit";
import { JSON } from "@kit.ArkTS";
import { http } from "@kit.NetworkKit";

// TODO 可添加其他来源
const IpCountryList: IpResolver[] = [{
  url: "https://api.vore.top/api/IPdata?ip=",
  resolve: (json, text)=>{
    return json["ipdata"]["info1"] as string
  }
}]
const ipInfoSources: IpResolver[]  = [
  {
    url: "https://api.vore.top/api/IPdata?ip=",
    resolve: (json, text)=>{
      return json["ipinfo"]["text"] as string
    }
  },
  {
    url: "https://ipwho.is/",
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
  },

];

export async function CallIpResolver(ip: string | undefined, resolver: IpResolver | string): Promise<string | null>{
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
}
export async function queryIpInfo(ip: string){
  for (let resolver of IpCountryList) {
    const result = await CallIpResolver(ip, resolver)
    console.log(`IPtest #queryIpInfo result: ${result}`)
    if (!result)
      continue
    return result
  }
  return "";
}
export async function checkIp() {
  for (let source of ipInfoSources) {
    console.log(`IPtest #checkIp source: ${JSON.stringify(source)}`)
    const result = await CallIpResolver(undefined, source)
    console.log(`IPtest #checkIp result: ${result}`)
    if (!result || result == "")
      continue
    return result
  }
  return "Unknown"
}

export interface IpResolver{
    url: string
    resolve: (json: object, text: string) => string
}