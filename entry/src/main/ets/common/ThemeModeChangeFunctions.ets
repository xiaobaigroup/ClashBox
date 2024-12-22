// 代码来自官方示例

import { common, ConfigurationConstant } from "@kit.AbilityKit";

const setColorMode = (context: common.UIAbilityContext, colorMode: ConfigurationConstant.ColorMode) => {
  context.getApplicationContext().setColorMode(colorMode);
}
/**
 * 设置主题模式为跟随系统变化
 */
export const setAutoColorMode = (context: common.UIAbilityContext) => {
  setColorMode(context, ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
}
/**
 * 设置主题模式为始终深色
 */
export const setDarkColorMode = (context: common.UIAbilityContext) => {
  setColorMode(context, ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
}
/**
 * 设置主题模式为始终浅色
 */
export const setLightColorMode = (context: common.UIAbilityContext) => {
  setColorMode(context, ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
}