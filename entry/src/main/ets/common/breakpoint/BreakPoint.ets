import { BreakpointFunction2D, BreakpointType2D } from "./BreakPointSystem2D";

/**Tab栏竖向方式*/
export const TabBarJustifyContent = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: FlexAlign.Start, ['hmd']: FlexAlign.Start, ['hlg']: FlexAlign.Start},
  ['md']: {['hsm']: FlexAlign.Center, ['hmd']: FlexAlign.Start, ['hlg']: FlexAlign.Start},
  ['lg']: {['hsm']: FlexAlign.Center, ['hmd']: FlexAlign.Center, ['hlg']: FlexAlign.Center},
  ['xl']: {['hsm']: FlexAlign.Center, ['hmd']: FlexAlign.Center, ['hlg']: FlexAlign.Center},
})

/**Tab栏横向方式-普通*/
export const TabBarAlignItems = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: ItemAlign.End, ['hmd']: ItemAlign.Center, ['hlg']: ItemAlign.Center},
  ['md']: {['hsm']: ItemAlign.End, ['hmd']: ItemAlign.Center, ['hlg']: ItemAlign.Center},
  ['lg']: {['hsm']: ItemAlign.Center, ['hmd']: ItemAlign.Center, ['hlg']: ItemAlign.Center},
  ['xl']: {['hsm']: ItemAlign.Center, ['hmd']: ItemAlign.Center, ['hlg']: ItemAlign.Center},
})

/**Tab栏位置*/
export const TabBarPosition = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: BarPosition.End, ['hmd']: BarPosition.End, ['hlg']: BarPosition.End},
  ['md']: {['hsm']: BarPosition.Start, ['hmd']: BarPosition.End, ['hlg']: BarPosition.End},
  ['lg']: {['hsm']: BarPosition.Start, ['hmd']: BarPosition.End, ['hlg']: BarPosition.End},
  ['xl']: {['hsm']: BarPosition.Start, ['hmd']: BarPosition.Start, ['hlg']: BarPosition.Start},
})

/**Tab栏方向*/
export const TabBarVertical = BreakpointFunction2D<boolean>({
  ['sm']: {['hsm']: false, ['hmd']: false, ['hlg']: false},
  ['md']: {['hsm']: true, ['hmd']: false, ['hlg']: false},
  ['lg']: {['hsm']: true, ['hmd']: false, ['hlg']: false},
  ['xl']: {['hsm']: true, ['hmd']: true, ['hlg']: true},
})

/**Tab栏宽度*/
export const TabBarWidth = BreakpointFunction2D<string>({
  ['sm']: {['hsm']: '67vp', ['hmd']: '100%', ['hlg']: '100%'},
  ['md']: {['hsm']: '77vp', ['hmd']: '100%', ['hlg']: '100%'},
  ['lg']: {['hsm']: '67vp', ['hmd']: '100%', ['hlg']: '100%'},
  ['xl']: {['hsm']: '67vp', ['hmd']: '67vp', ['hlg']: '67vp'},
})

/**Tab栏高度*/
export const TabBarHeight = BreakpointFunction2D<string>({
  ['sm']: {['hsm']: '100%', ['hmd']: '77vp', ['hlg']: '77vp'},
  ['md']: {['hsm']: '100%', ['hmd']: '77vp', ['hlg']: '77vp'},
  ['lg']: {['hsm']: '100%', ['hmd']: '77vp', ['hlg']: '77vp'},
  ['xl']: {['hsm']: '100%', ['hmd']: '100%', ['hlg']: '100%'},
})

/**列表行外边距*/
export const ListItemMarginValue = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 15, ['hmd']: 15, ['hlg']: 15},
  ['md']: {['hsm']: 16, ['hmd']: 16, ['hlg']: 16},
  ['lg']: {['hsm']: 16, ['hmd']: 16, ['hlg']: 16},
  ['xl']: {['hsm']: 16, ['hmd']: 16, ['hlg']: 16},
})

