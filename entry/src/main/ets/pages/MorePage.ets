/*
 * More列表页
 * 2024.12.04
 *
 */
import { BreakpointState } from '../common/breakpointsystem'
import { BIND_SHEET_CONTAINER_HEIGHT,
  ConfigItemData,
  CONTENT_END_OFFSET_150, ListMoreData, moreData,
  TAB_CONTENT_TITLE_FONT_SIZE,
  TAB_CONTENT_TITLE_HEIGHT } from '../common/Constants';
import { hilog } from '@kit.PerformanceAnalysisKit';
import Log from '../components/More/Log';
import { LogDetils } from '../components/More/Log';
import Resources from '../components/More/Resources';
import RequestPage from '../components/More/Request';
import Connect from '../components/More/Connect';
import Overwrite from '../components/More/Overwrite/Overwrite';
import Diversion from '../components/More/Diversion';
import Settings from '../components/Settings/Settings';
import Basic from '../components/More/Overwrite/Basic';
import DNS from '../components/More/Overwrite/DNS';
import Network, { NetworkCompatible, NetworkRouterAddress } from '../components/More/Overwrite/Network';
import { getResourceString } from '../utils/ResourceStringUtil';
import { extractLocationInfo, getIpInfo, mapLocation } from '../utils/GetIpInfo';
import {  promptAction } from '@kit.ArkUI';
import { skipRowList } from '../components/Common';
import { AppConfig, UIConfig } from '../entryability/AppState';
import { ArrayConfigEditor } from '../components/More/Overwrite/EditArrayConfig';
import { removeItemsByIndex } from '../utils/RemoveItemsUtils';
import { customAnimationUtil } from '../utils/Animation';


