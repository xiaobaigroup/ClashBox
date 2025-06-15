import { BreakpointState } from "../../common/breakpoint/breakpointsystem"
import { TAB_CONTENT_TITLE_FONT_SIZE, TAB_CONTENT_TITLE_HEIGHT } from "../../common/entity/Constants"
import { UIConfig } from "../../entryability/AppState"
import { customAnimationUtil } from "../../common/utils/Animation"
import { SymbolGlyphModifier } from "@kit.ArkUI"
import { ButtonBuilder, icon_primary } from '../Common/Common'
import { PageMargin } from "../../common/breakpoint/BreakPoint"

/**
 * 更多页顶部导航栏
 * @param title 标题文本
 * @param searchButton 搜索按钮
 * @param otherButton 其它功能按钮
 */
@Component
export struct MoreTop {

  @Prop icon1: Resource
  @Prop icon2: Resource
  // 是否进入二级界面
  @Consume isSecondary: boolean
  // 更多页路由表
  @Consume('NavPathStack') pageInfos: NavPathStack
  // 标题
  @State title?: Resource = undefined
  // 元素名称标识
  @State name: string = ''
  // 副标题
  @State subtitle: ResourceStr = ''
  @Consume needSearch: boolean
  @Consume isSearching: boolean
  @Consume searchText: string
  // page内顶部标题偏移量
  @Consume curYOffset: number
  @Prop enableClick2: boolean = true
  @BuilderParam theMenu: () => void = this.TheMenu
  @StorageProp('WindowMode') windowMode: boolean = false
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  onClick1: () => void = () => {}
  onClick2: () => void = () => {}

  build() {
    Row() {
      if (this.isSearching) {
        Search({ value: this.searchText, placeholder: $r('app.string.enter_search')})
          .enterKeyType(EnterKeyType.Search)
          .copyOption(CopyOptions.LocalDevice)
          .searchIcon(new SymbolGlyphModifier($r('sys.symbol.magnifyingglass')).fontColor([this.icon_emphasize]))
          .cancelButton({
            style: CancelButtonStyle.CONSTANT,
            icon: new SymbolGlyphModifier($r('sys.symbol.xmark')).fontColor([this.icon_emphasize])
          })
          .layoutWeight(1)
          .onSubmit((value: string) => {
            // 发送搜索
            this.searchText = value
          })
        Button({ stateEffect: true }) {
         Text($r('app.string.Cancel'))
        }
        .height(40)
        // .margin({ left: 10 })
        .backgroundColor($r('app.color.background'))
        .transition(customAnimationUtil.isSlide(50, this.uiConfig))
        .onClick(() => {
          this.isSearching = false
        })
      } else {
        // 返回图标
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(28)
            .fontColor([icon_primary])
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
          if(this.subtitle) {
            Text(this.subtitle)
              .fontWeight(FontWeight.Normal)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({top: 2, left: 8})
              .fontSize(14)
              .maxLines(1)
          }
        }
        .layoutWeight(1)
        .margin({ left: 10 })
        .alignItems(HorizontalAlign.Start)
        .transition(customAnimationUtil.isSlide(150, this.uiConfig))
        Blank()
        if (this.needSearch) {
          // 默认搜索按钮
          ButtonBuilder({
            icon: $r('sys.symbol.magnifyingglass'),
            iconSize: this.windowMode ? 16 : 24,
            onCheck: () => {
              this.isSearching = true
            }
          })
            .margin({ right: this.windowMode ? 0 : 10})
        }
        if (this.icon1) {
          // 功能按钮1
          Row() {
            ButtonBuilder({
              icon: this.icon1,
              iconSize: this.windowMode ? 16 : 24,
              onCheck: () => {
                this.onClick1()
              }
            })
          }.height('100%')
          .margin({ right: this.windowMode ? 0 : 10})
          .alignItems(this.windowMode ? VerticalAlign.Top : VerticalAlign.Center)
        }
        if (this.icon2) {
          // 功能按钮2
          Row() {
            ButtonBuilder({
              icon: this.icon2,
              enableClick: this.enableClick2,
              iconSize: this.windowMode ? 16 : 24,
              onCheck: () => {
                this.onClick2()
              }
            })
          }.height('100%')
          .alignItems(this.windowMode ? VerticalAlign.Top : VerticalAlign.Center)
          .bindMenu(this.enableClick2 ? undefined : this.theMenu())
        }
      }
    }.zIndex(1)
    .width('100%')
    .layoutWeight(1)
    .position({x: 0})
    .alignItems(VerticalAlign.Center)
    .height(this.curYOffset < 0 ? TAB_CONTENT_TITLE_HEIGHT - this.curYOffset : TAB_CONTENT_TITLE_HEIGHT)
    .padding({right: this.windowMode ? 120 : PageMargin(this.widthBp, this.heightBp), left: PageMargin(this.widthBp, this.heightBp)})
  }

  @Builder
  TheMenu() {
    Menu()
  }

}