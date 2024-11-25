import { BreakpointSystem, BreakpointState } from '../common/breakpointsystem'

interface MarginGenerate {
  left: number,
  bottom?:number
}

@Component
struct TrafficStatistics {
  @State TotalDownloads: number = 0
  @State TotalUpload: number = 0
  @State compStr: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg", xl: "xl" })
  @State fontSize: BreakpointState<number> = BreakpointState.of({
    sm: 21, md: 22, lg: 26, xl: 27
  });
  @State RowPadding: BreakpointState<number> = BreakpointState.of({
    sm: 10, md: 10, lg: 10, xl: 20
  });
  @State fontMargin: BreakpointState<MarginGenerate> = BreakpointState.of({
    sm: ({ left: 20 } as MarginGenerate),
    md: ({ left: 55 } as MarginGenerate),
    lg: ({ left: 50 } as MarginGenerate),
    xl: ({ left: 50 } as MarginGenerate)
  });

  aboutToAppear() {
    /*this.phonelistener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.onPhoneLandscape(mediaQueryResult)
    });*/

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.RowPadding)
    BreakpointSystem.getInstance().attach(this.fontMargin)
    BreakpointSystem.getInstance().start()
  }
  aboutToDisappear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.fontMargin)
    BreakpointSystem.getInstance().attach(this.RowPadding)
    BreakpointSystem.getInstance().stop()
    //this.phonelistener.off('change');
  }


  build() {
    Column() {
      Text($r('app.string.TrafficStatistics'))
        .fontSize(this.fontSize.value)
        .margin({left:this.RowPadding.value})
        .fontWeight(FontWeight.Bold)
      Column() {
        Row() {
          Text() {SymbolSpan($r('sys.symbol.chevron_up'))}
            .fontSize(this.fontSize.value)
          Text(this.TotalDownloads.toString() + ' B')
            .margin(this.fontMargin.value)
            .fontSize(this.fontSize.value)
        }
        .justifyContent(FlexAlign.Start)
        Row() {
          Text() {SymbolSpan($r('sys.symbol.chevron_down'))}
            .fontSize(this.fontSize.value)
          Text(this.TotalUpload.toString() + ' B')
            .margin(this.fontMargin.value)
            .fontSize(this.fontSize.value)
        }
        .justifyContent(FlexAlign.Start)
        .margin({top: this.RowPadding.value})

      }
      .padding(this.RowPadding.value)
    }
    .padding(5)
    .width('100%')
    .height('100%')
    //.justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
  }
}
export default TrafficStatistics