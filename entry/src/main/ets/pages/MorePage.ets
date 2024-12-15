/*
 * More列表页
 * 2024.12.04
 *
 */
import { BreakpointState, BreakpointSystem } from '../common/breakpointsystem'
import { BIND_SHEET_CONTAINER_HEIGHT, ListMoreData, moreData } from '../common/Constants';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { text } from '@kit.ArkGraphics2D';
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
import { mediaquery } from '@kit.ArkUI';

@Entry
@Component
struct MorePage {
  //系统颜色调用
  /*  @State icon_emphasize: ResourceColor = $r('sys.color.icon_emphasize')//高亮图标，蓝色
    @State icon_tertiary: ResourceColor = $r('sys.color.icon_tertiary')//三级图标色，浅灰色

     预留自定义主题，颜色在AppTheme里面修改
     onWillApplyTheme(theme: Theme) {
        this.backgroundPrimary = theme.colors.backgroundPrimary;
        this.fontPrimary = theme.colors.fontPrimary;
        this.iconOnPrimary = theme.colors.iconOnPrimary;
        this.iconFourth = theme.colors.iconFourth;
     }
 */
  @State isShowSettings: boolean = false
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @State moreList: moreData[] = ListMoreData()
  // 更多页面栈
  @Provide('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
  // 设置页面栈
  @Provide('NavSettingsPathStack') SettingsPageInfos: NavPathStack = new NavPathStack()
  // 平板竖屏判断
  @Provide('tabletVertical') istabletVertical: boolean = false

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

  // 平板竖屏判断
  deviceHeightListener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(1000vp< height)');


  aboutToAppear(): void {
    // 开启change监听
    this.deviceHeightListener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.istabletVertical = mediaQueryResult.matches
    });
  }

  aboutToDisappear(): void {
    // 解绑listener中注册的回调函数
    this.deviceHeightListener.off('change')
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
              Text($r('app.string.Settings'))
                .height(48)
                .fontWeight(FontWeight.Medium)
                .padding({ left: 12 })
                .fontSize(16)
              Blank()
              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontSize(28)
                .margin({right: 12})
            }
            .width('94%')
            .height(53)
            .borderRadius(20)
            .backgroundColor($r('app.color.container_background'))
          }
          .onClick(() => {
            this.isShowSettings = true
          })
          .bindSheet($$this.isShowSettings, this.SettingsSheet(), {
            detents: [BIND_SHEET_CONTAINER_HEIGHT, 300],
            dragBar: false,
            backgroundColor: $r('app.color.settings_container_background'),
            blurStyle: BlurStyle.BACKGROUND_REGULAR,
            preferType: SheetType.CENTER,
            onDisappear: () => {
              this.SettingsPageInfos.clear()
              //this.pageInfos.clear()
            }
          })
        }
        .width('100%')
        // .layoutWeight(1) // 自适应占满剩余空间
        .height(this.isLandscapePhone ? 275 : this.listHeight.value)
        .margin({ top: 10, left: this.morePageMargin.value, right: this.morePageMargin.value })
        .borderRadius(18)
        .alignListItem(ListItemAlign.Center)

      }
      .mode(this.isLandscapePhone ? NavigationMode.Stack : NavigationMode.Auto)
      .navBarWidth(330)
      .navDestination(this.PagesMap)
      .width('100%')
      .height('100%')
  }
}

export default MorePage




