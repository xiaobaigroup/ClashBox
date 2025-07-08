import { BreakpointState } from "../../common/breakpoint/breakpointsystem"
import {
  FONT_SIZE_14,
  FONT_SIZE_16,
  LIST_ITEM_HEIGHT_45,
  LIST_ITEM_HEIGHT,
  BORDER_RADIUS_20,
  CONTENT_END_OFFSET_150} from "../../common/entity/Constants"
import { getResourceString } from "../../common/utils/ResourceStringUtil"
import TopBuilder from "./TopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { customVibrator } from "../../common/utils/VibratorUtil"
import { customSound } from "../../common/utils/SoundPoolUtil"
import { promptAction } from "@kit.ArkUI"
import { ExperimentalFunction, theRowCustomDialog, toggleRowList } from "../Common/Common"
import { UIConfig } from "../../entryability/AppState"
import { notificationManager } from '@kit.NotificationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit'
import { customAnimationUtil } from "../../common/utils/Animation"
import { PageMargin } from "../../common/breakpoint/BreakPoint"

const TAG: string = '[通知页]';
const DOMAIN_NUMBER: number = 0xFF00;
const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

/**
 * 通知页
 */
@Component
struct Notice {
  private componentName: string = 'Notice'
  // 设置页路由栈
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 流量提醒启用状态变量
  @Consume EnableCellularDataReminder: boolean
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // UI控制变量
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 常驻通知开关变量
  @State EnabledPermanentnotice: boolean = true
  // 时间提醒开关变量
  @State EnabledTimenotice: boolean = false
  // 通知权限跳转授权弹窗提示弹窗标题
  @State theToDialogTitle: ResourceStr = $r('app.string.notice_request_to_settings')
  @State currentNumber: number = 0
  private TimeUnitSelect: number = 1
  private TimeUnitFruits: string[] = [
    getResourceString($r('app.string.min'), this),
    getResourceString($r('app.string.hour'), this),
    getResourceString($r('app.string.day'), this)
  ]
  @State
  private heightOfTextPickerInTheListItem: number = LIST_ITEM_HEIGHT_45
  // ListItem里自动更新间隔`TextPicker`组件的`fontSize`
  @State
  private fontSizeOfTextPickerInTheListItem: number = FONT_SIZE_16
  // ListItem里自动更新间隔`TextPicker`组件的`fontWeight`
  @State
  private fontWeightOfTextPickerInTheListItem: FontWeight = FontWeight.Medium
  // ListItem里自动更新间隔`TextPicker`组件的分割线样式
  @State
  private dividerOfTextPickerInTheListItem: DividerOptions | null = null
  // ListItem里自动更新间隔`TextPicker`组件的每个选择项高度
  @State
  private itemHeightOfTextPickerInTheListItem: number = FONT_SIZE_16 * 1.5
  // ListItem里自动更新间隔`TextPicker`组件的渐隐效果
  @State
  private gradientHeightOfTextPickerInTheListItem: number = FONT_SIZE_16
  private context = getContext(this) as common.UIAbilityContext
  private isDeveloping: boolean = true

