
@Component
struct Backgrounder {
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  //@Consume('morePageMargin') morePageMargin: BreakpointState<number>
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
        .margin({left: 16, top: 16 })
        .width(40)
        .height(40)
        .backgroundColor($r('app.color.settings_container_background'))
        .onClick(() => {
          this.SettingsPageInfos.pop(true)
        })
        Text($r('app.string.Backgrounder'))
          .fontSize(20)
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
    .backgroundColor($r('app.color.settings_container_background'))
    .backgroundBlurStyle(BlurStyle.BACKGROUND_REGULAR)
    .onBackPressed(() => {
      this.SettingsPageInfos.clear();
      return true;
    })
  }
}
export default Backgrounder