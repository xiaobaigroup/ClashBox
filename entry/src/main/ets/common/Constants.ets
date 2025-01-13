import { CustomThemeName } from "./AppTheme";
import { BreakpointState } from "./breakpointsystem";


/* 基础 */
// borderRadius 20
export const BORDER_RADIUS_20: number = 20
// bindSheet 初始默认高度
export const BIND_SHEET_CONTAINER_HEIGHT: number = 684
// bindSheet Title 整体高度
export const BIND_SHEET_TITLE_CONTAINER_HEIGHT: number = 56
// bindSheet 在不使用默认的dragBar时，填充dragBar区域所占位的高度
export const BIND_SHEET_DRAG_BAR_HEIGHT: number = 16
// bindSheet Title 左侧返回symbol 宽度
export const BIND_SHEET_TITLE_LEFT_SYMBOL_WEIGHT: number = 40
// bindSheet Title 左侧返回symbol 高度
export const BIND_SHEET_TITLE_LEFT_SYMBOL_HEIGHT: number = 40
// bindSheet Title 左侧返回symbol 大小
export const BIND_SHEET_TITLE_LEFT_SYMBOL_FONT_SIZE: number = 24
// bindSheet Title main fontSize
export const BIND_SHEET_MAIN_FONTSIZE: number = 20
// bindSheet Title main fontWeight
export const BIND_SHEET_MAIN_FONT_WEIGHT: number = FontWeight.Bold
// bindSheet Title sub fontSize
export const BIND_SHEET_SUB_FONTSIZE: number = 14

// fontSize 14
export const FONT_SIZE_14: number = 14
// fontSize 16
export const FONT_SIZE_16: number = 16

// TextInput height
export const TEXT_INPUT_HEIGHT: number = 45
// TextArea
export const TEXT_AREA_MAX_LENGTH: number = 999

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

// enum：routeName
export enum RouteName {
  IMPORT_CONFIG_FROM_URL = 'ImportConfigFromURL',
  IMPORT_CONFIG_FROM_QR_CODE = 'ImportConfigFromQRcode',
  IMPORT_CONFIG_FROM_FILE = 'ImportConfigFromFile',
  CREATE_NEW_CONFIG = 'CreateNewConfig',
}

// 更多列表类
export class moreData {
  icons: Resource;
  name?: string;
  title: string | Resource;
  subtitle: string | Resource;
  sign: number;
  isCheck: boolean

  constructor( icons: Resource, name: string, title: ResourceStr, subtitle: ResourceStr, sign: number, isCheck:boolean) {
    this.icons = icons
    this.name = name
    this.title = title
    this.subtitle = subtitle
    this.sign = sign
    this.isCheck = isCheck
  }
}

// 更多 -> MoreListItem
export  const ListMoreData = (): moreData[] => {
  let result: moreData[] = new Array()
  result = [
    new moreData($r('sys.symbol.doc_text_fill'), 'Log', $r('app.string.Log'), '', 0, false),
    new moreData($r('sys.symbol.externaldrive_fill_3'), 'Resources', $r('app.string.Resources'), '', 0, false),
    new moreData($r('sys.symbol.list_bullet'), 'Request', $r('app.string.Request'), '', 0, false),
    new moreData($r('sys.symbol.swap'), 'Connect', $r('app.string.Connect'), '', 0, false),
    new moreData($r('sys.symbol.pencil_line'), 'Overwrite', $r('app.string.Overwrite'), '', 0, false),
    new moreData($r('sys.symbol.navigation'), 'Diversion', $r('app.string.Diversion_Strategy'), '', 0, false),
    new moreData($r('sys.symbol.clean_fill'), 'QueryIP', $r('app.string.query_ip_region'), $r('app.string.query_ip_region_Subtitle'), 0, false),
  ]
  return result
}

