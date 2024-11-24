//主页 栅格布局、媒体查询
import { BreakpointSystem, BreakpointState } from '../common/breakpointsystem'

interface MarginGenerate {
  top: number,
  bottom?:number
}

@Entry
@Component
struct Home {
  @State currentBp: string = ''
  @State greetings: string = '早上好'
  @State ContainerHeight: string = ''
  @State TopHeight: string = ''
  @State DownloadSpeed: number = 0
  @State UploadSpeed: number = 0
  @State compStr: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg", xl: "xl" })
  @State containerMargin1: BreakpointState<MarginGenerate> = BreakpointState.of({
    sm: ({ top: 10 } as MarginGenerate),
    md: ({ top: 10 } as MarginGenerate),
    lg: ({ top: 8 } as MarginGenerate),
    xl: ({ top: 4 } as MarginGenerate)
  });
  @State containerMargin2: BreakpointState<MarginGenerate> = BreakpointState.of({
    sm: ({ top: 35 } as MarginGenerate),
    md: ({ top: 30 } as MarginGenerate),
    lg: ({ top: 8 } as MarginGenerate),
    xl: ({ top: 4 } as MarginGenerate)
  });
  @State containerMargin3: BreakpointState<MarginGenerate> = BreakpointState.of({
    sm: ({ top: 55 } as MarginGenerate),
    md: ({ top: 45 } as MarginGenerate),
    lg: ({ top: 8 } as MarginGenerate),
    xl: ({ top: 35 } as MarginGenerate)
  });
  @State containerHeight: BreakpointState<string> = BreakpointState.of({
    sm: '26%', md: '36%', lg: '26%', xl: '46%'
  });
  @State ContainerHeight1: BreakpointState<string> = BreakpointState.of({
    sm: '30%', md: '25%', lg: '26%', xl: '40%'
  });

