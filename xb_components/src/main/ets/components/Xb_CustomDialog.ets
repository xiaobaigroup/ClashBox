/* 通用组件 */
import { ThemeType } from "../entity/Common";
import { BORDER_RADIUS_24, PADDING_VALUE_12, PADDING_VALUE_16 } from "./Constants";



// 通用组件#对话框通用组件
@CustomDialog
export struct Xb_CustomDialog {
  controller?: CustomDialogController;
  titleText?: ResourceStr
  buttons: ResourceStr[] = [$r("app.string.xb_cancel"), $r("app.string.xb_confirm")]
  onButtonClick: (button: ResourceStr, index: number) => void = () => {}

  @BuilderParam center: () => void = this.centerUse
  @Builder centerUse(){ }
  @BuilderParam customTitle?: () => void
  @BuilderParam customButton: (controller?: CustomDialogController) => void


  @Builder
  DialogButton(label:ResourceStr, index: number){
    Button(label)
      .width(120)
      .fontColor(index == this.buttons.length - 1 ? Color.White : $r("app.color.emphasize"))
      .backgroundColor(index == this.buttons.length - 1 ? $r("app.color.emphasize") : Color.Transparent)
      .onClick(() => {
        if (label == $r("app.string.xb_cancel")){
          this.controller?.close()
        }
        this.onButtonClick(label, index)
      })
  }

  build() {
    Column({space: 8}) {
      if (this.customTitle){
        this.customTitle()
      } else {
        Text(this.titleText)
          .fontSize(20)
          .fontColor($r('app.color.font_color'))
          .fontWeight(FontWeight.Bold)
      }
      this.center()
      Blank().height(5)
      if (!this.customButton){
        Row({space: 10}){
          Repeat<ResourceStr>(this.buttons)
            .each((ri: RepeatItem<ResourceStr>) => {
              this.DialogButton(ri.item, ri.index)
            })
        }.justifyContent(FlexAlign.SpaceAround).width("100%")
      } else {
        this.customButton(this.controller)
      }
    }
    .borderRadius(32)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.SpaceAround)
    .padding({top: 10, bottom: 10, left: PADDING_VALUE_12, right: PADDING_VALUE_12 })
  }
}



//通用组件#对话框点击打开通用回调
export function DialogOpen(d: CustomDialogController | null) {
  if (d != null) {
    d.open();
  }
}


//通用组件#圆形按钮通用组件
@Builder
export function CircleButton(icon: Resource, change: string, iconSize: string | number | Resource){
  Stack() {
    Button({ type: ButtonType.Circle })
      .fontSize(40)
      .backgroundColor(change == 'title' ? colorChange.color1 :
        change == 'sure' ? colorChange.color2 : change == 'vGamepad' ? colorChange.color3 : $r("app.color.home_title_icon_background"))
    SymbolGlyph(icon)
      .fontSize(iconSize)
      .fontColor([Color.White])
  }
}

//要让Builder全局组件能传入变量，变量需要写入类里
@ObservedV2
export class ColorChange {
  color1:ResourceColor = $r("app.color.home_title_icon_background")
  @Trace color2: ResourceColor = $r("app.color.home_title_icon_background")
  @Trace color3: ResourceColor = $r("sys.color.icon_emphasize")
}

export const colorChange: ColorChange = new ColorChange()

//关于页#通用图标LOGO组件
@ComponentV2
export struct IconLogo{
  @Require @Param icon: Resource
  @Require @Param text1: string
  @Require @Param text2: string | Resource

  build() {
    Column(){
      Image(this.icon)
        .size({width: 80, height: 80})
        .borderRadius(BORDER_RADIUS_24)
      Text(this.text1)
        .logoText(20, Color.White, FontWeight.Bold)
        .padding({ top: 16, bottom:4 })
      Text(this.text2)
        .logoText(16, $r("sys.color.font_on_secondary"), FontWeight.Normal)
    }.height(207).width('100%').alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
    .padding({left: PADDING_VALUE_16, right: PADDING_VALUE_16})
  }
}

//关于页#logo文本样式
@Extend(Text)
function logoText(s: number , c: ResourceColor, w: FontWeight){
  .fontSize(s)
  .fontColor(c)
  .fontWeight(w)
}


//分组list样式
@Extend(ListItemGroup)
function listItemGroup(){
  .borderRadius(BORDER_RADIUS_24)
  .padding({left: PADDING_VALUE_12, right: PADDING_VALUE_12})
  .backgroundColor($r("app.color.settings_list_background"))
  .divider({ color: $r("app.color.divider_light"),
    strokeWidth: 1,})
}
