import { customAnimationUtil } from "../../common/utils/Animation"
import { UIConfig } from "../../entryability/AppState"
import { curves } from "@kit.ArkUI"


@Component
export struct RoundButton {

  @StorageProp('EnableAPIVersion') apiVersionEnable: boolean = false
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @Prop buttonColor?: ResourceColor = undefined
  @Prop buttonSize?: Length = undefined
  @Prop needMargin: boolean = true
  @Prop Switch: boolean = false
  @Prop SubText: string = ''
  @Prop Icon1: Resource
  @Prop Icon2: Resource

  build() {
    Column() {
      Row() {
        if (this.uiConfig.tabStyle == 'custom' || !this.apiVersionEnable) {
          Stack({ alignContent: Alignment.Center }) {
            SymbolGlyph(this.Switch ? this.Icon1 : this.Icon2)
              .fontSize(24)
              .fontColor([Color.White])
              .align(Alignment.Center)
              .effectStrategy(customAnimationUtil.isIconEffect(this.uiConfig))
          }
          .width(this.Switch ? 26 : $r('app.integer.vp_proxy_not_start_button_height'))
          .height(this.Switch ? 36 : $r('app.integer.vp_proxy_not_start_button_height'))
        }
        // 计时器文本
        Text(this.SubText)
          .fontSize(20) // 使用透明度控制是否显示计时器，是因为用 `visibility` 来控制的话，不显示的时间长了之后，再次显示时候会延迟一秒，体验不好
          .fontColor(this.Switch ? Color.White : Color.Transparent)
          .fontWeight(FontWeight.Bold)
      }.width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
    .borderRadius(100)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .margin(this.needMargin ? { bottom: $r('app.integer.vp_proxy_start_button_left_right_margin'), right: $r('app.integer.vp_proxy_start_button_left_right_margin'), left: $r('app.integer.vp_proxy_start_button_left_right_margin') } : undefined)
    .transition(customAnimationUtil.isSlideSwitch(this.uiConfig))
    .backgroundColor(this.buttonColor ?? this.icon_emphasize)
    .shadow({
      radius: 10,
      color: this.icon_emphasize,
      offsetY: 4,
      type: ShadowType.BLUR
    })
    .width(this.Switch ? (this.uiConfig.tabStyle == 'float' ? 120 : $r('app.integer.vp_proxy_started_button_width')) : this.buttonSize ?? $r('app.integer.vp_proxy_not_start_button_width'))
    .height(this.buttonSize ?? $r('app.integer.vp_proxy_not_start_button_height'))
    .clip(true)
    .animation({ duration: this.uiConfig.animationSpeed,curve: curves.springMotion() })
    .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
  }

}