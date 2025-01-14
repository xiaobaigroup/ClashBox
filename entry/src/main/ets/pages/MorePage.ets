/*
 * More列表页
 * 2024.12.04
 *
 */
import { BreakpointState, BreakpointSystem } from '../common/breakpointsystem'
import { BIND_SHEET_CONTAINER_HEIGHT, ListMoreData, moreData } from '../common/Constants';
import { hilog } from '@kit.PerformanceAnalysisKit';
import Log from '../components/More/Log';
import Resources from '../components/More/Resources';
import RequestPage from '../components/More/Request';
import Connect from '../components/More/Connect';
import Overwrite from '../components/More/Overwrite/Overwrite';
import Diversion from '../components/More/Diversion';
import Settings from '../components/Settings/Settings';
import moreListItem from '../components/More/MoreListItem';
import Basic from '../components/More/Overwrite/Basic';
import DNS from '../components/More/Overwrite/DNS';
import Network, { NetworkRouterAddress } from '../components/More/Overwrite/Network';
import { FakeIPfilter } from '../components/More/Overwrite/DNSsubpage';
import { getResourceString } from '../utils/ResourceStringUtil';
import { extractLocationInfo, getIpInfo, mapLocation } from '../utils/GetIpInfo';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct MorePage {
  private componentName: string = 'MorePage'
  // 设置页显示变量
  @State isShowSettings: boolean = false
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')

  // 查询IP地址弹窗默认文本
  @State QueryIPplaceholder: string = getResourceString($r('app.string.query_ip_region_placeholder'), this)
  // 添加路由地址弹窗标题
  @State QueryIPDialogTitle: ResourceStr = $r('app.string.query_ip_region')
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  // 更多页列表数组
  @State moreList: moreData[] = ListMoreData()
  // 更多页面栈
  @Provide('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
  // 设置页面栈
  @Provide('NavSettingsPathStack') SettingsPageInfos: NavPathStack = new NavPathStack()
  // 设置 -> 备份与恢复 -> 是否启用云备份配置
  @Provide isShowCloudconfig: boolean = false
  // 设置页语言选中暂存变量
  @Provide currentLanguage: ResourceStr = $r('app.string.Language_Subtitle')
  // 设置页实验功能提示框显示变量
  @Provide isShowExperimentalFunction: boolean = true
  // 设置 -> 通知 -> 流量提醒启用状态变量
  @Provide EnableCellularDataReminder: boolean = false
  // 设置 -> 后台运行 -> 流量提醒启用状态变量
  @Provide Enablebackgrounder: boolean = false
  /* 断点布局相关 相关作用看定义时候的注释 */
  // 整体外边距
  @Consume('breakPointStatemorePageMargin')  private morePageMargin: BreakpointState<number>
  // 列表底边距
  @Consume('breakPointStatemorePagelistBottom') private listBottom: BreakpointState<number>
  // 列表高度
  @Consume('breakPointStateListHeight') private listHeight: BreakpointState<number>

  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean

  /**
   * 查询IP地址弹窗控制器
   */
  QueryIPDialogController: CustomDialogController = new CustomDialogController({
    builder: theQueryIPDialog({
      theplaceholder: this.QueryIPplaceholder,
      theDialogTitle: this.QueryIPDialogTitle,
      cancel: ()=> { this.onQueryIPclose() },
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
  /**
   * 查询IP弹窗关闭处理
   */
  onQueryIPclose() {
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
  }

  aboutToAppear() {

  }

  aboutToDisappear() {

  }

  handleCheck(index: number) {
    if(index === 6) {
      // 模糊背景
      this.isEnableIndexForegroundBlur = true
      // 召唤查询IP弹窗
      this.QueryIPDialogController.open()
    } else {
      // 列表行点击处理
      let itemData = this.moreList[index]
      hilog.isLoggable(0xFF00, "MoretestTag", hilog.LogLevel.INFO);
      hilog.info(0xFF00, "MoretestTag", itemData.name)
      hilog.info(0xFF00, "MoretestTag", "isCheck状态: %{public}s", itemData.isCheck)
      this.pageInfos.clear()
      this.pageInfos.pushPathByName(itemData.name, false)
    }
  }

  // 更多页路由表
  @Builder
  PagesMap(name: string) {
    if (name == 'Log') {
      Log()
    } else
    if (name == 'Resources') {
      Resources()
    } else
    if (name == 'Request') {
      RequestPage()
    } else
    if (name == 'Connect') {
      Connect()
    } else
    if (name == 'Overwrite') {
      Overwrite()
    } else
    if (name == 'Diversion') {
      Diversion()
    } else
    if (name == 'Basic') {
      Basic()
    } else
    if (name == 'DNS') {
      DNS()
    } else
    if (name == 'Network') {
      Network()
    } else
    if (name == 'Route-Address') {
      NetworkRouterAddress()
    } else
    if (name == 'FakeIP-Filtering') {
      FakeIPfilter()
    }
  }

  // 通过@Builder构建设置模态展示界面
  @Builder  SettingsSheet() {

  Column() {
    Settings()
  }
  .width('100%')
  .height('100%')

}

  build() {
    // Column() {
      Navigation(this.pageInfos) {
        // 顶部导航栏
        Row() {
          Text($r('app.string.More'))
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .width('83%')
            .textAlign(TextAlign.Start)
        }
        .margin({left: this.morePageMargin.value})
        .width('100%')

        List() {
          ForEach(this.moreList, (item: moreData, index: number) => {
            ListItem() {
              moreListItem({
                index: index,
                itemObj: item,
                onCheck: (index: number) => {
                  this.handleCheck(index)
                }
              })
            }
            .margin({bottom: this.listBottom.value })
          })
          // 设置行
          ListItem() {
            Row() {
              SymbolGlyph($r('sys.symbol.gearshape'))
                .fontSize(24)
                .margin({left: 12})
                .fontColor([this.icon_primary])
              Text($r('app.string.Settings'))
                .height(48)
                .fontWeight(FontWeight.Medium)
                .padding({ left: 12 })
                .fontSize(16)
              Blank()
              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontSize(28)
                .margin({right: 12})
                .fontColor([this.icon_primary])
            }
            .width('94%')
            .height(53)
            .borderRadius(20)
            .backgroundColor($r('app.color.container_background'))
          }
          .onClick(() => {
            this.isShowSettings = true
            this.isEnableIndexForegroundBlur = true
          })
          // 设置页半模态窗口
          .bindSheet($$this.isShowSettings, this.SettingsSheet(), {
            detents: [BIND_SHEET_CONTAINER_HEIGHT, 300],
            dragBar: false,
            backgroundColor: $r('app.color.background'),
            keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
            preferType: SheetType.CENTER,
            onWillDismiss: () => {
              this.isShowSettings = false
              this.isEnableIndexForegroundBlur = false
              this.SettingsPageInfos.clear()
            }
          })
        }
        .width('100%')
        // .layoutWeight(1) // 自适应占满剩余空间
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .height(this.isLandscapePhone ? 275 : this.listHeight.value)
        .margin({ top: 10, left: this.morePageMargin.value, right: this.morePageMargin.value })
        .borderRadius(18)
        .alignListItem(ListItemAlign.Center)

      }
      .hideToolBar(true)
      .mode(this.isLandscapePhone ? NavigationMode.Stack : NavigationMode.Auto)
      .navBarWidth(330)
      .navDestination(this.PagesMap)
      .width('100%')
      .height('100%')
  }
}

export default MorePage

/**
 * 查询IP地址弹窗组件（竖排按钮）
 */
@CustomDialog
export struct theQueryIPDialog {
  @State SubmitInputValue: string = ''
  @State currentInputValue: string = ''
  @State IPaddressinfo: string = ''
  @Link theplaceholder: string
  @Link theDialogTitle: ResourceStr
  cancel?: () => void
  controller: CustomDialogController
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor

  async fetchIpInfo(IP: string) {
    try {
      // 调用 getIpInfo 函数并等待结果
      const ipInfo = await getIpInfo(IP)
      hilog.info(0xFF00, "MoreIPtestTag", "IP Info: %{public}s", JSON.stringify(ipInfo))
      const locationInfo = extractLocationInfo(ipInfo)
      if (locationInfo) {
        // 查询完成提示
        promptAction.showToast({message: $r('app.string.ip_address_query_success_tips'), duration: 2000 })
        // 使用模板字符串来只输出值，不输出键名
        hilog.info(0xFF00, "MoreIPtestTag", "IP地址: %{public}s", `${locationInfo.country},${locationInfo.province}, ${locationInfo.city}`)
        const theIPaddress = mapLocation(locationInfo)
        this.IPaddressinfo = `${theIPaddress.country} ${theIPaddress.province} ${theIPaddress.city}`
        hilog.info(0xFF00, "MoreIPtestTag", "IP地址(完整): %{public}s", this.IPaddressinfo)
      } else {
        hilog.info(0xFF00, "MoreIPtestTag", "提取位置信息失败")
      }
    } catch (err) {
      // 处理错误情况
      const IPinfoError = `Error:${JSON.stringify(err)}`
      hilog.info(0xFF00, "MoreIPtestTag", "IP Info: %{public}s", IPinfoError)
    }
  }

  build() {
    Column() {
      Text(this.theDialogTitle)
        .fontWeight(FontWeight.Medium)
        .fontSize(20)
        .margin({ top: 15, bottom: 15 })
      TextInput({placeholder: this.theplaceholder, text: this.currentInputValue })
        .onChange((value: string) => {
          this.currentInputValue = value
        })
        .margin({bottom: 10 })
        .onSubmit((enterKey: EnterKeyType, event: SubmitEvent) => {
          this.SubmitInputValue = this.currentInputValue
          // 查询开始提示
          promptAction.showToast({message: $r('app.string.ip_address_query_tips'), duration: 1600 })
          this.fetchIpInfo(this.SubmitInputValue)
        })
      if(this.SubmitInputValue != '') {
        Row() {
          Text(this.IPaddressinfo)
            .fontSize(16)
            .margin({left: 3})
        }
        .width('100%')
        .margin({bottom: 8})
        .justifyContent(FlexAlign.Start)
      }
      Button($r('app.string.close'))
        .width('100%')
        .height(39)
        .onClick(() => {
          this.currentInputValue = ''
          this.controller.close()
          if (this.cancel) {
            this.cancel()
          }
        })
        .backgroundColor(this.icon_emphasize)
        .fontColor(Color.White)
    }
    .padding({left: 16, right: 16, bottom: 16})
    .backgroundColor($r('app.color.container_background'))
    .width('100%')
  }
}




