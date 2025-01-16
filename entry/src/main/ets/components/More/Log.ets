import { BreakpointState } from "../../common/breakpointsystem"
import { SymbolGlyphModifier } from "@kit.ArkUI"
import { MoreTop } from "./MoreTopBuilder"
import { Nothing, skipRowList, toggleRowList } from "../Common"
import { timestampToDateTime } from "../../utils/TimeConvertUtil"

// 日志数据（假设）
interface LogData {
  // 日志类型（0：Warning；1：Info）
  logType: number
  // 日志生成时间(展示的时间)
  logTime: number
  // 日志详情
  LogDetails: string
  // 是否跳转
  logSkip: boolean
}

@Entry
@Component
struct Log {
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @State isShowMenu: boolean = false
  @State EnableLogger: boolean = false
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @State filterChecked: number = 0
  @Consume theLogSkipItem: number
  // 临时数据（数据本体在MorePage）
  @Consume logListData: Array<LogData>

  @Builder
  MoreMenu() {
    Menu() {
      MenuItem({
        content: $r('app.string.EnableLogger'),
        symbolEndIcon: this.EnableLogger ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
      })
        .selected(this.EnableLogger)
        .onChange((selected) => {
          this.EnableLogger = !this.EnableLogger
        })
      if (this.EnableLogger) {
        MenuItem({ content: $r('app.string.ClearLogs')})
          .onClick(() => {
            // 清空日志操作

          })
        MenuItem({ content: $r('app.string.ExportLog')})
          .onClick(() => {
            // 导出日志操作

          })
        MenuItem({
          builder: ():void => this.FilterMenu(),
          content: $r('app.string.filter'),
          symbolEndIcon: new SymbolGlyphModifier($r('sys.symbol.chevron_right'))
        })
      }
    }
  }

  @Builder
  FilterMenu() {
    Menu() {
      MenuItem({ content: $r('app.string.filter') })
        .contentFont({ weight: FontWeight.Bold })
      MenuItem({
        content: $r('app.string.not_filter'),
        symbolEndIcon: this.filterChecked === 0 ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
      })
        .onClick(() => {
          this.filterChecked = 0
        })
      MenuItem({
        content: $r('app.string.information_only'),
        symbolEndIcon: this.filterChecked === 1 ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
      })
        .onClick(() => {
          this.filterChecked = 1
        })
      MenuItem({
        content: $r('app.string.warning_only'),
        symbolEndIcon: this.filterChecked === 2 ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
      })
        .onClick(() => {
          this.filterChecked = 2
        })
      MenuItem({
        content: $r('app.string.error_only'),
        symbolEndIcon: this.filterChecked === 3 ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
      })
        .onClick(() => {
          this.filterChecked = 3
        })
    }
  }

