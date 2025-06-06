import { BreakpointState } from "../../common/breakpoint/breakpointsystem"
import {
  BIND_SHEET_MAIN_FONT_WEIGHT,
  BIND_SHEET_MAIN_FONTSIZE,
  BIND_SHEET_SUB_FONTSIZE,
  BIND_SHEET_TITLE_CONTAINER_HEIGHT,
  BIND_SHEET_DRAG_BAR_HEIGHT,
  BIND_SHEET_TITLE_LEFT_SYMBOL_WEIGHT,
  TEXT_AREA_MAX_LENGTH,
  FONT_SIZE_16,
  TEXT_INPUT_HEIGHT,
  RouteName,
  BORDER_RADIUS_20
} from "../../common/entity/Constants"
import { BindSheetTitleCustomBuilder, BindSheetTitleCustomBuilderMenu, CustomConfirmDialog } from "../Common/Common"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { picker } from "@kit.CoreFileKit"
import ClashViewModel from "../../entryability/ClashViewModel"
import { getResourceString } from "../../common/utils/ResourceStringUtil"
import { customVibrator } from "../../common/utils/VibratorUtil"
import { util } from "@kit.ArkTS"
import { ConfigData } from "../../common/entity/PageArgumentEntity"
import { BusinessError } from "@kit.BasicServicesKit"
import { UIConfig } from "../../entryability/AppState"
import { customAnimationUtil } from "../../common/utils/Animation"


// 关联：route_map.json
@Builder
export function ImportConfigFromFileBuilder(name: string, param: Object){
  ImportConfigFromFile()
}


@Component
export struct ImportConfigFromFile{

  private componentName: string = 'ImportConfigFromFile'

  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 模态弹窗显示变量
  @Consume isShowConfigAddBindSheet: boolean
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  /* 是否开启 配置页 `bindSheet` 组件的前景模糊 */
  @Consume('isEnableConfigPageBindSheetForegroundBlur')
  private isEnableConfigPageBindSheetForegroundBlur: boolean

  /* NV 路由相关 */
  @Consume('configAddPageInfos')
  // 页面栈
  private configAddPageInfos: NavPathStack
  @State @Watch('configDataChanged') fileurl: string = ''

