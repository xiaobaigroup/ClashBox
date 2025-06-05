import { i18n } from "@kit.LocalizationKit";
/**
 * 修改语言工具
 * @param areaID 地区代码
 */
export function ChangeLanguage(areaID: string) {
  i18n.System.setAppPreferredLanguage(areaID)
}