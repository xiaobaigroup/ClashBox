import { BreakpointState } from "../../../common/breakpointsystem"
import { BasicMenu, ListOverwriteBasicData, MenuListItemProp, moreData } from "../../../common/Constants"
import { hilog } from "@kit.PerformanceAnalysisKit"
import OverwriteTop from "./OverwriteTopBuilder"
import { menuRowList, skipRowList, theCustomDialog, toggleRowList } from "../../Common"
import { ClashConfig, LogLevel } from 'proxy_core'
import { AppConfig, copy, UIConfig } from '../../../entryability/AppState'
import { SymbolGlyphModifier } from "@kit.ArkUI"
import { getResourceString } from "../../../utils/ResourceStringUtil"

@Component
struct Basic {
  @State theMenuIndex: number = 0
  @State theDialogIndex: number = 0
  @State theInputUnit: ResourceStr = ''
  @State SaveInputValue: string = ''
  @State currentInputValue: string = ''
  @State theplaceholder: string = ''
  @State theDialogTitle: string = ''
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Consume('NavPathStack') pageInfos: NavPathStack
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @State overwriteBasicList: moreData[] = []
  @State basicMenuList: MenuListItemProp[] = BasicMenu
  @Consume('breakPointStatemorePagelistBottom') listBottom: BreakpointState<number>
  // 列表高度
  @Consume('breakPointStateListHeight') listHeight: BreakpointState<number>
  // 平板竖屏判断
  @StorageProp('istabletVertical')  private istabletVertical: boolean = false
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean

  aboutToAppear(): void {
    this.overwriteBasicList = ListOverwriteBasicData(this.clashConfig, this.appConfig)
  }

  changeChange(name: string, value: string | boolean | number | Record<string, string>){
    if (this.clashConfig){
      if (name == "LogLevel"){
        this.clashConfig["log-level"] = value as LogLevel
      }
      if (name == "ProxyPort"){
        this.clashConfig["mixed-port"] = value as number
      }
      if (name == "UnifiedLatency"){
        this.clashConfig["unified-delay"] = value as boolean
      }
      if(name == "Ipv6"){
        this.clashConfig.ipv6 = value as boolean
      }
      if(name == "TCP-Concurrency"){
        this.clashConfig['tcp-concurrent'] = value as boolean
      }
      if(name == "Hosts"){
        // 非基础类型需要copy，才能持久化
        this.clashConfig["hosts"] = copy(value as Record<string, string>)
      }
    }
  }