  @Builder
  logSearch() {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize(24)
        .fontColor([this.icon_primary])
    }
    .backgroundColor($r('app.color.settings_container_background'))
    .margin({ right: 10 })
    .width(40)
    .height(40)
    .onClick(() => {

    })
  }
  @Builder
  logOther() {
  }
  @Builder
  logTipsBuilder() {
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          // 导航区
          Row() {
            MoreTop({
              title: $r('app.string.Log'),
              searchButton: (): void => { this.logSearch() },
              otherButton: (): void => { this.logOther() }
            })
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
                .fontSize(24)
                .fontColor([this.icon_primary])
            }
            .width(40)
            .height(40)
            .bindMenu(this.MoreMenu())
            .backgroundColor($r('app.color.settings_container_background'))
          }.width('100%')

          // 主体
          if (this.EnableLogger === false) {
            Column() {
              SymbolGlyph($r('sys.symbol.checkmark_circle'))
                .fontSize(24)
                .fontColor([this.icon_primary])
                .margin({bottom: 4 })
              Text($r('app.string.EnableLoggerPrompt'))
            }
            .zIndex(1)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .height('100%')
          } else if (this.logListData.length === 0) {
            Nothing({ name: $r('app.string.Log') })
          } else {
            List({ space: 10 }) {
              ForEach(this.logListData, (item: LogData, index: number) => {
                ListItem() {
                  if(item.logSkip) {
                    // 需要跳转详情
                    skipRowList({
                      title: `Info ${timestampToDateTime(item.logTime)}`,
                      subtitle: `${item.LogDetails}`,
                      tips: this.logTipsBuilder
                    }).onClick(() => {
                      this.theLogSkipItem = index
                      // 跳转至详情页
                      this.pageInfos.pushPathByName('LogDetils', index)
                    })
                  } else {
                    // 无跳转
                    Row() {
                      Column() {
                        Text(`${item.logType === 0 ? 'Warning' : 'Info'} ${timestampToDateTime(item.logTime)}`)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(item.logType === 0 ? Color.Red : this.icon_primary)
                          .fontSize(16)
                        Text(`${item.LogDetails}`)
                          .fontWeight(FontWeight.Normal)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                          .maxLines(1)
                          .margin({top: 2})
                          .fontSize(14)
                      }.layoutWeight(1)
                      .alignItems(HorizontalAlign.Start)
                    }.width('100%')
                    .borderRadius(20)
                    .clickEffect({ level: ClickEffectLevel.MIDDLE })
                    .backgroundColor($r('app.color.container_background'))
                    .padding(12)
                  }
                }.width('100%')
              })
            }.width('100%')
            .height('100%')
          }

        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)
        .padding({right: this.morePageMargin.value, left: this.morePageMargin.value})

       /* if (this.isShowMenu) {
          MoreMenu({
            isShowMenu: this.isShowMenu,
            EnableLogger: this.EnableLogger
          })
            .zIndex(2)
        }*/

      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      if (this.isShowMenu) {
        this.isShowMenu = false
      } else {
        this.pageInfos.clear()
      }
      return true
    })
  }
}
export default Log

@Component
export struct LogDetils {
  @Consume theLogSkipItem: number
  @Consume logListData: Array<LogData>
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Builder
  logDetilsSearch() {
  }
  @Builder
  logDetilsOther() {
  }
  controller: RichEditorController = new RichEditorController()
  options: RichEditorOptions = { controller: this.controller }

  build() {
    NavDestination() {
      // 导航区
      Row() {
        MoreTop({
          title: $r('app.string.Log'),
          subtitle: `${this.logListData[this.theLogSkipItem].logType === 0 ? 'Warning' : 'Info'} ${timestampToDateTime(this.logListData[this.theLogSkipItem].logTime)}`,
          searchButton: (): void => { this.logDetilsSearch() },
          otherButton: (): void => { this.logDetilsOther() }
        })
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.arrowshape_down_to_line_fill'))
            .fontSize(24)
            .fontColor([this.icon_primary])
        }.ButtonStyle().margin({right: 10})
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.trash_fill'))
            .fontSize(24)
            .fontColor([this.icon_primary])
        }
        .ButtonStyle()
      }.width('100%')
      // 文本显示区域
      Column() {
        RichEditor(this.options)
          .onReady(() => {
            this.controller.addTextSpan(`${this.logListData[this.theLogSkipItem].LogDetails}`,
            {
              style: {
                fontColor: this.icon_primary,
                fontSize: 15
              }
            })
          })
      }.width('100%')
      .padding({top: 6, bottom: 6})
      .borderRadius(20)
      .backgroundColor($r('app.color.container_background'))
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .padding({right: this.morePageMargin.value, left: this.morePageMargin.value})
    .onBackPressed(() => {
      this.pageInfos.pop()
      return true
    })
  }
}

@Extend(Button)
function ButtonStyle() {
  .width(40)
  .height(40)
  .clickEffect({ level: ClickEffectLevel.LIGHT })
  .backgroundColor($r('app.color.settings_container_background'))
}