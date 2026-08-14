import { common, ConfigurationConstant } from "@kit.AbilityKit";

/**
 * 颜色模式工具类
 */
export class Xb_ColorModeManager {
  /**
   * 设置颜色模式
   * @param context UIAbilityContext
   * @param mode 模式类型
   */
  static setColorMode(
    context: common.UIAbilityContext,
    mode?: ConfigurationConstant.ColorMode
  ) {
    if (mode == undefined || mode == null) {
      console.error(`Xb_ColorModeManager setColorMode 没有颜色模式传入`)
      return
    }
    try {
      context.getApplicationContext().setColorMode(mode);
    } catch (error) {
      throw Error(error)
    }
  }

  static setAuto(context: common.UIAbilityContext) {
    Xb_ColorModeManager.setColorMode(context, ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
  }

  static setDark(context: common.UIAbilityContext) {
    Xb_ColorModeManager.setColorMode(context, ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
  }

  static setLight(context: common.UIAbilityContext) {
    Xb_ColorModeManager.setColorMode(context, ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
  }


  /**
   * 通过ThemeColorMode设置模式
   * @param context UIAbilityContext
   * @param mode 模式标识（ThemeColorMode）
   */
  static setThemeColorMode(
    context: common.UIAbilityContext,
    mode?: ThemeColorMode
  ) {
    if (mode == undefined || mode == null) {
      console.error(`Xb_ColorModeManager setThemeColorMode 没有颜色模式传入`)
      return
    }
    const modeMap: Record<number, ConfigurationConstant.ColorMode> = {
      0: ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET,
      1: ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT,
      2: ConfigurationConstant.ColorMode.COLOR_MODE_DARK
    }
    const targetMode = modeMap[mode] as ConfigurationConstant.ColorMode

    Xb_ColorModeManager.setColorMode(context, targetMode)
  }

}


