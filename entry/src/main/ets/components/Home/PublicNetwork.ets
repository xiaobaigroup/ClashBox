import { BreakpointSystem, BreakpointState } from '../../common/breakpointsystem'
import { mediaquery } from '@kit.ArkUI'
import { MarginGenerate } from '../../common/Constants'
import { CardTitle } from './CardTitleBuilder'

@Component
struct PublicNetwork {
  //下部文字大小
  //主页卡片内容IP地址小字体大小
  @Consume('HomeCardIPSmFontSize')
  private HomeCardIPSmFontSize: BreakpointState<number>

  @State address: string = '中国大陆'
  @State IP: string = '255.255.255.255'
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding')  private cardPadding: BreakpointState<MarginGenerate>
  // 主页卡片内容IP地址字体大小
  @Consume('IPfontSize')  private IPfontSize: BreakpointState<number>

  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');


  build() {
    Column() {
      CardTitle({title: $r('app.string.PublicNetwork')})
      Column() {

          Text(this.address)
            .fontSize(this.isLandscapePhone ? 12:this.HomeCardIPSmFontSize.value)
            .fontColor($r('sys.color.font_secondary'))

        Text(this.IP)
          .fontSize(this.isLandscapePhone ? 20 :this.IPfontSize.value)
          .textAlign(TextAlign.Start)
          .fontColor($r('sys.color.font_primary'))

      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .flexGrow(1)
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
    //.justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
  }
}
export default PublicNetwork