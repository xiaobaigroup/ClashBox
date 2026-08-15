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
import { Address, AddressWithPrefix, CommonVpnService, cidrToRoute, VpnConfig } from './CommonVpnService';
import { JSON, util } from '@kit.ArkTS';
import { RpcRequest, RpcResult } from './RpcRequest';
import { ClashRpcType } from './IClashManager';
import { ConnectionInfo, LogInfo, Proxy, Provider, ProxyGroup, ProxyMode, ProxyType, Traffic } from '../models/Common';
import { getHome, getProfilePath } from '../appPath';
import { ClashConfig, Tun, UpdateConfigParams } from '../models/ClashConfig';
import { readFile, readFileUri, readText } from '../fileUtils';

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
  ipv6?: boolean,
  accessControl: AccessControl,
  systemProxy: boolean,
  allowBypass: boolean,
  routeAddress: string[],
  bypassDomain: string[],
  dnsServerAddress: string,
  /** 最大传输单元: 缺省 1400 */
  mtu?: number,
}


export class FlClashVpnService extends CommonVpnService {
  vpnConnection: vpnExtension.VpnConnection | undefined
  public configPath: string = ""
  protectSocketPath: string = ""
  private clashSocket: socket.LocalSocket | undefined
  private textDecoder: util.TextDecoder = new util.TextDecoder()

  override async onRemoteMessageRequest(client: socket.LocalSocketConnection, message: socket.LocalSocketMessageInfo): Promise<void> {
    let request = JSON.parse(this.textDecoder.decodeToString(new Uint8Array(message.message))) as RpcRequest
    let code = request.method
    let params = request.params
    try {
      let result = await this.onRemoteMessage(code, params)
      this.sendClient(client, JSON.stringify({ result: result, error: undefined }))
    } catch (e) {
      console.error(`socket stub ${code} result: `, e.message ?? e, e.stack)
      this.sendClient(client, JSON.stringify({ error: e.message ?? e }))
    }
  }
  /** 防止多次调用 stopVpn 导致 stopTun 重复执行 */
  private isStopped: boolean = false

