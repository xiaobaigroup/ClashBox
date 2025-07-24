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
  ['sm']: {['hsm']: ItemAlign.Center, ['hmd']: ItemAlign.Center, ['hlg']: ItemAlign.Center},
  ['md']: {['hsm']: ItemAlign.End, ['hmd']: ItemAlign.Center, ['hlg']: ItemAlign.Center},
  ['lg']: {['hsm']: ItemAlign.Center, ['hmd']: ItemAlign.Center, ['hlg']: ItemAlign.Center},
  ['xl']: {['hsm']: ItemAlign.Center, ['hmd']: ItemAlign.Center, ['hlg']: ItemAlign.Center},
})

/**Tab栏位置*/
export const TabBarPosition = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: BarPosition.End, ['hmd']: BarPosition.End, ['hlg']: BarPosition.End},
  ['md']: {['hsm']: BarPosition.Start, ['hmd']: BarPosition.End, ['hlg']: BarPosition.End},
  ['lg']: {['hsm']: BarPosition.Start, ['hmd']: BarPosition.Start, ['hlg']: BarPosition.Start},
  ['xl']: {['hsm']: BarPosition.Start, ['hmd']: BarPosition.Start, ['hlg']: BarPosition.Start},
})

/**Tab栏方向*/
export const TabBarVertical = BreakpointFunction2D<boolean>({
  ['sm']: {['hsm']: false, ['hmd']: false, ['hlg']: false},
  ['md']: {['hsm']: true, ['hmd']: false, ['hlg']: false},
  ['lg']: {['hsm']: true, ['hmd']: true, ['hlg']: true},
  ['xl']: {['hsm']: true, ['hmd']: true, ['hlg']: true},
})

/**Tab栏宽度*/
export const TabBarWidth = BreakpointFunction2D<string>({
  ['sm']: {['hsm']: '100%', ['hmd']: '100%', ['hlg']: '100%'},
  ['md']: {['hsm']: '77vp', ['hmd']: '100%', ['hlg']: '100%'},
  ['lg']: {['hsm']: '67vp', ['hmd']: '67vp', ['hlg']: '67vp'},
  ['xl']: {['hsm']: '67vp', ['hmd']: '67vp', ['hlg']: '67vp'},
})

/**Tab栏宽度-窗口*/
export const WindowTabBarWidth = BreakpointFunction2D<string>({
  ['sm']: {['hsm']: '100%', ['hmd']: '100%', ['hlg']: '100%'},
  ['md']: {['hsm']: '57vp', ['hmd']: '100%', ['hlg']: '100%'},
  ['lg']: {['hsm']: '57vp', ['hmd']: '57vp', ['hlg']: '57vp'},
  ['xl']: {['hsm']: '57vp', ['hmd']: '57vp', ['hlg']: '57vp'},
})

/**Tab栏高度-避让底部*/
export const TabBarAvoidHeight = BreakpointFunction2D<string>({
  ['sm']: {['hsm']: '67vp', ['hmd']: '77vp', ['hlg']: '77vp'},
  ['md']: {['hsm']: '100%', ['hmd']: '77vp', ['hlg']: '77vp'},
  ['lg']: {['hsm']: '100%', ['hmd']: '100%', ['hlg']: '100%'},
  ['xl']: {['hsm']: '100%', ['hmd']: '100%', ['hlg']: '100%'},
})

/**Tab栏高度-不避让底部*/
export const TabBarHeight = BreakpointFunction2D<string>({
  ['sm']: {['hsm']: '57vp', ['hmd']: '57vp', ['hlg']: '57vp'},
  ['md']: {['hsm']: '100%', ['hmd']: '57vp', ['hlg']: '57vp'},
  ['lg']: {['hsm']: '100%', ['hmd']: '100%', ['hlg']: '100%'},
  ['xl']: {['hsm']: '100%', ['hmd']: '100%', ['hlg']: '100%'},
})

