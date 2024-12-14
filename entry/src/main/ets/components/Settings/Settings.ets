import { BreakpointState, BreakpointSystem } from "../../common/breakpointsystem"
import { LanguageListItem, settingsData, SettingsListItem } from "../../common/Constants"
import settingsListItem from "./settingsListItem"
import { hilog } from "@kit.PerformanceAnalysisKit"
import Appearance from "./Appearance"
import Backup from "./Backup"
import ApplicationLock from "./ApplicationLock"
import Notice from "./Notice"
import Backgrounder from "./Backgrounder"
import WipeData from "./WipeData"
import Disclaimer from "./Disclaimer"
import About from "./About"
import Language from "./Language"
import TopBuilder from "./TopBuilder"


//@Entry
@Component
struct Settings {
  @State settingsList: settingsData[] = SettingsListItem()
  @Link isShowSettings: boolean
  //@State isShowMenu: boolean = false
  // 当前设备`height`是否符合(320vp< height <= 500vp)
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary') //一级图标色，黑色
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 断点
  @State compStr: BreakpointState<string> = BreakpointState.of({
    xs: "xs", sm: "sm", md: "md", lg: "lg", xl: "xl"
  })
  // 列表底边距
  @State listBottom: BreakpointState<number> = BreakpointState.of({
    xs: 10, sm: 10, md: 14, lg: 14, xl: 14
  })


  handleCheck(index: number) {
    // 列表项路由跳转
    let itemSettingsData = this.settingsList[index]
    this.SettingsPageInfos.pushPathByName(itemSettingsData.name, false)
    hilog.isLoggable(0xFF00, "SettingstestTag", hilog.LogLevel.INFO);
    hilog.info(0xFF00, "SettingstestTag", itemSettingsData.name)
  }

/*  handleMenuCheck(index: number) {
    // 语言菜单项点击
    let menuItemData = this.LanguageList[index]
    menuItemData.isCheck = !menuItemData.isCheck
    this.LanguageList.splice(index, 1, menuItemData)
    hilog.isLoggable(0xFF00, "menutestTag", hilog.LogLevel.INFO);
    hilog.info(0xFF00, "menutestTag", "%{public}s", menuItemData.isCheck)
  }*/

  aboutToAppear(): void {
    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.listBottom)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear(): void {

  }

  // 设置页路由导航
  @Builder
  SettingsPagesMap(name: string) {
    if (name == 'Appearance') {
      Appearance({isShowSettings: this.isShowSettings})
    } else
      if (name == 'Backup') {
        Backup({isShowSettings: this.isShowSettings})
      } else
      if (name == 'ApplicationLock') {
        ApplicationLock({isShowSettings: this.isShowSettings})
      } else
      if (name == 'Notice') {
        Notice({isShowSettings: this.isShowSettings})
      } else
      if (name == 'Backgrounder') {
        Backgrounder({isShowSettings: this.isShowSettings})
      } else
      if (name == 'WipeData') {
        WipeData({isShowSettings: this.isShowSettings})
      } else
      if (name == 'Disclaimer') {
        Disclaimer({isShowSettings: this.isShowSettings})
      } else
      if (name == 'About') {
        About({isShowSettings: this.isShowSettings})
      } else
      if (name == 'Language') {
        Language({isShowSettings: this.isShowSettings})
      }
  }

  // 语言切换菜单
  /*@Builder
  LanguageMenu() {
    Menu() {
      ForEach(this.LanguageList, (menuItem: settingsData, index: number) => {
        MenuItem({ content: menuItem.title })
          .selected(menuItem.isCheck)
          .selectIcon(true)
          .onClick(() => {
            this.handleMenuCheck(index)
          })
      }, (menuItem: settingsData) => JSON.stringify(menuItem))
    }
  }*/

  build() {
    //Column() {
    Navigation(this.SettingsPageInfos) {
      TopBuilder({
        showBackButton: false,
        title: $r('app.string.Settings'),
        //isShowSettings: this.isShowSettings
      })
      List() {
        ForEach(this.settingsList, (item: settingsData, index: number) => {

            /*if (item.name === 'Language') {
              ListItem() {
                  Row() {
                    SymbolGlyph(item.icons)
                      .fontSize(24)
                      .margin({ left: 12 })
                    Text(item.title)
                      //.width('100%')
                      .height(48)
                      .fontWeight(FontWeight.Medium)
                      .padding({ left: 12 })
                      .fontSize(16)
                    Blank()
                    Text(item.hint)
                      .fontColor('gray')
                      .margin({ right: 8 })
                      .fontSize(14)
                    SymbolGlyph($r('sys.symbol.chevron_right'))
                      .fontSize(24)
                      .margin({ right: 12})
                      .bindContextMenu(this.isShowMenu, this.LanguageMenu,
                        {
                          onDisappear: ()=>{
                            this.isShowMenu = false;
                          }
                        })

                  }
                  .width('94%')
                  .height(53)
                  .borderRadius(20)
                  .backgroundColor($r('app.color.container_background'))
              }
              .onClick(() => {
                this.isShowMenu = !this.isShowMenu
              })
              .margin({bottom: this.listBottom.value })
            } else {*/
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
            //}

        })

      }
      .width('100%')
      .height(500)
      .borderRadius(18)
      .alignListItem(ListItemAlign.Center)
    }
    .mode(this.isLandscapePhone ? NavigationMode.Stack : NavigationMode.Auto)
    .navDestination(this.SettingsPagesMap)
    .width('100%')
    .height('100%')
  }
}
export default Settings