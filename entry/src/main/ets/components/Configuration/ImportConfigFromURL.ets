import {
  BIND_SHEET_MAIN_FONT_WEIGHT,
  BIND_SHEET_MAIN_FONTSIZE,
  BIND_SHEET_SUB_FONTSIZE,
  BIND_SHEET_DRAG_BAR_HEIGHT,
  BIND_SHEET_TITLE_LEFT_SYMBOL_WEIGHT,
  RouteName,
} from "../../common/Constants"
import { BindSheetTitleCustomBuilder, BindSheetTitleCustomBuilderMenu } from "../Common"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { ConfigInfo } from "./ConfigInfo"
import { PromptAction } from "@kit.ArkUI"
import { ConfigData } from "../../common/PageArgumentEntity"
import { util } from "@kit.ArkTS"
import { ConfigCustomDialog } from './ConfigCustomDialog'
import { BusinessError } from "@kit.BasicServicesKit"


// 关联：route_map.json
@Builder
export function ImportConfigFromURLBuilder(name: string, param: Object){
  ImportConfigFromURL()
}


@Component
export struct ImportConfigFromURL{

  private componentName: string = 'ImportConfigFromURL'
  private promptAction:PromptAction = this.getUIContext()?.getPromptAction()

  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor

  /* 是否开启 配置页 `bindSheet` 组件的前景模糊 */
  @Consume('isEnableConfigPageBindSheetForegroundBlur')
  private isEnableConfigPageBindSheetForegroundBlur: boolean

  /* NV 路由相关 */
  @Consume('configAddPageInfos')
  // 页面栈
  private configAddPageInfos: NavPathStack
  // 配置详情（要添加到用户首选项里的数据）
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
    // 跟随主题色：由于在这里直接赋值 this.icon_emphasize 编译器提示需要初始化 this.icon_emphasize 的值，放到了 aboutToAppear 回调里重新赋值
    symbolBackgroundColor: '#FF0A59F7',
    action: () => {
      this.saveConfig(this.configData.isNewConfig)
    }
  }
  // 当前显示的工具集合 默认为空 待两个input都有值之后才加入保存按钮菜单
  @State
  private menus: Array<BindSheetTitleCustomBuilderMenu> = []

  /* Input事件相关变量 */
  // [true: 都有值, false: 不是所有的input都有值]
  @State
  private allInputHaveValue: boolean = false

  /* 父子传参 */


  /* 自定义弹框 */
  // 配置是否保存弹框 Controller定义
  private configCustomDialogController: CustomDialogController | null= new CustomDialogController({
    builder: ConfigCustomDialog({
      cancelButtonBackgroundColor: Color.Transparent,
      // confirmButtonBackgroundColor: this.icon_emphasize_copy,
      cancel: () => {
        this.isEnableConfigPageBindSheetForegroundBlur = false
        this.configAddPageInfos.pop(true)
      },
      confirm: ()=> {
        this.isEnableConfigPageBindSheetForegroundBlur = false
        this.saveConfig(this.configData.isNewConfig)
      }
    }),
    cancel: () => {
      this.isEnableConfigPageBindSheetForegroundBlur = false
    },
    autoCancel: true,
    alignment: DialogAlignment.Center,
    width: 328,
    backgroundColor: $r('app.color.list_item_background_color'),
  })


  build() {
    NavDestination() {
      // 替代`NavDestination`的标题栏 START
      BindSheetTitleCustomBuilder({
        pageInfos: this.configAddPageInfos,
        // isSubPage: true,
        isSubPage: this.configData.isNewConfig,
        titlePaddingLeft: BIND_SHEET_DRAG_BAR_HEIGHT / 2,
        mainTitle: this.configData.isNewConfig ? this.mainTitle : '编辑配置',
        subTitle: this.configData.isNewConfig ? this.subTitle : '',
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
      ConfigInfo({configData: $configData})
      // 配置信息 END
    }
    .height('100%')
    .hideTitleBar(true)
    // .title({builder: , height: BIND_SHEET_TITLE_CONTAINER_HEIGHT + BIND_SHEET_DRAG_BAR_HEIGHT})
    .backgroundColor($r('app.color.container_background'))
    .onBackPressed(() => {
      if (this.allInputHaveValue) {
        // 弹框是否保存已经编辑好的配置
        this.configCustomDialogController?.open()
        // 更改bindSheet的前景模糊
        this.isEnableConfigPageBindSheetForegroundBlur = true
        return true
      } else {
        return false
      }
    })
    .onReady( () => {
      let paramJsonStr: string = JSON.stringify(this.configAddPageInfos.getParamByName(RouteName.ImportConfigFromURL))
      hilog.info(0xCA11, this.componentName, `#aboutToAppear#NavPathStack.getParamByName(${RouteName.ImportConfigFromURL}), result is: ${paramJsonStr}`)

      if( this.configAddPageInfos.getParamByName(RouteName.ImportConfigFromURL).length > 0 && this.configAddPageInfos.getParamByName(RouteName.ImportConfigFromURL)[0] !== null ) {
        try {
          this.configData = (JSON.parse(paramJsonStr) as Array<ConfigData>)[0]
        } catch (e) {
          let error = e as BusinessError;
          hilog.error(0xCA11, this.componentName, `#aboutToAppear#JSON.parse(paramJsonStr) as ConfigData#ERROR: code is [${error.code}],message is [${error.message}]`)
        }
      }
    })
    .animation({ duration: 200, curve: Curve.Ease })

  }

  aboutToAppear(): void {
    hilog.info(0xCA10, this.componentName, `#aboutToAppear executed`)
    this.saveMenus.symbolBackgroundColor = this.icon_emphasize
  }

  aboutToDisappear(): void {
    hilog.info(0xCA10, this.componentName, `#aboutToDisappear executed`)
    // 自定义弹框 清空
    this.configCustomDialogController = null
    this.isEnableConfigPageBindSheetForegroundBlur = false
    hilog.info(0xCA10, this.componentName, `#aboutToDisappear#置空[配置页内bindSheet是否保存自定义弹框]`)
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
    this.checkAllInputHaveValue()
    if (this.allInputHaveValue) {
      if (this.menus.filter(i => i === this.saveMenus).length <= 0) {
        // 新增`保存配置`菜单按钮
        this.menus.push(this.saveMenus)
      }
    } else {
      // 移除`保存配置`菜单按钮
      for (let i = 0; i < this.menus.length; i++) {
        if (this.menus[i] === this.saveMenus) {
          this.menus.splice(i, 1)
          break
        }
      }
    }
  }

  /**
   * 检查配置名 Input && 配置 URL 是否都有值
   */
  checkAllInputHaveValue() {
    this.allInputHaveValue = (this.configData.configName.length > 0 && this.configData.configURL.length > 0)
    hilog.info(0xCA11, this.componentName, `#checkAllInputHaveValue is [${this.allInputHaveValue}]}`)
  }
}