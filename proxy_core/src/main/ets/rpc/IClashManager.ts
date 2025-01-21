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
  queryOverride,
  patchOverride,
  clearOverride,
  setLogObserver,
  queryConfiguration,
  load,
  startClash,
  stopClash,
  fetchAndValid,
  reset,
  updateGeoData,
}

export interface IClashManager {

  queryProxyGroups(model: ProxyMode): Promise<ProxyGroup[]>;
  changeProxy(group: string, name: string): Promise<string>;

  queryProviders(): Promise<Provider[]>;
  updateProvider(type: ProviderType, name: string): Promise<string>;

  healthCheck(group: string): Promise<number>;
  loadConfig(path: UpdateConfigParams): Promise<string>;
  setLogObserver(observer: (log: LogInfo) => void): Promise<() => void>;
}