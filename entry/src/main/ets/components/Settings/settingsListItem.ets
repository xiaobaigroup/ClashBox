import { settingsData } from "../../common/Constants"

@Component
struct settingsListItem {
  @Prop itemObj: settingsData
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
            //.height(48)
            .fontWeight(FontWeight.Medium)
            .fontSize(16)
          Text(this.itemObj.subtitle)
            .fontSize(14)
        }
        .padding({ left: 12 })
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text(this.itemObj.hint)
          .fontColor('gray')
          .padding({ left: 12 })
          .fontSize(14)
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
      .backgroundColor($r('app.color.container_background'))
      Row()
        .height(10)
    }
    .onClick(() => {
      this.onCheck(this.index)
    })
  }
}
export default settingsListItem