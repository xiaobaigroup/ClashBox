import { BreakpointState } from "../../../common/breakpointsystem"
import { ConfigItemData, ListOverwriteBasicData, } from "../../../common/Constants"
import OverwriteTop from "./OverwriteTopBuilder"
import { ClashConfig } from 'proxy_core'
import { AppConfig, UIConfig } from '../../../entryability/AppState'
import { ConfigList } from "./Common"

@Component
struct Basic {
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')

  @Consume('NavPathStack') pageInfos: NavPathStack
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @State overwriteBasicList: ConfigItemData[] = []
  @Consume('breakPointStatemorePagelistBottom') listBottom: BreakpointState<number>
  // 列表高度
  @Consume('breakPointStateListHeight') listHeight: BreakpointState<number>
  // 平板竖屏判断
  @StorageProp('istabletVertical')  private istabletVertical: boolean = false
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  aboutToAppear(): void {
    this.overwriteBasicList = ListOverwriteBasicData(this.clashConfig, this.appConfig)
  }

  build() {
    NavDestination() {
      OverwriteTop({
        title: $r('app.string.Basic'),
        subtitle: ''
      })
      // 列表
      ConfigList({configList: this.overwriteBasicList})
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
export default Basic