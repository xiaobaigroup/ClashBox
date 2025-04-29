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
  CONFIG_AUTO_UPDATE_TIME_GAT_STRING_ARR,
  LIST_ITEM_HEIGHT,
} from "../../common/Constants"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { PromptAction } from "@kit.ArkUI"
import { ConfigData } from "../../common/PageArgumentEntity"
import { customVibrator } from "../../utils/VibratorUtil"
import { customSound } from "../../utils/SoundPoolUtil"
import { UIConfig } from "../../entryability/AppState"
import { customAnimationUtil } from "../../utils/Animation"

@Component
export struct ConfigInfo{

  private componentName: string = 'ConfigInfo'
  private promptAction:PromptAction = this.getUIContext()?.getPromptAction()

  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor

  // 配置详情
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
  private configAutoUpdateTextPickerStringArr: Array<string> = CONFIG_AUTO_UPDATE_TIME_GAT_STRING_ARR

  // 配置自动更新 填写的间隔值（由于`configData.configAutoUpdateTimeGapValue`是`number`类型，用这个变量当作一个中间变量利用`@Watch`实现双向绑定）
  @State
  @Watch('configAutoUpdateTimeGapInputChanged')
  private configAutoUpdateTimeGapInputValue: string = String(this.configData.configAutoUpdateTimeGapValue)
  // 配置自动更新 已选择的间隔 index
  /*@State
  private configAutoUpdateTimeGapTextPickerSelectedIndex: number = 1*/
  // 配置是否自动更新间隔菜单 是否显示
  // @State
  // private isShowConfigAutoUpdateMenu: boolean = false
  // ListItem里自动更新间隔`TextPicker`组件所在的`ListItem`的高度
  @State
  private heightOfTextPickerInTheListItem: number = LIST_ITEM_HEIGHT_45
  // ListItem里自动更新间隔`TextPicker`组件的`fontSize`
  @State
  private fontSizeOfTextPickerInTheListItem: number = FONT_SIZE_16
  // ListItem里自动更新间隔`TextPicker`组件的`fontWeight`
  @State
  private fontWeightOfTextPickerInTheListItem: FontWeight = FontWeight.Medium
  // ListItem里自动更新间隔`TextPicker`组件的分割线样式
  @State
  private dividerOfTextPickerInTheListItem: DividerOptions | null = null
  // ListItem里自动更新间隔`TextPicker`组件的每个选择项高度
  @State
  private itemHeightOfTextPickerInTheListItem: number = FONT_SIZE_16 * 1.5
  // ListItem里自动更新间隔`TextPicker`组件的渐隐效果
  @State
  private gradientHeightOfTextPickerInTheListItem: number = FONT_SIZE_16
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  build() {
    Column({ space: 10 }) {
      // 配置名input
      Text($r('app.string.config_name')).fontColor($r('sys.color.font_secondary')).fontSize(FONT_SIZE_16)
      TextInput({ text: $$this.configData.configName, placeholder: $r('app.string.enter_configuration_name') }).width('100%').height(TEXT_INPUT_HEIGHT).borderRadius(BORDER_RADIUS_20)
        .id('text_input_config_name')
        .caretColor(this.icon_emphasize)
        .maxLength(TEXT_AREA_MAX_LENGTH)
        .enterKeyType(EnterKeyType.Next)
        // .defaultFocus(true)
        .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
        .onSubmit( (enterKey: EnterKeyType, event: SubmitEvent) => {
          // 焦点切换给`URL`框
          focusControl.requestFocus('text_area_config_url')
          if (this.uiConfig.isVibrate) {
            customVibrator.vibratorTriggerOfHapticClockTimer()
          }
        })


      // 配置 URL
      Text('URL').fontColor($r('sys.color.font_secondary')).fontSize(FONT_SIZE_16)
      TextArea({ text: $$this.configData.configUrl, placeholder: $r('app.string.resource_path_placeholder') }).width('100%').height(TEXT_INPUT_HEIGHT * 2).borderRadius(BORDER_RADIUS_20)
        .id('text_area_config_url')
        .caretColor(this.icon_emphasize)
        .maxLength(TEXT_AREA_MAX_LENGTH)
        .wordBreak(WordBreak.BREAK_ALL)
        .enterKeyType(this.configData.isConfigAutoUpdate ? EnterKeyType.Next : EnterKeyType.Done)
        .type(TextAreaType.URL)
        .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
        .onSubmit( (enterKey: EnterKeyType) => {
          // 条件判断是否需要将焦点切换给`自动更新时间间隔`框
          this.configData.isConfigAutoUpdate ? focusControl.requestFocus('text_input_auto_update_time') : null
          if (this.uiConfig.isVibrate) {
            customVibrator.vibratorTriggerOfHapticClockTimer()
          }
        })

      // 配置自动更新 START
      List({space:LIST_SPACE}){
        ListItemGroup({style:ListItemGroupStyle.CARD}){
          // 自动更新开关 START
          ListItem({ style:ListItemStyle.CARD }){
            Row(){
              Text($r('app.string.auto_update')).fontColor($r('sys.color.font_primary')).fontSize(FONT_SIZE_16)
              Blank()
              Toggle({ type: ToggleType.Switch, isOn: this.configData.isConfigAutoUpdate })
                .selectedColor(this.icon_emphasize)
                .onChange((isOn: boolean) => {
                  hilog.info(0xCA1A, this.componentName, `#ListItem#Toggle#自动更新状态: ${isOn}`)
                  // 焦点置于`自动更新间隔`文本框
                  focusControl.requestFocus('text_input_auto_update_time')
                  if (this.uiConfig.isVibrate) {
                    customVibrator.vibratorTriggerOfHapticClockTimer()
                  }
                  // 自动更新间隔 显式动画
                  this.getUIContext()?.animateTo({
                    duration: this.uiConfig.animationSpeed ,
                    curve: Curve.Ease
                  }, () => {
                    this.configData.isConfigAutoUpdate = isOn
                  })
                  // （1. 新配置 || 2. 老配置之前没开自动更新，编辑的时候才打开自动更新）处理
               /*   if (isOn){
                    // `TextPicker` 默认选择`小时`
                    this.uiConfig.autoUpdateTimeUtils ?? 1
                  }*/
                })
            }.width('100%').alignItems(VerticalAlign.Center)
          }
          .height(LIST_ITEM_HEIGHT_45)
          .padding(LIST_ITEM_PADDING)
          .borderRadius(BORDER_RADIUS_20)
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .onClick( ()=> {
            // 自动更新间隔 显式动画
            this.getUIContext()?.animateTo({
              duration: this.uiConfig.animationSpeed
            }, () => {
              this.configData.isConfigAutoUpdate = !this.configData.isConfigAutoUpdate
            })
          })
          // 自动更新开关 END

          // 自动更新间隔 START
          if (this.configData.isConfigAutoUpdate) {
            ListItem({ style:ListItemStyle.CARD }){
              Row(){
                Text($r('app.string.auto_update_interval')).fontColor($r('sys.color.font_primary')).fontSize(FONT_SIZE_16)
                Blank()
                Row(){
                  TextInput({ text: $$this.configAutoUpdateTimeGapInputValue, placeholder: $r('app.string.text_input_placeholder') })
                    .width(50)
                    .height(30)
                    .padding(0)
                    .fontColor($r('sys.color.font_secondary'))
                    .fontSize(FONT_SIZE_16)
                    .lineHeight(FONT_SIZE_16)
                    .placeholderFont({size: FONT_SIZE_14})
                    .textAlign(TextAlign.Center)
                    .backgroundColor(Color.Transparent)
                    .borderRadius(0)
                    .border({
                      color: { top: Color.Transparent, bottom: this.icon_emphasize },
                      width: { top: 1, bottom: 1 },
                      style: { top: null, right: null, bottom: BorderStyle.Solid, left: null}
                    })
                    .id('text_input_auto_update_time')
                    .caretColor(this.icon_emphasize)
                    .maxLength(5)
                    .enterKeyType(EnterKeyType.Done)
                    .type(InputType.Number)
                    .onSubmit( (enterKey: EnterKeyType, event: SubmitEvent) => {
                      if (this.uiConfig.isVibrate) {
                        customVibrator.vibratorTriggerOfHapticClockTimer()
                      }
                    })
                    // 干喔~不知道为什么放在ListItem里面不生效
                    // .showUnderline(true)
                  TextPicker({
                    range: $r('app.strarray.config_auto_update_text_picker'),
                    selected: $$this.configData.configAutoUpdateTimeGapTextPickerIndex
                  })
                    .canLoop(false)
                    .width(60)
                    .height(this.heightOfTextPickerInTheListItem)
                    // .backgroundColor('#ffffc0c0')
                    .defaultPickerItemHeight(this.itemHeightOfTextPickerInTheListItem)
                    .gradientHeight(this.gradientHeightOfTextPickerInTheListItem)
                    .selectedTextStyle({
                      color: this.icon_emphasize,
                      font: {
                        size: this.fontSizeOfTextPickerInTheListItem,
                        weight: this.fontWeightOfTextPickerInTheListItem
                      }
                    })
                    .divider(this.dividerOfTextPickerInTheListItem)
                    .onChange( () => {
                      if (this.uiConfig.isVibrate) {
                        customVibrator.vibratorTriggerOfHapticClockTimer()
                      }
                      if(this.uiConfig.isSound) {
                        customSound.playAudioForSoundPool()
                      }
                      console.info('autoUpdateTimeUtils1',this.configData.configAutoUpdateTimeGapTextPickerIndex)
                    })
                    // 手指按下之后静态
                    // .onHover( (isHover: boolean, event: HoverEvent) => {
                    //
                    // })
                    // 手指触摸动态改变`TextPicker`和所在`ListItem`的样式
                    .onTouch((event: TouchEvent) => {
                      let ctx = this.getUIContext()
                      if (event.type === TouchType.Down) {
                        ctx.animateTo({
                          duration: this.uiConfig.animationSpeed ,
                          curve: Curve.Ease
                        }, () => {
                          this.heightOfTextPickerInTheListItem = 100
                          this.fontSizeOfTextPickerInTheListItem = FONT_SIZE_16 * 1.5
                          this.fontWeightOfTextPickerInTheListItem = FontWeight.Bold
                          this.dividerOfTextPickerInTheListItem = {
                            strokeWidth: 1,
                            startMargin: 5,
                            endMargin: 5,
                            color: this.icon_emphasize
                          }
                          this.itemHeightOfTextPickerInTheListItem = FONT_SIZE_16 * 2
                          this.gradientHeightOfTextPickerInTheListItem = FONT_SIZE_16 * 2
                        })
                      } else if (event.type === TouchType.Up){
                        ctx.animateTo({
                          duration: this.uiConfig.animationSpeed ,
                          curve: Curve.Ease
                        }, () => {
                          this.heightOfTextPickerInTheListItem = LIST_ITEM_HEIGHT
                          this.fontSizeOfTextPickerInTheListItem = FONT_SIZE_16
                          this.fontWeightOfTextPickerInTheListItem = FontWeight.Medium
                          this.dividerOfTextPickerInTheListItem = null
                          this.itemHeightOfTextPickerInTheListItem = FONT_SIZE_16 * 1.5
                          this.gradientHeightOfTextPickerInTheListItem = FONT_SIZE_16
                        })
                      }
                    })
                    // .animation({ duration: this.uiConfig.animationSpeed , curve: Curve.Ease })
                }
                .width('auto')
              }.width('100%').alignItems(VerticalAlign.Center)
            }
            .height(this.heightOfTextPickerInTheListItem)
            .padding(LIST_ITEM_PADDING)
            .borderRadius(BORDER_RADIUS_20)
            .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
            .animation({ duration: this.uiConfig.animationSpeed , curve: Curve.Ease })
          }
          // 自动更新间隔 END

        }
        .margin({right: 0, left:0 })
        .divider({
          strokeWidth: 0.4,
          color: $r('sys.color.comp_divider'),
          startMargin: LIST_ITEM_PADDING.left,
          endMargin: LIST_ITEM_PADDING.right
        })
      }
      .width('100%')
      .height('auto')
      .borderRadius(BORDER_RADIUS_20)
      .backgroundColor($r('app.color.container_background'))
      // // 配置自动更新 END
      // Text(`breakPointStateNavigationListPadding.value is [${this.breakPointStateNavigationListPadding.value?.toString()}]`)
      // Text(`isNewConfig: ${this.configData.isNewConfig}`).fontSize(35)
    }
    .width('100%')
    .height('100%')
    .padding({
      left: this.breakPointStateNavigationListPadding.value,
      right: this.breakPointStateNavigationListPadding.value
    })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('app.color.background'))
  }

  aboutToAppear(): void {
    hilog.info(0xCA1A, this.componentName, `#aboutToAppear executed`)
    // this.getConfigAutoUpdateMenuStringArr()
    if(this.uiConfig.isSound) {
      customSound.initSoundPool(3, 'beat_short.wav')
    }
    this.configData.configAutoUpdateTimeGapTextPickerIndex = this.uiConfig.autoUpdateTimeUtils
  }

  aboutToDisappear(): void {
    hilog.info(0xCA1A, this.componentName, `#aboutToDisappear executed`)
    customSound.destroySoundPool()
  }

  /**
   * 系统语言发生改变事件
   * @param changedPropertyName
   */
  /*languageChange(changedPropertyName: string) {
    hilog.info(0xCA1A, this.componentName, `#languageChange#监听到系统语言发生改变: ${this.currentLanguage}`)
    // this.getConfigAutoUpdateMenuStringArr()
    // 更换语言之后更换`TextPicker`显示的文本
    // this.configAutoUpdateTimeGapTextPickerSelectedValue = this.configAutoUpdateMenuStringArr[this.configAutoUpdateTimeGapTextPickerSelectedIndex]
  }*/

  /**
   * TODO `bindMenu`改成了`TextPicker`，支持直接使用Resource的方式来适应系统语言的改变
   * 从系统资源里 获取菜单集合值
   *    因为[自动更新间隔]不止是展示的，还有对应的value需要用，所以不是直接用的`$r()`格式使用的，
   *    就导致如果系统语言环境改变之后，需要手动适配更新[自动更新间隔]对应的string数组
   */
 /* getConfigAutoUpdateMenuStringArr() {
    try {
      let resourceManager = this.getUIContext().getHostContext()?.resourceManager
      let configAutoUpdateTimeGapStringArr = resourceManager?.getStringArrayValueSync($r('app.strarray.config_auto_update_text_picker').id) as Array<string>
      hilog.info(0xCA1A, this.componentName, `#aboutToAppear#getStringArrayValueSync($r('app.strarray.config_auto_update_menu')#configAutoUpdateMenuStringArr: index[${configAutoUpdateTimeGapStringArr.length}], value [${configAutoUpdateTimeGapStringArr}])}`)
      if (configAutoUpdateTimeGapStringArr.length <= 0) {
        // TODO 国际化
        this.promptAction.showToast({message: `菜单数据获取失败！`})
        hilog.error(0xCA1A, this.componentName, `#aboutToAppear#getStringArrayValueSync($r('app.strarray.config_auto_update_menu')#ERROR: 配置自动更新时间间隔菜单数据获取数据为空！`)
      } else {
        // 给菜单赋值
        configAutoUpdateTimeGapStringArr.forEach( (item: string, index) => {
          this.configAutoUpdateMenuStringArr[index] = item
        })
      }
    } catch (e) {
      let error = e as BusinessError;
      hilog.error(0xCA1A, this.componentName, `#aboutToAppear#getStringArrayValueSync($r('app.strarray.config_auto_update_menu')#ERROR: code is [${error.code}],message is [${error.message}]`)
    }
  }*/

  /**
   * @Watch监听事件：配置自动更新 填写的间隔值
   */
  configAutoUpdateTimeGapInputChanged() {
    this.configData.configAutoUpdateTimeGapValue = Number(this.configAutoUpdateTimeGapInputValue)
  }
}