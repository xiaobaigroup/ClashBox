import { i18n } from "@kit.LocalizationKit";
/**
 * 修改语言工具
 * @param areaID 地区代码
 */
export function Xb_ChangeLanguage(areaID: string) {
  console.log(`SettingsPage #Xb_ChangeLanguage 执行语言切换`)
  i18n.System.setAppPreferredLanguage(areaID)
}