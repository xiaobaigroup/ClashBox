/*
 * More列表页
 * 2024.12.04
 *
 */
import { BreakpointState, BreakpointSystem } from '../common/breakpointsystem'
import { ListMoreData, moreData } from '../common/Constants';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { text } from '@kit.ArkGraphics2D';
import Log from '../components/More/Log';
import Resources from '../components/More/Resources';
import RequestPage from '../components/More/Request';
import Connect from '../components/More/Connect';
import Overwrite from '../components/More/Overwrite';
import Settings from '../components/Settings/Settings';
import moreListItem from '../components/More/moreListItem';

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
  // 断点
  @State compStr: BreakpointState<string> = BreakpointState.of({
    xs: "xs", sm: "sm", md: "md", lg: "lg", xl: "xl"
  })
  // 整体外边距
  @Provide('morePageMargin') morePageMargin: BreakpointState<number> = BreakpointState.of({
    xs: 12, sm: 14, md: 56, lg: 56, xl: 79
  })
  // 列表底边距
  @Provide('listBottom') listBottom: BreakpointState<number> = BreakpointState.of({
    xs: 10, sm: 10, md: 14, lg: 14, xl: 14
  })


  aboutToAppear(): void {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.morePageMargin)
    BreakpointSystem.getInstance().attach(this.listBottom)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear(): void {
    // BreakpointSystem.getInstance().attach(this.compStr)
    // BreakpointSystem.getInstance().attach(this.morePageMargin)
    // BreakpointSystem.getInstance().attach(this.listBottom)
    // BreakpointSystem.getInstance().stop()
  }


  handleCheck(index: number) {
    // 将isCheck变为true并更新数组
    let itemData = this.moreList[index]
    //itemData.isCheck = !itemData.isCheck
    //this.moreList.splice(index, 1, itemData)
    hilog.isLoggable(0xFF00, "MoretestTag", hilog.LogLevel.INFO);
    hilog.info(0xFF00, "MoretestTag", itemData.name)
    hilog.info(0xFF00, "MoretestTag", "isCheck状态: %{public}s", itemData.isCheck)
    //hilog.info(0xFF00, "jsHilogTest", " itemData: %{public}s", JSON.stringify( itemData))
    this.pageInfos.pushPathByName(itemData.name, false)
  }

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
    }
  }

  build() {
    // Column() {
      Navigation(this.pageInfos) {
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
              Row()
                .width(10)
                .height(10)
                .margin({ right: 20 })
                .border({
                  width: {
                    top: 2,
                    right: 2
                  },
                  color: '#000000'
                })
                .rotate({ angle: 45 })
            }
            .width('94%')
            .height(53)
            .borderRadius(20)
            .backgroundColor($r('app.color.container_background'))
          }
          .onClick(() => {
            this.isShowSettings = true
          })
          .bindSheet($$this.isShowSettings, SettingsSheet(), {
            detents: [700, SheetSize.MEDIUM, 200],
            backgroundColor: $r('app.color.settings_container_background'),
            blurStyle: BlurStyle.BACKGROUND_REGULAR,
            showClose: true,
            onDisappear: () => {
              this.SettingsPageInfos.clear()
              this.pageInfos.clear()
            }
          })
        }
        .width('100%')
        .height(700)
        .margin({ top: 10, left: this.morePageMargin.value, right: this.morePageMargin.value })
        .borderRadius(18)
        .alignListItem(ListItemAlign.Center)

      }
      .mode(this.isLandscapePhone ? NavigationMode.Stack : NavigationMode.Auto)
      .navDestination(this.PagesMap)
      .width('100%')
      .height('100%')
  }
}

export default MorePage

// 通过@Builder构建设置模态展示界面
@Builder function SettingsSheet() {

  Column() {
    Settings()
  }
  .width('100%')
  .height('100%')
  //.backgroundColor(Color.White)
}


