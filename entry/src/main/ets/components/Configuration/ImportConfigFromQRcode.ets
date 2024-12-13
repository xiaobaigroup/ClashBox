import { BreakpointState } from "../../common/breakpointsystem"
import {
  BIND_SHEET_MAIN_FONT_WEIGHT,
  BIND_SHEET_MAIN_FONTSIZE,
  BIND_SHEET_SUB_FONTSIZE,
  BIND_SHEET_TITLE_CONTAINER_HEIGHT,
  BIND_SHEET_DRAG_BAR_HEIGHT
} from "../../common/Constants"
import { ConfigAddBindSheetTitleBuilder } from "../Common"
import { hilog } from "@kit.PerformanceAnalysisKit"


// 关联：route_map.json
@Builder
export function ImportConfigFromQRcodeBuilder(name: string, param: Object){
  ImportConfigFromQRcode()
}


@Component
export struct ImportConfigFromQRcode{

  private componentName: string = 'ImportConfigFromQRcode'

  /* NV 路由相关 */
  @Consume('configAddPageInfos')
  // 页面栈
  private configAddPageInfos: NavPathStack

  /* 断点相关 */
  // NV容器的padding
  @Consume('breakPointStateNavigationListPadding')
  breakPointStateNavigationListPadding: BreakpointState<number>

  // NV title Builder
  // TODO 国际化
  @State
  private mainTitle: string = '添加配置'
  @State
  private subTitle: string = '从二维码导入'


  build() {
    NavDestination() {
      Column() {
        Text(this.componentName).fontSize(50)
        Text(this.breakPointStateNavigationListPadding.value?.toString())

      }.width('100%').height('auto').backgroundColor('#ffd43400').alignItems(HorizontalAlign.Start)
    }
    .height('100%')
    .title({builder: ConfigAddBindSheetTitleBuilder({
      isSubPage: true,
      titlePaddingLeft: BIND_SHEET_DRAG_BAR_HEIGHT / 2,
      mainTitle: this.mainTitle,
      subTitle: this.subTitle,
      mainTitleFontWeight: BIND_SHEET_MAIN_FONT_WEIGHT,
      mainTitleFontSize: BIND_SHEET_MAIN_FONTSIZE,
      subTitleFontSize: BIND_SHEET_SUB_FONTSIZE,
      padding: {
        // 为什么设置`15`，看Builder的参数中`padding`的介绍：ConfigAddBindSheetTitleBuilderParam
        left: 15,
        // left: this.breakPointStateNavigationListPadding.value,
        // right: this.breakPointStateNavigationListPadding.value
      }
    }), height: BIND_SHEET_TITLE_CONTAINER_HEIGHT + BIND_SHEET_DRAG_BAR_HEIGHT})
    .backgroundColor($r('app.color.container_background'))
    .onBackPressed(() => {
      this.configAddPageInfos.pop()
      return true
    })

  }

  aboutToAppear(): void {
    hilog.info(0xCA20, this.componentName, `#aboutToAppear`)
  }

  aboutToDisappear(): void {
    hilog.info(0xCA20, this.componentName, `#aboutToDisappear`)
  }
}