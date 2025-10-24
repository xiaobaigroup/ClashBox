import { UIConfig } from "../../../entryability/AppState"
import { customAnimationUtil } from "../../../common/utils/Animation"
import { TAB_CONTENT_TITLE_FONT_SIZE, TAB_CONTENT_TITLE_HEIGHT } from "../../../common/entity/Constants"
import { PageMargin } from "../../../common/breakpoint/BreakPoint"
import { icon_primary } from  '../../Common/Common'

@Component
struct OverwriteTop {

  @State title: ResourceStr = ''
  @State subtitle: ResourceStr = ''

  // 更多页面栈
  @StorageLink('MoreNavPathStack') morePageInfos: NavPathStack = new NavPathStack()
  @StorageLink('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 状态栏高度
  @StorageProp('topRectHeight') topRectHeight: number = 0

  // page内顶部标题偏移量
  @Consume curYOffset: number

  build() {
    Row() {
      //返回图标
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(28)
          .fontColor([icon_primary])
      }
      .transition(customAnimationUtil.isSlide(200, this.uiConfig))
      .margin({left: PageMargin(this.widthBp, this.heightBp)})
      .onClick(() => {
        console.log(`点击返回，pageInfos：${this.pageInfos.size()}，morePageInfos：${this.morePageInfos.size()}`)
        if (this.widthBp < 2) {
          this.pageInfos.pop(true)
        } else {
          this.morePageInfos.pop(true)
        }
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
        if (this.subtitle) {
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
    .zIndex(1)
    .width('100%')
    .position({x: 0})
    .alignItems(VerticalAlign.Center)
    .margin({ top: this.widthBp < 2 ? this.topRectHeight : 0 })
    .height(this.curYOffset < 0 ? TAB_CONTENT_TITLE_HEIGHT  -this.curYOffset : TAB_CONTENT_TITLE_HEIGHT)
  }
}

export default OverwriteTop