import { ClashConfig, Dns, DnsEnhancedMode, LogLevel, RouteMode,
  Sniff,
  TunStack } from "proxy_core";
import { CustomThemeName } from "xb_components/src/main/ets/utils/AppThemeManager";
import { AppConfig, AppState, copy } from "../../entryability/AppState";
import { BreakpointState } from "../breakpoint/breakpointsystem";
import { UpdateInfo } from "../utils/CheckUpdateUtil";
import { ConfigData, HomeCardInfo } from "./PageArgumentEntity";
import { PCTabInfo } from "./PCTabInfo";


/* 基础 */
export const APP_LINKING: string = "https://xbstudio.top/clashbox"
// 默认一分钟
export const DEFAULT_TIMEOUT: number = 60 * 1000
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
export const ANIMATION_DURATION_100: number = 100
export const ANIMATION_DURATION_500: number = 500

export const CHART_NUMBER: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

/**
 * list偏移数值：150
 */
export const CONTENT_END_OFFSET_150: number = 150

// 默认更新信息
export const DefaultUpdateInfo: UpdateInfo = {
  tag_name: '1.0.0',
  name: '1.2.3',
  published_at: '2024-01-28T15:13:58Z',
  browser_download_url: '',
  body: ''
}

// 实验功能开关列表行数据
export const TheExperimentData: AboutListItemProp = {
  title: 'Experiment',
  subtitle: '',
  name: '',
  children: [
    { title: $r('app.string.experimental_function'),
      subtitle: $r('app.string.experimental_function_Subtitle'),
      sign: 1,
      name: 'ExperimentalFunction',
      isOn: true },
  ]
}

export const NewConfigData: ConfigData = {
  configId: 'new',
  isNewConfig: false,
  configName: '',
  configUrl: '',
  disableUpdate: false,
  isConfigAutoUpdate: false,
  lastUpdateDateTime: 0,
  updateTime: 0,
}

// enum：routeName
export enum RouteName {
  IMPORT_CONFIG_FROM_URL = 'ImportConfigFromURL',
  IMPORT_CONFIG_FROM_QR_CODE = 'ImportConfigFromQRcode',
  IMPORT_CONFIG_FROM_FILE = 'ImportConfigFromFile',
  CREATE_NEW_CONFIG = 'CreateNewConfig',
}

/**
 * 主页卡片显示变量
 */
export let showHomeCard = [
  'speed',
  'mode',
  'data',
  'node',
  'ip',
  'f_node',
  'f_config',
]

export let showHomeCardPC = [
  'speed',
  'mode',
  'data',
  'node',
  'ip',
  'f_node',
  'f_config',
  'fast',
  'config',
  'node_info'
]

/**
 * 根据布尔数组过滤字符串数组
 * @param booleanJsonStr 布尔数组的JSON字符串
 * @returns 过滤后的字符串数组的JSON字符串
 */
export function filterStringsByBooleans(booleanJsonStr: string, mode: 'string' | 'array'): string | string[] {
  try {
    // 解析布尔JSON字符串
    const booleanArray: boolean[] = JSON.parse(booleanJsonStr);
    const stringArray: string[] = showHomeCardPC;

    // 检查数组长度是否一致，防止逻辑错误
    if (booleanArray.length !== stringArray.length) {
      console.error("Error: 数组长度不一致，无法进行对应过滤。");
      return JSON.stringify(showHomeCard); // 返回默认数组
    }
    // 过滤逻辑
    // 使用filter方法，遍历stringArray，回调函数接收元素和索引
    // 如果booleanArray中对应索引的值为true，则保留该元素
    const filteredArray: string[] = stringArray.filter((element: string, index: number) => {
      return booleanArray[index] === true;
    });
    if (mode === 'string') {
      // 将结果数组转换回JSON字符串
      return JSON.stringify(filteredArray);
    } else {
      return filteredArray
    }
  } catch (error) {
    console.error("处理JSON字符串时发生错误:", error);
    return JSON.stringify(showHomeCard); // 发生异常时返回默认数组
  }
}

export enum ValueType {
  Number,
  Boolean,
  String,
  StringArray,
  Record,
  Sniff
}

// 日志数据
export interface LogData {
  // 日志类型（0：Warning；1：Info）
  logType: LogLevel
  // 日志生成时间(展示的时间)
  logTime: number
  // 日志详情
  LogDetails: string
  // 是否跳转
  logSkip: boolean
}

export const NullLogData: LogData = {
  logType: LogLevel.Debug,
  logTime: 0,
  LogDetails: '',
  logSkip: false
}

