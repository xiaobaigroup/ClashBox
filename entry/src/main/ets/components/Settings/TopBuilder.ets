import { hilog } from "@kit.PerformanceAnalysisKit"
import { BIND_SHEET_DRAG_BAR_HEIGHT, BIND_SHEET_TITLE_CONTAINER_HEIGHT } from "../../common/Constants"

@Preview
@Component
struct TopBuilder {

  @State title: ResourceStr = '设置'
  @State subtitle: ResourceStr = ''
  @State showBackButton: boolean = true
  // @Link isShowSettings: boolean
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色


  build() {
    Row() {
      if (this.showBackButton) {
        //返回图标
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(28)
            .fontColor([this.icon_primary])
        }
        .margin({left: 16, top: BIND_SHEET_DRAG_BAR_HEIGHT })
        .width(40)
        .height(40)
        .clickEffect({ level: ClickEffectLevel.LIGHT })
        .backgroundColor($r('app.color.back'))
        .onClick(() => {
          this.SettingsPageInfos.pop(true)
        })
      }
      Column() {
        Text(this.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin(this.showBackButton ? {left: 8, top: 21 } : {left: 16, top: 21 })
        if(this.subtitle) {
          Text(this.subtitle)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .fontSize(12)
            .fontWeight(FontWeight.Normal)
            .margin(this.showBackButton ? {left: 8, top: 2 } : {left: 16, top: 2})
        }
      }.alignItems(HorizontalAlign.Start)
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