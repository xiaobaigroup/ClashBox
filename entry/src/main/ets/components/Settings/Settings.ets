import { BreakpointState, BreakpointSystem } from "../../common/breakpointsystem"
import { FONT_SIZE_16, settingsData, SettingsListItem } from "../../common/Constants"
import settingsListItem from "./settingsListItem"
import { hilog } from "@kit.PerformanceAnalysisKit"
import Appearance from "./Appearance"
import Backup, { CloudBackup } from "./Backup"
import ApplicationLock from "./ApplicationLock"
import Notice from "./Notice"
import Backgrounder from "./Backgrounder"
import WipeData from "./WipeData"
import About, { AboutContributors } from "./About"
import Language from "./Language"
import TopBuilder from "./TopBuilder"

// 免责声明弹窗
@CustomDialog
@Component
struct DisclaimerCustomDialog {
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  confirm: () => void = () => {}
  controller?: CustomDialogController

  build() {
    Column() {
      Text($r('app.string.Disclaimer'))
        .fontSize(20)
        .margin({ top: 15, bottom: 15 })
      Text($r('app.string.Disclaimer_Content'))
        .textAlign(TextAlign.Center)
        .fontSize(FONT_SIZE_16)
      Button($r('app.string.Confirm'))
        .margin({ top: 15 })
        .width('100%')
        .backgroundColor(this.icon_emphasize)
        .onClick(() => {
          if (this.controller != undefined) {
            this.controller.close()
            this.confirm()
          }
        })
        .fontColor(Color.White)
    }
    .backgroundColor($r('app.color.container_background'))
    .padding({left: 24, right: 24})
    .height(195)
    .borderRadius(32)
  }
}

@Component
struct Settings {

  @State settingsList: settingsData[] = SettingsListItem()
  @Link isShowSettings: boolean
  // 当前设备`height`是否符合(320vp< height <= 500vp)
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 列表底边距
  @Consume('breakPointStatemorePagelistBottom') private listBottom: BreakpointState<number>
  // 列表高度
  @Consume('breakPointStateSettingslistHeight')
  private SettingslistHeight: BreakpointState<number>

  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean
  // 免责声明弹窗控制器
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: DisclaimerCustomDialog({
      confirm: () => {
        this.onAccept()
      }
    }),
    autoCancel: false,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
      }
    },
    // alignment: DialogAlignment.Center,
    // offset: { dx: 0, dy: -20 },
    // gridCount: 4,
    // customStyle: false,
  })

  onAccept() {

  }

  handleCheck(index: number) {
    if(index === 7) {
      // 免责声明弹窗
      if (this.dialogController != null) {
        this.dialogController.open()
      }
    } else {
      // 列表项路由跳转
      let itemSettingsData = this.settingsList[index]
      this.SettingsPageInfos.pushPathByName(itemSettingsData.name, false)
      hilog.isLoggable(0xFF00, "SettingstestTag", hilog.LogLevel.INFO);
      hilog.info(0xFF00, "SettingstestTag", itemSettingsData.name)
    }
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
    BreakpointSystem.getInstance().attach(this.listBottom)
    BreakpointSystem.getInstance().start()
  }

  // 在自定义组件即将析构销毁时将dialogController置空
  aboutToDisappear() {
    this.dialogController = null // 将dialogController置空
  }

  // 设置页路由表
  @Builder
  SettingsPagesMap(name: string) {
    if (name == 'Appearance') {
      Appearance({isShowSettings: this.isShowSettings})
    } else
      if (name == 'Backup') {
        Backup()
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
      if (name == 'About') {
        About({isShowSettings: this.isShowSettings})
      } else
      if (name == 'Language') {
        Language({isShowSettings: this.isShowSettings})
      } else
      if (name == 'Contributors') {
        AboutContributors()
      } else
      if (name == 'CloudBackup') {
        CloudBackup()
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
      })
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
      .width('100%')
      .height(this.isLandscapePhone ? 300 : this.SettingslistHeight.value)
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