import { BreakpointState } from '../../common/breakpointsystem'

@Component
export struct CardTitle {
  @State title: ResourceStr = ''
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @Consume('breakPointStateCardTitleFontSize') private titleFontSize: BreakpointState<number>
  @Consume('breakPointStateHomeCardTitleBottomMargin') private titleBottomMargin: BreakpointState<number>
  build() {
    Row() {
      Text(this.title)
        .fontSize(this.isLandscapePhone ? 18 : this.titleFontSize.value)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
    }
    .width('100%')
    .margin({bottom: this.titleBottomMargin.value})
    .justifyContent(FlexAlign.Start)
  }
}