import { ConfigItemData, ListOverwriteBasicData, } from "../../../common/Constants"
import OverwriteTop from "./OverwriteTopBuilder"
import { ClashConfig } from 'proxy_core'
import { AppConfig } from '../../../entryability/AppState'
import { ConfigList } from "./Common"


@Component
struct Basic {

  @Consume('NavPathStack') pageInfos: NavPathStack
  @State overwriteBasicList: ConfigItemData[] = []
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()

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