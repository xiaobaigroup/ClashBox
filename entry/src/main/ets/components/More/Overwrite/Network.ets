
import { BreakpointState } from "../../../common/breakpointsystem"
import { ANIMATION_DURATION_300, ListOverwriteNetworkData,
  MenuListItemProp,
  moreData, NetworkMenu } from "../../../common/Constants"
import { hilog } from "@kit.PerformanceAnalysisKit"
import OverwriteTop from "./OverwriteTopBuilder"
import { menuRowList, skipRowList, theCustomDialog, toggleRowList } from "../../Common"
import { SymbolGlyphModifier } from "@kit.ArkUI"
import { UIConfig } from "../../../entryability/AppState"

@Component
struct Network {
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  @Consume('NavPathStack') pageInfos: NavPathStack
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @State overwriteNetworkList: moreData[] = ListOverwriteNetworkData()
  @State networkMenuList: MenuListItemProp[] = NetworkMenu
  @Consume('breakPointStatemorePagelistBottom') listBottom: BreakpointState<number>
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 栈模式临时选择项
  @State stackModeIndex: number = 0
  // 列表行点击事件处理
  handleCheck(index: number) {
      // 跳转
      let itemData = this.overwriteNetworkList[index]
      this.pageInfos.pushPathByName(itemData.name, false)

  }

  // 网络页面开关处理
  handleToggle(index: number) {
    switch (index) {
      case 0:
        // VPN
        hilog.info(0xFF00, "NetworktestTag", "VPN")

        break
      case 2:
        // IPv6
        hilog.info(0xFF00, "NetworktestTag", "IPv6")

        break
    }
  }

  @Builder
  switchMenu(item: MenuListItemProp[], index: number) {
    if (index === 3) {
      // 栈模式菜单
      Menu() {
        MenuItem({ content: $r('app.string.stack_mode') }).contentFont({ weight: FontWeight.Bold })
        ForEach(item, (menuItem: MenuListItemProp, index: number) => {
          MenuItem({
            content: menuItem.title,
            symbolEndIcon: this.stackModeIndex === index ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
          })
            .selected(this.stackModeIndex === index)
            .onChange(() => {
              this.stackModeIndex = index
              if (this.networkMenuList[0].children) {
                let Item = this.overwriteNetworkList[3]
                Item.subtitle = menuItem.title
                this.overwriteNetworkList.splice(3, 1, Item)
              }
            })
        }, (menuItem: MenuListItemProp) => JSON.stringify(menuItem))
      }
    }
  }

  @Builder
  networkMenuTipsBuilder(tips: ResourceStr) {
    Text(tips)
      .fontWeight(FontWeight.Normal)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .margin({top: 2 })
      .fontSize(14)
  }
  @Builder
  networkToggleBuilder(isON: boolean) {
    Toggle({ type: ToggleType.Switch, isOn: isON })
      .margin({right: 12})
      .hitTestBehavior(HitTestMode.None)
      .selectedColor(this.icon_emphasize)
  }
  @Builder
  MenuEntrance(index: number) {
    // 确保children存在
    if(this.networkMenuList && this.networkMenuList[0].children) {
      this.switchMenu(this.networkMenuList[0].children, index)
    }
  }


  build() {
    NavDestination() {
      // 导航栏
      OverwriteTop({
        title: $r('app.string.Network'),
        subtitle: ''
      })

      List({space: this.listBottom.value}) {
        ForEach(this.overwriteNetworkList, (item: moreData, index: number) => {
          if (item.sign === 0 ) {
            // 展开型
            ListItem() {
              menuRowList({
                title: item.title,
                tips: () => { this.networkMenuTipsBuilder(item.subtitle) },
                menu: (): void => { this.MenuEntrance(index) }
              })
            }
            .transition(this.uiConfig.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: index*10+10 })
              .combine(TransitionEffect.scale({x: 0, y: 0})):null)
          } else
            if (item.sign === 1 ) {
              // 跳转型
              ListItem() {
                skipRowList({
                  title: item.title,
                  subtitle: item.subtitle,
                })
              }.onClick(() => {
                this.handleCheck(index)
              })
              .transition(this.uiConfig.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: index*10+10 })
                .combine(TransitionEffect.scale({x: 0, y: 0})):null)
            } else
            if (item.sign === 2 ) {
              // 开关型
              ListItem() {
                toggleRowList({
                  title: item.title,
                  subtitle: item.subtitle,
                  toggle: () => { this.networkToggleBuilder(item.isCheck) }
                })
              }.onClick(() => {
                hilog.info(0xFF00, "NetworkTestTag", "开关状态1:  %{public}s", item.isCheck)
                this.getUIContext()?.animateTo({
                  duration: ANIMATION_DURATION_300
                }, () => {
                  const toggleItem = this.overwriteNetworkList[index]
                  toggleItem.isCheck = !toggleItem.isCheck
                  this.overwriteNetworkList.splice(index, 1, toggleItem)
                  hilog.info(0xFF00, "NetworkTestTag", "开关状态2:  %{public}s", toggleItem.isCheck)
                  if(toggleItem.isCheck) {
                    hilog.info(0xFF00, "NetworkTestTag", "开关已打开")
                    this.handleToggle(index)
                  }
                })
              })
              .transition(this.uiConfig.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: index*10+10 })
                .combine(TransitionEffect.scale({x: 0, y: 0})):null)
            } else
            if (item.sign === 3) {
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
              .transition(this.uiConfig.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: index*10+10 })
                .combine(TransitionEffect.scale({x: 0, y: 0})):null)
            }

        })

      }
      .width('100%')
      .height(this.isLandscapePhone ? 275 : 650)
      .margin({ top: 10 })
      .padding({ left: this.morePageMargin.value, right: this.morePageMargin.value  })
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
export default Network

