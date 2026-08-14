import { bundleManager } from "@kit.AbilityKit";

export function Xb_GetPackageInfo() {
  return bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
}