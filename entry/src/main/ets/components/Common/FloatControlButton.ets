import { UIConfig } from '../../entryability/AppState'
import { EventHub, EventKey } from '../../common/EventHub'
import { icon_tertiary } from './Common'
import { customAnimationUtil } from '../../common/utils/Animation'

/**
 * @fileName:      FloatControlButton
 * @author:     SummerKaze
 * @description:  悬浮控制按钮组件
 * @date:    2026/2/8 17:03
 * @version:    1.0
 */

@Component
export struct FloatControlButton {
  /** @description 是否为左侧按钮 */
  isLeft: boolean = false
  /** @description 代理启动状态 */
  @Consume proxyEnabled: boolean
  /** @description 主题强调色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  /** @description UI 配置 */
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  /** @description 宽度断点 */
  @StorageProp('currentWidthBreakpoint') widthBp: number = 1

  build() {
    Row() {
      SymbolGlyph(this.proxyEnabled ? $r('sys.symbol.pause') : $r('sys.symbol.play_fill'))
        .fontSize(27)
        .fontColor([this.proxyEnabled ? Color.White : icon_tertiary])
    }
    .functionButtonStyle(this.proxyEnabled && this.widthBp <= 2, this.icon_emphasize)
    .animation({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear })
    // 背景模糊
    .backdropBlur(this.uiConfig.isBlurr && !this.proxyEnabled ? 30 : 0)
    .backgroundColor(
      this.proxyEnabled
        ? this.icon_emphasize
        : this.uiConfig.isBlurr
          ? $r('app.color.float_tab_background_blur')
          : $r('app.color.background')
    )
    .onClick(() => {
      // 触发代理启动事件
      EventHub.sendEvent(EventKey.ChangeProxy)
    })
    // 滑入/滑出 动画
    .transition(customAnimationUtil.getFloatButtonTransition(this.uiConfig, this.uiConfig.buttonPositionIndex))
  }
}

/**
 * 功能按钮样式
 * @param during - 是否处于激活状态（代理已启动）
 * @param c - 阴影颜色
 */
@Extend(Row)
function functionButtonStyle(during: boolean, c: ResourceColor = $r('app.color.shadow_button')) {
  .borderRadius(30)
  .padding(during ? { left: 8, right: 8 } : 0)
  .size({ width: 60, height: 60 })
  .justifyContent(FlexAlign.Center)
  .aspectRatio(1)
  .alignItems(VerticalAlign.Center)
  .shadow({
    radius: 15,
    offsetY: 4,
    color: during ? c : $r('app.color.shadow_button'),
    type: ShadowType.COLOR
  })
}
