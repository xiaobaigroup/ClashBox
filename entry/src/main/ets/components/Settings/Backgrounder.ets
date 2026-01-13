
import TopBuilder from "./TopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { theRowCustomDialog, toggleRowList } from "../Common/Common"
import { UIConfig } from "../../entryability/AppState"
import { BusinessError } from "@kit.BasicServicesKit"
import { notificationManager } from "@kit.NotificationKit"
import { common } from "@kit.AbilityKit"
import { PageMargin } from "../../common/breakpoint/BreakPoint"
import { deviceInfo } from '@kit.BasicServicesKit';

@Component
struct Backgrounder {
  // UI控制变量
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 模拟下载控制变量
  @State @Watch('onBackgroundValueChange') isDown: boolean = false
  // 模拟画中画控制变量
  @State @Watch('onBackgroundValueChange') isPiP: boolean = false
  // 模拟定位控制变量
  @State @Watch('onBackgroundValueChange') isLocate: boolean = false
  // 后台保持控制变量
  @State @Watch('onBackgroundValueChange') isKeepTask: boolean = false
  // 模拟定位关闭提示弹窗标题
  @State theColsedDialogTitle: ResourceStr = $r('app.string.simulate_locate_closed_tips')
  // 模拟定位关闭提示弹窗内容文本
  @State closedContentText: ResourceStr = $r('app.string.simulate_locate_closed_content_text')
  // 模拟启用提示弹窗标题
  @State theOpenDialogTitle: ResourceStr = $r('app.string.simulate_down_open_tips')
  // 模拟画中画启用提示弹窗内容文本
  @State openContentText: ResourceStr = $r('app.string.simulate_down_open_content_text')
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1

  private context = this.getUIContext().getHostContext()! as common.UIAbilityContext

