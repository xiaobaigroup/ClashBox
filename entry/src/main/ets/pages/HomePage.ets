@Entry
@Component
struct Home {
  @State currentBp: string = 'unknown'

  build() {
    Column() {
      Text('123')
     /* GridRow({
        columns: 12,
        gutter: { x: 5, y: 10 },
        breakpoints: { value: ["320vp", "600vp", "840vp"],
          reference: BreakpointsReference.WindowSize },
      })
      {
        GridCol()
      }
      .width("100%")
      .height("100%")
      .onBreakpointChange((breakpoint) => {
        this.currentBp = breakpoint
      })*/
    }
    .width('100%')
    //.margin({ left: 10, top: 5, bottom: 5 })
    //.height(200)
    .border({ color: '#880606', width: 2 })
  }
}
export default Home