import { BreakpointState } from "../../common/breakpointsystem"
import { Font, SymbolGlyphModifier } from "@kit.ArkUI"
import { MoreTop } from "./MoreTopBuilder"

@Entry
@Component
struct Log {
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @State isShowMenu: boolean = false
  @State EnableLogger: boolean = false
  @State isLogData: boolean = false
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @State filterChecked: number = 0

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
  logOther() {
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          // 导航区
          Row() {
            MoreTop({
              title: $r('app.string.Log'),
              otherButton: this.logOther
            })
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph($r('sys.symbol.magnifyingglass'))
                .fontSize(24)
                .fontColor([this.icon_primary])
            }
            .backgroundColor($r('app.color.settings_container_background'))
            .margin({ right: 10 })
            .width(40)
            .height(40)
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
          } else if (this.isLogData === false) {
            Column() {
              SymbolGlyph($r('sys.symbol.doc'))
                .fontSize(24)
                .fontColor([this.icon_primary])
                .margin({bottom: 4 })
              Text($r('app.string.NoLogs'))
            }
            .zIndex(1)
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .height('100%')
          } else {



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