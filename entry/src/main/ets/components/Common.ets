import {
  ANIMATION_DURATION_300,
  BIND_SHEET_DRAG_BAR_HEIGHT,
  BIND_SHEET_TITLE_CONTAINER_HEIGHT,
  BIND_SHEET_TITLE_LEFT_SYMBOL_HEIGHT,
  BIND_SHEET_TITLE_LEFT_SYMBOL_WEIGHT,
  TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE,
  FONT_SIZE_16
} from "../common/Constants"
import { getResourceString } from "../utils/ResourceStringUtil"

/* 通用属性 START */
@Styles
function outerLayerContainerCommonStyles(){
  .padding( FONT_SIZE_16 )
  .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Ease })
}
/* 通用属性 END */


/* bindSheet 里套 `Navigation`、`NavDestination`是的标题栏的替代品 START */
// XXX 前提：不使用NavDestination的标题栏.hideTitleBar(true)。不使用`bindSheet`的`dragBar`，仅使用`bindSheet`自带的`close`按钮。

/*
 * 不在`.title`属性里设置这个`Builder`标题组件是因为`bindSheet`里使用NV的话，用自带返回按钮和标题栏的有很多问题，
 *    比如NV返回按钮和打开了`dragBar的`bindSheet`自带的叉号不在同一个水平线
 *    比如不使用`bindSheet`自带的关闭按钮，叉号不能保持自带的叉号类似`fixed`的固定位置，体验不好
 *    比如切换路由的时候返回按钮下面会短暂的变透明、给标题栏设置背景颜色后，自带的返回按钮依然是默认背景颜色
 *    由于api12没有单独隐藏返回按钮的api，所以v这是在直接隐藏了整个标题栏 `.hideTitleBar(true)` 的情况下使用的bindSheet套NV的通用标题栏
 */

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
  mainTitle: ResourceStr,
  // 副标题（`isSubPage`为`true`的时候生效）（下文中`subTitle`开头的属性是副标题的样式属性)
  subTitle?: ResourceStr,
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
        .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Ease })
      if (param?.subTitle != undefined && param.subTitle != ''){
        Text(param.subTitle)
          .fontSize(param.subTitleFontSize??14)
          .fontColor($r('sys.color.font_secondary'))
          .lineHeight(16)
          .maxLines(1)
          .textOverflow({overflow: TextOverflow.MARQUEE})
          .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Ease })
      }
    }
    .alignItems(HorizontalAlign.Start)
    // 避让菜单menus、返回按钮（所以param.menus.length + 1）
    .width(`calc(100% - ${(BIND_SHEET_TITLE_LEFT_SYMBOL_WEIGHT + 10) * (param.menus.length + 1)}vp)`)
    .height(param.subTitle != null && param.subTitle != '' ? param.mainTitleFontSize * 2 : param.mainTitleFontSize )
    .padding({ left: param.isSubPage ? param.titlePaddingLeft??0 : 0 })
    .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Ease })
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
        .transition(
          TransitionEffect.OPACITY.animation({duration: ANIMATION_DURATION_300, delay:0})
            .combine(
              TransitionEffect.asymmetric(
                TransitionEffect.move(TransitionEdge.END),
                TransitionEffect.move(TransitionEdge.END)
              )
            )
        )
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
  // .sharedTransition('configAddBindSheetTitle', { duration: ANIMATION_DURATION_300, curve: Curve.Ease } )
  // .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Ease })
}

/* bindSheet 里套 `Navigation`、`NavDestination`是的标题栏的替代品 START */


/* `Confirm`类型的`CustomDialog` START */
// XXX 注意副标题不要太长，否则副标题会折行到按钮组下面，则需要修改`Text`外层添加`Scroll`组件

@CustomDialog
export struct CustomConfirmDialog {
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor

  title: ResourceStr = 'No Title!'
  subTitle?: ResourceStr

  controller?: CustomDialogController
  name? :ResourceStr = ''
  // 取消事件
  cancel: () => void = () => {}
  // 取消按钮 文本内容
  cancelText: ResourceStr = 'Cancel'
  // 取消按钮 字体颜色
  cancelFontColor? : ResourceColor = $r('sys.color.warning')
  // 取消按钮 按钮背景颜色
  cancelButtonBackgroundColor?: ResourceColor = Color.Transparent
  // 确认按钮 事件
  confirm: () => void = () => {}
  // 确认按钮 文本内容
  confirmText: ResourceStr = 'Confirm'
  // 确认按钮 按钮背景颜色
  confirmButtonBackgroundColor?: ResourceColor = $r('sys.color.ohos_id_color_button_normal')


