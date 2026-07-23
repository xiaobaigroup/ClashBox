
/*
* 属性动画参数使用方法：.animation(Xb_AnimationStyle.animationUtils())
* 属性变化使用方法：Xb_AnimationStyle.attributeAnim(i为属性变化数值)
* 显示动画参数使用方法：Xb_AnimationStyle.animationUtils()
* 转场动画使用方法：.transition(Xb_AnimationStyle.isScale())
* 点击动效使用方法：.clickEffect(Xb_AnimationStyle.isClick())
* API18及以上使用显示动画，需要在ui实例处添加：
* private ctx: UIContext = this.getUIContext();
  aboutToAppear(): void {
    Xb_AnimationStyle.setContext(this.ctx)
  }
 */

import { curves } from "@kit.ArkUI"

// 通用动画参数
let animationUtils: AnimateParam
let transitionEffect: TransitionEffect
let clickEffect: ClickEffect

@ObservedV2
export class AnimationStyle {
  @Trace i?: number | string | FlexAlign | undefined
  @Trace translateY: number = 0
  @Trace scaleSize: number = 1
  @Trace rotateSize: number = 0
  @Trace heightRow: number | string = ''
  @Trace flexAlign: FlexAlign = FlexAlign.Start
  @Trace isShow: boolean = false

  /* 通用动画参数 */

  // 弹性动画参数
  public animSpringUtils() {
    animationUtils = {
      // 动画持续时长
      duration: 500,
      // 弹簧动画参数
      curve: curves.springMotion(0.5, 0.7, 0.6),
      // 动画播放次数
      iterations: 1,
      // 动画播放形式
      playMode: PlayMode.Normal,
      // 动画延迟
      delay: 50
    }
    return animationUtils
  }

  // 弹性动画参数
  public animSpringUtilsD(i: number) {
    animationUtils = {
      // 动画持续时长
      duration: 500,
      // 弹簧动画参数
      curve: curves.springMotion(0.5, 0.7, 0.6),
      // 动画播放次数
      iterations: 1,
      // 动画播放形式
      playMode: PlayMode.Normal,
      // 动画延迟
      delay: i * 30 + 50
    }
    return animationUtils
  }

  // 图标动画参数1
  public animIconUtils(d: number) {
    animationUtils = {
      duration: 150,
      curve: Curve.EaseOut,
      iterations: 5,
      playMode: PlayMode.Alternate,
      delay: d
    }
    return animationUtils
  }

  // 图标动画参数2
  public animIconUtils2(d: number) {
    animationUtils = {
      duration: 200,
      curve: Curve.EaseOut,
      iterations: 3,
      playMode: PlayMode.Alternate,
      delay: d
    }
    return animationUtils
  }

  // 普通动画参数
  public animNormalUtils(d: number) {
    animationUtils = {
      duration: 300,
      curve: Curve.EaseOut,
      iterations: 1,
      playMode: PlayMode.Normal,
      delay: d
    }
    return animationUtils
  }

  /** 液态玻璃弹簧动画参数 - Apple Liquid Glass 风格
   * @param isExpand true=展开(向下滚动), false=收缩(向上滚动)
   */
  public animLiquidGlassUtils(isExpand: boolean): AnimateParam {
    animationUtils = {
      duration: isExpand ? 500 : 600,
      curve: curves.springMotion(0.55, isExpand ? 0.85 : 0.9),
      iterations: 1,
      playMode: PlayMode.Normal,
      delay: 0
    }
    return animationUtils
  }

  //普通动画参数,根据软件选择参数
  public animNormalApp(time: number, d: number, curve?: string | Curve | ICurve) {
    animationUtils = {
      duration: time,
      curve: curve, //Curve.EaseOut,
      iterations: 1,
      playMode: PlayMode.Normal,
      delay: d
    }
    return animationUtils
  }

