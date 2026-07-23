import { CustomThemeName, CUSTOM_THEME_MAP } from "../utils/AppThemeManager"
import { AppStorageV2, PersistenceV2 } from "@kit.ArkUI"

@ObservedV2
class GlobalInfo {
  /** 主题色 */
  @Trace icon_emphasize: ResourceColor = $r("app.color.emphasize")
  /** @description 当前宽度断点 */
  @Trace WidthBp: number = 0
  /** @description 当前高度断点 */
  @Trace HeightBp: number = 0
  @Trace BottomRectHeight: number = 0
  /** @description 状态栏高度 */
  @Trace TopRectHeight: number = 0
  // 窗口模式
  @Trace windowMode: boolean = false
}

const Xb_Global: GlobalInfo = new GlobalInfo()


@ObservedV2
class UIConfigInfo {


}

const Xb_UIConfig: UIConfigInfo = AppStorageV2.connect(UIConfigInfo, 'UIConfig', () => new UIConfigInfo())!

export { Xb_Global, Xb_UIConfig }