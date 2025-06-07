import { customAnimationUtil } from "../../common/utils/Animation"
import { UIConfig } from "../../entryability/AppState"
import { curves } from "@kit.ArkUI"


@Component
export struct RoundButton {

  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @Prop Switch: boolean = false
  @Prop SubText: string = ''
  @Prop Icon1: Resource
  @Prop Icon2: Resource

  build() {
    Column() {
      Row() {
        Stack({ alignContent: Alignment.Center }) {
          SymbolGlyph(this.Switch ? this.Icon1 : this.Icon2)
            .fontSize(24)
            .fontColor([Color.White])
            .align(Alignment.Center)
            .effectStrategy(customAnimationUtil.isIconEffect(this.uiConfig))
        }
        .width($r('app.integer.vp_proxy_not_start_button_height'))
        .height($r('app.integer.vp_proxy_not_start_button_height'))
        // 计时器文本
        Text(this.SubText)
          .fontSize(20) // 使用透明度控制是否显示计时器，是因为用 `visibility` 来控制的话，不显示的时间长了之后，再次显示时候会延迟一秒，体验不好
          .fontColor(this.Switch ? Color.White : Color.Transparent)
          .fontWeight(FontWeight.Bold)
      }.width('100%')
    }
    .borderRadius(100)
    .transition(customAnimationUtil.isSlideSwitch(this.uiConfig))
    .backgroundColor(this.icon_emphasize)
    .shadow({
      radius: 10,
      color: this.icon_emphasize,
      offsetY: 4,
      type: ShadowType.BLUR
    })
    .margin({ bottom: $r('app.integer.vp_proxy_start_button_left_right_margin'), right: $r('app.integer.vp_proxy_start_button_left_right_margin'), left: $r('app.integer.vp_proxy_start_button_left_right_margin') })
    .width(this.Switch ? $r('app.integer.vp_proxy_started_button_width') : $r('app.integer.vp_proxy_not_start_button_width'))
    .height($r('app.integer.vp_proxy_not_start_button_height'))
    .clip(true)
    .animation(this.uiConfig.isAnimation ? { duration: this.uiConfig.animationSpeed,curve: curves.springMotion() } : null)
    .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
  }

}