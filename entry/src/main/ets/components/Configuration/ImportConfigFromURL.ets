import { BreakpointState } from "../../common/breakpointsystem"
import {
  BIND_SHEET_MAIN_FONT_WEIGHT,
  BIND_SHEET_MAIN_FONTSIZE,
  BIND_SHEET_SUB_FONTSIZE,
  BIND_SHEET_DRAG_BAR_HEIGHT,
  BIND_SHEET_TITLE_LEFT_SYMBOL_WEIGHT,
} from "../../common/Constants"
import { BindSheetTitleCustomBuilder, BindSheetTitleCustomBuilderMenu } from "../Common"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { ConfigInfo } from "./ConfigInfo"
import { PromptAction } from "@kit.ArkUI"
import { ConfigData } from "../../common/PageArgumentEntity"
import { util } from "@kit.ArkTS"


// 关联：route_map.json
@Builder
export function ImportConfigFromURLBuilder(name: string, param: Object){
  ImportConfigFromURL()
}


@Component
export struct ImportConfigFromURL{

  private componentName: string = 'ImportConfigFromURL'
  private promptAction:PromptAction = this.getUIContext()?.getPromptAction()

  /* NV 路由相关 */
  @Consume('configAddPageInfos')
  // 页面栈
  private configAddPageInfos: NavPathStack
  // TODO 路由传参
  // 路由参数：是否为新配置（非已有配置进入编辑状态）
  isNewConfig: boolean = true
  // 配置详情
  @State
  @Watch('configDataChanged')
  private configData: ConfigData = {
    configId: util.generateRandomUUID(),
    isNewConfig: true,
    configName: '',
    configURL: '',
    isConfigAutoUpdate: false,
  }
  /* 断点相关 */
  // NV容器的padding
  // @Consume('breakPointStateNavigationListPadding')
  // breakPointStateNavigationListPadding: BreakpointState<number>

  /* NV title Builder */
  // TODO 国际化
  @State
  private mainTitle: string = '添加配置'
  @State
  private subTitle: string = '从URL(链接)导入'
  // 标题栏工具菜单
  // { symbol: $r('sys.symbol.star'), action: () => { this.menus.pop() } },
  // 保存按钮
  private saveMenus: BindSheetTitleCustomBuilderMenu = {
    symbol: $r('sys.symbol.save'),
    symbolFontColor: ['#e6ffffff'],
    symbolBackgroundColor: '#FF0A59F7',
    action: () => {
      this.saveConfig(this.isNewConfig)
    }
  }
  @State
  private menus: Array<BindSheetTitleCustomBuilderMenu> = []

  /* Input事件相关变量 */
  // 配置名 Input 是否有值
  private configNameInputHaveText: boolean = false
  // 配置 URL 是否有值
  private configURLInputHaveText: boolean = false

  /* 父子传参 */


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
          // left: this.breakPointStateNavigationListPadding.value,
          // 避让`bindSheet`右上角的叉号本身`40vp`、右`15vp`
          right: BIND_SHEET_TITLE_LEFT_SYMBOL_WEIGHT + 15
          // right: this.breakPointStateNavigationListPadding.value
        },
        menus: this.menus,
      })
      // 替代`NavDestination`的标题栏 END

      // 配置信息 START
      ConfigInfo({isNewConfig: this.isNewConfig, configData: $configData})
      // 配置信息 END
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
    hilog.info(0xCA10, this.componentName, `#aboutToAppear`)
  }

  aboutToDisappear(): void {
    hilog.info(0xCA10, this.componentName, `#aboutToDisappear`)
  }

  /**
   * TODO 保存配置
   */
  saveConfig(isNewConfig: boolean){
    if (isNewConfig) {
      this.promptAction.showToast({ message: `保存中...` })
      // this.menus.push({ symbol: $r('sys.symbol.heart') })
    } else {
      this.promptAction.showToast({ message: `更新配置信息中...` })
    }
  }

  /**
   * 检查配置名 Input && 配置 URL 是否都有值
   *    true: 显示保存按钮。 false反之
   */
  // checkInput() {
  //   if(this.configNameInputHaveText && this.configURLInputHaveText) {
  //     this.menus.push(this.saveMenus)
  //   }
  // }

  /**
   * 检查配置名 Input && 配置 URL 是否都有值
   *    true: 显示保存按钮。 false反之
   */
  configDataChanged() {
    if (this.configData.configName.length > 0 && this.configData.configURL.length > 0) {
      if (this.menus.filter(i => i === this.saveMenus).length <= 0) {
        this.menus.push(this.saveMenus)
      }
    } else {
      this.menus.pop()
    }
  }
}