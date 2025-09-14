import { i18n } from "@kit.LocalizationKit";
/**
 * 修改语言工具
 * @param areaID 地区代码
 */
export function ChangeLanguage(areaID: string) {
  try {
    i18n.System.setAppPreferredLanguage(areaID)
  } catch (error) {
    console.error(`#ChangeLanguage 语言切换错误 code：${error.code} message: ${error.message}`)
  }
}