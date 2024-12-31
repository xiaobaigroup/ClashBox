import { settingsData } from "../../common/Constants"

@Component
struct settingsListItem {
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Prop itemObj: settingsData
  @Prop index: number
  onCheck = (index: number) => {}

  build() {
    Row() {
      Row() {
        SymbolGlyph(this.itemObj.icons)
          .fontSize(24)
          .margin({left: 12})
          .fontColor([this.icon_emphasize])
        Column() {
          Text(this.itemObj.title)
            //.height(48)
            .fontWeight(FontWeight.Medium)
            .fontSize(16)
          if(this.itemObj.subtitle) {
            Text(this.itemObj.subtitle)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('60%')
              .maxLines(1)
              .fontSize(14)
          }
        }
        .padding({ left: 12 })
        .alignItems(HorizontalAlign.Start)
        Blank()
        Text(this.itemObj.hint)
          .fontColor($r('sys.color.font_secondary'))
          .padding({ left: 8 })
          .fontSize(14)
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(24)
          .margin({left: 12, right: 12})
          .fontColor([this.icon_primary])
      }
      .width('94%')
      .height(53)
      .borderRadius(20)
      .backgroundColor($r('app.color.container_background'))
      Row()
        .height(10)
    }
    .clickEffect({ level: ClickEffectLevel.MIDDLE })
    .onClick(() => {
      this.onCheck(this.index)
    })
  }
}
export default settingsListItem