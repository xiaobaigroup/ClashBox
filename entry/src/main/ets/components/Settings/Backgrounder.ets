import { BreakpointState } from "../../common/breakpoint/breakpointsystem"
import TopBuilder from "./TopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { theRowCustomDialog, toggleRowList } from "../Common/Common"
import { UIConfig } from "../../entryability/AppState"
import { BusinessError } from "@kit.BasicServicesKit"
import { notificationManager } from "@kit.NotificationKit"
import { common } from "@kit.AbilityKit"
import { PageMargin } from "../../common/breakpoint/BreakPoint"

const context = getContext(this) as common.UIAbilityContext

@Component
struct Backgrounder {
  // UI控制变量
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 模拟播放控制变量
  @State isPlay: boolean = false
  // 模拟画中画控制变量
  @State isPiP: boolean = false
  // 模拟定位控制变量
  @State isLocate: boolean = false
  // 实验功能展示变量
  @Consume isShowExperimentalFunction: boolean
  // 模拟定位关闭提示弹窗标题
  @State theColsedDialogTitle: ResourceStr = $r('app.string.simulate_locate_closed_tips')
  // 模拟定位关闭提示弹窗内容文本
  @State closedContentText: ResourceStr = $r('app.string.simulate_locate_closed_content_text')
  // 模拟画中画启用提示弹窗标题
  @State theOpenDialogTitle: ResourceStr = $r('app.string.simulate_record_open_tips')
  // 模拟画中画启用提示弹窗内容文本
  @State openContentText: ResourceStr = $r('app.string.simulate_record_open_content_text')
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1

  /**
   * 关闭模拟定位提示弹窗控制器
   */
  closeDialogController: CustomDialogController = new CustomDialogController({
    builder: theRowCustomDialog({
      theDialogTitle: this.theColsedDialogTitle,
      contentText: this.closedContentText,
      cancel: ()=> { this.oncloseCancel() },
      confirm: ()=> { this.oncloseAccept() },
      leftButton: this.closedBuilder
    }),
  })
  /**
   * 模拟定位关闭提示弹窗左按钮
   */
  @Builder
  closedBuilder() {
    Button($r('app.string.close'))
      .backgroundColor($r('app.color.container_background'))
      .width('100%')
      .height(39)
      .fontColor(Color.Red)
  }
  // 模拟定位关闭提示弹窗-取消
  async oncloseCancel() {
    // 将模拟定位设置为 true
    this.isLocate = true
  }
  // 模拟定位关闭提示弹窗-关闭
  oncloseAccept() {
    // 将模拟定位设置为 false
    this.isLocate = false
    hilog.info(0xFF00, "BackgrounderSwitchtestTag", "模拟定位设置为: %{public}s", this.isLocate)
    // 关闭模拟定位逻辑处理
    hilog.info(0xFF00, "BackgroundertestTag", "模拟定位正在关闭")
    this.onCloseDown()
  }

  /**
   * 启用模拟模拟画中画提示弹窗控制器
   */
  openDialogController: CustomDialogController = new CustomDialogController({
    builder: theRowCustomDialog({
      theDialogTitle: this.theOpenDialogTitle,
      contentText: this.openContentText,
      cancel: ()=> { this.onopenCancel() },
      confirm: ()=> { this.onopenAccept() }
    }),
  })
  // 模拟画中画启用提示弹窗-取消
  onopenCancel() {
    // 将模拟画中画设置为 false
    this.isPiP = false
    hilog.info(0xFF00, "BackgrounderSwitchtestTag", "模拟画中画设置为: %{public}s", this.isPiP)
  }
  // 模拟画中画启用提示弹窗-启用
  onopenAccept() {
    // 将模拟画中画设置为 true
    this.isPiP = true
    // 关闭其它两个模拟
    if(this.isLocate) {
      // 关闭模拟定位
      this.oncloseAccept()
    } else if (this.isPlay) {
      // 关闭模拟播放
      this.isPlay = false
    }
    // 启用模拟画中画逻辑处理
    hilog.info(0xFF00, "BackgroundertestTag", "模拟画中画正在开启")
  }

  toDialogController: CustomDialogController = new CustomDialogController({
    builder: theRowCustomDialog({
      theDialogTitle: $r('app.string.notice_request_to_settings'),
      contentText: $r('app.string.notice_request_to_settings_text'),
      cancel: ()=> {
        this.uiConfig.Enablednotice = false
        this.isLocate = false
      },
      confirm: ()=> {
        this.handleToSettings()
      },
      leftButton: this.toBuilder
    }),
  })

  @Builder
  toBuilder() {
    Button($r('app.string.to'))
      .backgroundColor($r('app.color.container_background'))
      .width('100%')
      .height(39)
      .fontColor(this.icon_emphasize)
  }

  /**
   * 启用模拟定位
   */
  onOpenDown() {
    this.uiConfig.backgroundLocateModel = true
  }
  /**
   * 关闭模拟定位
   */
  onCloseDown() {
    this.uiConfig.backgroundLocateModel = false
  }
  /**
   * 启用模拟画中画
   */
  onOpenPlay() {
    this.uiConfig.backgroundPiPModel = true
  }
  /**
   * 关闭模拟画中画
   */
  onClosePlay() {
    this.uiConfig.backgroundPiPModel = false
  }
  /**
   * 启用模拟录音
   */
  onOpenRecord() {

  }
  /**
   * 关闭模拟录音
   */
  onCloseRecord() {

  }