// 更多 -> 覆写OverwriteListItem
export  const ListOverwriteData = (): moreData[] => {
  let result: moreData[] = new Array()
  result = [
    new moreData($r('sys.symbol.pencil_line_1'), 'Basic', $r('app.string.Basic'), '', 0,  false),
    new moreData($r('sys.symbol.worldclock'), 'Network', $r('app.string.Network'), '', 0, false),
    new moreData($r('sys.symbol.externaldrive_fill_3'), 'DNS', $r('app.string.DNS'), '', 0, false),
    new moreData($r('sys.symbol.clean_fill'), 'default', $r('app.string.Reset_overwrite_settings'), $r('app.string.Reset_overwrite_settings_subtitle'), 0, false),
  ]
  return result
}

// 更多 -> 覆写 -> 基础Listitem
export  const ListOverwriteBasicData = (): moreData[] => {
  let result: moreData[] = new Array()
  result = [
    new moreData($r('sys.symbol.info_circle'), 'LogLevel', $r('app.string.LogLevel'), $r('app.string.Info'), 0,  false),
    new moreData($r('sys.symbol.person_shield_fill'), 'UA', $r('app.string.UA'), $r('app.string.Default_UA'), 0, false),
    new moreData($r('sys.symbol.stopwatch_2'), 'TCP_Active', $r('app.string.TCP_Active'), $r('app.string.TCP_interval'), 1, false),
    new moreData($r('sys.symbol.bolt_filled_on_circle'), 'Test-Link', $r('app.string.Test_Latency_Link'), $r('app.string.Default_test_latency_link'), 1, false),
    new moreData($r('sys.symbol.record_circle'), 'ProxyPort', $r('app.string.Proxy_Port'), '7890', 1,  false),
    new moreData($r('sys.symbol.list_bullet_square_fill'), 'Hosts', $r('app.string.Hosts'), '', 1, false),
    new moreData($r('sys.symbol.mobiledata'), 'Ipv6', $r('app.string.IPv6'), '', 2, false),
    new moreData($r('sys.symbol.line_arrowtriangle_2_inward'), 'UnifiedLatency', $r('app.string.UnifiedLatency'), $r('app.string.Unified_Latency_Subtitle'), 2, false),
    new moreData($r('sys.symbol.order_play'), 'TCP-Concurrency', $r('app.string.TCP_Concurrency'), '', 2,  false),
    new moreData($r('sys.symbol.selector'), 'External-Control', $r('app.string.External_Control'), $r('app.string.External_Control_Subtitle'), 2, false),
  ]
  return result
}

