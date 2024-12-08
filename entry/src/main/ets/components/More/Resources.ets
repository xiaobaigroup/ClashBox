import { BreakpointState } from "../../common/breakpointsystem"

@Component
struct Resources {
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('morePageMargin') morePageMargin: BreakpointState<number>
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary') //一级图标色，黑色

  build() {
    NavDestination() {
      Row() {
        //返回图标
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(28)
            .fontColor([this.icon_secondary])
        }
        .margin({left: this.morePageMargin.value})
        .onClick(() => {
          this.pageInfos.pop(true)
        })
        .width(40)
        .height(40)
        .backgroundColor($r('app.color.settings_container_background'))
        Text($r('app.string.Resources'))
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
          .margin({left: 8})
        Blank()

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

export default Resources