  toDialogController: CustomDialogController = new CustomDialogController({
    builder: theRowCustomDialog({
      theDialogTitle: this.theToDialogTitle,
      contentText: this.uiConfig.EnabledStatusNotice ? $r('app.string.status_bar_to') : $r('app.string.notice_request_to_settings_text'),
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onAccept() },
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

  aboutToAppear() {
    hilog.info(0xFF00, this.componentName, `#aboutToAppear executed`)
    if(this.uiConfig.isSound) {
      customSound.initSoundPool(3, 'beat_short.wav')
    }
  }

  aboutToDisappear(): void {
    hilog.info(0xFF00, this.componentName, `#aboutToDisappear executed`)
    customSound.destroySoundPool()
  }

  onPageShow(): void {
    hilog.debug(DOMAIN_NUMBER, TAG, '页面显示')
  }

  onCancel() {
    if (!this.uiConfig.EnabledStatusNotice) {
      this.uiConfig.Enablednotice = false
    }
  }
  onAccept() {
    this.handleToSettings()
  }

  /**
   * 通知启用操作
   */
  async EnabledNotification() {
    try {
      // 先获取最新权限状态
      const currentStatus = await notificationManager.isNotificationEnabled()
      if (currentStatus) {
        // 已有权限时通知开关启用或关闭
        // 显示通知设置 显式动画
        this.getUIContext()?.animateTo({
          duration: this.uiConfig.animationSpeed,
        }, () => {
          this.uiConfig.Enablednotice = !this.uiConfig.Enablednotice
        })

      } else {
        // 没有授权时
        if (!this.uiConfig.isRequestNotification) {
          // 首次请求权限
          try {
            await notificationManager.requestEnableNotification(this.context)
            this.uiConfig.isRequestNotification = true
            // 显示通知设置 显式动画
            this.getUIContext()?.animateTo({
              duration: this.uiConfig.animationSpeed,
            }, () => {
              this.uiConfig.Enablednotice = true
            })
          } catch (err) {
            if ((err as BusinessError).code === 1600004) {
              hilog.error(DOMAIN_NUMBER, TAG, '用户拒绝授权')
              this.uiConfig.Enablednotice = false
              this.uiConfig.isRequestNotification = true
            }
          }
        } else {
          // 已请求过权限且通知开关未启用，进入跳转设置
          if(!this.uiConfig.Enablednotice) {
            this.toDialogController.open()
          }
        }
      }
    } catch (err) {
      hilog.error(DOMAIN_NUMBER, TAG, `Toggle Error: ${(err as BusinessError).code}, ${(err as BusinessError).message}`);
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
        pushParams: context.applicationInfo.name,
      }
    })
  }


  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Notice')})
      Column({space: 10}) {
        // 反馈 Start
        Column() {
          // 震动反馈开关 Start
          Row() {
            toggleRowList({
              title: $r('app.string.vibrate_feedback'),
              icons: $r('sys.symbol.rectangle_portrait_wave_2')
            }) {
              // 震动反馈开关
              Toggle({ type: ToggleType.Switch, isOn: $$this.uiConfig.isVibrate })
                .selectedColor(this.icon_emphasize)
                .margin({right: 12})
                .hitTestBehavior(HitTestMode.None)
            }
          }
          .RowStyle()
          .onClick( ()=> {
            // 显示后台通知设置 显式动画
            this.getUIContext()?.animateTo({
              duration: this.uiConfig.animationSpeed,
            }, () => {
              this.uiConfig.isVibrate = !this.uiConfig.isVibrate
            })
          })
          // 震动反馈开关 End
          // 分割线
          Row().height(0.5).backgroundColor($r('app.color.divider')).width('93%')
          // 声音反馈开关 Start
          Row() {
            toggleRowList({
              title: $r('app.string.sound_feedback'),
              icons: $r('sys.symbol.bell_fill')
            }) {
              // 声音反馈开关
              Toggle({ type: ToggleType.Switch, isOn: $$this.uiConfig.isSound })
                .selectedColor(this.icon_emphasize)
                .margin({right: 12})
                .hitTestBehavior(HitTestMode.None)
            }
          }
          .RowStyle()
          .onClick( ()=> {
            // 显示后台通知设置 显式动画
            this.getUIContext()?.animateTo({
              duration: this.uiConfig.animationSpeed,
            }, () => {
              this.uiConfig.isSound = !this.uiConfig.isSound
            })
          })
          // 声音反馈开关 End
        }.ColumnStyle()
        // 反馈 End
        // 通知 Start
        Column() {
          // 通知总开关 Start
          Row() {
            toggleRowList({
              title: $r('app.string.notice_main_switch'),
              icons: $r('sys.symbol.message_on_message_fill')
            }) {
              Row() {
                // 通知总开关
                Toggle({ type: ToggleType.Switch, isOn: $$this.uiConfig.Enablednotice })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .hitTestBehavior(HitTestMode.None)
              }.onClick(() => {
                this.EnabledNotification()
              })
            }
          }
          .RowStyle()
          .onClick( ()=> {
            // 点击提示 防误触
            promptAction.showToast({message: $r('app.string.click_prompt'), duration: 2000 })
          })
          // 通知总开关 End
          if (this.uiConfig.Enablednotice) {
            // 分割线
            Row().height(0.5).backgroundColor($r('app.color.divider')).width('93%')
            // 常驻通知 Start
            Row() {
              toggleRowList({
                title: $r('app.string.background_notice'),
                icons: $r('sys.symbol.ellipsis_message_fill'),
                subtitle: $r('app.string.background_notice_subtitle')
              }) {
                // 常驻通知开关
                Toggle({ type: ToggleType.Switch, isOn: $$this.uiConfig.EnabledPermanentnotice })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .opacity(this.uiConfig.Enablebackgrounder ? 0.5 : 1)
                  .hitTestBehavior(this.uiConfig.Enablebackgrounder ? HitTestMode.None : HitTestMode.Default)
                  .onChange((isOn: boolean) => {
                    if(!this.uiConfig.Enablebackgrounder) {
                      // 显示后台通知设置 显式动画
                      this.getUIContext()?.animateTo({
                        duration: this.uiConfig.animationSpeed,
                        curve: Curve.Ease
                      }, () => {
                        this.uiConfig.EnabledPermanentnotice = isOn
                      })
                    }
                  })
              }
            }
            .RowStyle()
            .onClick( ()=> {
              if(!this.uiConfig.Enablebackgrounder) {
                // 点击提示
                promptAction.showToast({message: $r('app.string.click_prompt'), duration: 2000 })
              }
            })
            // 常驻通知 End
            // 常驻状态栏 Start
            Row() {
              toggleRowList({
                title: $r('app.string.status_icon_notice'),
                icons: $r('sys.symbol.star_circle_fill'),
                subtitle: $r('app.string.status_icon_tips')
              }) {
                // 常驻状态栏开关
                Toggle({ type: ToggleType.Switch, isOn: $$this.uiConfig.EnabledStatusNotice })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .opacity(1)
                  .hitTestBehavior(HitTestMode.Default)
                  .onChange((isOn: boolean) => {
                    // 显示后台通知设置 显式动画
                    this.getUIContext()?.animateTo({
                      duration: this.uiConfig.animationSpeed,
                      curve: Curve.Ease
                    }, () => {
                      this.uiConfig.EnabledStatusNotice = isOn
                      if (isOn) {
                        this.toDialogController.open()
                      }
                    })
                  })
              }
            }
            .RowStyle()
            .onClick( ()=> {
              // 点击提示
              promptAction.showToast({message: $r('app.string.click_prompt'), duration: 2000 })
            })
            // 常驻状态栏 End
          }
        }.ColumnStyle()
        // 通知 End
        if(this.uiConfig.Enablednotice) {
          // 常驻通知提醒 Start
          if(this.uiConfig.Enablebackgrounder) {
            Row() {
              Text($r('app.string.background_notice_tips'))
                .fontWeight(FontWeight.Normal)
                .fontSize(15)
            }.width('100%').justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center)
          }
          // 常驻通知提醒 End

         if (this.uiConfig.isShowExperimentalFunction) {
           // 流量提醒 Start
           Row() {
             toggleRowList({
               title: $r('app.string.cellular_data_reminder'),
               isExperimentalFunction: true,
               icons: $r('sys.symbol.mobiledata'),
               subtitle: $r('app.string.cellular_data_reminder_subtitle')
             }) {
               // 使用文本与箭头替换掉默认的开关
               Text(this.EnableCellularDataReminder ? $r('app.string.enabled') : $r('app.string.not_enabled'))
                 .fontWeight(FontWeight.Normal)
                 .margin({right: 4 })
                 .fontSize(14)
               SymbolGlyph($r('sys.symbol.chevron_right'))
                 .fontSize(28)
                 .fontColor([this.icon_primary])
                 .margin({right: 12})
             }
           }
           .RowStyle()
           .onClick( ()=> {
             // 点击跳转至流量提醒设置
             this.SettingsPageInfos.pushPathByName('CellularDataReminder', false)
           })
           // 流量提醒 End
           // 时间提醒与时间设置Column Start
           Column() {
             // 时间提醒行 Start
             Row() {
               toggleRowList({
                 title: $r('app.string.time_reminder'),
                 isExperimentalFunction: true,
                 icons: $r('sys.symbol.clock'),
                 subtitle: $r('app.string.time_reminder_subtitle')
               }) {
                 // 时间提醒开关
                 Toggle({ type: ToggleType.Switch, isOn: $$this.EnabledTimenotice })
                   .selectedColor(this.icon_emphasize)
                   .margin({right: 12})
                   .onChange((isOn: boolean) => {
                     // 逻辑处理 TODO 【用户首选项】保存时间提醒开关的启用状态 Ya@2024-12-26
                     // 展开提醒时间设置行 显式动画
                     this.getUIContext()?.animateTo({
                       duration: this.uiConfig.animationSpeed,
                       curve: Curve.Ease
                     }, () => {
                       this.EnabledTimenotice = isOn
                     })
                   })
               }
             }
             .RowStyle()
             // 时间提醒行 End
             // 提醒时间设置行 Start
             if (this.EnabledTimenotice) {
               // 分割线
               Row().height(0.5).backgroundColor('#0D000000').width('93%')
               // 提醒时间设置行
               Row() {
                 SymbolGlyph($r('sys.symbol.stopwatch_2'))
                   .fontSize(24)
                   .margin({left: 12})
                   .fontColor([this.icon_emphasize])
                 Text($r('app.string.reminder_time'))
                   .fontWeight(FontWeight.Medium)
                   .margin({ left: 12 })
                   .fontSize(16)
                 // 实验功能提示框
                 if(this.uiConfig.isShowExperimentalFunction) {
                   ExperimentalFunction()
                 }
                 Blank()
                 TextInput({placeholder: $r('app.string.text_input_placeholder'), text: $$this.currentNumber})
                   .TextInputStyle()
                   .caretColor(this.icon_emphasize)
                   .borderColor({bottom: this.icon_emphasize})
                   .onSubmit( (enterKey: EnterKeyType, event: SubmitEvent) => {
                     if (this.uiConfig.isVibrate) {
                       customVibrator.vibratorTriggerOfHapticClockTimer()
                     }
                   })
                 TextPicker({range: this.TimeUnitFruits, selected: $$this.TimeUnitSelect})
                   .canLoop(false)
                   .width(60)
                   .height(this.heightOfTextPickerInTheListItem)
                   .defaultPickerItemHeight(this.itemHeightOfTextPickerInTheListItem)
                   .gradientHeight(this.gradientHeightOfTextPickerInTheListItem)
                   .selectedTextStyle({
                     color: this.icon_emphasize,
                     font: {
                       size: this.fontSizeOfTextPickerInTheListItem,
                       weight: this.fontWeightOfTextPickerInTheListItem
                     }
                   })
                   .divider(this.dividerOfTextPickerInTheListItem)
                     // 手指触摸动态改变`TextPicker`和所在`Row`的样式
                   .onTouch((event: TouchEvent) => {
                     let ctx = this.getUIContext()
                     if (event.type === TouchType.Down) {
                       ctx.animateTo({
                         duration: this.uiConfig.animationSpeed,
                         curve: Curve.Ease
                       }, () => {
                         this.heightOfTextPickerInTheListItem = 100
                         this.fontSizeOfTextPickerInTheListItem = FONT_SIZE_16 * 1.5
                         this.fontWeightOfTextPickerInTheListItem = FontWeight.Bold
                         this.dividerOfTextPickerInTheListItem = {
                           strokeWidth: 1,
                           startMargin: 5,
                           endMargin: 5,
                           color: this.icon_emphasize
                         }
                         this.itemHeightOfTextPickerInTheListItem = FONT_SIZE_16 * 2
                         this.gradientHeightOfTextPickerInTheListItem = FONT_SIZE_16 * 2
                       })
                     } else if (event.type === TouchType.Up){
                       ctx.animateTo({
                         duration: this.uiConfig.animationSpeed,
                         curve: Curve.Ease
                       }, () => {
                         this.heightOfTextPickerInTheListItem = LIST_ITEM_HEIGHT
                         this.fontSizeOfTextPickerInTheListItem = FONT_SIZE_16
                         this.fontWeightOfTextPickerInTheListItem = FontWeight.Medium
                         this.dividerOfTextPickerInTheListItem = null
                         this.itemHeightOfTextPickerInTheListItem = FONT_SIZE_16 * 1.5
                         this.gradientHeightOfTextPickerInTheListItem = FONT_SIZE_16
                       })
                     }
                   })
                   .onChange((value: string | string[], index: number | number[]) => {
                     // 震动和声音反馈
                     if (this.uiConfig.isVibrate) {
                       customVibrator.vibratorTriggerOfHapticClockTimer()
                     }
                     if(this.uiConfig.isSound) {
                       customSound.playAudioForSoundPool()
                     }
                     hilog.info(0xFF00, "NoticetestTag", "选择的时间单位为: %{public}s", JSON.stringify(value))
                     hilog.info(0xFF00, "NoticetestTag", "选择的时间单位index: %{public}s", JSON.stringify(index))
                     hilog.info(0xFF00, "NoticetestTag", "当前输入为: %{public}s", this.currentNumber)
                     // TODO 待实现时间提醒功能，this.currentNumber为输入框输入数字，index为单位选择器对应角标，具体对应单位参照this.TimeUnitFruits

                   })
               }
               .width('100%')
               .height(this.heightOfTextPickerInTheListItem)
               .borderRadius(BORDER_RADIUS_20)
               .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
               .animation({ duration: this.uiConfig.animationSpeed, curve: Curve.Ease })
             }
             // 提醒时间设置行 End
           }
           .ColumnStyle()
           .onClick( ()=> {
             if (!this.EnabledTimenotice) {
               // 展开提醒时间设置行 显式动画
               this.getUIContext()?.animateTo({
                 duration: this.uiConfig.animationSpeed
               }, () => {
                 this.EnabledTimenotice = !this.EnabledTimenotice
               })
             }
           })
           // 时间提醒与时间设置Column End
         }

        }
        // 常驻通知&流量提醒&时间提醒 End
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
export default Notice

/**
 * 流量提醒页
 */
@Component
export struct CellularDataReminder {
  // 流量提醒启用状态变量
  @Consume EnableCellularDataReminder: boolean
  // 设置页路由表
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 每小时通知控制变量
  @State perHourNotice: boolean = false
  @State theHourNumber: number = 0
  // 每天通知控制变量
  @State perDayNotice: boolean = false
  @State theDayNumber: number = 0
  // 每周通知控制变量
  @State perWeekNotice: boolean = false
  @State theWeekNumber: number = 0
  // 每月通知控制变量
  @State perMonthNotice: boolean = false
  @State theMonthNumber: number = 0
  // 总量通知控制变量
  @State totalDataNotice: boolean = false
  @State theTotalNumber: number = 0
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Notice'), subtitle: $r('app.string.cellular_data_reminder')})
      List() {
        // 流量提醒总开关行
        ListItem() {
          Row() {
            toggleRowList({
              title: $r('app.string.cellular_data_reminder'),
              icons: $r('sys.symbol.mobiledata'),
              subtitle: $r('app.string.cellular_data_reminder_subtitle')
            }) {
              // 流量提醒总开关  TODO 【用户首选项】保存通知页的流量提醒开关启用状态 Ya@2024-12-26
              Toggle({ type: ToggleType.Switch, isOn: $$this.EnableCellularDataReminder })
                .selectedColor(this.icon_emphasize)
                .margin({right: 12})
                .onChange((isOn: boolean) => {
                  // 展开流量提醒设置列表行 显式动画
                  this.getUIContext()?.animateTo({
                    duration: this.uiConfig.animationSpeed,
                    curve: Curve.Ease
                  }, () => {
                    this.EnableCellularDataReminder = isOn
                  })
                })
            }
          }
          .RowStyle()
          .margin({bottom: 10})
          .onClick( ()=> {
            // 展开流量提醒设置列表行 显式动画
            this.getUIContext()?.animateTo({
              duration: this.uiConfig.animationSpeed
            }, () => {
              this.EnableCellularDataReminder = !this.EnableCellularDataReminder
            })
          })
        }
        if(this.EnableCellularDataReminder) {
          // 每小时通知
          ListItem() {
            Column() {
              toggleRowList({
                title: $r('app.string.per_hour_notice'),
                subtitle: $r('app.string.per_hour_notice_subtitle')
              }) {
                // 每小时通知开关
                Toggle({ type: ToggleType.Switch, isOn: $$this.perHourNotice })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .onChange((isOn: boolean) => {
                    // 展开每小时通知流量设置行 显式动画
                    this.getUIContext()?.animateTo({
                      duration: this.uiConfig.animationSpeed,
                      curve: Curve.Ease
                    }, () => {
                      this.perHourNotice = isOn
                    })
                  })
              }
              if(this.perHourNotice) {
                // 分割线
                Row().height(0.5).backgroundColor('#0D000000').width('93%')
                noticeInputRow() {
                  // 每小时通知阈值输入框 TODO 待实现时间提醒的每小时通知功能，this.theHourNumber为输入框输入数字
                  TextInput({placeholder: $r('app.string.text_input_placeholder'), text: $$this.theHourNumber})
                    .TextInputStyle()
                    .borderColor(this.icon_emphasize)
                    .onChange(() => {
                      // 测试用
                      hilog.info(0xFF00, "NoticeReminderTag", "当前每小时行输入为: %{public}s", this.theHourNumber)
                    })
                }
              }
            }
            .ColumnStyle()
            .margin({bottom: 10})
            .onClick( ()=> {
              if (!this.perHourNotice) {
                // 展开每小时通知流量设置行 显式动画
                this.getUIContext()?.animateTo({
                  duration: this.uiConfig.animationSpeed
                }, () => {
                  this.perHourNotice = !this.perHourNotice
                })
              }
            })
          }
          // 每日通知
          ListItem() {
            Column() {
              toggleRowList({
                title: $r('app.string.per_day_notice'),
                subtitle: $r('app.string.per_day_notice_subtitle')
              }) {
                // 每日通知开关
                Toggle({ type: ToggleType.Switch, isOn: $$this.perDayNotice })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .onChange((isOn: boolean) => {
                    // 展开每日通知流量设置行 显式动画
                    this.getUIContext()?.animateTo({
                      duration: this.uiConfig.animationSpeed,
                      curve: Curve.Ease
                    }, () => {
                      this.perDayNotice = isOn
                    })
                  })
              }
              if(this.perDayNotice) {
                // 分割线
                Row().height(0.5).backgroundColor('#0D000000').width('93%')
                noticeInputRow() {
                  // 每天通知阈值输入框 TODO 待实现时间提醒的每日通知功能，this.theDayNumber为输入框输入数字
                  TextInput({placeholder: $r('app.string.text_input_placeholder'), text: $$this.theDayNumber})
                    .TextInputStyle()
                    .borderColor(this.icon_emphasize)
                    .onChange(() => {
                      // 测试用
                      hilog.info(0xFF00, "NoticeReminderTag", "当前每日行输入为: %{public}s", this.theDayNumber)
                    })
                }
              }
            }
            .ColumnStyle()
            .margin({bottom: 10})
            .onClick( ()=> {
              if (!this.perDayNotice) {
                // 展开每日通知流量设置行 显式动画
                this.getUIContext()?.animateTo({
                  duration: this.uiConfig.animationSpeed
                }, () => {
                  this.perDayNotice = !this.perDayNotice
                })
              }
            })
          }
          // 每周通知
          ListItem() {
            Column() {
              toggleRowList({
                title: $r('app.string.per_week_notice'),
                subtitle: $r('app.string.per_week_notice_subtitle')
              }) {
                // 每周通知开关
                Toggle({ type: ToggleType.Switch, isOn: $$this.perWeekNotice })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .onChange((isOn: boolean) => {
                    // 展开每周通知流量设置行 显式动画
                    this.getUIContext()?.animateTo({
                      duration: this.uiConfig.animationSpeed,
                      curve: Curve.Ease
                    }, () => {
                      this.perWeekNotice = isOn
                    })
                  })
              }
              if(this.perWeekNotice) {
                // 分割线
                Row().height(0.5).backgroundColor('#0D000000').width('93%')
                noticeInputRow() {
                  // 每周通知阈值输入框 TODO 待实现时间提醒的每周通知功能，this.theWeekNumber为输入框输入数字
                  TextInput({placeholder: $r('app.string.text_input_placeholder'), text: $$this.theWeekNumber})
                    .TextInputStyle()
                    .borderColor(this.icon_emphasize)
                    .onChange(() => {
                      // 测试用
                      hilog.info(0xFF00, "NoticeReminderTag", "当前每星期行输入为: %{public}s", this.theWeekNumber)
                    })
                }
              }
            }
            .ColumnStyle()
            .margin({bottom: 10})
            .onClick( ()=> {
              if (!this.perWeekNotice) {
                // 展开每周通知流量设置行 显式动画
                this.getUIContext()?.animateTo({
                  duration: this.uiConfig.animationSpeed
                }, () => {
                  this.perWeekNotice = !this.perWeekNotice
                })
              }
            })
          }
          // 每月通知
          ListItem() {
            Column() {
              toggleRowList({
                title: $r('app.string.per_month_notice'),
                subtitle: $r('app.string.per_month_notice_subtitle')
              }) {
                // 每月通知开关
                Toggle({ type: ToggleType.Switch, isOn: $$this.perMonthNotice })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .onChange((isOn: boolean) => {
                    // 展开每月通知流量设置行 显式动画
                    this.getUIContext()?.animateTo({
                      duration: this.uiConfig.animationSpeed,
                      curve: Curve.Ease
                    }, () => {
                      this.perMonthNotice = isOn
                    })
                  })
              }
              if(this.perMonthNotice) {
                // 分割线
                Row().height(0.5).backgroundColor('#0D000000').width('93%')
                noticeInputRow() {
                  // 每月通知阈值输入框 TODO 待实现时间提醒的每月通知功能，this.theMonthNumber为输入框输入数字
                  TextInput({placeholder: $r('app.string.text_input_placeholder'), text: $$this.theMonthNumber})
                    .TextInputStyle()
                    .borderColor(this.icon_emphasize)
                    .onChange(() => {
                      // 测试用
                      hilog.info(0xFF00, "NoticeReminderTag", "当前每月行输入为: %{public}s", this.theMonthNumber)
                    })
                }
              }
            }
            .ColumnStyle()
            .margin({bottom: 10})
            .onClick( ()=> {
              if (!this.perMonthNotice) {
                // 展开每月通知流量设置行 显式动画
                this.getUIContext()?.animateTo({
                  duration: this.uiConfig.animationSpeed
                }, () => {
                  this.perMonthNotice = !this.perMonthNotice
                })
              }
            })
          }
          // 总量通知
          ListItem() {
            Column() {
              toggleRowList({
                title: $r('app.string.total_data_notice'),
                subtitle: $r('app.string.total_data_notice_subtitle')
              }) {
                // 总量通知开关
                Toggle({ type: ToggleType.Switch, isOn: $$this.totalDataNotice })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .onChange((isOn: boolean) => {
                    // 展开总量通知流量设置行 显式动画
                    this.getUIContext()?.animateTo({
                      duration: this.uiConfig.animationSpeed,
                      curve: Curve.Ease
                    }, () => {
                      this.totalDataNotice = isOn
                    })
                  })
              }
              if(this.totalDataNotice) {
                // 分割线
                Row().height(0.5).backgroundColor('#0D000000').width('93%')
                noticeInputRow() {
                  // 总量通知阈值输入框 TODO 待实现时间提醒的总量通知功能，this.theTotalNumber为输入框输入数字
                  TextInput({placeholder: $r('app.string.text_input_placeholder'), text: $$this.theTotalNumber})
                    .TextInputStyle()
                    .borderColor(this.icon_emphasize)
                    .expandSafeArea([SafeAreaType.KEYBOARD, SafeAreaType.SYSTEM])
                    .onChange(() => {
                      // 测试用
                      hilog.info(0xFF00, "NoticeReminderTag", "当前总量输入为: %{public}s", this.theTotalNumber)
                    })
                }
              }
            }
            .ColumnStyle()
            .margin({bottom: 10})
            .onClick( ()=> {
              if (!this.totalDataNotice) {
                // 展开总量通知流量设置行 显式动画
                this.getUIContext()?.animateTo({
                  duration: this.uiConfig.animationSpeed
                }, () => {
                  this.totalDataNotice = !this.totalDataNotice
                })
              }
            })
          }
        }

      }
      .width('100%')
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
      .contentEndOffset(CONTENT_END_OFFSET_150 - 85)
      .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
    }
    .width('100%')
    .hideTitleBar(true)
    //.hideToolBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.SettingsPageInfos.pop(true)
      return true
    })
  }
}

