import { BreakpointState } from "../../common/breakpointsystem"
import { SymbolGlyphModifier } from "@kit.ArkUI"
import { MoreTop } from "./MoreTopBuilder"
import { Nothing, skipRowList, toggleRowList } from "../Common"
import { timestampToDateTime } from "../../utils/TimeConvertUtil"
import { ClashConfig, LogLevel } from "proxy_core"
import { AppConfig, UIConfig } from "../../entryability/AppState"
import { EventHub, EventKey } from "../../common/EventHub"

// 日志数据（假设）
interface LogData {
  // 日志类型（0：Warning；1：Info）
  logType: LogLevel
  // 日志生成时间(展示的时间)
  logTime: number
  // 日志详情
  LogDetails: string
  // 是否跳转
  logSkip: boolean
}

@Component
struct Log {
  // 是否进入二级界面
  @Consume isSecondary: boolean
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @State EnableLogger: boolean = false
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @State filterChecked: number = 0
  @Consume theLogSkipItem: number
  // 临时数据（数据本体在MorePage）
  @Consume logListData: Array<LogData>
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 临时排序变量
  @State theSort: number = 0
  // 临时时间正序变量
  @State theSortTimeUp: boolean = false
  // 临时名称正序变量
  @State theSortNameUp: boolean = false
  @Builder
  MoreMenu() {
    Menu() {
      MenuItem({
        content: $r('app.string.EnableLogger'),
        symbolEndIcon: this.appConfig.enableLogger ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
      })
        .selected(this.appConfig.enableLogger ?? false)
        .onChange((selected) => {
          this.appConfig.enableLogger = !this.appConfig.enableLogger
          EventHub.sendEvent(EventKey.StartLog, this.appConfig.enableLogger)
        })
      if (this.appConfig.enableLogger) {
        MenuItem({ content: $r('app.string.ClearLogs')})
          .onClick(() => {
            EventHub.sendEvent(EventKey.ClearLog)
            // 清空日志操作
          })
        MenuItem({ content: $r('app.string.ExportLog')})
          .onClick(() => {
            // 导出日志操作
            EventHub.sendEvent(EventKey.ExportLog)
          })
        MenuItem({
          builder: ():void => this.SortMenu(),
          content: $r('app.string.sort'),
          symbolEndIcon: new SymbolGlyphModifier($r('sys.symbol.chevron_right'))
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
  SortMenu() {
    Menu() {
      MenuItem({ content: $r('app.string.sort') })
        .contentFont({ weight: FontWeight.Bold })
      MenuItem({
        content: $r('app.string.sort_name'),
        symbolEndIcon: this.theSort === 0 ? new SymbolGlyphModifier(this.theSortNameUp ? $r('sys.symbol.arrow_up') : $r('sys.symbol.arrow_down')) : undefined
      })
        .onClick(() => {
          this.theSort = 0
          this.theSortNameUp = !this.theSortNameUp
        })
      MenuItem({
        content: $r('app.string.sort_time'),
        symbolEndIcon: this.theSort === 1 ? new SymbolGlyphModifier(this.theSortTimeUp ? $r('sys.symbol.arrow_up') : $r('sys.symbol.arrow_down')) : undefined
      })
        .onClick(() => {
          this.theSort = 1
          this.theSortTimeUp = !this.theSortTimeUp
        })
    }
  }

  @Builder
  FilterMenu() {
    Menu() {
      MenuItem({ content: $r('app.string.filter') })
        .contentFont({ weight: FontWeight.Bold })
      MenuItem({
        content: $r('app.string.not_filter'),
        symbolEndIcon: this.clashConfig["log-level"] === LogLevel.Debug ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
      })
        .onClick(() => {
          this.clashConfig["log-level"] = LogLevel.Debug
        })
      MenuItem({
        content: $r('app.string.information_only'),
        symbolEndIcon: this.clashConfig["log-level"] === LogLevel.Info  ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
      })
        .onClick(() => {
          this.clashConfig["log-level"] = LogLevel.Info
        })
      MenuItem({
        content: $r('app.string.warning_only'),
        symbolEndIcon: this.clashConfig["log-level"] === LogLevel.Warning ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
      })
        .onClick(() => {
          this.clashConfig["log-level"] = LogLevel.Warning
        })
      MenuItem({
        content: $r('app.string.error_only'),
        symbolEndIcon: this.clashConfig["log-level"] === LogLevel.Error ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
      })
        .onClick(() => {
          this.clashConfig["log-level"] = LogLevel.Error
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
              name: 'Log',
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
          if (this.appConfig.enableLogger === false) {
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
                        Text(`${item.logType} ${timestampToDateTime(item.logTime)}`)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(item.logType === LogLevel.Error ? Color.Red : this.icon_primary)
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
                    .clickEffect(this.uiConfig.isAnimation ? { level: ClickEffectLevel.MIDDLE, scale: 0.8} : null)
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
      this.pageInfos.clear()
      this.isSecondary = false
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
          subtitle: `${this.logListData[this.theLogSkipItem].logType} ${timestampToDateTime(this.logListData[this.theLogSkipItem].logTime)}`,
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