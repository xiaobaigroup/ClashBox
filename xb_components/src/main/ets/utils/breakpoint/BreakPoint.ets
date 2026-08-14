import { Xb_BreakpointFunction } from "./BreakPointStystem"
import { Xb_BreakpointFunction2D } from "./BreakPointSystem2D"

/**Tab栏方向*/
const Xb_TabBarVertical = Xb_BreakpointFunction2D<boolean>({
  ['sm']: {['hsm']: false, ['hmd']: false, ['hlg']: false},
  ['md']: {['hsm']: true, ['hmd']: false, ['hlg']: false},
  ['lg']: {['hsm']: true, ['hmd']: true, ['hlg']: true},
  ['xl']: {['hsm']: true, ['hmd']: true, ['hlg']: true},
})

/**Tab栏横向方式-普通*/
const Xb_TabBarAlignItems = Xb_BreakpointFunction2D<number>({
  ['sm']: {['hsm']: ItemAlign.Center, ['hmd']: ItemAlign.Center, ['hlg']: ItemAlign.Center},
  ['md']: {['hsm']: ItemAlign.End, ['hmd']: ItemAlign.Center, ['hlg']: ItemAlign.Center},
  ['lg']: {['hsm']: ItemAlign.Center, ['hmd']: ItemAlign.Center, ['hlg']: ItemAlign.Center},
  ['xl']: {['hsm']: ItemAlign.Center, ['hmd']: ItemAlign.Center, ['hlg']: ItemAlign.Center},
})

/**Tab栏位置*/
const Xb_TabBarPosition = Xb_BreakpointFunction2D<number>({
  ['sm']: {['hsm']: BarPosition.End, ['hmd']: BarPosition.End, ['hlg']: BarPosition.End},
  ['md']: {['hsm']: BarPosition.Start, ['hmd']: BarPosition.End, ['hlg']: BarPosition.End},
  ['lg']: {['hsm']: BarPosition.Start, ['hmd']: BarPosition.Start, ['hlg']: BarPosition.Start},
  ['xl']: {['hsm']: BarPosition.Start, ['hmd']: BarPosition.Start, ['hlg']: BarPosition.Start},
})

/** @description Tab栏竖向方式*/
const Xb_TabBarJustifyContent = Xb_BreakpointFunction2D<number>({
  ['sm']: {['hsm']: FlexAlign.Start, ['hmd']: FlexAlign.Start, ['hlg']: FlexAlign.Start},
  ['md']: {['hsm']: FlexAlign.Center, ['hmd']: FlexAlign.Start, ['hlg']: FlexAlign.Start},
  ['lg']: {['hsm']: FlexAlign.Center, ['hmd']: FlexAlign.Center, ['hlg']: FlexAlign.Center},
  ['xl']: {['hsm']: FlexAlign.Center, ['hmd']: FlexAlign.Center, ['hlg']: FlexAlign.Center},
})

/**Tab栏宽度*/
const Xb_TabBarWidth = Xb_BreakpointFunction2D<string>({
  ['sm']: {['hsm']: '100%', ['hmd']: '100%', ['hlg']: '100%'},
  ['md']: {['hsm']: '77vp', ['hmd']: '100%', ['hlg']: '100%'},
  ['lg']: {['hsm']: '67vp', ['hmd']: '67vp', ['hlg']: '67vp'},
  ['xl']: {['hsm']: '67vp', ['hmd']: '67vp', ['hlg']: '67vp'},
})

/**Tab栏宽度-窗口*/
const Xb_WindowTabBarWidth = Xb_BreakpointFunction2D<string>({
  ['sm']: {['hsm']: '100%', ['hmd']: '100%', ['hlg']: '100%'},
  ['md']: {['hsm']: '57vp', ['hmd']: '100%', ['hlg']: '100%'},
  ['lg']: {['hsm']: '57vp', ['hmd']: '57vp', ['hlg']: '57vp'},
  ['xl']: {['hsm']: '57vp', ['hmd']: '57vp', ['hlg']: '57vp'},
})

