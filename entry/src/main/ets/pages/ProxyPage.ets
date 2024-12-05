import { ThemeControl } from '@ohos.arkui.theme'
import { gAppTheme } from '../common/AppTheme'
import { BreakpointState, BreakpointSystem } from '../common/breakpointsystem';
import { createGroup1Data, ProxyData } from '../common/ProxyListData';
import ProxyListItem from '../components/ProxyListItem';

// 在页面build前执行ThemeControl，就可以改变主题颜色
//ThemeControl.setDefaultTheme(gAppTheme)

@Entry
@Component
struct ProxyPage {
  //系统颜色调用
  @State icon_emphasize: ResourceColor = $r('sys.color.icon_emphasize') //高亮图标，蓝色
  @State font_primary: ResourceColor = $r('sys.color.font_primary') //一级文本色，黑色

  @State container_background: ResourceColor = ($r('app.color.container_background'));
  /*
       预留自定义主题，颜色在AppTheme里面修改
       onWillApplyTheme(theme: Theme) {
          this.backgroundPrimary = theme.colors.backgroundPrimary;
          this.fontPrimary = theme.colors.fontPrimary;
          this.iconOnPrimary = theme.colors.iconOnPrimary;
          this.iconFourth = theme.colors.iconFourth;
       }
   */
  @State currentIndex: number = 0;
  @State proxyGroup1List: ProxyData[] = createGroup1Data();
  @State compStr: BreakpointState<string> = BreakpointState.of({
    xs: "xs",
    sm: "sm",
    md: "md",
    lg: "lg",
    xl: "xl"
  })
  @State proxyPageMargin: BreakpointState<number> = BreakpointState.of({
    xs: 12,
    sm: 14,
    md: 28,
    lg: 36,
    xl: 37
  });
  @State ListLanes: BreakpointState<number> = BreakpointState.of({
    xs: 1,
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3
  });
  @State ListGutter: BreakpointState<number> = BreakpointState.of({
    xs: 1,
    sm: 1,
    md: 2,
    lg: 3,
    xl: 3
  });
  private tabsController: TabsController = new TabsController()

  aboutToAppear(): void {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.proxyPageMargin)
    BreakpointSystem.getInstance().attach(this.ListLanes)
    BreakpointSystem.getInstance().attach(this.ListGutter)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear(): void {
    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.proxyPageMargin)
    BreakpointSystem.getInstance().attach(this.ListLanes)
    BreakpointSystem.getInstance().attach(this.ListGutter)
    BreakpointSystem.getInstance().stop()
  }

  @Builder
  TabBuilder(title: ResourceStr, targetIndex: number) {
    Column() {
      Column() {
        Text(title)
          .fontSize(16)
          .fontColor(this.currentIndex === targetIndex ? this.container_background : this.font_primary)
      }
      .borderRadius(21)
      .height(32)
      .width(96)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.currentIndex === targetIndex ? this.icon_emphasize : this.container_background)
    } //
    //.alignItems(HorizontalAlign.Start)
    // .justifyContent(FlexAlign.Start)
    .justifyContent(FlexAlign.Center)
    .height(55)
    .margin({ right: 8, bottom: 10 })


    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(this.currentIndex);
    })
  }

  handleCheck(index: number) {
    let itemData = this.proxyGroup1List[index]
    itemData.isCheck = !itemData.isCheck
    //this.proxyGroup1List.splice(index, 1, itemData)
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.Proxy'))
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 15 })
          .width('100%')
          .textAlign(TextAlign.Start)
      }

      Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
        TabContent() {
          Column() {
            List() {
              ForEach(this.proxyGroup1List, (item: ProxyData, index: number) => {
                ListItem() {
                  ProxyListItem({
                    index: index,
                    itemObj: item,
                    onCheck: (index: number) => {
                      this.handleCheck(index)
                    }
                  })
                    .backgroundColor($r('app.color.container_background'))
                    .borderRadius(20)
                    .width('93%')
                    .height(58)
                    .margin({ bottom: 10 })
                    .padding({left:14,right: 14 })
                }
              })
            }
            .lanes(this.ListLanes.value)
            .scrollBar(BarState.Auto)
            .width('100%')
          }
          .width('100%')
          .height('100%')

          //   .backgroundColor($r('app.color.background'))
          //   .justifyContent(FlexAlign.SpaceBetween)
        }
        .tabBar(this.TabBuilder('分组1', 0))

        TabContent() {
        }
        .tabBar(this.TabBuilder('分组2', 1))

        TabContent() {
        }
        .tabBar(this.TabBuilder('分组3', 2))

        TabContent() {
        }
        .tabBar(this.TabBuilder('分组4', 3))

        TabContent() {
        }
        .tabBar(this.TabBuilder('分组6', 4))

        TabContent() {
        }
        .tabBar(this.TabBuilder('分组7', 5))
      }

      .barMode(BarMode.Scrollable)
      .barHeight(55)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    }
    .width('100%')

    //外边距
    .margin({ left: this.proxyPageMargin.value })
    .backgroundColor($r('app.color.background'))
  }
}

export default ProxyPage