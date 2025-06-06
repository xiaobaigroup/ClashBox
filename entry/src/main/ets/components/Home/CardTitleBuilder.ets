import { HomeCardFontSize, HomeCardTitleBottomMargin } from '../../common/breakpoint/BreakPoint'
import { BreakpointState } from '../../common/breakpoint/breakpointsystem'

@Component
export struct CardTitle {
  @State title: ResourceStr = ''
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageLink ('isLandscapePhone') isLandscapePhone: boolean = false
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1

  build() {
    Row() {
      Text(this.title)
        .fontSize(HomeCardFontSize(this.widthBp, this.heightBp) + 2)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .maxLines(1)
    }
    .width('100%')
    .padding({bottom: HomeCardTitleBottomMargin(this.widthBp, this.heightBp)})
    .justifyContent(FlexAlign.Start)
  }
}