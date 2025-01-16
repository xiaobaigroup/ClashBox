
import { BreakpointState } from "../../../common/breakpointsystem"
import { ListOverwriteNetworkData, moreData } from "../../../common/Constants"
import { hilog } from "@kit.PerformanceAnalysisKit"
import OverwriteTop from "./OverwriteTopBuilder"
import { MoreTop } from "../MoreTopBuilder"
import { theCustomDialog } from "../../Common"

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
  @Consume('breakPointStatemorePagelistBottom') listBottom: BreakpointState<number>

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

  build() {
    NavDestination() {
      // 导航栏
      OverwriteTop({
        title: $r('app.string.Network'),
        subtitle: ''
      })

      List() {
        ForEach(this.overwriteNetworkList, (item: moreData, index: number) => {
          ListItem() {
            Row() {
              Row() {
                SymbolGlyph(item.icons)
                  .fontSize(24)
                  .margin({left: 12})
                  .fontColor([this.icon_primary])
                Column() {
                  Text(item.title)
                    .fontWeight(FontWeight.Medium)
                    .fontSize(16)
                  if (item.sign === 1) {
                    if(index != 9 && index != 18 ) {
                      Text(item.subtitle)
                        .fontWeight(FontWeight.Normal)
                        .margin({ top: 2 })
                        .fontSize(14)
                    }
                  }
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
                Blank()
                if (item.sign === 0 ) {
                  // 展开型
                  Text(item.subtitle)
                    .fontWeight(FontWeight.Normal)
                    .margin({top: 2 })
                    .fontSize(14)
                  SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
                    .fontSize(14)
                    .margin({left: 7, right: 20})
                    .fontColor([this.icon_primary])
                } else if (item.sign === 1) {
                  // 跳转型
                  if(index === 9 || index === 18) {
                    Text(item.subtitle)
                      .fontWeight(FontWeight.Normal)
                      .margin({right: 4 })
                      .fontSize(14)
                  }
                  SymbolGlyph($r('sys.symbol.chevron_right'))
                    .fontSize(28)
                    .margin({right: 12})
                    .fontColor([this.icon_primary])
                } else if (item.sign === 2 ) {
                  // 开关型
                  Toggle({ type: ToggleType.Switch, isOn: item.isCheck })
                    .selectedColor(this.icon_emphasize)
                    .margin({right: 12})
                    .onChange((isOn: boolean) => {
                      if(isOn) {
                        this.handleToggle(index)
                      }
                    })
                }
              }
              .width('94%')
              .height(53)
              .borderRadius(20)
              .backgroundColor($r('app.color.container_background'))
            }
            .onClick(() => {
              if(item.sign === 1) {
                this.handleCheck(index)
              }
            })
          }
          .margin({bottom: this.listBottom.value })
          if (item.sign === 3) {
            // 标题栏
            ListItem() {
              Row() {
                Row() {
                  Text(item.title)
                    .fontWeight(FontWeight.Normal)
                    .fontSize(16)
                }
                .width('94%')
                .height(29)
                Row()
                  .height(10)
              }
            }
          }

        })

      }
      .width('100%')
      .height(this.isLandscapePhone ? 275 : 650)
      .margin({ top: 10, left: this.morePageMargin.value, right: this.morePageMargin.value })
      .borderRadius(18)
      .alignListItem(ListItemAlign.Center)

    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.pageInfos.clear();
      return true;
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

  @Builder
  RouterAddressSearch() {
  }
  @Builder
  RouterAddressOther() {
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
      this.addDialogController.open()
    })
  }

  build() {
    NavDestination() {
      // 导航栏
      Row() {
        MoreTop({
          title: $r('app.string.Routing_Address'),
          searchButton: this.RouterAddressSearch,
          otherButton: () => { this.RouterAddressOther() }
        })
      }.width('100%')

      List() {
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
                    // 进入列表行删除
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
            this.currentEditInputValue = item.name
            this.theEditPlaceholder = index
            this.editDialogController.open()
          })
        })

      }
      .width('100%')
      .height(this.isLandscapePhone ? 275 : 650)
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

// 临时数据
const createRouterAddressData = (): RouterAddressData[] => {
  let result: RouterAddressData[] = new Array()
  result = [
    new RouterAddressData('123', false),
    new RouterAddressData('值', false),

  ]
  return result
}
