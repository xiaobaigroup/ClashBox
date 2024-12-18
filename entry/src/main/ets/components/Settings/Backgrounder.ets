import TopBuilder from "./TopBuilder"

@Component
struct Backgrounder {
  @Link isShowSettings: boolean
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  //@Consume('morePageMargin') morePageMargin: BreakpointState<number>
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Backgrounder'), /*isShowSettings: this.isShowSettings*/})
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