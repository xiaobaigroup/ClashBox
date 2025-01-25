import { socket } from '@kit.NetworkKit';
import {  RpcResult } from './RpcRequest';
import { JSON, util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { ClashRpcType, IClashManager } from './IClashManager';
import { IpInfo, LogInfo, Provider, ProxyGroup, ProxyMode,
  Traffic } from '../models/Common';
import { promptAction } from '@kit.ArkUI';
import { UpdateConfigParams } from '../models/ClashConfig';
import { checkIp, queryIpInfo } from '../Request';


export class SocketProxyService implements IClashManager{
  context?: common.Context
  init(context: common.Context) {
    this.context = context
  }
  async setLogObserver(observer: (message: LogInfo) => void): Promise<()=>void> {
    return this.callbackRequest(ClashRpcType.setLogObserver, [], observer)
  }

  async loadConfig(path: UpdateConfigParams): Promise<string> {
    let result =  await this.sendMessageRequest(ClashRpcType.load, [JSON.stringify(path)])
    return result as string
  }
  async queryTrafficTotal(): Promise<Traffic> {
    let result = await this.sendMessageRequest(ClashRpcType.queryTrafficTotal)
    const json = JSON.parse(result as string) as Traffic
    return new Traffic(json.upRaw ?? 1024, json.downRaw ?? 10024);
  }
  async checkIpInfo(): Promise<IpInfo> {
    let result = await checkIp()
    let country = await queryIpInfo(result)
    return {
      ip: result,
      country: country
    } as IpInfo
  }
  async queryTrafficNow(): Promise<Traffic> {
    let result = await this.sendMessageRequest(ClashRpcType.queryTrafficNow)
    const json = JSON.parse(result as string) as Traffic
    return new Traffic(json.upRaw, json.downRaw);
  }
  async queryProxyGroups(model: ProxyMode): Promise<ProxyGroup[]> {
    let result = await this.sendMessageRequest(ClashRpcType.queryProxyGroup,[model])
    console.log("queryProxyGroups",model, result)
    return JSON.parse(result as string) as ProxyGroup[]
  }
  async queryProviders(): Promise<Provider[]> {
    let result = await this.sendMessageRequest(ClashRpcType.queryProviders)
    return JSON.parse(result as string) as Provider[]
  }
  async updateProvider(provider: Provider): Promise<string> {
    return  (await this.sendMessageRequest(ClashRpcType.updateProvider,[JSON.stringify(provider)])) as string
  }
  async updateGeoData(geoName: string, geoType: string): Promise<string>{
    return await (this.sendMessageRequest(ClashRpcType.updateGeoData,[geoName, geoType])) as string
  }
  async changeProxy(group: string, name: string): Promise<string> {
    let result = await this.sendMessageRequest(ClashRpcType.changeProxy,[group, name])
    return result as string
  }

  async healthCheck(proxyName: string): Promise<number> {
    return (await this.sendMessageRequest(ClashRpcType.healthCheck, [proxyName, 3000])) as number
  }


  async startClash():Promise<boolean>{
    let json = await this.sendMessageRequest(ClashRpcType.startClash, [])
    return json as boolean
  }
  async stopClash():Promise<boolean>{
    let json = await this.sendMessageRequest(ClashRpcType.stopClash, [])
    return json as boolean
  }
  async reset():Promise<boolean>{
    let json = await this.sendMessageRequest(ClashRpcType.reset, [])
    return json as boolean
  }

  async sendMessageRequest(
    method: number,
    params: (string| number | boolean) [] = []
  ): Promise<string| number | boolean | undefined>{
    return new Promise(async (resolve, reject)=>{
      let client: socket.LocalSocket = socket.constructLocalSocketInstance();
      let messageBuffer = ""
      client.on('message', async (value: socket.LocalSocketMessageInfo) => {
        let text = new util.TextDecoder()
        let result = text.decodeToString(new Uint8Array(value.message))
        try {
          let json = JSON.parse(messageBuffer + result) as RpcResult
          resolve(json.result)
          client.close();
        } catch (e) {
          messageBuffer += result
        }
      })
      client.on("error", ()=>{
        console.log("socketProxy on error" )
        reject("失败")
      })
      const socketPath = this.context?.filesDir + '/clashNext.sock'

      client.connect({address: { address: socketPath }, timeout:1000}).then(async ()=>{
        client.send({ data: JSON.stringify({method, params}) });
      }).catch((e:Error)=>{
        console.log("socketProxy error", e.message)
        promptAction.showToast({message: "rpc失败: " + e.message})
        reject(e)
      });
    })
  }
  async callbackRequest(
    method: number,
    params: (string | number | boolean) [] = [],
    callBack: (message: LogInfo) => void
  ): Promise<() => void> {
    return new Promise(async (resolve, reject)=>{
      let tcp: socket.LocalSocket = socket.constructLocalSocketInstance();
      tcp.on('message', (value: socket.LocalSocketMessageInfo) => {
        let text = new util.TextDecoder()
        let dd = text.decodeToString(new Uint8Array(value.message))
        try {
          callBack(JSON.parse(dd) as LogInfo)
        } catch (e) {
          console.log("socketProxy error", e, dd)
        }
      })
      tcp.on('error', (e: Error) => {
        console.log("socketProxy error", e.message)
        reject("失败")
      });
      const socketPath = this.context?.filesDir + '/clashNext.sock'
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

export default new SocketProxyService()