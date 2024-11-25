import { BreakpointSystem, BreakpointState } from '../common/breakpointsystem'

interface MarginGenerate {
  left: number,
  bottom?:number
}

@Component
struct PublicNetwork {
  @State address: string = '中国大陆'
  @State IP: string = '255.255.255.255'
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
      Text($r('app.string.PublicNetwork'))
        .fontSize(this.fontSize.value)
        .margin({left:this.RowPadding.value})
        .fontWeight(FontWeight.Bold)
      Column() {
        Row() {
          Text(this.address)
            .fontSize(this.fontSize.value)
        }
        .justifyContent(FlexAlign.Center)
        Text(this.IP)
          .fontSize(this.fontSize.value)
          .textAlign(TextAlign.Center)
          .margin(this.RowPadding.value)

      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .flexGrow(1)
    }
    .padding(5)
    .width('100%')
    .height('100%')
    //.justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
  }
}
export default PublicNetwork