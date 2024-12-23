import { BreakpointState } from "../../common/breakpointsystem"
import TopBuilder from "./TopBuilder"

@Component
struct Backgrounder {
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Backgrounder')})
      Column() {

      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .padding({ left: this.breakPointStatemorePageMargin.value, right: this.breakPointStatemorePageMargin.value })
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.SettingsPageInfos.clear();
      return true;
    })
  }
}
export default Backgrounder