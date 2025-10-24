import { ConfigItemData, ListOverwriteDNSData,} from "../../../common/entity/Constants"
import { hilog } from "@kit.PerformanceAnalysisKit"
import OverwriteTop from "./OverwriteTopBuilder"
import { ClashConfig, Dns } from 'proxy_core'
import { AppConfig } from '../../../entryability/AppState'
import { ConfigList } from "./Common"

@Builder
export function DNSBuilder(name: string, param: Object){
  DNS()
}

@Component
struct DNS {

  // 更多页面栈
  @StorageLink('MoreNavPathStack') morePageInfos: NavPathStack = new NavPathStack()
  @StorageLink('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1

  @State overwriteDNSList: ConfigItemData[] = []

  aboutToAppear(): void {
    this.overwriteDNSList = ListOverwriteDNSData(this.clashConfig, this.appConfig)
    console.log("dnsConfig", JSON.stringify(this.clashConfig))
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
      if (this.widthBp < 2) {
        this.pageInfos.pop(true)
      } else {
        this.morePageInfos.pop(true)
      }
      return true
    })
  }
}
export default DNS