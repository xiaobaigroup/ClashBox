import { ClashConfig } from 'proxy_core'
import { BreakpointState } from '../../../common/breakpointsystem'
import { ConfigItemData, CONTENT_END_OFFSET_110, OptionItem,
  ValueType } from '../../../common/Constants'
import { EventHub, EventKey } from '../../../common/EventHub'
import { AppConfig, UIConfig } from '../../../entryability/AppState'
import { getResourceString } from '../../../utils/ResourceStringUtil'
import { menuRowList, skipRowList, theCustomDialog, toggleRowList } from '../../Common'
import { ArrayConfigParam } from './EditArrayConfig'
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { JSON } from '@kit.ArkTS'


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
  @State isShowIcons: boolean = true
  @State theplaceholder: string = ''
  @State currentInputValue: string = ''
  @State currentItemIndex: number = 0
  @State SaveInputValue: string = ''
  @State theDialogTitle: ResourceStr = ''
  @State theUnit: ResourceStr = ''

  dialogController: CustomDialogController = new CustomDialogController({
    builder: theCustomDialog({
      Unit: this.theUnit,
      theDialogTitle: this.theDialogTitle,
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
    this.isEnableIndexForegroundBlur = false
  }

  onAccept() {
    this.isEnableIndexForegroundBlur = false
    const item = this.configList[this.currentItemIndex]
    let value = this.SaveInputValue
    if(item.valueType == ValueType.Number){
      item.onChange(parseInt(this.currentInputValue))
    } else {
      item.onChange(this.currentInputValue)
    }
    item.value = value
    this.configList.splice(this.currentItemIndex, 1, item)
  }

  handleCheck(index: number) {
    this.currentItemIndex = index
    let itemData = this.configList[index]
    if(itemData.isEditType()){
      console.debug("debug itemData", JSON.stringify(itemData))
      this.theUnit = itemData.name === 'keep-alive-interval' ? getResourceString($r('app.string.s'), this) : ''
      this.theplaceholder = `${getResourceString($r('app.string.example'), this)}: ${getResourceString(itemData.tips(), this)}`
      this.currentInputValue = (itemData.value + "") as string
      this.theDialogTitle =  getResourceString($r('app.string.Edit'), this) +  getResourceString(itemData.title, this)
      this.isEnableIndexForegroundBlur = true
      this.dialogController.open()
    } else {
      this.pageInfos.pushPathByName("EditArrayConfig", itemData, true)
    }
  }

  handleToggle(index: number) {
    const toggleItem = this.configList[index]
    toggleItem.isCheck = !toggleItem.isCheck
    this.configList.splice(index, 1, toggleItem)
    toggleItem.onChange(toggleItem.isCheck)
  }

  aboutToAppear(): void {
    EventHub.on(EventKey.ArrayConfigChanged, (d: ArrayConfigParam) => {
      let item = this.configList[this.currentItemIndex]
      item.value = d.value
      item.onChange(d.value)
      this.configList.splice(this.currentItemIndex, 1, item)
    })
    // 设置DNS页无图标
    if(this.configList[0].name === 'overrideDns') {
      this.isShowIcons = false
    }
  }

  @Builder
  menuTipsBuilder(tips: ResourceStr) {
    Text(tips)
      .fontWeight(FontWeight.Normal)
      .fontColor($r('sys.color.font_secondary'))
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .margin({top: 2 })
      .fontSize(14)
  }
  @Builder
  skipTipsBuilder(tips: ResourceStr) {
    Text(tips)
      .fontWeight(FontWeight.Normal)
      .fontColor($r('sys.color.font_secondary'))
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

  @Builder
  switchMenu(item: ConfigItemData, itemIndex: number) {
    // 菜单
    Menu() {
      MenuItem({ content: item.title}).contentFont({ weight: FontWeight.Bold })
      ForEach(item.options ?? [], (option: OptionItem) => {
        MenuItem({
          content: option.title,
          symbolEndIcon: item.value == option.value ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
        })
          .selected(item.value == option.value)
          .onChange(() => {
            let Item = this.configList[itemIndex]
            Item.subtitle = option.title
            Item.value = option.value
            Item.onChange(option.value)
            this.configList.splice(itemIndex, 1, Item)
          })
      }, (menuItem: OptionItem) => JSON.stringify(menuItem))
    }
  }

  build() {
    List({space: this.listBottom.value}) {
      ForEach(this.configList, (item: ConfigItemData, index: number) => {
        if (item.sign === 0 ) {
          ListItem() {
            // 展开型
            menuRowList({
              icons: this.isShowIcons ? item.icons : undefined,
              title: item.title,
              isPrimaryIcons: true,
              tips: () => { this.menuTipsBuilder(item.tips()) },
              menu: (): void => { this.switchMenu(item, index) }
            })
          }
          .transition(this.uiConfig.isAnimation ? TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: 0 })
            .combine(TransitionEffect.scale({x: 0, y: 0})) : null)
        } else if (item.sign === 1) {
          ListItem() {
            // 跳转型
            skipRowList({
              icons: this.isShowIcons ? item.icons : undefined,
              title: item.title,
              subtitle: item.subtitle,
              isPrimaryIcons: true,
              tips: () => { this.skipTipsBuilder(item.tips()) }
            })
          }.onClick(() => {
            this.handleCheck(index)
          })
          .transition(this.uiConfig.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: 0 })
            .combine(TransitionEffect.scale({x: 0, y: 0})) : null)
        } else if (item.sign === 2 ) {
          ListItem() {
            // 开关型
            toggleRowList({
              icons: this.isShowIcons ? item.icons : undefined,
              title: item.title,
              subtitle: item.subtitle,
              isPrimaryIcons: true,
              toggle:  () => { this.toggleBuilder(item.isCheck) }
            })
          }
          .transition(this.uiConfig.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: 0 })
            .combine(TransitionEffect.scale({x: 0, y: 0})) : null)
          .onClick(() => {
            this.getUIContext()?.animateTo({
              duration: this.uiConfig.animationSpeed
            }, () => {
              this.currentItemIndex = index
              this.handleToggle(index)
            })
          })
        } else  {
          // 标题栏
          ListItem() {
            Row() {
              Text(item.title)
                .fontWeight(FontWeight.Normal)
                .fontSize(15)
              Blank()
            }.width('100%')
            .justifyContent(FlexAlign.Start)
          }
          .transition(this.uiConfig.isAnimation ? TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: index*10+10 })
            .combine(TransitionEffect.scale({x: 0, y: 0})) : null)
        }
      })
    }
    .padding({ left: this.morePageMargin.value, right: this.morePageMargin.value })
    .margin({ top: 10 })
    .borderRadius(18)
    .alignListItem(ListItemAlign.Center)
    .contentEndOffset(CONTENT_END_OFFSET_110 - 40)
  }
}