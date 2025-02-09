
import { BreakpointState } from "../../../common/breakpointsystem"
import {
  ConfigItemData,
  CONTENT_END_OFFSET,
  DNSMenu, ListOverwriteDNSData, MenuListItemProp, moreData } from "../../../common/Constants"
import { hilog } from "@kit.PerformanceAnalysisKit"
import OverwriteTop from "./OverwriteTopBuilder"
import { menuRowList, skipRowList, theCustomDialog, toggleRowList } from "../../Common"
import { ClashConfig, Dns } from 'proxy_core'
import { AppConfig, copy, UIConfig } from '../../../entryability/AppState'
import { ArrayConfigParam } from "./EditArrayConfig"
import { EventHub, EventKey } from "../../../common/EventHub"
import { JSON } from "@kit.ArkTS"
import { SymbolGlyphModifier } from "@kit.ArkUI"
import { getResourceString } from "../../../utils/ResourceStringUtil"
import { ConfigList } from "./Common"


@Component
struct DNS {
  // 是否进入二级界面
  @Consume isSecondary: boolean
  @State isFakeIP: boolean = false
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Consume('NavPathStack') pageInfos: NavPathStack
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @State overwriteDNSList: ConfigItemData[] = []
  @State DNSMenuList: MenuListItemProp[] = DNSMenu
  @Consume('breakPointStatemorePagelistBottom') listBottom: BreakpointState<number>
  // 列表高度
  @Consume('breakPointStateListHeight') listHeight: BreakpointState<number>
  // 平板竖屏判断
  @StorageProp('istabletVertical')  private istabletVertical: boolean = false
  @State SaveInputValue: string = ''
  @State currentInputValue: string = ''
  @State theplaceholder: string = 'CN'
  // DNS模式临时选择项
  @State DNSModeIndex: number = 0
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  aboutToAppear(): void {
    this.overwriteDNSList = ListOverwriteDNSData(this.clashConfig, this.appConfig)
  }
  build() {
    NavDestination() {
      // 导航栏
      OverwriteTop({
        title: $r('app.string.DNS'),
        subtitle: ''
      })
      ConfigList({configList: this.overwriteDNSList})
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      if(this.pageInfos.size() === 1) {
        this.pageInfos.clear()
      } else {
        this.pageInfos.pop(true)
      }
      return true
    })
  }
}
export default DNS