/**主页卡片Span-3-6_sm*/
export const HomeCardSpan36sm = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 6, ['hmd']: 6, ['hlg']: 6},
  ['md']: {['hsm']: 3, ['hmd']: 6, ['hlg']: 6},
  ['lg']: {['hsm']: 6, ['hmd']: 6, ['hlg']: 6},
  ['xl']: {['hsm']: 6, ['hmd']: 6, ['hlg']: 6},
})

/**主页卡片Span-3-4-6_md*/
export const HomeCardSpan346md = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 6, ['hmd']: 6, ['hlg']: 6},
  ['md']: {['hsm']: 3, ['hmd']: 4, ['hlg']: 6},
  ['lg']: {['hsm']: 6, ['hmd']: 6, ['hlg']: 6},
  ['xl']: {['hsm']: 6, ['hmd']: 6, ['hlg']: 6},
})

/**主页卡片Span-3-4-6_md*/
export const HomeCardSpan346lg = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 6, ['hmd']: 6, ['hlg']: 6},
  ['md']: {['hsm']: 3, ['hmd']: 4, ['hlg']: 6},
  ['lg']: {['hsm']: 3, ['hmd']: 6, ['hlg']: 6},
  ['xl']: {['hsm']: 6, ['hmd']: 6, ['hlg']: 6},
})

/**主页卡片ProxyINFO卡片order*/
export const HomeCardProxyInfoOrder = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 1, ['hmd']: 1, ['hlg']: 1},
  ['md']: {['hsm']: 1, ['hmd']: 3, ['hlg']: 1},
  ['lg']: {['hsm']: 1, ['hmd']: 1, ['hlg']: 1},
  ['xl']: {['hsm']: 1, ['hmd']: 1, ['hlg']: 1},
})

/**主页栅格内边距*/
export const HomeGridRowPadding = BreakpointFunction2D<Padding>({
  ['sm']: {['hsm']: {top: 4, left: 14, right: 14}, ['hmd']: { top: 4, left: 25, right: 25 }, ['hlg']: {top: 4, left: 14, right: 14}},
  ['md']: {['hsm']: { top: 4, left: 25, right: 25 }, ['hmd']: { top: 4, left: 50, right: 50 }, ['hlg']: { top: 4, left: 25, right: 25 }},
  ['lg']: {['hsm']: { top: 4, left: 25, right: 25 }, ['hmd']: { top: 4, left: 50, right: 50 }, ['hlg']: { top: 4, left: 25, right: 25 }},
  ['xl']: {['hsm']: { top: 4, left: 25, right: 25 }, ['hmd']: { top: 4, left: 25, right: 25 }, ['hlg']: { top: 4, left: 25, right: 25 }},
})

/**主页栅格列间距*/
export const HomeCardGutter = BreakpointFunction2D<GutterOption>({
  ['sm']: {['hsm']: {x: 12, y: 15}, ['hmd']: {x: 12, y: 15}, ['hlg']: {x: 12, y: 15}},
  ['md']: {['hsm']: { x: 12, y: 15 }, ['hmd']: {x: 12, y: 15}, ['hlg']: {x: 17.6, y: 22} },
  ['lg']: {['hsm']: {x: 17.6, y: 22} , ['hmd']: {x: 17.6, y: 22} , ['hlg']: {x: 17.6, y: 22} },
  ['xl']: {['hsm']: {x: 17.6, y: 22} , ['hmd']: {x: 17.6, y: 22} , ['hlg']: {x: 17.6, y: 22} },
})

/**页面外边距(更多、设置)*/
export const PageMargin = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 12, ['hmd']: 15, ['hlg']: 15},
  ['md']: {['hsm']: 15, ['hmd']: 16, ['hlg']: 16},
  ['lg']: {['hsm']: 16, ['hmd']: 16, ['hlg']: 16},
  ['xl']: {['hsm']: 16, ['hmd']: 16, ['hlg']: 16},
})