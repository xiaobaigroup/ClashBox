import { UIConfig } from "../entryability/AppState"
import { curves } from "@kit.ArkUI"

let effectHomeCard: TransitionEffect | null
let clickEffect_8: ClickEffect | null

class AnimationUtil{

  //转场缩放动画
  public isScaleTran(i:number,uiConfig:UIConfig){
    effectHomeCard=
    uiConfig.isAnimation ?
    TransitionEffect.OPACITY
      .combine(TransitionEffect.scale({x: 0, y: 0}))
      .animation({ duration: uiConfig.animationSpeed,curve:curves.springMotion(),delay: i*10+30 }):null
    return effectHomeCard
  }

  //转场滑动动画（从左到右）
  public isSlide(i:number,uiConfig:UIConfig){
    effectHomeCard=
      uiConfig.isAnimation ?
      TransitionEffect.OPACITY
        .animation({ duration: uiConfig.animationSpeed, curve:curves.springMotion(),delay: i })
        .combine(TransitionEffect.SLIDE):null
    return effectHomeCard
  }

  //右下角按钮滑动动画（从右到左）
  public isSlideSwitch(uiConfig:UIConfig){
  effectHomeCard=
    uiConfig.isAnimation ?
  TransitionEffect.OPACITY
  .animation({ duration: uiConfig.animationSpeed, curve: curves.springMotion(), delay: 50 })
  .combine(TransitionEffect.SLIDE_SWITCH) : null
    return effectHomeCard
  }

  //底部tabs转场动画
  public isTranslate(uiConfig:UIConfig){
    effectHomeCard=
      uiConfig.isAnimation ? TransitionEffect.OPACITY
        .animation({ duration: uiConfig.animationSpeed, delay: 0 })
        .combine(TransitionEffect.translate({ y: 50 })) : null
    return effectHomeCard
  }

  //点击动效
  public isClickEffect(uiConfig:UIConfig){
    clickEffect_8 =
    uiConfig.isAnimation ? { level: ClickEffectLevel.MIDDLE, scale: 0.8} : null

    return clickEffect_8
  }

}


export const customAnimationUtil = new AnimationUtil()


