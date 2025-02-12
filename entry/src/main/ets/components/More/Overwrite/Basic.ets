import { ConfigItemData, ListOverwriteBasicData, TAB_CONTENT_TITLE_HEIGHT, } from "../../../common/Constants"
import OverwriteTop from "./OverwriteTopBuilder"
import { ClashConfig } from 'proxy_core'
import { AppConfig, UIConfig } from '../../../entryability/AppState'
import { ConfigList } from "./Common"


@Component
struct Basic {

  @Consume('NavPathStack') pageInfos: NavPathStack
  @State overwriteBasicList: ConfigItemData[] = []
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  //page内顶部标题偏移量
  @Consume curYOffset: number
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
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