  // NV title Builder
  @State
  private mainTitle: string = getResourceString($r('app.string.add_config'), this)
  @State
  private subTitle: string = getResourceString($r('app.string.import_from_file'), this)
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  // 配置详情（要添加到用户首选项里的数据）
  @State @Watch('configDataChanged')
  configData: ConfigData = {
    configId: util.generateRandomUUID(),
    isNewConfig: true,
    configName: '',
    configUrl: '',
    isConfigAutoUpdate: false,
    lastUpdateDateTime: 0,
    updateTime: 0
  }
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
  private filemenus: Array<BindSheetTitleCustomBuilderMenu> = []
  /* Input事件相关变量 */
  // [true: 都有值, false: 不是所有的input都有值]
  @State private allInputHaveValue: boolean = false
  @Consume('currentTouchConfigData') currentTouchConfigData: ConfigData
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
        this.configAddPageInfos.pop(true)
      },
      confirm: ()=> {
        // 保存配置后关闭半模态窗口
        this.isShowConfigAddBindSheet = false
        this.isEnableConfigPageBindSheetForegroundBlur = false
        this.saveConfig(this.configData.isNewConfig)
      }
    }),
    cancel: () => {
      this.isEnableConfigPageBindSheetForegroundBlur = false
    },
    alignment: DialogAlignment.Center,
    width: 328,
    backgroundColor: $r('app.color.list_item_background_color'),
  })

  build() {
    NavDestination() {
      // 替代`NavDestination`的标题栏 START
      BindSheetTitleCustomBuilder({
        pageInfos: this.configAddPageInfos,
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
          right: BIND_SHEET_TITLE_LEFT_SYMBOL_WEIGHT + 15 * 2
        },
        menus: this.filemenus
      })
      // 替代`NavDestination`的标题栏 END

      // START
      Column({space: 10}) {
        // 配置名input
        Text($r('app.string.config_name')).fontColor($r('sys.color.font_secondary')).fontSize(FONT_SIZE_16)
        TextInput(
          { text: $$this.configData.configName,
            placeholder: $r('app.string.enter_configuration_name')
          }).width('100%')
          .height(TEXT_INPUT_HEIGHT)
          .borderRadius(BORDER_RADIUS_20)
          .id('text_input_config_name')
          .caretColor(this.icon_emphasize)
          .maxLength(TEXT_AREA_MAX_LENGTH)
          .enterKeyType(EnterKeyType.Next)
          // .defaultFocus(true)
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))

        // 导入文件
        Row() {
          SymbolGlyph($r('sys.symbol.folder'))
            .fontSize(24)
            .margin({left: 12})
            .fontColor([this.icon_emphasize])
            .transition(customAnimationUtil.isScaleTranIcon(10,this.uiConfig))
          Text($r('app.string.browse_local_files'))
            .fontWeight(FontWeight.Medium)
            .fontSize(16)
            .margin({ left: 12 })
          Blank()
        }.width('100%')
        .height(53)
        .borderRadius(20)
        .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
        .backgroundColor($r('app.color.container_background'))
        .onClick(() => {
          let filePicker = new picker.DocumentViewPicker(getContext(this))
          let options = new picker.DocumentSelectOptions()
          filePicker.select(options).then((documentSelectResult)=>{
            this.fileurl = documentSelectResult[0];
            this.configData.configName =  decodeURIComponent(this.fileurl.substring(this.fileurl.lastIndexOf('/') + 1))
            hilog.debug(0xFF00, this.componentName, 'FileUrl: %{public}s', this.fileurl)
          })
        })
        // 提示
        Text($r('app.string.import_config_file_tips'))
          .fontWeight(FontWeight.Normal)
          .fontSize(15)
        // Text(this.componentName).fontSize(50)
        // Text(`NavigationListPadding(this.widthBp, this.heightBp) value is [${NavigationListPadding(this.widthBp, this.heightBp)}]`)

      }.width('100%').height('auto')
      .alignItems(HorizontalAlign.Start)
      .padding({left: 12, right: 12})
      // END
    }
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
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
    .animation({ duration:  this.uiConfig.animationSpeed , curve: Curve.Ease })

  }

  aboutToAppear(): void {
    hilog.info(0xCC10, this.componentName, `#aboutToAppear executed`)
    // 若为编辑状态直接显示保存按钮
    if (!this.configData.isNewConfig) {
      this.filemenus.push(this.saveMenus)
      // 赋予初始值
      this.fileurl = this.configData.configUrl
    }
  }

  aboutToDisappear(): void {
    hilog.info(0xCC10, this.componentName, `#aboutToDisappear executed`)
  }

  async saveConfig(isNewConfig: boolean) {
    this.currentTouchConfigData = this.configData
    hilog.info(0xFF00, "EditConfig #saveConfig configSaveTestTag", `File 新文件保存：${isNewConfig}`)
    if (isNewConfig) {
      // 新增配置
      await ClashViewModel.addOrUpdateProfileByFile(this.configData.configName, this.fileurl, null)
    } else {
      // 更新配置
      hilog.info(0xFF00, "EditConfig #saveConfig configSaveTestTag", `文件更新 名称：${this.configData.configName} id：${this.configData.configId}`)
      try {
        await ClashViewModel.addOrUpdateProfileByFile(this.configData.configName, this.fileurl, this.configData.configId)
      } catch (e) {
        hilog.info(0xFF00, "EditConfig", `#saveConfig configSaveTestTag 文件更新错误：${e.message || e}`)
      }
    }
  }

  /**
   * 检查配置名 Input && 配置 文件 是否都有值
   *    true: 显示保存按钮。 false反之
   */
  configDataChanged() {
    this.checkTheInputHaveValue()
    if (this.configData.isNewConfig) {
      if (this.allInputHaveValue) {
        if (this.filemenus.filter(i => i === this.saveMenus).length <= 0) {
          // 新增`保存配置`菜单按钮
          this.filemenus.push(this.saveMenus)
        }
      } else {
        // 移除`保存配置`菜单按钮
        for (let i = 0; i < this.filemenus.length; i++) {
          if (this.filemenus[i] === this.saveMenus) {
            this.filemenus.splice(i, 1)
            break
          }
        }
      }
    }
  }

  /**
   * 检查配置名 Input && 配置 文件 是否都有值
   */
  checkTheInputHaveValue() {
    this.allInputHaveValue = (this.configData.configName.length > 0) && (this.fileurl !== '')
  }

}

