import { settingsData } from "../../common/Constants"
import { UIConfig } from "../../entryability/AppState"
import { customAnimationUtil } from "../../utils/Animation"
import { ExperimentalFunction } from "../Common"
import { LengthMetrics } from "@kit.ArkUI"

@Component
struct settingsListItem {
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @State isExperimental: boolean = false
  @Prop itemObj: settingsData
  @Prop index: number
  onCheck = (index: number) => {}

  build() {
    Row() {
      SymbolGlyph(this.itemObj.icons)
        .fontSize(24)
        .margin({right: 10, left: 12})
        .fontColor([this.icon_emphasize])
        .transition(customAnimationUtil.isScaleTranIcon(10,this.uiConfig))
      Flex({
        direction: FlexDirection.Column,
        space:{main: LengthMetrics.vp(2)},
        alignItems: ItemAlign.Start,
        justifyContent: FlexAlign.Center
      }){
        Text(this.itemObj.title)
          .fontWeight(FontWeight.Medium)
          .fontSize(16)
        if(this.itemObj.subtitle) {
          Text(this.itemObj.subtitle)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .fontSize(14)
        }
      }
      if (this.index === (this.uiConfig.isShowExperimentalFunction ? 2 : -1)) {
        ExperimentalFunction()
      }
      Blank()
      Text(this.itemObj.hint)
        .fontColor($r('sys.color.font_secondary'))
        .padding({ left: 8 })
        .fontSize(14)
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(24)
        .margin({left: 12, right: 12})
        .fontColor([this.icon_primary])
    }.height(53)
    .width('100%')
    .borderRadius(20)
    .margin({bottom: 10})
    .backgroundColor($r('app.color.container_background'))
    .alignItems(VerticalAlign.Center)
    .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
    .onClick(() => {
      this.onCheck(this.index)
    })
  }
}
export default settingsListItem