import { BreakpointState } from "../../../common/breakpointsystem"
import { MoreTop } from "../MoreTopBuilder"
import { KVCustomDialog, theCustomDialog } from "../../Common"
import { curves, promptAction } from "@kit.ArkUI"
import { EventHub, EventKey } from "../../../common/EventHub"
import { UIConfig } from "../../../entryability/AppState"
import {
  BORDER_RADIUS_20,
  ConfigItemData, CONTENT_END_OFFSET_150, TAB_CONTENT_TITLE_HEIGHT, ValueType } from "../../../common/Constants"
import { getResourceString } from "../../../utils/ResourceStringUtil"
import { customAnimationUtil } from "../../../utils/Animation"
import { common } from "@kit.AbilityKit"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { Sniff } from "proxy_core"

export interface ArrayConfigParam{
  label?: string | ResourceStr
  key: string
  value: string[] | Record<string, string>
}

const context = getContext(this) as common.UIAbilityContext

// 提取公共组件，复用
@Component
export struct ArrayConfigEditor {
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @State isEditPage: boolean = false
  @State SaveInputValue: string = ''
  @State currentInputValue: string = ''
  @State theplaceholder: string = '请输入内容'
  @State kvDialogTitle: ResourceStr = ''
  @State addDialogTitle: ResourceStr = ''
  @State editDialogTitle: ResourceStr = ''
  // 编辑弹窗默认输入框文本值
  @State theEditPlaceholder: number = 0
  // 编辑弹窗保存的输入文本
  @State SaveEditInputValue: string = ''
  // 编辑弹窗当前输入文本
  @State currentEditInputValue: string = ''
  @State keyValueData: KeyValueData = new KeyValueData("")
  // 编辑路由地址弹窗标题
  @State ArrayConfigList: KeyValueData[] = []
  @Consume('NavPathStack') pageInfos: NavPathStack
  // 列表高度
  @Consume('breakPointStateListHeight') listHeight: BreakpointState<number>
  @StorageLink ('isLandscapePhone')  private isLandscapePhone: boolean = false
  // 平板竖屏判断
  // 平板竖屏判断变量
  @Consume istabletLandscape: boolean
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @Consume('breakPointStatemorePagelistBottom') listBottom: BreakpointState<number>
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  @Prop params: ConfigItemData
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  //page内顶部标题偏移量
  @Consume curYOffset: number
  @State content: string = ""

  aboutToAppear(): void {
    this.addDialogTitle = getResourceString($r('app.string.Add'), this) + getResourceString(this.params.title, this)
    this.editDialogTitle = getResourceString($r('app.string.Edit'), this) + getResourceString(this.params.title, this)
    // string []
    if(this.params.valueType == ValueType.StringArray){
      this.isEditPage = false
      const list = this.params.value as string []
      if(list){
        this.ArrayConfigList = list.map((v: string)=>{
          return new KeyValueData(v)
        }) ?? []
      }
    } else if(this.params.valueType == ValueType.Sniff) {
      // Record<string, Sniff>
      this.isEditPage = true
      hilog.info(0xFF00, "NetworkEditTag", "文本值%{public}s", JSON.stringify(this.params.value as Record<string, Sniff>))
      if (this.params.value !== undefined) {
        this.content = JSON.stringify(this.params.value as Record<string, Sniff>, null, 2)
      }

    } else { // Record<string, string>
      this.isEditPage = false
      const list = this.params.value as Record<string, string>
      if(list){
        this.ArrayConfigList =  Object.entries(list).map((arr)=> new KeyValueData(arr[0], arr[1]))
      }
    }
  }
  aboutToDisappear(): void {
    this.updateArrayConfig()
  }
  updateArrayConfig(){
    if(this.params.valueType == ValueType.Sniff){
      try {
        EventHub.sendEvent(EventKey.ArrayConfigChanged, {key: this.params.name, value: JSON.parse(this.content)})
      }catch (e) {
        promptAction.showToast({message:'格式不正确'})
      }
    }else{
      // string[]
      if(this.params.valueType == ValueType.StringArray){
        EventHub.sendEvent(EventKey.ArrayConfigChanged, {key: this.params.name, value: this.ArrayConfigList.map((d)=>{
          return d.key
        })})
      }else{
        // record<string, string>
        const record = {} as Record<string, string>;
        for (let kv of this.ArrayConfigList){
          record[kv.key] = kv.value as string
        }
        EventHub.sendEvent(EventKey.ArrayConfigChanged, {key: this.params.name, value: record})
      }
    }

  }