  onRemoteMessage(code: number, data: (string | number | boolean)[]): Promise<string | number | boolean> {
    // 根据code处理客户端的请求
    return new Promise(async (resolve, reject) => {
      switch (code) {
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
          // ★ 先停止 tun 再停止 listener，防止 Go 内部清理和 stopTun() 竞争导致 NULL 指针崩溃
          this.stopVpn()
          stopListener()
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
    // 根据 ipv6 开关决定是否启用 IPv6 地址和路由
    const vpnIpv6Enabled = option.ipv6 !== false
    if (option.ipv6Address == undefined || option.ipv6Address == "") {
      option.ipv6Address = "fdfe:dcba:9876::1/126"
    }
    if (option.routeAddress == undefined) {
      option.routeAddress = []
    }
    if (option.ipv4Address != "") {
      const ips = option.ipv4Address.split("/")
      console.debug("tunIp ", ips)
      const prefixLength = ips.length > 1 ? parseInt(ips[1]) : 30
      vpnConfig.addresses[0] = new AddressWithPrefix(new Address(ips[0], 1), prefixLength)
      vpnConfig.isIPv4Accepted = true
    }
    if (vpnIpv6Enabled && option.ipv6Address != "") {
      const ips = option.ipv6Address.split("/")
      const prefixLength = ips.length > 1 ? parseInt(ips[1]) : 126
      vpnConfig.addresses.push(new AddressWithPrefix(new Address(ips[0], 2), prefixLength))
      vpnConfig.isIPv6Accepted = true
    }
    const routeAddresses: string[] = []
    const addRouteAddress = (cidr: string) => {
      if (cidr != "" && !routeAddresses.includes(cidr)) {
        routeAddresses.push(cidr)
      }
    }
    // Explicit defaults avoid OHOS auto-generating only fe80::/derived IPv6 coverage.
    option.routeAddress?.forEach(addRouteAddress)
    if (option.ipv4Address != "") {
      addRouteAddress("0.0.0.0/0")
    }
    if (vpnIpv6Enabled && option.ipv6Address != "") {
      addRouteAddress("::/0")
    }
    routeAddresses.forEach((cidr) => {
      const route = cidrToRoute(cidr)
      if (route != null) {
        vpnConfig.routes.push(route)
      }
    })
    if (option.accessControl?.mode) {
      if (option.accessControl?.mode == "AcceptSelected") {
        vpnConfig.trustedApplications = option.accessControl?.acceptList
      } else {
        vpnConfig.blockedApplications = option.accessControl?.rejectList
      }
    }
    if (option.dnsServerAddress && option.dnsServerAddress != "") {
      vpnConfig.dnsAddresses = [option.dnsServerAddress]
    } else {
      vpnConfig.dnsAddresses = ["172.19.0.2"]
    }
    // ★ MTU: 优先使用用户配置(1280-65535), 缺省 1400
    vpnConfig.mtu = (option.mtu && option.mtu >= 1280 && option.mtu <= 65535) ? option.mtu : 1400
    if (option.systemProxy || option.allowBypass) {
      // TODO ohos 不支持
      // not use option.bypassDomain option.port
    }
    console.debug("vpnConfig", JSON.stringify(vpnConfig))
    return vpnConfig;
  }
  override async startVpn(): Promise<boolean> {
    // ★ 重置停止标记，允许下次 stopVpn 正常关闭资源
    this.isStopped = false
    if (this.vpnConnection) {
      this.vpnConnection.destroy()
      this.vpnConnection = undefined
      // 系统级 VPN 连接销毁后需要时间回收 TUN 路由/protect 通道，
      // 立即重建（卡片冷启动→关闭→UI 再启动场景）会叠加残留状态，
      // 后台大流量时 protect 超时 → 流量回环 → 代理与直连全断
      await new Promise<void>((resolve) => {
        setTimeout(resolve, 500)
      })
    }
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
    this.clashSocket?.off('message')
    this.clashSocket?.close()
    let tcp: socket.LocalSocket = socket.constructLocalSocketInstance();
    this.clashSocket = tcp
    tcp.on('message', (value: socket.LocalSocketMessageInfo) => {
      let dd = this.textDecoder.decodeToString(new Uint8Array(value.message))
      let list = dd.split("EOF")
      for (let index = 0; index < list.length; index++) {
        const element = list[index];
        // 每个 fd 独立异步处理：Go 侧每个出站 socket 都等待 protect 完成（最长 5s），
        // 串行 await 会让前一个 protect 阻塞后续 fd，后台 JS 线程受限时更易超时
        // → socket 未保护 → 流量回环进 TUN → DNS 全断。
        this.handleProtectMessage(element)
      }
    })
    const socketPath = this.context?.filesDir + '/clash_go.sock'
    console.error("ClashVPN connect", tunFd)
    tcp.connect({ address: { address: socketPath }, timeout: 1000 }).then(() => {
      console.error("ClashVPN connect", tunFd)
      tcp.send({ data: JSON.stringify({ method: ClashRpcType.startClash, params: [tunFd] }) });
    }).catch((e: Error) => {
      console.error("ClashVPN  error ", e.message, e)
    })
  }

  /**
   * 单个 protect 消息的异步处理：解析 fd → protect（带重试）→ setFdMap。
   * 每个 fd 独立执行，互不阻塞。protect 失败会导致该出站 fd 未绕过 TUN → 流量回环 → 直连断网。
   */
  private handleProtectMessage(element: string): void {
    if (element == "") return
    try {
      let json = JSON.parse(element) as RpcResult
      let fd = JSON.parse(json.result as string) as Fd
      this.protectWithRetry(fd.value, 3).then(() => {
        setFdMap(fd.id)
      }).catch((protectErr: Error) => {
        // 重试仍失败：打 hilog 点便于确认后台 protect 是否被系统中断（hilog | grep ClashVPN protect）
        console.error("ClashVPN protect failed after retry, skipping setFdMap for fd.id=" + fd.id, protectErr.message, element)
      })
    } catch (e) {
      console.error("ClashVPN message parse error", (e as Error).message, element)
    }
  }

  stopVpn() {
    if (this.isStopped) return
    this.isStopped = true
    this.clashSocket?.off('message')
    this.clashSocket?.close()
    this.clashSocket = undefined
    stopTun()
    super.stopVpn()
  }

  /**
   * protect 带重试：后台 Extension 进程受限时 vpnConnection.protect 可能偶发失败，
   * 失败重试可避免出站 fd 未保护导致流量回环（直连断网）
   */
  private async protectWithRetry(fd: number, retries: number): Promise<void> {
    let lastErr: Error | undefined = undefined
    for (let i = 0; i < retries; i++) {
      try {
        await this.protect(fd)
        return
      } catch (e) {
        lastErr = e as Error
        await new Promise<void>((resolve) => {
          setTimeout(resolve, 100)
        })
      }
    }
    throw lastErr ?? new Error('protect failed')
  }
  override async init() {
    initClash(await getHome(this.context), "1.0.0")
  }
}

export interface Fd {
  id: number
  value: number
}

export function ParseProxyGroup(mode: ProxyMode, result: string): ProxyGroup[] {
  if (result == null || result.length === 0)
    return []
  const map = JSON.parse(result) as Record<string, Record<string, string | string[] | boolean | number | undefined>>
  const global = map[ProxyMode.Global]
  let groupNames: string[] = (global?.["all"] as string[] | undefined) ?? []
  if (mode == ProxyMode.Global) {
    groupNames = ["GLOBAL", ...groupNames]
  } else if (mode == ProxyMode.Rule) {
    // keep groupNames as is
  } else {
    groupNames = []
  }
  groupNames = groupNames.filter(e => {
    const proxy = map[e]
    if (!proxy)
      return false
    return ["Selector", "URLTest", "Fallback", "LoadBalance", "Relay"].indexOf(proxy["type"] as string) > -1
  })
  const groupsRaw: (ProxyGroup | null)[] = groupNames.map((groupName) => {
    const group = map[groupName];
    if (!group) {
      return null;
    }
    const rawAll = group["all"]
    const allNames: string[] = Array.isArray(rawAll) ? rawAll as string[] : []
    const proxies: Proxy[] = []
    for (const n of allNames) {
      const rawProxy = map[n];
      if (!rawProxy) {
        continue;
      }
      const proxyName = (rawProxy["name"] as string | undefined) ?? n;
      const proxyType = (rawProxy["type"] as string | undefined) ?? "Reject";
      proxies.push({
        name: proxyName,
        type: proxyType as ProxyType,
        display: (rawProxy["display"] as string | undefined) ?? "",
        id: rawProxy["id"] as string | undefined,
        g: rawProxy["g"] as string | undefined,
        icon: rawProxy["icon"] as string | undefined,
        latency: rawProxy["latency"] as number | undefined,
      })
    }
    return {
      name: (group["name"] as string) ?? "",
      now: (group["now"] as string) ?? "",
      type: (group["type"] as ProxyType) ?? ProxyType.Reject,
      display: (group["display"] as string) ?? "",
      hidden: group["hidden"] == true,
      icon: group["icon"] as string | undefined,
      proxies: proxies
    } as ProxyGroup
  })
  return groupsRaw.filter(g => g != null) as ProxyGroup[];
}