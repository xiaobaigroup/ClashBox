/*
 * More列表页
 * 2024.12.04
 *
 */
import { BreakpointState, BreakpointSystem } from '../common/breakpointsystem'
import Constants from '../common/Constants';
import { ListItemProp } from '../common/ListItemProp';

@Entry
@Component
struct MorePage {
  @State moreList: ListItemProp[] = Constants.MoreList;
  @State compStr: BreakpointState<string> = BreakpointState.of({
    xs: "xs", sm: "sm", md: "md", lg: "lg", xl: "xl"
  })
  @State listMargin: BreakpointState<number> = BreakpointState.of({
    xs: 12, sm: 14, md: 28, lg: 36, xl: 36
  });

  aboutToAppear(): void {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.listMargin)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear(): void {
    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.listMargin)
    BreakpointSystem.getInstance().stop()
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.More'))
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .margin({ left: this.listMargin.value })
      }
      .width('100%')
      .margin({ bottom: 15 })

      Scroll() {
        Column() {
          ForEach(this.moreList, (item: ListItemProp) => {
            Column() {
              ForEach(item.children, (itemChild: ListItemProp) => {

                Column() {
                  Row() {
                    SymbolGlyph(itemChild.icons)
                      .fontSize(24)
                      .margin({left: 12})
                    Text(itemChild.title)
                      .height(48)
                      .fontWeight(FontWeight.Medium)
                      .padding({ left: 12 })
                      .fontSize(16)
                    Blank()
                    Row()
                      .width(10)
                      .height(10)
                      .margin({ right: 20 })
                      .border({
                        width: {
                          top: 2,
                          right: 2
                        },
                        color: '#000000'
                      })
                      .rotate({ angle: 45 })
                  }
                  .width('100%')
                  .height(53)
                  .borderRadius(20)
                  .backgroundColor('white')
                  Row()
                    .height(10)

                }
                .onClick(() => {
                  //this.pageInfos.pushPathByName(itemChild.name, false);
                  console.log('名字是' + itemChild.name)
                })

              })
            }
            .margin({
              top: 10,
              bottom: 18
            })
            .borderRadius(18)

            //.backgroundColor('gray')
          })
        }
        .padding({
          left: 16,
          right: 16
        })
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)

    }
    .width('100%')
    .height('100%')
    .padding({ bottom: '45vp' })
    .backgroundColor('#F1F3F5')
  }
}

export default MorePage