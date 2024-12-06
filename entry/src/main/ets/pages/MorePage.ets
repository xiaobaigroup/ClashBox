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
import Settings from '../components/More/Settings';
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
  @State isLandscapePhone: boolean = false
  @State moreList: moreData[] = ListMoreData()
  @Provide('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
  // 断点
  @State compStr: BreakpointState<string> = BreakpointState.of({
    xs: "xs", sm: "sm", md: "md", lg: "lg", xl: "xl"
  })
  // 整体外边距
  @State morePageMargin: BreakpointState<number> = BreakpointState.of({
    xs: 12, sm: 14, md: 56, lg: 56, xl: 79
  })
  // 列表底边距
  @State listBottom: BreakpointState<number> = BreakpointState.of({
    xs: 10, sm: 10, md: 14, lg: 14, xl: 14
  })

  onPhoneLandscape(mediaQueryResult:mediaquery.MediaQueryResult) {
    if (mediaQueryResult.matches as boolean ) {
      this.isLandscapePhone = true
    } else {
      this.isLandscapePhone = false
    }
  }

  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)')

  aboutToAppear(): void {
    this.phonelistener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.onPhoneLandscape(mediaQueryResult)
    })

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.morePageMargin)
    BreakpointSystem.getInstance().attach(this.listBottom)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear(): void {
    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.morePageMargin)
    BreakpointSystem.getInstance().attach(this.listBottom)
    BreakpointSystem.getInstance().stop()
    this.phonelistener.off('change')
  }


  handleCheck(index: number) {
    // 将isCheck变为true并更新数组
    let itemData = this.moreList[index]
    itemData.isCheck = !itemData.isCheck
    this.moreList.splice(index, 1, itemData)
    hilog.isLoggable(0xFF00, "MoretestTag", hilog.LogLevel.INFO);
    hilog.info(0xFF00, "MoretestTag", itemData.name)
    hilog.info(0xFF00, "MoretestTag", "isCheck状态: %{public}s", itemData.isCheck)
    hilog.info(0xFF00, "jsHilogTest", " itemData: %{public}s", JSON.stringify( itemData))
    this.pageInfos.pushPathByName(itemData.name, false)
  }

  @Builder
  PagesMap(name: string) {
    if (name == 'Log') {
      Log()
    }
    if (name == 'Resources') {
      Resources()
    }
    if (name == 'Resources') {
      RequestPage()
    }
    if (name == 'Resources') {
      Connect()
    }
    if (name == 'Resources') {
      Overwrite()
    }
  }

  build() {
      Navigation(this.pageInfos) {
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
                /*.bindContentCover(item.isCheck, moreSheet({paramIndex: index}), {
                  modalTransition: ModalTransition.NONE,
                  onDisappear: () => {
                    // 模态窗口消失时恢复isCheck的false状态并更新数组
                    item.isCheck = false
                    hilog.info(0xFF00, "MoretestTag", "isCheck状态2: %{public}s", item.isCheck)
                    this.moreList.splice(index, 1, item)
                    hilog.info(0xFF00, "jsHilogTest", " item: %{public}s", JSON.stringify( item))

                  }
                })*/
                /*.bindSheet(item.isCheck, moreSheet({paramIndex: index}), {
                  detents: [SheetSize.LARGE, SheetSize.MEDIUM, 200],
                  backgroundColor: Color.Gray,
                  blurStyle: BlurStyle.Thick,
                  showClose: true,
                  title: { title: item.title, subtitle: "subtitle" },
                  onDisappear: () => {
                    // 模态窗口消失时恢复isCheck的false状态并更新数组
                    item.isCheck = false
                    hilog.info(0xFF00, "MoretestTag", "isCheck状态2: %{public}s", item.isCheck)
                    this.moreList.splice(index, 1, item)
                    hilog.info(0xFF00, "jsHilogTest", " item: %{public}s", JSON.stringify( item))

                  }
                })*/
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
                .width('100%')
                .height(53)
                .borderRadius(20)
                .backgroundColor('white')
              }
              .onClick(() => {
                this.isShowSettings = true
              })
              .bindSheet($$this.isShowSettings, SettingsSheet(), {
                detents: [SheetSize.LARGE, SheetSize.MEDIUM, 200],
                //backgroundColor: Color.Gray,
                blurStyle: BlurStyle.Thick,
                showClose: true,
                title: { title: $r('app.string.Settings') },
              })
            }
            //.height('100%')
            .margin({ top: 10, left: this.morePageMargin.value, right: this.morePageMargin.value })
            .borderRadius(18)
            .alignListItem(ListItemAlign.Center)

      }
      .title($r('app.string.More'))
      .mode(this.isLandscapePhone? NavigationMode.Stack : NavigationMode.Auto)
      .navDestination(this.PagesMap)
      .width('100%')
      .height('100%')
  }
}

export default MorePage

@Component
struct moreListItem {
  @Prop itemObj: moreData
  @Prop index: number
  onCheck = (index: number) => {}

  build() {
    Row() {
      Row() {
        SymbolGlyph(this.itemObj.icons)
          .fontSize(24)
          .margin({left: 12})
        Text(this.itemObj.title)
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
      .width('100%')
      .height(53)
      .borderRadius(20)
      .backgroundColor('white')
      Row()
        .height(10)
    }
    .onClick(() => {
      this.onCheck(this.index)
    })
  }
}

// 通过@Builder构建模态展示界面
class Tmp {
  paramIndex: number = 0
}
@Builder function SettingsSheet() {

  Column() {
    Text('设置')
  }
  .width('100%')
  .height('100%')
  //.backgroundColor(Color.White)
}


