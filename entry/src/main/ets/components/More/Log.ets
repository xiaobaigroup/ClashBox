import { SymbolGlyphModifier } from "@kit.ArkUI"
import { MoreTop } from "./MoreTopBuilder"
import { Nothing, skipRowList } from "../Common/Common"
import { timestampToDateTime } from "../../common/utils/TimeConvertUtil"
import { ClashConfig, LogLevel } from "proxy_core"
import { AppConfig, UIConfig } from "../../entryability/AppState"
import { EventHub, EventKey } from "../../common/EventHub"
import { BORDER_RADIUS_20, CONTENT_END_OFFSET_150, LogData,
  NullLogData,
  TAB_CONTENT_TITLE_HEIGHT } from "../../common/entity/Constants"
import { customAnimationUtil } from "../../common/utils/Animation"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { universalSearch } from "../../common/utils/SmartSearchUtil"
import { PageMargin } from "../../common/breakpoint/BreakPoint"

@Component
struct Log {
  // 是否进入二级界面
  @Consume isSecondary: boolean
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @State EnableLogger: boolean = false
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @State filterChecked: number = 0
  // 数据（数据本体在Index）
  @Consume logListData: Array<LogData>
  @State lastLogListData: Array<LogData> = []
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 临时名称正序变量
  @State theSortNameUp: boolean = false
  // page内顶部标题偏移量
  @Consume curYOffset: number
  @Consume needSearch: boolean
  @Consume @Watch('loglist') isSearching: boolean
  @Consume @Watch('searchLogs') searchText: string

