import {
  BIND_SHEET_MAIN_FONT_WEIGHT,
  BIND_SHEET_MAIN_FONTSIZE,
  BIND_SHEET_SUB_FONTSIZE,
  BIND_SHEET_DRAG_BAR_HEIGHT,
  BIND_SHEET_TITLE_LEFT_SYMBOL_WEIGHT,
  RouteName,
} from "../../common/Constants"
import { BindSheetTitleCustomBuilder, BindSheetTitleCustomBuilderMenu, CustomDownloadingDialog } from "../Common"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { ConfigInfo } from "./ConfigInfo"
import { PromptAction, window } from "@kit.ArkUI"
import { ConfigData } from "../../common/PageArgumentEntity"
import { util } from "@kit.ArkTS"
import { CustomConfirmDialog } from '../Common'
import { BusinessError } from "@kit.BasicServicesKit"
import { common } from "@kit.AbilityKit"
import ClashViewModel from "../../entryability/ClashViewModel"
import { getResourceString } from "../../utils/ResourceStringUtil"
import { UIConfig } from "../../entryability/AppState"


// 关联：route_map.json
@Builder
export function ImportConfigFromURLBuilder(name: string, param: Object){
  ImportConfigFromURL()
}


@Component
export struct ImportConfigFromURL{