// 更多 -> 覆写 -> DNSListitem
export  const ListOverwriteDNSData = (): moreData[] => {
  let result: moreData[] = new Array()
  result = [
    new moreData($r('sys.symbol.selector'), 'OverwriteDNS', $r('app.string.OverwriteDNS'), '', 2,  false),
    new moreData($r('sys.symbol.selector'), 'Option', $r('app.string.option'), '', 3, false),
    new moreData($r('sys.symbol.selector'), 'State', $r('app.string.State'), $r('app.string.State_subtitle'), 2, false),
    new moreData($r('sys.symbol.selector'), 'UseHosts', $r('app.string.UseHosts'), '', 2,  false),
    new moreData($r('sys.symbol.selector'), 'Use-System-Hosts', $r('app.string.Use_System_Hosts'), '', 2, false),
    new moreData($r('sys.symbol.selector'), 'IPv6', $r('app.string.IPv6'), $r('app.string.Info'), 2,  false),
    new moreData($r('sys.symbol.selector'), 'Follow-The-Rules', $r('app.string.Follow_The_Rules'), $r('app.string.Follow_The_Rules_Subtitle'), 2, false),
    new moreData($r('sys.symbol.selector'), 'Priority-Use-H3', $r('app.string.Priority_Use_H3'), $r('app.string.Priority_Use_H3_Subtitle'), 2, false),
    new moreData($r('sys.symbol.selector'), 'DNS-Mode', $r('app.string.DNS_Mode'), $r('app.string.DNS_Mode_Subtitle'), 0,  false),
    new moreData($r('sys.symbol.selector'), 'FakeIP-Range', $r('app.string.FakeIP_Range'), $r('app.string.FakeIP_Range_Subtitle_1'), 1, false),
    new moreData($r('sys.symbol.selector'), 'FakeIP-Filtering', $r('app.string.FakeIP_Filtering'), '', 1,  false),
    new moreData($r('sys.symbol.selector'), 'Default-Domain-Name-Server', $r('app.string.Default_Domain_Name_Server'), $r('app.string.Default_Domain_Name_Server_Subtitle'), 1, false),
    new moreData($r('sys.symbol.selector'), 'Domain-Name-Server-Strategy', $r('app.string.Domain_Name_Server_Strategy'), $r('app.string.Domain_Name_Server_Strategy_Subtitle'), 1, false),
    new moreData($r('sys.symbol.selector'), 'Domain-Name-Server', $r('app.string.Domain_Name_Server'), $r('app.string.Domain_Name_Server_Subtitle'), 1,  false),
    new moreData($r('sys.symbol.selector'), 'FallBack', $r('app.string.FallBack'), $r('app.string.FallBack_Subtitle'), 1, false),
    new moreData($r('sys.symbol.selector'), 'Proxy-Domain-Name-Server', $r('app.string.Proxy_Domain_Name_Server'), $r('app.string.Proxy_Domain_Name_Server_Subtitle'), 1,  false),
    new moreData($r('sys.symbol.selector'), 'FallBack-Filtering', $r('app.string.FallBack_Filtering'), '', 3, false),
    new moreData($r('sys.symbol.selector'), 'GeoIP', $r('app.string.GeoIP'), '', 2, false),
    new moreData($r('sys.symbol.selector'), 'GeoIP-Code', $r('app.string.GeoIP_Code'), $r('app.string.GeoIP_Code_Subtitle_1'), 1,  false),
    new moreData($r('sys.symbol.selector'), 'IP/Mask', $r('app.string.IP_Mask'), '', 1, false),
    new moreData($r('sys.symbol.selector'), 'LogLevel', $r('app.string.LogLevel'), '', 1,  false),
    new moreData($r('sys.symbol.selector'), 'Domain', $r('app.string.Domain_Name'), '', 1, false),
  ]
  return result
}

// 更多 -> 覆写 -> 网络Listitem
export  const ListOverwriteNetworkData = (): moreData[] => {
  let result: moreData[] = new Array()
  result = [
    new moreData($r('sys.symbol.key_shield_fill'), 'VPN', 'VPN', '', 2,  false),
    new moreData($r('sys.symbol.selector'), 'Option', $r('app.string.option'), '', 3, false),
    new moreData($r('sys.symbol.selector'), 'IPv6', $r('app.string.IPv6'), $r('app.string.Info'), 2,  false),
    new moreData($r('sys.symbol.satellite_map_fill'), 'Stack-Mode', $r('app.string.Stack_Mode'), 'gvisor', 0, false),
    new moreData($r('sys.symbol.slider_horizontal_2'), 'Route-Mode', $r('app.string.Route_Mode'), $r('app.string.Using_Configuration'), 0,  false),
    new moreData($r('sys.symbol.local_fill'), 'Route-Address', $r('app.string.Routing_Address'), $r('app.string.Routing_Address_Subtitle'), 1, false),
  ]
  return result
}

/**
 * 设置列表参数
 */
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

/**
 * 设置页列表
 */
