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
        Text(this.itemObj.title)
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
      this.onCheck(this.index)
    })
  }
}
export default moreListItem