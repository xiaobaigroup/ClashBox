import { socket } from '@kit.NetworkKit';
import { RpcRequest } from './RpcRequest';
import {  util } from '@kit.ArkTS';
import json from '@ohos.util.json';
import { ClashRpcType } from './IClashManager';
import { getProxies, getTraffic, initClash, updateConfig
} from 'libflclash.so';
import { common } from '@kit.AbilityKit';
import { OverrideSlot } from '../models/Common';
import { ClashVpnService } from './ClashVpnService';
import { getHome } from '../appPath';

export class SocketStubService {
  server: socket.LocalSocketServer = socket.constructLocalSocketServerInstance();
  clientPool: Map<number, socket.LocalSocketConnection>

  constructor() {
    this.clientPool = new Map()
  }
  async onRemoteMessageRequest(client: socket.LocalSocketConnection, message: socket.LocalSocketMessageInfo): Promise<void>{
    let decoder = new util.TextDecoder()
    let request = json.parse(decoder.decodeToString(new Uint8Array(message.message))) as RpcRequest
    let code = request.method
    let params = request.params
    console.debug("socketService stub request", JSON.stringify(request))
    if(code == ClashRpcType.setLogObserver){
      // 订阅日志，需要持续输出
      // nativeSubscribeLogcat((value: string)=>{
      //   this.sendClient(client, value)
      // })
    } else {
      try {
        let result = await this.onRemoteMessage(code, params)
        console.debug("socketService stub result", result)
        this.sendClient(client, json.stringify({ result: result}))
      } catch (e) {
        console.error("socketService stub error", e.message, e.stack)
        this.sendClient(client, json.stringify({ result: e.message}))
      }
    }
  }
  onRemoteMessage(code: number, data: (string | number| boolean)[]): Promise<string | number | boolean> {
    // 根据code处理客户端的请求
    return new Promise(async (resolve, reject) => {
      switch (code){
        case ClashRpcType.queryTunnelState: {
          //resolve(nativeQueryTunnelState())
          break;
        }
        case ClashRpcType.queryTrafficTotal:{
          //resolve(nativeQueryTrafficTotal())
          break;
        }
        case ClashRpcType.queryTrafficNow:{
          //resolve(nativeQueryTrafficNow())
          break;
        }
        case ClashRpcType.queryProxyGroup:{
          resolve(getProxies())
          break;
        }
        case ClashRpcType.queryProviders:{
          //resolve(nativeQueryProviders())
          break;
        }
        case ClashRpcType.patchSelector:{
          //resolve(nativePatchSelector(data[0] as string, data[1] as string))
          break;
        }
        case ClashRpcType.healthCheck:{
          // nativeHealthCheck(data[0] as string,(value: string)=>{
          //   resolve(value)
          // })
          break;
        }
        case ClashRpcType.updateProvider:{
          // nativeUpdateProvider(data[0] as string, data[1] as string,()=>{
          //   resolve(true)
          // })
          break;
        }
        case ClashRpcType.queryOverride:{
          //resolve(nativeReadOverride(data[0] as number))
          break;
        }
        case ClashRpcType.patchOverride:{
          //nativeWriteOverride(data[0] as number, data[1] as string)
          resolve(true)
          break;
        }
        case ClashRpcType.clearOverride:{
          //nativeClearOverride(data[0] as number)
          resolve(true)
          break;
        }
        case ClashRpcType.queryConfiguration:{
          //resolve(nativeQueryConfiguration())
          break;
        }
        case ClashRpcType.load:{
          updateConfig(data[0] as string).then(e=>{
            resolve(e)
          })
          break;
        }
        case ClashRpcType.reset:{
          resolve(true)
          break;
        }
        case ClashRpcType.startClash: {
          this.startVpn().then((r)=>{
            resolve(r)
          }).catch((e:Error)=>{
            reject(e)
          })
          break;
        }
        case ClashRpcType.stopClash:{
          this.stopVpn()
          resolve(true)
          break;
        }
      }
    })
  }
  async sendClient(client: socket.LocalSocketConnection, message: string){
    await client.send({data: message, encoding:"utf-8"})
  }
  async startService(context: common.Context){
    try {
      this.vpnService.init(context)
      initClash(await getHome(context), "1.0.0")
      const socketPath = context.filesDir + '/flclash.sock'
      await this.server.listen({ address: socketPath})
      this.server.on('connect', (client: socket.LocalSocketConnection) => {
          this.clientPool.set(client.clientId, client);
          client.on("message", (value: socket.LocalSocketMessageInfo) => {
            this.onRemoteMessageRequest(client, value)
          })
          client.on('close', () => {
            client.off("message")
            client.off("close")
            this.clientPool.delete(client.clientId);
          });
      })
    } catch (e) {
      console.error("socketService failure", e.message)
    }
  }
  vpnService = new ClashVpnService()
  startVpn() {
    return this.vpnService.StartVpn()
  }
  stopVpn(){
    this.vpnService.stopVpn()
  }
}
function sleepTime(timeout = 100): Promise<void>{
  return new Promise((resolve)=>{
    setTimeout(resolve, timeout)
  })
}