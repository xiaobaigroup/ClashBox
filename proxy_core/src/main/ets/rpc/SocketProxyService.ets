import { socket } from '@kit.NetworkKit';
import {  RpcResult } from './RpcRequest';
import { JSON, util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { ClashRpcType, IClashManager, ProviderType, Provider } from './IClashManager';
import { FetchInfo, OverrideSlot,
  Proxy,
  ProxyGroup,
  ProxySort,
  ProxyType,
  Traffic,
  UsedProxy } from '../models/Common';
import { promptAction, PromptAction } from '@kit.ArkUI';
import { TunnelState, UpdateConfigParams } from '../models/ClashConfig';


export class SocketProxyService implements IClashManager{
  context?: common.Context
  init(context: common.Context) {
    this.context = context
  }
  async setLogObserver(observer: (message:string) => void): Promise<()=>void> {
    return this.callbackRequest(ClashRpcType.setLogObserver, [], observer)
  }

  async loadConfig(path: UpdateConfigParams): Promise<string> {
    let result =  await this.sendMessageRequest(ClashRpcType.load, [JSON.stringify(path)])
    return result as string
  }

  async queryTrafficTotal(): Promise<Traffic> {
    let result = await this.sendMessageRequest(ClashRpcType.queryTrafficTotal)
    return new Traffic(result as number);
  }
  async queryTrafficNow(): Promise<Traffic> {
    let result = await this.sendMessageRequest(ClashRpcType.queryTrafficNow)
    return new Traffic(result as number);
  }
  async queryProxyGroups(): Promise<ProxyGroup[]> {
    let result = await this.sendMessageRequest(ClashRpcType.queryProxyGroup,[])
    let map = JSON.parse(result as string) as Record<string, string | Record<string, string[] | string>>
    let groupNames = map[UsedProxy.GLOBAL]["all"] as string[]
    groupNames = ["GLOBAL", ...groupNames]
    groupNames = groupNames.filter(e => {
      const proxy = map[e] as Record<string, string>
      const indexes = ["Selector","URLTest", "Fallback", "LoadBalance", "Relay"].indexOf(proxy["type"])
      return indexes > -1
    })
    const groupsRaw = groupNames.map((groupName) =>{
      const group = map[groupName];
      group["proxies"] = (group["all"] ?? []).map((n:string) =>{
          map[n]["text"] = map[n]["name"]
          return map[n]
      }).filter((d: string) => d != null && d != undefined)
      return {
        name: group["name"] as string,
        now: group["now"] as string,
        type: group["type"] as ProxyType,
        hidden: group["hidden"] == true,
        icon: group["icon"] as string,
        proxies: group["proxies"]
      } as ProxyGroup
    })
    console.log("queryProxyGroups", JSON.stringify(groupsRaw[1]));
    return groupsRaw
  }

  async queryConfiguration(): Promise<string> {
    let result = await this.sendMessageRequest(ClashRpcType.queryConfiguration)
    return result as string
  }

  async queryProviders(): Promise<Provider[]> {
    let result = await this.sendMessageRequest(ClashRpcType.queryProviders)
    return JSON.parse(result as string) as Provider[]
  }

  async patchSelector(group: string, name: string): Promise<boolean> {
    let result = await this.sendMessageRequest(ClashRpcType.patchSelector,[group, name])
    return result as boolean
  }

  async healthCheck(proxyName: string): Promise<void> {
    await this.sendMessageRequest(ClashRpcType.healthCheck, [proxyName, 3000])
  }

  async updateProvider(type: ProviderType, name: string): Promise<void> {
    await this.sendMessageRequest(ClashRpcType.updateProvider,[type, name])
    return
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
        console.log("socketService proxy error" )
        reject("失败")
      })
      const socketPath = this.context?.filesDir + '/flclash.sock'

      client.connect({address: { address: socketPath }, timeout:1000}).then(async ()=>{
        client.send({ data: JSON.stringify({method, params}) });
      }).catch((e:Error)=>{
        console.log("socketService error", e.message)
        promptAction.showToast({message: "rpc失败: " + e.message})
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
        callBack(text.decodeToString(new Uint8Array(value.message)))
      })
      tcp.on('error', (e: Error) => {
        console.log("socketService error", e.message)
        reject("失败")
      });
      const socketPath = this.context?.filesDir + '/ipc_socket'
      tcp.connect({address: { address: socketPath }, timeout:3000}).then(()=>{
        tcp.send({ data: JSON.stringify({method, params}) });
        resolve(()=>{
          tcp.close()
        })
      }).catch((e: Error)=>{
        console.log("socketService error", e.message)
        reject(e)
      });
    })
  }
}

export default new SocketProxyService()