import { CustomColors, CustomTheme } from '@ohos.arkui.theme'
import { HashMap } from '@kit.ArkTS'


/* 主题定义 多个主题就创建多个*/
/* 鸿蒙蓝（星河蓝） blueAppTheme */
// 主题颜色
class BlueAppThemeColors implements CustomColors {
  iconEmphasize: ResourceColor = $r('sys.color.icon_emphasize')
}
// 主题配置
class BlueAppTheme implements CustomTheme {
  public colors: BlueAppThemeColors = new BlueAppThemeColors()
}


/* 猫咪蓝 catBlueAppTheme */
// 主题颜色
class CatBlueAppThemeColors implements CustomColors {
  iconEmphasize: ResourceColor = $r('app.color.theme_color_main_cat_blue')
}
// 主题配置
class CatBlueAppTheme implements CustomTheme {
  public colors: BlueAppThemeColors = new CatBlueAppThemeColors()
}


/* 便单黄 yellowAppTheme */
// 主题颜色
class YellowAppThemeColors implements CustomColors {
  iconEmphasize: ResourceColor = $r('app.color.theme_color_main_yellow')
}
// 主题配置
class YellowAppTheme implements CustomTheme {
  public colors: BlueAppThemeColors = new YellowAppThemeColors()
}


/* 华为红 redAppTheme */
// 主题颜色
class RedAppThemeColors implements CustomColors {
  iconEmphasize: ResourceColor = $r('app.color.theme_color_main_red')
}
// 主题配置
class RedAppTheme implements CustomTheme {
  public colors: BlueAppThemeColors = new RedAppThemeColors()
}


/* 优雅紫 purpleAppTheme */
// 主题颜色
class PurpleAppThemeColors implements CustomColors {
  iconEmphasize: ResourceColor = $r('app.color.theme_color_main_purple')
}
// 主题配置
class PurpleAppTheme implements CustomTheme {
  public colors: BlueAppThemeColors = new PurpleAppThemeColors()
}


/* 哔哩粉 pinkAppTheme */
// 主题颜色
class PinkAppThemeColors implements CustomColors {
  iconEmphasize: ResourceColor = $r('app.color.theme_color_main_pink')
}
// 主题配置
class PinkAppTheme implements CustomTheme {
  public colors: BlueAppThemeColors = new PinkAppThemeColors()
}

/* 小草绿 greenAppTheme */
// 主题颜色
class GreenAppThemeColors implements CustomColors {
  iconEmphasize: ResourceColor = $r('app.color.theme_color_main_green')
}
// 主题配置
class GreenAppTheme implements CustomTheme {
  public colors: BlueAppThemeColors = new GreenAppThemeColors()
}

/* 导出 */
// 自定义主题名称 TODO 补充主题名称字符串
export type CustomThemeName =
  'blueAppTheme' |
  'catBlueAppTheme' |
  'yellowAppTheme' |
  'redAppTheme' |
  'purpleAppTheme' |
  'pinkAppTheme' |
  'greenAppTheme';
// 自定义主题HashMap
let _CUSTOM_THEME_MAP: HashMap<CustomThemeName, CustomTheme> = new HashMap<CustomThemeName, CustomTheme>()
_CUSTOM_THEME_MAP.set('blueAppTheme', new BlueAppTheme())
_CUSTOM_THEME_MAP.set('catBlueAppTheme', new CatBlueAppTheme())
_CUSTOM_THEME_MAP.set('yellowAppTheme', new YellowAppTheme())
_CUSTOM_THEME_MAP.set('redAppTheme', new RedAppTheme())
_CUSTOM_THEME_MAP.set('purpleAppTheme', new PurpleAppTheme())
_CUSTOM_THEME_MAP.set('pinkAppTheme', new PinkAppTheme())
_CUSTOM_THEME_MAP.set('greenAppTheme', new GreenAppTheme())

export const CUSTOM_THEME_MAP = _CUSTOM_THEME_MAP