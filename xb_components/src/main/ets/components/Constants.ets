import { common } from "@kit.AbilityKit"

/* 全局共用尺寸 */
// 圆角
export const BORDER_RADIUS_24 = 24
export const BORDER_RADIUS_20 = 20
// 避让值
export const PADDING_VALUE_16 = 16
export const PADDING_VALUE_14 = 14.5
export const PADDING_VALUE_12 = 12
// 通用对话框中间组组件上下避让值
export const PADDING_DIALOG_UP_15 = 15
export const PADDING_DIALOG_DOWN_18 = 18
// 提示框出现时长
export const PROMPT_TIME_2000 = 2000
// list偏移数值
export const CONTENT_END_OFFSET = 130


export const context = getContext() as common.UIAbilityContext

// 一级图标色
export const icon_primary: ResourceColor = $r('sys.color.icon_primary')
// 一级文本色
export const font_primary: ResourceColor = $r('sys.color.font_primary')
// 二级文本色，深灰色
export const font_secondary: ResourceColor = $r('sys.color.font_secondary')
// 三级图标色，浅灰色
export const icon_tertiary: ResourceColor = $r('sys.color.icon_tertiary')