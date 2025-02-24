import { BreakpointState } from "../../../common/breakpointsystem"
import { curves } from "@kit.ArkUI"
import { UIConfig } from "../../../entryability/AppState"
import { customAnimationUtil } from "../../../utils/Animation"
import { TAB_CONTENT_TITLE_FONT_SIZE, TAB_CONTENT_TITLE_HEIGHT } from "../../../common/Constants"

@Component
struct OverwriteTop {

  @State title: ResourceStr = ''
  @State subtitle: ResourceStr = ''
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  //page内顶部标题偏移量
  @Consume curYOffset: number
  build() {
    Row() {
      //返回图标
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(28)
          .fontColor([this.icon_primary])
      }
      .transition(customAnimationUtil.isSlide(200, this.uiConfig))
      .margin({left: this.morePageMargin.value})
      .onClick(() => {
        this.pageInfos.pop(true)
      })
      .width(40)
      .height(40)
      .backgroundColor($r('app.color.settings_container_background'))
      Column() {
        Text(this.title)
          .fontSize(this.curYOffset<0?TAB_CONTENT_TITLE_FONT_SIZE-this.curYOffset/100:TAB_CONTENT_TITLE_FONT_SIZE)
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
      .transition(customAnimationUtil.isSlide(100, this.uiConfig))
      .alignItems(HorizontalAlign.Center)
      Blank()
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .height(this.curYOffset<0?TAB_CONTENT_TITLE_HEIGHT-this.curYOffset:TAB_CONTENT_TITLE_HEIGHT)
    .zIndex(1)
    .position({x:0})
  }
}

export default OverwriteTop