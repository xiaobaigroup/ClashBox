import { socket, vpnExtension } from '@kit.NetworkKit';
import {  RpcResult } from './RpcRequest';
import { JSON, util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { ClashRpcType, IClashManager } from './IClashManager';
import { ConnectionInfo, IpInfo, LogInfo, Provider, ProxyGroup, ProxyMode,
  Traffic } from '../models/Common';
import  fs from  "@ohos.file.fs"
import { fileIo, fileUri } from "@kit.CoreFileKit";
import { promptAction } from '@kit.ArkUI';
import { UpdateConfigParams } from '../models/ClashConfig';
import { checkIp, queryIpInfo } from '../Request';
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
  init(context: common.Context) {
    this.context = context
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
    let result = await checkIp()
    let country = await this.sendMessageRequest(ClashRpcType.getCountryCode, [result])
    if (country == "")
      country = await queryIpInfo(result)
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
  // async startClash(){
  //   let config = await this.ParseConfig();
  //   let tunFd = await this.getTunFd(config)
  //   // this.callbackRequest(ClashRpcType.startClash, [tunFd], (res)=>{
  //   //   console.log("ClashVPN", `startClash : ${res}`)
  //   // })
  //   //this.startClashNew(tunFd);
  //   return true
  // }
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
  //
  // async ParseConfig(): Promise<VpnConfig> {
  //   let vpnConfig = new VpnConfig();
  //   let option = await this.getVpnOptions()
  //   if (option.ipv4Address != "") {
  //     vpnConfig.addresses[0].address = new Address(option.ipv4Address.split("/")[0], 1)
  //     option.routeAddress?.filter((a:string) => isIpv4(a)).map((f:string) => f.split("/")[0])
  //   }
  //   if (option.ipv6Address != ""){
  //     vpnConfig.addresses[0].address = new Address(option.ipv6Address.split("/")[0], 2)
  //     option.routeAddress?.filter((a:string) => isIpv6(a)).map((f:string) => f.split("/")[0])
  //   }
  //   if(option.accessControl?.mode){
  //     if(option.accessControl?.mode == "AcceptSelected"){
  //       vpnConfig.trustedApplications = option.accessControl?.acceptList
  //     }else{
  //       vpnConfig.blockedApplications = option.accessControl?.rejectList
  //     }
  //   }
  //   if(option.systemProxy || option.allowBypass){
  //     // TODO ohos 不支持
  //     // not use option.bypassDomain option.port
  //   }
  //   console.debug("vpnConfig", JSON.stringify(vpnConfig))
  //   return vpnConfig;
  // }

  // startClashNew(tunFd:number){
  //   let tcp: socket.LocalSocket = socket.constructLocalSocketInstance();
  //   tcp.on('message', async (value: socket.LocalSocketMessageInfo) => {
  //     let text = new util.TextDecoder()
  //     let dd = text.decodeToString(new Uint8Array(value.message))
  //     console.log("ClashVPN", `protect: ${dd}`)
  //     try {
  //       let json = JSON.parse(dd) as RpcResult
  //       //let fd = JSON.parse(json.result as string) as Fd
  //       // await this.vpnConnection?.protect(fd.value)
  //       // setFdMap(fd.id)
  //     }catch (e) {
  //       console.error("ClashVPN protect error", e.message, dd)
  //     }
  //   })
  //   const socketPath = this.context?.filesDir + '/clash_go.sock'
  //   console.log("ClashVPN", `connect: ${socketPath}}`)
  //   tcp.connect({address: { address: socketPath }, timeout:1000}).then(()=>{
  //     console.log("ClashVPN", `connect: ${tunFd}`)
  //     tcp.send({ data: JSON.stringify({method: ClashRpcType.startClash, params:[tunFd]}) });
  //   }).catch((e: Error)=>{
  //     console.error("ClashVPN", `error: ${e}`)
  //   })
  // }
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
        promptAction.showToast({message: json.error})
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
      }, 9000)
      client.on("error", ()=>{
        reject("rpc client error")
      })
      // {"proxy-name":"♻️自动选择","timeout":3000}
      let socketPath = this.context?.filesDir + '/clash_go.sock'
      if (method == ClashRpcType.startClash || method == ClashRpcType.stopClash){
        socketPath = this.context?.filesDir + '/ClashBox.sock'
      }
      if(!await fileIo.access(socketPath, fs.AccessModeType.EXIST))
      {
        promptAction.showToast({message: "VPN服务启动失败"})
        reject("")
        return;
      }
      client.connect({address: { address: socketPath }, timeout:1000}).then(async ()=>{
        this.active = true
        client.send({ data: JSON.stringify({method, params}) });
      }).catch((e:Error)=>{
        this.active = false
        this.offlineTime.push(Date.now())
        console.error("vpn服务启动失败", e.message, e.stack)
        if(e.message == "Connection refused"){
          promptAction.showToast({message: "VPN服务被系统干掉了"})
        }else{
          promptAction.showToast({message: "vpn服务失败: " + e.message})
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