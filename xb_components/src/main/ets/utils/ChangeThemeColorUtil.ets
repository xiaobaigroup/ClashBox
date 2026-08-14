import { CustomThemeName, CUSTOM_THEME_MAP } from "./AppThemeManager";
import { ThemeControl } from "@kit.ArkUI";

/**
 * 更改主题配置
 * @param customThemeName 自定义主题的名字
 */
export function Xb_ChangeThemeColor(customThemeName: CustomThemeName) {
  console.log(`Xb_MainPage onWillApplyTheme 当前主题：${customThemeName}`)
  ThemeControl.setDefaultTheme(CUSTOM_THEME_MAP.get(customThemeName))
}


// 主题色工具
export class Xb_ThemeColorUtil {
  // 主题色映射表
  private static themeMap = new Map<string, Resource>([
    ['blueAppTheme', $r('sys.color.icon_emphasize')],
    ['ke_blueAppTheme', $r('app.color.theme_color_main_ke_blue')],
    ['catBlueAppTheme', $r('app.color.theme_color_main_cat_blue')],
    ['yellowAppTheme', $r('app.color.theme_color_main_yellow')],
    ['redAppTheme', $r('app.color.theme_color_main_red')],
    ['purpleAppTheme', $r('app.color.theme_color_main_purple')],
    ['pinkAppTheme', $r('app.color.theme_color_main_pink')],
    ['greenAppTheme', $r('app.color.theme_color_main_green')]
  ]);

  // 默认主题色
  private static defaultTheme = $r('sys.color.icon_emphasize');

  /**
   * 根据主题代号获取颜色资源
   * @param themeName 主题代号
   * @returns 对应的颜色资源
   */
  static getThemeColor(themeName: string): Resource {
    return Xb_ThemeColorUtil.themeMap.get(themeName) || Xb_ThemeColorUtil.defaultTheme;
  }

  /**
   * 随机获取一个主题色资源
   * @returns 随机的颜色资源
   */
  static getRandomThemeColor(): Resource {
    const themeNames = Array.from(Xb_ThemeColorUtil.themeMap.keys());
    if (themeNames.length === 0) {
      return Xb_ThemeColorUtil.defaultTheme;
    }
    const randomIndex = Math.floor(Math.random() * themeNames.length);
    return Xb_ThemeColorUtil.getThemeColor(themeNames[randomIndex]);
  }

  /**
   * 随机获取一个主题代号
   * @returns 随机的主题代号 (如 'blueAppTheme')
   */
  static getRandomThemeName(): string {
    const themeNames = Array.from(Xb_ThemeColorUtil.themeMap.keys());
    if (themeNames.length === 0) {
      return 'blueAppTheme'; // 容错默认值
    }
    const randomIndex = Math.floor(Math.random() * themeNames.length);
    return themeNames[randomIndex];
  }

  /**
   * 获取所有可用主题代号
   * @returns 主题代号数组
   */
  static getAllThemeNames(): string[] {
    return Array.from(Xb_ThemeColorUtil.themeMap.keys());
  }
}