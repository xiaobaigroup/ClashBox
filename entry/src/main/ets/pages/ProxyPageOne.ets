
@Entry
@Component
struct ProxyPageOne {

  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary') //一级图标色，黑色

  build() {
    Column() {
      Row() {
        Text($r('app.string.Proxy'))
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .width('83%')
          .textAlign(TextAlign.Start)
        Blank()
        //编辑图标
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.square_and_pencil'))
            .fontSize(24)//      .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)//分层颜色
            .fontColor([this.icon_secondary])
        }
        .margin({ right: 50, bottom: 15 })
        .width(40)
        .height(40)
        .backgroundColor($r('app.color.settings_container_background'))

      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Top)

      Navigation() {
        /*List() {
          ForEach(this.moreList, (item: moreData, index: number) => {
            ListItem() {
              moreListItem({
                index: index,
                itemObj: item,
                onCheck: (index: number) => {
                  this.handleCheck(index)
                }
              })
            }
            .margin({bottom: this.listBottom.value })

          })
        }*/
      }

    }

  }
}