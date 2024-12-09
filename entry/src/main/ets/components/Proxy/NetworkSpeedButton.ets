import { ANIMATION_DURATION_300 } from '../../common/Constants'


@Entry
@Component
struct NetworkSpeedButton {

  // 代理启动按钮状态
  @State
  private proxyEnabled: boolean = false
  // 按钮前Symbol动效
  private ReplaceSymbolEffect: SymbolEffect = EffectScope.WHOLE
  private proxyStartButtonHeight: Length = $r('app.integer.vp_proxy_not_start_button_height')

  build() {
    Column() {
      Button() {
        Stack({ alignContent: Alignment.Center }) {
          SymbolGlyph($r('sys.symbol.bolt_filled_on_circle'))
            .fontSize(24)
            .fontColor([Color.White])
            .symbolEffect(this.ReplaceSymbolEffect)
            .align(Alignment.Center)
        }.width('100%')
      }
      .shadow({
        radius: 10,
        color: $r('app.color.speed_down_icon'),
        offsetY: 4,
        type: ShadowType.BLUR
      })
      .margin($r('app.integer.vp_proxy_start_button_margin') )
      .width(50)
      .height(this.proxyStartButtonHeight)
      .clip(true)
      .onClick((event: ClickEvent) => {
      })
      .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Ease })
      .clickEffect({ level: ClickEffectLevel.MIDDLE })
    }
  }
}


export default NetworkSpeedButton