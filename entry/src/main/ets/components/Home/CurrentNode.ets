import {  BreakpointState } from '../../common/breakpointsystem'
import { mediaquery } from '@kit.ArkUI'
import { MarginGenerate } from '../../common/Constants'
import { CardTitle } from './CardTitleBuilder'
import { Item, ProxyData  } from '../../common/ProxyData'


@Component
struct CurrentNode {
  @State font_primary: ResourceColor = $r('sys.color.font_primary')
  //节点假数据组后期可改可删
  @Consume items: Item[]
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding')  private cardPadding: BreakpointState<MarginGenerate>
  //主页卡片内容当前延迟小字体大小（16,20,18,24）
  @Consume('HomeCardPrpxySmFontSize') private HomeCardPrpxySmFontSize: BreakpointState<number>
  //主页卡片内容当前节点字体大小
  @Consume('ProxyFontSize') private ProxyFontSize: BreakpointState<number>
  // 当前代理节点单选框选择的配置
  @Consume private ProxyRadioCheckedValue: number

  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');

  build() {
    Column() {
      CardTitle({title: $r('app.string.CurrentNode')})
      Column() {
        if (this.ProxyRadioCheckedValue >= 0) {
          Text(`${this.items[this.ProxyRadioCheckedValue].text}`)
            .fontSize(this.isLandscapePhone ? 24 : this.ProxyFontSize.value)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.font_primary)

          Text('ping ' + `${this.items[this.ProxyRadioCheckedValue].latency}` + 'ms')
            .fontSize(this.isLandscapePhone ? 16 : this.HomeCardPrpxySmFontSize.value)
            .fontColor(ProxyData.getColorForLatency(this.items[this.ProxyRadioCheckedValue].latency))
        }
        else if(this.ProxyRadioCheckedValue < 0){
          Text($r('app.string.proxy_name'))
            .fontSize(this.isLandscapePhone ? 24 : this.ProxyFontSize.value)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.font_primary)

          Row(){
            Text('ping ')
              .fontSize(this.isLandscapePhone ? 16 : this.HomeCardPrpxySmFontSize.value)
              .fontColor('#64BB5C')
            Text($r('app.string.Delay'))
              .fontSize(this.isLandscapePhone ? 16 : this.HomeCardPrpxySmFontSize.value)
              .fontColor('#64BB5C')
          }
        }
      }
      .flexGrow(1)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .id('CurrentNodeId')
  }
}
export default CurrentNode