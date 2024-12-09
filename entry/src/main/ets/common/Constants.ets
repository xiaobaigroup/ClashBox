import { BreakpointState } from "./breakpointsystem";

// 更多列表类
export class moreData {
  icons: Resource;
  name?: string;
  title: string | Resource;
  isCheck: boolean

  constructor( icons: Resource, name: string, title: ResourceStr, isCheck:boolean) {
    this.icons = icons
    this.name = name
    this.title = title
    this.isCheck = isCheck
  }
}

// 更多 -> MoreListItem
export  const ListMoreData = (): moreData[] => {
  let result: moreData[] = new Array()
  result = [
    new moreData($r('sys.symbol.doc_text_fill'), 'Log', $r('app.string.Log'),  false),
    new moreData($r('sys.symbol.externaldrive_fill_3'), 'Resources', $r('app.string.Resources'), false),
    new moreData($r('sys.symbol.list_bullet'), 'Request', $r('app.string.Request'), false),
    new moreData($r('sys.symbol.swap'), 'Connect', $r('app.string.Connect'), false),
    new moreData($r('sys.symbol.pencil_line'), 'Overwrite', $r('app.string.Overwrite'), false),
    //new moreData($r('sys.symbol.gearshape'), 'Settings', $r('app.string.Settings'), false),
  ]
  return result
}

// 更多 -> 覆写OverwriteListItem
export  const ListOverwriteData = (): moreData[] => {
  let result: moreData[] = new Array()
  result = [
    new moreData($r('sys.symbol.pencil_line_1'), 'Log', $r('app.string.Basic'),  false),
    new moreData($r('sys.symbol.worldclock'), 'Resources', $r('app.string.Network'), false),
    new moreData($r('sys.symbol.externaldrive_fill_3'), 'Request', $r('app.string.DNS'), false),
  ]
  return result
}


/* TabContent标题栏 */
// 工具symbol大小
export const TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE:Length = 24

// 整个title区域的高度
export const TAB_CONTENT_TITLE_HEIGHT: number = 56
// fontSize
export const TAB_CONTENT_TITLE_FONT_SIZE: number = 30
// fontWeight
export const TAB_CONTENT_TITLE_FONT_WEIGHT: number = FontWeight.Bold

// 主页 -> 代理启动按钮内计时器的初始值
export const PROXY_STARTED_DURATION_INIT_VALUE: string = '00:00:00'

// 组件animation duration值: 300
export const ANIMATION_DURATION_300: number = 300

// 设置列表类
export class settingsData {
  icons: Resource;
  name?: string;
  title: string | Resource;
  subtitle: string | Resource;
  hint: string | Resource;
  isCheck: boolean

  constructor( icons: Resource, name: string, title: ResourceStr, subtitle: ResourceStr, hint: ResourceStr, isCheck:boolean) {
    this.icons = icons
    this.name = name
    this.title = title
    this.subtitle = subtitle
    this.hint = hint
    this.isCheck = isCheck
  }
}

// 设置页列表项
export const SettingsListItem = (): settingsData[] => {
  let result: settingsData[] = new Array()
  result = [
    new settingsData($r('sys.symbol.translate_c2e'), 'Language', $r('app.string.Language'), '', $r('app.string.LanguageHint_Zh'), false),
    new settingsData($r('sys.symbol.brush_fill'), 'Appearance', $r('app.string.Appearance'), $r('app.string.AppearanceSubtitle'), '', false),
    new settingsData($r('sys.symbol.externaldrive_fill'), 'Backup', $r('app.string.Backup_Recovery'), $r('app.string.BackgrounderSubtitle'), '', false),
    new settingsData($r('sys.symbol.lock_fill'), 'ApplicationLock', $r('app.string.ApplicationLock'), $r('app.string.ApplicationicationLockSubtitle'), '', false),
    new settingsData($r('sys.symbol.ellipsis_message_fill'), 'Notice', $r('app.string.Notice'), $r('app.string.NoticeSubtitle'), '', false),
    new settingsData($r('sys.symbol.checkmark_square_on_square_fill'), 'Backgrounder', $r('app.string.Backgrounder'), $r('app.string.BackgrounderSubtitle'), '', false),
    new settingsData($r('sys.symbol.trash_fill'), 'WipeData', $r('app.string.WipeData'), $r('app.string.WipeDataSubtitle'), '', false),
    new settingsData($r('sys.symbol.person_shield_fill'), 'Disclaimer', $r('app.string.Disclaimer'), '', '', false),
    new settingsData($r('sys.symbol.info_circle'), 'About', $r('app.string.About'), '', '', false),
  ]
  return result
}


/* 断点相关 */
// List组件的布局 列数或行数
export const BPS_LIST_LANES_1_1_2_3_4: BreakpointState<number> = BreakpointState.of({
  xs: 1,
  sm: 1,
  md: 2,
  lg: 3,
  xl: 3,
  xxl: 4
})


// List组件的布局 列间距
export const BPS_LIST_GUTTER_1_1_2_3_3: BreakpointState<number> = BreakpointState.of({
  xs: 5,
  sm: 8,
  md: 10,
  lg: 15,
  xl: 20
})

// TabContent的title Margin
export const BPS_TAB_CONTENT_TITLE_MARGIN_12_13_28_36: BreakpointState<number> = BreakpointState.of({
  xs: 12,
  sm: 13,
  md: 28,
  lg: 36,
  xl: 36
})