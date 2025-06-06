import { BreakpointState } from "../../common/breakpoint/breakpointsystem"
import {
  BIND_SHEET_MAIN_FONT_WEIGHT,
  BIND_SHEET_MAIN_FONTSIZE,
  BIND_SHEET_SUB_FONTSIZE,
  BIND_SHEET_TITLE_CONTAINER_HEIGHT,
  BIND_SHEET_DRAG_BAR_HEIGHT,
  BIND_SHEET_TITLE_LEFT_SYMBOL_WEIGHT
} from "../../common/entity/Constants"
import { BindSheetTitleCustomBuilder } from "../Common/Common"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { getResourceString } from "../../common/utils/ResourceStringUtil"
import { NavigationListPadding } from "../../common/breakpoint/BreakPoint"


// 关联：route_map.json
@Builder
export function CreateNewConfigBuilder(name: string, param: Object){
  CreateNewConfig()
}


@Component
export struct CreateNewConfig{

  private componentName: string = 'CreateNewConfig'

  /* NV 路由相关 */
  @Consume('configAddPageInfos')
  // 页面栈
  private configAddPageInfos: NavPathStack
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // NV title Builder
  @State
  private mainTitle: string = getResourceString($r('app.string.add_config'), this)
  @State
  private subTitle: string = getResourceString($r('app.string.new_blank_configuration'), this)


  build() {
    NavDestination() {
      // 替代`NavDestination`的标题栏 START
      BindSheetTitleCustomBuilder({
        pageInfos: this.configAddPageInfos,
        isSubPage: true,
        titlePaddingLeft: BIND_SHEET_DRAG_BAR_HEIGHT / 2,
        mainTitle: this.mainTitle,
        subTitle: this.subTitle,
        mainTitleFontWeight: BIND_SHEET_MAIN_FONT_WEIGHT,
        mainTitleFontSize: BIND_SHEET_MAIN_FONTSIZE,
        subTitleFontSize: BIND_SHEET_SUB_FONTSIZE,
        titleBackgroundColor: $r('app.color.background'),
        padding: {
          // 为什么设置`15`，看Builder的参数中`padding`的介绍：ConfigAddBindSheetTitleBuilderParam
          left: 15,
          right: BIND_SHEET_TITLE_LEFT_SYMBOL_WEIGHT + 15 * 2
        },
        menus: []
      })
      // 替代`NavDestination`的标题栏 END

      // START
      Column() {
        Text(this.componentName).fontSize(50)
        Text(`NavigationListPadding(this.widthBp, this.heightBp) value is [${NavigationListPadding(this.widthBp, this.heightBp)}]`)

      }.width('100%').height('auto').backgroundColor('#ffac70e9').alignItems(HorizontalAlign.Start)
      // END
    }
    .height('100%')
    .hideTitleBar(true)
    // .title({builder: , height: BIND_SHEET_TITLE_CONTAINER_HEIGHT + BIND_SHEET_DRAG_BAR_HEIGHT})
    .backgroundColor($r('app.color.container_background'))
    // .onBackPressed(() => {
    //   this.configAddPageInfos.pop(true)
    //   return true
    // })

  }

  aboutToAppear(): void {
    hilog.info(0xCD10, this.componentName, `#aboutToAppear executed`)
  }

  aboutToDisappear(): void {
    hilog.info(0xCD10, this.componentName, `#aboutToDisappear executed`)
  }
}