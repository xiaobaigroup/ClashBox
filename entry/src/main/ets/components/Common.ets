/* bindSheet 里套 `Navigation`、`NavDestination`是的标题栏的替代品 START */
// 前提：不使用NavDestination的标题栏.hideTitleBar(true)。不使用`bindSheet`的`dragBar`，仅使用`bindSheet`自带的`close`按钮。

/*
 * 不在`.title`属性里设置这个`Builder`标题组件是因为`bindSheet`里使用NV的话，用自带返回按钮和标题栏的有很多问题，
 *    比如NV返回按钮和打开了`dragBar的`bindSheet`自带的叉号不在同一个水平线
 *    比如不使用`bindSheet`自带的关闭按钮，叉号不能保持自带的叉号类似`fixed`的固定位置，体验不好
 *    比如切换路由的时候返回按钮下面会短暂的变透明、给标题栏设置背景颜色后，自带的返回按钮依然是默认背景颜色
 *    由于api12没有单独隐藏返回按钮的api，所以v这是在直接隐藏了整个标题栏 `.hideTitleBar(true)` 的情况下使用的bindSheet套NV的通用标题栏
 */
import {
  BIND_SHEET_DRAG_BAR_HEIGHT,
  BIND_SHEET_TITLE_CONTAINER_HEIGHT,
  BIND_SHEET_TITLE_LEFT_SYMBOL_HEIGHT,
  BIND_SHEET_TITLE_LEFT_SYMBOL_WEIGHT,
  TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE
} from "../common/Constants"


/* BindSheetTitleCustomBuilder 组件内菜单 */
export interface BindSheetTitleCustomBuilderMenu{
  // value: string
  // Symbol符号
  symbol?: Resource
  symbolFontColor?: Array<ResourceColor>
  // 背景颜色
  symbolBackgroundColor?: ResourceColor
  // 是否启用（现在没有效果）
  isEnabled?: boolean
  // 点击事件
  action?: Function
}

/**
 * BindSheetTitleCustomBuilder 组件参数
 */
export interface BindSheetTitleCustomBuilderParam{
  // 标题栏绑定的`NV`路由栈对象
  pageInfos: NavPathStack,
  // 是否子页面（子页面的情况下会给`mainTitle`和`subTitle`设置一个 paddingLeft，为了不和NV的返回按钮靠得太近
  isSubPage: boolean,
  // 标题的左边距（`isSubPage`为`true`的时候生效）
  titlePaddingLeft?: Length
  // 主标题（下文中`mainTitle`开头的属性是主标题的样式属性)
  mainTitle: string,
  // 副标题（`isSubPage`为`true`的时候生效）（下文中`subTitle`开头的属性是副标题的样式属性)
  subTitle?: string,
  mainTitleFontWeight?: number,
  mainTitleFontSize: number,
  // subTitleFontWeight?: number,
  subTitleFontSize?: number,
  titleBackgroundColor?: Length,
  // 这个Title容器的`padding`设置，建议只设置`left`为固定值`15`，
  // 因为navDestination自带的返回按钮左边距在多个设备下默认都是15（可以改：paddingStart）、bindSheet默认的关闭按钮在多个设备下右边距也是15
  padding?: Padding
  // 菜单Symbol按钮集合（定义顺序就是从左至右的显示顺序）
  menus: Array<BindSheetTitleCustomBuilderMenu>
}

/**
 * 使用
 * @param param Builder 组件参数
 */
@Builder
export function BindSheetTitleCustomBuilder(param: BindSheetTitleCustomBuilderParam){
  Row(){
    // 返回按钮 START
    // 由于NV根页面不需要显示返回按钮，直接用是否子页面来判断了
    if (param.isSubPage) {
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
          .fontColor([$r('sys.color.icon_secondary')])
      }
      .width(BIND_SHEET_TITLE_LEFT_SYMBOL_WEIGHT)
      .height(BIND_SHEET_TITLE_LEFT_SYMBOL_HEIGHT)
      .backgroundColor($r('app.color.settings_container_background'))
      .clickEffect({ level: ClickEffectLevel.LIGHT })
      .onClick(() => {
        // 弹出页面栈
        param.pageInfos.pop(true)
      })
    }
    // 返回按钮 END

    // 主副标题 START
    Column(){
      // TODO 国际化
      Text(param.mainTitle)
        .fontWeight(param.mainTitleFontWeight?? FontWeight.Bold)
        .fontSize(param.mainTitleFontSize)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(24)
        .maxLines(1)
        .textOverflow({overflow: TextOverflow.MARQUEE})
        .animation({ duration: 200, curve: Curve.Ease })
      if (param.subTitle != null && param.subTitle != ''){
        Text(param.subTitle)
          .fontSize(param.subTitleFontSize??14)
          .fontColor($r('sys.color.font_secondary'))
          .lineHeight(16)
          .maxLines(1)
          .textOverflow({overflow: TextOverflow.MARQUEE})
          .animation({ duration: 200, curve: Curve.Ease })
      }
    }
    .alignItems(HorizontalAlign.Start)
    // 子页面避让菜单menus、返回按钮（所以param.menus.length + 1）
    .width(param.isSubPage ? `calc(100% - ${(BIND_SHEET_TITLE_LEFT_SYMBOL_WEIGHT + 10) * (param.menus.length + 1)}vp)` : '100%')
    .height(param.subTitle != null && param.subTitle != '' ? param.mainTitleFontSize * 2 : param.mainTitleFontSize )
    .padding({ left: param.isSubPage ? param.titlePaddingLeft??0 : 0 })
    .animation({ duration: 200, curve: Curve.Ease })
    // 主副标题 END

    // 菜单按钮 START
    if (param.menus.length > 0) {
      ForEach( param.menus, (item: BindSheetTitleCustomBuilderMenu, index: number) => {
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph(item.symbol)
            .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
            .fontColor(item.symbolFontColor ?? [$r('sys.color.icon_secondary')])
        }
        .width(BIND_SHEET_TITLE_LEFT_SYMBOL_WEIGHT)
        .height(BIND_SHEET_TITLE_LEFT_SYMBOL_HEIGHT)
        .margin({ left: 10 })
        // .backgroundColor($r('app.color.settings_container_background'))
        .backgroundColor(item.symbolBackgroundColor ?? $r('app.color.settings_container_background'))
        .clickEffect({ level: ClickEffectLevel.LIGHT })
        .onClick(() => {
          if (item.action != undefined) {
            item.action()
          }
        })
      })
    }
    // 菜单按钮 END
  }
  .height(BIND_SHEET_TITLE_CONTAINER_HEIGHT + BIND_SHEET_DRAG_BAR_HEIGHT)
  .width('100%')
  .alignItems(VerticalAlign.Center)
  // 为什么设置`15`，看参数类型中`padding`的介绍
  .padding(param.isSubPage ? param.padding : 15 )
  .backgroundColor(param?.titleBackgroundColor)
  // .sharedTransition('configAddBindSheetTitle', { duration: 300, curve: Curve.Ease } )
  // .animation({ duration: 200, curve: Curve.Ease })
}

/* bindSheet 里套 `Navigation`、`NavDestination`是的标题栏的替代品 START */
