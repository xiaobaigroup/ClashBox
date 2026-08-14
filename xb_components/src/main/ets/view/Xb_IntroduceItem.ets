import { Xb_Global } from "../entity/XbGlobal"
import { RightStyle, SettingsItem } from "../settings/SettingsCommonOp"
import { customVibrator } from "../utils/Vibrator"
import { Xb_AnimationStyle } from "../utils/Animation"

@ComponentV2
export struct IntroduceItem {
  @Require @Param item: SettingsItem
  @Param space: number = 12
  @Param heightAll: Length = 56

  @Param SymbolFontColor: ResourceColor = Xb_Global.icon_emphasize

  build() {
    Row(){
      Row({ space: this.space }){
        if (this.item.rightStyle == RightStyle.BUTTON){
          Image(this.item.icon)
            .borderRadius(100)
            .aspectRatio(1)
            .size({width: 40, height: 40})
              //.transition(Xb_AnimationStyle.isIcon())
            .scale({x: Xb_AnimationStyle.scaleSize, y: Xb_AnimationStyle.scaleSize})
            .rotate({angle: Xb_AnimationStyle.rotateSize})
            .onAppear(()=>{
              Xb_AnimationStyle.iconAnim()
            })
            .animation(Xb_AnimationStyle.animNormalUtils(0))
        } else {
          SymbolGlyph(this.item.icon)
            .fontColor([this.SymbolFontColor])
            .fontSize(24)
              //.transition(Xb_AnimationStyle.isIcon())
            .scale({x: Xb_AnimationStyle.scaleSize, y: Xb_AnimationStyle.scaleSize})
            .rotate({angle: Xb_AnimationStyle.rotateSize})
            .onAppear(()=>{
              Xb_AnimationStyle.iconAnim()
            })
            .animation(Xb_AnimationStyle.animNormalUtils(0))
        }
        Column({space: 2}){
          Text(this.item.contentL)
            .fontSize(16)
          Text(this.item.contentSecL)
            .fontColor($r("sys.color.icon_tertiary"))
            .fontSize(14)
        }.alignItems(HorizontalAlign.Start)
      }.alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Start)

      if (this.item.rightStyle == RightStyle.JUMP){
        SymbolGlyph($r("sys.symbol.chevron_right")).menuSymbolGlyph(24)
          .hitTestBehavior(HitTestMode.None)
      }else if (this.item.rightStyle == RightStyle.TEXT){
        Text(this.item.contentR)
          .fontSize(14)
          .fontColor($r("sys.color.icon_on_tertiary"))
      }else if (this.item.rightStyle == RightStyle.BUTTON){
        Button(this.item.contentR,{type: ButtonType.Capsule})
          .fontSize(12).fontColor(Xb_Global.icon_emphasize)
          .backgroundColor($r("app.color.settings_list_background"))
          .height(26)
          .onClick(()=>{
            if (this.item.onClick) this.item.onClick()
            customVibrator.vibratorTriggerOfHapticClockTimer()
          })
          .clickEffect(Xb_AnimationStyle.isClick())
      }
    }.width('100%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.SpaceBetween).height(this.heightAll)
  }
}

@Extend(SymbolGlyph)
function menuSymbolGlyph(s: number){
  .fontSize(s).fontColor([$r("sys.color.icon_on_tertiary")])
}