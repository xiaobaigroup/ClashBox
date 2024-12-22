import TopBuilder from "./TopBuilder"

@Component
struct Appearance {
  @Link isShowSettings: boolean
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色

  build() {
    NavDestination() {
      // 顶部导航区
      TopBuilder({title: $r('app.string.Appearance'), /*isShowSettings: this.isShowSettings*/})


    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
 //   .backgroundBlurStyle(BlurStyle.BACKGROUND_REGULAR)
    .onBackPressed(() => {
      this.SettingsPageInfos.clear();
      return true;
    })
  }
}
export default Appearance