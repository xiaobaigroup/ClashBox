import { BreakpointState } from "../../common/breakpointsystem"
import { getResourceString } from "../../utils/getResourceString"
import LogTopBuilder from "./TopBuilder"

@Component
struct Log {
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('morePageMargin') morePageMargin: BreakpointState<number>
  @State EnableLogger: boolean = false
  @State isLogData: boolean = false
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary') //一级图标色，黑色

  build() {
    NavDestination() {
      LogTopBuilder({
        EnableLogger: this.EnableLogger
      })
      if (this.EnableLogger === false) {
        Column() {
          SymbolGlyph($r('sys.symbol.checkmark_circle'))
            .fontSize(24)
            .fontColor([this.icon_secondary])
            .margin({bottom: 4 })
          Text($r('app.string.EnableLoggerPrompt'))
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height('100%')
      } else if (this.isLogData === false) {
        Column() {
          SymbolGlyph($r('sys.symbol.doc'))
            .fontSize(24)
            .fontColor([this.icon_secondary])
            .margin({bottom: 4 })
          Text($r('app.string.NoLogs'))
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height('100%')
      } else {



      }

    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    //.title(this.TopBuilder)//getResourceString($r('app.string.Log'), this)
    .onBackPressed(() => {
      this.pageInfos.clear();
      return true;
    })
  }
}
export default Log