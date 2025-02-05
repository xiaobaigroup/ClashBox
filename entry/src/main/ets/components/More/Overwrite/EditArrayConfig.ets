import { BreakpointState } from "../../../common/breakpointsystem"
import { MoreTop } from "../MoreTopBuilder"
import { theCustomDialog } from "../../Common"
import { promptAction } from "@kit.ArkUI"
import { EventHub, EventKey } from "../../../common/EventHub"

export interface ArrayConfigParam{
    label?: string | ResourceStr
    key: string
    value?: string[] | Record<string, string>
}

// 提取公共组件，复用
@Component
export struct ArrayConfigEditor {
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  @State SaveInputValue: string = ''
  @State currentInputValue: string = ''
  @State theplaceholder: string = '请输入内容'
  @State theDialogTitle: ResourceStr = $r('app.string.Add_FakeIPfilter')
  // 编辑路由地址弹窗默认输入框文本值
  @State theEditPlaceholder: number = 0
  // 编辑路由地址弹窗保存的输入文本
  @State SaveEditInputValue: string = ''
  // 编辑路由地址弹窗当前输入文本
  @State currentEditInputValue: string = ''
  // 编辑路由地址弹窗标题
  @State FakeIPfilterList: KeyValueData[] = []
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
  @Prop params: ArrayConfigParam

  aboutToAppear(): void {
    // string []
    if(Array.isArray(this.params.value)){
      const list = this.params.value as string []
      if(list){
        this.FakeIPfilterList = list.map((v: string)=>{
          return new KeyValueData(v)
        }) ?? []
      }
    }else{ // Record<string, string>
      const list = this.params.value as Record<string, string>
      if(list){
        this.FakeIPfilterList =  Object.entries(list).map((arr)=> new KeyValueData(arr[0], arr[1]))
      }
    }


  }
  aboutToDisappear(): void {
    this.updateArrayConfig()
  }
  updateArrayConfig(){
    // string[]
    if(Array.isArray(this.params.value)){
      EventHub.sendEvent(EventKey.ArrayConfigChanged, {key: this.params.key, value: this.FakeIPfilterList.map((d)=>{
        return d.key
      })})
    }else{
      // record<string, string>
      const record = {} as Record<string, string>;
      for (let kv of this.FakeIPfilterList){
        record[kv.key] = kv.value as string
      }
      EventHub.sendEvent(EventKey.ArrayConfigChanged, {key: this.params.key, value: record})
    }
  }

  /**
   * FakeIP添加过滤弹窗控制器
   */
  dialogController: CustomDialogController = new CustomDialogController({
    builder: theCustomDialog({
      theplaceholder: this.theplaceholder,
      currentInputValue: $currentInputValue,
      SaveInputValue: $SaveInputValue,
      theDialogTitle: this.theDialogTitle,
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
    const newItem: KeyValueData = new KeyValueData(this.SaveInputValue)
    this.FakeIPfilterList = [...this.FakeIPfilterList, newItem]
  }

  /**
   * FakeIP编辑过滤弹窗控制器
   */
  editDialogController: CustomDialogController = new CustomDialogController({
    builder: theCustomDialog({
      theplaceholder: $theEditPlaceholder,
      currentInputValue: $currentEditInputValue,
      SaveInputValue: $SaveEditInputValue,
      theDialogTitle: this.params.label,
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
    const editItem: KeyValueData = new KeyValueData(this.SaveEditInputValue)
    this.FakeIPfilterList.splice(this.theEditPlaceholder, 1, editItem)
  }

  // 列表行删除
  handleDelete(index: number) {
    this.FakeIPfilterList.splice(index, 1)
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
      this.dialogController.open()
    })
  }

  build() {
    NavDestination() {
      // 导航栏
      Row() {
        MoreTop({
          title: this.params.label as Resource,
          searchButton: this.FakeIPfilterSearch,
          otherButton: () => { this.FakeIPfilterOther() }
        })
      }.width('100%')

      List() {
        ForEach(this.FakeIPfilterList, (item: KeyValueData, index: number) => {
          // 数据列表行
          ListItem() {
            Row() {
              Row() {
                Text(item.key)
                  .fontWeight(FontWeight.Medium)
                  .fontSize(16)
                  .margin({left: 12})
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
          .margin({bottom: this.listBottom.value })
          .onClick(() => {
            // 启用背景模糊
            this.isEnableIndexForegroundBlur = true
            // 进入列表行数据编辑
            this.currentEditInputValue = item.key
            this.theEditPlaceholder = index
            this.editDialogController.open()
          })
        })

      }
      .width('100%')
      .height(this.isLandscapePhone ? 275 : (this.istabletVertical ? 945 : this.listHeight.value))
      .margin({ top: 10 })
      .borderRadius(18)
      .alignListItem(ListItemAlign.Center)
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .padding({left: this.morePageMargin.value, right: this.morePageMargin.value})
    .onBackPressed(() => {
      this.pageInfos.pop(true);
      return true;
    })
  }
}

// FakeIP过滤列表数据类
class KeyValueData {
  key: string
  value: string | null
  constructor(name: string, value: string | null = null) {
    this.key = name
    this.value = value
  }
}

