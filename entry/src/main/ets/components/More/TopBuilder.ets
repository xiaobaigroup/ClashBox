import { BreakpointState } from "../../common/breakpointsystem"


@Component
struct LogTopBuilder {
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('morePageMargin') morePageMargin: BreakpointState<number>
  @Link EnableLogger: boolean
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary') //一级图标色，黑色

  @Builder
  MoreMenu() {
    Menu() {
      MenuItem({ content: $r('app.string.EnableLogger') })
        .selectIcon(true)
        .selected(this.EnableLogger)
        .onChange((selected) => {
          this.EnableLogger = !this.EnableLogger
        })
      if (this.EnableLogger) {
        MenuItem({ content: $r('app.string.ClearLogs')})
          .selectIcon(true)
        MenuItem({ content: $r('app.string.ExportLog')})
          .selectIcon(true)
      }
    }
  }

  build() {
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
      Text($r('app.string.Log'))
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
        .margin({left: 8})
      Blank()
      //搜索
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        SymbolGlyph($r('sys.symbol.magnifyingglass'))
          .fontSize(24)
          .fontColor([this.icon_secondary])
      }
      .backgroundColor($r('app.color.settings_container_background'))
      .margin({ right: 10 })
      .width(40)
      .height(40)
      //更多图标
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
          .fontSize(24)
          .fontColor([this.icon_secondary])
      }
      .margin({ right: this.morePageMargin.value })
      .width(40)
      .height(40)
      .bindMenu(this.MoreMenu())
      .backgroundColor($r('app.color.settings_container_background'))
    }
    .width('100%')
    .height(56)
    .alignItems(VerticalAlign.Center)
  }
}

export default LogTopBuilder