/**Tab栏字体大小*/
export const TabTitleFontSize = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 12, ['hmd']: 12, ['hlg']: 12},
  ['md']: {['hsm']: 12, ['hmd']: 14, ['hlg']: 16},
  ['lg']: {['hsm']: 16, ['hmd']: 16, ['hlg']: 16},
  ['xl']: {['hsm']: 16, ['hmd']: 16, ['hlg']: 16},
})

/**Tab栏图标大小*/
export const TabIconFontSize = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 24, ['hmd']: 24, ['hlg']: 24},
  ['md']: {['hsm']: 24, ['hmd']: 26, ['hlg']: 26},
  ['lg']: {['hsm']: 26, ['hmd']: 26, ['hlg']: 26},
  ['xl']: {['hsm']: 26, ['hmd']: 26, ['hlg']: 26},
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
  ['md']: {['hsm']: 4, ['hmd']: 4, ['hlg']: 6},
  ['lg']: {['hsm']: 3, ['hmd']: 6, ['hlg']: 6},
  ['xl']: {['hsm']: 3, ['hmd']: 6, ['hlg']: 6},
})

/**主页卡片Span-3-4-6_lg*/
export const HomeCardSpan346lg = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 6, ['hmd']: 6, ['hlg']: 6},
  ['md']: {['hsm']: 4, ['hmd']: 4, ['hlg']: 6},
  ['lg']: {['hsm']: 3, ['hmd']: 4, ['hlg']: 6},
  ['xl']: {['hsm']: 3, ['hmd']: 6, ['hlg']: 6},
})

/**主页卡片ProxyINFO卡片order*/
export const HomeCardProxyInfoOrder = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 1, ['hmd']: 1, ['hlg']: 1},
  ['md']: {['hsm']: 1, ['hmd']: 3, ['hlg']: 1},
  ['lg']: {['hsm']: 1, ['hmd']: 1, ['hlg']: 1},
  ['xl']: {['hsm']: 1, ['hmd']: 1, ['hlg']: 1},
})

/**主页卡片字体大小*/
export const HomeCardFontSize = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 16, ['hmd']: 14, ['hlg']: 16},
  ['md']: {['hsm']: 14, ['hmd']: 19, ['hlg']: 20},
  ['lg']: {['hsm']: 22, ['hmd']: 22, ['hlg']: 22},
  ['xl']: {['hsm']: 22, ['hmd']: 22, ['hlg']: 22},
})

/**主页代理信息卡片字体大小*/
export const HomeCardProxyFontSize = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 16, ['hmd']: 18, ['hlg']: 18},
  ['md']: {['hsm']: 18, ['hmd']: 20, ['hlg']: 20},
  ['lg']: {['hsm']: 22, ['hmd']: 22, ['hlg']: 22},
  ['xl']: {['hsm']: 22, ['hmd']: 22, ['hlg']: 22},
})

/**主页标题栏顶部外边距*/
export const HomeTopHeight = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 0, ['hmd']: 0, ['hlg']: 0},
  ['md']: {['hsm']: 6, ['hmd']: 0, ['hlg']: 0},
  ['lg']: {['hsm']: 0, ['hmd']: 0, ['hlg']: 0},
  ['xl']: {['hsm']: 0, ['hmd']: 0, ['hlg']: 0},
})

/**主页卡片内边距*/
export const HomeCardPadding = BreakpointFunction2D<Padding>({
  ['sm']: {['hsm']: { top: 12, bottom: 18, left: 14, right: 14 }, ['hmd']: { top: 12, bottom: 18, left: 14, right: 14 }, ['hlg']: { top: 12, bottom: 18, left: 14, right: 14 }},
  ['md']: {['hsm']: { top: 15, bottom: 20, left: 15, right: 15 }, ['hmd']: { top: 15, bottom: 20, left: 15, right: 15 }, ['hlg']: { top: 15, bottom: 20, left: 15, right: 15 }},
  ['lg']: {['hsm']: { top: 16, bottom: 22, left: 16, right: 16 }, ['hmd']: { top: 16, bottom: 22, left: 16, right: 16 }, ['hlg']: { top: 16, bottom: 22, left: 16, right: 16 }},
  ['xl']: {['hsm']: { top: 17, bottom: 25, left: 17, right: 17 }, ['hmd']: { top: 17, bottom: 25, left: 17, right: 17 }, ['hlg']: { top: 17, bottom: 25, left: 17, right: 17 }},
})

