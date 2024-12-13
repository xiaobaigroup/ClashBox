/* bindSheet 配合 `Navigation`、`NavDestination`的`title`属性使用的自定义`Title`组件`Builder` START */
// 前提：不使用`bindSheet`的`dragBar`，使用`bindSheet`自带的`close`按钮

/**
 * Builder 组件参数
 */
export interface ConfigAddBindSheetTitleBuilderParam{
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
  // 这个Title容器的`padding`设置，建议只设置`left`为固定值`15`，
  // 因为navDestination自带的返回按钮左边距在多个设备下默认都是15（可以改：paddingStart）、bindSheet默认的关闭按钮在多个设备下右边距也是15
  padding?: Padding
}

/**
 * 使用
 * @param param Builder 组件参数
 */
@Builder
export function ConfigAddBindSheetTitleBuilder(param: ConfigAddBindSheetTitleBuilderParam){
  // 主副标题 START
  Row(){
    Column(){
      // TODO 国际化
      Text(param.mainTitle)
        .fontWeight(param.mainTitleFontWeight?? FontWeight.Bold)
        .fontSize(param.mainTitleFontSize)
        .fontColor($r('sys.color.font_primary'))
        .lineHeight(24)
        // .animation({ duration: 200, curve: Curve.Ease })
      if (param.subTitle != null && param.subTitle != ''){
        Text(param.subTitle)
          .fontSize(param.subTitleFontSize??14)
          .fontColor($r('sys.color.font_secondary'))
          .lineHeight(16)
          // .animation({ duration: 200, curve: Curve.Ease })
      }
    }
    .alignItems(HorizontalAlign.Start)
    .height(param.subTitle != null && param.subTitle != '' ? param.mainTitleFontSize * 2 : param.mainTitleFontSize )
    .padding({ left: param.isSubPage ? param.titlePaddingLeft??0 : 0 })
    .animation({ duration: 200, curve: Curve.Ease })

  }
  .height('100%')
  .width('auto')
  .alignItems(VerticalAlign.Center)
  .padding(param.isSubPage ? 0 : param.padding)
  // .sharedTransition('configAddBindSheetTitle', { duration: 300, curve: Curve.Ease } )
  // .animation({ duration: 200, curve: Curve.Ease })
  // 主副标题 END
}

/* bindSheet 配合 `Navigation`、`NavDestination`的`title`属性使用的自定义`Title`组件`Builder` END */