export const SettingsListItem = (): settingsData[] => {
  let result: settingsData[] = new Array()
  result = [
    new settingsData($r('sys.symbol.translate_c2e'), 'Language', $r('app.string.Language'), '', $r('app.string.Language_Subtitle'), false),
    new settingsData($r('sys.symbol.brush_fill'), 'Appearance', $r('app.string.Appearance'), $r('app.string.AppearanceSubtitle'), '', false),
    new settingsData($r('sys.symbol.externaldrive_fill'), 'Backup', $r('app.string.Backup_Recovery'), $r('app.string.BackgrounderSubtitle'), '', false),
    //new settingsData($r('sys.symbol.lock_fill'), 'Kernel', $r('app.string.Kernel'), $r('app.string.ApplicationicationLockSubtitle'), $r('app.string.already_open'), false),
    new settingsData($r('sys.symbol.ellipsis_message_fill'), 'Notice', $r('app.string.Notice'), $r('app.string.subtitle'), '', false),
    new settingsData($r('sys.symbol.checkmark_square_on_square_fill'), 'Backgrounder', $r('app.string.Backgrounder'), $r('app.string.BackgrounderSubtitle'), '', false),
    new settingsData($r('sys.symbol.satellite_map_fill'), 'Kernel', $r('app.string.kernel'), $r('app.string.kernel_subtitle'), '', false),
    new settingsData($r('sys.symbol.trash_fill'), 'WipeData', $r('app.string.WipeData'), $r('app.string.WipeDataSubtitle'), '', false),
    new settingsData($r('sys.symbol.person_shield_fill'), 'Disclaimer', $r('app.string.Disclaimer'), '', '', false),
    new settingsData($r('sys.symbol.info_circle'), 'About', $r('app.string.About'), '', '', false),
  ]
  return result
}

/**
 * 语言列表参数
 */
export class LanguageData {
  title: string | Resource;
  subtitle: string | Resource;
  areaID: string;
  isCheck: boolean

  constructor(title: ResourceStr, subtitle: ResourceStr, areaID: string, isCheck:boolean) {
    this.title = title
    this.subtitle = subtitle
    this.areaID = areaID
    this.isCheck = isCheck
  }
}
/**
 * 设置页多语言列表
 */
export const LanguageListItem = (): LanguageData[] => {
  let result: LanguageData[] = new Array()
  result = [
    new LanguageData($r('app.string.SimplifiedChinese'), $r('app.string.SimplifiedChinese_Subtitle'), 'zh-Hans', false),
    new LanguageData($r('app.string.TraditionalChinese_HK'), $r('app.string.TraditionalChinese_HK_Subtitle'), 'zh-Hant', false),
    new LanguageData($r('app.string.TraditionalChinese_TW'), $r('app.string.TraditionalChinese_TW_Subtitle'), 'zh-Hant', false),
    new LanguageData($r('app.string.English'), $r('app.string.English_Subtitle'), 'en-Latn', false),

  ]
  return result
}

/**
 * 外观页菜单参数
 */
export interface AppearanceListItemProp {
  title: string | Resource
  // 自定义主题的名字
  customThemeName?: CustomThemeName
  // `start`方向上`Symbol`的颜色数组
  startSymbolFontColor?: Array<ResourceColor>
  children?: Array<AppearanceListItemProp>
}
/**
 * 外观页菜单列表
 */
export const AppearanceList: AppearanceListItemProp[] = [
  { title: $r('app.string.dark_mode'),
    children: [
      { title: $r('app.string.follow_system') },
      { title: $r('app.string.always_light') },
      { title: $r('app.string.always_dark') },
    ]
  },
  { title: $r('app.string.theme_color'),
    children: [
      { title: $r('app.string.star_river_blue'), customThemeName: 'blueAppTheme', startSymbolFontColor: [$r('sys.color.icon_emphasize')] },
      { title: $r('app.string.cat_blue'), customThemeName: 'catBlueAppTheme', startSymbolFontColor: [$r('app.color.theme_color_main_cat_blue')] },
      { title: $r('app.string.yellow'), customThemeName: 'yellowAppTheme', startSymbolFontColor: [$r('app.color.theme_color_main_yellow')] },
      { title: $r('app.string.red'), customThemeName: 'redAppTheme', startSymbolFontColor: [$r('app.color.theme_color_main_red')] },
      { title: $r('app.string.purple'), customThemeName: 'purpleAppTheme', startSymbolFontColor: [$r('app.color.theme_color_main_purple')] },
      { title: $r('app.string.pink'), customThemeName: 'pinkAppTheme', startSymbolFontColor: [$r('app.color.theme_color_main_pink')] },
      { title: $r('app.string.green'), customThemeName: 'greenAppTheme', startSymbolFontColor: [$r('app.color.theme_color_main_green')] },
    ]
  },
  { title: $r('app.string.suspension_button_position'),
    children: [
      { title: $r('app.string.right') },
      { title: $r('app.string.middle') },
      { title: $r('app.string.left') },
    ]
  }
  // { title: 'Theme',
  //   subtitle: '',
  //   children:[
  //     { icon: $r('sys.symbol.rectangle_on_rectangle_fill'), title: $r('app.string.blurred_background'), subtitle: $r('app.string.blurred_background_subtitle'), isOn: false},
  //     { icon: $r('sys.symbol.livephoto'), title: $r('app.string.animation_effects'), subtitle: $r('app.string.animation_effects_subtitle'), subtitle2: $r('app.string.experimental_function'), isOn: false},
  //   ]
  // },
  // { title: 'Ability',
  //   subtitle: '',
  //   children: [
  //     { icon: $r('sys.symbol.message'), title: $r('app.string.homepage_greetings'), subtitle: $r('app.string.homepage_greetings_subtitle'), isOn: false},
  //
  //   ]
  // }
]