/**主页栅格内边距*/
export const HomeGridRowPadding = BreakpointFunction2D<Padding>({
  ['sm']: {['hsm']: { top: 4, left: 14, right: 14 }, ['hmd']: { top: 4, left: 25, right: 25 }, ['hlg']: {top: 4, left: 14, right: 14}},
  ['md']: {['hsm']: { top: 4, left: 25, right: 25 }, ['hmd']: { top: 4, left: 50, right: 50 }, ['hlg']: { top: 4, left: 100, right: 100 }},
  ['lg']: {['hsm']: { top: 4, left: 25, right: 25 }, ['hmd']: { top: 4, left: 50, right: 50 }, ['hlg']: { top: 4, left: 25, right: 25 }},
  ['xl']: {['hsm']: { top: 4, left: 25, right: 25 }, ['hmd']: { top: 4, left: 25, right: 25 }, ['hlg']: { top: 4, left: 25, right: 25 }},
})

/**主页栅格内边距-窗口*/
export const WindowHomeGridRowPadding = BreakpointFunction2D<Padding>({
  ['sm']: {['hsm']: { top: 4, left: 10, right: 14 }, ['hmd']: { top: 4, left: 25, right: 25 }, ['hlg']: {top: 4, left: 14, right: 14}},
  ['md']: {['hsm']: { top: 4, left: 10, right: 25 }, ['hmd']: { top: 4, left: 50, right: 50 }, ['hlg']: { top: 4, left: 100, right: 100 }},
  ['lg']: {['hsm']: { top: 4, left: 10, right: 25 }, ['hmd']: { top: 4, left: 10, right: 50 }, ['hlg']: { top: 4, left: 10, right: 25 }},
  ['xl']: {['hsm']: { top: 4, left: 10, right: 25 }, ['hmd']: { top: 4, left: 10, right: 25 }, ['hlg']: { top: 4, left: 10, right: 25 }},
})

/**主页栅格列间距*/
export const HomeCardGutter = BreakpointFunction2D<GutterOption>({
  ['sm']: {['hsm']: {x: 12, y: 15}, ['hmd']: {x: 12, y: 15}, ['hlg']: {x: 12, y: 15}},
  ['md']: {['hsm']: {x: 12, y: 15 }, ['hmd']: {x: 12, y: 15}, ['hlg']: {x: 17.6, y: 22} },
  ['lg']: {['hsm']: {x: 17.6, y: 22} , ['hmd']: {x: 17.6, y: 22} , ['hlg']: {x: 17.6, y: 22} },
  ['xl']: {['hsm']: {x: 17.6, y: 22} , ['hmd']: {x: 17.6, y: 22} , ['hlg']: {x: 17.6, y: 22} },
})

/**主页卡片标题下边距*/
export const HomeCardTitleBottomMargin = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 5, ['hmd']: 5, ['hlg']: 5},
  ['md']: {['hsm']: 7, ['hmd']: 9, ['hlg']: 9},
  ['lg']: {['hsm']: 9, ['hmd']: 9, ['hlg']: 9},
  ['xl']: {['hsm']: 9, ['hmd']: 9, ['hlg']: 9},
})

/**主页卡片流量条高度*/
export const HomeCardCellularDataBarHeight = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 5, ['hmd']: 6, ['hlg']: 6},
  ['md']: {['hsm']: 5, ['hmd']: 5, ['hlg']: 5},
  ['lg']: {['hsm']: 5, ['hmd']: 5, ['hlg']: 5},
  ['xl']: {['hsm']: 5, ['hmd']: 5, ['hlg']: 5},
})

/**主页流量统计卡片上下行箭头图标大小*/
export const HomeCardCellularDataChevronSize = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 14, ['hmd']: 16, ['hlg']: 16},
  ['md']: {['hsm']: 12, ['hmd']: 22, ['hlg']: 26},
  ['lg']: {['hsm']: 26, ['hmd']: 26, ['hlg']: 26},
  ['xl']: {['hsm']: 27, ['hmd']: 27, ['hlg']: 27},
})