  aboutToAppear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.containerMargin1)
    BreakpointSystem.getInstance().attach(this.containerMargin2)
    BreakpointSystem.getInstance().attach(this.containerMargin3)
    BreakpointSystem.getInstance().attach(this.containerHeight)
    BreakpointSystem.getInstance().attach(this.ContainerHeight1)
    BreakpointSystem.getInstance().start()
  }
  aboutToDisappear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.containerMargin1)
    BreakpointSystem.getInstance().attach(this.containerMargin2)
    BreakpointSystem.getInstance().attach(this.containerMargin3)
    BreakpointSystem.getInstance().attach(this.containerHeight)
    BreakpointSystem.getInstance().attach(this.ContainerHeight1)
    BreakpointSystem.getInstance().stop()
  }


  build() {
    Column() {
      GridRow({
        columns: 12,
        gutter: { x: 10, y: 10 },
        breakpoints: {
          value: ["320vp", "600vp", "840vp", "1000vp"],
          reference: BreakpointsReference.WindowSize
        },
        //direction: GridRowDirection.Row
      }) {
        GridCol({ span: 12 }) {
          GridRow() {
            GridCol({
              span: { xs: 2, sm: 4, md: 3, lg: 2, xl:2 },
              offset: 0, order: 0
            }) {
              Text(this.greetings)
                .fontSize(36)
                .fontWeight(FontWeight.Bold)
            }
            //.backgroundColor('blue')
            //.height("100%")

            GridCol({
              span: { xs: 1, sm: 2, md: 1, lg: 1, xl: 1 },
              offset: { xs: 1, sm: 6, md: 8, lg: 9, xl: 9 }, order: 1
            }) {
              Button({ type: ButtonType.Circle, stateEffect: true }) {
                SymbolGlyph($r('sys.symbol.gearshape'))
                  .fontSize(26)
              }
              .width(40)
              .height(40)
              .backgroundColor($r('app.color.container_background'))
            }
            //.backgroundColor('red')
          }
        }
        .height('45vp')

        GridCol({
          span: { xs: 12, sm: 12, md: 12, lg: 6, xl:6 }
        }) {
          GridRow() {
            GridCol({
              span: 10, offset: 1, order: 0
            }) {
              Column() {
                GridRow() {
                  GridCol({ span: 7 }) {
                    Text($r('app.string.Start'))
                      .fontSize(36)
                  }
                }.margin(5).height('25%')
                GridRow() {

                }//.flexGrow(1)
                .height('50%')
                GridRow() {
                  GridCol({span: 6, offset:6}) {
                    Row() {
                      Text() {SymbolSpan($r('sys.symbol.chevron_up'))}
                      Text(this.DownloadSpeed.toString() + 'Kbps')
                        .margin({right: 3})
                      Text() {SymbolSpan($r('sys.symbol.chevron_down'))}
                      Text(this.UploadSpeed.toString() + 'Kbps')
                        .margin({right: 3})
                    }
                  }
                }.height('12%')
              }

            }
            .width('100%')
            .height('100%')
            .borderRadius(20)
            .backgroundColor('red')
          }
          .height('100%')
        }
        .height(this.containerHeight.value)
        .margin(this.containerMargin1.value)

        GridCol({
          span: { xs: 12, sm: 12, md: 12, lg: 6, xl:6 }
        }) {
          GridRow() {
            GridCol({
              span: 10,
              offset: {sm: 1, md: 1} }) {
              GridRow({columns:16}) {
                GridCol({
                  span:{ sm: 7, md: 7, lg: 7, xl:7 }
                }) {

                }
                .height('100%')
                .backgroundColor('blue')
                .borderRadius(20)
                GridCol({
                  span:{ sm: 7, md: 7, lg: 7, xl:7 },
                  offset:{sm: 2}
                }) {

                }
                .height('100%')
                .borderRadius(20)
                //.margin(this.containerMargin3.value)
                .backgroundColor('blue')
              }
            }
            .height('100%')
          }
          .height('100%')
        }
        .height(this.ContainerHeight1.value)
        .margin(this.containerMargin2.value)

        GridCol({
          span: { xs: 12, sm: 12, md: 12, lg: 6, xl:6 }
        }) {
          GridRow() {
            GridCol({
              span: 10,
              offset: {sm: 1, md: 1} }) {
              GridRow({columns:16}) {
                GridCol({
                  span:{ sm: 7, md: 7, lg: 7, xl:7 }
                }) {

                }
                .height('100%')
                .backgroundColor('gray')
                .borderRadius(20)
                GridCol({
                  span:{ sm: 7, md: 7, lg: 7, xl:7 },
                  offset:{sm: 2}
                }) {

                }
                .height('100%')
                .borderRadius(20)
                //.margin(this.containerMargin3.value)
                .backgroundColor('gray')
              }
            }
            .height('100%')
          }
          .height('100%')
        }
        .height(this.ContainerHeight1.value)
        .margin(this.containerMargin3.value)

        if(this.currentBp === 'lg' || this.currentBp === 'xl') {
          GridCol({
            span: { xs: 12, sm: 12, md: 12, lg: 6, xl:6 }
          }) {
            GridRow() {
              GridCol({
                span: 10,
                offset: {sm: 1, md: 1} }) {
                GridRow({columns:16}) {
                  GridCol({
                    span:{ sm: 7, md: 7, lg: 7, xl:7 }
                  }) {

                  }
                  .height('100%')
                  .backgroundColor('green')
                  .borderRadius(20)
                  GridCol({
                    span:{ sm: 7, md: 7, lg: 7, xl:7 },
                    offset:{sm: 2}
                  }) {

                  }
                  .height('100%')
                  .borderRadius(20)
                  //.margin(this.containerMargin3.value)
                  .backgroundColor('green')
                }
              }
              .height('100%')
            }
            .height('100%')
          }
          .height(this.ContainerHeight1.value)
          .margin(this.containerMargin3.value)
        }
      }
      .width('100%')
      .height("100%")
      .onBreakpointChange((breakpoint) => {
        this.currentBp = breakpoint
        switch (this.currentBp) {
          case 'xs':
          case 'sm':
            this.ContainerHeight = '26%'
            this.TopHeight = '6%'
            break
          case 'lg':
          case 'xl':
          case 'md':
            this.ContainerHeight = '46%'
            this.TopHeight = '11%'
            break
        }
        console.log('断点为：' + this.currentBp + '容器高：' + this.ContainerHeight + '顶部高：' + this.TopHeight)
      })
    }
    .padding({bottom: '45vp'})
    .height("100%")
  }
}

export default Home