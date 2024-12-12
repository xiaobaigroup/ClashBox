import { BreakpointState } from "../../../common/breakpointsystem"
import { ListOverwriteData, moreData } from "../../../common/Constants"
import moreListItem from "../moreListItem"
import { hilog } from "@kit.PerformanceAnalysisKit"

@Component
struct Overwrite {
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @State overwriteList: moreData[] = ListOverwriteData()
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary') //一级图标色，黑色
  @Consume('breakPointStatemorePagelistBottom') listBottom: BreakpointState<number>

  handleCheck(index: number) {
    // 跳转
    let itemData = this.overwriteList[index]
    this.pageInfos.pushPathByName(itemData.name, false)
    hilog.isLoggable(0xFF00, "OverwritetestTag", hilog.LogLevel.INFO);
    hilog.info(0xFF00, "OverwritetestTag", itemData.name)
  }

  build() {
    NavDestination() {
      Row() {
        //返回图标
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(28)
            .fontColor([this.icon_secondary])
        }
        .margin({left: this.morePageMargin.value})
        .onClick(() => {
          this.pageInfos.pop(true)
        })
        .width(40)
        .height(40)
        .backgroundColor($r('app.color.settings_container_background'))
        Text($r('app.string.Overwrite'))
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
          .margin({left: 8})
        Blank()

      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)

      List() {
        ForEach(this.overwriteList, (item: moreData, index: number) => {
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

      }
      .width('100%')
      .height(500)
      .margin({ top: 10, left: this.morePageMargin.value, right: this.morePageMargin.value })
      .borderRadius(18)
      .alignListItem(ListItemAlign.Center)

    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.pageInfos.clear();
      return true;
    })
  }
}
export default Overwrite