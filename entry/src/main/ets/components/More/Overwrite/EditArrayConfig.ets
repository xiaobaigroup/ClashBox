import { BreakpointState } from "../../../common/breakpointsystem"
import { MoreTop } from "../MoreTopBuilder"
import { KVCustomDialog, theCustomDialog } from "../../Common"
import { promptAction } from "@kit.ArkUI"
import { EventHub, EventKey } from "../../../common/EventHub"
import { UIConfig } from "../../../entryability/AppState"
import { ConfigItemData, CONTENT_END_OFFSET, ValueType } from "../../../common/Constants"
import { getResourceString } from "../../../utils/ResourceStringUtil"

export interface ArrayConfigParam{
    label?: string | ResourceStr
    key: string
    value: string[] | Record<string, string>
}

// 提取公共组件，复用
@Component
export struct ArrayConfigEditor {
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  @State SaveInputValue: string = ''
  @State currentInputValue: string = ''
  @State theplaceholder: string = '请输入内容'
  @State addDialogTitle: ResourceStr = $r('app.string.Add_FakeIPfilter')
  @State editDialogTitle: ResourceStr = $r('app.string.Add_FakeIPfilter')
  // 编辑路由地址弹窗默认输入框文本值
  @State theEditPlaceholder: number = 0
  // 编辑路由地址弹窗保存的输入文本
  @State SaveEditInputValue: string = ''
  // 编辑路由地址弹窗当前输入文本
  @State currentEditInputValue: string = ''
  @State keyValueData: KeyValueData = new KeyValueData("")
  // 编辑路由地址弹窗标题
  @State ArrayConfigList: KeyValueData[] = []
  @Consume('NavPathStack') pageInfos: NavPathStack
  // 列表高度
  @Consume('breakPointStateListHeight') listHeight: BreakpointState<number>
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  // 平板竖屏判断
  @StorageProp('istabletVertical')  private istabletVertical: boolean = false
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @Consume('breakPointStatemorePagelistBottom') listBottom: BreakpointState<number>
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  @Prop params: ConfigItemData
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  aboutToAppear(): void {
    this.addDialogTitle = "添加" + getResourceString(this.params.title, this)
    this.editDialogTitle = this.params.title
    // string []
    if(this.params.valueType == ValueType.StringArray){
      const list = this.params.value as string []
      if(list){
        this.ArrayConfigList = list.map((v: string)=>{
          return new KeyValueData(v)
        }) ?? []
      }
    }else{ // Record<string, string>
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
    // string[]
    if(Array.isArray(this.params.value)){
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
  kvDialogController = new CustomDialogController({
    builder: KVCustomDialog({
      value: $keyValueData,
      theDialogTitle: this.addDialogTitle,
      confirm: (value)=>{
        this.onCancel()
        this.ArrayConfigList = [...this.ArrayConfigList, value]
      },
      cancel: ()=> { this.onCancel() },
    })
  })
  /**
   * FakeIP添加过滤弹窗控制器
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
        // 完成IP地址查询后主动通过dismiss主动关闭对话框
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
  }

  /**
   * FakeIP编辑过滤弹窗控制器
   */
  editDialogController: CustomDialogController = new CustomDialogController({
    builder: theCustomDialog({
      theplaceholder: $theEditPlaceholder,
      currentInputValue: $currentEditInputValue,
      SaveInputValue: $SaveEditInputValue,
      theDialogTitle: this.editDialogTitle,
      cancel: ()=> { this.oneditCancel() },
      confirm: ()=> { this.oneditAccept() },
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      // 1、PRESS_BACK    点击三键back、左滑/右滑、键盘ESC。
      // 2、TOUCH_OUTSIDE    点击遮障层时
      // 3、CLOSE_BUTTON    点击关闭按钮
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        // 点击遮蔽层不响应，防误触
      } else {
        // 完成IP地址查询后主动通过dismiss主动关闭对话框
        dismissDialogAction.dismiss()
        // 关闭背景模糊
        this.isEnableIndexForegroundBlur = false
      }
    },
  })
  oneditCancel() {
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
  }
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
  }

  // 列表行删除
  handleDelete(index: number) {
    this.ArrayConfigList.splice(index, 1)
  }
  @Builder
  FakeIPfilterSearch() {
  }
  @Builder
  FakeIPfilterOther() {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph($r('sys.symbol.plus'))
        .fontSize(24)
        .fontColor([this.icon_primary])
    }
    .width(40)
    .height(40)
    .backgroundColor($r('app.color.settings_container_background'))
    .onClick(() => {
      // 启用背景模糊
      this.isEnableIndexForegroundBlur = true
      if(this.params.valueType == ValueType.Record){
        this.kvDialogController.open()
      }else{
        this.dialogController.open()
      }
    })
  }

  build() {
    NavDestination() {
      // 导航栏
      Row() {
        MoreTop({
          title: this.params.title as Resource,
          searchButton: this.FakeIPfilterSearch,
          otherButton: () => { this.FakeIPfilterOther() }
        })
      }.width('100%')
      .padding({left: this.morePageMargin.value, right: this.morePageMargin.value})

      List() {
        ForEach(this.ArrayConfigList, (item: KeyValueData, index: number) => {
          // 数据列表行
          ListItem() {
            Row() {
              Row() {
                Column(){
                  Text(item.key)
                    .fontWeight(FontWeight.Medium)
                    .fontSize(16)
                    .margin({left: 12})
                  Text(item.value)
                    .fontWeight(FontWeight.Medium)
                    .fontSize(16)
                    .margin({left: 12})
                }
                Blank()
                SymbolGlyph($r('sys.symbol.trash_fill'))
                  .fontColor([this.icon_primary])
                  .fontSize(28)
                  .margin({right: 12})
                  .onClick(() => {
                    this.handleDelete(index)
                  })
              }
              .width('100%')
              .height(53)
              .borderRadius(20)
              .backgroundColor($r('app.color.container_background'))
              Row()
                .height(10)
            }

          }
          .transition(this.uiConfig.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: index*10+10 })
            .combine(TransitionEffect.scale({x: 0, y: 0})):null)
          .margin({bottom: this.listBottom.value })
          .onClick(() => {
            // 启用背景模糊
            this.isEnableIndexForegroundBlur = true
            // 进入列表行数据编辑
            if(this.params.valueType != ValueType.Record){
              this.currentEditInputValue = item.key
              this.editDialogController.open()
            }else{
              this.keyValueData = item
              this.kvDialogController.open()
            }
            this.theEditPlaceholder = index
          })
        })

      }
      .width('100%')
      .contentEndOffset(CONTENT_END_OFFSET - 40)
      .margin({ top: 10 })
      .borderRadius(18)
      .alignListItem(ListItemAlign.Center)
      .padding({left: this.morePageMargin.value, right: this.morePageMargin.value})
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

