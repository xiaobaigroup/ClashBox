import { BreakpointState } from "../../common/breakpointsystem"
import { MoreTop } from "./MoreTopBuilder"

@Component
struct Diversion {
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')

  @Builder
  diversionSearch() {
  }
  @Builder
  diversionOther() {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph($r('sys.symbol.plus'))
        .fontSize(24)
        .fontColor([this.icon_primary])
    }
    .width(40)
    .height(40)
    .backgroundColor($r('app.color.settings_container_background'))
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          MoreTop({
            title: $r('app.string.Diversion_Strategy'),
            searchButton: this.diversionSearch,
            otherButton: this.diversionOther
          })
        }.width('100%')


      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .padding({right: this.morePageMargin.value, left: this.morePageMargin.value})
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.pageInfos.clear();
      return true;
    })
  }
}

export default Diversion