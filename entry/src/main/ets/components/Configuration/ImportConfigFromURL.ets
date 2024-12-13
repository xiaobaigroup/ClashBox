import { BreakpointState } from "../../common/breakpointsystem"
import {
  BIND_SHEET_MAIN_FONT_WEIGHT,
  BIND_SHEET_MAIN_FONTSIZE,
  BIND_SHEET_SUB_FONTSIZE,
  BIND_SHEET_TITLE_CONTAINER_HEIGHT,
  BIND_SHEET_DRAG_BAR_HEIGHT,
} from "../../common/Constants"
import { ConfigAddBindSheetTitleBuilder } from "../Common"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { ConfigInfo } from "./ConfigInfo"


// 关联：route_map.json
@Builder
export function ImportConfigFromURLBuilder(name: string, param: Object){
  ImportConfigFromURL()
}


@Component
export struct ImportConfigFromURL{

  private componentName: string = 'ImportConfigFromURL'

  /* NV 路由相关 */
  @Consume('configAddPageInfos')
  // 页面栈
  private configAddPageInfos: NavPathStack
  // TODO 路由传参
  // 路由参数：是否是新配置（非已有配置进入编辑状态）
  isNewConfig: boolean = false

  /* 断点相关 */
  // NV容器的padding
  // @Consume('breakPointStateNavigationListPadding')
  // breakPointStateNavigationListPadding: BreakpointState<number>

  // NV title Builder
  // TODO 国际化
  @State
  private mainTitle: string = '添加配置'
  @State
  private subTitle: string = '从URL(链接)导入'


  build() {
    NavDestination() {
      ConfigInfo({isNewConfig: this.isNewConfig})
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
    hilog.info(0xCA10, this.componentName, `#aboutToAppear`)
  }

  aboutToDisappear(): void {
    hilog.info(0xCA10, this.componentName, `#aboutToDisappear`)
  }
}