  build() {
    Column({ space: FONT_SIZE_16 }) {
      // 主标题 START
      Row(){
        Text(this.title)
          .fontSize(20)
          .lineHeight(23)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
      }
      // .height(55)
      // 主标题 END

      // 副标题 START
      if (this.subTitle != undefined) {
        Row(){
          Text(this.subTitle)
            .fontSize(FONT_SIZE_16)
            .lineHeight(20)
            .fontColor($r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Bold)
        }
        // .height(55)
      }
      // 副标题 END

      // Blank()

      // 按钮组 START
      Row(){
        Button(this.cancelText)
          .width(144)
          .fontSize(FONT_SIZE_16)
          .fontColor(this.cancelFontColor)
          .backgroundColor(this.cancelButtonBackgroundColor)
          .onClick(() => {
            if (this.controller != undefined) {
              this.cancel()
              this.controller.close()
            }
          })
        Text(' ').width(8)
        Button(this.confirmText)
          .width(144)
          .height('100%')
          .fontSize(FONT_SIZE_16)
          .fontColor($r('sys.color.font_on_primary'))
            // .backgroundColor(this?.confirmButtonBackgroundColor ?? $r('sys.color.comp_background_emphasize'))
          .backgroundColor(this.icon_emphasize ?? $r('sys.color.comp_background_emphasize'))
          .onClick(() => {
            if (this.controller != undefined) {
              this.confirm()
              this.controller.close()
            }
          })
      }
      .height(40)
      // 按钮组 END
    }
    .alignItems(HorizontalAlign.Center)
    .outerLayerContainerCommonStyles()
  }
}
/* `Confirm`类型的`CustomDialog` END */


/* 下载中`CustomDialog`小型弹框 START */
@CustomDialog
export struct CustomDownloadingDialog {

  controller?: CustomDialogController

  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor

  title: ResourceStr = 'No Title!'
  // 取消下载事件
  cancel: () => void = () => {}
  // 取消下载按钮 文本内容
  cancelText: ResourceStr = 'Cancel'
  // 取消下载按钮 字体颜色
  cancelFontColor? : ResourceColor = $r('sys.color.warning')
  // 取消下载按钮 按钮背景颜色
  cancelButtonBackgroundColor?: ResourceColor = $r('sys.color.comp_background_tertiary')


  build() {
    Column() {
      // 主标题 START
      Text(this.title)
        .fontSize(20)
        .lineHeight(23)
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Bold)
      // 主标题 END

      // 加载动画 START
      Stack({ alignContent: Alignment.Center }){
        LoadingProgress()
          .color($r('sys.color.icon_secondary'))
          .width(40)
          .height(40)
      }
      .width('100%')
      .height(72)
      // 加载动画 END

      // 取消下载按钮 START
      Button(this.cancelText)
        .width('100%')
        .height(40)
        .fontSize(FONT_SIZE_16)
        .fontColor(this.cancelFontColor)
        .backgroundColor(this.cancelButtonBackgroundColor)
        .onClick(() => {
          if (this.controller != undefined) {
            this.cancel()
            this.controller.close()
          }
        })
    }
    // 取消下载按钮 END
    .alignItems(HorizontalAlign.Center)
    .outerLayerContainerCommonStyles()
  }

}
/* 下载中`CustomDialog`小型弹框 END */

/**
 * 开启&关闭提示弹窗组件（横排按钮）
 * @param leftButton 传入自定义左按钮
 */
@CustomDialog
export struct theRowCustomDialog {
  @State theDialogTitle: ResourceStr = ''
  @State contentText: ResourceStr = ''
  cancel?: () => void
  confirm?: () => void
  controller: CustomDialogController
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @BuilderParam leftButton: () => void = this.defaultBuilder
  // 默认的左按钮(蓝色字体开启)
  @Builder
  defaultBuilder() {
    Button($r('app.string.open'))
      .width('100%')
      .height(39)
      .fontColor(this.icon_emphasize)
      .backgroundColor($r('app.color.container_background'))
  }

  build() {
    Column() {
      // 标题
      Text(this.theDialogTitle)
        .fontWeight(FontWeight.Medium)
        .fontSize(20)
        .margin({ bottom: 15 })
      // 内容文本
      Text(this.contentText)
        .fontWeight(FontWeight.Regular)
        .fontSize(18)
        .margin({bottom: 8 })
      Row() {
        // 左按钮
        Row() {
          this.leftButton()
        }.width('50%')
        .onClick(() => {
          this.controller.close()
          if (this.confirm) {
            this.confirm()
          }
        })
        Button($r('app.string.Cancel'))
          .height(39)
          .width('50%')
          .fontColor(Color.White)
          .backgroundColor(this.icon_emphasize)
          .onClick(() => {
            this.controller.close()
            if (this.cancel) {
              this.cancel()
            }
          })
      }.width('100%')
    }
    .padding({left: 16, right: 16, top: 15, bottom: 15})
    .backgroundColor($r('app.color.container_background'))
    .width('100%')
  }
}