/**
 * 列表Row共有样式
 */
@Extend(Row)
function RowStyle() {
  .width('100%')
  .height(53)
  .borderRadius(20)
  .backgroundColor($r('app.color.container_background'))
}
/**
 * 列表Column共有样式
 */
@Extend(Column)
function ColumnStyle() {
  .width('100%')
  .borderRadius(20)
  .backgroundColor($r('app.color.container_background'))
}
/**
 * 列表TextInput共有样式
 */
@Extend(TextInput)
function TextInputStyle() {
  .width(50)
  .height(30)
  .padding(0)
  .maxLength(5)
  .borderRadius(0)
  .type(InputType.Number)
  .fontSize(FONT_SIZE_16)
  .lineHeight(FONT_SIZE_16)
  .textAlign(TextAlign.Center)
  .enterKeyType(EnterKeyType.Done)
  .backgroundColor(Color.Transparent)
  .placeholderFont({size: FONT_SIZE_14})
  .fontColor($r('sys.color.font_secondary'))
  .border({
    width: {  bottom: 1 },
    style: { top: null, right: null, bottom: BorderStyle.Solid, left: null}
  })
}



/**
 * 通知阈值输入行
 */
@Component
struct noticeInputRow {
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 通知开关
  @BuilderParam noticeTextInput: () => void = this.defaultBuilder
  // 默认开关
  @Builder
  defaultBuilder() {
    TextInput({placeholder: $r('app.string.text_input_placeholder'), text: ''})
      .TextInputStyle()
      .borderColor(this.icon_emphasize)
  }

  build() {
    Row() {
      Column() {
        Text($r('app.string.threshold_data'))
          .fontWeight(FontWeight.Medium)
          .fontSize(16)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      Blank()
      this.noticeTextInput()
      Text('GB')
        .fontSize(16)
        .margin({right: 12})
        .fontWeight(FontWeight.Medium)
    }
    .RowStyle()
  }
}