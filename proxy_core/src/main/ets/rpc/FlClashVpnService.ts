import { vpnExtension, socket } from '@kit.NetworkKit';
import {
  startTun, stopTun, setFdMap, getVpnOptions, startLog, getProxies, getTraffic,
  getTotalTraffic,
  getExternalProviders,
  asyncTestDelay,
  updateConfig,
  initClash,
  changeProxy,
  forceGc,
  updateExternalProvider,
  getCountryCode,
  updateGeoData,
  sideLoadExternalProvider,
  getConnections,
  closeConnections,
  closeConnection,
  validateConfig,
  registerMessage,
  getRequestList,
  clearRequestList,
  startListener,
  stopListener
} from 'libflclash.so';
import { Address, CommonVpnService, isIpv4, isIpv6, VpnConfig } from './CommonVpnService';
import { JSON, util } from '@kit.ArkTS';
import { RpcRequest, RpcResult } from './RpcRequest';
import { ClashRpcType } from './IClashManager';
import { ConnectionInfo, LogInfo, Provider, ProxyGroup, ProxyMode, ProxyType, Traffic } from '../models/Common';
import { getHome, getProfilePath } from '../appPath';
import { Tun, UpdateConfigParams } from '../models/ClashConfig';
import { readFile, readFileUri, readText } from '../fileUtils';
import { startFlClash } from 'libproxy_core.so';

export interface AccessControl {
  mode: string
  acceptList: string[]
  rejectList: string[]
  isFilterSystemApp: boolean
}
export interface VpnOptions {
  enable: boolean,
  port: number,
  ipv4Address: string,
  ipv6Address: string,
  accessControl: AccessControl,
  systemProxy: string,
  allowBypass: boolean,
  routeAddress: string[],
  bypassDomain: string[],
  dnsServerAddress: string,
}


export class FlClashVpnService extends CommonVpnService {
  noVpn: boolean = false // 模拟器开启
  running: boolean = false
  vpnConnection: vpnExtension.VpnConnection | undefined
  public configPath: string = ""
  protectSocketPath: string = ""

  override async onRemoteMessageRequest(client: socket.LocalSocketConnection, message: socket.LocalSocketMessageInfo): Promise<void> {
    let decoder = new util.TextDecoder()
    let request = JSON.parse(decoder.decodeToString(new Uint8Array(message.message))) as RpcRequest
    let code = request.method
    let params = request.params
    console.log(`socket stub ${code} request: `, params)
    if (code == ClashRpcType.setLogObserver) {
      // 订阅日志，需要持续输出
      startLog((message: string, value: string) => {
        if (typeof value === "string") {
          try {
            const log = JSON.parse(value)
            this.sendClient(client, JSON.stringify({
              logLevel: log["data"]["LogLevel"],
              payload: log["data"]["Payload"],
              time: new Date().getTime(),
            } as LogInfo))
          } catch (e) {
            console.error("log error", value)
          }
        }
      })
    } else {
      try {
        console.log(`socket stub ${code} onRemoteMessage: `)
        let result = await this.onRemoteMessage(code, params)
        console.log(`socket stub ${code} result: `, result)
        this.sendClient(client, JSON.stringify({ result: result, error: undefined }))
      } catch (e) {
        console.error(`socket stub ${code} result: `, e.message ?? e, e.stack)
        this.sendClient(client, JSON.stringify({ error: e.message ?? e }))
      }
    }
  }

  onRemoteMessage(code: number, data: (string | number | boolean)[]): Promise<string | number | boolean> {
    // 根据code处理客户端的请求
    return new Promise(async (resolve, reject) => {
      switch (code) {
        case ClashRpcType.queryTrafficTotal: {
          resolve(getTotalTraffic())
          break;
        }
        case ClashRpcType.queryTrafficNow: {
          resolve(getTraffic())
          break;
        }
        case ClashRpcType.queryProxyGroup: {
          let result = getProxies()
          resolve(result)
          break;
        }
        case ClashRpcType.getRequestList: {
          resolve(getRequestList())
          break;
        }
        case ClashRpcType.clearRequestList: {
          clearRequestList()
          resolve(true)
          break;
        }
        case ClashRpcType.changeProxy: {
          resolve(changeProxy(JSON.stringify({
            "group-name": data[0] as string,
            "proxy-name": data[1] as string,
          })))
          break;
        }
        case ClashRpcType.healthCheck: {
          asyncTestDelay(JSON.stringify({
            "proxy-name": data[0] as string,
            timeout: data[1] as string,
          })).then((v) => {
            resolve(v)
          }).catch((e) => {
            console.error("healthCheck error", e)
            resolve(0)
          })
          break;
        }
        case ClashRpcType.queryProviders: {
          const provider = getExternalProviders()
          resolve(provider)
          break;
        }
        case ClashRpcType.updateProvider: {
          const params = JSON.parse(data[0] as string)
          updateExternalProvider(params["name"]).then((v) => {
            resolve(v)
          })
          break;
        }
        case ClashRpcType.uploadProvider: {
          let provider = data[0] as string
          let pathUri = data[1] as string
          const buffer = await readFile(pathUri)
          sideLoadExternalProvider(provider, buffer).then((v) => {
            resolve(v)
          })
          break;
        }
        case ClashRpcType.queryConnections: {
          let v = await getConnections()
          resolve(v)
          break;
        }
        case ClashRpcType.closeConnection: {
          resolve(closeConnection(data[0] as string))
          break;
        }
        case ClashRpcType.clearConnections: {
          resolve(closeConnections())
          break;
        }
        case ClashRpcType.updateGeoData: {
          updateGeoData(data[0] as string, data[1] as string).then((v) => {
            resolve(v)
          })
          break;
        }
        case ClashRpcType.getCountryCode: {
          getCountryCode(data[0] as string).then((v) => {
            resolve(v)
          })
          break;
        }
        case ClashRpcType.load: {
          const parms = JSON.parse(data[0] as string) as UpdateConfigParams
          updateConfig(JSON.stringify(parms)).then(e => {
            resolve(e)
          })
          break;
        }
        case ClashRpcType.reset: {
          forceGc()
          resolve(true)
          break;
        }
        case ClashRpcType.validConfig: {
          const filePath = data[0] as string
          let raw = await readText(filePath)
          resolve(await validateConfig(raw))
          break;
        }
        case ClashRpcType.startClash: {
          startListener()
          this.startVpn().then((r) => {
            resolve(r)
          }).catch((e: Error) => {
            reject(e)
          })
          break;
        }
        case ClashRpcType.stopClash: {
          stopListener()
          this.stopVpn()
          resolve(true)
          break;
        }
        default: {
          resolve("不支持当前操作")
        }
      }
    })
  }

