import { BreakpointState } from "../../../common/breakpoint/breakpointsystem"
import {
  BORDER_RADIUS_20,
  ConfigItemData, ListOverwriteNetworkData,
  OverwriteNetworkCompatible,
  TAB_CONTENT_TITLE_HEIGHT } from "../../../common/entity/Constants"
import { hilog } from "@kit.PerformanceAnalysisKit"
import OverwriteTop from "./OverwriteTopBuilder"
import { theCustomDialog } from "../../Common/Common"
import { AppConfig, UIConfig } from "../../../entryability/AppState"
import { ConfigList } from "./Common"
import { ClashConfig } from "proxy_core"
import { customAnimationUtil } from "../../../common/utils/Animation"
import { PageMargin } from "../../../common/breakpoint/BreakPoint"

@Builder
export function NetworkBuilder(name: string, param: Object){
  Network()
}

@Component
struct Network {

  // 更多页面栈
  @StorageLink('MoreNavPathStack') morePageInfos: NavPathStack = new NavPathStack()
  @StorageLink('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1

  @State overwriteNetworkList: ConfigItemData[] = []

  aboutToAppear(): void {
    this.overwriteNetworkList = ListOverwriteNetworkData(this.clashConfig, this.appConfig)
  }

  build() {
    NavDestination() {
      // 导航栏
      OverwriteTop({
        title: $r('app.string.Network'),
        subtitle: ''
      })
      ConfigList({configList: this.overwriteNetworkList})
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      if (this.widthBp < 2) {
        this.pageInfos.pop(true)
      } else {
        this.morePageInfos.pop(true)
      }
      return true
    })
  }
}
export default Network

@Builder
export function NetworkCompatibleBuilder(name: string, param: Object){
  NetworkCompatible()
}

// 网络 -> 兼容模式
@Component
export struct NetworkCompatible {
  // 更多页面栈
  @StorageLink('MoreNavPathStack') morePageInfos: NavPathStack = new NavPathStack()
  // 主路由
  @StorageLink('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()

  @State networkCompatibleList: ConfigItemData[] = []

  aboutToAppear(): void {
    this.networkCompatibleList = OverwriteNetworkCompatible(this.clashConfig, this.appConfig)
  }

  build() {
    NavDestination() {
      Stack() {
        // 导航栏
        OverwriteTop({
          title: $r('app.string.Network'),
          subtitle: $r('app.string.compatibility_mode')
        })
        ConfigList({configList: this.networkCompatibleList})
      }
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.pageInfos.pop(true)
      this.morePageInfos.pop(true)
      return true
    })
  }
}