  /**
   * KV弹窗控制器
   */
  kvDialogController = new CustomDialogController({
    builder: KVCustomDialog({
      value: $keyValueData,
      theDialogTitle: this.kvDialogTitle,
      confirm: (value)=>{
        this.onCancel()
        const indexes = this.ArrayConfigList.findIndex((d) => d.key == value.key)
        if(indexes > -1){
          this.ArrayConfigList[indexes].value = value.value
          this.ArrayConfigList = [... this.ArrayConfigList]
        }else{
          this.ArrayConfigList = [...this.ArrayConfigList, value]
        }
        // 保存后重置数据
        this.keyValueData = new KeyValueData("")
      },
      cancel: ()=> { this.onCancel() },
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      // 1、PRESS_BACK    点击三键back、左滑/右滑、键盘ESC。
      // 2、TOUCH_OUTSIDE    点击遮障层时
      // 3、CLOSE_BUTTON    点击关闭按钮
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        // 点击遮蔽层不响应，防误触
      } else {
        // 完成任务后主动通过dismiss主动关闭对话框
        dismissDialogAction.dismiss()
        // 关闭背景模糊
        this.isEnableIndexForegroundBlur = false
      }
    }
  })

  /**
   * 添加弹窗控制器
   */
  dialogController: CustomDialogController = new CustomDialogController({
    builder: theCustomDialog({
      theplaceholder: this.theplaceholder,
      currentInputValue: $currentInputValue,
      SaveInputValue: $SaveInputValue,
      theDialogTitle: this.addDialogTitle,
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onAccept() },
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      // 1、PRESS_BACK    点击三键back、左滑/右滑、键盘ESC。
      // 2、TOUCH_OUTSIDE    点击遮障层时
      // 3、CLOSE_BUTTON    点击关闭按钮
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        // 点击遮蔽层不响应，防误触
      } else {
        // 完成任务后主动通过dismiss主动关闭对话框
        dismissDialogAction.dismiss()
        // 关闭背景模糊
        this.isEnableIndexForegroundBlur = false
      }
    },
  })

  onCancel() {
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
  }
  onAccept() {
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
    // 更新UI数组中对应元素
    let item : KeyValueData = new KeyValueData(this.SaveInputValue)
    if(this.params.valueType == ValueType.Record){
      let arr = this.SaveInputValue.split(",")
      item = new KeyValueData(arr[0], arr[1])
    }
    this.ArrayConfigList = [...this.ArrayConfigList, item]
    this.currentInputValue = ''
  }

  /**
   * 编辑弹窗控制器
   */
  editDialogController: CustomDialogController = new CustomDialogController({
    builder: theCustomDialog({
      theplaceholder: $theEditPlaceholder,
      currentInputValue: $currentEditInputValue,
      SaveInputValue: $SaveEditInputValue,
      theDialogTitle: this.editDialogTitle,
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.oneditAccept() },
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      // 1、PRESS_BACK    点击三键back、左滑/右滑、键盘ESC。
      // 2、TOUCH_OUTSIDE    点击遮障层时
      // 3、CLOSE_BUTTON    点击关闭按钮
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        // 点击遮蔽层不响应，防误触
      } else {
        // 完成任务后主动通过dismiss主动关闭对话框
        dismissDialogAction.dismiss()
        // 关闭背景模糊
        this.isEnableIndexForegroundBlur = false
      }
    },
  })

  oneditAccept() {
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
    // 更新UI数组中对应元素
    let item : KeyValueData = new KeyValueData(this.SaveEditInputValue)
    if(this.params.valueType == ValueType.Record){
      let arr = this.SaveEditInputValue.split(",")
      item = new KeyValueData(arr[0], arr[1])
    }
    this.ArrayConfigList.splice(this.theEditPlaceholder, 1, item)
    this.currentInputValue = ''
  }

  // 列表行删除
  handleDelete(index: number) {
    this.ArrayConfigList.splice(index, 1)
  }

  @Builder
  TopOtherButton() {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph(this.isEditPage ? $r('sys.symbol.save') : $r('sys.symbol.plus'))
        .fontSize(24)
        .fontColor([this.icon_primary])
    }
    .width(40)
    .height(40)
    .transition(customAnimationUtil.isSlide(0, this.uiConfig))
    .backgroundColor($r('app.color.settings_container_background'))
    .onClick(() => {
      if (!this.isEditPage) {
        // 启用背景模糊
        this.isEnableIndexForegroundBlur = true
        if(this.params.valueType == ValueType.Record) {
          // 替换为添加标题
          this.kvDialogTitle = getResourceString($r('app.string.Add'), this) + getResourceString(this.params.title, this)
          this.kvDialogController.open()
        }else{
          this.dialogController.open()
        }
      } else {
        // 编辑页时保存按钮
        this.pageInfos.pop()

      }
    })
  }

  build() {
    NavDestination() {
      Stack() {
        // 导航栏
        MoreTop({
          title: this.params.title as Resource,
          otherButton: () => {
            this.TopOtherButton()
          }
        })

        Column() {
          Blank().height(TAB_CONTENT_TITLE_HEIGHT + 6)
          Scroll() {
            if (this.isEditPage) {
              // 文本编辑页
              Column() {
                TextArea({text:this.content})
                  .onChange((e)=>{
                    this.content = e
                  })
                  .width('100%')
                  .height('100%')
              }.width('100%')
              .height('100%')
              .padding({ left: this.morePageMargin.value, right: this.morePageMargin.value })
            } else {
              // 键值页
              List({ space: this.listBottom.value }) {
                ForEach(this.ArrayConfigList, (item: KeyValueData, index: number) => {
                  // 数据列表行
                  ListItem() {
                    Row() {
                      Row() {
                        Column() {
                          Text(item.key)
                            .fontWeight(FontWeight.Medium)
                            .fontSize(16)
                            .margin({ left: 12 })
                          Text(item.value)
                            .fontWeight(FontWeight.Medium)
                            .fontSize(16)
                            .margin({ left: 12 })
                        }

                        Blank()
                        SymbolGlyph($r('sys.symbol.trash_fill'))
                          .fontColor([this.icon_primary])
                          .fontSize(28)
                          .margin({ right: 12 })
                          .onClick(() => {
                            this.handleDelete(index)
                          })
                      }
                      .width('100%')
                      .height(53)
                      .borderRadius(BORDER_RADIUS_20)
                      .backgroundColor($r('app.color.container_background'))

                      Row()
                        .height(10)
                    }

                  }
                  .transition(customAnimationUtil.isScaleTran(index, this.uiConfig))
                  .onClick(() => {
                    // 启用背景模糊
                    this.isEnableIndexForegroundBlur = true
                    // 进入列表行数据编辑
                    if (this.params.valueType != ValueType.Record) {
                      this.currentEditInputValue = item.key
                      this.editDialogController.open()
                    } else {
                      this.keyValueData = item
                      // 替换为编辑标题
                      this.kvDialogTitle =
                        getResourceString($r('app.string.Edit'), this) + getResourceString(this.params.title, this)
                      this.kvDialogController.open()
                    }
                    this.theEditPlaceholder = index
                  })
                })

              }
              .height('100%')
              .width('100%')
              .contentEndOffset(CONTENT_END_OFFSET_150 - 40)
              .borderRadius(BORDER_RADIUS_20)
              .alignListItem(ListItemAlign.Center)
              .padding({ left: this.morePageMargin.value, right: this.morePageMargin.value })
              .chainAnimation(true)
              .nestedScroll({
                scrollForward: NestedScrollMode.PARENT_FIRST,
                scrollBackward: NestedScrollMode.SELF_FIRST
              })
            }
          }
          .edgeEffect(this.uiConfig.isAnimation ? EdgeEffect.Spring : null) //,{alwaysEnabled:true})
          .onDidScroll((xOffset: number, yOffset: number): void => {
            // 累计计算当前父组件滚动在Y轴方向的偏移量
            if (this.uiConfig.isAnimation) {
              this.curYOffset += yOffset
            }
            console.info("yOffset" + this.curYOffset);
          })
        }
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.pageInfos.pop(true);
      return true;
    })
  }
}

export class KeyValueData {
  key: string
  value: string | null
  constructor(name: string, value: string | null = null) {
    this.key = name
    this.value = value
  }
}