/**
 * 通用保存&取消弹窗组件（竖排按钮）
 * @param theDialogTitle 弹窗标题-ResourceStr
 * @param theplaceholder 输入框默认文本-ResourceStr
 * @param SaveInputValue 保存的输入值-string
 * @param currentInputValue 实时的输入值-string
 */
@CustomDialog
export struct theCustomDialog {
  @Link SaveInputValue: string
  @Link currentInputValue: string
  @Link theplaceholder: string
  @State theDialogTitle: ResourceStr = ''
  cancel?: () => void
  confirm?: () => void
  controller: CustomDialogController
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor

  build() {
    Column() {
      Text(this.theDialogTitle)
        .fontWeight(FontWeight.Medium)
        .fontSize(20)
        .margin({ top: 15, bottom: 15 })
      TextArea({placeholder: this.theplaceholder, text: this.currentInputValue })
        .onChange((value: string) => {
          this.currentInputValue = value
        })
        .margin({bottom: 8 })
      Button($r('app.string.Save'))
        .width('100%')
        .height(39)
        .onClick(() => {
          this.SaveInputValue = this.currentInputValue
          this.currentInputValue = this.theplaceholder
          this.controller.close()
          if (this.confirm) {
            this.confirm()
          }
        })
        .backgroundColor(this.icon_emphasize)
        .fontColor(Color.White)
      Button($r('app.string.Cancel'))
        .height(39)
        .width('100%')
        .fontColor(this.icon_emphasize)
        .backgroundColor($r('app.color.container_background'))
        .onClick(() => {
          this.controller.close()
          if (this.cancel) {
            this.cancel()
          }
        })
    }
    .padding(16)
    .backgroundColor($r('app.color.container_background'))
    .width('100%')
  }
}

/**
 * 实验功能提示框
 */
@Component
export struct ExperimentalFunction {
  @Consume('icon_emphasize') icon_emphasize: ResourceColor

  build() {
    Column() {
      Text($r('app.string.experimental_function'))
        .fontColor(Color.White)
        .fontSize(10)
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width(50)
    .height(18)
    .borderRadius(4)
    .margin({left: 2})
    .backgroundColor(this.icon_emphasize)
  }
}

/**
 * 页面暂无XX
 * @param name 页面标题(暂无XX)-Resource
 */
@Component
export struct Nothing {
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  //二级文本色，深灰色
  @State font_secondary: ResourceColor = $r('sys.color.font_secondary')
  // 页面标题
  @State name: Resource = $r('app.string.none')