/**主页流量统计卡片上下行箭头间距*/
export const HomeCardCellularDataChevronSpace = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 3, ['hmd']: 10, ['hlg']: 10},
  ['md']: {['hsm']: 3, ['hmd']: 10, ['hlg']: 10},
  ['lg']: {['hsm']: 10, ['hmd']: 10, ['hlg']: 10},
  ['xl']: {['hsm']: 12, ['hmd']: 12, ['hlg']: 12},
})

/**主页流量统计卡片内容文本字体大小*/
export const HomeCardCellularDataFontSize = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 12, ['hmd']: 14, ['hlg']: 14},
  ['md']: {['hsm']: 12, ['hmd']: 16, ['hlg']: 16},
  ['lg']: {['hsm']: 16, ['hmd']: 16, ['hlg']: 16},
  ['xl']: {['hsm']: 16, ['hmd']: 17, ['hlg']: 17},
})

/**主页流量统计卡片内边距*/
export const HomeCardCellularDataPadding = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 30, ['hmd']: 30, ['hlg']: 30},
  ['md']: {['hsm']: 30, ['hmd']: 50, ['hlg']: 50},
  ['lg']: {['hsm']: 50, ['hmd']: 50, ['hlg']: 50},
  ['xl']: {['hsm']: 50, ['hmd']: 50, ['hlg']: 50},
})

/**主页卡片部分内容文本（当前节点、代理信息）二级字体大小*/
export const HomeCardPartSmFontSize = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 14, ['hmd']: 16, ['hlg']: 16},
  ['md']: {['hsm']: 16, ['hmd']: 19, ['hlg']: 20},
  ['lg']: {['hsm']: 20, ['hmd']: 20, ['hlg']: 22},
  ['xl']: {['hsm']: 22, ['hmd']: 22, ['hlg']: 22},
})

/**主页卡片部分内容文本二级字体大小*/
export const HomeCardPartSmallFontSize = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 12, ['hmd']: 12, ['hlg']: 12},
  ['md']: {['hsm']: 12, ['hmd']: 14, ['hlg']: 18},
  ['lg']: {['hsm']: 16, ['hmd']: 18, ['hlg']: 18},
  ['xl']: {['hsm']: 18, ['hmd']: 18, ['hlg']: 18},
})

/**主页卡片IP文本字体大小*/
export const HomeCardIPFontSize = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 12, ['hmd']: 15, ['hlg']: 16},
  ['md']: {['hsm']: 15, ['hmd']: 19, ['hlg']: 20},
  ['lg']: {['hsm']: 22, ['hmd']: 20, ['hlg']: 24},
  ['xl']: {['hsm']: 22, ['hmd']: 24, ['hlg']: 24},
})

/**主页卡片速度文本字体大小*/
export const HomeCardSpeedFontSize = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 12, ['hmd']: 12, ['hlg']: 12},
  ['md']: {['hsm']: 11, ['hmd']: 14, ['hlg']: 16},
  ['lg']: {['hsm']: 14, ['hmd']: 16, ['hlg']: 16},
  ['xl']: {['hsm']: 16, ['hmd']: 16, ['hlg']: 16},
})

/**主页卡片角标删除按钮大小*/
export const HomeCardDeleteButtonSize = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 22, ['hmd']: 24, ['hlg']: 24},
  ['md']: {['hsm']: 20, ['hmd']: 24, ['hlg']: 32},
  ['lg']: {['hsm']: 32, ['hmd']: 32, ['hlg']: 32},
  ['xl']: {['hsm']: 32, ['hmd']: 32, ['hlg']: 32},
})

/**主页切换模式卡片按钮圆角*/
export const HomeCardSwitchModeBorderRadius = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 16, ['hmd']: 16, ['hlg']: 20},
  ['md']: {['hsm']: 16, ['hmd']: 20, ['hlg']: 20},
  ['lg']: {['hsm']: 20, ['hmd']: 20, ['hlg']: 20},
  ['xl']: {['hsm']: 20, ['hmd']: 20, ['hlg']: 20},
})