  private componentName: string = 'ImportConfigFromURL'
  private context = getContext() as common.UIAbilityContext
  private promptAction:PromptAction = this.getUIContext()?.getPromptAction()
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  // 模态弹窗显示变量
  @Consume isShowConfigAddBindSheet: boolean
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
    configUrl: '',
    isConfigAutoUpdate: false,
    lastUpdateDateTime: 0,
    updateTime: 0
  }

  /* 断点相关 */
  // NV容器的padding
  // @Consume('breakPointStateNavigationListPadding')
  // breakPointStateNavigationListPadding: BreakpointState<number>

  /* NV title Builder */
  @State
  private mainTitle: string = getResourceString($r('app.string.add_config'), this)
  @State
  private subTitle: string = getResourceString($r('app.string.Import_from_url'), this)
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
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
      // 保存配置后关闭半模态窗口
      this.isShowConfigAddBindSheet = false
      this.isEnableIndexForegroundBlur = false
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
  private configCustomConfirmDialogController: CustomDialogController | null= new CustomDialogController({
    builder: CustomConfirmDialog({
      title: $r('app.string.save_current_configuration'),
      cancelText: $r('app.string.Cancel'),
      confirmText: $r('app.string.Save'),
      cancelButtonBackgroundColor: Color.Transparent,
      // 不可以使用`@Consume`注解的变量
      // confirmButtonBackgroundColor: this.icon_emphasize,
      cancel: () => {
        // 取消保存配置后关闭半模态窗口
        this.isShowConfigAddBindSheet = false
        this.isEnableConfigPageBindSheetForegroundBlur = false
        this.isEnableIndexForegroundBlur = false
        this.configAddPageInfos.pop(true)
      },
      confirm: ()=> {
        // 保存配置后关闭半模态窗口
        this.isShowConfigAddBindSheet = false
        this.isEnableConfigPageBindSheetForegroundBlur = false
        this.isEnableIndexForegroundBlur = false
        this.saveConfig(this.configData.isNewConfig)
      }
    }),
    cancel: () => {
      this.isEnableConfigPageBindSheetForegroundBlur = false
      this.isEnableIndexForegroundBlur = false
    },
    // autoCancel: true,
    alignment: DialogAlignment.Center,
    width: 328,
    backgroundColor: $r('app.color.list_item_background_color'),
  })
  // 配置下载弹框 title动态值
  @State
  private customDownloadingDialogTitle: ResourceStr = $r('app.string.downloading_configuration_file')
  // 配置下载弹框 Controller定义
  configCustomDownloadingDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDownloadingDialog({
      title: this.customDownloadingDialogTitle,
      cancelText: $r('app.string.cancel_download'),
      cancel: () => {},
    }),
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
        mainTitle: this.configData.isNewConfig ? this.mainTitle : getResourceString($r('app.string.edit_config'), this),
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
        this.configCustomConfirmDialogController?.open()
        // 更改bindSheet的前景模糊
       this.isEnableConfigPageBindSheetForegroundBlur = true
        return true
      } else {
        return false
      }
    })
    .onReady( () => {
      let paramJsonStr: string = JSON.stringify(this.configAddPageInfos.getParamByName(RouteName.IMPORT_CONFIG_FROM_URL))
      hilog.info(0xCA11, this.componentName, `#aboutToAppear#NavPathStack.getParamByName(${RouteName.IMPORT_CONFIG_FROM_URL}), result is: ${paramJsonStr}`)

      if( this.configAddPageInfos.getParamByName(RouteName.IMPORT_CONFIG_FROM_URL).length > 0 && this.configAddPageInfos.getParamByName(RouteName.IMPORT_CONFIG_FROM_URL)[0] !== null ) {
        try {
          this.configData = (JSON.parse(paramJsonStr) as Array<ConfigData>)[0]

        } catch (e) {
          let error = e as BusinessError;
          hilog.error(0xCA11, this.componentName, `#aboutToAppear#JSON.parse(paramJsonStr) as ConfigData#ERROR: code is [${error.code}],message is [${error.message}]`)
        }
      }
    })
    .animation({ duration: this.uiConfig.animationSpeed, curve: Curve.Ease })
  }

  aboutToAppear(): void {
    hilog.info(0xCA10, this.componentName, `#aboutToAppear executed`)
    // XXX 没有写`this.icon_emphasize`的`Watch`事件，是因为如果在设置页面里设置了其他主题色时，这个页面一定不是打开的状态
    this.saveMenus.symbolBackgroundColor = this.icon_emphasize
  }

  aboutToDisappear(): void {
    hilog.info(0xCA10, this.componentName, `#aboutToDisappear executed`)
    // 自定义弹框 清空
    this.configCustomConfirmDialogController = null
    this.isEnableConfigPageBindSheetForegroundBlur = false
    hilog.info(0xCA10, this.componentName, `#aboutToDisappear#置空[配置页\`bindSheet\`内提示是否保存配置信息的自定义弹框]`)
  }

  /**
   * TODO 保存配置
   */
  async saveConfig(isNewConfig: boolean){
    if (isNewConfig) {
      this.customDownloadingDialogTitle = $r('app.string.downloading_configuration_file')
      this.configCustomDownloadingDialogController.open()
      try {
        await ClashViewModel.addOrUpdateProfileByUrl(this.configData, null)
        this.configCustomDownloadingDialogController.close()
        this.promptAction.showToast({message: getResourceString($r('app.string.download_success'), this)})
      } catch (e) {
        console.error("ClashNext", e.message, e.stack);
        this.configCustomDownloadingDialogController.close()
        this.promptAction.showToast({message: getResourceString($r('app.string.download_failed'), this) + e.message || e})
      }

    } else {
      this.customDownloadingDialogTitle = $r('app.string.updating_configuration_file')
      this.configCustomDownloadingDialogController.open()
      try {
        await ClashViewModel.addOrUpdateProfileByUrl(this.configData, this.configData.configId)
        this.configCustomDownloadingDialogController.close()
        this.promptAction.showToast({message: getResourceString($r('app.string.update_success'), this)})
      } catch (e) {
        console.error("ClashNext", e.message, e.stack);
        this.configCustomDownloadingDialogController.close()
        this.promptAction.showToast({message: getResourceString($r('app.string.download_failed'), this) + e.message || e})
      }

    }
  }

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
    this.allInputHaveValue = (this.configData.configUrl.length > 0/* && this.configData.configName.length > 0*/)
    // hilog.info(0xCA12, this.componentName, `#checkAllInputHaveValue is [${this.allInputHaveValue}]}`)
  }
}