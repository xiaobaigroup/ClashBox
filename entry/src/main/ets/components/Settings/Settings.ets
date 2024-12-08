import { BreakpointState, BreakpointSystem } from "../../common/breakpointsystem"
import { settingsData, SettingsListItem } from "../../common/Constants"
import settingsListItem from "./settingsListItem"

@Component
struct Settings {
  @State settingsList: settingsData[] = SettingsListItem()
  // 当前设备`height`是否符合(320vp< height <= 500vp)
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @Consume('NavPathStack') pageInfos: NavPathStack
  // 断点
  @State compStr: BreakpointState<string> = BreakpointState.of({
    xs: "xs", sm: "sm", md: "md", lg: "lg", xl: "xl"
  })
  // 列表底边距
  @Consume('listBottom') listBottom: BreakpointState<number>

  handleCheck(index: number) {
    // 跳转
    let itemData = this.settingsList[index]
    this.pageInfos.pushPathByName(itemData.name, false)
  }

  aboutToAppear(): void {

    BreakpointSystem.getInstance().attach(this.compStr)
    //BreakpointSystem.getInstance().attach(this.listBottom)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear(): void {
    BreakpointSystem.getInstance().attach(this.compStr)
    //BreakpointSystem.getInstance().attach(this.listBottom)
    BreakpointSystem.getInstance().stop()
  }

  @Builder
  PagesMap(name: string) {
    if (name == 'Log') {
      //Log()
    } else
      if (name == 'Resources') {
        //Resources()
      } else
      if (name == 'Request') {
        //RequestPage()
      } else
      if (name == 'Connect') {
        //Connect()
      } else
      if (name == 'Overwrite') {
        //Overwrite()
      }
  }

  build() {
    Navigation(this.pageInfos) {
      List() {
        ForEach(this.settingsList, (item: settingsData, index: number) => {
          ListItem() {
            settingsListItem({
              index: index,
              itemObj: item,
              onCheck: (index: number) => {
                this.handleCheck(index)
              }
            })
          }
          .margin({bottom: this.listBottom.value })
        })

      }
      //.height(400)
      //.margin({ top: 10, left: this.morePageMargin.value, right: this.morePageMargin.value })
      .borderRadius(18)
      .alignListItem(ListItemAlign.Center)
    }
    .mode(this.isLandscapePhone ? NavigationMode.Stack : NavigationMode.Auto)
    .navDestination(this.PagesMap)
    .width('100%')
    .height('100%')
  }
}
export default Settings