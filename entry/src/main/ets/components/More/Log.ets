import { BreakpointState } from "../../common/breakpointsystem"
import { getResourceString } from "../../utils/getResourceString"
import MoreMenu from "./LogMoreMenu"

@Entry
@Component
struct Log {
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @State isShowMenu: boolean = false
  @State EnableLogger: boolean = false
  @State isLogData: boolean = false
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色

  @Builder
  MoreMenu() {
    Menu() {
      MenuItem({ content: $r('app.string.EnableLogger') })
        .selectIcon(true)
        .selected(this.EnableLogger)
        .onChange((selected) => {
          this.EnableLogger = !this.EnableLogger
        })
      if (this.EnableLogger) {
        MenuItem({ content: $r('app.string.ClearLogs')})
          .selectIcon(true)
        MenuItem({ content: $r('app.string.ExportLog')})
          .selectIcon(true)
      }
    }
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          // 导航区
          Row() {
            //返回图标
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph($r('sys.symbol.chevron_left'))
                .fontSize(28)
                .fontColor([this.icon_primary])
            }
            .margin({left: this.morePageMargin.value})
            .onClick(() => {
              this.pageInfos.pop(true)
            })
            .width(40)
            .height(40)
            .backgroundColor($r('app.color.settings_container_background'))
            Text($r('app.string.Log'))
              .fontSize(30)
              .fontWeight(FontWeight.Bold)
              .textAlign(TextAlign.Start)
              .margin({left: 8})
            Blank()
            //搜索
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph($r('sys.symbol.magnifyingglass'))
                .fontSize(24)
                .fontColor([this.icon_primary])
            }
            .backgroundColor($r('app.color.settings_container_background'))
            .margin({ right: 10 })
            .width(40)
            .height(40)
            //更多图标
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
                .fontSize(24)
                .fontColor([this.icon_primary])
            }
            /*.onClick(() => {
              this.isShowMenu = !this.isShowMenu
            })*/
            .margin({ right: this.morePageMargin.value })
            .width(40)
            .height(40)
            .bindMenu(this.MoreMenu())
            .backgroundColor($r('app.color.settings_container_background'))
          }
          .zIndex(1)
          .width('100%')
          .height(56)
          .alignItems(VerticalAlign.Center)

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
    //.title(this.TopBuilder)//getResourceString($r('app.string.Log'), this)
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