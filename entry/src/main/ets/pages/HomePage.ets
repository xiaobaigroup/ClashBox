//主页 栅格布局、媒体查询
import { BreakpointSystem, BreakpointState } from '../common/breakpointsystem'
import { mediaquery, window } from '@kit.ArkUI'
import SwitchMode from '../components/SwitchMode'
import TrafficStatistics from '../components/TrafficStatistics'
import CurrrentNode from '../components/CurrentNode'
import PublicNetwork from '../components/PublicNetwork'
import Start from '../components/Start'

interface MarginGenerate {
  top: number,
  bottom?:number
}

@Entry
@Component
struct Home {
  //@Prop isLandscape: boolean
  @State currentBp: string = ''
  @State greetings: string = '早上好'
  @State ContainerHeight: string = ''
  @State TopHeight: string = ''
  @State isLandscapePhone: boolean = false
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
    sm: '26%', md: '25%', lg: '26%', xl: '40%'
  });

  onPhoneLandscape(mediaQueryResult:mediaquery.MediaQueryResult) {
    if (mediaQueryResult.matches as boolean ) {
      this.isLandscapePhone = true
       console.log('手机横屏' + this.isLandscapePhone)
    } else {
      this.isLandscapePhone = false
       console.log('手机竖屏' + this.isLandscapePhone)
    }
  }

  // 手机横屏高度条件
  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');

  aboutToAppear() {
    this.phonelistener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.onPhoneLandscape(mediaQueryResult)
    });

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
    this.phonelistener.off('change');
  }


  build() {
    Column() {
      GridRow({
        columns: 12,
        gutter: { x: this.isLandscapePhone ? 5 : 10, y: 10 },
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
              .backgroundColor($r('app.color.settings_container_background'))
            }
            //.backgroundColor('red')
          }
        }
        .height('45vp')

        GridCol({
          span: { xs: 12, sm: 12, md: this.isLandscapePhone ? 6 : 12 , lg: 6, xl:6 }
        }) {
          GridRow() {
            GridCol({
              span: 10, offset: 1, order: 0
            }) {
              Start()
            }
            .width('100%')
            .height('100%')
            .borderRadius(20)
            .backgroundColor($r('app.color.container_background'))
          }
          .height('100%')
        }
        .height(this.isLandscapePhone ? '45%' : this.containerHeight.value)
        .margin(this.isLandscapePhone ? '2vp' : this.containerMargin1.value)

        GridCol({
          span: { xs: 12, sm: 12, md: this.isLandscapePhone ? 6 : 12, lg: 6, xl:6 }
        }) {
          GridRow() {
            GridCol({
              span: 10,
              offset: {sm: 1, md: this.isLandscapePhone ? 0 : 1} }) {
              GridRow({columns:16}) {
                GridCol({
                  span:{ sm: 7, md: 7, lg: 7, xl:7 }
                }) {
                  SwitchMode()
                }
                .height('100%')
                .backgroundColor($r('app.color.container_background'))
                .borderRadius(20)
                GridCol({
                  span:{ sm: 7, md: 7, lg: 7, xl:7 },
                  offset:{sm: 2}
                }) {
                  TrafficStatistics()
                }
                .height('100%')
                .borderRadius(20)
                //.margin(this.containerMargin3.value)
                .backgroundColor($r('app.color.container_background'))
              }
            }
            .height('100%')
          }
          .height('100%')
        }
        .height(this.isLandscapePhone ? '45%' : this.ContainerHeight1.value)
        .margin(this.isLandscapePhone ? '2vp' : this.containerMargin2.value)

        GridCol({
          span: { xs: 12, sm: 12, md: this.isLandscapePhone ? 6 : 12, lg: 6, xl:6 }
        }) {
          GridRow() {
            GridCol({
              span: 10,
              offset: 1 }) {
              GridRow({columns:16}) {
                GridCol({
                  span:{ sm: 7, md: 7, lg: 7, xl:7 }
                }) {
                  CurrrentNode()
                }
                .height('100%')
                .backgroundColor($r('app.color.container_background'))
                .borderRadius(20)
                GridCol({
                  span:{ sm: 7, md: 7, lg: 7, xl:7 },
                  offset: 2
                }) {
                  PublicNetwork()
                }
                .height('100%')
                .borderRadius(20)
                //.margin(this.containerMargin3.value)
                .backgroundColor($r('app.color.container_background'))
              }
            }
            .height('100%')
          }
          .height('100%')
        }
        .height(this.isLandscapePhone ? '45%' : this.ContainerHeight1.value)
        .margin(this.isLandscapePhone ? '2vp' : this.containerMargin3.value)

        if(this.currentBp === 'lg' || this.currentBp === 'xl' || this.isLandscapePhone) {
          GridCol({
            span: { xs: 12, sm: 12, md: this.isLandscapePhone ? 6 : 12, lg: 6, xl:6 }
          }) {
            GridRow() {
              GridCol({
                span: 10,
                offset: {sm: 1, md: this.isLandscapePhone ? 0 : 1} }) {
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
          .height(this.isLandscapePhone ? '45%' : this.ContainerHeight1.value)
          .margin(this.isLandscapePhone ? '2vp' : this.containerMargin3.value)
        }
      }
      .width('100%')
      .height("100%")
      .onBreakpointChange((breakpoint) => {
        this.currentBp = breakpoint
        /*switch (this.currentBp) {
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
        }*/
        console.log('断点为：' + this.currentBp + '容器高：' + this.ContainerHeight + '顶部高：' + this.TopHeight)
      })
    }
    .backgroundColor($r('app.color.background'))
    .padding({bottom: '45vp'})
    .height("100%")
  }
}

export default Home