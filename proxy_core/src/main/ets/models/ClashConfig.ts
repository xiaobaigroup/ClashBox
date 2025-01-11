import { ClashConfig } from "./Common"

export interface  UpdateConfigParams{
  "profile-id": string
  config: ClashConfig
  params: ConfigExtendedParams
}
export interface  ConfigExtendedParams{
  "is-patch": boolean
  "is-compatible": boolean
  "selected-map": Map<string, string>
  "override-dns": boolean
  "test-url": string
}
