import { BreakpointSystem, BreakpointState } from '../common/breakpointsystem'

interface MarginGenerate {
  left: number,
  bottom?:number
}

@Component
struct CurrrentNode {
  @State currentNode: string = '123'
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
      Text($r('app.string.CurrentNode'))
        .fontSize(this.fontSize.value)
        .margin({left:this.RowPadding.value})
        .fontWeight(FontWeight.Bold)
      Row() {
        Text(this.currentNode)
          .fontSize(this.fontSize.value)
      }
      .flexGrow(1)
      .width('100%')
      .justifyContent(FlexAlign.Center)
      Row() {
        Text($r('app.string.Switch'))
          .fontSize(this.fontSize.value)
          .fontWeight(FontWeight.Bold)
        Text() {SymbolSpan($r('sys.symbol.chevron_right'))}
        .fontSize(this.fontSize.value)
        .margin({left:5})
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
    }
    .padding(5)
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
export default CurrrentNode