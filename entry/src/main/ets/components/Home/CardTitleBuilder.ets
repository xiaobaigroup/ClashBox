import { BreakpointState } from '../../common/breakpointsystem'

@Component
export struct CardTitle {
  @State title: ResourceStr = ''
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageLink ('isLandscapePhone')  private isLandscapePhone: boolean = false
  @Consume('breakPointStateCardTitleFontSize') private titleFontSize: BreakpointState<number>
  @Consume('breakPointStateHomeCardTitleBottomMargin') private titleBottomMargin: BreakpointState<number>
  build() {
    Row() {
      Text(this.title)
        .fontSize(this.isLandscapePhone ? 16 : this.titleFontSize.value)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .maxLines(1)
    }
    .width('100%')
    .padding({bottom: this.titleBottomMargin.value})
    .justifyContent(FlexAlign.Start)
  }
}