/* 存放组件之间传输的实体类、需要持久化的数据对象 */

// TODO 之后根据这些数据整理成用户首选项
export interface UserPreferences{
  // 用户id
  userId: string
  // 首选语言
  language: string
  // 首选颜色模式 [0: LIGHT, 1: DARK]
  colorMode: ColorMode
  // ...
}


/* 主页 */


/* 代理 */


/* 配置 */
// 配置来源类型
export enum ConfigDataSourceType{
  URL,
  QR_CODE,
  FILE,
  BLANK_FILE,
  COPY
}

// 配置 -> 新增配置时的传输数据
export interface ConfigData{
  // 配置id
  readonly configId: string
  // 是否为新配置（非已有配置进入编辑状态）
  isNewConfig: boolean
  // 配置名
  configName: string
  // 配置URL
  configUrl: string
  // 是否自动更新
  isConfigAutoUpdate: boolean
  // 自动更新间隔对应的值
  configAutoUpdateTimeGapValue?: number
  // 自动更新间隔`TextPicker`对应的索引（默认数据参照`Constants.CONFIG_AUTO_UPDATE_TIME_GAT_STRING_ARR` & $r('app.strarray.config_auto_update_text_picker')）
  configAutoUpdateTimeGapTextPickerIndex?: number
  // 创建日期 yyyy-MM-dd hh:mm:ss
  createdDate?: string
  // 最后更新/编辑日期 yyyy-MM-dd hh:mm:ss
  lastUpdateDateTime?: string
  // 套餐已用流量
  trafficUsed?: string
  // 套餐所有流量
  trafficTotal?: string
  // 配置是否收藏
  isFavorite?: boolean
  // 配置来源类型
  sourceType?: ConfigDataSourceType
  // 如果是副本配置，对应源配置id
  copySourceConfigId?: string


  // 代理列表 TODO 还用不到 先设为可选属性
  proxyList?: Array<ProxyData>
}

// 代理 -> 新增代理
export interface ProxyData{

}


/* 更多 */