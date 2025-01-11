import { UpdateConfigParams } from "../models/ClashConfig";
import { ClashConfig, OverrideSlot, ProxyGroup, ProxySort, TunnelState } from "../models/Common";

export interface Provider {
  name: string;
  type: ProviderType;
  vehicleType: VehicleType;
  updatedAt: number;
}
export enum ProviderType {
  Proxy = "Proxy",
  Rule = "Rule"
}
export enum VehicleType {
  HTTP = "HTTP",
  File = "File",
  Compatible = "Compatible"
}
export enum ClashRpcType{
  queryTrafficNow = 0,
  queryTunnelState = 1,
  queryTrafficTotal = 2,
  queryProxyGroup = 4,
  queryProviders = 5,
  patchSelector = 6,
  healthCheck = 7,
  updateProvider = 8,
  queryOverride = 9,
  patchOverride = 10,
  clearOverride = 11,
  setLogObserver = 12,
  queryConfiguration = 13,
  load = 14,
  startClash = 15,
  stopClash = 16,
  fetchAndValid = 17,
  reset = 18,
}

export interface IClashManager {

  queryTunnelState(): Promise<TunnelState>;
  queryProxyGroups(): Promise<ProxyGroup[]>;
  queryConfiguration(): Promise<string>;
  queryProviders(): Promise<Provider[]>;
  patchSelector(group: string, name: string): Promise<boolean>;

  healthCheck(group: string): Promise<void>;
  updateProvider(type: ProviderType, name: string): Promise<void>;
  loadConfig(path: UpdateConfigParams): Promise<string>;
  setLogObserver(observer: (string: string) => void): Promise<() => void>;
}