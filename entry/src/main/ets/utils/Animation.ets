/*
转场等动画参数配置
 */

import { UIConfig } from "../entryability/AppState"
import { curves } from "@kit.ArkUI"


let effectEvent: TransitionEffect | null
let clickEffect: ClickEffect | null
let iconEffect: SymbolEffectStrategy | null
export class isON{toggleAnim: boolean = false}

class AnimationUtil{

  //转场缩放动画，i为延迟，在list或者foreach中可以将i设为index，达到递增的动画效果，uiConfig为动画速度以及开关的切换
  public isScaleTran(i:number,uiConfig:UIConfig){
    effectEvent=
    uiConfig.isAnimation ?
    TransitionEffect.OPACITY
      .combine(TransitionEffect.scale({x: 0, y: 0}))
      .animation({ duration: uiConfig.animationSpeed,curve:curves.springMotion(),delay: i*10+30 })
      :null

    return effectEvent
  }

  //转场滑动动画（从左到右），i为直接延迟数值，uiConfig为动画速度以及开关的切换
  public isSlide(i:number,uiConfig:UIConfig){
    effectEvent=
      uiConfig.isAnimation ?
      TransitionEffect.OPACITY
        .animation({ duration: uiConfig.animationSpeed, curve:curves.springMotion(),delay: i })
        .combine(TransitionEffect.SLIDE):null

    return effectEvent
  }

  //转场滑动动画（从下到上），i为直接延迟数值，uiConfig为动画速度以及开关的切换
  public isSlideBottom(i:number,uiConfig:UIConfig){
    effectEvent=
      uiConfig.isAnimation ?
      TransitionEffect.OPACITY
        .animation({ duration: uiConfig.animationSpeed, curve:curves.springMotion(),delay: i })
        .combine(TransitionEffect.translate({y:'100%'})):null
    {}

    return effectEvent
  }

  //右下角按钮滑动动画（从右到左），uiConfig为动画速度以及开关的切换
  public isSlideSwitch(uiConfig:UIConfig){
  effectEvent=
    uiConfig.isAnimation ?
      uiConfig.buttonPositionIndex===0 ?
    TransitionEffect.asymmetric(
        TransitionEffect.OPACITY
        .animation({ duration: uiConfig.animationSpeed, curve: curves.springMotion(), delay: 50 })
        .combine(TransitionEffect.SLIDE_SWITCH),

      TransitionEffect.OPACITY
        .animation({ duration: uiConfig.animationSpeed, curve: curves.springMotion(), delay: 50 })
        .combine(TransitionEffect.SLIDE)
    ):
        uiConfig.buttonPositionIndex===2 ?
      TransitionEffect.asymmetric(
        TransitionEffect.OPACITY
          .animation({ duration: uiConfig.animationSpeed, curve: curves.springMotion(), delay: 50 })
          .combine(TransitionEffect.SLIDE),

        TransitionEffect.OPACITY
          .animation({ duration: uiConfig.animationSpeed, curve: curves.springMotion(), delay: 50 })
          .combine(TransitionEffect.SLIDE_SWITCH)
      ):
          ( TransitionEffect.OPACITY
            .animation({ duration: uiConfig.animationSpeed, curve: curves.springMotion(), delay: 50 })
            .combine(TransitionEffect.SLIDE_SWITCH))
        :null

    return effectEvent
  }

  //底部tabs转场动画，uiConfig为动画速度以及开关的切换
  public isTranslate(uiConfig:UIConfig){
    effectEvent=
      uiConfig.isAnimation ? TransitionEffect.OPACITY
        .animation({ duration: uiConfig.animationSpeed, delay: 0 })
        .combine(TransitionEffect.translate({ y: 50 })) : null
    return effectEvent
  }

  //点击动效，uiConfig为开关的切换
  public isClickEffect(uiConfig:UIConfig){
    clickEffect =
    uiConfig.isAnimation ? { level: ClickEffectLevel.MIDDLE,scale:0.95} : null

    return clickEffect
  }

  //图标动效，uiConfig为开关的切换
  public isIconEffect(uiConfig:UIConfig){
    iconEffect =
      uiConfig.isAnimation ? SymbolEffectStrategy.SCALE : null

    return iconEffect
  }

  //配置添加，更多页，设置页图标转场缩放动画，i为延迟，在list或者foreach中可以将i设为index，达到递增的动画效果，uiConfig为动画速度以及开关的切换
  public isScaleTranIcon(i:number,uiConfig:UIConfig){
    effectEvent=
      uiConfig.isAnimation ?
      TransitionEffect.scale({x: 0, y: 0})
        .combine(TransitionEffect.rotate({angle:360}))
        .animation({ duration: uiConfig.animationSpeed,curve:curves.springMotion(),delay: i*10+50 })
        :null
    return effectEvent
  }
}

/*
转场动画使用方法:
* .transition(customAnimationUtil.isScaleTran(延迟参数（最好是index，自带计算递增效果）,this.uiConfig))
点击动效动画使用方法:
* .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
图标动效使用方法
* .effectStrategy(customAnimationUtil.isIconEffect(this.uiConfig))
 */
export const customAnimationUtil = new AnimationUtil()


