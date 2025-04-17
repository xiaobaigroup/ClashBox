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
import About, { AboutContributors, CheckUpdate, FAQ, ThirdServices, UseGuidance } from "./About"
import Language from "./Language"
import TopBuilder from "./TopBuilder"
import { DisclaimerCustomDialog, theRowCustomDialog } from "../Common"
import { AppState, UIConfig } from "../../entryability/AppState"
import { promptAction } from "@kit.ArkUI"
import { removeItemsByIndex } from "../../utils/RemoveItemsUtils"
import ClashViewModel from "../../entryability/ClashViewModel"


@Entry
@Component
struct Settings {
  @Consume isDisclaimer: boolean
  @Consume currentLanguage: ResourceStr
  @State settingsList: settingsData[] = SettingsListItem()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 当前设备`height`是否符合(320vp< height <= 500vp)
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 列表底边距
  @Consume('breakPointStatemorePagelistBottom') private listBottom: BreakpointState<number>
  // 列表高度
  @Consume('breakPointStateSettingslistHeight') private SettingslistHeight: BreakpointState<number>
  // 断点系统
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  // 免责声明弹窗控制器
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: DisclaimerCustomDialog({
      confirm: () => {
        this.onAccept()
      },
      isDisclaimer: this.isDisclaimer
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

  /**
   * 清空应用设置提示弹窗控制器
   */
  resetDialogController: CustomDialogController = new CustomDialogController({
    builder: theRowCustomDialog({
      theDialogTitle: $r('app.string.settings_reset_prompt'),
      cancel: ()=> { this.onresetCancel() },
      confirm: ()=> { this.onresetAccept() },
      leftButton: this.resetBuilder
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        // 点击遮蔽层不响应，防误触
      } else {
        // 通过dismiss主动关闭对话框
        dismissDialogAction.dismiss()
      }
    }
  })
  /**
   * 清空应用设置按钮
   */
  @Builder
  resetBuilder() {
    Button($r('app.string.reset'))
      .backgroundColor($r('app.color.container_background'))
      .width('100%')
      .height(39)
      .fontColor(Color.Red)
  }
  onresetCancel() {
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
  }
  onresetAccept() {
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
    // 清空应用设置操作
    AppState.ResetConfig()
    promptAction.showToast({message: $r('app.string.settings_reset_tips')})
  }

  handleCheck(index: number) {
    if(index === (this.uiConfig.isShowExperimentalFunction ? 7 : 6)) {
      // 免责声明弹窗
      if (this.dialogController != null) {
        this.isDisclaimer = true
        this.dialogController.open()
      }
    } else if(index == (this.uiConfig.isShowExperimentalFunction ? 6 : 5)) {
      // 清空应用设置弹窗
      this.resetDialogController.open()
    } else if (index === (this.uiConfig.isShowExperimentalFunction ? 2 : -1)) {
      // 备份
      promptAction.showToast({message: $r('app.string.developing')})
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
    if (!this.uiConfig.isShowExperimentalFunction) {
      this.settingsList = removeItemsByIndex(this.settingsList, [2])
    }
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
      } else
      if (name == 'FAQ') {
        FAQ()
      } else
      if (name == 'Three') {
        ThirdServices()
      } else
      if (name == 'UseGuidance') {
        UseGuidance()
      }
  }

  build() {
    Navigation(this.SettingsPageInfos) {
      TopBuilder({
        showBackButton: false,
        title: $r('app.string.Settings'),
        subtitle: `${ClashViewModel.socketProxy.offlineCount}`
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
        })

      }
      .width('100%')
      .contentEndOffset(CONTENT_END_OFFSET_150 - 85)
      .borderRadius(18)
      .alignListItem(ListItemAlign.Center)
      .padding({left: this.breakPointStatemorePageMargin.value, right: this.breakPointStatemorePageMargin.value})
    }
    .hideToolBar(true)
    .mode(this.isLandscapePhone ? NavigationMode.Stack : NavigationMode.Auto)
    .navDestination(this.SettingsPagesMap)
    .width('100%')
    .height('100%')
    .onNavBarStateChange((isVisible: boolean) => {
      // 刷新备份行显示
      if (this.uiConfig.isShowExperimentalFunction) {
        this.settingsList = SettingsListItem()
      }
      // 刷新语言行的语言提示
      const itemData = this.settingsList[0]
      itemData.hint = this.currentLanguage
      this.settingsList.splice(0, 1, itemData)
    })
  }
}
export default Settings