// 网络 -> 路由地址
@Component
export struct NetworkRouterAddress {
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  // 添加路由地址弹窗保存的输入文本
  @State SaveInputValue: string = ''
  // 编辑路由地址弹窗保存的输入文本
  @State SaveEditInputValue: string = ''
  // 添加路由地址弹窗当前输入文本
  @State currentInputValue: string = ''
  // 编辑路由地址弹窗当前输入文本
  @State currentEditInputValue: string = ''
  // 添加路由地址弹窗默认输入框文本
  @State theplaceholder: string = '请输入地址'
  // 编辑路由地址弹窗默认输入框文本值
  @State theEditPlaceholder: number = 0
  // 添加路由地址弹窗标题
  @State theDialogTitle: ResourceStr = $r('app.string.Add_Router_Address')
  // 编辑路由地址弹窗标题
  @State theEditDialogTitle: ResourceStr = $r('app.string.edit_router_address')
  @State RouterAddressList: RouterAddressData[] = createRouterAddressData()
  @Consume('NavPathStack') pageInfos: NavPathStack
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @Consume('breakPointStatemorePagelistBottom') listBottom: BreakpointState<number>
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  /**
   * 添加路由地址弹窗控制器
   */
  addDialogController: CustomDialogController = new CustomDialogController({
    builder: theCustomDialog({
      theplaceholder: this.theplaceholder,
      currentInputValue: $currentInputValue,
      SaveInputValue: $SaveInputValue,
      theDialogTitle: this.theDialogTitle,
      cancel: ()=> { this.onaddCancel() },
      confirm: ()=> { this.onaddAccept() },
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
  onaddCancel() {
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
  }
  onaddAccept() {
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
    // 在UI数组末尾添加对应元素
    const newItem: RouterAddressData = new RouterAddressData(this.SaveInputValue, false)
    this.RouterAddressList = [...this.RouterAddressList, newItem]
  }

  /**
   * 编辑路由地址弹窗控制器
   */
  editDialogController: CustomDialogController = new CustomDialogController({
    builder: theCustomDialog({
      theplaceholder: $theEditPlaceholder,
      currentInputValue: $currentEditInputValue,
      SaveInputValue: $SaveEditInputValue,
      theDialogTitle: this.theEditDialogTitle,
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
    const editItem: RouterAddressData = new RouterAddressData(this.SaveEditInputValue, false)
    this.RouterAddressList.splice(this.theEditPlaceholder, 1, editItem)
  }



  // 列表行删除
  handleDelete(index: number) {
    hilog.info(0xFF00, "NetworkRoutertestTag", "%{public}d", index)
    hilog.info(0xFF00, "NetworkRoutertestTag", "1%{public}s", JSON.stringify(this.RouterAddressList))
    this.RouterAddressList.splice(index, 1)
    hilog.info(0xFF00, "NetworkRoutertestTag", "2%{public}s", JSON.stringify(this.RouterAddressList))

  }


  build() {
    NavDestination() {
      // 导航栏
      OverwriteTop({
        title: $r('app.string.Network'),
        subtitle: $r('app.string.Routing_Address')
      })

      List({space: this.listBottom.value}) {
        ForEach(this.RouterAddressList, (item: RouterAddressData, index: number) => {
          // 数据列表行
          ListItem() {
            Row() {
              Row() {
                Text(item.name)
                  .fontWeight(FontWeight.Medium)
                  .fontSize(16)
                  .margin({left: 12})
                Blank()
                SymbolGlyph($r('sys.symbol.trash_fill'))
                  .fontColor([this.icon_primary])
                  .fontSize(28)
                  .margin({right: 12})
                  .onClick(() => {
                    // 进去列表行删除
                    this.handleDelete(index)
                  })
              }
              .width('100%')
              .height(53)
              .borderRadius(20)
              .backgroundColor($r('app.color.container_background'))
            }

          }
          .transition(this.uiConfig.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: index*10+10 })
            .combine(TransitionEffect.scale({x: 0, y: 0})):null)
          .onClick(() => {
            // 启用背景模糊
            this.isEnableIndexForegroundBlur = true
            // 进入列表行数据编辑
            this.currentEditInputValue = item.name
            this.theEditPlaceholder = index
            this.editDialogController.open()
          })
        })

        // 添加栏
        ListItem() {
          Row() {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(28)
              .margin({left: 12, right: 16})
              .fontColor([this.icon_primary])
            Text($r('app.string.Add'))
              .fontWeight(FontWeight.Medium)
              .fontSize(16)
          }
          .width('100%')
          .height(53)
          .borderRadius(20)
          .backgroundColor($r('app.color.container_background'))
        }
        .transition(this.uiConfig.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: 0 })
          .combine(TransitionEffect.scale({x: 0, y: 0})):null)
        .onClick(() => {
          // 启用背景模糊
          this.isEnableIndexForegroundBlur = true
          this.addDialogController.open()
        })

      }
      .width('100%')
      .height(this.isLandscapePhone ? 275 : 650)
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

/**
 * 路由地址列表数据类
 */
class RouterAddressData {
  name: string
  isCheck: boolean

  constructor(name: string, isCheck:boolean) {
    this.name = name
    this.isCheck = isCheck
  }
}

// 数据
const createRouterAddressData = (): RouterAddressData[] => {
  let result: RouterAddressData[] = new Array()
  result = [
    new RouterAddressData('123', false),
    new RouterAddressData('值', false),

  ]
  return result
}
