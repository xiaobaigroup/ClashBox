import { BreakpointState } from '../../common/breakpointsystem'
import { mediaquery } from '@kit.ArkUI'
import {  MarginGenerate } from '../../common/Constants'
import { CardTitle } from './CardTitleBuilder'

@Component
struct CellularDataStat {
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  @State font_primary: ResourceColor = $r('sys.color.font_primary')
  @State TotalDownloads: number = 0
  @State TotalCellular: number = 30 //假数据
  @State TotalUpload: number = 0
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  // 内容文本字体大小
  @Consume('breakPointStateCardCellularDataFontSize') private fontSize: BreakpointState<number>
  // 上下行箭头图标大小
  @Consume('breakPointStateCardCellularDataChevronSize') private chevronSize: BreakpointState<number>
  // 箭头组件部分间距
  @Consume('breakPointStateCardCellularDataChevronRowMargin') private RowMargin: BreakpointState<number>
  // 统计条高度
  @Consume('breakPointStateCardCellularDatabarHeight') private barHeight: BreakpointState<number>
  // 统计条边距
  @Consume('breakPointStateCardCellularDatabarMargin') private barMargin: BreakpointState<MarginGenerate>
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding') private cardPadding: BreakpointState<MarginGenerate>
  @Consume('breakPointStateHomeCardTitleBottomMargin') private titleBottomMargin: BreakpointState<number>
//下部文字大小
  @Consume('HomeCardCellularDataSmFontSize') private HomeCardCellularDataSmFontSize: BreakpointState<number>
  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');
  /**
   * 主页流量统计卡片padding高度
   */
  @Consume('HomeCardCellularDataPadding')
  private HomeCardCellularDataPadding: BreakpointState<number>

  build() {
    Column() {
      CardTitle({title: $r('app.string.CellularData')})
      Column({space:this.RowMargin.value}) {
        Row({space:this.RowMargin.value}) {
          Column() {
            Text() {SymbolSpan($r('sys.symbol.chevron_down'))}
            .fontSize(this.isLandscapePhone ? 14:this.chevronSize.value)
            .fontColor(this.icon_primary)
            Text(this.TotalDownloads.toString() + ' GB')
              .fontSize(this.isLandscapePhone ? 14:this.fontSize.value)
              .fontColor(this.icon_primary)
          }
          //     .margin({top:this.RowMargin.value, right: this.RowMargin.value})
          // .justifyContent(FlexAlign.Center)
          Column() {
            Text() {SymbolSpan($r('sys.symbol.chevron_up'))}
            .fontSize(this.isLandscapePhone ? 14:this.chevronSize.value)
            .fontColor(this.icon_primary)
            Text(this.TotalUpload.toString() + ' GB')
              .fontSize(this.isLandscapePhone ? 14:this.fontSize.value)
              .fontColor(this.icon_primary)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        Column() {
          Progress({ value: 60,total: 100, type: ProgressType.Capsule  })//value为使用流量的值
            .style({enableSmoothEffect: true,borderColor:'#00ffffff'})
            .color('#ff46b1e3')
            .width('100%')
            .height('100%')
        }
        .width('90%')
        .backgroundColor('#4d46b1e3')
        .height(this.barHeight.value)
        .borderRadius(this.barHeight.value)
        //   .margin(this.barMargin.value)

        Text(this.TotalDownloads.toString() + ' GB'+ '/'+ this.TotalCellular.toString() + ' GB')
          .fontSize(this.isLandscapePhone ? 10:this.HomeCardCellularDataSmFontSize.value)
          .fontColor($r('sys.color.font_secondary'))
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
  //    .backgroundColor('#ba942020')
      .padding({bottom:this.isLandscapePhone ? 30: this.HomeCardCellularDataPadding.value})
    //  .alignItems(HorizontalAlign.Center)
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
//.backgroundColor('#ff55b54e')
    .id('CellularDataId')
  }
}
export default CellularDataStat