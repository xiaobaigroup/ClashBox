import { BreakpointState } from "../../common/breakpointsystem"
import {
  FONT_SIZE_16,
  BORDER_RADIUS_20,
  LIST_SPACE,
  LIST_ITEM_PADDING,
  TEXT_AREA_MAX_LENGTH,
  LIST_ITEM_HEIGHT_45,
  TEXT_INPUT_HEIGHT,
  FONT_SIZE_14,
  TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE,
  CONFIG_AUTO_UPDATE_MENU_STRING_ARR,
  ConfigAutoUpdateGap,
} from "../../common/Constants"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { PromptAction } from "@kit.ArkUI"
import { BusinessError } from "@kit.BasicServicesKit"
import { ConfigData } from "../../common/PageArgumentEntity"

@Component
export struct ConfigInfo{

  private componentName: string = 'ConfigInfo'
  private promptAction:PromptAction = this.getUIContext()?.getPromptAction()

  /* 系统语言 */
  @StorageProp('language')
  @Watch('languageChange')
  private currentLanguage: string = ''

  /* TODO 路由参数：是否为新配置（非已有配置进入编辑状态） */
  @Prop
  isNewConfig:boolean

  @Link
  configData: ConfigData

  /* 断点相关 */
  // NV容器的padding
  @Consume('breakPointStateNavigationListPadding')
  breakPointStateNavigationListPadding: BreakpointState<number>

  /* List */
  // 配置是否自动更新
  @State
  private isConfigAutoUpdate: boolean = false
  // 配置自动更新的间隔菜单显示文本默认值，用于获取string_array.json资源异常的时候显示
  private configAutoUpdateMenuStringArr: Array<ConfigAutoUpdateGap> = CONFIG_AUTO_UPDATE_MENU_STRING_ARR
  // 配置自动更新的间隔菜单
  private configAutoUpdateMenus: Array<MenuElement> = [
    {value: this.configAutoUpdateMenuStringArr[0].label, action: () => {hilog.info(0xCA11, this.componentName, `#ListItem#自动更新间隔bindMenu#: 5分钟`)}},
    {value: this.configAutoUpdateMenuStringArr[1].label, action: () => {hilog.info(0xCA11, this.componentName, `#ListItem#自动更新间隔bindMenu: 10分钟`)}},
    {value: this.configAutoUpdateMenuStringArr[2].label, action: () => {hilog.info(0xCA11, this.componentName, `#ListItem#自动更新间隔bindMenu: 30分钟`)}},
    {value: this.configAutoUpdateMenuStringArr[3].label, action: () => {hilog.info(0xCA11, this.componentName, `#ListItem#自动更新间隔bindMenu: 1小时`)}},
    {value: this.configAutoUpdateMenuStringArr[4].label, action: () => {hilog.info(0xCA11, this.componentName, `#ListItem#自动更新间隔bindMenu: 1天`)}},
    {value: this.configAutoUpdateMenuStringArr[5].label, action: () => {hilog.info(0xCA11, this.componentName, `#ListItem#自动更新间隔bindMenu: 自定义`)}},
  ]
  // 配置自动更新 已选择的间隔时间 文本
  @State
  private configAutoUpdateTimeGapSelected: ConfigAutoUpdateGap = this.configAutoUpdateMenuStringArr[2]
  // 配置是否自动更新间隔菜单 是否显示
  // @State
  // private isShowConfigAutoUpdateMenu: boolean = false


