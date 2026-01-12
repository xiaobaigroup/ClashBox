import { BreakpointState } from "../../common/breakpoint/breakpointsystem"
import { TAB_CONTENT_TITLE_FONT_SIZE, TAB_CONTENT_TITLE_HEIGHT } from "../../common/entity/Constants"
import { UIConfig } from "../../entryability/AppState"
import { customAnimationUtil } from "../../common/utils/Animation"
import { SymbolGlyphModifier } from "@kit.ArkUI"
import { ButtonBuilder, icon_primary } from '../Common/Common'
import { NeedClearMoreStack, PageMargin, WindowModeMoreTitleFontSize } from "../../common/breakpoint/BreakPoint"

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
  @Prop needBackButton: boolean = false

  // 标题
  @State title?: Resource = undefined
  // 副标题
  @State subtitle: ResourceStr = ''
  @Consume searchText: string
  // 元素名称标识
  @State name: string = ''

  @Consume isSearching: boolean
  // 是否进入二级界面
  @Consume isSecondary: boolean
  @Consume needSearch: boolean

  // page内顶部标题偏移量
  @Consume curYOffset: number

  @BuilderParam theMenu: () => void = this.TheMenu

  @StorageProp('WindowMode') windowMode: boolean = false
  @Prop enableClick2: boolean = true
  /** 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor

  // 更多页面栈
  @StorageLink('MoreNavPathStack') morePageInfos: NavPathStack = new NavPathStack()
  // 主路由表
  @StorageLink('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 状态栏高度
  @StorageProp('topRectHeight') topRectHeight: number = 0

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
        .margin({ left: 5 })
        .backgroundColor($r('app.color.background'))
        .transition(customAnimationUtil.isSlide(50, this.uiConfig))
        .onClick(() => {
          this.isSearching = false
        })
      } else {
        if (NeedClearMoreStack(this.widthBp, this.heightBp) || this.needBackButton) {
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
            if (this.widthBp < 2) {
              this.pageInfos.pop(true)
            } else {
              this.morePageInfos.pop(true)
            }
            if (this.pageInfos.size() <= 1) {
              this.isSecondary = false
            }
          })
        }

        Column() {
          Text(this.title)
            .fontSize(WindowModeMoreTitleFontSize(this.widthBp, this.heightBp))
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
          Row() {
            // 默认搜索按钮
            ButtonBuilder({
              icon: $r('sys.symbol.magnifyingglass'),
              iconSize: this.windowMode ? 18 : 24,
              iconWeight: this.windowMode ? FontWeight.Bold : undefined,
              onCheck: () => {
                this.isSearching = true
              }
            })
              .margin({ right: this.windowMode ? 0 : 10})
              .transition(customAnimationUtil.isSlide(50, this.uiConfig))
          }.height('100%')
          .alignItems(this.windowMode ? VerticalAlign.Top : VerticalAlign.Center)
        }
        if (this.icon1) {
          // 功能按钮1
          Row() {
            ButtonBuilder({
              icon: this.icon1,
              iconSize: this.windowMode ? 18 : 24,
              iconWeight: this.windowMode ? FontWeight.Bold : undefined,
              onCheck: () => {
                this.onClick1()
              }
            })
          }.height('100%')
          .margin({ right: this.windowMode ? 0 : 10})
          .alignItems(this.windowMode ? VerticalAlign.Top : VerticalAlign.Center)
          .transition(customAnimationUtil.isSlide(50, this.uiConfig))
        }
        if (this.icon2) {
          // 功能按钮2
          Row() {
            ButtonBuilder({
              icon: this.icon2,
              enableClick: this.enableClick2,
              iconSize: this.windowMode ? 18 : 24,
              iconWeight: this.windowMode ? FontWeight.Bold : undefined,
              onCheck: () => {
                this.onClick2()
              }
            })
          }
          .height('100%')
          .alignItems(this.windowMode ? VerticalAlign.Top : VerticalAlign.Center)
          .bindMenu(this.enableClick2 ? undefined : this.theMenu())
          .transition(customAnimationUtil.isSlide(0, this.uiConfig))
        }
      }
    }.zIndex(1)
    .width('100%')
    .layoutWeight(1)
    .position({x: 0})
    .alignItems(VerticalAlign.Center)
    .margin({ top: this.widthBp < 2 ? this.topRectHeight : 0 })
    .height(this.curYOffset < 0 ? TAB_CONTENT_TITLE_HEIGHT - this.curYOffset : TAB_CONTENT_TITLE_HEIGHT)
    .padding({right: (this.windowMode && !this.isSearching) ? 120 : PageMargin(this.widthBp, this.heightBp), left: PageMargin(this.widthBp, this.heightBp)})
  }

  @Builder
  TheMenu() {
    Menu()
  }

}