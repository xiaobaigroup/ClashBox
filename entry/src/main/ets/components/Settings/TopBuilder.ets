import { hilog } from "@kit.PerformanceAnalysisKit"
import { BIND_SHEET_DRAG_BAR_HEIGHT, BIND_SHEET_TITLE_CONTAINER_HEIGHT } from "../../common/Constants"

@Preview
@Component
struct TopBuilder {

  @State title: ResourceStr = '设置'
  @State showBackButton: boolean = true
  // @Link isShowSettings: boolean
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary') //一级图标色，黑色


  build() {
    Row() {
      if (this.showBackButton) {
        //返回图标
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(28)
            .fontColor([this.icon_secondary])
        }
        .margin({left: 16, top: BIND_SHEET_DRAG_BAR_HEIGHT })
        .width(40)
        .height(40)
        .backgroundColor('#CACACA')
        .onClick(() => {
          this.SettingsPageInfos.pop(true)
        })
      }
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin(this.showBackButton ? {left: 8, top: 24 } : {left: 16, top: 24 })
      Blank()
      /*Button({ type: ButtonType.Circle, stateEffect: true }) {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(24)
          .fontColor([this.icon_secondary])
      }
      .width(40)
      .height(40)
      .backgroundColor($r('app.color.settings_container_background'))
      .backgroundBlurStyle(BlurStyle.BACKGROUND_REGULAR)
      .margin({right: 16, top: BIND_SHEET_DRAG_BAR_HEIGHT })
      .onClick(() => {
        if (this.SettingsPageInfos.size() != 0 ) {
          this.SettingsPageInfos.pop(true)
        } else {
          this.isShowSettings = false
          this.SettingsPageInfos.clear()
        }
      })*/
    }
    .margin({bottom: 8})
    .alignItems(VerticalAlign.Top)
    .width('100%')
    .height(BIND_SHEET_TITLE_CONTAINER_HEIGHT)

  }
}

export default  TopBuilder