  ParseConfig(): VpnConfig {
    let vpnConfig = new VpnConfig();
    let option = JSON.parse(getVpnOptions()) as VpnOptions
    console.debug("ParseConfig", JSON.stringify(option))
    if (option.ipv4Address != "") {
      vpnConfig.addresses[0].address = new Address(option.ipv4Address.split("/")[0], 1)
      option.routeAddress?.filter(a => isIpv4(a)).map(f => f.split("/")[0])
    }
    if (option.ipv6Address != "") {
      vpnConfig.addresses[0].address = new Address(option.ipv6Address.split("/")[0], 2)
      option.routeAddress?.filter(a => isIpv6(a)).map(f => f.split("/")[0])
    }
    if (option.accessControl?.mode) {
      if (option.accessControl?.mode == "AcceptSelected") {
        vpnConfig.trustedApplications = option.accessControl?.acceptList
      } else {
        vpnConfig.blockedApplications = option.accessControl?.rejectList
      }
    }
    if (option.systemProxy || option.allowBypass) {
      // TODO ohos 不支持
      // not use option.bypassDomain option.port
    }
    console.debug("vpnConfig", JSON.stringify(vpnConfig))
    return vpnConfig;
  }
  override async startVpn(): Promise<boolean> {
    let config = this.ParseConfig();
    let tunFd = -1
    try {
      tunFd = await super.getTunFd(config)
      if (tunFd > -1) {
        this.startClash(tunFd)
      }
      return tunFd > -1;
    } catch (error) {
      console.error("ClashVPN  error ", error)
      return false
    }
  }

  startClash(tunFd: number) {
    let tcp: socket.LocalSocket = socket.constructLocalSocketInstance();
    tcp.on('message', async (value: socket.LocalSocketMessageInfo) => {
      let text = new util.TextDecoder()
      let dd = text.decodeToString(new Uint8Array(value.message))
      let list = dd.split("EOF")
      for (let index = 0; index < list.length; index++) {
        const element = list[index];
        try {
          if (element != "") {
            let json = JSON.parse(element) as RpcResult
            let fd = JSON.parse(json.result as string) as Fd
            await this.protect(fd.value)
            setFdMap(fd.id)
          }
        } catch (e) {
          console.error("ClashVPN protect error", e.message, element)
        }
      }
    })
    const socketPath = this.context?.filesDir + '/clash_go.sock'
    console.error("ClashVPN connect", tunFd)
    tcp.connect({ address: { address: socketPath }, timeout: 1000 }).then(() => {
      console.error("ClashVPN connect", tunFd)
      tcp.send({ data: JSON.stringify({ method: ClashRpcType.startClash, params: [tunFd] }) });
    }).catch((e) => {
      console.error("ClashVPN  error ", e.message, e)
    })
  }


  stopVpn() {
    stopTun()
    super.stopVpn()
  }
  override async init() {
    initClash(await getHome(this.context), "1.0.0")
  }
}

export interface Fd {
  id: number
  value: number
}

export function ParseProxyGroup(mode, result: string) {
  if (result == null)
    return []
  const map = JSON.parse(result) as Record<string, string | Record<string, string[] | string>>
  const global = map[ProxyMode.Global]
  let groupNames = global?.["all"] as string[] ?? []
  if (mode == ProxyMode.Global) {
    groupNames = ["GLOBAL", ...groupNames]
  } else if (mode == ProxyMode.Rule) {
    groupNames = groupNames
  } else {
    groupNames = []
  }
  groupNames = groupNames.filter(e => {
    const proxy = map[e] as Record<string, string>
    const indexes = ["Selector", "URLTest", "Fallback", "LoadBalance", "Relay"].indexOf(proxy["type"])
    return indexes > -1
  })
  const groupsRaw = groupNames.map((groupName) => {
    const group = map[groupName];
    group["proxies"] = (group["all"] ?? []).map((n: string) => {
      map[n]["name"] = map[n]["name"]
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
  return groupsRaw;
}