/**
 * 关于列表参数
 */
export interface AboutListItemProp {
  name: string
  title: string | Resource
  subtitle: string | Resource
  sign?: number
  isOn?: boolean
  children?: Array<AboutListItemProp>
}
/**
 * 关于列表
 */
export const AboutList: AboutListItemProp[] = [
  {
    title: 'Version',
    subtitle: '',
    name: '',
    children: [
      { title: $r('app.string.Application_Version'), subtitle: '2.0.000 Preview1',sign: 0, name: 'ApplicationVersion' },
      { title: $r('app.string.Kernel_Version'), subtitle: 'Unknown',sign: 0, name: 'KernelVersion' }
    ]
  },
  {
    title: 'Experiment',
    subtitle: '',
    name: '',
    children: [
      { title: $r('app.string.experimental_function'), subtitle: $r('app.string.experimental_function_Subtitle'), sign: 1, name: 'ExperimentalFunction', isOn: true },
    ]
  },
  {
    title: 'Contributors',
    subtitle: '',
    name: '',
    children: [
      { title: $r('app.string.Contributors'), subtitle: '', sign: 2, name: 'Contributors' },
    ]
  },
  {
    title: 'General',
    subtitle: '',
    name: '',
    children: [
      { title: $r('app.string.UseGuidance'), subtitle: '', sign: 2, name: 'UseGuidance' },
      { title: $r('app.string.FQ'), subtitle: '', sign: 2, name: 'FQ' },
    ]
  },
  { title: 'Update',
    subtitle: '',
    name: '',
    children: [
      { title: $r('app.string.Check_Updates'), subtitle: '', sign: 2, name: 'CheckUpdate' },
      { title: $r('app.string.UpdateChannels'), subtitle: $r('app.string.UpdateChannels_Subtitle1'), sign: 3, name: 'UpdateChannels',
        children: [
          { title: $r('app.string.UpdateChannels_Subtitle1'), name: 'Github', subtitle: '' },
          { title: 'Gitee', name: 'Gitee', subtitle: '' }
         ]
      },
      { title: $r('app.string.Auto_Check_Updates'), subtitle: '', sign: 1, name: 'Auto', isOn: false },
    ]
  },
  {
    title: 'Contact',
    subtitle: '',
    name: '',
    children: [
      { title: $r('app.string.Official_Telegram_Channel'), subtitle: '', sign: 2, name: 'Telegram' },
      { title: $r('app.string.Official_Discord_Community'), subtitle: '', sign: 2, name: 'Discord' },
      { title: $r('app.string.Development_Team_Email'), subtitle: '', sign: 2, name: 'Email' },
    ]
  },
  {
    title: 'Repositories',
    subtitle: '',
    name: '',
    children: [
      { title: $r('app.string.ProjectRepositories'), subtitle: '', sign: 2, name: 'Repositories' },
    ]
  }
]

