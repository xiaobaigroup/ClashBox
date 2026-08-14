
// 界面类
export { MainPage } from './src/main/ets/components/MainPage';
export { Xb_Studio } from './src/main/ets/view/Xb_Studio';
export { Xb_SettingsGroup } from  './src/main/ets/view/Xb_SettingsGroup'

// 组件类
export { Xb_RowCustomDialog } from './src/main/ets/components/Xb_RowCustomDialog';
export { Xb_SettingsCommon } from './src/main/ets/components/Xb_SettingsCommon';
export { Xb_CircleButton, Xb_CapsuleButton } from './src/main/ets/components/Xb_Button';
export { Xb_WindowDecor } from './src/main/ets/components/Xb_WindowDecor';
export { Xb_UIConfig, Xb_Global } from './src/main/ets/entity/XbGlobal'
export { Xb_PriUserComWeb } from './src/main/ets/components/Xb_PriUserComWeb'
export { Xb_SingleValueDialog } from './src/main/ets/components/Xb_Dialog'
export { Xb_TabComponent, Xb_TabComponentConfig } from './src/main/ets/components/Xb_TabComponent'
export { Xb_SwitchButton, SwitchButtonItem } from './src/main/ets/components/Xb_SwitchButton'
export { Xb_GeneralListItem } from './src/main/ets/components/Xb_GeneralListItem'
export { Xb_Menu } from './src/main/ets/components/Xb_Menu'
export { Xb_Pay } from './src/main/ets/components/Xb_Pay'
export { Xb_Account } from './src/main/ets/components/Xb_Account'
export { Xb_UpdateLog, TCItemProp } from './src/main/ets/components/Xb_UpdateLog'
export { Xb_Vip } from './src/main/ets/components/Xb_Vip'
export { Xb_SettingsItem } from  './src/main/ets/components/Xb_SettingItem'
export { CrashPage as Xb_CrashPage } from './src/main/ets/view/Xb_CrashPage'
export { Xb_SideBar } from './src/main/ets/components/Xb_SideBar'

