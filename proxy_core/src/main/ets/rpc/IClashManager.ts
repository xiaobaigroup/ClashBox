import { TunnelState, UpdateConfigParams } from "../models/ClashConfig";
import {  OverrideSlot, Provider, ProviderType, ProxyGroup,
  ProxyMode,
  ProxySort, SubscriptionInfo} from "../models/Common";

export enum ClashRpcType{
  queryTrafficNow,
  queryTunnelState,
  queryTrafficTotal,
  queryProxyGroup,
  queryProviders,
  patchSelector,
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
  patchSelector(group: string, name: string): Promise<string>;

  queryProviders(): Promise<Provider[]>;
  updateProvider(type: ProviderType, name: string): Promise<string>;

  healthCheck(group: string): Promise<number>;
  loadConfig(path: UpdateConfigParams): Promise<string>;
  setLogObserver(observer: (string: string) => void): Promise<() => void>;
}