/**
 * 贡献者名单参数
 */
export interface ContributorsListItemProp {
  image?: Resource
  title: string | Resource
  subtitle?: string | Resource
  contact?: string | Resource
  contact2?: string
}
/**
 * 贡献者名单列表
 */
export const ContributorsList: ContributorsListItemProp[] = [
  { title: '小白', subtitle: $r('app.string.XiaoBai_Subtitle'), contact: 'Github', image: $rawfile('XiaoBai.png')},
  { title: '船长', subtitle: $r('app.string.ChuanZhang_Subtitle'), contact: $r('app.string.Email'), image: $rawfile('chuanzhang.png')},
  { title: '柯蓝KL', subtitle: $r('app.string.KL_Subtitle'), contact: $r('app.string.Email'), contact2: 'Telegram', image: $rawfile('kl.png')},
  { title: '恩临大帝', subtitle: $r('app.string.FrondEnd_Development'), contact: $r('app.string.Email'), image: $rawfile('enlin.png')},
  { title: 'crazypig321', subtitle: $r('app.string.FrondEnd_Development'), contact: 'Github', image: $rawfile('crazypig321.png')},
  { title: '小雅', subtitle: $r('app.string.FrondEnd_Development'), contact: 'Github', image: $rawfile('ya.png')},
  { title: '凛凛早露', subtitle: $r('app.string.LLZL_Subtitle'), image: $rawfile('llzl.png')},
  { title: $r('app.string.Dear_Group_Members'), subtitle: $r('app.string.Dear_Group_Members_Subtitle'), image: $rawfile('group.jpg')},
]

/**
 * 检查更新页列表参数
 */
export interface CheckUpdateListItemProp {
  icons?: Resource
  title: string | Resource
  subtitle: string | Resource
  children?: Array<CheckUpdateListItemProp>
}
/**
 *  检查更新页列表
 */
export const CheckUpdateList: CheckUpdateListItemProp[] = [
  {
    title: 'Version',
    subtitle: '',
    children: [
      { title: $r('app.string.current_version'), subtitle: '2.0.000 Preview1' },
      { title: $r('app.string.latest_version'), subtitle: '2.0.000' }
    ]
  },
  {
    title: 'Go',
    subtitle: '',
    children: [
      { icons: $r('sys.symbol.arrowshape_down_to_line_fill'), title: $r('app.string.go_download_update'), subtitle: $r('app.string.go_download_update_subtitle') },
    ]
  },
  {
    title: 'Ignore',
    subtitle: '',
    children: [
      { icons: $r('sys.symbol.hand_raised_hexagon'), title: $r('app.string.ignore_update'), subtitle: '' },
    ]
  }
]


/* 断点相关 */
// List组件的布局 列数或行数
export const BPS_LIST_LANES_1_1_2_3_4: BreakpointState<number> = BreakpointState.of({
  xs: 1,  sm: 1,  md: 2,  lg: 3,  xl: 3,  xxl: 4 })

// List组件的布局 列间距
export const BPS_LIST_GUTTER_1_1_2_3_3: BreakpointState<number> = BreakpointState.of({
  xs: 5,  sm: 8,  md: 10,  lg: 15,  xl: 20 })

// bindSheet内List内边距 Padding（主要是为了bindSheet内使用Navigation套List使用的，因为路由在md设备往上的默认双栏效果）
export const BPS_NAVIGATION_LIST_PADDING_12_13_13_28_36: BreakpointState<number> = BreakpointState.of({
  xs: 12,  sm: 13,  md: 13,  lg: 28,  xl: 36 })

// TabContent的title Margin
export const BPS_TAB_CONTENT_TITLE_MARGIN_12_13_28_36: BreakpointState<number> = BreakpointState.of({
  xs: 12,  sm: 13,  md: 28,  lg: 36,  xl: 36 })

// 更多页整体外边距
export const morePageMargin_12_14_16: BreakpointState<number> = BreakpointState.of({
  xs: 12, sm: 16, md: 16, lg: 16, xl: 16
})