  //普通递增动画参数
  public animNormalAddUtils(d: number) {
    animationUtils = {
      duration: 500,
      curve: Curve.EaseOut,
      iterations: 1,
      playMode: PlayMode.Normal,
      delay: d * 50 + 50
    }
    return animationUtils
  }

  //普通递减动画参数
  public animNormalMinusUtils(d: number) {
    animationUtils = {
      duration: 300,
      curve: Curve.EaseOut,
      iterations: 1,
      playMode: PlayMode.Normal,
      delay: 100 - d * 30
    }
    return animationUtils
  }

  //一镜到底退出动画参数
  public animOneToEndBackUtils() {
    animationUtils = {
      duration: 500,
      // curve: curves.springMotion(0.5, 0.7, 0.6),
      // curve: Curve.Linear
      curve: curves.interpolatingSpring(0, 1, 342, 38)
      //  curve: Curve.Friction
    }

    return animationUtils
  }

  //一镜到底进入动画参数
  public animOneToEndInUtils() {
    animationUtils = {
      duration: 500,
      // curve: Curve.Linear,
      // curve: curves.springMotion(0.5, 0.7, 0.6),
      curve: curves.interpolatingSpring(0, 1, 328, 36)
      //  curve: Curve.Friction
    }

    return animationUtils
  }

  /* 属性动画 */
  /* API18及以下可直接使用显示动画 后面API全面升级后可以弃用 */
  public attributeAnim(i: number | string | FlexAlign | undefined, d: number) {
    animateTo(this.animNormalUtils(d), () => {
      this.i = i
    })
  }

  //显示动画回调
  public animateToVoid(v: () => void) {
    animateTo(this.animSpringUtils(), () => {
      v()
    })
  }

  ///图标属性动画参数
  public iconAnim() {
    animateTo(this.animSpringUtils(), () => {
      Xb_AnimationStyle.scaleSize = 1.2
      Xb_AnimationStyle.rotateSize = 15

      setTimeout(() => {
        Xb_AnimationStyle.scaleSize = 0.8
        Xb_AnimationStyle.rotateSize = -15
      }, 200)
      setTimeout(() => {
        Xb_AnimationStyle.scaleSize = 1
        Xb_AnimationStyle.rotateSize = 0
      }, 400)
    })
  }

  ///右侧图标属性动画参数
  public iconRAnim() {
    animateTo(this.animSpringUtils(), () => {
      Xb_AnimationStyle.attributeAnim(Xb_AnimationStyle.scaleSize = 1.2, 50)
      setTimeout(() => {
        Xb_AnimationStyle.attributeAnim(Xb_AnimationStyle.scaleSize = 0.8, 80)
      }, 200)
      setTimeout(() => {
        Xb_AnimationStyle.attributeAnim(Xb_AnimationStyle.scaleSize = 1, 80)
      }, 400)
    })
  }


  /* API18及以上使用显示动画 */
  //api18及以上使用显示动画，需要先在ui实例处初始化UIContext，具体方法查看本文件顶部注释文案
  ctx?: UIContext;

  setContext(context: UIContext) {
    this.ctx = context;
  }

  /* 属性动画 */
  public attributeAnimAPI18(i: number | string | FlexAlign | undefined, d: number) {
    if (this.ctx) {
      this.ctx.animateTo(this.animNormalUtils(d), () => {
        this.i = i
      })
    }
  }

  //显示动画回调
  public animToAPI18(v: () => void, time: number = 300, witchOne?: 'default' | 'app', d?: number,
    curve?: string | Curve | ICurve) {
    if (this.ctx) {
      if (witchOne === 'app') {
        this.ctx.animateTo(this.animNormalApp(time, d ?? 0, curve ?? Curve.EaseOut), () => {
          v()
        })
      } else {
        this.ctx.animateTo(this.animNormalUtils(d ?? 0), () => {
          v()
        })
      }
    }
  }

