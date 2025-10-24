import { ConfigItemData, ListOverwriteBasicData, TAB_CONTENT_TITLE_HEIGHT, } from "../../../common/entity/Constants"
import OverwriteTop from "./OverwriteTopBuilder"
import { ClashConfig } from 'proxy_core'
import { AppConfig, UIConfig } from '../../../entryability/AppState'
import { ConfigList } from "./Common"

@Builder
export function BasicBuilder(name: string, param: Object){
  Basic()
}

@Component
struct Basic {

  // 更多页面栈
  @StorageLink('MoreNavPathStack') morePageInfos: NavPathStack = new NavPathStack()
  @StorageLink('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @State overwriteBasicList: ConfigItemData[] = []

  aboutToAppear(): void {
    this.overwriteBasicList = ListOverwriteBasicData(this.clashConfig, this.appConfig)
  }

  build() {
    NavDestination() {
      Stack() {
        OverwriteTop({
          title: $r('app.string.Basic'),
          subtitle: ''
        })

        Column() {
          // 列表
          ConfigList({ configList: this.overwriteBasicList })
        }
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      if (this.widthBp < 2) {
        this.pageInfos.pop(true)
      } else {
        this.morePageInfos.pop(true)
      }
      return true
    })
  }
}
export default Basic