// 更多配置项列表类
@Observed
export class ConfigItemData{
  icons: Resource;
  name: string;
  title: string | Resource;
  subtitle: string | Resource;
  theTips: string | Resource;
  sign: number;
  isCheck: boolean = false
  value: boolean | string[] | Record<string, string> | Record<string, Sniff>| string | number = false
  options?: OptionItem[]
  onChange: (value: boolean | string [] | Record<string, string> | string | number ) => void = ()=> {}
  valueType: ValueType = ValueType.Boolean
  constructor(
    icons: Resource,
    name: string,
    title: ResourceStr,
    subtitle: ResourceStr,
    theTips: ResourceStr,
    sign: number,
  ) {
    this.icons = icons
    this.name = name
    this.title = title
    this.subtitle = subtitle
    this.theTips = theTips
    this.sign = sign // 1 input 2 array
  }
  isEditType(){
    return this.valueType == ValueType.String || this.valueType  == ValueType.Number
  }
  initValue(){
    this.valueType = ValueType.Boolean
    const type = typeof this.value
    if(type == "string")
      this.valueType = ValueType.String
    if(type == "number")
      this.valueType = ValueType.Number
    if(type == "object")
      this.valueType = ValueType.Record
    if(Array.isArray(this.value))
      this.valueType = ValueType.StringArray

    if(this.valueType == ValueType.Boolean){
      this.isCheck = this.value as boolean
    }
  }
  theSubtitle(): string | Resource{
    if(this.isEditType() && this.theTips === ''){
      return this.value !== '' ? (this.value  + "") as string : this.subtitle
    } else {
      return this.subtitle
    }
  }
  tips(): string | Resource{
    if (this.options){
      return this.options.find((d) => d.value == this.value)?.title ?? (this.value as string) ?? this.theTips
    }
    if(this.isEditType() && this.theTips !== ''){
      return (this.value  + "") as string
    } else {
      return this.theTips
    }
  }
  bindOption(options: OptionItem[]){
    this.options = options
    return this
  }
  bindType(type: ValueType){
    this.valueType = type
    return this
  }
  bind<T>(
    value: boolean | string[] | Record<string, string> | string | number,
    onUpdate:(value: T ) => void
  ){
    this.value = value
    this.onChange = (v: boolean | string [] | Record<string, string> | string | number )=>{
      this.value = v
      onUpdate(v as T)
    }
    this.initValue()
    return this
  }
  default<T>(value: T){
    if (!this.value){
      this.value == value
    }

    this.initValue()
    return this
  }
  bindClashConfig(config: ClashConfig){
    this.value = config[this.name]
    this.onChange = (value: boolean | string [] | Record<string, string> | string | number )=>{
      config[this.name] = value
    }
    this.initValue()
    return this
  }
  bindClashConfigBy(
    config: ClashConfig,
    key: string | undefined = undefined,
  ){
    if (key){
      let obj = config[key] as object
      this.value = obj[this.name]
      this.onChange = (value: boolean | string [] | Record<string, string> | string | number )=>{
        obj[this.name] = value
        config[key] = copy(obj)
      }
    } else {
      this.value = config[this.name]
      this.onChange = (value: boolean | string [] | Record<string, string> | string | number )=>{
        config[this.name] = value
      }
    }
    this.initValue()
    return this
  }
  bindDnsConfig(
    config: ClashConfig,
    dns: Dns,
    key: string
  ){
    if(!dns[key])
      dns[key] = {}
    this.value = dns[key][this.name]
    this.onChange = (value: boolean | string [] | Record<string, string> | string | number )=>{
      dns[key][this.name] = value
      config.dns = copy(dns)
    }
    this.initValue()
    return this
  }
}


// 更多列表类
export class moreData {
  icons: Resource;
  name: string;
  title: string | Resource;
  subtitle: string | Resource;
  sign: number;
  isCheck: boolean
  value: boolean | string[] | Record<string, string> | string
  onChange: (value: boolean | string [] | Record<string, string> | string | undefined) => void
  constructor(
    icons: Resource,
    name: string,
    title: ResourceStr,
    subtitle: ResourceStr,
    sign: number,
    value: boolean | string [] | Record<string, string> | string = false,
    onChange: (name: string, value: boolean | string [] | Record<string, string> | string) => void =
    (name: string, value: boolean | string [] | Record<string, string> | string) => {}
  ) {
    this.icons = icons
    this.name = name
    this.title = title
    this.subtitle = subtitle
    this.sign = sign // 1 input 2 array
    this.onChange = ()=>{
      onChange(this.name, value)
    }
    if(typeof value == "boolean"){
      this.isCheck = value as boolean
    }else {
      this.isCheck = false
    }
    this.value = value
  }
}

// 更多 -> MoreListItem
export const ListMoreData = (): moreData[] => {
  let result: moreData[] = new Array()
  result = [
    new moreData($r('sys.symbol.doc_text_fill'), 'log', $r('app.string.Log'), '', 0, false),
    new moreData($r('sys.symbol.externaldrive_fill_3'), 'resources', $r('app.string.Resources'), '', 0, false),
    new moreData($r('sys.symbol.list_bullet'), 'request', $r('app.string.Request'), '', 0, false),
    new moreData($r('sys.symbol.swap'), 'connect', $r('app.string.Connect'), '', 0, false),
    new moreData($r('sys.symbol.pencil_line'), 'overwrite', $r('app.string.Overwrite'), '', 0, false),
    new moreData($r('sys.symbol.bolt_filled_on_circle'), 'access_control', $r('app.string.access_control'), '', 0, false),
    // new moreData($r('sys.symbol.navigation'), 'diversion', $r('app.string.Diversion_Strategy'), '', 5, false),
    new moreData($r('sys.symbol.clean_fill'), 'QueryIP', $r('app.string.query_ip_region'), $r('app.string.query_ip_region_Subtitle'), 0, false),
  ]
  return result
}

