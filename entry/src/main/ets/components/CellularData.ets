import { BreakpointSystem, BreakpointState } from '../common/breakpointsystem'

interface MarginGenerate {
  left: number,top: number,
  bottom?:number
}

@Component
struct TrafficStatistics {
  @State TotalDownloads: number = 0
  @State TotalUpload: number = 0
  @State compStr: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg", xl: "xl" })
  @State fontSize: BreakpointState<number> = BreakpointState.of({
    sm: 12, md: 22, lg: 26, xl: 27
  });
  @State titleFontSize: BreakpointState<number> = BreakpointState.of({
    sm: 18, md: 22, lg: 26, xl: 27
  });
  @State chevronSize: BreakpointState<number> = BreakpointState.of({
    sm: 16, md: 22, lg: 26, xl: 27
  });
  @State RowMargin: BreakpointState<number> = BreakpointState.of({
    sm: 20, md: 10, lg: 10, xl: 20
  });
  @State barHeight: BreakpointState<number> = BreakpointState.of({
    sm: 6, md: 5, lg: 5, xl: 5
  });
  @State barMargin: BreakpointState<MarginGenerate> = BreakpointState.of({
    xs: ({ top: 10, bottom: 7 } as MarginGenerate),
    sm: ({ top: 10, bottom: 7 } as MarginGenerate),
    md: ({ top: 84 } as MarginGenerate),
    lg: ({ top: 25, left: 15 } as MarginGenerate),
    xl: ({ top: 25, left: 15 } as MarginGenerate)
  });

  aboutToAppear() {
    /*this.phonelistener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.onPhoneLandscape(mediaQueryResult)
    });*/

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.titleFontSize)
    BreakpointSystem.getInstance().attach(this.chevronSize)
    BreakpointSystem.getInstance().attach(this.RowMargin)
    BreakpointSystem.getInstance().attach(this.barHeight)
    BreakpointSystem.getInstance().attach(this.barMargin)
    BreakpointSystem.getInstance().start()
  }
  aboutToDisappear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.titleFontSize)
    BreakpointSystem.getInstance().attach(this.chevronSize)
    BreakpointSystem.getInstance().attach(this.barHeight)
    BreakpointSystem.getInstance().attach(this.RowMargin)
    BreakpointSystem.getInstance().attach(this.barMargin)
    BreakpointSystem.getInstance().stop()
    //this.phonelistener.off('change');
  }


  build() {
    Column() {
      Text($r('app.string.CellularData'))
        .fontSize(this.titleFontSize.value)
          //.margin({left:this.RowPadding.value})
        .fontWeight(FontWeight.Bold)
      Column() {
        Row() {
          Column() {
            Text() {SymbolSpan($r('sys.symbol.chevron_down'))}
            .fontSize(this.chevronSize.value)
            Text(this.TotalDownloads.toString() + ' GB')
              //.margin(this.fontMargin.value)
              .fontSize(this.fontSize.value)
          }
          .margin({top:this.RowMargin.value, right: this.RowMargin.value})
          .justifyContent(FlexAlign.Center)
          Column() {
            Text() {SymbolSpan($r('sys.symbol.chevron_up'))}
            .fontSize(this.chevronSize.value)
            Text(this.TotalUpload.toString() + ' GB')
              //.margin(this.fontMargin.value)
              .fontSize(this.fontSize.value)
          }
          .margin({top:this.RowMargin.value})
          .justifyContent(FlexAlign.Center)
          //.margin({top: this.RowPadding.value})
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        Column() {

        }
        .width('90%')
        .backgroundColor('#B2B2B2')
        .height(this.barHeight.value)
        .borderRadius(this.barHeight.value)
        .margin(this.barMargin.value)
        Text($r('app.string.CellularData_Statistics_explanation'))
          .fontSize(this.fontSize.value)

      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)

    }
    .padding({top: 12, bottom: 12, left: 10, right: 10})
    .width('100%')
    .height('100%')
    //.justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
  }
}
export default TrafficStatistics