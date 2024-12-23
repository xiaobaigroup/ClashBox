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
import Settings from '../components/Settings/Settings';
import moreListItem from '../components/More/moreListItem';
import Basic from '../components/More/Overwrite/Basic';
import DNS from '../components/More/Overwrite/DNS';
import Network, { NetworkRouterAddress } from '../components/More/Overwrite/Network';
import { FakeIPfilter } from '../components/More/Overwrite/DNSsubpage';

@Entry
@Component
struct MorePage {
  private componentName: string = 'MorePage'
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')

  @State isShowSettings: boolean = false
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
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
  /* 断点布局相关 相关作用看定义时候的注释 */
  // 整体外边距
  @Consume('breakPointStatemorePageMargin')
  private morePageMargin: BreakpointState<number>
  // 列表底边距
  @Consume('breakPointStatemorePagelistBottom')
  private listBottom: BreakpointState<number>
  // 列表高度
  @Consume('breakPointStateListHeight')
  private listHeight: BreakpointState<number>

  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean


  aboutToAppear() {

  }

  aboutToDisappear() {

  }


  handleCheck(index: number) {
    // 列表行点击处理
    let itemData = this.moreList[index]
    hilog.isLoggable(0xFF00, "MoretestTag", hilog.LogLevel.INFO);
    hilog.info(0xFF00, "MoretestTag", itemData.name)
    hilog.info(0xFF00, "MoretestTag", "isCheck状态: %{public}s", itemData.isCheck)
    this.pageInfos.clear()
    this.pageInfos.pushPathByName(itemData.name, false)
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
    Settings({isShowSettings: this.isShowSettings})
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
          .bindSheet($$this.isShowSettings, this.SettingsSheet(), {
            detents: [BIND_SHEET_CONTAINER_HEIGHT, 300],
            dragBar: false,
            backgroundColor: $r('app.color.container_background'),
            blurStyle: BlurStyle.BACKGROUND_REGULAR,
            preferType: SheetType.CENTER,
            onWillDismiss: () => {
              this.isShowSettings = false
              this.isEnableIndexForegroundBlur = false
              this.SettingsPageInfos.clear()
              //this.pageInfos.clear()
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




