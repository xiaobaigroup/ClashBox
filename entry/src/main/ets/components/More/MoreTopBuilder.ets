import { BreakpointState } from "../../common/breakpointsystem"
import { TAB_CONTENT_TITLE_FONT_SIZE, TAB_CONTENT_TITLE_HEIGHT } from "../../common/Constants"
import { UIConfig } from "../../entryability/AppState"
import { customAnimationUtil } from "../../utils/Animation"

/**
 * 更多页顶部导航栏
 * @param title 标题文本
 * @param searchButton 搜索按钮
 * @param otherButton 其它功能按钮
 */
@Component
export struct MoreTop {
  // 是否进入二级界面
  @Consume isSecondary: boolean
  // 更多页路由表
  @Consume('NavPathStack') pageInfos: NavPathStack
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  // 标题
  @State title?: Resource = undefined
  // 元素名称标识
  @State name: string = ''
  // 副标题
  @State subtitle: ResourceStr = ''
  // 搜索按钮
  @BuilderParam searchButton: () => void = this.searchDefaultButton
  // 其它按钮
  @BuilderParam otherButton: () => void = this.otherDefaultButton
  //page内顶部标题偏移量
  @Consume curYOffset: number
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>

  @Builder searchDefaultButton() {
    // 默认搜索按钮
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize(24)
        .fontColor([this.icon_primary])
    }
    .backgroundColor($r('app.color.settings_container_background'))
    .width(40)
    .height(40)
    .transition(customAnimationUtil.isSlide(100, this.uiConfig))
  }
  @Builder otherDefaultButton() {
    // 默认功能按钮为更多
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
        .fontSize(24)
        .fontColor([this.icon_primary])
    }
    .width(40)
    .height(40)
    .margin({ left: 10 })
    .backgroundColor($r('app.color.settings_container_background'))
    .transition(customAnimationUtil.isSlide(50, this.uiConfig))
  }

  build() {
    Row() {
      // 返回图标
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(28)
          .fontColor([this.icon_primary])
      }
      .transition(customAnimationUtil.isSlide(200, this.uiConfig))
      .width(40)
      .height(40)
      .backgroundColor($r('app.color.settings_container_background'))
      .onClick(() => {
        this.pageInfos.pop(true)
        if (this.pageInfos.size() <= 1) {
          this.isSecondary = false
        }
      })
      Column() {
        Text(this.title)
          .fontSize(this.curYOffset<0?TAB_CONTENT_TITLE_FONT_SIZE-this.curYOffset/100:TAB_CONTENT_TITLE_FONT_SIZE)
          .geometryTransition(this.name)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
          .margin({left: 8})
        if(this.subtitle) {
          Text(this.subtitle)
            .fontWeight(FontWeight.Normal)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({top: 2, left: 8})
            .fontSize(14)
            .maxLines(1)
        }
      }.layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .transition(customAnimationUtil.isSlide(150, this.uiConfig))
      Blank()
      this.searchButton()
      this.otherButton()
    }
    .layoutWeight(1)
    .alignItems(VerticalAlign.Center)
    .width('100%')
    .position({x:0})
    .height(this.curYOffset<0?TAB_CONTENT_TITLE_HEIGHT-this.curYOffset:TAB_CONTENT_TITLE_HEIGHT)
    .zIndex(1)
    .padding({right: this.morePageMargin.value, left: this.morePageMargin.value})
  }
}