  //显示动画回调(自己填动画参数)
  public animToCustomAPI18(param: AnimateParam, v: () => void) {
    if (this.ctx) {
      this.ctx.animateTo(param, () => {
        v()
      })
    }
  }

  // 一镜到底显示动画退出回调
  public animToOneToEndBackAPI18(v: void) {
    if (this.ctx) {
      this.ctx.animateTo(this.animOneToEndBackUtils(), () => {
        v
      })
    }
  }

  ///图标属性动画参数
  public iconAnimAPI18() {
    if (this.ctx) {
      this.ctx.animateTo(this.animSpringUtils(), () => {
        Xb_AnimationStyle.scaleSize = 1.2
        Xb_AnimationStyle.rotateSize = 15

        setTimeout(() => {
          Xb_AnimationStyle.scaleSize = 0.8
          Xb_AnimationStyle.rotateSize = -15
        }, 200)
        setTimeout(() => {
          Xb_AnimationStyle.scaleSize = 1
          Xb_AnimationStyle.rotateSize = 0
        }, 400)
      })
    }
  }


  ///右侧图标属性动画参数
  public iconRAnimAPI18() {
    if (this.ctx) {
      this.ctx.animateTo(this.animSpringUtils(), () => {
        Xb_AnimationStyle.attributeAnim(Xb_AnimationStyle.scaleSize = 1.2, 50)
        setTimeout(() => {
          Xb_AnimationStyle.attributeAnim(Xb_AnimationStyle.scaleSize = 0.8, 80)
        }, 200)
        setTimeout(() => {
          Xb_AnimationStyle.attributeAnim(Xb_AnimationStyle.scaleSize = 1, 80)
        }, 400)
      })
    }
  }

  /* 转场动画 不受api影响 */
  // 显隐转场动画
  public isOpacity() {
    transitionEffect =
      TransitionEffect.OPACITY
        .animation(this.animNormalAddUtils(0))

    return transitionEffect
  }

  // 缩放转场动画
  public isScale(i?: number) {
    transitionEffect =
      TransitionEffect.OPACITY
        .combine(TransitionEffect.scale({ x: 0, y: 0 }))
        .animation(this.animSpringUtilsD(i!))

    return transitionEffect
  }

  // Y缩放转场动画
  public isScaleY(i?: number) {
    transitionEffect =
      TransitionEffect.OPACITY
        .combine(TransitionEffect.scale({ x: 1, y: 0.3 }))
        .animation(this.animSpringUtilsD(i!))

    return transitionEffect
  }

  // Y缩放转场动画
  public isScaleTransY(i?: number) {
    transitionEffect =
      TransitionEffect.OPACITY
        .combine(TransitionEffect.translate({ y: -20 }))
        .combine(TransitionEffect.scale({ x: 1, y: 0, centerY: 20 }))
        .animation(this.animSpringUtilsD(i!))

    return transitionEffect
  }

  // Y缩放转场动画无回弹动画
  public isScaleYNoSpring(i?: number) {
    transitionEffect =
      TransitionEffect.OPACITY
        .combine(TransitionEffect.scale({ x: 0.9, y: 0.75 }))
        .animation(this.animNormalUtils(i!))

    return transitionEffect
  }

  // 图标转场动画
  public isIcon() {
    transitionEffect =
      TransitionEffect.OPACITY.animation({
        curve: curves.springMotion(0.6, 0.8)
      })// 通过combine方法，这里的动画参数会跟随上面的TransitionEffect，也就是springMotion(0.6, 0.8)
        .combine(TransitionEffect.scale({
          x: 0,
          y: 0
        }))// 添加旋转转场效果，这里的动画参数会跟随上面带animation的TransitionEffect，也就是springMotion(0.6, 0.8)
        .combine(TransitionEffect.rotate({ angle: 90 }))// 添加平移转场效果，这里的动画参数使用指定的springMotion()
        .combine(TransitionEffect.translate({ x: 50 })
          .animation({ curve: curves.springMotion() })) // 添加move转场效果，这里的动画参数会跟随上面的TransitionEffect，也就是springMotion()


    return transitionEffect
  }

