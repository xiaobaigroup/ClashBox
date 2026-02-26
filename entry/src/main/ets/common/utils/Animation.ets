/*
转场等动画参数配置
 */

import { UIConfig } from "../../entryability/AppState"
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

  //转场缩放动画(延迟小)，i为延迟，在list或者foreach中可以将i设为index，达到递增的动画效果，uiConfig为动画速度以及开关的切换
  public isScaleTranFast(i:number,uiConfig:UIConfig){
    effectEvent=
      uiConfig.isAnimation ?
      TransitionEffect.scale({x: 0.7, y: 0.7})
        .animation({ duration: uiConfig.animationSpeed,curve:curves.springMotion(),delay: i*2+10 })
        :null

    return effectEvent
  }

  //转场隐显动画
  public isOpacity(uiConfig:UIConfig){
    effectEvent=
      uiConfig.isAnimation ?
      TransitionEffect.OPACITY
        .animation({ duration: uiConfig.animationSpeed,curve:Curve.Ease,delay: 0 })
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

  //转场滑动动画（从右到左边），i为直接延迟数值，uiConfig为动画速度以及开关的切换
  public isSlideR(i:number,uiConfig:UIConfig){
    effectEvent=
      uiConfig.isAnimation ?
      TransitionEffect.OPACITY
        .animation({ duration: uiConfig.animationSpeed, curve:curves.springMotion(),delay: i })
        .combine(TransitionEffect.translate({x:20})):null

    return effectEvent
  }

  //转场放大动画，i为直接延迟数值，uiConfig为动画速度以及开关的切换
  public isSlideScaleBig(i:number,uiConfig:UIConfig){
    effectEvent=
      uiConfig.isAnimation ?
      TransitionEffect.OPACITY
        .animation({ duration: uiConfig.animationSpeed, curve:curves.springMotion(),delay: i })
        .combine(TransitionEffect.scale({x:0,y:0})):null
    {}

    return effectEvent
  }

  //转场放大动画，i为直接延迟数值，uiConfig为动画速度以及开关的切换
  public isSlideScaleBigMove(uiConfig:UIConfig){
    effectEvent=
      uiConfig.isAnimation ?
        TransitionEffect.OPACITY
          .animation({ duration: 50, curve: Curve.Linear,delay: 0 })
          .combine(TransitionEffect.scale({x:0,y:0})):null
    {}

    return effectEvent
  }

  //转场缩小动画，i为直接延迟数值，uiConfig为动画速度以及开关的切换
  public isSlideScaleSmall(i:number,uiConfig:UIConfig){
    effectEvent=
      uiConfig.isAnimation ?

      TransitionEffect.asymmetric(
        TransitionEffect.OPACITY
          .animation({ duration: uiConfig.animationSpeed, curve:curves.springMotion(),delay: i })
          .combine(TransitionEffect.scale({x:2,y:2})),

        TransitionEffect.OPACITY
          .animation({ duration: uiConfig.animationSpeed, curve:curves.springMotion(),delay: i })
          .combine(TransitionEffect.translate({y:-5}))
      ) :null
    {}

    return effectEvent
  }


  // 右下角按钮滑动动画（从右到左），uiConfig为动画速度以及开关的切换
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

  /**
   * 右侧悬浮按钮转场：固定 END 方向
   * @param uiConfig 动画配置（开关、速度）
   * @returns TransitionEffect 或 null（动画关闭时）
   */
  public rightTransition(uiConfig: UIConfig): TransitionEffect | null {
    if (!uiConfig.isAnimation) return null
    return TransitionEffect.asymmetric(
      TransitionEffect.move(TransitionEdge.END)
        .animation({ duration: uiConfig.animationSpeed, curve: curves.springMotion(0.5, 0.7) }),
      TransitionEffect.move(TransitionEdge.END)
        .animation({ duration: 400, curve: curves.springMotion(0.5, 0.7) })
    )
  }

  /**
   * 左侧悬浮按钮转场：固定 START 方向
   * @param uiConfig 动画配置（开关、速度）
   * @returns TransitionEffect 或 null（动画关闭时）
   */
  public leftTransition(uiConfig: UIConfig): TransitionEffect | null {
    if (!uiConfig.isAnimation) return null
    return TransitionEffect.asymmetric(
      TransitionEffect.move(TransitionEdge.START)
        .animation({ duration: uiConfig.animationSpeed, curve: curves.springMotion(0.5, 0.7) }),
      TransitionEffect.move(TransitionEdge.START)
        .animation({ duration: 400, curve: curves.springMotion(0.5, 0.7) })
    )
  }

  /**
   * 中间悬浮按钮转场：纯透明度
   * @param uiConfig 动画配置（开关、速度）
   * @returns TransitionEffect 或 null（动画关闭时）
   */
  public centerTransition(uiConfig: UIConfig): TransitionEffect | null {
    if (!uiConfig.isAnimation) return null
    return TransitionEffect.OPACITY
      .animation({ duration: uiConfig.animationSpeed, curve: curves.springMotion(0.5, 0.7) })
  }

  /**
   * 根据悬浮按钮位置索引返回对应转场效果
   * @param uiConfig 动画配置
   * @param positionIndex 0=右侧, 1=中间, 2=左侧
   */
  public getFloatButtonTransition(uiConfig: UIConfig, positionIndex: number): TransitionEffect | null {
    return positionIndex === 2 ? this.leftTransition(uiConfig) :
      positionIndex === 0 ? this.rightTransition(uiConfig) : this.centerTransition(uiConfig)
  }
}

/*
转场动画使用方法:
* .transition(customAnimationUtil.isScaleTran(延迟参数（最好是index，自带计算递增效果）,this.uiConfig))
点击动效动画使用方法:
* .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
图标动效使用方法
* .effectStrategy(customAnimationUtil.isIconEffect(this.uiConfig))
悬浮按钮转场使用方法（配置页/代理页）:
* .transition(customAnimationUtil.getFloatButtonTransition(this.uiConfig, this.uiConfig.buttonPositionIndex))
* 或单独使用: rightTransition/leftTransition/centerTransition(uiConfig)
 */
export const customAnimationUtil = new AnimationUtil()


