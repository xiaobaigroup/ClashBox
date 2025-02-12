import { BreakpointState } from "../../common/breakpointsystem"
import { CONTENT_END_OFFSET_150, FONT_SIZE_16, settingsData, SettingsListItem } from "../../common/Constants"
import settingsListItem from "./settingsListItem"
import { hilog } from "@kit.PerformanceAnalysisKit"
import Appearance from "./Appearance"
import Backup, { CloudBackup } from "./Backup"
import Kernel from "./Kernel"
import Notice, { CellularDataReminder } from "./Notice"
import Backgrounder from "./Backgrounder"
import WipeData from "./WipeData"
import About, { AboutContributors, CheckUpdate } from "./About"
import Language from "./Language"
import TopBuilder from "./TopBuilder"
import { DisclaimerCustomDialog } from "../Common"


@Entry
@Component
struct Settings {

  @State settingsList: settingsData[] = SettingsListItem()
  @Consume currentLanguage: ResourceStr
  // 当前设备`height`是否符合(320vp< height <= 500vp)
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 列表底边距
  @Consume('breakPointStatemorePagelistBottom') private listBottom: BreakpointState<number>
  // 列表高度
  @Consume('breakPointStateSettingslistHeight') private SettingslistHeight: BreakpointState<number>

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
    }
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

  onLanguageChanged() {
    hilog.info(0xFF00, "SettingsTestTag", "设置页页面栈：%{public}d", this.SettingsPageInfos.size())
  }

  aboutToAppear(): void {
  }

  // 在自定义组件即将析构销毁时将dialogController置空
  aboutToDisappear() {
    this.dialogController = null
  }

  // 设置页路由表
  @Builder
  SettingsPagesMap(name: string) {
    if (name == 'Appearance') {
      Appearance()
    } else
      if (name == 'Backup') {
        Backup()
      } else
      if (name == 'Notice') {
        Notice()
      } else
      if (name == 'Backgrounder') {
        Backgrounder()
      } else
      if (name == 'WipeData') {
        WipeData()
      } else
      if (name == 'About') {
        About()
      } else
      if (name == 'Language') {
        Language()
      } else
      if (name == 'Contributors') {
        AboutContributors()
      } else
      if (name == 'CloudBackup') {
        CloudBackup()
      } else
      if (name == 'CheckUpdate') {
        CheckUpdate()
      } else
      if (name == 'CellularDataReminder') {
        CellularDataReminder()
      } else
      if (name == 'Kernel') {
        Kernel()
      }
  }

  build() {
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
      .contentEndOffset(CONTENT_END_OFFSET_150 - 85)
      .borderRadius(18)
      .alignListItem(ListItemAlign.Center)
    }
    .hideToolBar(true)
    .mode(this.isLandscapePhone ? NavigationMode.Stack : NavigationMode.Auto)
    .navDestination(this.SettingsPagesMap)
    .width('100%')
    .height('100%')
    .onNavBarStateChange((isVisible: boolean) => {
      // 刷新语言行的语言提示
      const itemData = this.settingsList[0]
      itemData.hint = this.currentLanguage
      this.settingsList.splice(0, 1, itemData)
    })
  }
}
export default Settings