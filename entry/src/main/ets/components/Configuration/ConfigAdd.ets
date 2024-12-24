import { BreakpointState } from "../../common/breakpointsystem";
import {
  ANIMATION_DURATION_300,
  BIND_SHEET_CONTAINER_HEIGHT,
  BIND_SHEET_DRAG_BAR_HEIGHT,
  BIND_SHEET_MAIN_FONTSIZE,
  BIND_SHEET_MAIN_FONT_WEIGHT,
  BIND_SHEET_SUB_FONTSIZE,
  BIND_SHEET_TITLE_CONTAINER_HEIGHT,
  BORDER_RADIUS_20, LIST_ITEM_HEIGHT,
  LIST_ITEM_PADDING,
  LIST_SPACE,
  RouteName
} from "../../common/Constants";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { BindSheetTitleCustomBuilder } from "../Common";

interface ConfigAddType {
  symbolStart? : Resource,
  // 内容
  text: ResourceStr,
  // NV路由栈name
  navPathStackName?: RouteName,
  symbolEnd?: Resource
}

@Component
export struct ConfigAdd {

  private componentName: string = 'ConfigAdd';

  /* 断点相关 */
  @Consume('breakPointStateNavigationListPadding')
  breakPointStateNavigationListPadding: BreakpointState<number>

  /* 是否开启 配置页 `bindSheet` 组件的前景模糊 */
  @Provide('isEnableConfigPageBindSheetForegroundBlur')
  private isEnableConfigPageBindSheetForegroundBlur: boolean = false

  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor

  /* List 相关 */
  private configAddTypeArray: Array<ConfigAddType> = [
    // TODO 国际化
    { symbolStart: $r('sys.symbol.paperclip'), text: '从URL(链接)导入', navPathStackName: RouteName.IMPORT_CONFIG_FROM_URL, symbolEnd: $r('sys.symbol.chevron_right')},
    { symbolStart: $r('sys.symbol.qrcode'), text: '从二维码导入', navPathStackName: RouteName.IMPORT_CONFIG_FROM_QR_CODE, symbolEnd: $r('sys.symbol.chevron_right')},
    { symbolStart: $r('sys.symbol.doc_text_fill'), text: '从文件导入', navPathStackName: RouteName.IMPORT_CONFIG_FROM_FILE, symbolEnd: $r('sys.symbol.chevron_right')},
    { symbolStart: $r('sys.symbol.doc'), text: '新建空白配置', navPathStackName: RouteName.CREATE_NEW_CONFIG, symbolEnd: $r('sys.symbol.chevron_right')},
  ]

  /* NV路由 相关 */
  // 路由栈
  @Consume('configAddPageInfos')
  private configAddPageInfos: NavPathStack

  // NV title Builder
  @State
  private subTitle: string | Resource = 'subTitle'


  build() {
    Column(){
      // NV路由 START
      Navigation(this.configAddPageInfos){
        // 添加配置几种方式的ListItem START
        List({ space: LIST_SPACE }){
          ForEach( this.configAddTypeArray, (item: ConfigAddType, index: number)=> {
            ListItem(){
              Row(){
                SymbolGlyph(item.symbolStart).fontSize(24).fontColor([this.icon_emphasize]).margin({ right: 20 })
                Text(item.text).fontSize(16).fontColor($r('sys.color.font_primary'))
                Blank()
                SymbolGlyph(item.symbolEnd).fontSize(24).fontColor([$r('sys.color.icon')])
              }
              .width('100%')
              .padding(LIST_ITEM_PADDING)
              .alignItems(VerticalAlign.Center)
            }
            // .backgroundColor($r('app.color.container_background'))
            .backgroundColor($r('app.color.list_item_background_color'))
            .width('100%')
            .height(LIST_ITEM_HEIGHT)
            .clickEffect({ level: ClickEffectLevel.MIDDLE })
            .borderRadius(BORDER_RADIUS_20)
            .onClick( () => {
              hilog.info(0xC020, this.componentName, `#ListItem#onClick(): NavPathStack.pushDestinationByName(${item?.navPathStackName}, null})`)
              this.configAddPageInfos.pushDestinationByName(item?.navPathStackName, null)
            })
          })
        }
        .height(`${(LIST_ITEM_HEIGHT + LIST_SPACE) * this.configAddTypeArray.length + 20}`)
        .width('100%')
        .padding({
          left: this.breakPointStateNavigationListPadding.value,
          right: this.breakPointStateNavigationListPadding.value
        })
        // TODO下面这三个都不生效，bindSheet是用Scroll为根节点包裹的，但是nestedScroll也不生效 未知
        // .chainAnimation(true)
        .nestedScroll({scrollForward: NestedScrollMode.SELF_ONLY, scrollBackward: NestedScrollMode.SELF_ONLY})
        .edgeEffect(EdgeEffect.Spring)
        // 添加配置几种方式的ListItem END
      }
      // TODO 国际化
      // .title({ main: '添加配置', sub: ' '})
      // .titleMode(NavigationTitleMode.Mini)
      .title(
        {
          builder: BindSheetTitleCustomBuilder({
            pageInfos: this.configAddPageInfos,
            isSubPage: false,
            mainTitle: '添加配置',
            // subTitle: '',
            mainTitleFontWeight: BIND_SHEET_MAIN_FONT_WEIGHT,
            mainTitleFontSize: BIND_SHEET_MAIN_FONTSIZE,
            subTitleFontSize: BIND_SHEET_SUB_FONTSIZE,
            padding: {
              left: this.breakPointStateNavigationListPadding.value,
              right: this.breakPointStateNavigationListPadding.value
            },
            menus: []
          }),
          // height + 16 是因为设计稿里这56 没包含了dragBar的高度（16）
          height: BIND_SHEET_TITLE_CONTAINER_HEIGHT + BIND_SHEET_DRAG_BAR_HEIGHT
        },
        {
          // barStyle: BarStyle.STACK,
        })
      .height(BIND_SHEET_CONTAINER_HEIGHT)
      .mode(NavigationMode.Stack)
      .hideBackButton(true)
      .navBarWidthRange([255, '100%'])
      .foregroundBlurStyle(this.isEnableConfigPageBindSheetForegroundBlur ? BlurStyle.Thin : BlurStyle.NONE,{ colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 0.3 })
      .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Ease })
      // NV路由 END
    }
    .height('auto')
    // .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK, { colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })

  }

  aboutToAppear(): void {
    hilog.info(0xC020, this.componentName, `#aboutToAppear executed`)
  }

  aboutToDisappear(): void {
    hilog.info(0xC020, this.componentName, `#aboutToDisappear executed`)
    this.configAddPageInfos.clear(true)
    hilog.info(0xC020, this.componentName, `#aboutToDisappear#NV路由configAddPageInfos已清空！`)
  }

}