import { UIConfig } from "../entryability/AppState"
import { curves } from "@kit.ArkUI"

let effectHomeCard: TransitionEffect | null
let clickEffect_8: ClickEffect | null

class AnimationUtil{

  //转场缩放动画，i为延迟，在list或者foreach中可以将i设为index，达到递增的动画效果，uiConfig为动画速度以及开关的切换
  public isScaleTran(i:number,uiConfig:UIConfig){
    effectHomeCard=
    uiConfig.isAnimation ?
    TransitionEffect.OPACITY
      .combine(TransitionEffect.scale({x: 0, y: 0}))
      .animation({ duration: uiConfig.animationSpeed,curve:curves.springMotion(),delay: i*10+30 }):null
    return effectHomeCard
  }

  //转场滑动动画（从左到右），i为直接延迟数值，uiConfig为动画速度以及开关的切换
  public isSlide(i:number,uiConfig:UIConfig){
    effectHomeCard=
      uiConfig.isAnimation ?
      TransitionEffect.OPACITY
        .animation({ duration: uiConfig.animationSpeed, curve:curves.springMotion(),delay: i })
        .combine(TransitionEffect.SLIDE):null
    return effectHomeCard
  }

  //右下角按钮滑动动画（从右到左），uiConfig为动画速度以及开关的切换
  public isSlideSwitch(uiConfig:UIConfig){
  effectHomeCard=
    uiConfig.isAnimation ?
  TransitionEffect.OPACITY
  .animation({ duration: uiConfig.animationSpeed, curve: curves.springMotion(), delay: 50 })
  .combine(TransitionEffect.SLIDE_SWITCH) : null
    return effectHomeCard
  }

  //底部tabs转场动画，uiConfig为动画速度以及开关的切换
  public isTranslate(uiConfig:UIConfig){
    effectHomeCard=
      uiConfig.isAnimation ? TransitionEffect.OPACITY
        .animation({ duration: uiConfig.animationSpeed, delay: 0 })
        .combine(TransitionEffect.translate({ y: 50 })) : null
    return effectHomeCard
  }

  //点击动效，uiConfig为开关的切换
  public isClickEffect(uiConfig:UIConfig){
    clickEffect_8 =
    uiConfig.isAnimation ? { level: ClickEffectLevel.MIDDLE,scale:0.93} : null

    return clickEffect_8
  }

}

//使用方法 customAnimationUtil.isScaleTran(延迟参数（最好是index，自带计算递增效果）,this.uiConfig)
export const customAnimationUtil = new AnimationUtil()


