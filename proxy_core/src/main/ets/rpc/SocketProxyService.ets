import { socket, vpnExtension } from '@kit.NetworkKit';
import {  RpcResult } from './RpcRequest';
import { JSON, util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { ClashRpcType, IClashManager, VpnRawOptions } from './IClashManager';
import { ConnectionInfo, IpInfo, LogInfo, Provider, ProxyGroup, ProxyMode,
  Traffic } from '../models/Common';
import  fs from  "@ohos.file.fs"
import { fileIo, fileUri } from "@kit.CoreFileKit";
import { PromptAction } from '@kit.ArkUI';
import { UpdateConfigParams } from '../models/ClashConfig';
import { checkIp, queryCurrentIpInfo } from '../Request';
import { Fd, ParseProxyGroup, VpnOptions } from './FlClashVpnService';
import { getVpnOptions, setFdMap } from 'libflclash.so';
import { Address, isIpv4, isIpv6, VpnConfig } from './CommonVpnService';

interface DelayInfo{
  name: string
  value: number
}
interface Snapshot{
  connections: ConnectionInfo[]
}
interface TrafficInfo{
  up: number
  down: number
}



export class SocketProxyService implements IClashManager {
  context?: common.Context
  active: boolean = false
  offlineTime: number[] = []
  static promptAction: PromptAction
  init(context: common.Context, promptAction: PromptAction) {
    this.context = context
    SocketProxyService.promptAction = promptAction
  }
  async setLogObserver(observer: (message: LogInfo) => void): Promise<()=>void> {
    return this.callbackRequest(ClashRpcType.setLogObserver, [], (message)=>{
        if(message != ""){
          observer(JSON.parse(message) as LogInfo)
        }
    })
  }
  async registerMessage(observer: (message: string) => void): Promise<()=>void> {
    return this.callbackRequest(ClashRpcType.registerOnMessage, [], observer)
  }
  async loadConfig(config: UpdateConfigParams): Promise<string> {
    config['profile-id'] = config['profile-id'] + "/config"
    let result =  await this.sendMessageRequest(ClashRpcType.load, [JSON.stringify(config)])
    return result as string
  }
  async vailConfig(filepath: string){
    let result = await this.sendMessageRequest(ClashRpcType.validConfig, [filepath])
    return result as string;
  }
  async queryTrafficTotal(onlyProxy: boolean): Promise<Traffic> {
    let result = await this.sendMessageRequest(ClashRpcType.queryTrafficTotal, [onlyProxy])
    const json = JSON.parse(result as string) as TrafficInfo
    return new Traffic(json.up, json.down);
  } 
  async queryTrafficNow(onlyProxy: boolean): Promise<Traffic> {
    let result = await this.sendMessageRequest(ClashRpcType.queryTrafficNow,  [onlyProxy])
    const json = JSON.parse(result as string) as TrafficInfo
    return new Traffic(json.up, json.down);
  }

  async checkIpInfo(): Promise<IpInfo> {
    // let result = await checkIp()
    // let country = await queryIpInfo(result)
    // console.log(`IPtest SocketProxyService#checkIpInfo country: ${country}`)
    // if (country == "")
    //   country = await this.sendMessageRequest(ClashRpcType.getCountryCode, [result]) as string

    const ipInfo = await queryCurrentIpInfo()
    
    if (ipInfo) {
      console.log(`IPtest SocketProxyService#checkIpInfo IP: ${ipInfo.ip}, Country: ${ipInfo.country}`)
      return {
        ip: ipInfo.ip,
        country: ipInfo.country
      } as IpInfo
    }
    
    // 如果所有 API 都失败，尝试使用本地方法获取
    console.warn(`IPtest SocketProxyService#checkIpInfo 所有 API 请求失败，尝试本地方法`)
    const result = await checkIp()
    const country = await this.sendMessageRequest(ClashRpcType.getCountryCode, [result]) as string

    return {
      ip: result,
      country: country
    } as IpInfo
  }
  async queryConnections(): Promise<ConnectionInfo[]> {
    let result = await this.sendMessageRequest(ClashRpcType.queryConnections)
    const json = JSON.parse(result as string) as Snapshot
    return json.connections ?? [];
  }
  async getRequestList(): Promise<ConnectionInfo[]>{
    let result = await this.sendMessageRequest(ClashRpcType.getRequestList)
    return JSON.parse(result as string) as ConnectionInfo[]
  }
  async  clearRequestList(): Promise<boolean>{
    await this.sendMessageRequest(ClashRpcType.clearRequestList)
    return true
  }
  async closeConnection(id: string): Promise<string> {
    let result = await this.sendMessageRequest(ClashRpcType.closeConnection, [id])
    return result as string;
  }
  async clearConnections(): Promise<ConnectionInfo[]> {
    let result = await this.sendMessageRequest(ClashRpcType.clearConnections)
    const json = JSON.parse(result as string) as ConnectionInfo[]
    return json;
  }

  async queryProxyGroups(model: ProxyMode): Promise<ProxyGroup[]> {
    let result = await this.sendMessageRequest(ClashRpcType.queryProxyGroup,[model])
    return ParseProxyGroup(model, result as string)
  }
  async queryProviders(): Promise<Provider[]> {
    let result = await this.sendMessageRequest(ClashRpcType.queryProviders)
    return JSON.parse(result as string) as Provider[]
  }
  async getVpnOptions(): Promise<VpnOptions> {
    let result = await this.sendMessageRequest(ClashRpcType.vpnOptions)
    return JSON.parse(result as string) as VpnOptions
  }
  async setOptionStates(options: VpnRawOptions): Promise<string> {
    let result = await this.sendMessageRequest(ClashRpcType.setOptionState, [JSON.stringify(options)])
    return result as string
  }
  async updateProvider(provider: Provider): Promise<string> {
    return  (await this.sendMessageRequest(ClashRpcType.updateProvider,[provider.name])) as string
  }
  async upLoadProvider(provider: Provider, uri: string): Promise<string> {
    const temp = this.context?.filesDir + "/temp_provider"
    fs.copy(uri, fileUri.getUriFromPath(temp))
    return  (await this.sendMessageRequest(ClashRpcType.uploadProvider,[provider.name, temp])) as string
  }
  async updateGeoData(geoName: string, geoType: string): Promise<string>{
    return await (this.sendMessageRequest(ClashRpcType.updateGeoData,[geoName, geoType])) as string
  }
  async changeProxy(group: string, name: string): Promise<string> {
    let result = await this.sendMessageRequest(ClashRpcType.changeProxy,[group, name])
    return result as string
  }
  async healthCheck(proxyName: string): Promise<number> {
    let result = await this.sendMessageRequest(ClashRpcType.healthCheck, [proxyName, 3000])
    let info = JSON.parse(result as string) as DelayInfo
    return info.value
  }

  async startClash():Promise<boolean>{
    let json = await this.sendMessageRequest(ClashRpcType.startClash, [])
    return json as boolean
  }
  // TODO 返回运行时间,卡片和ui统一使用 需要测试,
  async getRuntime(): Promise<number> {
    let result = await this.sendMessageRequest(ClashRpcType.GetVpnRunTime)
    return result as number
  }
  // TODO startClash前需要调用判断, clash配置是否加载完成,
  // 没有加载,做友好提示,或则先加载clash配置,在启动
  async vpnConfigIsLoad(): Promise<boolean> {
    let result = await this.sendMessageRequest(ClashRpcType.VpnConfigInited)
    return result  == "true"
  }
  vpnConnection : vpnExtension.VpnConnection | undefined
  async getTunFd(config: VpnConfig): Promise<number> {
    let tunFd = -1
    try {
      this.vpnConnection = vpnExtension.createVpnConnection(this.context as common.VpnExtensionContext);
      tunFd = await this.vpnConnection.create(config)
      console.log("ClashVPN", `获取tunFd: ${tunFd}`)
      return tunFd;
    } catch (error) {
      console.log("ClashVPN", `Clash启动失败 ${error.message} => ${error.stack}` )
      this.vpnConnection?.destroy()
      return -1
    }
  }
  async stopClash():Promise<boolean>{
    let json = await this.sendMessageRequest(ClashRpcType.stopClash, [])
    return json as boolean
  }
  async reset():Promise<boolean>{
    let json = await this.sendMessageRequest(ClashRpcType.reset, [])
    return json as boolean
  }
  async ParseMessage(messageBuffer: string, resolve: (s: string| number | boolean | undefined)=>void, reject:  (err: string)=>void){
    try {
      let json = JSON.parse(messageBuffer) as RpcResult
      if (!json.error || json.error == "")
        resolve(json.result)
      else{
        SocketProxyService.promptAction.showToast({message: JSON.stringify(json.error)})
        resolve(json.error)
      }
    } catch (e) {
      console.error("ParseMessage", e, messageBuffer)
      reject("JSON解码失败: " + JSON.stringify(e))
    }
  }
  async sendMessageRequest(
    method: number,
    params: (string| number | boolean) [] = []
  ): Promise<string| number | boolean | undefined>{
    console.log("sendMessageRequest " + method)
    return new Promise(async (resolve, reject)=>{
      let client: socket.LocalSocket = socket.constructLocalSocketInstance();
      let text = new util.TextDecoder()
      let fullMessage = '';
      let timeout = true
      let parseMessage = debounce((message)=>{
        timeout = false
        this.ParseMessage(message.replace("EOF",""), resolve, reject)
        message = ''
        fullMessage = ''
        client.close()
      }, 200)
        client.on('message', async (value: socket.LocalSocketMessageInfo) => {
        let chunk = text.decodeToString(new Uint8Array(value.message),  { stream: true })
        fullMessage += chunk;
        parseMessage(fullMessage)
      })
      setTimeout(()=>{
        if (timeout) {
          reject("请求超时")
          client.close();
        }
      }, 10000)
      client.on("error", ()=>{
        reject("rpc client error")
      })
      // {"proxy-name":"♻️自动选择","timeout":3000}
      let socketPath = this.context?.filesDir + '/clash_go.sock'
      // || method == ClashRpcType.getRuntime 在clash_go里已实现,
      if (method == ClashRpcType.startClash || method == ClashRpcType.stopClash){
        socketPath = this.context?.filesDir + '/ClashBox.sock'
      }
      if(!await fileIo.access(socketPath, fs.AccessModeType.EXIST))
      {
        SocketProxyService.promptAction.showToast({message: "VPN服务启动失败"})
        reject(new Error("VPN服务未启动"))
        return;
      }

      client.connect({address: { address: socketPath }, timeout:1000}).then(async ()=>{
        this.active = true
        client.send({ data: JSON.stringify({method, params}) });
      }).catch((e:Error)=>{
        this.active = false
        console.error("vpn服务启动失败", e.message, e.stack)
        if (e.message == "Connection refused"){
          try {
            SocketProxyService.promptAction.showToast({ message: "VPN服务被系统干掉了" })
          } catch (error) {
            console.error(`VPN服务断开提示弹窗error：${JSON.stringify(error)}`)
          }
        } else {
          try {
            SocketProxyService.promptAction.showToast({ message: "vpn服务失败: " + e.message })
          } catch (error) {
            console.error(`VPN服务失败提示弹窗error：${JSON.stringify(error)}`)
          }
        }
        reject(e)
      });
    })
  }
  async callbackRequest(
    method: number,
    params: (string | number | boolean) [] = [],
    callBack: (message: string) => void
  ): Promise<() => void> {
    return new Promise(async (resolve, reject)=>{
      let tcp: socket.LocalSocket = socket.constructLocalSocketInstance();
      tcp.on('message', (value: socket.LocalSocketMessageInfo) => {
        let text = new util.TextDecoder()
        let dd = text.decodeToString(new Uint8Array(value.message))
        let list = dd.split("EOF")
        for (let index = 0; index < list.length; index++) {
          const element = list[index];
          try {
            if (element != ""){
              let json = JSON.parse(element) as RpcResult
              callBack(json.result as string)
            }
          }catch (e) {
            console.error("log error", e.message, element)
          }
        }
      })
      tcp.on('error', (e: Error) => {
        reject("失败")
      });
      const socketPath = this.context?.filesDir + '/clash_go.sock'
      tcp.connect({address: { address: socketPath }, timeout:3000}).then(()=>{
        tcp.send({ data: JSON.stringify({method, params}) });
        resolve(()=>{
          tcp.close()
        })
      }).catch((e: Error)=>{
        console.log("socketProxy error", e.message)
        reject(e)
      });
    })
  }
}

function debounce(func:(json: string)=>void, delay =100) {
  let timer = 0;
  return (json: string) => {
    clearTimeout(timer);
    timer = setTimeout(() => {
      func(json);
    }, delay);
  };
}

export default new SocketProxyService()