// 更多 -> 覆写OverwriteListItem
export const ListOverwriteData = (): moreData[] => {
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
export const ListOverwriteBasicData = (clashConfig: ClashConfig, appConfig: AppConfig): ConfigItemData[] => {
  let result: ConfigItemData[] = new Array()
  result = [
    new ConfigItemData($r('sys.symbol.info_circle'), 'log-level', $r('app.string.LogLevel'), '', $r('app.string.Info'), 0).bindClashConfig(clashConfig).bindOption(LogMenu),
    new ConfigItemData($r('sys.symbol.person_shield_fill'), 'global-ua', $r('app.string.UA'), '', $r('app.string.Default_UA'), 0).bindClashConfig(clashConfig).bindOption([
      {title: AppState.globalUA, value: AppState.globalUA },
      {title: 'ClashBox/v2.0.0', value:"ClashBox/v2.0.0"},
      {title: 'clash.meta/1.19.5', value:"clash.meta/1.19.5"},
      {title: 'clash-verge/v2.4.1', value:"clash-verge/v2.4.1"},
      {title: 'ClashforWindows/0.19.23', value:"ClashforWindows/0.19.23"},
    ]),
    new ConfigItemData($r('sys.symbol.stopwatch_2'), 'keep-alive-interval', $r('app.string.TCP_Active'), '', $r('app.string.TCP_interval'), 1).bindClashConfig(clashConfig).bindType(ValueType.Number),
    new ConfigItemData($r('sys.symbol.bolt_filled_on_circle'), "testUrl", $r('app.string.Test_Latency_Link'), 'https://www.gstatic.com/generate204', '', 1).bind<string>(appConfig.testUrl,(v)=>{ appConfig.testUrl = v}).bindType(ValueType.String),
    new ConfigItemData($r('sys.symbol.worldclock_badge_checkmark'),"allow-lan", $r('app.string.lan'), $r('app.string.lan_subtitle'), '', 2).bindClashConfig(clashConfig),
    new ConfigItemData($r('sys.symbol.record_circle'), 'mixed-port', $r('app.string.Proxy_Port'), '', '7890', 1).bindClashConfig(clashConfig).bindType(ValueType.Number),
    new ConfigItemData($r('sys.symbol.list_bullet_square_fill'), 'hosts', 'Hosts', '', '', 1).bindClashConfig(clashConfig).bindType(ValueType.Record),
    new ConfigItemData($r('sys.symbol.paperplane'), 'only-proxy', $r('app.string.only_proxy'), $r('app.string.only_proxy_subtitle'), '', 2).bindClashConfig(clashConfig),
    new ConfigItemData($r('sys.symbol.mobiledata'), 'ipv6', 'IPv6', '', '', 2).bindClashConfig(clashConfig),
    new ConfigItemData($r('sys.symbol.line_arrowtriangle_2_inward'), 'unified-delay', $r('app.string.UnifiedLatency'), $r('app.string.Unified_Latency_Subtitle'), '', 2).bindClashConfig(clashConfig),
    new ConfigItemData($r('sys.symbol.order_play'), 'tcp-concurrent', $r('app.string.TCP_Concurrency'), '', '',  2, ).bindClashConfig(clashConfig),
    new ConfigItemData($r('sys.symbol.selector'), 'external-controller', $r('app.string.External_Control'), $r('app.string.External_Control_Subtitle'), '',  2).bind<boolean>(clashConfig["external-controller"] != "", (result)=>{
      if(result){
        clashConfig["external-controller"] = AppState.externalController
      }else{
        clashConfig["external-controller"] = ""
      }

    }),
  ]
  return result
}

// 更多 -> 覆写 -> DNSListitem
export const ListOverwriteDNSData = (clashConfig: ClashConfig, appConfig: AppConfig): ConfigItemData[] => {
  let result: ConfigItemData[] = new Array()
  let dns = clashConfig.dns ?? new Dns()
  result = [
    new ConfigItemData($r('sys.symbol.selector'), 'overrideDns', $r('app.string.OverwriteDNS'), $r('app.string.overwrite_dns_subtitle'), '', 2).bind<boolean>(clashConfig.overrideDns, (v)=>{
      clashConfig.overrideDns = v
      if (v) { dns.enable = true }
    }),
    new ConfigItemData($r('sys.symbol.selector'), 'Option', $r('app.string.option'), '', '', 3),
    new ConfigItemData($r('sys.symbol.selector'), 'enable', $r('app.string.State'), $r('app.string.State_subtitle'), '', 2).bindClashConfigBy(clashConfig, "dns"),
    new ConfigItemData($r('sys.symbol.selector'), 'use-hosts', $r('app.string.UseHosts'), '', '', 2).bindClashConfigBy(clashConfig,"dns"),
    new ConfigItemData($r('sys.symbol.selector'), 'use-system-hosts', $r('app.string.Use_System_Hosts'), '', '', 2).bindClashConfigBy(clashConfig, "dns"),
    new ConfigItemData($r('sys.symbol.selector'), 'ipv6', 'IPv6', '', '', 2).bindClashConfigBy(clashConfig, "dns"),
    new ConfigItemData($r('sys.symbol.selector'), 'respect-rules', $r('app.string.Follow_The_Rules'), $r('app.string.Follow_The_Rules_Subtitle'), '', 2).bindClashConfigBy(clashConfig, "dns"),
    new ConfigItemData($r('sys.symbol.selector'), 'prefer-h3"', $r('app.string.Priority_Use_H3'), $r('app.string.Priority_Use_H3_Subtitle'), '', 2,).bindClashConfigBy(clashConfig, "dns"),
    new ConfigItemData($r('sys.symbol.selector'), 'enhanced-mode', $r('app.string.DNS_Mode'), '', dns?.["enhanced-mode"] ?? $r('app.string.DNS_Mode_Subtitle'), 0).bindClashConfigBy(clashConfig, "dns").bindOption(DNSMenu),
    new ConfigItemData($r('sys.symbol.selector'), 'fake-ip-range', $r('app.string.FakeIP_Range'), '', $r('app.string.FakeIP_Range_Subtitle_1'), 1).bindClashConfigBy(clashConfig, "dns").bindType(ValueType.String),
    new ConfigItemData($r('sys.symbol.selector'), 'fake-ip-filter', $r('app.string.FakeIP_Filtering'), '', '', 1,).bindClashConfigBy(clashConfig, "dns"),
    new ConfigItemData($r('sys.symbol.selector'), 'default-nameserver', $r('app.string.Default_Domain_Name_Server'), $r('app.string.Default_Domain_Name_Server_Subtitle'), '', 1).bindClashConfigBy(clashConfig, "dns").bindType(ValueType.StringArray),
    new ConfigItemData($r('sys.symbol.selector'), 'nameserver-policy', $r('app.string.Domain_Name_Server_Strategy'), $r('app.string.Domain_Name_Server_Strategy_Subtitle'), '', 1,).bindClashConfigBy(clashConfig, "dns").bindType(ValueType.Record),
    new ConfigItemData($r('sys.symbol.selector'), 'nameserver', $r('app.string.Domain_Name_Server'), $r('app.string.Domain_Name_Server_Subtitle'), '', 1,).bindClashConfigBy(clashConfig, "dns"),
    new ConfigItemData($r('sys.symbol.selector'), 'fallback', $r('app.string.FallBack'), $r('app.string.FallBack_Subtitle'), '', 1,).bindClashConfigBy(clashConfig, "dns"),
    new ConfigItemData($r('sys.symbol.selector'), 'proxy-server-nameserver', $r('app.string.Proxy_Domain_Name_Server'), $r('app.string.Proxy_Domain_Name_Server_Subtitle'), '', 1,).bindClashConfigBy(clashConfig, "dns"),
    new ConfigItemData($r('sys.symbol.selector'), 'FallBack-Filtering', $r('app.string.FallBack_Filtering'), '', '', 3, ),
    new ConfigItemData($r('sys.symbol.selector'), 'geoip', $r('app.string.GeoIP'), '', '',  2, ).bindDnsConfig(clashConfig, dns, "fallback-filter"),
    new ConfigItemData($r('sys.symbol.selector'), 'geoip-code', $r('app.string.GeoIP_Code'), '', $r('app.string.GeoIP_Code_Subtitle_1'), 1,).bindDnsConfig(clashConfig, dns, "fallback-filter").bindType(ValueType.String),
    new ConfigItemData($r('sys.symbol.selector'), 'geosite', 'Geosite', '', '', 1).bindDnsConfig(clashConfig, dns, "fallback-filter"),
    new ConfigItemData($r('sys.symbol.selector'), 'ipcidr', $r('app.string.IP_Mask'), '', '', 1).bindDnsConfig(clashConfig, dns, "fallback-filter"),
    new ConfigItemData($r('sys.symbol.selector'), 'domain', $r('app.string.Domain_Name'), '', '', 1,).bindDnsConfig(clashConfig, dns, "fallback-filter"),
  ]
  return result
}

// 更多 -> 覆写 -> 网络Listitem
export const ListOverwriteNetworkData = (clashConfig: ClashConfig, appConfig: AppConfig): ConfigItemData[] => {
  let result: ConfigItemData[] = new Array()
  result = [
    // new ConfigItemData($r('sys.symbol.key_shield_fill'), 'VPN', 'VPN', '', '', 2),
    new ConfigItemData($r('sys.symbol.selector'), 'Option', $r('app.string.option'), '', '', 3),
    new ConfigItemData($r('sys.symbol.selector'), 'ipv6', 'IPv6', $r('app.string.Info'), '', 2).bindClashConfig(clashConfig),
    new ConfigItemData($r('sys.symbol.satellite_map_fill'), 'stack', $r('app.string.stack_mode'), '', 'gvisor', 0).bindClashConfigBy(clashConfig, "tun").bindOption(StackMenu),
    new ConfigItemData($r('sys.symbol.slider_horizontal_2'), 'route-mode', $r('app.string.route_mode'), '', $r('app.string.using_configuration'), 0)
      .bindClashConfig(clashConfig).bindOption(RouteMenu),
    new ConfigItemData($r('sys.symbol.fast'), 'tun-ip', $r('app.string.tun_ip'), '', '172.19.0.1/30', 1).bindClashConfigBy(clashConfig, "tun").bindType(ValueType.String),
    new ConfigItemData($r('sys.symbol.local_fill'), 'route-address', $r('app.string.Routing_Address'), $r('app.string.Routing_Address_Subtitle'), '', 1).bindClashConfig(clashConfig),
    new ConfigItemData($r('sys.symbol.network_acceleration'), 'compatible', $r('app.string.compatibility_mode'), $r('app.string.compatibility_mode_subtitle'), '', 1),
  ]
  return result
}

// 更多 -> 覆写 -> 网络 -> 兼容模式
export const OverwriteNetworkCompatible = (clashConfig: ClashConfig, appConfig: AppConfig): ConfigItemData[] => {
  let result: ConfigItemData[] = new Array()
  clashConfig.sniffer = clashConfig.sniffer ?? clashConfig.snifferDefault
  result = [
    new ConfigItemData($r('sys.symbol.network_acceleration'), 'enable', $r('app.string.compatibility_mode'), $r('app.string.compatibility_mode_subtitle'), '', 2).bindClashConfigBy(clashConfig, "sniffer").bindType(ValueType.Boolean),
    new ConfigItemData($r('sys.symbol.selector'), 'Option', 'Sniffer Setting', '', '', 3),
    new ConfigItemData($r('sys.symbol.save'), 'force-dns-mapping', 'Force DNS Mapping', '', $r('app.string.not_modify'), 2).bindClashConfigBy(clashConfig, "sniffer"),
    new ConfigItemData($r('sys.symbol.save'), 'parse-pure-ip', 'Parse Pure Ip', '', $r('app.string.not_modify'), 2).bindClashConfigBy(clashConfig, "sniffer"),
    new ConfigItemData($r('sys.symbol.save'), 'override-destination', 'Override Destination', '', $r('app.string.not_modify'), 2).bindClashConfigBy(clashConfig, "sniffer"),
    new ConfigItemData($r('sys.symbol.save'), 'force-domain', 'Force Domain', '', '', 1).bindClashConfigBy(clashConfig, "sniffer").bindType(ValueType.StringArray),
    new ConfigItemData($r('sys.symbol.save'), 'skip-domain', 'Skip Domain', '', '', 1).bindClashConfigBy(clashConfig, "sniffer").bindType(ValueType.StringArray),
    new ConfigItemData($r('sys.symbol.save'), 'port-whitelist', 'Port Whitelist', '', '', 1).bindClashConfigBy(clashConfig, "sniffer"),
    new ConfigItemData($r('sys.symbol.save'), 'sniff', 'Sniff', '', '', 1).bindClashConfigBy(clashConfig, "sniffer").bindType(ValueType.Sniff),
  ]
  return result
}

/**
 * 菜单
 */
export interface MenuListItemProp {
  title: string | Resource
  children?: Array<MenuListItemProp>
}
export interface OptionItem{
  title: string | Resource
  value: string | number | boolean
}

/**
 * 更多 -> 覆写 -> 基础 -> 菜单
 */
export const LogMenu :OptionItem[] = [
  {title: 'Debug', value: LogLevel.Debug},
  {title: 'Info', value: LogLevel.Info},
  {title: 'Warning', value: LogLevel.Warning},
  {title: 'Error', value: LogLevel.Error},
  {title: 'Silent', value: LogLevel.Silent},
]
export const UAMenu: OptionItem[] = [

]

/**
 * 更多 -> 覆写 -> 网络 -> 栈模式菜单
 */
export const StackMenu: OptionItem[] = [
  {title: 'Gvisor', value: TunStack.Gvisor},
  {title: 'System', value: TunStack.System},
  {title: 'Mixed',  value: TunStack.Mixed},
]

/**
 * 更多 -> 覆写 -> 网络 -> 路由模式菜单
 */
export const RouteMenu: OptionItem[] = [
  {title: $r('app.string.bypass_private_route_address'),value: RouteMode.BypassPrivate},
  {title: $r('app.string.using_configuration'), value: RouteMode.Config},
]

/**
 * 更多 -> 覆写 -> 网络 -> 兼容模式切换菜单
 */
export const SwitchMenu: OptionItem[] = [
  {title: $r('app.string.not_modify'),value: -1},
  {title: $r('app.string.enabled'),value: true},
  {title: $r('app.string.disabled'), value: false},
]

/**
 * 更多 -> 覆写 -> DNS -> 菜单
 */
export const DNSMenu: OptionItem[] = [
  {title: 'Normal', value:DnsEnhancedMode.None},
  {title: 'FakeIp', value:DnsEnhancedMode.FakeIp},
  {title: 'RedirHost', value:DnsEnhancedMode.Mapping},
]

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

  constructor( icons: Resource, name: string, title: ResourceStr, subtitle: ResourceStr, hint: ResourceStr, isCheck: boolean) {
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
    new settingsData($r('sys.symbol.externaldrive_fill'), 'Backup', $r('app.string.Backup_Recovery'), $r('app.string.backup_restore_subtitle'), '', false),
    new settingsData($r('sys.symbol.ellipsis_message_fill'), 'Notice', $r('app.string.Notice'), $r('app.string.subtitle'), '', false),
    new settingsData($r('sys.symbol.checkmark_square_on_square_fill'), 'Backgrounder', $r('app.string.Backgrounder'), $r('app.string.BackgrounderSubtitle'), '', false),
    new settingsData($r('sys.symbol.satellite_map_fill'), 'Kernel', $r('app.string.kernel'), $r('app.string.kernel_subtitle'), '', false),
    new settingsData($r('sys.symbol.trash_fill'), 'WipeData', $r('app.string.WipeData'), $r('app.string.WipeDataSubtitle'), '', false),
    new settingsData($r('sys.symbol.person_shield_fill'), 'agreement-privacy', $r('app.string.agreement_privacy'), '', '', false),
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
    new LanguageData($r('app.string.TraditionalChinese_HK'), $r('app.string.TraditionalChinese_HK_Subtitle'), 'zh-HK', false),
    new LanguageData($r('app.string.TraditionalChinese_TW'), $r('app.string.TraditionalChinese_TW_Subtitle'), 'zh-TW', false),
    new LanguageData($r('app.string.English'), $r('app.string.English_Subtitle'), 'en-Latn', false),
    // 更对语言...
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
  // 颜色模式
  colorMode?: ThemeColorMode
  // `start`方向上`Symbol`的颜色数组
  startSymbolFontColor?: Array<ResourceColor>
  children?: Array<AppearanceListItemProp>
}

/**
 * 外观页菜单列表
 */
export function getAppearance(windowMode: boolean): AppearanceListItemProp[] {
  const AppearanceList: AppearanceListItemProp[] = [
    { title: $r('app.string.dark_mode'),
      children: [
        { title: $r('app.string.follow_system'), colorMode: ThemeColorMode.SYSTEM },
        { title: $r('app.string.always_light'), colorMode: ThemeColorMode.LIGHT },
        { title: $r('app.string.always_dark'), colorMode: ThemeColorMode.DARK },
      ]
    },
    { title: $r('app.string.theme_color'),
      children: [
        { title: $r('app.string.star_river_blue'), customThemeName: 'blueAppTheme', startSymbolFontColor: [$r('sys.color.icon_emphasize')] },
        { title: $r('app.string.yellow'), customThemeName: 'yellowAppTheme', startSymbolFontColor: [$r('app.color.theme_color_main_yellow')] },
        { title: $r('app.string.cat_blue'), customThemeName: 'catBlueAppTheme', startSymbolFontColor: [$r('app.color.theme_color_main_cat_blue')] },
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
    },
    { title: $r('app.string.animation_speed'),
      children: [
        { title: $r('app.string.fast') },
        { title: $r('app.string.normal') },
        { title: $r('app.string.low') },
        { title: $r('app.string.close') }
      ]
    },
    { title: $r('app.string.tab_style'),
      children: [
        { title: $r('app.string.float') },
        { title: $r('app.string.custom') },
      ]
    },
    { title: $r('app.string.string_display_preferences'),
      children: [
        { title: $r('app.string.Appearance') },
        { title: $r('app.string.information') },
      ]
    },
    { title: $r('app.string.exit_window'),
      children: [
        { title: $r('app.string.minimize_tray') },
        { title: $r('app.string.exit') },
      ]
    }
  ]
  if (windowMode) {
    const tab = AppearanceList[4]
    tab.children?.unshift({ title: '窗口' })
  }
  return AppearanceList
}

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
export function getAboutList(): AboutListItemProp[] {
  return [
    {
      title: 'Version',
      subtitle: '',
      name: '',
      children: [
        { title: $r('app.string.Application_Version'), subtitle: `${AppState.versionName}(${AppState.versionCode}) ${AppState.appProvisionType}`, sign: 0, name: 'ApplicationVersion' },
        { title: $r('app.string.Kernel_Version'), subtitle: `${AppState.coreVersion}`, sign: 0, name: 'KernelVersion' }
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
      title: 'collaborators',
      subtitle: '',
      name: '',
      children: [
        { title: $r('app.string.xb_studio'), subtitle: '', sign: 2, name: 'xb' },
        { title: $r('app.string.collaborators'), subtitle: '', sign: 2, name: 'collaborators' },
        { title: $r('app.string.third_party_services'), subtitle: '', sign: 2, name: 'Three' },
      ]
    },
    {
      title: 'General',
      subtitle: '',
      name: '',
      children: [
        { title: $r('app.string.UseGuidance'), subtitle: '', sign: 2, name: 'UseGuidance' },
        { title: $r('app.string.FAQ'), subtitle: '', sign: 2, name: 'FAQ' },
        { title: $r('app.string.update_log'), subtitle: '', sign: 2, name: 'UpdateLog' },
      ]
    },
    // { title: 'Update',
    //   subtitle: '',
    //   name: '',
    //   children: [
    //     { title: $r('app.string.Check_Updates'), subtitle: '', sign: 2, name: 'CheckUpdate' },
    //     { title: $r('app.string.UpdateChannels'), subtitle: $r('app.string.UpdateChannels_Subtitle1'), sign: 3, name: 'UpdateChannels',
    //       children: [
    //         { title: $r('app.string.UpdateChannels_Subtitle1'), name: 'Github', subtitle: '' },
    //         // { title: 'Gitee', name: 'Gitee', subtitle: '' }
    //       ]
    //     },
    //     { title: $r('app.string.Auto_Check_Updates'), subtitle: '', sign: 1, name: 'Auto', isOn: false },
    //   ]
    // },
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
}
/**
 * 协作者名单参数
 */
export interface CollaboratorsListItemProp {
  image?: Resource
  title: string | Resource
  subtitle?: string | Resource
  contact?: string | Resource
  contact2?: string
  sign: number
  link: string
}
/**
 * 协作者名单列表
 */
export const CollaboratorsList: CollaboratorsListItemProp[] = [
  { title: 'mihomo', subtitle: $r('app.string.mihomo_subtitle'), contact: 'Github', sign: 0, link: 'https://github.com/MetaCubeX/mihomo', image: $rawfile('mihomo.png')},
  { title: 'FlClash', subtitle: $r('app.string.flclash_subtitle'), contact: 'Github', sign: 0, link: 'https://github.com/chen08209/FlClash', image: $rawfile('FlClash.svg')},
  { title: '恩临大帝', subtitle: $r('app.string.FrondEnd_Development'), contact: $r('app.string.Email'), sign: 1, link: 'mailto:ealion@outlook.com?subject=联系&body=你的内容...', image: $rawfile('enlin.png')},
  { title: 'SummerKaze', subtitle: $r('app.string.FrondEnd_Development'), contact: 'Github', sign: 0, link: 'https://github.com/SummerKaze', image: $rawfile('SummerKaze.jpg')},
  { title: '凛凛早露', subtitle: $r('app.string.LLZL_Subtitle'), sign: 3, link: '', image: $rawfile('llzl.png')},
  { title: $r('app.string.Dear_Group_Members'), subtitle: $r('app.string.Dear_Group_Members_Subtitle'), sign: 2, link: '693903194', contact: $r('app.string.copy_qq_group'), image: $rawfile('group.jpg')},
]

/**
 * 标题&内容
 */
export interface TCItemProp {
  title: ResourceStr
  content: ResourceStr
}

/**
 * 三方库与服务
 */
export const ThirdServicesList: TCItemProp[] = [
  { title: 'mcCharts(莓创图表)', content: 'http://meichuangit.net.cn/GettingStarted' },
  { title: 'webdav', content: 'https://ohpm.openharmony.cn/#/cn/detail/@ya520%2Fwebdav' },
  { title: 'CodeMirror', content: 'https://codemirror.net/' },
  { title: '应用检索服务', content: 'https://next.vcck.cn/' },
  { title: 'VORE-API', content: 'https://api.vore.top/doc/IPdata.html' },
  { title: 'IP-API', content: 'https://ip-api.com/' },
  { title: 'IPWHOIS.IO', content: 'https://ipwhois.io/' },
  { title: 'IPinfo', content: 'https://ipinfo.io/' },
  { title: 'ifconfig.me', content: 'https://ifconfig.me/' },
]

/**
 * 使用引导
 */
export const UseGuidanceList: TCItemProp[] = [
  {title: $r('app.string.home_start_button'), content: $rawfile('start_pop.png')},
  {title: $r('app.string.config_list_items'), content: $rawfile('config_guidance.png')},
  {title: $r('app.string.proxy_node_list_item'), content: $rawfile('proxy_node_pop.png')},
  {title: $r('app.string.delay_test_button'), content: $rawfile('proxy_delay_pop.png')},
]

/**
 * 常见问题
 */
export const FAQList: TCItemProp[] = [
  {title: $r('app.string.game_q'), content: $r('app.string.game_a')},
  {title: $r('app.string.link_q'), content: $r('app.string.link_a')},
  {title: $r('app.string.function_q'), content: $r('app.string.function_a')},
  {title: $r('app.string.node_q'), content: $r('app.string.node_a')},
  {title: $r('app.string.node_q2'), content: $r('app.string.node_a2')},
  //{title: $r('app.string.proxy_q'), content: $r('app.string.proxy_a')},
  {title: $r('app.string.config_q'), content: $r('app.string.config_a')},
]

/**
 * 常见问题 -> 转换链接
 */
export const LinkList: TCItemProp[] = [
  {title: `https://sub.xeton.dev`, content: `https://sub.xeton.dev`},
  {title: 'https://acl4ssr-sub.github.io', content: 'https://acl4ssr-sub.github.io'},
  {title: 'https://sub.2c.lol', content: 'https://sub.2c.lol'},
]

/**
 * 检查更新页列表参数
 */
export interface CheckUpdateListItemProp {
  icons?: Resource
  url?: string
  title: string | Resource
  subtitle: string | Resource
  children?: Array<CheckUpdateListItemProp>
}
/**
 * 检查更新页列表
 */
export function getCheckUpdateList(updateInfo: UpdateInfo): CheckUpdateListItemProp[] {
  return [
    {
      title: 'Version',
      subtitle: '',
      children: [
        { title: $r('app.string.current_version'), subtitle: `${AppState.versionName} Release` },
        { title: $r('app.string.latest_version'), subtitle: `${updateInfo.tag_name} Release` }
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
      title: 'Url',
      subtitle: '',
      children: [
        { icons: $r('sys.symbol.download_fill'), title: $r('app.string.download_url'), subtitle: updateInfo.browser_download_url },
      ]
    },
    // {
    //   title: 'Ignore',
    //   subtitle: '',
    //   children: [
    //     { icons: $r('sys.symbol.hand_raised_hexagon'), title: $r('app.string.ignore_update'), subtitle: '' },
    //   ]
    // }
  ]
}


/**
 * 主页卡片编辑半模态里列表
 */
export interface HomeCardItem {
  key: string
  image:Resource
  aspectRatio:number
  isShow:boolean
  width:ResourceStr
}

export const HomeCardList: HomeCardItem[] = [
  {key: 'speed', image: $r('app.media.Speed'), aspectRatio: 2.07, isShow: true, width: '100%' },
  {key: 'mode', image:$r('app.media.SwitchMode'),aspectRatio:1,isShow:true,width:'48.5%'},
  {key: 'data', image:$r('app.media.CellularData'),aspectRatio:1,isShow:true,width:'48.5%'},
  {key: 'node', image:$r('app.media.CurrentNode'),aspectRatio:1,isShow:true,width:'48.5%'},
  {key: 'ip', image:$r('app.media.PublicNetwork'),aspectRatio:1,isShow:true,width:'48.5%'},
  {key: 'f_node', image:$r('app.media.FavoriteProxy'),aspectRatio:1,isShow:true,width:'48.5%'},
  {key: 'f_config', image:$r('app.media.FavoriteConfiguration'),aspectRatio:1,isShow:true,width:'48.5%'},
  {key: 'config', image:$r('app.media.CurrentConfiguration'),aspectRatio:1,isShow:true,width:'48.5%'},
  {key: 'fast', image:$r('app.media.Shortcuts'),aspectRatio:1,isShow:true,width:'48.5%'},
  {key: 'node_info', image:$r('app.media.ProxyINFO'),aspectRatio:2.07,isShow:true,width:'100%'},
]

export const HomeCards: HomeCardInfo[] = [
  { // 网络速度小卡片
    aspectRatio: 2.07,
    spanMultiple: 2,
    key: 'speed',
    name: $r('app.string.Speed'),
    isShow: true,
    order: 1
  },
  { // 分流模式小卡片
    aspectRatio: 1,
    spanMultiple: 1,
    key: 'mode',
    name: $r('app.string.Mode'),
    isShow: true,
    order: 2
  },
  { // 流量统计小卡片
    aspectRatio: 1,
    spanMultiple: 1,
    isShow: true,
    key: 'data',
    name: $r('app.string.CellularData'),
    order: 3
  },
  { // 当前节点小卡片
    aspectRatio: 1,
    spanMultiple: 1,
    isShow: true,
    key: 'node',
    name: $r('app.string.CurrentNode'),
    order: 4
  },
  { // IP地址小卡片
    aspectRatio: 1,
    spanMultiple: 1,
    isShow: true,
    key: 'ip',
    name: $r('app.string.PublicNetwork'),
    order: 5
  },
  { // 收藏节点小卡片
    aspectRatio: 1,
    spanMultiple: 1,
    isShow: true,
    key: 'f_node',
    name: $r('app.string.FavoriteProxy'),
    order: 6
  },
  { // 收藏配置小卡片
    aspectRatio: 1,
    spanMultiple: 1,
    key: 'f_config',
    isShow: true,
    name: $r('app.string.FavoriteConfiguration'),
    order: 7
  },
  { // 快捷方式小卡片
    aspectRatio: 1,
    spanMultiple: 1,
    isShow: false,
    key: 'fast',
    name: $r('app.string.shortcuts'),
    order: 8
  },
  { // 当前配置小卡片
    aspectRatio: 1,
    spanMultiple: 1,
    isShow: false,
    key: 'config',
    name: $r('app.string.CurrentConfiguration'),
    order: 9
  },
  { // 节点信息小卡片
    order: 10,
    isShow: false,
    key: 'node_info',
    name: $r('app.string.proxy_info'),
    spanMultiple: 2,
    aspectRatio: 2.07,
  }
]

export const NullHomeCard1_1: HomeCardInfo = {
  key: "null",
  name: "null",
  order: 0,
  isShow: false,
  spanMultiple: 1,
  aspectRatio: 1
}

export const NullHomeCard2_1: HomeCardInfo = {
  key: "null",
  name: "null",
  order: 0,
  isShow: false,
  spanMultiple: 2,
  aspectRatio: 2.07
}

export const PCTabList: PCTabInfo[] = [
  {
    group: 'main',
    groupName: '',
    items: [
      { name: 'home', title: $r('app.string.Home'), icon: $r('sys.symbol.house_fill') },
      { name: 'node', title: $r('app.string.Proxy'), icon: $r('sys.symbol.list_bullet_square_fill') },
      { name: 'config', title: $r('app.string.Configuration'), icon: $r('sys.symbol.folder_fill') }
    ]
  },
  {
    group: 'info',
    groupName: $r('app.string.information'),
    items: [
      { name: 'log', title: $r('app.string.Log'), icon: $r('sys.symbol.doc_text_fill') },
      { name: 'request', title: $r('app.string.Request'), icon: $r('sys.symbol.mobiledata_circle_fill') },
      { name: 'connect', title: $r('app.string.Connect'), icon: $r('sys.symbol.transformation_fill') },
      { name: 'resources', title: $r('app.string.Resources'), icon: $r('sys.symbol.externaldrive_fill_3') }
    ]
  },
  {
    group: 'control',
    groupName: '高级',
    items: [
      { name: 'overwrite', title: $r('app.string.Overwrite'), icon: $r('sys.symbol.square_and_pencil_fill') },
      { name: 'access_control', title: $r('app.string.access_control'), icon: $r('sys.symbol.bookmark_filled_on_bookmark') },
      { name: 'settings', title: $r('app.string.Settings'), icon: $r('sys.symbol.gearshape_fill') }
    ]
  }
]

/* List 相关*/
// List中子组件的间隔
export const LIST_SPACE: number = 10
// ListItem的高度 56
export const LIST_ITEM_HEIGHT: number = 56
// ListItem的高度 45
export const LIST_ITEM_HEIGHT_45: number = 45
// ListItem 的 padding
export const LIST_ITEM_PADDING: Padding = { left: 12, right: 12 }

/* 配置页 */
// 自动更新间隔 乐行
// 配置自动更新的间隔`TextPicker`组件显示文本默认值，用于获取string_array.json资源异常的时候显示
export const CONFIG_AUTO_UPDATE_TIME_GAT_STRING_ARR: Array<string> = [ 'Minute', 'Hour', 'Day', ]

/**
 * @description 时间单位到毫秒的转换映射
 * 根据 CONFIG_AUTO_UPDATE_TIME_GAT_STRING_ARR 的索引返回对应的毫秒倍数
 */
export const CONFIG_AUTO_UPDATE_TIME_GAP_TO_MS_MAP: Map<number, number> = new Map([
  [0, 60 * 1000],        // Minute: 60秒 * 1000毫秒 = 60000毫秒
  [1, 60 * 60 * 1000],   // Hour: 60分钟 * 60秒 * 1000毫秒 = 3600000毫秒
  [2, 24 * 60 * 60 * 1000] // Day: 24小时 * 60分钟 * 60秒 * 1000毫秒 = 86400000毫秒
])

/**
 * @description 将时间间隔值转换为毫秒
 * @param value 时间间隔数值（如：10）
 * @param unitIndex 时间单位索引（0=Minute, 1=Hour, 2=Day），对应 CONFIG_AUTO_UPDATE_TIME_GAT_STRING_ARR
 * @returns 转换后的毫秒数，如果索引无效则返回 value * 60000（默认按分钟计算）
 */
export function convertTimeGapToMilliseconds(value: number, unitIndex?: number): number {
  if (unitIndex === undefined || unitIndex === null) {
    // 默认按分钟计算
    return value * DEFAULT_TIMEOUT
  }
  
  const multiplier = CONFIG_AUTO_UPDATE_TIME_GAP_TO_MS_MAP.get(unitIndex)
  if (multiplier === undefined) {
    // 索引无效，默认按分钟计算
    return value * DEFAULT_TIMEOUT
  }
  
  return value * multiplier
}

export interface ITimeGap {
  value: number
  unit: number
}

/**
 * @description 将毫秒转换为时间间隔
 * @param value 毫秒数
 * @returns ITimeGap 包含时间间隔和单位信息的对象
 */
export function convertMillisecondsToTimeGap(value: number): ITimeGap {
  let timeGap: ITimeGap = {
    value: 0,
    unit: 0
  }

  CONFIG_AUTO_UPDATE_TIME_GAP_TO_MS_MAP.forEach((multiplier, index) => {
    if (value % multiplier === 0) {
      timeGap = {
        value: value / multiplier,
        unit: index
      }
    }
  })

  return timeGap
}

/** @description 包名信息 */
export class BundleInfo {
  /** @description 包名 */
  bundleName?: string
  /** @description 应用名 */
  appName?: string
  /** @description 应用缩略图 */
  iconUintArr?: Uint8Array


  constructor(bundleName?: string, appName?: string, iconUintArr?: Uint8Array) {
    this.bundleName = bundleName;
    this.appName = appName;
    this.iconUintArr = iconUintArr
  }

  /**
   * @returns false -> 空
   * @returns true -> 不为空
   * */
  static isEmpty(bundleInfo: BundleInfo): boolean {
    return !(bundleInfo.bundleName === '' || bundleInfo.bundleName === undefined || bundleInfo.bundleName === null || bundleInfo.appName === '' || bundleInfo.appName === undefined || bundleInfo.appName === null)
  }
}