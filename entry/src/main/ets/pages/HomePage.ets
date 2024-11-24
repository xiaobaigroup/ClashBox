@Entry
@Component
struct Home {
  @State currentBp: string = ''
  @State greetings: string = '早上好'
  @State ContainerHeight: string = ''
  @State TopHeight: string = ''

  build() {
    Column() {
      GridRow({
        columns: 12,
        gutter: { x: 5, y: 10 },
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
              span: { xs: 1, sm: 2, md: 1, lg: 1, xl:1 },
              offset: { xs: 1, sm: 6, md: 8, lg: 9, xl:9 }, order: 1
            }) {
              Button({ type: ButtonType.Circle, stateEffect: true }) {
                SymbolGlyph($r('sys.symbol.gearshape'))
                  .fontSize(26)
              }
              .width(40)
              .height(40)
              .backgroundColor($r('app.color.container_background'))
            }
            //.height("100%")

            //.backgroundColor('red')
          }
        }
        .height('45vp')

        GridCol({
          span: { xs: 12, sm: 12, md: 6, lg: 6, xl:6 }
        }) {
          GridRow() {
            GridCol({
              span: 10, offset: 1, order: 0
            }) {
              Column() {
                Row() {

                }
                .justifyContent(FlexAlign.Start)

                Row() {
                }

                Row() {

                }
                .justifyContent(FlexAlign.End)
              }
              .width('100%')
              .height('100%')
              .borderRadius(20)
              .backgroundColor('red')

            }

            //.backgroundColor('blue')
          }
          .height('100%')
        }
        .height(this.ContainerHeight)
        .margin({top: 5})

        GridCol({
          span: { xs: 12, sm: 12, md: 6, lg: 6, xl:6 }
        }) {
          GridRow() {
            GridCol({ span: 10, offset: 1 }) {

            }
            .height('100%')
            .backgroundColor('blue')
            .borderRadius(20)
          }
          .height('100%')
        }
        .height(this.ContainerHeight)
        .margin({top: 5})

        GridCol({
          span: { xs: 12, sm: 12, md: 6, lg: 6, xl:6 }
        }) {
          GridRow() {
            GridCol({ span: 10, offset: 1 }) {

            }
            .height('100%')
            .backgroundColor('gray')
            .borderRadius(20)
          }
          .height('100%')
        }
        .height(this.ContainerHeight)
        .margin({top: 5})

        GridCol({
          span: { xs: 12, sm: 12, md: 6, lg: 6, xl:6 }
        }) {
          GridRow() {
            GridCol({ span: 10, offset: 1 }) {

            }
            .height('100%')
            .backgroundColor('green')
            .borderRadius(20)
          }
          .height('100%')
        }
        .height(this.ContainerHeight)
        .margin({top: 5})
      }
      .width('100%')
      .height("100%")
      .onBreakpointChange((breakpoint) => {
        this.currentBp = breakpoint
        switch (this.currentBp) {
          case 'xs':
          case 'sm':
            this.ContainerHeight = '23%'
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