  //移动转场动画
  public isMove(d: number) {
    transitionEffect =
      TransitionEffect.OPACITY
        .combine(TransitionEffect.SLIDE)
        .animation(this.animSpringUtilsD(d))

    return transitionEffect
  }

  //从下往上移动转场动画
  public isMoveButton(d: number) {
    transitionEffect =
      TransitionEffect.OPACITY
        .combine(TransitionEffect.move(TransitionEdge.BOTTOM))
        .animation(this.animNormalAddUtils(d))

    return transitionEffect
  }

  // 半模态弹窗专用动画 (模仿系统半模态的弹簧效果)
  public isHalfModalSpring() {
    transitionEffect = TransitionEffect.OPACITY
      .combine(TransitionEffect.move(TransitionEdge.BOTTOM)) // 从底部滑入/滑出
      .animation({
        duration: 500, // 弹簧动画下时长作为参考值
        // 使用 springMotion 曲线参数：response(响应度), dampingFraction(阻尼比)
        // response 值越小动画越快，dampingFraction 越小弹性越大
        curve: curves.springMotion(0.6, 0.9)
      })
    return transitionEffect
  }

  //移动转场动画
  public isMoveSettings(d: number) {
    transitionEffect =
      TransitionEffect.move(TransitionEdge.START)
        .animation(this.animNormalUtils(d))

    return transitionEffect
  }

  public isMoveSettings2(d: number) {
    transitionEffect =
      TransitionEffect.move(TransitionEdge.END)
        .animation(this.animNormalUtils(d))

    return transitionEffect
  }


  //移动转场动画
  public isSlide(d: number) {
    transitionEffect =
      TransitionEffect.OPACITY
        .combine(TransitionEffect.SLIDE)
        .animation(this.animNormalUtils(d))

    return transitionEffect
  }

  public isSlide2(d: number) {
    transitionEffect =
      TransitionEffect.OPACITY
        .combine(TransitionEffect.SLIDE_SWITCH)
        .animation(this.animNormalUtils(d))

    return transitionEffect
  }

  //旋转转场动画（类似百叶窗效果）
  public isRotate(d: number) {
    transitionEffect =
      TransitionEffect.asymmetric(
        TransitionEffect.OPACITY
          .combine(TransitionEffect.rotate({ x: 1, angle: 270, perspective: 20 }))
          .combine(TransitionEffect.scale({ x: 0.7, y: 0.7 }))
          .animation(this.animNormalAddUtils(d)),

        TransitionEffect.OPACITY
          .combine(TransitionEffect.rotate({ x: 1, angle: 270, perspective: 50 }))
          .combine(TransitionEffect.scale({
            x: 0,
            y: 0,
            centerX: 0,
            centerY: 0
          }))
          .animation(this.animNormalMinusUtils(d))
      )
    return transitionEffect
  }

  // 列表一镜到底转场动画
  public isListOneToEnd() {
    transitionEffect =
      TransitionEffect.OPACITY
        .combine(TransitionEffect.scale({ x: 0.9, y: 0.9 }))
        .animation({ curve: curves.interpolatingSpring(0, 1, 195, 23) })

    return transitionEffect
  }

  // 列表一镜到底转场返回动画
  public isListOneToEndBack() {
    transitionEffect =
      TransitionEffect.scale({ y: 0 })
        .animation({ curve: curves.interpolatingSpring(0, 1, 195, 23) })

    return transitionEffect
  }

  /* 点击动效 */
  //点击动效
  public isClick() {
    clickEffect =
      { level: ClickEffectLevel.MIDDLE, scale: 0.85 }

    return clickEffect
  }
}

export const Xb_AnimationStyle: AnimationStyle = new AnimationStyle()