// 更多页列表底边距
export const morePagelistBottom_10_14: BreakpointState<number> = BreakpointState.of({
  xs: 10, sm: 10, md: 14, lg: 14, xl: 14
})

// 列表高度（主要是更多相关页面使用）
export const listHeight_610_590: BreakpointState<number> = BreakpointState.of({
  xs: 620, sm: 620, md: 590, lg: 590, xl: 590
})

// 设置页列表高度
export const SettingslistHeight_590_500: BreakpointState<number> = BreakpointState.of({
  xs: 620, sm: 620, md: 500, lg: 500, xl: 500
})

// MarginGenerate
export interface MarginGenerate {
  left: number, top: number, right: number,
  bottom?:number
}

/**
 * 主页卡片内边距
 */
export const HomeCardPadding_14_15_16_17: BreakpointState<MarginGenerate> = BreakpointState.of({
  sm: ({top: 14, bottom: 18, left: 14, right: 14} as MarginGenerate),
  md: ({top: 15, bottom: 20, left: 15, right: 15} as MarginGenerate),
  lg: ({top: 16, bottom: 22, left: 16, right: 16} as MarginGenerate),
  xl: ({top: 17, bottom: 25, left: 17, right: 17} as MarginGenerate)
})

/**
 * 主页整个卡片区域边距
 */
export const HomeCardAreaPadding: BreakpointState<MarginGenerate> = BreakpointState.of({
  sm: ({top: 4, left: 14, right: 14} as MarginGenerate),
  md: ({top: 4, left: 110, right: 110} as MarginGenerate),
  lg: ({top: 4, left: 14, right: 14} as MarginGenerate),
  xl: ({top: 4, left: 14, right: 14} as MarginGenerate)
})

// 主页栅格卡片间距定义
export interface gutterHomeGridcol {
  x: number, y: number
}
/**
 * 主页栅格卡片间距
 */
export const gutterHomeGridcol_12_15: BreakpointState<gutterHomeGridcol> = BreakpointState.of({
  sm: ({x: 12, y: 15} as gutterHomeGridcol),
  md: ({x: 35, y: 22}  as gutterHomeGridcol),
  lg: ({x: 17.6, y: 22}  as gutterHomeGridcol),
  xl: ({x: 17.6, y: 22}  as gutterHomeGridcol)
})
/**
 * 主页卡片标题下边距（5，7，9）
 */
export const HomeCardTitleBottomMargin: BreakpointState<number> = BreakpointState.of({
  sm: 5, md: 7, lg: 9, xl: 9
})
/**
 * 主页卡片标题按钮间距
 */
export const HomeCardTitleButtonPadding: BreakpointState<number> = BreakpointState.of({
  sm: 10, md: 20, lg: 22, xl: 22
})
/**
 * 主页模式卡片上下边距（3，6）
 */
export const HomeCardSwitchModeRowMargin: BreakpointState<number> = BreakpointState.of({
  sm: 3, md: 6, lg: 6, xl: 6
})
/**
 * 主页模式卡片字体大小（16，27，26，27）
 */
export const HomeCardSwitchModeFontSize: BreakpointState<number> = BreakpointState.of({
  sm: 16, md: 20, lg: 20, xl: 22
})
/**
 * 主页模式卡片文本上下边距（6，7）
 */
export const HomeCardSwitchModeTextMargin: BreakpointState<MarginGenerate> = BreakpointState.of({
  sm: ({ top: 6, bottom: 6 } as MarginGenerate),
  md: ({ top: 7, bottom: 7 } as MarginGenerate),
  lg: ({ top: 7, bottom: 7 } as MarginGenerate),
  xl: ({ top: 7, bottom: 7 } as MarginGenerate)
})
/**
 * 主页流量统计卡片统计条边距
 */