  build() {
    Column() {
      // 配置名input
      // TODO 国际化
      Text('配置名').margin({bottom: 10}).fontColor($r('sys.color.font_secondary')).fontSize(FONT_SIZE_16)
      TextInput({ placeholder: '输入配置名' }).margin({bottom: 10}).width('100%').height(TEXT_INPUT_HEIGHT).borderRadius(BORDER_RADIUS_20)
        .id('text_input_config_name')
        .maxLength(TEXT_AREA_MAX_LENGTH)
        .enterKeyType(EnterKeyType.Next)
        .defaultFocus(true)
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .onChange( (value: string, previewText: PreviewText) => {
          this.configData.configName = value.trim()
        })
        .onSubmit( (enterKey: EnterKeyType, event: SubmitEvent) => {
          // 焦点切换给`URL`框
          focusControl.requestFocus('text_area_config_url')
        })


      // 配置 URL
      // TODO 国际化
      Text('URL').margin({bottom: 10}).fontColor($r('sys.color.font_secondary')).fontSize(FONT_SIZE_16)
      // TODO 国际化
      TextArea({ placeholder: '输入链接...' }).margin({bottom: 10}).width('100%').height(TEXT_INPUT_HEIGHT * 2).borderRadius(BORDER_RADIUS_20)
        .id('text_area_config_url')
        .maxLength(TEXT_AREA_MAX_LENGTH)
        .wordBreak(WordBreak.BREAK_ALL)
        .enterKeyType(EnterKeyType.Done)
        .type(TextAreaType.URL)
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .onChange( (value: string, previewText: PreviewText) => {
          this.configData.configURL = value.trim()
        })

      // 配置自动更新
      List({space:LIST_SPACE}){
        ListItemGroup({style:ListItemGroupStyle.CARD}){
          // 自动更新开关
          ListItem({ style:ListItemStyle.CARD }){
            Row(){
              // TODO 国际化
              Text('自动更新').fontColor($r('sys.color.font_primary')).fontSize(FONT_SIZE_16)
              Blank()
              Toggle({ type: ToggleType.Switch, isOn: this.isConfigAutoUpdate!! })
                .onChange((isOn: boolean) => {
                  hilog.info(0xCA11, this.componentName, `#ListItem#Toggle#自动更新状态: ${isOn}`)
                })
            }.width('100%').alignItems(VerticalAlign.Center)
          }
          .height(LIST_ITEM_HEIGHT_45)
          .padding(LIST_ITEM_PADDING)
          .borderRadius(BORDER_RADIUS_20)
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
          .onClick( ()=> {
            this.isConfigAutoUpdate = !this.isConfigAutoUpdate
          })
          // 自动更新间隔
          ListItem({ style:ListItemStyle.CARD }){
            Row(){
              // TODO 国际化
              Text('自动更新间隔').fontColor($r('sys.color.font_primary')).fontSize(FONT_SIZE_16)
              Blank()
              // TODO 国际化
              Row(){
                Text(this.configAutoUpdateTimeGapSelected.label).fontColor($r('sys.color.font_secondary')).fontSize(FONT_SIZE_14)
                Column(){
                  SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill')).fontColor([$r('sys.color.font_secondary')]).fontSize(8)
                }
                .width(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).height(8)
                .alignItems(HorizontalAlign.Center)
              }
              .width('auto')
            }.width('100%').alignItems(VerticalAlign.Center)
          }
          .height(LIST_ITEM_HEIGHT_45)
          .padding(LIST_ITEM_PADDING)
          .borderRadius(BORDER_RADIUS_20)
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
          .bindMenu(this.configAutoUpdateMenus, { placement: Placement.RightBottom })
          // hilog.info(0xCA11, this.componentName, `#ListItem#ContextMenu#自动更新间隔: ${isOn}`)
        }
        .margin({right: 0, left:0 })
        .divider({
          strokeWidth: .4,
          color: $r('sys.color.comp_divider'),
          startMargin: LIST_ITEM_PADDING.left,
          endMargin: LIST_ITEM_PADDING.right
        })
      }
      .margin({bottom: 10})
      .width('100%')
      .height('auto')
      .borderRadius(BORDER_RADIUS_20)
      .backgroundColor($r('app.color.container_background'))
      Text(this.breakPointStateNavigationListPadding.value?.toString())
      Text(`isNewConfig: ${this.isNewConfig}`).fontSize(35)
    }
    .width('100%')
    .height('100%')
    .padding({
      left: this.breakPointStateNavigationListPadding.value,
      right: this.breakPointStateNavigationListPadding.value
    })
    .alignItems(HorizontalAlign.Start)
    // .backgroundColor('#ffdd7f7f')
    .backgroundColor($r('app.color.background'))
  }

  aboutToAppear(): void {
    hilog.info(0xCA11, this.componentName, `#aboutToAppear`)
    this.getConfigAutoUpdateMenuStringArr()
  }

  aboutToDisappear(): void {
    hilog.info(0xCA11, this.componentName, `#aboutToDisappear`)
  }

  /**
   * 系统语言发生改变事件
   * @param changedPropertyName
   */
  languageChange(changedPropertyName: string) {
    hilog.info(0xCA11, this.componentName, `#languageChange#监听到系统语言发生改变: ${this.currentLanguage}`)
    this.getConfigAutoUpdateMenuStringArr()
  }

  /**
   * 从系统资源里 获取菜单集合值
   */
  getConfigAutoUpdateMenuStringArr() {
    try {
      let resourceManager = this.getUIContext().getHostContext()?.resourceManager
      let configAutoUpdateMenuStringArr = resourceManager?.getStringArrayValueSync($r('app.strarray.config_auto_update_menu').id) as Array<string>
      hilog.info(0xCA11, this.componentName, `#aboutToAppear#getStringArrayValueSync($r('app.strarray.config_auto_update_menu')#configAutoUpdateMenuStringArr: index[${configAutoUpdateMenuStringArr.length}], value [${configAutoUpdateMenuStringArr}])}`)
      if (configAutoUpdateMenuStringArr.length <= 0) {
        // TODO 国际化
        this.promptAction.showToast({message: `菜单数据获取失败！`})
        hilog.error(0xCA11, this.componentName, `#aboutToAppear#getStringArrayValueSync($r('app.strarray.config_auto_update_menu')#ERROR: 配置自动更新时间间隔菜单数据获取数据为空！`)
      } else {
        // 给菜单赋值
        configAutoUpdateMenuStringArr.forEach( (item: string, index) => {
          this.configAutoUpdateMenuStringArr[index].label = item
        })
        this.configAutoUpdateMenus.forEach( (item: MenuElement, index) => {
          item.value = this.configAutoUpdateMenuStringArr[index].label
        })
        // TODO 这里有个问题 后面处理：如果在已经更改了默认间隔30分钟之后，切换了系统语言，这里显示的会被重置回默认值
        this.configAutoUpdateTimeGapSelected.label = configAutoUpdateMenuStringArr[2]
      }
    } catch (e) {
      let error = e as BusinessError;
      hilog.error(0xCA11, this.componentName, `#aboutToAppear#getStringArrayValueSync($r('app.strarray.config_auto_update_menu')#ERROR: code is [${error.code}],message is [${error.message}]`)
    }
  }
}