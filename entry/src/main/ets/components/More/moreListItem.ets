import { moreData } from "../../common/Constants"

@Component
struct moreListItem {
  @Prop itemObj: moreData
  @Prop index: number
  onCheck = (index: number) => {}

  build() {
    Row() {
      Row() {
        SymbolGlyph(this.itemObj.icons)
          .fontSize(24)
          .margin({left: 12})
        Column() {
          Text(this.itemObj.title)
            .fontWeight(FontWeight.Medium)
            .fontSize(16)
          if (this.itemObj.subtitle) {
            Text(this.itemObj.subtitle)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .width('75%')
              .fontWeight(FontWeight.Normal)
              .margin({top: 2 })
              .fontSize(14)
          }
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 12 })
        Blank()
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(28)
          .margin({right: 12})
      }
      .width('94%')
      .height(53)
      .borderRadius(20)
      .backgroundColor($r('app.color.container_background'))
      Row()
        .height(10)
    }

    .onClick(() => {
      this.onCheck(this.index)
    })
  }
}
export default moreListItem