@Entry
@Component
struct MorePage {
  private componentName: string = 'MorePage'
  @Consume isRolling: boolean
  @Consume isSmallSquareScreen: boolean
  // 设置页显示变量
  @State isShowSettings: boolean = false
  // 是否进入二级界面
  @Consume isSecondary: boolean
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  // 日志页详情页跳转角标
  @Provide theLogSkipItem: number = 0
  // 查询IP地址弹窗默认文本
  @State QueryIPplaceholder: string = getResourceString($r('app.string.query_ip_region_placeholder'), this)
  // 添加路由地址弹窗标题
  @State QueryIPDialogTitle: ResourceStr = $r('app.string.query_ip_region')
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  // 更多页列表数组
  @Consume moreList: moreData[]
  // 主页面栈
  @Consume('NavPathStack') pageInfos: NavPathStack
  // 设置页面栈
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  /* 断点布局相关 相关作用看定义时候的注释 */
  // 整体外边距
  @Consume('breakPointStatemorePageMargin')  private morePageMargin: BreakpointState<number>

  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @Consume('breakPointStateTabContentTitleMargin')
  private breakPointStateTabContentTitleMargin: BreakpointState<number>
  //更多页一级页面顶部标题偏移量
  @Consume curYOffsetMore: number
  //px外屏隐藏top和tab偏移
  @Consume heightTop: number
  @Consume curOffsetRemain: number
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
    if(index === this.moreList.length - 1) {
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
      this.pageInfos.replacePathByName(itemData.name, false)
      this.isSecondary = true
    }
  }

  // 更多页路由表
  @Builder
  PagesMap(name: string, params: string | ConfigItemData) {
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
    if (name == 'EditArrayConfig') {
      ArrayConfigEditor({params: params as ConfigItemData})
    } else
    if (name == 'LogDetils') {
      LogDetils()
    } else
    if (name == 'compatible') {
      NetworkCompatible()
    }
  }

  // 通过@Builder构建设置模态展示界面
  @Builder
  SettingsSheet() {
    Column() {
      Settings()
    }
    .width('100%')
    .height('100%')
  }

  build() {
    Navigation(this.pageInfos) {
      Stack() {
        // 顶部导航栏
        Row() {
          Text($r('app.string.More'))
            .fontSize(this.curYOffsetMore<0?TAB_CONTENT_TITLE_FONT_SIZE-this.curYOffsetMore/100:TAB_CONTENT_TITLE_FONT_SIZE)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .zIndex(1)
        .height(this.curYOffsetMore < 0 ? TAB_CONTENT_TITLE_HEIGHT - this.curYOffsetMore : TAB_CONTENT_TITLE_HEIGHT)
        .position({x: 0,y:this.isRolling && this.isSmallSquareScreen?this.heightTop:0})
        .backgroundColor($r('app.color.background'))
        .transition(customAnimationUtil.isSlide(0, this.uiConfig))
        .padding({
          left: this.breakPointStateTabContentTitleMargin.value,
          right: this.breakPointStateTabContentTitleMargin.value,
        })

          Scroll() {
            List({ space: 10 }) {
              ForEach(this.moreList, (item: moreData, index: number) => {
                ListItem() {
                  skipRowList({
                    icons: item.icons,
                    name: item.name,
                    title: item.title,
                    subtitle: item.subtitle,
                    isPrimaryIcons: true
                  })
                }.margin({ left: this.morePageMargin.value, right: this.morePageMargin.value })
                .onClick(() => {
                  this.handleCheck(index)
                })
                .transition(customAnimationUtil.isScaleTran(index, this.uiConfig))
              })
              // 设置行
              ListItem() {
                skipRowList({
                  icons: $r('sys.symbol.gearshape'),
                  title: $r('app.string.Settings'),
                  isPrimaryIcons: true
                })
              }.margin({ left: this.morePageMargin.value, right: this.morePageMargin.value })
              .onClick(() => {
                this.isShowSettings = true
                this.isEnableIndexForegroundBlur = true
              })
              .transition(customAnimationUtil.isScaleTran(6, this.uiConfig))
              // 设置页半模态窗口
              .bindSheet($$this.isShowSettings, this.SettingsSheet(), {
                detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.LARGE],
                dragBar: false,
                backgroundColor: $r('app.color.background'),
                keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
                scrollSizeMode: ScrollSizeMode.CONTINUOUS,
                preferType: SheetType.CENTER,
                onWillDismiss: () => {
                  this.isShowSettings = false
                  this.isEnableIndexForegroundBlur = false
                  this.SettingsPageInfos.clear()
                }
              })

              /*ListItem() {
                Button("appCrash 测试按钮，请勿点击").onClick(()=>{
                  // 在按钮点击函数中构造一个crash场景，触发应用崩溃事件
                  let result: object = JSON.parse("");
                })
              }*/

            }
            .width('100%')
            .height('100%')
            .edgeEffect(EdgeEffect.Spring)
            .borderRadius(18)
            .alignListItem(ListItemAlign.Center)
            .contentEndOffset(CONTENT_END_OFFSET_150)
            .chainAnimation(true)
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            })
          }
          .padding({top: (this.isRolling && this.isSmallSquareScreen) ? this.heightTop : TAB_CONTENT_TITLE_HEIGHT})
          .height('100%')
          .edgeEffect(this.uiConfig.isAnimation ? EdgeEffect.Spring: null)
          .onScrollFrameBegin((offset: number) => {
            this.curOffsetRemain  += offset
            if (offset>0) {
              this.isRolling = true
            }else if(offset<0){
              this.isRolling = false
              this.curOffsetRemain = 0
            }
            console.info("offsetRemain:" + offset + '/' +this.curOffsetRemain);
            return { offsetRemain: offset }
          })
          .onDidScroll((xOffset: number, yOffset: number, scrollState: ScrollState): void => {
            // 累计计算当前父组件滚动在Y轴方向的偏移量
            if (this.uiConfig.isAnimation){
              this.curYOffsetMore += yOffset
            }
            console.info("yOffset" + this.curYOffsetMore);
          })
        }.height('100%').width('100%')
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




