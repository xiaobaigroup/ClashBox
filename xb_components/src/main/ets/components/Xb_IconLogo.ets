import { Xb_AnimationStyle } from "../utils/Animation"
import { BORDER_RADIUS_24, PADDING_VALUE_16 } from "./Constants"


// 通用LOGO-名称-介绍组件
@ComponentV2
export struct Xb_IconLogo {
  @Require @Param icon: Resource
  @Require @Param text1: ResourceStr
  @Param text2: ResourceStr = ''
  @Param text3?: ResourceStr = ''

  build() {
    Column(){
      Image(this.icon)
        .size({width: 80, height: 80})
        .borderRadius(BORDER_RADIUS_24)
      Text(this.text1)
        .logoText(20, undefined, FontWeight.Bold)
        .padding({ top: 16, bottom:4 })
      Text(this.text2)
        .logoText(16, $r("sys.color.font_secondary"), FontWeight.Normal)
        .padding({ bottom:4 })

      Text(this.text3)
        .logoText(12, $r("sys.color.font_tertiary"), FontWeight.Normal).textAlign(TextAlign.Center)
    }.height(207).width('100%').alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
    .padding({left: PADDING_VALUE_16, right: PADDING_VALUE_16})
    .transition(Xb_AnimationStyle.isScale())
  }
}

//关于页#logo文本样式
@Extend(Text)
function logoText(s: number , c?: ResourceColor, w?: FontWeight){
  .fontSize(s)
  .fontColor(c)
  .fontWeight(w)
}