  build() {
    NavDestination() {
      TopBuilder({
        title: $r('app.string.Backgrounder'),
        pathStack: this.SettingsPageInfos
      })
      List({space: 10}) {
        // 任务保持
        if (deviceInfo.deviceType === 'tablet' || deviceInfo.deviceType === '2in1') {
          ListItem() {
            Row() {
              toggleRowList({
                icons: $r('sys.symbol.lock_filled_arrow_counterclockwise'),
                title: $r('app.string.keep_task'),
              }) {
                Toggle({ type: ToggleType.Switch, isOn: $$this.isKeepTask })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .hitTestBehavior(HitTestMode.None)
              }
            }
          }
          .onClick(() => {
            // 开启任务保持并关闭模拟定位
            this.isKeepTask = !this.isKeepTask
            if (this.isKeepTask) {
              this.isLocate = false
            }
          })
        }
        // 模拟定位
        ListItem() {
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
          }
        }.onClick(() => {
          if(this.isLocate) {
            // 打开模拟定位关闭提示弹窗
            if(!this.isDown && !this.isDown) {
              this.closeDialogController.open()
            }
          } else {
            // 关闭模拟下载并开启模拟定位
            this.isDown = false
            this.isKeepTask = false
            this.noticePermission('locate')
          }
        })
        // 模拟画中画
        ListItem() {
          Row() {
            toggleRowList({
              icons: $r('sys.symbol.media_center'),
              title: $r('app.string.simulate_pip'),
              subtitle: $r('app.string.simulate_pip_subtitle'),
            }) {
              Toggle({ type: ToggleType.Switch, isOn: $$this.isPiP })
                .selectedColor(this.icon_emphasize)
                .hitTestBehavior(HitTestMode.None)
                .margin({right: 12})
            }
          }
        }.onClick(() => {
          if (this.isPiP) {
            // 关闭模拟画中画
            this.isPiP = false
          } else {
            this.isPiP = true
          }
        })
        // 模拟下载
        ListItem() {
          Row() {
            toggleRowList({
              icons: $r('sys.symbol.circle_and_arrow_down'),
              title: $r('app.string.simulate_down'),
              subtitle: $r('app.string.simulate_down_subtitle'),
            }) {
              Toggle({ type: ToggleType.Switch, isOn: $$this.isDown })
                .selectedColor(this.icon_emphasize)
                .hitTestBehavior(HitTestMode.None)
                .margin({right: 12})
            }
          }
        }.onClick(() => {
          if(this.isDown) {
            // 模拟下载关闭
            this.isDown = false
          } else {
            // 打开模拟下载启用提示弹窗
            this.openDialogController.open()
          }
        })
        // 提示
        ListItem() {
          Text() {
            Span($r('app.string.backgrounder_tips'))
            Span($r('app.string.backgrounder_tips_3'))
            if (deviceInfo.deviceType === 'tablet' || deviceInfo.deviceType === '2in1') {
              Span($r('app.string.backgrounder_tips_2'))
            }
          }
          .fontWeight(FontWeight.Normal)
          .fontSize(15)
        }
      }
      .width('100%')
      .contentEndOffset(72)
      .alignListItem(ListItemAlign.Center)
      .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.SettingsPageInfos.clear();
      return true;
    })
  }

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
  oncloseCancel() {
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
    this.uiConfig.backgroundLocateModel = false
  }

  /**
   * 启用模拟模拟下载提示弹窗控制器
   */
  openDialogController: CustomDialogController = new CustomDialogController({
    builder: theRowCustomDialog({
      theDialogTitle: this.theOpenDialogTitle,
      contentText: this.openContentText,
      cancel: ()=> { this.onopenCancel() },
      confirm: ()=> { this.onopenAccept() }
    }),
  })
  // 模拟下载启用提示弹窗-取消
  onopenCancel() {
    // 将模拟下载设置为 false
    this.isDown = false
    hilog.info(0xFF00, "BackgrounderSwitchtestTag", "模拟下载设置为: %{public}s", this.isDown)
  }
  // 模拟下载启用提示弹窗-启用
  onopenAccept() {
    // 关闭其它两个模拟
    if(this.isLocate) {
      // 关闭模拟定位
      this.oncloseAccept()
    }
    hilog.info(0xFF00, "BackgroundertestTag", "模拟下载正在开启")
    this.noticePermission('down')
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


  aboutToAppear(): void {
    // 初始化开关状态
    this.isLocate = this.uiConfig.backgroundLocateModel
    this.isKeepTask = this.uiConfig.backgroundKeepTask
    this.isDown = this.uiConfig.backgroundDownModel
    this.isPiP = this.uiConfig.backgroundPiPModel
  }

  aboutToDisappear(): void {
    this.onBackgroundValueChange()
  }

  onBackgroundValueChange() {
    // 持久化开关状态
    this.uiConfig.backgroundLocateModel = this.isLocate
    this.uiConfig.backgroundKeepTask = this.isKeepTask
    this.uiConfig.backgroundDownModel = this.isDown
    this.uiConfig.backgroundPiPModel = this.isPiP
    // 改变后台运行全局变量的状态
    if(this.isKeepTask || this.isDown || this.isPiP || this.isLocate) {
      this.uiConfig.Enablebackgrounder = true
    } else {
      this.uiConfig.Enablebackgrounder = false
    }
  }

  async noticePermission(id: 'down' | 'locate') {
    try {
      // 先获取最新权限状态
      const currentStatus = await notificationManager.isNotificationEnabled()
      if (currentStatus) {
        // 已有权限时通知开关启用或关闭
        // 显示通知设置 显式动画
        this.getUIContext()?.animateTo({
          duration: this.uiConfig.animationSpeed,
        }, () => {
          if (!this.isLocate && id === 'locate') {
            this.isLocate = true
          }
          if (!this.isDown && id === 'down') {
            this.isDown = true
          }
          this.uiConfig.Enablednotice = true
        })

      } else {
        // 没有授权时
        this.uiConfig.Enablednotice = false
        if (!this.uiConfig.isRequestNotification) {
          // 首次请求权限
          try {
            await notificationManager.requestEnableNotification(this.context)
            this.uiConfig.isRequestNotification = true
            // 显示通知设置 显式动画
            this.getUIContext()?.animateTo({
              duration: this.uiConfig.animationSpeed,
            }, () => {
              if (!this.isLocate && id === 'locate') {
                this.isLocate = true
              }
              if (!this.isDown && id === 'down') {
                this.isDown = true
              }
              this.uiConfig.Enablednotice = true
            })
          } catch (err) {
            if ((err as BusinessError).code === 1600004) {
              hilog.error(0xFF00, "BackgrounderSwitchtestTag",'用户拒绝授权')
              this.uiConfig.Enablednotice = false
              this.isLocate = false
              this.isDown = false
              this.uiConfig.isRequestNotification = true
            }
          }
        } else {
          // 已请求过权限且通知开关,模拟定位、模拟下载开关均未启用，进入跳转设置
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
    this.context.startAbility({
      bundleName: 'com.huawei.hmos.settings', // 系统设置界面的包名 （固定）
      abilityName: 'com.huawei.hmos.settings.MainAbility', // 系统设置的Ability的名字（固定）
      uri: "application_info_entry", // 系统设置的界面 （固定）
      parameters: {
        pushParams: this.context.applicationInfo.name // 包名
      }
    }).catch((err: BusinessError) => {
      console.error(`跳转至设置失败, code：${err.code} message: ${err.message}`)
    })
  }

}
export default Backgrounder
