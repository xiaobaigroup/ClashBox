import { BreakpointState } from "../../common/breakpointsystem"

@Component
struct RequestPage {
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色

  build() {
    NavDestination() {
      Row() {
        //返回图标
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(28)
            .fontColor([this.icon_primary])
        }
        .margin({left: this.morePageMargin.value})
        .onClick(() => {
          this.pageInfos.pop(true)
        })
        .width(40)
        .height(40)
        .backgroundColor($r('app.color.settings_container_background'))
        Text($r('app.string.Request'))
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
          .margin({left: 8})
        Blank()
        //搜索
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(24)
            .fontColor([this.icon_primary])
        }
        .margin({ right: this.morePageMargin.value })
        .backgroundColor($r('app.color.settings_container_background'))
        .width(40)
        .height(40)
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.pageInfos.clear();
      return true;
    })
  }
}

export default RequestPage