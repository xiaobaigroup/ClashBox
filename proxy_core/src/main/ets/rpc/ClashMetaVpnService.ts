import { vpnExtension, socket } from '@kit.NetworkKit';
import {
  nativeClearOverride,
  nativeFetchAndValid,
  nativeForceGc,
  nativeHealthCheck,
  nativeInit,
  nativeLoad,
  nativePatchSelector,
  nativeQueryConfiguration,
  nativeQueryGroup, nativeQueryGroupNames,
  nativeQueryProviders,
  nativeQueryTrafficNow,
  nativeQueryTrafficTotal, nativeQueryTunnelState,
  nativeReadOverride,
  nativeReset,
  nativeStartTun,
  nativeStopTun,
  nativeSubscribeLogcat,
  nativeUpdateProvider,
  nativeWriteOverride} from 'libclashmeta.so';
import { Address, CommonVpnService, VpnConfig } from './CommonVpnService';
import { JSON, util } from '@kit.ArkTS';
import { RpcRequest } from './RpcRequest';
import { ClashRpcType } from './IClashManager';
import { getHome, getProfileDir, getProfilePath } from '../appPath';
import { UpdateConfigParams } from '../models/ClashConfig';
import { OverrideSlot, Proxy, ProxyGroup, ProxyMode } from '../models/Common';


export class ClashMetaVpnService extends CommonVpnService{
  noVpn: boolean = false // 模拟器开启
  running: boolean = false
  vpnConnection : vpnExtension.VpnConnection | undefined
  public configPath: string = ""
  protectSocketPath: string = ""

  override async onRemoteMessageRequest(client: socket.LocalSocketConnection, message: socket.LocalSocketMessageInfo): Promise<void>{
    let decoder = new util.TextDecoder()
    let request = JSON.parse(decoder.decodeToString(new Uint8Array(message.message))) as RpcRequest
    let code = request.method
    let params = request.params
    console.debug("socketService stub request", JSON.stringify(request))
    if(code == ClashRpcType.setLogObserver){
      // 订阅日志，需要持续输出
      nativeSubscribeLogcat((value)=>{
        this.sendClient(client, value)
      })
    } else {
      try {
        let result = await this.onRemoteMessage(code, params)
        console.debug("socketService stub result", result)
        this.sendClient(client, JSON.stringify({ result: result}))
      } catch (e) {
        console.error("socketService stub error", e.message, e.stack)
        this.sendClient(client, JSON.stringify({ result: e.message}))
      }
    }
  }

  onRemoteMessage(code: number, data: (string | number| boolean)[]): Promise<string | number | boolean> {
    // 根据code处理客户端的请求
    return new Promise(async (resolve, reject) => {
      switch (code){
        case ClashRpcType.queryTunnelState: {
          resolve(nativeQueryTunnelState())
          break;
        }
        case ClashRpcType.queryTrafficTotal:{
          resolve(nativeQueryTrafficTotal())
          break;
        }
        case ClashRpcType.queryTrafficNow:{
          resolve(nativeQueryTrafficNow())
          break;
        }
        case ClashRpcType.queryProxyGroup:{
          let override = JSON.parse(nativeReadOverride(OverrideSlot.Session))
          override["mode"] = data[0]
          nativeWriteOverride(OverrideSlot.Session, JSON.stringify(override))
          let names = JSON.parse(nativeQueryGroupNames(true)) as string[]
          let groups = names.map((gn)=>{
            let d = JSON.parse(nativeQueryGroup(gn, ""))
            return {
              name: gn,
              now: d['now'],
              type: d['type'],
              proxies: d['proxies'].map((p)=>{
                return {
                  type: p['type'],
                  name: p['name'],
                  latency: p['delay']
                } as Proxy
              }),
            } as ProxyGroup
          })
          resolve(JSON.stringify(groups))
          break;
        }
        case ClashRpcType.queryProviders:{
          resolve(nativeQueryProviders())
          break;
        }
        case ClashRpcType.patchSelector:{
          resolve(nativePatchSelector(data[0] as string, data[1] as string))
          break;
        }
        case ClashRpcType.healthCheck:{
          nativeHealthCheck(data[0] as string,(value)=>{
            resolve(value)
          })
          break;
        }
        case ClashRpcType.updateProvider:{
          nativeUpdateProvider(data[0] as string, data[1] as string,()=>{
            resolve(true)
          })
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
          let params = JSON.parse(data[0] as string) as UpdateConfigParams
          let profilePath = await getProfileDir(this.context, params['profile-id'])
          nativeLoad(profilePath, (e)=>{
            resolve(e ?? "")
          })
          break;
        }
        case ClashRpcType.reset:{
          nativeReset()
          resolve(true)
          break;
        }
        case ClashRpcType.startClash: {
          this.startTun().then((r)=>{
            resolve(r)
          }).catch((e:Error)=>{
            reject(e)
          })
          break;
        }
        case ClashRpcType.stopClash:{
          nativeStopTun()
          super.stopVpn()
          resolve(true)
          break;
        }
      }
    })
  }
  async startTun(): Promise<boolean> {
    let config = new VpnConfig(new Address("172.19.0.1", 1), ["172.19.0.2"]);
    let tunFd = -1
    try {
      tunFd = await super.startVpn(config)
      if(tunFd > -1){
        nativeStartTun(tunFd, (fd)=>{
          this.vpnConnection?.protect(fd)
        })
      }
      return true;
    } catch (error) {
      return false
    }
  }

  override async init(){
    nativeInit(await getHome(this.context), "1.0.0")
  }
}


