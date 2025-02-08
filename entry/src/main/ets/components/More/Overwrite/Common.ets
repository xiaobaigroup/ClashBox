import { ClashConfig } from 'proxy_core'
import { BreakpointState } from '../../../common/breakpointsystem'
import { ConfigItemData, moreData } from '../../../common/Constants'
import { EventHub, EventKey } from '../../../common/EventHub'
import { AppConfig, UIConfig } from '../../../entryability/AppState'
import { getResourceString } from '../../../utils/ResourceStringUtil'
import { menuRowList, skipRowList, theCustomDialog, toggleRowList } from '../../Common'
import { ArrayConfigParam } from './EditArrayConfig'


@Component
export struct ConfigList {
  @Prop configList: ConfigItemData[]
  @Consume('breakPointStatemorePagelistBottom') listBottom: BreakpointState<number>
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  @State theplaceholder: string = 'CN'
  @State currentInputValue: string = ''
  @State currentItemIndex: number = 0
  // 添加路由地址弹窗保存的输入文本
  @State SaveInputValue: string = ''
  dialogController: CustomDialogController = new CustomDialogController({
    builder: theCustomDialog({
      theDialogTitle: $r('app.string.GeoIP_Code'),
      theplaceholder: this.theplaceholder,
      currentInputValue: $currentInputValue,
      SaveInputValue: $SaveInputValue,
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
    // 重置FakeIP判断及提示词和当前文本状态
    this.theplaceholder = 'CN'
    this.currentInputValue = ''
  }

  onAccept() {
    this.isEnableIndexForegroundBlur = false
    const item = this.configList[ this.currentItemIndex]
    item.onChange(this.SaveInputValue)
    console.debug("currentInputValue", this.SaveInputValue, item.value)
    this.configList.splice(this.currentItemIndex, 1, item)
    this.currentInputValue = ''
  }
  handleCheck(index: number) {
    this.currentItemIndex = index
    let itemData = this.configList[index]
    if(typeof itemData.value == "string"){
      this.theplaceholder = `${getResourceString($r('app.string.example'), this)}: ${itemData.subtitle}`
      this.isEnableIndexForegroundBlur = true
      this.dialogController.open()
    }else{
      this.pageInfos.pushPathByName("EditArrayConfig", {
        key: itemData.name,
        label: itemData.title,
        value: itemData.value
      } as ArrayConfigParam, true)
    }
  }
  handleToggle(item: ConfigItemData, checked: boolean) {
    item.onChange(checked)
  }
  aboutToAppear(): void {
    EventHub.on(EventKey.ArrayConfigChanged, (d: ArrayConfigParam) => {
      let item = this.configList[this.currentItemIndex]
      item.onChange(d.value)
      this.configList.splice(this.currentItemIndex, 1, item)
    })
  }
  @Builder
  menuTipsBuilder(tips: ResourceStr) {
    Text(tips)
      .fontWeight(FontWeight.Normal)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .margin({top: 2 })
      .fontSize(14)
  }
  @Builder
  skipTipsBuilder(tips: ResourceStr) {
    Text(tips)
      .fontWeight(FontWeight.Normal)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .margin({top: 2, right: 2 })
      .fontSize(14)
  }
  @Builder
  toggleBuilder(isON: boolean) {
    Toggle({ type: ToggleType.Switch, isOn: isON })
      .margin({right: 12})
      .hitTestBehavior(HitTestMode.None)
      .selectedColor(this.icon_emphasize)
  }
  build() {
    List({space: this.listBottom.value}) {
      ForEach(this.configList, (item: ConfigItemData, index: number) => {
        if (item.sign === 0 ) {
          ListItem() {
            // 展开型
            menuRowList({
              icons: item.icons,
              title: item.title,
              isPrimaryIcons: true,
              tips: () => { this.menuTipsBuilder(item.subtitle) }
            })
          }
          .transition(this.uiConfig.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: 0 })
            .combine(TransitionEffect.scale({x: 0, y: 0})):null)
        } else if (item.sign === 1) {
          ListItem() {
            // 跳转型
            skipRowList({
              icons: item.icons,
              title: item.title,
              isPrimaryIcons: true,
              tips: () => { this.skipTipsBuilder(item.subtitle) }
            })
          }.onClick(() => {
            this.handleCheck(index)
          })
          .transition(this.uiConfig.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: 0 })
            .combine(TransitionEffect.scale({x: 0, y: 0})):null)
        } else if (item.sign === 2 ) {
          ListItem() {
            // 开关型
            toggleRowList({
              icons: item.icons,
              title: item.title,
              subtitle: item.subtitle,
              isPrimaryIcons: true,
              toggle:  () => { this.toggleBuilder(item.isCheck) }
            })
          }
          .transition(this.uiConfig.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: 0 })
            .combine(TransitionEffect.scale({x: 0, y: 0})):null)
          .onClick(() => {
            this.getUIContext()?.animateTo({
              duration: this.uiConfig.animationSpeed
            }, () => {
              const toggleItem = this.configList[index]
              toggleItem.isCheck = !toggleItem.isCheck
              this.configList.splice(index, 1, toggleItem)
              this.handleToggle(toggleItem, toggleItem.isCheck)
            })
          })
        }
      })
    }
    .padding({ left: this.morePageMargin.value, right: this.morePageMargin.value })
    .margin({ top: 10 })
    .borderRadius(18)
    .alignListItem(ListItemAlign.Center)
    .contentEndOffset(70)
  }
}