@Builder
export function NetworkRouterAddressBuilder(name: string, param: Object){
  NetworkRouterAddress()
}

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
  @State routeAddressList: string[] = []
  // 添加路由地址弹窗标题
  @State theDialogTitle: ResourceStr = $r('app.string.Add_Router_Address')
  // 编辑路由地址弹窗标题
  @State theEditDialogTitle: ResourceStr = $r('app.string.edit_router_address')

  // 更多页面栈
  @StorageLink('MoreNavPathStack') morePageInfos: NavPathStack = new NavPathStack()
  @StorageLink('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean

  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 状态栏高度
  @StorageProp('topRectHeight') topRectHeight: number = 0

  // page内顶部标题偏移量
  @Consume curYOffset: number
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
    console.log(`保存的值：${JSON.stringify(this.SaveInputValue)}`);
    this.routeAddressList.push(this.SaveInputValue)
    console.log(`保存后的列表数组值：${JSON.stringify(this.routeAddressList)}`);
    if (this.SaveInputValue) {
      if (!Array.isArray(this.clashConfig["route-address"])) {
        this.clashConfig["route-address"] = [];
      }
      this.clashConfig["route-address"] = this.routeAddressList
      console.log(`保存后的数组值：${JSON.stringify(this.clashConfig["route-address"])}`);
    }
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
    console.log(`编辑后保存的值：${JSON.stringify(this.SaveEditInputValue)}`);
    // 首先判断输入值是否有效
    if (this.SaveEditInputValue) {
      // 然后判断编辑的索引是否有效
      const index = this.theEditPlaceholder;
      if (index >= 0 && index < this.routeAddressList.length) {
        // 更新本地列表
        this.routeAddressList.splice(index, 1, this.SaveEditInputValue);
        console.log(`编辑后保存的列表数组值：${JSON.stringify(this.routeAddressList)}`);
        // 同步到配置对象 确保配置中的属性是数组
        if (!Array.isArray(this.clashConfig["route-address"])) {
          this.clashConfig["route-address"] = [];
        }
        this.clashConfig["route-address"] = [...this.routeAddressList];
        console.log(`编辑后保存的列表值：${JSON.stringify(this.clashConfig["route-address"])}`);
      } else {
        console.error(`错误：编辑索引 ${index} 无效！`);
      }
    } else {
      console.log("输入值为空，不执行保存操作。");
    }
  }

  // 列表行删除
  handleDelete(index: number) {
    hilog.info(0xFF00, "NetworkRoutertestTag", "%{public}d", index)
    hilog.info(0xFF00, "NetworkRoutertestTag", "1%{public}s", JSON.stringify(this.clashConfig["route-address"]))
    this.routeAddressList.splice(index, 1)
    if (this.SaveInputValue) {
      if (!Array.isArray(this.clashConfig["route-address"])) {
        this.clashConfig["route-address"] = [];
      }
      this.clashConfig["route-address"] = this.routeAddressList
      console.log(`删除后保存的列表值：${JSON.stringify(this.clashConfig["route-address"])}`)
    }
  }

  build() {
    NavDestination() {
      Stack() {
        // 导航栏
        OverwriteTop({
          title: $r('app.string.Network'),
          subtitle: $r('app.string.Routing_Address')
        })

        Column() {
          Blank()
            .height(TAB_CONTENT_TITLE_HEIGHT + (this.widthBp < 2 ? this.topRectHeight : 0) + 6)
          Scroll() {
            List({ space: 12 }) {
              if (this.routeAddressList.length > 0) {
                ForEach(this.routeAddressList, (item: string, index: number) => {
                  // 数据列表行
                  ListItem() {
                    Row() {
                      Row() {
                        Text(item)
                          .fontWeight(FontWeight.Medium)
                          .fontSize(16)
                          .margin({ left: 12 })
                        Blank()
                        SymbolGlyph($r('sys.symbol.trash_fill'))
                          .fontColor([this.icon_primary])
                          .fontSize(28)
                          .margin({ right: 12 })
                          .onClick(() => {
                            // 进去列表行删除
                            this.handleDelete(index)
                          })
                      }
                      .width('100%')
                      .height(53)
                      .borderRadius(BORDER_RADIUS_20)
                      .backgroundColor($r('app.color.container_background'))
                    }
                  }
                  .transition(customAnimationUtil.isScaleTran(index, this.uiConfig))
                  .onClick(() => {
                    // 启用背景模糊
                    this.isEnableIndexForegroundBlur = true
                    // 进入列表行数据编辑
                    this.currentEditInputValue = item
                    this.theEditPlaceholder = index
                    this.editDialogController.open()
                  })
                })
              }
              // 添加栏
              ListItem() {
                Row() {
                  SymbolGlyph($r('sys.symbol.plus'))
                    .fontSize(28)
                    .margin({ left: 12, right: 16 })
                    .fontColor([this.icon_primary])
                  Text($r('app.string.Add'))
                    .fontWeight(FontWeight.Medium)
                    .fontSize(16)
                }
                .width('100%')
                .height(53)
                .borderRadius(BORDER_RADIUS_20)
                .backgroundColor($r('app.color.container_background'))
              }
              .transition(customAnimationUtil.isScaleTran(3, this.uiConfig))
              .onClick(() => {
                // 启用背景模糊
                this.isEnableIndexForegroundBlur = true
                this.SaveInputValue = ''
                this.addDialogController.open()
              })
            }
            .width('100%')
            .height('100%')
            .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
            .margin({ top: 10 })
            .borderRadius(BORDER_RADIUS_20)
            .alignListItem(ListItemAlign.Center)
            .chainAnimation(true)
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            })
          }
          .edgeEffect(this.uiConfig.isAnimation ? EdgeEffect.Spring : null) //,{alwaysEnabled:true})
          .onDidScroll((xOffset: number, yOffset: number): void => {
            // 累计计算当前父组件滚动在Y轴方向的偏移量
            if (this.uiConfig.isAnimation) {
              this.curYOffset += yOffset
            }
            // console.debug("yOffset" + this.curYOffset);
          })
        }
      }
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.pageInfos.pop(true)
      this.morePageInfos.pop(true)
      return true
    })
  }

  aboutToAppear(): void {
    const addressFromConfig = this.clashConfig?.["route-address"];
    if (Array.isArray(addressFromConfig)) {
      this.routeAddressList = addressFromConfig;
    } else {
      this.routeAddressList = [];
    }
    console.log(`初始化的值：${JSON.stringify(this.routeAddressList)}`);
  }

}
