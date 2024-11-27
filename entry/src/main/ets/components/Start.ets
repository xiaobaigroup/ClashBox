import { BreakpointState, BreakpointSystem } from '../common/breakpointsystem';

@Component
struct Start {
  @State DownloadSpeed: number = 0
  @State UploadSpeed: number = 0
  @State compStr: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg", xl: "xl" })
  @State fontSize: BreakpointState<number> = BreakpointState.of({
    sm: 28, md: 30, lg: 35, xl: 36
  });
  @State speedfontSize: BreakpointState<number> = BreakpointState.of({
    sm: 16, md: 20, lg: 21, xl: 21
  });

  aboutToAppear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.speedfontSize)
    BreakpointSystem.getInstance().start()
  }
  aboutToDisappear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.speedfontSize)
    BreakpointSystem.getInstance().stop()
    //this.phonelistener.off('change');
  }

  build() {
    Column() {
      Row() {
        Row() {
          Text() {SymbolSpan($r('sys.symbol.play_fill'))}
            .fontSize(this.fontSize.value)
            .fontColor('green')
          Text($r('app.string.Start'))
            .fontSize(this.fontSize.value)
        }
        .width('145vp')
          //.margin({ top: 10, left: 20 })
        Row() {}
        .flexGrow(1)
        Column() {
          Row() {
            Text(this.DownloadSpeed.toString() + ' B/s')
              .margin({ right: 3 })
              .fontSize(this.speedfontSize.value)
            Text() {
              SymbolSpan($r('sys.symbol.chevron_up'))
                .fontSize(this.speedfontSize.value)
            }

          }
          Row() {
            Text(this.UploadSpeed.toString() + ' B/s')
              .margin({ right: 3 })
              .fontSize(this.speedfontSize.value)
            Text() {
              SymbolSpan($r('sys.symbol.chevron_down'))
                .fontSize(this.speedfontSize.value)
            }

          }
        }
        .width('67vp')

      }
      .height(40)
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {

      }
      .justifyContent(FlexAlign.Center)
      .width('100%')




    }
    .padding({top: 12, bottom: 12, left: 10, right: 10})
    .width('100%')
    .height('100%')
  }
}

export default Start