  build() {
    Column() {
      SymbolGlyph($r('sys.symbol.doc'))
        .fontSize(32)
        .fontColor([this.icon_primary])
        .margin({bottom: 4 })
      Text(getResourceString($r('app.string.none'), this) + getResourceString(this.name, this))
        .fontSize(20)
        .fontColor(this.font_secondary)
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}

/**
 * 列表Row共有样式
 */
@Extend(Row)
function RowStyle() {
  .width('100%')
  .height(53)
  .borderRadius(20)
  .clickEffect({ level: ClickEffectLevel.MIDDLE })
  .backgroundColor($r('app.color.container_background'))
}

/**
 * 跳转列表行通用组件
 * @param icons SymbolGlyph对应的系统资源文件地址-Resource
 * @param title 标题文本-ResourceStr
 * @param subtitle 副标题文本-ResourceStr
 * @param tips 传入自定义提示文本-Builder
 * @param isExperimentalFunction 是否为实验功能-boolean
 */
@Component
export struct skipRowList {
  @State icons?: Resource = undefined
  @State name: string = ''
  @State title: ResourceStr = ''
  @State subtitle: ResourceStr = ''
  @State isPrimaryIcons: boolean = false
  @State isExperimentalFunction: boolean = false
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 跳转行提示文本项
  @BuilderParam tips: () => void = this.defaultTipsBuilder
  // 默认跳转行提示文本
  @Builder
  defaultTipsBuilder() {
    Text('')
      .fontWeight(FontWeight.Normal)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .margin({top: 2 })
      .fontSize(14)
  }

  build() {
    Row() {
      if(this.icons) {
        SymbolGlyph(this.icons)
          .fontSize(24)
          .margin({left: 12})
          .fontColor([this.isPrimaryIcons ? this.icon_primary : this.icon_emphasize])
      }
      Column() {
        Row() {
          Text(this.title)
            .fontWeight(FontWeight.Medium)
            .geometryTransition(this.name)
            .fontSize(16)
          if(this.isExperimentalFunction) {
            ExperimentalFunction()
          }
        }
        if(this.subtitle) {
          Text(this.subtitle)
            .fontWeight(FontWeight.Normal)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .margin({top: 2})
            .fontSize(14)
        }
      }.layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      Blank()
      this.tips()
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(28)
        .margin({right: 12})
        .fontColor([this.icon_primary])
    }
    .RowStyle()
  }
}

/**
 * 开关列表行通用组件
 * @param icons SymbolGlyph对应的系统资源文件地址-Resource
 * @param title 标题文本-ResourceStr
 * @param subtitle 副标题文本-ResourceStr
 * @param toggle 尾随闭包内传入自定义开关
 */
@Component
export struct toggleRowList {
  // 标题
  @State title: ResourceStr = ''
  // 图标
  @State icons?: Resource = undefined
  // 副标题
  @State subtitle: ResourceStr = ''
  @State isPrimaryIcons: boolean = false
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  // 实验功能标识
  @State isExperimentalFunction: boolean = false
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 开关
  @BuilderParam toggle: () => void = this.defaultBuilder
  // 默认开关
  @Builder
  defaultBuilder() {
    Toggle({ type: ToggleType.Switch, isOn: false })
      .selectedColor(this.icon_emphasize)
      .margin({right: 12})
  }

  build() {
    Row() {
      if(this.icons) {
        SymbolGlyph(this.icons)
          .fontSize(24)
          .margin({left: 12})
          .fontColor([this.isPrimaryIcons ? this.icon_primary : this.icon_emphasize])
      }
      Column() {
        Row() {
          Text(this.title)
            .fontWeight(FontWeight.Medium)
            .fontSize(16)
          // 实验功能提示框
          if(this.isExperimentalFunction) {
            ExperimentalFunction()
          }
        }
        if(this.subtitle) {
          Text(this.subtitle)
            .fontWeight(FontWeight.Normal)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .margin({top: 2})
            .fontSize(14)
        }
      }.layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: this.icons != null ? 12 : 14 })
      Blank()
      this.toggle()
    }
    .RowStyle()
  }
}

/**
 * 菜单列表行通用组件
 * @param icons SymbolGlyph对应的系统资源文件地址-Resource
 * @param title 标题文本-ResourceStr
 * @param subtitle 副标题文本-ResourceStr
 * @param menu 传入自定义菜单入口组件-Builder
 * @param tips 传入自定义菜单提示文本组件-Builder
 */
@Component
export struct menuRowList {
  // 标题
  @State title: ResourceStr = ''
  // 图标
  @State icons?: Resource = undefined
  // 副标题
  @State subtitle: ResourceStr = ''
  @State isPrimaryIcons: boolean = false
  // 实验功能标识
  @State isExperimentalFunction: boolean = false
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  // 菜单
  @BuilderParam menu: () => void = this.defaultMenuBuilder
  // 默认菜单
  @Builder
  defaultMenuBuilder() {
    Menu()
  }
  // 菜单提示文本项
  @BuilderParam tips: () => void = this.defaultTipsBuilder
  // 默认菜单提示文本
  @Builder
  defaultTipsBuilder() {
    Text('')
      .fontWeight(FontWeight.Normal)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .margin({top: 2 })
      .fontSize(14)
  }

  build() {
    Row() {
      if(this.icons) {
        SymbolGlyph(this.icons)
          .fontSize(24)
          .margin({left: 12})
          .fontColor([this.isPrimaryIcons ? this.icon_primary : this.icon_emphasize])
      }
      Column() {
        Row() {
          Text(this.title)
            .fontWeight(FontWeight.Medium)
            .fontSize(16)
          // 实验功能提示框
          if(this.isExperimentalFunction) {
            ExperimentalFunction()
          }
        }
        if(this.subtitle) {
          Text(this.subtitle)
            .fontWeight(FontWeight.Normal)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .margin({ top: 2 })
            .fontSize(14)
        }
      }.layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
      Blank()
      // 菜单
      Row() {
        this.tips()
        SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
          .fontSize(14)
          .margin({left: 7, right: 20})
          .fontColor([this.icon_primary])
      }.bindMenu(this.menu())
    }
    .RowStyle()
  }
}