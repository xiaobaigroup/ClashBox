import { TunnelState, UpdateConfigParams } from "../models/ClashConfig";
import {
  LogInfo,
  OverrideSlot, Provider, ProviderType, ProxyGroup,
  ProxyMode,
  ProxySort, SubscriptionInfo} from "../models/Common";

export enum ClashRpcType{
  queryTrafficNow,
  queryTunnelState,
  queryTrafficTotal,
  queryProxyGroup,
  queryProviders,
  changeProxy,
  healthCheck,
  updateProvider,
  uploadProvider,
  queryConnections,
  closeConnection,
  clearConnections,
  load,
  startClash,
  stopClash,
  validConfig,
  reset,
  getCountryCode,
  updateGeoData,
  registerOnMessage,
  getRequestList,
  clearRequestList,
  setLogObserver,
  stopLogObserver,
  vpnOptions,
  setOptionState,
  GetVpnRunTime,
  VpnConfigInited,
  SetNetInterfaces,
  downloadConfig,
  SetSystemDns,
  healthCheckAll,
  healthCheckBatch,
  GetVersion
}

export interface AccessControl{
  mode: string // AcceptSelected or other
  acceptList: string[]
  rejectList: string[]
}
export interface VpnRawOptions{
  tunIp: string
  ipv6?: boolean
  routeAddress?: string[]
  accessControl: AccessControl
  /** 最大传输单元: VPN 层 VpnConfig.mtu, 缺省 1400 */
  mtu?: number
}

export interface HealthCheckBatchParams{
  "proxy-names": string[]
  timeout: number
  "test-url": string
}


export interface IClashManager {

  queryProxyGroups(model: ProxyMode): Promise<ProxyGroup[]>;
  changeProxy(group: string, name: string): Promise<string>;

  queryProviders(): Promise<Provider[]>;
  updateProvider(provider: Provider): Promise<string>;

  healthCheck(group: string): Promise<number>;
  loadConfig(path: UpdateConfigParams): Promise<string>;
  setLogObserver(observer: (log: LogInfo) => void): Promise<() => void>;
}