  build() {
    NavDestination() {
      Stack() {
        // 导航区
        MoreTop({
          title: $r('app.string.Log'),
          name: 'Log',
          enableClick2: false,
          icon2: $r('sys.symbol.dot_grid_2x2'),
          theMenu: (): void => { this.MoreMenu() }
        })

        Column() {
          Blank().height(TAB_CONTENT_TITLE_HEIGHT+6)
          // 主体
          if (this.appConfig.enableLogger === false) {
            Column() {
              SymbolGlyph($r('sys.symbol.checkmark_circle'))
                .fontSize(24)
                .fontColor([this.icon_primary])
                .margin({ bottom: 4 })
              Text($r('app.string.EnableLoggerPrompt'))
            }
            .transition(customAnimationUtil.isScaleTranFast(0, this.uiConfig))
            .zIndex(1)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .height('85%')
          } else if (this.logListData.length === 0) {
            Nothing({ name: $r('app.string.Log') })
          } else {
            Scroll() {
              List({ space: 10 }) {
                ForEach(this.sortedLogs(this.uiConfig.LogSortTime === 0, this.clashConfig?.["log-level"] ?? LogLevel.Debug), (item: LogData, index: number) => {
                  ListItem() {
                    if (item.logSkip) {
                      // 需要跳转详情
                      skipRowList({
                        title: `Info ${timestampToDateTime(item.logTime * 1000)}`,
                        subtitle: `${item.LogDetails}`,
                        tips: this.logTipsBuilder
                      }).onClick(() => {
                        // 跳转至详情页
                        this.pageInfos.pushPathByName('LogDetils', item, true)
                      })
                    } else {
                      // 无跳转
                      Row() {
                        Column() {
                          Text(`${item.logType} ${timestampToDateTime(item.logTime * 1000)}`)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(item.logType === LogLevel.Error ? Color.Red : this.icon_primary)
                            .fontSize(16)
                          Text(`${item.LogDetails}`)
                            .fontWeight(FontWeight.Normal)
                            .textOverflow({ overflow: TextOverflow.Ellipsis })
                            .maxLines(1)
                            .margin({ top: 2 })
                            .fontSize(14)
                        }.layoutWeight(1)
                        .alignItems(HorizontalAlign.Start)
                      }
                      .width('100%')
                      .borderRadius(BORDER_RADIUS_20)
                      .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                      .backgroundColor($r('app.color.container_background'))
                      .padding(12)
                    }
                  }.width('100%')
                  .transition(customAnimationUtil.isScaleTranFast(index, this.uiConfig))
                })

              }.width('100%')
              .height('100%')
              .contentEndOffset(CONTENT_END_OFFSET_150)
              .padding({ right: PageMargin(this.widthBp, this.heightBp), left: PageMargin(this.widthBp, this.heightBp) })
              .chainAnimation(true)
              .nestedScroll({
                scrollForward: NestedScrollMode.PARENT_FIRST,
                scrollBackward: NestedScrollMode.SELF_FIRST
              })
            }
            .edgeEffect(this.uiConfig.isAnimation?EdgeEffect.Spring:null)//,{alwaysEnabled:true})
            .onDidScroll((xOffset: number, yOffset: number): void => {
              // 累计计算当前父组件滚动在Y轴方向的偏移量
              if (this.uiConfig.isAnimation){
                this.curYOffset += yOffset
              }
              console.info("yOffset" + this.curYOffset);
            })
          }
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Start)

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
    .onShown(() => {
      // 初始化搜索按钮
      this.needSearch = this.appConfig.enableLogger
    })
    .onWillHide(() => {
      this.needSearch = false
      this.isSearching = false
    })
    .onBackPressed(() => {
      if(this.isSearching) {
        this.isSearching = false
        this.searchText = ''
        return true
      }
      this.pageInfos.clear()
      this.isSecondary = false
      return true
    })
  }

  aboutToAppear(): void {
    // 缓存日志
    this.lastLogListData = this.logListData
  }

  // 日志排序
  sortedLogs( time: boolean, level:LogLevel){
    let logs = this.logListData;
    if (time) {
      logs = this.logListData.sort((a,b)=> b.logTime - a.logTime)
    } else {
      logs = this.logListData.sort((a,b)=> a.logTime - b.logTime)
    }
    if(level !== LogLevel.Debug){
      return logs.filter((l)=> l.logType == level );
    }
    return logs;
  }

  loglist() {
    if (this.isSearching) {
      if (this.searchText === '') {
        return
      }
    } else {
    // 如果不在搜索，还原日志列表
    this.logListData = this.lastLogListData
    }
  }

 // 日志搜索
 searchLogs(keyword: string) {
   hilog.info(0xFF00, 'Log', `#smartsearchLogs 搜索文本：${this.searchText}`)
   keyword = this.searchText
   if (keyword !== '') {
     hilog.info(0xFF00, 'Log', `#smartsearchLogs 开始搜索，搜索文本：${this.searchText}`)
     this.logListData = universalSearch(this.logListData, keyword, {
       fields: ['LogDetails']
     })
   } else {
     hilog.info(0xFF00, 'Log', `#smartsearchLogs 空搜索文本：${this.searchText}`)
     // 空文本恢复数据
     this.logListData = this.lastLogListData
   }
  }

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
          this.needSearch = this.appConfig.enableLogger
          EventHub.sendEvent(EventKey.StartLog, this.appConfig.enableLogger)
        })
      if (this.appConfig.enableLogger) {
        MenuItem({ content: $r('app.string.ClearLogs')})
          .onClick(() => {
            // 清空日志操作
            EventHub.sendEvent(EventKey.ClearLog)
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
        content: $r('app.string.sort_time'),
        symbolEndIcon: new SymbolGlyphModifier(this.uiConfig.LogSortTime === 0 ? $r('sys.symbol.arrow_up') : $r('sys.symbol.arrow_down'))
      })
        .onClick(() => {
          if (this.uiConfig.LogSortTime === 0) {
            this.uiConfig.LogSortTime = 1
          } else {
            this.uiConfig.LogSortTime = 0
          }
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
  logTipsBuilder() {
  }

}
export default Log

@Component
export struct LogDetils {

  @Consume logListData: Array<LogData>
  @State theLogSkipItem: LogData = NullLogData
  @Consume('NavPathStack') pageInfos: NavPathStack
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  //page内顶部标题偏移量
  @Consume curYOffset: number

  controller: RichEditorController = new RichEditorController()
  options: RichEditorOptions = { controller: this.controller }

  build() {
    NavDestination() {
      Stack() {
        // 导航区
        MoreTop({
          title: $r('app.string.Log'),
          subtitle: `${this.theLogSkipItem.logType} ${timestampToDateTime(this.theLogSkipItem.logTime * 1000)}`,
          icon1: $r('sys.symbol.arrowshape_down_to_line_fill'),
          icon2: $r('sys.symbol.trash_fill'),
          onClick1: () => {
            // 保存按钮
            // 导出单个日志
            EventHub.sendEvent(EventKey.ExportLog, this.theLogSkipItem)
          },
          onClick2: () => {
            // 删除按钮
            const index = this.logListData.findIndex((log => log.LogDetails == this.theLogSkipItem.LogDetails))
            this.logListData.splice(index, 1)
            this.pageInfos.pop()
          }
        }).backgroundColor($r('app.color.background')).zIndex(1).position({ x: 0 })

        Scroll() {
          // 文本显示区域
          Column() {
            Blank().height(TAB_CONTENT_TITLE_HEIGHT+6)
            RichEditor(this.options)
              .onReady(() => {
                this.controller.addTextSpan(`${this.theLogSkipItem.LogDetails}`,
                  {
                    style: {
                      fontColor: this.icon_primary,
                      fontSize: 15
                    }
                  })
              })
              .hitTestBehavior(HitTestMode.None)
              .backgroundColor($r('app.color.container_background'))
              .width('100%')
              .margin({ right: PageMargin(this.widthBp, this.heightBp), left: PageMargin(this.widthBp, this.heightBp) })
              .padding({ top: PageMargin(this.widthBp, this.heightBp), bottom: PageMargin(this.widthBp, this.heightBp) })
              .borderRadius(BORDER_RADIUS_20)
          }.height('100%')
          .margin({ right: PageMargin(this.widthBp, this.heightBp), left: PageMargin(this.widthBp, this.heightBp) })
        }
        .edgeEffect(this.uiConfig.isAnimation ? EdgeEffect.Spring : null)//,{alwaysEnabled:true})
        .onDidScroll((xOffset: number, yOffset: number): void => {
          // 累计计算当前父组件滚动在Y轴方向的偏移量
          if (this.uiConfig.isAnimation){
            this.curYOffset += yOffset
          }
          console.info("yOffset" + this.curYOffset);
        })
      }
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.pageInfos.pop()
      return true
    })
    .onReady(async (ctx: NavDestinationContext) => {
      // 接收信息
      try {
        const param: LogData = ctx?.pathInfo?.param as LogData
        this.theLogSkipItem = param
        console.log('ClashBox#LogDetail#onReady 版本详情页接收的params：', JSON.stringify(this.theLogSkipItem))
      } catch (e) {
        console.log(`ClashBox#LogDetail#onReady Navigate onReady catch exception: ${JSON.stringify(e)}`)
      }
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