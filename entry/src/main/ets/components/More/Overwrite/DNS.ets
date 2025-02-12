import { ConfigItemData, ListOverwriteDNSData,} from "../../../common/Constants"
import { hilog } from "@kit.PerformanceAnalysisKit"
import OverwriteTop from "./OverwriteTopBuilder"
import { ClashConfig, Dns } from 'proxy_core'
import { AppConfig } from '../../../entryability/AppState'
import { ConfigList } from "./Common"


@Component
struct DNS {
  @Consume('NavPathStack') pageInfos: NavPathStack
  @State overwriteDNSList: ConfigItemData[] = []
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()

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
        .height('100%')
    }
    .width('100%')
    .height('100%')
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