  // 编辑FakeIP范围 & GeoIP代码弹窗控制器
  dialogController: CustomDialogController = new CustomDialogController({
    builder: theCustomDialog({
      Unit: this.theInputUnit,
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
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
    this.theInputUnit = ''
    this.theplaceholder = ''
    this.currentInputValue = ''
  }
  onAccept() {
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
    if(this.SaveInputValue === '') {
      // 如果没有输入则为默认值
      this.SaveInputValue = this.theplaceholder
    }
    switch (this.theDialogIndex) {
      case 2:
        // TCP保持活动间隔
        let TCPData = this.overwriteBasicList[2]
        TCPData.subtitle = `${this.SaveInputValue}${getResourceString($r('app.string.s'), this)}`
        this.overwriteBasicList.splice(2, 1, TCPData)
        // 逻辑处理

        break
      case 3:
        // 测试延迟链接逻辑处理

        break
      case 4:
        // 代理端口
        let proxyData = this.overwriteBasicList[4]
        proxyData.subtitle = this.SaveInputValue
        this.overwriteBasicList.splice(4, 1, proxyData)
        // 逻辑处理

        break
    }
    this.theInputUnit = ''
    this.theplaceholder = ''
    this.currentInputValue = ''
  }

  handleCheck(index: number) {
    // 跳转
    let itemData = this.overwriteBasicList[index]
    if(index === 5) {
      this.pageInfos.pushPathByName(itemData.name, false)
    } else {
      this.theDialogIndex = index
      this.theDialogTitle = typeof itemData.title == "string" ? itemData.title : getResourceString(itemData.title, this)
      if(index === 2) {
        this.theInputUnit = $r('app.string.s')
        this.theplaceholder = '30'
      } else if (index === 4){
        this.theplaceholder = '7890'
      } else {
        this.theplaceholder = ''
      }
      this.isEnableIndexForegroundBlur = true
      this.dialogController.open()
    }

  }

  @Builder
  basicMenuTipsBuilder(tips: ResourceStr) {
    Text(tips)
      .fontWeight(FontWeight.Normal)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .margin({top: 2 })
      .fontSize(14)
  }
  @Builder
  basicSkipTipsBuilder(tips: ResourceStr) {
    Text(tips)
      .fontWeight(FontWeight.Normal)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .margin({top: 2, right: 2 })
      .fontSize(14)
  }
  @Builder
  basicToggleBuilder(isON: boolean) {
    Toggle({ type: ToggleType.Switch, isOn: isON })
      .margin({right: 12})
      .hitTestBehavior(HitTestMode.None)
      .selectedColor(this.icon_emphasize)
  }
  @Builder
  MenuEntrance(index: number) {
    // 确保children存在
    if(this.basicMenuList && this.basicMenuList[0].children && index === 0) {
      this.switchMenu(this.basicMenuList[0].children, index)
    } else if (this.basicMenuList && this.basicMenuList[1].children && index === 1) {
      this.switchMenu(this.basicMenuList[1].children, index)
    }
  }
  @Builder
  switchMenu(item: MenuListItemProp[], index: number) {
    if(index === 0) {
      // 日志等级菜单
      Menu() {
        MenuItem({ content: $r('app.string.LogLevel') }).contentFont({ weight: FontWeight.Bold })
        ForEach(item, (menuItem: MenuListItemProp, index: number) => {
          MenuItem({
            content: menuItem.title,
            symbolEndIcon: this.theMenuIndex === index ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
          })
            .selected(this.theMenuIndex === index)
            .onChange(() => {
              this.theMenuIndex = index
              if (this.basicMenuList[0].children) {
                let Item = this.overwriteBasicList[0]
                Item.subtitle = menuItem.title
                this.overwriteBasicList.splice(0, 1, Item)
              }
            })
        }, (menuItem: MenuListItemProp) => JSON.stringify(menuItem))
      }
    } else {
      // UA菜单
      Menu() {
        MenuItem({ content: 'UA' }).contentFont({ weight: FontWeight.Bold })
        ForEach(item, (menuItem: MenuListItemProp, index: number) => {
          MenuItem({
            content: menuItem.title,
            symbolEndIcon: this.theMenuIndex === index ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
          })
            .selected(this.theMenuIndex === index)
            .onChange(() => {
              this.theMenuIndex = index
              if (this.basicMenuList[0].children) {
                let Item = this.overwriteBasicList[1]
                Item.subtitle = menuItem.title
                this.overwriteBasicList.splice(1, 1, Item)
              }
            })
        }, (menuItem: MenuListItemProp) => JSON.stringify(menuItem))
      }
    }
  }

  build() {
    NavDestination() {
      OverwriteTop({
        title: $r('app.string.Basic'),
        subtitle: ''
      })
      // 列表
      List({space: this.listBottom.value}) {
        ForEach(this.overwriteBasicList, (item: moreData, index: number) => {
          if (item.sign === 0 ) {
            ListItem() {
              // 展开型
              menuRowList({
                icons: item.icons,
                title: item.title,
                isPrimaryIcons: true,
                tips: () => { this.basicMenuTipsBuilder(item.subtitle) },
                menu: (): void => { this.MenuEntrance(index) }
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
                tips: () => { this.basicSkipTipsBuilder(item.subtitle) }
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
                toggle:  () => { this.basicToggleBuilder(item.isCheck) }
              })
            }
            .transition(this.uiConfig.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: 0 })
              .combine(TransitionEffect.scale({x: 0, y: 0})):null)
            .onClick(() => {
              hilog.info(0xFF00, "BasictestTag", "开关状态1:  %{public}s", item.isCheck)
              this.getUIContext()?.animateTo({
                duration: this.uiConfig.animationSpeed
              }, () => {
                const toggleItem = this.overwriteBasicList[index]
                toggleItem.isCheck = !toggleItem.isCheck
                this.overwriteBasicList.splice(index, 1, toggleItem)
                hilog.info(0xFF00, "BasictestTag", "开关状态2:  %{public}s", toggleItem.isCheck)
                this.changeChange(toggleItem.name as string, toggleItem.isCheck)

              })
            })
          }
        })
      }
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .height('100%')
    //  .height(this.isLandscapePhone ? 275 : (this.istabletVertical ? 900 : this.listHeight.value))
      .padding({ left: this.morePageMargin.value, right: this.morePageMargin.value })
      .margin({ top: 10 })
      .borderRadius(18)
      .alignListItem(ListItemAlign.Center)

    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      if(this.pageInfos.size() === 1) {
        this.pageInfos.clear()
      } else {
        this.pageInfos.pop(true)
      }
      return true
    })
  }
}
export default Basic