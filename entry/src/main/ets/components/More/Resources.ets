import { BreakpointState } from "../../common/breakpointsystem"
import { MoreTop } from "./MoreTopBuilder"

@Component
struct Resources {
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色

  @Builder
  reaourceSearch() {
  }
  @Builder
  reaourceOther() {
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          MoreTop({
            title: $r('app.string.Resources'),
            searchButton: this.reaourceSearch,
            otherButton: this.reaourceOther
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

export default Resources