/**Tab栏高度-避让底部*/
const Xb_TabBarAvoidHeight = Xb_BreakpointFunction2D<string>({
  ['sm']: {['hsm']: '67vp', ['hmd']: '77vp', ['hlg']: '77vp'},
  ['md']: {['hsm']: '100%', ['hmd']: '77vp', ['hlg']: '77vp'},
  ['lg']: {['hsm']: '100%', ['hmd']: '100%', ['hlg']: '100%'},
  ['xl']: {['hsm']: '100%', ['hmd']: '100%', ['hlg']: '100%'},
})

/**Tab栏高度-不避让底部*/
const Xb_TabBarHeight = Xb_BreakpointFunction2D<string>({
  ['sm']: {['hsm']: '57vp', ['hmd']: '57vp', ['hlg']: '57vp'},
  ['md']: {['hsm']: '100%', ['hmd']: '57vp', ['hlg']: '57vp'},
  ['lg']: {['hsm']: '100%', ['hmd']: '100%', ['hlg']: '100%'},
  ['xl']: {['hsm']: '100%', ['hmd']: '100%', ['hlg']: '100%'},
})

/**Tab栏字体大小*/
const Xb_TabTitleFontSize = Xb_BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 12, ['hmd']: 12, ['hlg']: 12},
  ['md']: {['hsm']: 12, ['hmd']: 16, ['hlg']: 16},
  ['lg']: {['hsm']: 16, ['hmd']: 16, ['hlg']: 16},
  ['xl']: {['hsm']: 16, ['hmd']: 16, ['hlg']: 16},
})

/**Tab栏图标大小*/
const Xb_TabIconFontSize = Xb_BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 24, ['hmd']: 24, ['hlg']: 24},
  ['md']: {['hsm']: 24, ['hmd']: 26, ['hlg']: 26},
  ['lg']: {['hsm']: 26, ['hmd']: 26, ['hlg']: 26},
  ['xl']: {['hsm']: 26, ['hmd']: 26, ['hlg']: 26},
})

/**弹窗宽度*/
const Xb_CustomDialogWidth = Xb_BreakpointFunction<number>({
  ['sm']: 332, ['md']: 360, ['lg']: 400, ['xl']: 400
})

/**页面外边距(更多、设置)*/
export const PageMargin = Xb_BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 12, ['hmd']: 15, ['hlg']: 15},
  ['md']: {['hsm']: 15, ['hmd']: 16, ['hlg']: 16},
  ['lg']: {['hsm']: 16, ['hmd']: 16, ['hlg']: 16},
  ['xl']: {['hsm']: 16, ['hmd']: 16, ['hlg']: 16},
})

/**页面路由分栏模式*/
const Xb_NavigationStackMode = Xb_BreakpointFunction<NavigationMode>({
  ['sm']: NavigationMode.Stack, ['md']: NavigationMode.Split, ['lg']: NavigationMode.Split, ['xl']: NavigationMode.Split
})

/**悬浮Tab栏横竖位置*/
const Xb_FloatTabBarDirection = Xb_BreakpointFunction2D<FlexDirection>({
  ['sm']: {['hsm']: FlexDirection.Row, ['hmd']: FlexDirection.Row, ['hlg']: FlexDirection.Row},
  ['md']: {['hsm']: FlexDirection.Column, ['hmd']: FlexDirection.Row, ['hlg']: FlexDirection.Row},
  ['lg']: {['hsm']: FlexDirection.Column, ['hmd']: FlexDirection.Column, ['hlg']: FlexDirection.Column},
  ['xl']: {['hsm']: FlexDirection.Column, ['hmd']: FlexDirection.Column, ['hlg']: FlexDirection.Column},
})

/**悬浮Tab栏横竖位置反转*/
const Xb_FloatTabBarDirectionReverse = Xb_BreakpointFunction2D<FlexDirection>({
  ['sm']: {['hsm']: FlexDirection.RowReverse, ['hmd']: FlexDirection.RowReverse, ['hlg']: FlexDirection.RowReverse},
  ['md']: {['hsm']: FlexDirection.ColumnReverse, ['hmd']: FlexDirection.RowReverse, ['hlg']: FlexDirection.RowReverse},
  ['lg']: {['hsm']: FlexDirection.ColumnReverse, ['hmd']: FlexDirection.ColumnReverse, ['hlg']: FlexDirection.ColumnReverse},
  ['xl']: {['hsm']: FlexDirection.ColumnReverse, ['hmd']: FlexDirection.ColumnReverse, ['hlg']: FlexDirection.ColumnReverse},
})

