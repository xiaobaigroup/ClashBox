import { vpnExtension, socket } from '@kit.NetworkKit';
import {
  nativeHealthCheck,
  nativeInit,
  nativeLoad,
  nativePatchSelector,
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
  nativeWriteOverride } from 'libclashmeta.so';
import { Address, CommonVpnService, VpnConfig } from './CommonVpnService';
import { JSON, util } from '@kit.ArkTS';
import { RpcRequest } from './RpcRequest';
import { ClashRpcType } from './IClashManager';
import { getHome, getProfileDir, getProfilePath } from '../appPath';
import { UpdateConfigParams } from '../models/ClashConfig';
import { LogInfo, OverrideSlot, Provider, Proxy, ProxyGroup, ProxyMode, Traffic } from '../models/Common';


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
        console.log("startLog", value);
        try {
          if (!value.endsWith("}")){
            value += "}"
          }
          const log = JSON.parse(value)
          this.sendClient(client, JSON.stringify({
            logLevel: log["level"],
            payload: log["message"],
            time: log["time"]
          } as LogInfo))
        } catch (e) {
        }
      })
    } else {
      try {
        let result = await this.onRemoteMessage(code, params)
        console.debug("socketService stub result", result)
        this.sendClient(client, JSON.stringify({ result: result }))
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
          const data = nativeQueryTrafficTotal()
          console.debug("queryTrafficTotal", data)
          resolve(JSON.stringify({ upRaw: Traffic.FetchUp(data), downRaw: Traffic.FetchDown(data)} as Traffic))
          break;
        }
        case ClashRpcType.queryTrafficNow:{
          const data = nativeQueryTrafficNow()
          console.debug("nativeQueryTrafficNow", data)
          resolve(JSON.stringify({ upRaw: Traffic.FetchUp(data), downRaw: Traffic.FetchDown(data) } as Traffic))
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
          const result = nativeQueryProviders()
          const list = JSON.parse(result) as Provider[]
          console.log("queryProviders", result)
          resolve(JSON.stringify(list.map(d=> ({
            name: d.name,
            type: d.type,
            path: "",
            "update-at": d["updatedAt"],
            "vehicle-type": d["vehicleType"]
          } as Provider))))
          break;
        }
        case ClashRpcType.changeProxy:{
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
          let provider = JSON.parse(data[0] as string) as Provider
          nativeUpdateProvider(provider.type, provider.name,(v)=>{
            resolve(v)
          })
          break;
        }
        case ClashRpcType.uploadProvider:{
          let provider = data[0] as string
          let path = data[1] as string
          resolve("暂不支持")
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
        case ClashRpcType.getCountryCode:{
          resolve("")
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
          this.startVpn().then((r)=>{
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
  override async startVpn(): Promise<boolean> {
    let config = new VpnConfig(new Address("172.19.0.1", 1), ["172.19.0.2"]);
    let tunFd = -1
    try {
      tunFd = await super.getTunFd(config)
      if(tunFd > -1){
        nativeStartTun(tunFd, (fd)=>{
          this.vpnConnection?.protect(fd)
        })
      }
      return tunFd > -1;
    } catch (error) {
      return false
    }
  }

  override async init(){
    nativeInit(await getHome(this.context), "1.0.0")
  }
}