  aboutToAppear(): void {
    // 初始化开关状态
    this.isLocate = this.uiConfig.backgroundLocateModel
    this.isPiP = this.uiConfig.backgroundPiPModel
  }

  aboutToDisappear(): void {
    // 改变后台运行全局变量的状态
    if(this.uiConfig.backgroundLocateModel || this.isPlay || this.isPiP || this.isLocate) {
      this.uiConfig.Enablebackgrounder = true
    } else {
      this.uiConfig.Enablebackgrounder = false
    }
    // 持久化开关状态
    this.uiConfig.backgroundLocateModel = this.isLocate
    this.uiConfig.backgroundPiPModel = this.isPiP
  }

  async noticePermission() {
    try {
      // 先获取最新权限状态
      const currentStatus = await notificationManager.isNotificationEnabled()
      if (currentStatus) {
        // 已有权限时通知开关启用或关闭
        // 显示通知设置 显式动画
        this.getUIContext()?.animateTo({
          duration: this.uiConfig.animationSpeed,
        }, () => {
          this.isLocate = true
          this.uiConfig.Enablednotice = true
        })

      } else {
        // 没有授权时
        this.uiConfig.Enablednotice = false
        if (!this.uiConfig.isRequestNotification) {
          // 首次请求权限
          try {
            await notificationManager.requestEnableNotification(context)
            this.uiConfig.isRequestNotification = true
            // 显示通知设置 显式动画
            this.getUIContext()?.animateTo({
              duration: this.uiConfig.animationSpeed,
            }, () => {
              this.isLocate = true
              this.uiConfig.Enablednotice = true
            })
          } catch (err) {
            if ((err as BusinessError).code === 1600004) {
              hilog.error(0xFF00, "BackgrounderSwitchtestTag",'用户拒绝授权')
              this.uiConfig.Enablednotice = false
              this.isLocate = false
              this.uiConfig.isRequestNotification = true
            }
          }
        } else {
          // 已请求过权限且通知开关,模拟定位开关均未启用，进入跳转设置
          if(!this.uiConfig.Enablednotice) {
            this.toDialogController.open()
          }
        }
      }
    } catch (err) {
      hilog.error(0xFF00, "BackgrounderSwitchtestTag", `Toggle Error: ${(err as BusinessError).code}, ${(err as BusinessError).message}`);
    }
  }

  /**
   *  跳转至设置界面开启通知权限
   */
  handleToSettings() {
    context.startAbility({
      bundleName: 'com.huawei.hmos.settings', // 系统设置界面的包名 （固定）
      abilityName: 'com.huawei.hmos.settings.MainAbility', // 系统设置的Ability的名字（固定）
      uri: "application_info_entry", // 系统设置的界面 （固定）
      parameters: {
        // pushParams: 'org.xbgroup.clashbox' // 包名
        pushParams: "org.xbgroup.clashboxb",
      }
    })
  }

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Backgrounder')})
      Column({space: 10}) {
        // 模拟定位
        Row() {
          toggleRowList({
            icons: $r('sys.symbol.compass_circle'),
            title: $r('app.string.simulate_locate'),
            subtitle: $r('app.string.simulate_locate_subtitle')
          }) {
            Toggle({ type: ToggleType.Switch, isOn: $$this.isLocate })
              .selectedColor(this.icon_emphasize)
              .margin({right: 12})
              .hitTestBehavior(HitTestMode.None)
          }
        }.onClick(() => {
          if(this.isLocate) {
            // 打开模拟定位关闭提示弹窗
            if(!this.isPlay && !this.isPiP) {
              this.closeDialogController.open()
            }
          } else {
            // 关闭其它两个模拟并开启模拟定位
            this.isPlay = false
            this.isPiP = false
            this.noticePermission()
          }
        })
        // 模拟画中画
        Row() {
          toggleRowList({
            icons: $r('sys.symbol.media_center'),
            title: $r('app.string.simulate_pip'),
            subtitle: $r('app.string.simulate_pip_subtitle'),
          }) {
            Toggle({ type: ToggleType.Switch, isOn: $$this.isPiP })
              .selectedColor(this.icon_emphasize)
              .margin({right: 12})
              .hitTestBehavior(HitTestMode.None)
          }
        }.onClick(() => {
          if(this.isPiP) {
            // 关闭模拟画中画
            this.isPiP= false
          } else {
            // 关闭其它两个模拟并开启模拟画中画
            this.isLocate = false
            this.isPlay = false
            // 打开模拟画中画启用提示弹窗
            this.openDialogController.open()
          }
        })
        if(this.isShowExperimentalFunction) {
          /*// 模拟播放
          Row() {
            toggleRowList({
              icons: $r('sys.symbol.mic_circle'),
              title: $r('app.string.simulate_record'),
              subtitle: $r('app.string.simulate_record_subtitle'),
              isExperimentalFunction: true
            }) {
              Toggle({ type: ToggleType.Switch, isOn: $$this.isPlay })
                .selectedColor(this.icon_emphasize)
                .margin({right: 12})
                .hitTestBehavior(HitTestMode.None)
            }
          }.onClick(() => {
            if(this.isPiP) {
              // 模拟播放关闭
              this.isPiP = false
            } else {
              // 打开模拟播放启用提示弹窗
              this.openDialogController.open()
            }
          })*/
        }
        // 提示
        Text($r('app.string.backgrounder_tips_2'))
          .fontWeight(FontWeight.Normal)
          .fontSize(15)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.SettingsPageInfos.clear();
      return true;
    })
  }



}
export default Backgrounder