/**主页卡片文本最大行数*/
export const HomeCardTextMaxLines = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 1, ['hmd']: 2, ['hlg']: 2},
  ['md']: {['hsm']: 1, ['hmd']: 2, ['hlg']: 2},
  ['lg']: {['hsm']: 2, ['hmd']: 2, ['hlg']: 2},
  ['xl']: {['hsm']: 2, ['hmd']: 2, ['hlg']: 2},
})

/**页面外边距(更多、设置)*/
export const PageMargin = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 12, ['hmd']: 15, ['hlg']: 15},
  ['md']: {['hsm']: 15, ['hmd']: 16, ['hlg']: 16},
  ['lg']: {['hsm']: 16, ['hmd']: 16, ['hlg']: 16},
  ['xl']: {['hsm']: 16, ['hmd']: 16, ['hlg']: 16},
})

/**窗口化更多标题字体大小*/
export const WindowModeMoreTitleFontSize = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 24, ['hmd']: 24, ['hlg']: 24},
  ['md']: {['hsm']: 23, ['hmd']: 27, ['hlg']: 27},
  ['lg']: {['hsm']: 27, ['hmd']: 30, ['hlg']: 30},
  ['xl']: {['hsm']: 30, ['hmd']: 30, ['hlg']: 30},
})

/**列表列数（配置页）*/
export const ListLanes = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 1, ['hmd']: 1, ['hlg']: 1},
  ['md']: {['hsm']: 2, ['hmd']: 2, ['hlg']: 2},
  ['lg']: {['hsm']: 2, ['hmd']: 2, ['hlg']: 2},
  ['xl']: {['hsm']: 3, ['hmd']: 3, ['hlg']: 3},
})

/**列表列数（代理页）*/
export const ProxyListLanes = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 2, ['hmd']: 2, ['hlg']: 2},
  ['md']: {['hsm']: 2, ['hmd']: 3, ['hlg']: 3},
  ['lg']: {['hsm']: 3, ['hmd']: 4, ['hlg']: 4},
  ['xl']: {['hsm']: 4, ['hmd']: 4, ['hlg']: 4},
})

/**列表间距*/
export const ListGutter = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 8, ['hmd']: 8, ['hlg']: 8},
  ['md']: {['hsm']: 10, ['hmd']: 10, ['hlg']: 10},
  ['lg']: {['hsm']: 15, ['hmd']: 15, ['hlg']: 15},
  ['xl']: {['hsm']: 20, ['hmd']: 20, ['hlg']: 20},
})

/**路由主页列表内边距*/
export const NavigationListPadding = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 13, ['hmd']: 13, ['hlg']: 13},
  ['md']: {['hsm']: 15, ['hmd']: 15, ['hlg']: 15},
  ['lg']: {['hsm']: 28, ['hmd']: 28, ['hlg']: 28},
  ['xl']: {['hsm']: 36, ['hmd']: 36, ['hlg']: 36},
})

/**内容外边距*/
export const TabContentTitleMargin = BreakpointFunction2D<number>({
  ['sm']: {['hsm']: 13, ['hmd']: 13, ['hlg']: 13},
  ['md']: {['hsm']: 28, ['hmd']: 28, ['hlg']: 28},
  ['lg']: {['hsm']: 36, ['hmd']: 36, ['hlg']: 36},
  ['xl']: {['hsm']: 36, ['hmd']: 36, ['hlg']: 36},
})

/**更多页是否清空路由*/
export const NeedClearMoreStack = BreakpointFunction2D<boolean>({
  ['sm']: {['hsm']: true, ['hmd']: true, ['hlg']: true},
  ['md']: {['hsm']: false, ['hmd']: false, ['hlg']: false},
  ['lg']: {['hsm']: false, ['hmd']: false, ['hlg']: false},
  ['xl']: {['hsm']: false, ['hmd']: false, ['hlg']: false},
})