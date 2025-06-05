import { CustomThemeName, CUSTOM_THEME_MAP } from "./AppThemeManager";
import { ThemeControl } from "@kit.ArkUI";

/**
 * 更改主题配置
 * @param customThemeName 自定义主题的名字
 */
export function changeThemeColor(customThemeName: CustomThemeName) {
  ThemeControl.setDefaultTheme(CUSTOM_THEME_MAP.get(customThemeName))
}