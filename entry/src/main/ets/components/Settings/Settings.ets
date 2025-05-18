import { BreakpointState } from "../../common/breakpointsystem"
import {
  BORDER_RADIUS_20,
  CONTENT_END_OFFSET_150, FONT_SIZE_16, settingsData, SettingsListItem } from "../../common/Constants"
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
import { DisclaimerCustomDialog, Nothing, theRowCustomDialog } from "../Common"
import { AppState, UIConfig } from "../../entryability/AppState"
import { promptAction } from "@kit.ArkUI"
import { removeItemsByIndex } from "../../utils/RemoveItemsUtils"
import ClashViewModel from "../../entryability/ClashViewModel"
import { getResourceString } from "../../utils/ResourceStringUtil"
import { common } from "@kit.AbilityKit"
import { timestampToDateTime } from "../../utils/TimeConvertUtil"
import { ProxyGroupItemDataSource } from "../../common/ProxyData"
import { ConfigData } from "../../common/PageArgumentEntity"
import { PrivacyPolicy, UserAgreement } from "./AgreementPrivacyPage"

const context = getContext(this) as common.UIAbilityContext

@Entry
@Component
struct Settings {
  @Consume isDisclaimer: boolean
  // 判断设置是否清楚数据
  @Consume isClearData: boolean
  // 设置模态页控制变量
  @Consume isShowSettings: boolean
  @Consume currentLanguage: ResourceStr
  @Consume configList: Array<ConfigData>
  @Consume proxyGroups: ProxyGroupItemDataSource
  @State settingsList: settingsData[] = SettingsListItem()
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 当前设备`height`是否符合(320vp< height <= 500vp)
  @StorageLink ('isLandscapePhone') private isLandscapePhone: boolean = false
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
    // this.isEnableIndexForegroundBlur = false
  }
  async onresetAccept() {
    // 清空应用设置操作
    try {
      await AppState.ResetConfig(getContext(this))
    }catch (e) {
      promptAction.showToast({message: "清理配置失败!"})
    }
    this.proxyGroups.clear()
    this.isClearData = true
    this.configList = []
    hilog.info(0xC011, 'Settings', `EditConfig #onConfigListChange#配置列表: ${JSON.stringify(this.configList)}`)
    promptAction.showToast({message: $r('app.string.settings_reset_tips')})
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
    // 关闭设置页
    this.isShowSettings = false
  }

  handleCheck(index: number) {
    if(index == (this.uiConfig.isShowExperimentalFunction ? 6 : 5)) {
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
      } else
      if (name == 'offline-detail') {
        OfflineDetail()
      } else
      if (name == 'agreement-privacy') {
        UserAgreement()
      } else
      if (name == 'privacy-policy') {
        PrivacyPolicy()
      }
  }

  build() {
    Navigation(this.SettingsPageInfos) {
      TopBuilder({
        showBackButton: false,
        title: $r('app.string.Settings'),
      })
      List({space: 10}) {
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
        ListItem() {
          Text() {
            Span($r('app.string.settings_count_vpn'))
            Span(`${ClashViewModel.socketProxy.offlineTime.length}`)
            Span(`${getResourceString($r('app.string.times'), context)}, `)
            Span($r('app.string.view_detail'))
              .fontColor(this.icon_emphasize)
              .onClick(() => {
                this.SettingsPageInfos.pushPathByName('offline-detail', false)
              })
          }
            .fontColor($r('sys.color.font_secondary'))
            .maxLines(1)
            .fontSize(14)
        }
      }
      .width('100%')
      .contentEndOffset(CONTENT_END_OFFSET_150 - 75)
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


@Component
struct OfflineDetail {

  @State offline: number[] = []
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>

  aboutToAppear(): void {
    this.offline = ClashViewModel.socketProxy.offlineTime.reverse()
  }

  build() {
    NavDestination() {
      TopBuilder({
        title: $r('app.string.offline'),
        subtitle: ''
      })

      if (this.offline.length === 0) {
        Nothing({
          name: $r('app.string.offline')
        })
      } else {
        List({ space: 10 }) {
          ForEach(this.offline, (item: number, index: number) => {
            ListItem() {
              Row() {
                Column() {
                  Text() {
                    Span($r('app.string.id'))
                    Span('：')
                    Span((index + 1).toString())
                  }
                  .fontWeight(FontWeight.Normal)
                  .fontSize(15)
                  Text() {
                    Span($r('app.string.time'))
                    Span('：')
                    Span(timestampToDateTime(item))
                  }
                  .fontWeight(FontWeight.Normal)
                  .fontSize(15)
                }
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(12)
              .justifyContent(FlexAlign.Start)
              .backgroundColor($r('app.color.container_background'))
              .borderRadius(BORDER_RADIUS_20)
            }
          })
        }.width('100%')
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)
        .contentEndOffset(CONTENT_END_OFFSET_150 - 85)
        .padding({ left: this.breakPointStatemorePageMargin.value, right: this.breakPointStatemorePageMargin.value, bottom: this.breakPointStatemorePageMargin.value })

      }

    }.width('100%')
    .backgroundColor($r('app.color.background'))
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.SettingsPageInfos.clear();
      return true;
    })
  }
}