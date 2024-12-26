import { BreakpointState } from "../../common/breakpointsystem"
import { NoticeList, NoticeListItemProp } from "../../common/Constants"
import { getResourceString } from "../../utils/ResourceStringUtil"
import TopBuilder from "./TopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"

/**
 * 通知页
 */
@Component
struct Notice {
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  @State noticeList: NoticeListItemProp[] = NoticeList
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 流量提醒启用状态变量
  @Consume EnableCellularDataReminder: boolean
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>
  @State Enablednotice: boolean = false
  @State EnabledTimenotice: boolean = false
  @State currentNumber: number = 0
  private TimeUnitSelect: number = 1
  private TimeUnitFruits: string[] = [
    getResourceString($r('app.string.min'), this),
    getResourceString($r('app.string.hour'), this),
    getResourceString($r('app.string.day'), this)
  ]

  // 刷新流量提醒行UI  TODO 【用户首选项】保存通知页的数组 即流量提醒启用状态 Ya@2024-12-26
  refreshCellularDataReminder() {
    hilog.info(0xFF00, "NoticePageTag", "当前流量提醒启用状态为: %{public}s", this.EnableCellularDataReminder)
    if(this.EnableCellularDataReminder) {
      // 通知页数组流量提醒状态 -> 已启用
      const ItemData = this.noticeList[1]
      ItemData.subtitle2 = $r('app.string.enabled')
      hilog.info(0xFF00, "NoticePageReminderTrueTag", "当前流量提醒启用状态: %{public}s", getResourceString(ItemData.subtitle2, this))
      this.noticeList.splice(1, 1, ItemData)
    } else {
      // 通知页数组流量提醒状态 -> 未启用
      const ItemData = this.noticeList[1]
      ItemData.subtitle2 = $r('app.string.not_enabled')
      hilog.info(0xFF00, "NoticePageReminderFalseTag", "当前流量提醒启用状态: %{public}s", getResourceString(ItemData.subtitle2, this))
      this.noticeList.splice(1, 1, ItemData)
    }
  }

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Notice')})
      Column() {
        // 通知总开关
        Row() {
          SymbolGlyph($r('sys.symbol.message_on_message_fill'))
            .fontSize(24)
            .margin({left: 12})
            .fontColor([this.icon_emphasize])
          Text($r('app.string.notice_main_switch'))
            .fontWeight(FontWeight.Medium)
            .margin({ left: 12 })
            .fontSize(16)
          Blank()
          // 后台通知开关
          Toggle({ type: ToggleType.Switch, isOn: $$this.Enablednotice })
            .selectedColor(this.icon_emphasize)
            .margin({right: 12})
            .onChange((isOn: boolean) => {
              if(isOn) {
                this.Enablednotice = true
              } else {
                this.Enablednotice = false
              }
            })
        }
        .RowStyle()
        .margin({bottom: 10})
        if(this.Enablednotice) {
          // 后台通知&流量提醒 Start
          ForEach(this.noticeList, (item: NoticeListItemProp, index: number) => {
            Row() {
              SymbolGlyph(item.icons)
                .fontSize(24)
                .margin({left: 12})
                .fontColor([this.icon_emphasize])
              Column() {
                Text(item.title)
                  .fontWeight(FontWeight.Medium)
                  .fontSize(16)
                Text(item.subtitle)
                  .fontWeight(FontWeight.Normal)
                  .textOverflow({ overflow: TextOverflow.MARQUEE })
                  .maxLines(1)
                  .margin({top: 2})
                  .fontSize(14)
                  .width('65%')
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })
              Blank()
              if(index === 0) {
                // 后台通知开关
                Toggle({ type: ToggleType.Switch, isOn: item.isOn })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .onChange((isOn: boolean) => {
                    // 逻辑处理 TODO 待完成后台通知的实现逻辑

                  })
              } else {
                // 流量提醒
                Text(item.subtitle2)
                  .fontWeight(FontWeight.Normal)
                  .margin({right: 4 })
                  .fontSize(14)
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontSize(28)
                  .margin({right: 12})
                  .fontColor([this.icon_primary])
              }
            }
            .RowStyle()
            .margin({bottom: 10})
            .onClick(() => {
              // 流量提醒
              if(index === 1) {
                // 跳转至流量提醒
                this.SettingsPageInfos.pushPathByName('CellularDataReminder', false)
              }
            })
          })
          // 时间提醒与时间设置Column Start
          Column() {
            // 时间提醒行
            Row() {
              SymbolGlyph($r('sys.symbol.clock'))
                .fontSize(24)
                .margin({left: 12})
                .fontColor([this.icon_emphasize])
              Column() {
                Text( $r('app.string.time_reminder'))
                  .fontWeight(FontWeight.Medium)
                  .fontSize(16)
                Text($r('app.string.time_reminder_subtitle'))
                  .fontWeight(FontWeight.Normal)
                  .textOverflow({ overflow: TextOverflow.MARQUEE })
                  .maxLines(1)
                  .margin({top: 2})
                  .fontSize(14)
                  .width('65%')
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })
              Blank()
              // 时间提醒开关
              Toggle({ type: ToggleType.Switch, isOn: $$this.EnabledTimenotice })
                .selectedColor(this.icon_emphasize)
                .margin({right: 12})
                .onChange((isOn: boolean) => {
                  // 逻辑处理 TODO 【用户首选项】保存时间提醒开关的启用状态 Ya@2024-12-26
                  if(isOn) {
                    this.EnabledTimenotice = true
                  } else {
                    this.EnabledTimenotice = false
                  }
                })
            }.RowStyle()
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
                Blank()
                TextInput({placeholder: $r('app.string.text_input_placeholder'), text: $$this.currentNumber})
                  .TextInputStyle()
                  .borderColor(this.icon_emphasize)
                TextPicker({range: this.TimeUnitFruits, selected: this.TimeUnitSelect})
                  .width('15%')
                  .height(56)
                  .margin({right: 9})
                  .defaultPickerItemHeight(23)
                  .disappearTextStyle({font: {size: 14, weight: FontWeight.Normal}})
                  .textStyle({font: {size: 14, weight: FontWeight.Normal}})
                  .selectedTextStyle({color: this.icon_emphasize, font: {size: 16, weight: FontWeight.Regular}})
                  .onChange((value: string | string[], index: number | number[]) => {
                    hilog.info(0xFF00, "NoticetestTag", "选择的时间单位index:", index)
                    hilog.info(0xFF00, "NoticetestTag", "当前输入为: %{public}s", this.currentNumber)
                    // TODO 待实现时间提醒功能，this.currentNumber为输入框输入数字，index为单位选择器对应角标，具体对应单位参照this.TimeUnitFruits

                  })
              }.RowStyle()
            } // 提醒时间设置行 End

          } // 时间提醒与时间设置Column End
          .ColumnStyle()
        } // 后台通知&流量提醒 End

      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: this.breakPointStatemorePageMargin.value, right: this.breakPointStatemorePageMargin.value })
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.SettingsPageInfos.clear();
      return true;
    })
    // 当通知页即将弹出至栈顶时触发
    .onWillShow(() => {
      this.refreshCellularDataReminder()
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
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>
  // 滚动列表高度
  @Consume('breakPointStateSettingslistHeight') private SettingslistHeight: BreakpointState<number>
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

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Notice'), subtitle: $r('app.string.cellular_data_reminder')})
      Scroll() {
        Column() {
          // 流量提醒总开关行
          Row() {
            SymbolGlyph($r('sys.symbol.mobiledata'))
              .fontSize(24)
              .margin({left: 12})
              .fontColor([this.icon_emphasize])
            Column() {
              Text( $r('app.string.cellular_data_reminder'))
                .fontWeight(FontWeight.Medium)
                .fontSize(16)
              Text($r('app.string.cellular_data_reminder_subtitle'))
                .fontWeight(FontWeight.Normal)
                .textOverflow({ overflow: TextOverflow.MARQUEE })
                .maxLines(1)
                .margin({top: 2})
                .fontSize(14)
                .width('65%')
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })
            Blank()
            // 流量提醒总开关
            Toggle({ type: ToggleType.Switch, isOn: $$this.EnableCellularDataReminder })
              .selectedColor(this.icon_emphasize)
              .margin({right: 12})
              .onChange((isOn: boolean) => {
                if(isOn) {
                  this.EnableCellularDataReminder = true
                } else {
                  this.EnableCellularDataReminder = false
                }
              })
          }
          .RowStyle()
          .margin({bottom: 10})
          if(this.EnableCellularDataReminder) {
            // 每小时通知
            Column() {
              noticeRow({
                noticeTitle: $r('app.string.per_hour_notice'),
                noticeSubtitle: $r('app.string.per_hour_notice_subtitle')
              }) {
                // 每小时通知开关
                Toggle({ type: ToggleType.Switch, isOn: $$this.perHourNotice })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .onChange((isOn: boolean) => {
                    if(isOn) {
                      this.perHourNotice = true
                    } else {
                      this.perHourNotice = false
                    }
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
            // 每日通知
            Column() {
              noticeRow({
                noticeTitle: $r('app.string.per_day_notice'),
                noticeSubtitle: $r('app.string.per_day_notice_subtitle')
              }) {
                // 每日通知开关
                Toggle({ type: ToggleType.Switch, isOn: $$this.perDayNotice })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .onChange((isOn: boolean) => {
                    if(isOn) {
                      this.perDayNotice = true
                    } else {
                      this.perDayNotice = false
                    }
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
            // 每周通知
            Column() {
              noticeRow({
                noticeTitle: $r('app.string.per_week_notice'),
                noticeSubtitle: $r('app.string.per_week_notice_subtitle')
              }) {
                // 每周通知开关
                Toggle({ type: ToggleType.Switch, isOn: $$this.perWeekNotice })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .onChange((isOn: boolean) => {
                    if(isOn) {
                      this.perWeekNotice = true
                    } else {
                      this.perWeekNotice = false
                    }
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
            // 每月通知
            Column() {
              noticeRow({
                noticeTitle: $r('app.string.per_month_notice'),
                noticeSubtitle: $r('app.string.per_month_notice_subtitle')
              }) {
                // 每月通知开关
                Toggle({ type: ToggleType.Switch, isOn: $$this.perMonthNotice })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .onChange((isOn: boolean) => {
                    if(isOn) {
                      this.perMonthNotice = true
                    } else {
                      this.perMonthNotice = false
                    }
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
            // 总量通知
            Column() {
              noticeRow({
                noticeTitle: $r('app.string.total_data_notice'),
                noticeSubtitle: $r('app.string.total_data_notice_subtitle')
              }) {
                // 总量通知开关
                Toggle({ type: ToggleType.Switch, isOn: $$this.totalDataNotice })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .onChange((isOn: boolean) => {
                    if(isOn) {
                      this.totalDataNotice = true
                    } else {
                      this.totalDataNotice = false
                    }
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
                    .onChange(() => {
                      // 测试用
                      hilog.info(0xFF00, "NoticeReminderTag", "当前总量输入为: %{public}s", this.theTotalNumber)
                    })
                }
              }
            }
            .ColumnStyle()
            .margin({bottom: 10})
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: this.breakPointStatemorePageMargin.value, right: this.breakPointStatemorePageMargin.value })
      }
      .width('100%')
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .height(this.isLandscapePhone ? 300 : this.SettingslistHeight.value)
    }
    .width('100%')
    .hideTitleBar(true)
    .hideToolBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.SettingsPageInfos.clear();
      return true;
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
  .width('20%')
  .borderRadius(0)
  .type(InputType.Number)
  .fontSize(15)
  .textAlign(TextAlign.Center)
  .padding({ left: 5, right: 5 })
  .margin({right: 2, top: 10, bottom: 10})
  .backgroundColor($r('app.color.container_background'))
  .border({
    width: { bottom: 2 },
    // 实线
    style: { top: BorderStyle.Solid }
  })
}

/**
 * 通知开关行
 */
@Component
struct noticeRow {
  // 标题
  @State noticeTitle: ResourceStr = ''
  // 副标题
  @State noticeSubtitle: ResourceStr = ''
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 通知开关
  @BuilderParam noticeToggle: () => void = this.defaultBuilder
  // 默认开关
  @Builder
  defaultBuilder() {
    Toggle({ type: ToggleType.Switch, isOn: false })
      .selectedColor(this.icon_emphasize)
      .margin({right: 12})
  }

  build() {
    Row() {
      Column() {
        Text(this.noticeTitle)
          .fontWeight(FontWeight.Medium)
          .fontSize(16)
        Text(this.noticeSubtitle)
          .fontWeight(FontWeight.Normal)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .margin({top: 2})
          .fontSize(14)
          .width('75%')
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 14 })
      Blank()
      this.noticeToggle()
    }
    .RowStyle()
  }
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