import { LengthMetrics } from '@kit.ArkUI'
import { UIConfig } from '../../entryability/AppState'
import { TabBuild } from '../../common/entity/PageArgumentEntity'
import { customAnimationUtil } from '../../common/utils/Animation'
import {
  Xb_FloatTabBarDirection,
  Xb_FloatTabBarPadding,
  Xb_TabBarVertical,
  Xb_TabIconFontSize,
  Xb_TabTitleFontSize
} from 'xb_components'
import { Xb_AnimationStyle } from 'xb_components'
import { FloatControlButton } from './FloatControlButton'
import { FloatTabBarHeight } from '../../common/breakpoint/BreakPoint'

/**
 * @fileName:      FloatBar
 * @author:     SummerKaze
 * @description:  悬浮 Tab 栏组件
 * @date:    2026/2/8 17:03
 * @version:    1.0
 */

@Component
export struct FloatBar {
  // 必传属性
  /** @description Tab 列表数据 */
  @Require tabList: TabBuild[] = []
  /** @description Swiper 控制器（与 FloatTab 中的 Swiper 共享） */
  @Require swiperController: SwiperController = new SwiperController()
  // @Consume 父子共享属性
  /** @description 当前选中的 Tab 页索引 */
  @Consume tabCurrentPage: number
  /** @description 列表是否正在滚动（控制 Tab 栏折叠） */
  @Consume isRolling: boolean
  /** @description 主题强调色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // @StorageLink / @StorageProp 全局共享属性
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @StorageProp('currentWidthBreakpoint') widthBp: number = 1
  @StorageProp('currentHeightBreakpoint') heightBp: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('LeftAvoidWidth') leftAvoidWidth: number = 0
  @StorageProp('WindowMode') windowMode: boolean = false

  build() {
    Flex({
      direction: Xb_FloatTabBarDirection(this.widthBp, this.heightBp),
      justifyContent: this.widthBp < 2 ? FlexAlign.SpaceBetween : FlexAlign.Center,
      alignItems: this.widthBp < 2 ? ItemAlign.Center : ItemAlign.Start,
      space: { main: LengthMetrics.vp(10) }
    }) {
      // 左侧控制按钮
      if (this.uiConfig.buttonPositionIndex === 2) {
        FloatControlButton({ isLeft: true })
      }

      // Tab 图标区
      Flex({
        direction: Xb_FloatTabBarDirection(this.widthBp, this.heightBp),
        justifyContent: FlexAlign.SpaceAround,
        alignItems: ItemAlign.Center,
        space: { main: LengthMetrics.vp(10) }
      }) {
        if (this.isRolling && this.uiConfig.isAnimation && this.widthBp < 2) {
          // 滚动状态：仅显示当前 Tab 图标
          Column() {
            SymbolGlyph(this.tabList[this.tabCurrentPage].icon)
              .fontSize(27)
              .fontColor([this.icon_emphasize])
              .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
          }
          .size({ width: 60, height: 60 })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.isRolling = false
          })
        } else {
          // 正常状态：显示所有 Tab 图标
          ForEach(this.tabList, (item: TabBuild, index: number) => {
            Column() {
              SymbolGlyph(item.icon)
                .fontSize(Xb_TabIconFontSize(this.widthBp, this.heightBp))
                .fontColor([this.tabCurrentPage === index ? this.icon_emphasize : $r('sys.color.icon_tertiary')])
                .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
                .translate({ y: this.tabCurrentPage == index ? -2 : 0 })
                .animation(Xb_AnimationStyle.animNormalUtils(0))
              Text(item.name)
                .fontColor(this.tabCurrentPage === index ? this.icon_emphasize : $r('sys.color.icon_tertiary'))
                .fontSize(Xb_TabTitleFontSize(this.widthBp, this.heightBp))
            }
            .width(60)
            .height(60)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .onClick(() => {
              Xb_AnimationStyle.animToAPI18(() => {
                this.tabCurrentPage = index
              }, this.uiConfig.animationSpeed, 'app')
              this.swiperController.changeIndex(index, true)
            })
            .transition(customAnimationUtil.isSlideScaleBigMove(this.uiConfig))
          })
        }
      }
      .transition(customAnimationUtil.isOpacity(this.uiConfig))
      .padding((this.isRolling && this.uiConfig.isAnimation && this.widthBp < 2) ? 0 :
        Xb_FloatTabBarPadding(this.widthBp, this.heightBp))
      .width((!this.isRolling && this.widthBp < 2) ? '100%' : 'auto')
      .height(FloatTabBarHeight(this.widthBp, this.heightBp))
      .layoutWeight((!this.isRolling && this.widthBp < 2) ? 1 : undefined)
      .borderRadius(30)
      // 背景模糊
      .backdropBlur(this.uiConfig.isBlurr ? 30 : 0)
      .backgroundColor(this.uiConfig.isBlurr ? $r('app.color.float_tab_background_blur') : $r('app.color.background'))
      .animation({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear })
      .shadow({
        radius: 15,
        offsetY: 4,
        color: $r('app.color.shadow_button'),
        type: ShadowType.COLOR,
      })
      .onAppear(() => {
        this.swiperController.changeIndex(this.tabCurrentPage, true)
      })

      // 右侧控制按钮
      if (this.uiConfig.buttonPositionIndex === 0) {
        FloatControlButton({ isLeft: false })
      }
    }
    .height(FloatTabBarHeight(this.widthBp, this.heightBp))
    .width(this.widthBp < 2 ? '100%' : 'auto')
    .padding({
      left: 10,
      right: 10,
      top: this.topRectHeight === 0 ? 10 : 0,
      bottom: this.topRectHeight === 0 ? 10 : 0
    })
    .margin({
      bottom: this.getFloatBottom(),
      top: this.windowMode ? 0 : this.topRectHeight,
      left: (this.leftAvoidWidth != 0 && !this.windowMode) ? this.leftAvoidWidth + 19 : 0,
    })
  }

  /** 获取悬浮 Tab 底部避让值 */
  getFloatBottom(): number | string {
    const isTabBarVertical = Xb_TabBarVertical(this.widthBp, this.heightBp);
    const isFloatTabBarFullHeight = FloatTabBarHeight(this.widthBp, this.heightBp) == '100%';
    // 优先级 1: 侧边撑满布局
    if (isTabBarVertical && isFloatTabBarFullHeight) {
      return 5;
    }
    // 优先级 2: 窗口模式下的水平布局
    if (!isTabBarVertical && this.windowMode) {
      return this.widthBp < 2 ? 8 : 1;
    }
    // 优先级 3: 常规避让布局：有高度就减 10
    if (this.bottomRectHeight !== 0) {
      return this.bottomRectHeight - 10;
    }
    // 优先级 4 (兜底逻辑): 其他所有情况
    return isTabBarVertical ? 3 : 8;
  }
}
