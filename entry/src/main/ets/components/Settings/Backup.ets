import TopBuilder from "./TopBuilder"

@Component
struct Backup {
  @Link isShowSettings: boolean
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  //@Consume('morePageMargin') morePageMargin: BreakpointState<number>
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary') //一级图标色，黑色

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Backup_Recovery'), /*isShowSettings: this.isShowSettings*/})
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
export default Backup