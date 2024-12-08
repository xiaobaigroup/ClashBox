
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
