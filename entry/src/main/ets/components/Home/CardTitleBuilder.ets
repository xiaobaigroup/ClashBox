import { HomeCardFontSize, HomeCardTitleBottomMargin } from '../../common/breakpoint/BreakPoint'
import { BreakpointState } from '../../common/breakpoint/breakpointsystem'
import { customAnimationUtil } from '../../common/utils/Animation'
import { getResourceString } from '../../common/utils/ResourceStringUtil'
import { number2Time } from '../../common/utils/TimeConvertUtil'
import { UIConfig } from '../../entryability/AppState'

@Component
export struct CardTitle {

  // 代理启动按钮状态
  @Consume proxyEnabled: boolean
  @State title: ResourceStr = ''
  @Prop subtitle: ResourceStr
  // 代理启动持续的时间
  @Consume proxyTime:number

  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageLink ('isLandscapePhone') isLandscapePhone: boolean = false
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1

  build() {
    Row() {
      Column() {
        Text(this.title)
          .fontSize(HomeCardFontSize(this.widthBp, this.heightBp) + 2)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
        if (this.subtitle) {
          // 计时器文本
          if(this.proxyEnabled) {
            Text((getResourceString($r('app.string.px_sec_screen_use_time'), this) + number2Time(Number(this.proxyTime), true)))
              .fontSize(14)
              .fontColor($r('sys.color.font_secondary'))
              .transition(customAnimationUtil.isSlideR(0, this.uiConfig))
          }
        }
      }
    }
    .width('100%')
    .padding({bottom: HomeCardTitleBottomMargin(this.widthBp, this.heightBp)})
    .justifyContent(FlexAlign.Start)
  }
}