export const HomeCardCellularDatabarMargin: BreakpointState<MarginGenerate> = BreakpointState.of({
  xs: ({ top: 10, bottom: 7 } as MarginGenerate),
  sm: ({ top: 10, bottom: 7 } as MarginGenerate),
  md: ({ top: 15, bottom: 9 } as MarginGenerate),
  lg: ({ top: 15, bottom: 9 } as MarginGenerate),
  xl: ({ top: 15, bottom: 9 } as MarginGenerate)
})
/**
 * 主页流量统计卡片统计条高度
 */
export const HomeCardCellularDatabarHeight_6_5: BreakpointState<number> = BreakpointState.of({
  sm: 6, md: 5, lg: 5, xl: 5
})
/**
 * 主页流量统计卡片上下行箭头图标大小（16，22，26，27）
 */
export const HomeCardCellularDataChevronSize: BreakpointState<number> = BreakpointState.of({
  sm: 16, md: 22, lg: 26, xl: 27
})
/**
 * 主页流量统计卡片上下行箭头组件部分间距（20,10）
 */
export const HomeCardCellularDataChevronRowMargin: BreakpointState<number> = BreakpointState.of({
  sm: 10, md: 10, lg: 10, xl: 15
})
/**
 * 主页流量统计卡片内容文本字体大小（14,23,26,21）
 */
export const HomeCardCellularDataFontSize: BreakpointState<number> = BreakpointState.of({
  sm: 14, md: 16, lg: 18, xl: 18
})
/**
 * 主页卡片内容流量统计下部小字体大小（10,16,14,16）
 */
export const HomeCardCellularDataSmFontSize: BreakpointState<number> = BreakpointState.of({
  sm: 10, md: 16, lg: 14, xl: 16
})

/**
 * 主页卡片内容当前节点小字体大小（16,20,18,24）
 */
export const HomeCardPrpxySmFontSize: BreakpointState<number> = BreakpointState.of({
  sm: 16, md: 20, lg: 18, xl: 24
})
/**
 * 主页卡片标题字体大小
 */
export const CardTitleFontSize_18_20_22_22: BreakpointState<number> = BreakpointState.of({
  sm: 18, md: 20, lg: 22, xl: 22
})
/**
 * 主页卡片当前节点字体大小
 */
export const HomeProxyFontSize_24_26_26_27: BreakpointState<number> = BreakpointState.of({
  sm: 24, md: 26, lg: 26, xl: 27
})

/**
 * 主页卡片角标删除按钮大小
 */
export const DeleteButtonSize_24_32: BreakpointState<number> = BreakpointState.of({
  sm: 24, md: 32, lg: 32, xl: 32
})
/**
 * 主页卡片内容IP地址小字体大小（12,16,14,16）
 */
export const HomeCardIPSmFontSize: BreakpointState<number> = BreakpointState.of({
  sm: 12, md: 18, lg: 16, xl: 18
})
/**
 * 主页卡片内容IP地址字体大小
 */
export const IPfontSize: BreakpointState<number> = BreakpointState.of({
  sm: 18, md: 24, lg: 20, xl: 24
});
/**
* 主页添加卡片半模拟态卡片高度
  */
  export const HomeCardEditHeight: BreakpointState<number> = BreakpointState.of({
  sm: 160, md: 160, lg: 180, xl: 180
});
/**
 * 主页卡片内容网络测速字体大小
 */
export const SpeedfontSize12_14_14_16: BreakpointState<number> = BreakpointState.of({
  sm: 12,  md: 14,  lg: 14,  xl: 16
});

/* List 相关*/
// List中子组件的间隔
export const LIST_SPACE: number = 10
// ListItem的高度 56
export const LIST_ITEM_HEIGHT: number = 56
// ListItem的高度 45
export const LIST_ITEM_HEIGHT_45: number = 56
// ListItem 的 padding
export const LIST_ITEM_PADDING: Padding = { left: 12, right: 12 }

/* 配置页 */
// 自动更新间隔 乐行
// 配置自动更新的间隔`TextPicker`组件显示文本默认值，用于获取string_array.json资源异常的时候显示
export const CONFIG_AUTO_UPDATE_TIME_GAT_STRING_ARR: Array<string> = [ 'Minute', 'Hour', 'Day', ]