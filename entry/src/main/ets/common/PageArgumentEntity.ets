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
// 配置 -> 新增配置时的传输数据
export interface ConfigData{
  // 配置id
  configId: string
  // 是否为新配置（非已有配置进入编辑状态）
  isNewConfig: boolean
  // 配置名
  configName: string
  // 配置URL
  configURL: string
  // 是否自动更新
  isConfigAutoUpdate: boolean
  // 自动更新间隔
  configAutoUpdateTimeGapSelectedValue?: number
  // 代理列表
  // proxyList:
}


/* 更多 */