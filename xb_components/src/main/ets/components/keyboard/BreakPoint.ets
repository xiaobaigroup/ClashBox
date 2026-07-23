// 一维断点工具
import { LengthMetrics } from "@kit.ArkUI"
import { Xb_BreakpointFunction } from "../../utils/breakpoint/BreakPointStystem"

export const vKFontSize = Xb_BreakpointFunction<number>({
  ['sm']: 6, ['md']: 10, ['lg']: 16, ['xl']: 18
})

export const vKIconSize = Xb_BreakpointFunction<number>({
  ['sm']: 8, ['md']: 12, ['lg']: 18, ['xl']: 20
})

export const vKPaddingSize = Xb_BreakpointFunction<Padding>({
  ['sm']: {top: 8, right: 8, left: 8, bottom: 8},
  ['md']: {top: 12, right: 30, left: 30, bottom: 12},
  ['lg']: {top: 12, right: 30, left: 30, bottom: 12},
  ['xl']: {top: 12, right: 30, left: 30, bottom: 12}
})

export const vKColumnsGapSize = Xb_BreakpointFunction<Length>({
  ['sm']: 3, ['md']: 6, ['lg']: 6, ['xl']: 6
})

export const vKRowsGapSize = Xb_BreakpointFunction<Length>({
  ['sm']: 2, ['md']: 4, ['lg']: 4, ['xl']: 4
})

export const vKeyHeightSize = Xb_BreakpointFunction<number>({
  ['sm']: 24, ['md']: 24, ['lg']: 50, ['xl']: 50
})

export const vKeyHeightSize1 = Xb_BreakpointFunction<number>({
  ['sm']: 28, ['md']: 28, ['lg']: 58, ['xl']: 58
})

export const vKeyHeightSize2 = Xb_BreakpointFunction<number>({
  ['sm']: 32, ['md']: 32, ['lg']: 64, ['xl']: 64
})

export const vKBorderRadius = Xb_BreakpointFunction<Length>({
  ['sm']: 2, ['md']: 4, ['lg']: 8, ['xl']: 8
})

export const vKRowsSize = Xb_BreakpointFunction<FlexSpaceOptions>({
  ['sm']: {main: LengthMetrics.px(8), cross: LengthMetrics.px(0)}, ['md']: {main: LengthMetrics.px(12), cross: LengthMetrics.px(0)},
  ['lg']: {main: LengthMetrics.px(14), cross: LengthMetrics.px(0)}, ['xl']: {main: LengthMetrics.px(18), cross: LengthMetrics.px(0)}
})