/**悬浮Tab栏内边距*/
const Xb_FloatTabBarPadding = Xb_BreakpointFunction2D<Length | Padding | LocalizedPadding>({
  ['sm']: {['hsm']: {left: 8, right: 8}, ['hmd']: {left: 8, right: 8}, ['hlg']: {left: 8, right: 8} },
  ['md']: {['hsm']: {top: 8, bottom: 8}, ['hmd']: {left: 8, right: 8}, ['hlg']: {left: 8, right: 8} },
  ['lg']: {['hsm']: {top: 8, bottom: 8}, ['hmd']: {top: 8, bottom: 8}, ['hlg']: {top: 8, bottom: 8} },
  ['xl']: {['hsm']: {top: 8, bottom: 8}, ['hmd']: {top: 8, bottom: 8}, ['hlg']: {top: 8, bottom: 8} },
})

/**悬浮Tab栏横竖位置*/
const Xb_FloatTabBarAlignCenter = Xb_BreakpointFunction2D<Alignment>({
  ['sm']: {['hsm']: Alignment.Bottom, ['hmd']:  Alignment.Bottom, ['hlg']: Alignment.Bottom},
  ['md']: {['hsm']:  Alignment.Start, ['hmd']:  Alignment.Bottom, ['hlg']: Alignment.Bottom},
  ['lg']: {['hsm']: Alignment.Start, ['hmd']: Alignment.Start, ['hlg']: Alignment.Start},
  ['xl']: {['hsm']: Alignment.Start, ['hmd']: Alignment.Start, ['hlg']: Alignment.Start},
})
const Xb_FloatTabBarAlignStart = Xb_BreakpointFunction2D<Alignment>({
  ['sm']: {['hsm']: Alignment.BottomStart, ['hmd']:  Alignment.BottomStart, ['hlg']: Alignment.BottomStart},
  ['md']: {['hsm']:  Alignment.TopStart, ['hmd']:  Alignment.BottomStart, ['hlg']: Alignment.BottomStart},
  ['lg']: {['hsm']: Alignment.TopStart, ['hmd']: Alignment.TopStart, ['hlg']: Alignment.TopStart},
  ['xl']: {['hsm']: Alignment.TopStart, ['hmd']: Alignment.TopStart, ['hlg']: Alignment.TopStart},
})
const Xb_FloatTabBarAlignEnd = Xb_BreakpointFunction2D<Alignment>({
  ['sm']: {['hsm']: Alignment.BottomEnd, ['hmd']:  Alignment.BottomEnd, ['hlg']: Alignment.BottomEnd},
  ['md']: {['hsm']:  Alignment.BottomStart, ['hmd']:  Alignment.BottomEnd, ['hlg']: Alignment.BottomEnd},
  ['lg']: {['hsm']: Alignment.BottomStart, ['hmd']: Alignment.BottomStart, ['hlg']: Alignment.BottomStart},
  ['xl']: {['hsm']: Alignment.BottomStart, ['hmd']: Alignment.BottomStart, ['hlg']: Alignment.BottomStart},
})

export {
  Xb_TabBarVertical,
  Xb_TabBarAlignItems,
  Xb_TabBarPosition,
  Xb_TabBarJustifyContent,
  Xb_TabBarWidth,
  Xb_WindowTabBarWidth,
  Xb_TabIconFontSize,
  Xb_TabTitleFontSize,
  Xb_TabBarHeight,
  Xb_TabBarAvoidHeight,
  Xb_CustomDialogWidth,
  Xb_NavigationStackMode,
  Xb_FloatTabBarDirection,
  Xb_FloatTabBarAlignCenter,
  Xb_FloatTabBarAlignStart,
  Xb_FloatTabBarAlignEnd,
  Xb_FloatTabBarPadding,
  Xb_FloatTabBarDirectionReverse
}