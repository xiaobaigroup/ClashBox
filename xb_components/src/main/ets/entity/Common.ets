import { SettingsGroup, SettingsItem } from "../settings/SettingsCommonOp";

/**小白工坊页路由参数*/
export interface XbStudioNavInfo {
  itemBackgroundColor: ResourceColor,
  pageBackgroundColor: ResourceColor,
  topRectHeight?: Length
}

/**协作者名单路由参数*/
export interface XbCollaboratorsNavInfo {
  needClose: boolean
  iconSize: number
  appLogo: Resource
  appNameEng: ResourceStr
  appName: ResourceStr
  itemBackgroundCorlor: ResourceColor,
  pageBackgroundColor: ResourceColor,
  topButtonColor: ResourceColor,
  developer: SettingsItem[],
  project: SettingsItem[]
}

/**续接跳转页路由参数*/
export interface AppContinueNavInfo {
// todo 需要加入续接页面相关信息
}

/** Tab栏样式 */
export type TabStyle = 'float' | 'custom' | 'window'

export enum ThemeType {
  Auto,
  Light,
  Black
}