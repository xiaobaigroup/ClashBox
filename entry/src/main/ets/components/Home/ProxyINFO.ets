import { BreakpointState } from "../../common/breakpointsystem"
import { MarginGenerate } from "../../common/Constants"
import { Item, ProxyData } from "../../common/ProxyData"
import { CardTitle } from "./CardTitleBuilder"

@Component
struct ProxyINFO{
  //自定义主题，颜色在AppTheme里面修改
  @Consume('icon_emphasize') icon_emphasize: ResourceColor //高亮图标,可在apptheme更换
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding')  private cardPadding: BreakpointState<MarginGenerate>
  //节点假数据组后期可改可删
  @Consume items: Item[]
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  //主页卡片内容当前节点字体大小
  @Consume('ProxyFontSize_24_29_26_27') private ProxyFontSize_24_29_26_27: BreakpointState<number>
  @State address: string = '美国'
  @State IP: string = '255.255.255.255'
  @State DownloadSpeed: number = 0
  @State UploadSpeed: number = 0
  //主页卡片内容IP地址小字体大小
  @Consume('HomeCardIPSmFontSize')
  private HomeCardIPSmFontSize: BreakpointState<number>
  //主页卡片内容当前延迟小字体大小（16,20,18,24）
  @Consume('HomeCardPrpxySmFontSize') private HomeCardPrpxySmFontSize: BreakpointState<number>
  //主页卡片内容网络测速字体大小
  @Consume('SpeedfontSize12_16_14_16') private SpeedfontSize12_16_14_16: BreakpointState<number>
  // 内容文本字体大小
  @Consume('breakPointStateHomeCardSwitchModeFontSize') private fontSize: BreakpointState<number>

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween}) {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween }) {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
          CardTitle({ title: $r('app.string.proxy_INFO') })
          Text(`${this.items[0].text}`)//此处items[]里的数字为节点假数据（common/ProxyData）数组里的单一项，后端接入后此处应改为选中的节点项
            .fontSize(this.isLandscapePhone ? 24 : this.ProxyFontSize_24_29_26_27.value)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text(this.address + this.IP)
            .fontSize(this.isLandscapePhone ? 12 : this.HomeCardIPSmFontSize.value)
            .fontColor($r('sys.color.font_secondary'))
        }

        Text('ping ' + `${this.items[0].latency}` + 'ms')//此处items[]里的数字为节点假数据（common/ProxyData）数组里的单一项，后端接入后此处应改为选中的节点项
          .fontSize(this.isLandscapePhone ? 16 : this.HomeCardPrpxySmFontSize.value)
          .fontColor(ProxyData.getColorForLatency(this.items[0].latency)) //此处items[]里的数字为节点假数据（common/ProxyData）数组里的单一项，后端接入后此处应改为选中的节点项
      }
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.End, justifyContent: FlexAlign.SpaceBetween }) {
        Column() {
          Row({space:5}) {
            Text(this.DownloadSpeed.toString() + ' B/s')
              .fontSize(this.isLandscapePhone ? 12:this.SpeedfontSize12_16_14_16.value)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.End)

            SymbolGlyph($r('sys.symbol.chevron_up'))
              .fontColor([$r('sys.color.font_primary')])
          }.width('100%').justifyContent(FlexAlign.End)

          Row({space:5}) {
            Text(this.UploadSpeed.toString() + ' B/s')
              .fontSize(this.isLandscapePhone ? 12:this.SpeedfontSize12_16_14_16.value)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.End)

            SymbolGlyph($r('sys.symbol.chevron_down'))
              .fontColor([$r('sys.color.font_primary')])
          }.width('100%').justifyContent(FlexAlign.End)
        }

        Button($r('app.string.refresh_IP2'))
          .width('55%')
          .height('25%')
          .fontColor(this.icon_emphasize)
          .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
          .backgroundColor($r('app.color.home_card_background'))
      }
    }
    .width('100%')
    .height('100%')
    .padding(this.cardPadding.value)
    .id('ProxyINFOId')
  }
}

export default ProxyINFO