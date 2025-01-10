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
  @Consume('ProxyFontSize_24_29_26_27') private ProxyFontSize_24_29_26_27: BreakpointState<number>


  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');

  build() {
    Column() {
      CardTitle({title: $r('app.string.CurrentNode')})
      Column() {
        Text(`${this.items[0].text}`)//此处items[]里的数字为节点假数据（common/ProxyData）数组里的单一项，后端接入后此处应改为选中的节点项
          .fontSize(this.isLandscapePhone ? 24 :this.ProxyFontSize_24_29_26_27.value)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.font_primary)

        Text('ping ' +`${this.items[0].latency}`+ 'ms')//此处items[]里的数字为节点假数据（common/ProxyData）数组里的单一项，后端接入后此处应改为选中的节点项
          .fontSize(this.isLandscapePhone ?16:this.HomeCardPrpxySmFontSize.value)
          .fontColor(ProxyData.getColorForLatency(this.items[0].latency))//此处items[]里的数字为节点假数据（common/ProxyData）数组里的单一项，后端接入后此处应改为选中的节点项
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

