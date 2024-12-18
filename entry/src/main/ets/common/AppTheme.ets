import { CustomColors, CustomTheme } from '@ohos.arkui.theme'
import { HashMap } from '@kit.ArkTS'

/* 主题定义 多个主题就创建多个*/
/* 鸿蒙蓝 blueAppTheme */
// 主题颜色
class BlueAppThemeColors implements CustomColors {
  iconEmphasize: ResourceColor = $r('sys.color.icon_emphasize')

}
// 主题配置
class BlueAppTheme implements CustomTheme {
  public colors: BlueAppThemeColors = new BlueAppThemeColors()
}

// TODO 测试用 有了色值之后更换
/* 红色 redTheme */
// 主题颜色
class RedAppThemeColors implements CustomColors {
  iconEmphasize: ResourceColor = Color.Red
}
// 主题配置
class RedAppTheme implements CustomTheme {
  public colors: BlueAppThemeColors = new RedAppThemeColors()
}

// TODO 测试用 有了色值之后更换
/* 橙色 redTheme */
// 主题颜色
class OrangeAppThemeColors implements CustomColors {
  iconEmphasize: ResourceColor = Color.Orange
}
// 主题配置
class OrangeAppTheme implements CustomTheme {
  public colors: BlueAppThemeColors = new OrangeAppThemeColors()
}

/* 导出 */
// 自定义主题名称 TODO 补充主题名称字符串
export type CustomThemeName = 'blueAppTheme' | 'redAppTheme' | 'orangeAppTheme'
// 自定义主题HashMap
let _CUSTOM_THEME_MAP: HashMap<CustomThemeName, CustomTheme> = new HashMap<CustomThemeName, CustomTheme>()
_CUSTOM_THEME_MAP.set('blueAppTheme', new BlueAppTheme())
_CUSTOM_THEME_MAP.set('redAppTheme', new RedAppTheme())
_CUSTOM_THEME_MAP.set('orangeAppTheme', new OrangeAppTheme())

export const CUSTOM_THEME_MAP = _CUSTOM_THEME_MAP