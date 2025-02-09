import { BreakpointState } from "../../../common/breakpointsystem"
import { curves } from "@kit.ArkUI"
import { UIConfig } from "../../../entryability/AppState"

@Component
struct OverwriteTop {

  @State title: ResourceStr = ''
  @State subtitle: ResourceStr = ''
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  build() {
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
      Column() {
        Text(this.title)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
          .margin({left: 8})
        if(this.subtitle) {
          Text(this.subtitle)
            .fontWeight(FontWeight.Normal)
            .margin({top: 2, left: 8})
            .fontSize(14)
        }
      }
      .alignItems(HorizontalAlign.Center)
      Blank()

    }
    .width('100%')
    .height(56)
    .alignItems(VerticalAlign.Center)
    .transition(this.uiConfig.isAnimation ? TransitionEffect.OPACITY
      .animation({ duration: this.uiConfig.animationSpeed,curve:curves.springMotion(), delay: 0 })
      .combine(TransitionEffect.SLIDE) : null)
  }
}

export default OverwriteTop