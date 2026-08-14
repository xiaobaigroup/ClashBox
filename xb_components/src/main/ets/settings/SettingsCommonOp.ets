
export interface SettingsItem {
  id: string
  icon?: Resource
  iconColor?: ResourceColor
  menuIcon?: Resource
  contentL: string | Resource
  contentLColor?: ResourceColor
  contentSecL?: string | Resource
  contentR?: ResourceStr
  rightStyle?: string
  rightColor?: ResourceColor
  onClick?: (d?:CustomDialogController | null) => void
  menuSelect?: number | string
  radioSelect?: string
  toggleState?: boolean
  menuList?: Array<MenuItem>
}

export interface SettingsGroup {
  title?: ResourceStr
  groupId?: string
  items: SettingsItem[]
}

// 应用设置和串流设置切换
export enum AppOrStreamSelect {
  APP,
  STREAM
}

// 应用设置list列表小标题选择
export enum AppTitleSelect {
  APPEARANCE = '外观',
  MORE = '更多',
  ABOUT = '关于'
}


// 右边可选择的组件
export enum RightStyle {
  MENU = 'Menu',
  TOGGLE = 'Toggle',
  DIALOG = 'Dialog',
  JUMP = 'Jump',
  TEXT = 'Text',
  TEXTRIGHT = 'TEXTRIGHT', // 文本后有跳转箭头
  RIGHTTEXT = 'RIGHTTEXT', // 文本后无跳转箭头
  BUTTON = 'Button',
  RADIO = 'Radio',
  NONE = 'None',
  SYMBOL = 'Symbol'
}

export interface MenuItem {
  selectOption?: SelectOption
  startIcon?: Resource
  startMediaIcon?: Resource
  startIconColor?: ResourceColor[]
  endIcon?: Resource
  itemName?: ResourceStr
  itemValue?: string | number
  onSelect?: () => void
}