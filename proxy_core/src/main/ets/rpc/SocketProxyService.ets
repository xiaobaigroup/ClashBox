import { socket } from '@kit.NetworkKit';
import {  RpcResult } from './RpcRequest';
import { JSON, util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { ClashRpcType, IClashManager } from './IClashManager';
import { ConnectionInfo, IpInfo, LogInfo, Provider, ProxyGroup, ProxyMode,
  Traffic } from '../models/Common';
import { promptAction } from '@kit.ArkUI';
import { UpdateConfigParams } from '../models/ClashConfig';
import { checkIp, queryIpInfo } from '../Request';


export class SocketProxyService implements IClashManager{
  context?: common.Context
  active: boolean = false
  offlineCount: number = 0
  init(context: common.Context) {
    this.context = context
  }
  async setLogObserver(observer: (message: LogInfo) => void): Promise<()=>void> {
    return this.callbackRequest(ClashRpcType.setLogObserver, [], (message)=>{
        observer(JSON.parse(message) as LogInfo)
    })
  }
  async registerMessage(observer: (message: string) => void): Promise<()=>void> {
    return this.callbackRequest(ClashRpcType.registerOnMessage, [], observer)
  }
  async loadConfig(config: UpdateConfigParams): Promise<string> {
    let result =  await this.sendMessageRequest(ClashRpcType.load, [JSON.stringify(config)])
    return result as string
  }
  async vailConfig(config: string){
    let result = await this.sendMessageRequest(ClashRpcType.validConfig, [config])
    return result as string;
  }
  async queryTrafficTotal(): Promise<Traffic> {
    let result = await this.sendMessageRequest(ClashRpcType.queryTrafficTotal)
    const json = JSON.parse(result as string) as Traffic
    return new Traffic(json.upRaw ?? 1024, json.downRaw ?? 1024);
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
    const json = JSON.parse(result as string) as ConnectionInfo[]
    return json;
  }
  async getRequestList(): Promise<ConnectionInfo[]>{
    let result = await this.sendMessageRequest(ClashRpcType.getRequestList)
    return JSON.parse(result as string) as ConnectionInfo[]
  }
  async  clearRequestList(): Promise<boolean>{
    let result = await this.sendMessageRequest(ClashRpcType.clearRequestList)
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
  async queryTrafficNow(): Promise<Traffic> {
    let result = await this.sendMessageRequest(ClashRpcType.queryTrafficNow)
    const json = JSON.parse(result as string) as Traffic
    return new Traffic(json.upRaw, json.downRaw);
  }
  async queryProxyGroups(model: ProxyMode): Promise<ProxyGroup[]> {
    let result = await this.sendMessageRequest(ClashRpcType.queryProxyGroup,[model])
    return JSON.parse(result as  string) as ProxyGroup[]
  }
  async queryProviders(): Promise<Provider[]> {
    let result = await this.sendMessageRequest(ClashRpcType.queryProviders)
    return JSON.parse(result as string) as Provider[]
  }
  async updateProvider(provider: Provider): Promise<string> {
    return  (await this.sendMessageRequest(ClashRpcType.updateProvider,[JSON.stringify(provider)])) as string
  }
  async upLoadProvider(provider: Provider, filePath: string): Promise<string> {
    return  (await this.sendMessageRequest(ClashRpcType.uploadProvider,[provider.name, filePath])) as string
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
  async ParseMessage(messageBuffer: string, resolve: (s: string| number | boolean | undefined)=>void, reject:  (err: string)=>void){
    try {
      let json = JSON.parse(messageBuffer) as RpcResult
      if (!json.error)
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
        console.log("onMessage " + method, message)
        timeout = false
        this.ParseMessage(message, resolve, reject)
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
      const socketPath = this.context?.filesDir + '/clashNext.sock'

      client.connect({address: { address: socketPath }, timeout:1000}).then(async ()=>{
        this.active = true
        client.send({ data: JSON.stringify({method, params}) });
      }).catch((e:Error)=>{
        this.active = false
        this.offlineCount++
        if(e.message == "Connection refused"){
          promptAction.showToast({message: "vpn服务系统被回收!"})
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
        callBack(dd)
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
function appendArrayBuffers(buffer1: ArrayBuffer, buffer2: ArrayBuffer) {
  // 如果其中一个 buffer 是空的，直接返回另一个
  if (buffer1.byteLength === 0) return buffer2;
  if (buffer2.byteLength === 0) return buffer1;

  // 创建一个新的 ArrayBuffer，总长度为两个 buffer 之和
  const resultBuffer = new ArrayBuffer(buffer1.byteLength + buffer2.byteLength);

  // 使用 Uint8Array 视图操作二进制数据
  const resultView = new Uint8Array(resultBuffer);

  // 拷贝 buffer1 和 buffer2 的数据到新 buffer
  resultView.set(new Uint8Array(buffer1), 0);
  resultView.set(new Uint8Array(buffer2), buffer1.byteLength);
  return resultBuffer;
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