// 工具类
export { EventHub, EventHub as Xb_EventHub, Xb_EventKey } from './src/main/ets/utils/EventHub'
export { Xb_Timer, Xb_TimeCountdown, globalTimeCountDown, globalTimer } from './src/main/ets/utils/Timer'
export { Xb_KVdbUtil } from './src/main/ets/utils/KVdbUtil'
export { Xb_Copy } from './src/main/ets/utils/ClipBoardUtil'
export { Xb_FileUtils } from './src/main/ets/utils/FileUtils'
export { Xb_AnimationStyle } from './src/main/ets/utils/Animation'
export { Xb_DynamicIconManager } from './src/main/ets/utils/DynamicIconManager'
export { Xb_BatchUpsert } from './src/main/ets/utils/BatchUpsertUtil'
export { Xb_GoToWeb, Xb_HandleMailto, Xb_HandleMail } from './src/main/ets/utils/JumpTo';
export { Xb_TimeUtils, Xb_TimeGap } from './src/main/ets/utils/TimeUtils';
export { Xb_HoldingHandleUtil } from './src/main/ets/utils/HoldingHandleUtil'
export { Xb_NotificationUtils } from './src/main/ets/utils/AppNotificationService'
export { Xb_ColorModeManager } from './src/main/ets/utils/ColorModeManager'
export { Xb_ChangeThemeColor, Xb_ThemeColorUtil } from './src/main/ets/utils/ChangeThemeColorUtil'
export { Xb_ChangeLanguage } from './src/main/ets/utils/ChangeLanguageUtil'
export { Xb_GetPackageInfo } from './src/main/ets/utils/GetPackageInfoUtil'
export { Xb_GetResourceString } from './src/main/ets/utils/ResourceStringUtil'
export { Xb_ResourceColorUtil } from './src/main/ets/utils/ResourceColorUtil'
export { Xb_BreakpointFunction } from './src/main/ets/utils/breakpoint/BreakPointStystem'
export { Xb_BreakpointType2D, Xb_BreakpointFunction2D } from './src/main/ets/utils/breakpoint/BreakPointSystem2D'
export { Xb_GetNumber } from './src/main/ets/utils/GetNumber'
export { Xb_ColorUtils } from './src/main/ets/utils/ColorUtils'
export { Xb_PipManager } from './src/main/ets/utils/PipManager';
export { Xb_DataSwitch } from './src/main/ets/utils/DataSwitch';
export { Xb_BackgroundRunning } from './src/main/ets/utils/BackgroundRunning';
export { Xb_AppContinue } from './src/main/ets/utils/AppContinue';
export { Xb_Share, ShareData } from './src/main/ets/utils/Share';
export { Xb_GetEnumKey, KeyCodeMine } from './src/main/ets/utils/GetEnumKey';
export { Xb_BackgroundLocateService } from './src/main/ets/utils/BackgroundLocateService'
export { Xb_FileConnectApp } from './src/main/ets/utils/FileConnectApp'
export { productsUtils as Xb_ProductsUtils, PayProduct } from  './src/main/ets/utils/ProductsUtils'
export { Xb_ImageUtils } from './src/main/ets/utils/ImageUtils'
export { Xb_StatusBarUtils, StatusBarIconResource, StatusBarConfig } from './src/main/ets/utils/StatusBarUtils'
export { Xb_PromptActionsClass } from './src/main/ets/entity/PromptActionClass'
export { AvoidanceChangeListener, Xb_AvoidanceManager, SmartAvoidance } from './src/main/ets/utils/AvoidManager'
export { crashUtils as Xb_CrashUtils } from  './src/main/ets/utils/CrashUtils'
export { Xb_PreferenceUtil } from  './src/main/ets/utils/PreferenceUtil'
export {  Xb_SettingsItemData, Xb_SettingsGroupData, makeSettingsGroupData as Xb_MakeSettingsGroupData, Xb_RadioGroupData,  Xb_MenuSelectItem, Xb_ActionType } from  './src/main/ets/model/SettingsItem'
export { Xb_CustomDialog } from  './src/main/ets/components/Xb_CustomDialog'

export { LocalSocketUtils } from "./src/main/ets/utils/LocalSocketUtils"
export { Xb_GlobalContext } from './src/main/ets/entity/GlobalContext'
export { Xb_ToastUtil } from  './src/main/ets/utils/ToastUtils'

// 虚拟键盘
export { VirtualKeyboard as Xb_VirtualKeyboard, VirtualMouseKey as Xb_VirtualMouseKey, KeyCodeSelector as Xb_KeyCodeSelector, MouseButtonCode as Xb_MouseButtonCode } from  './src/main/ets/components/keyboard/VirtualKeyboard'
export { GameLayout as Xb_GameLayout } from './src/main/ets/controllers/GameLayout'
export { ControllerEventHandler as Xb_ControllerEventHandler, StickAxisEvent } from './src/main/ets/controllers/ControllerEventHandler'
export { ControllerViewModel as Xb_GameControllerViewModel} from './src/main/ets/controllers/ControllerViewModel'
export { MenuState as Xb_GameMenuState, CursorMoveType as Xb_CursorMoveType } from './src/main/ets/controllers/MenuButton'
// 依赖注入
export { getPersistence, getPersistence as Xb_getPersistence, getPersistenceByName as Xb_getPersistenceByName, savePersistence as Xb_savePersistence, getAppStore, getAppStore as Xb_getAppStore, makePersistenceSettings as Xb_makePersistenceSettings } from "./src/main/ets/model/di"

// 配置类
export { RightStyle } from "./src/main/ets/settings/SettingsCommonOp"
export { TabStyle, ThemeType } from "./src/main/ets/entity/Common"

export { BaseDataSource } from "./src/main/ets/entity/BaseDataSource"

export { lockCursor, unlockCursor, hasJit } from "libxb_components.so"

// 常用断点
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
} from './src/main/ets/utils/breakpoint/BreakPoint'


export { SettingsGroup, SettingsItem } from './src/main/ets/settings/SettingsCommonOp'
