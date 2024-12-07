import { ThemeControl } from '@ohos.arkui.theme'
import { gAppTheme } from '../common/AppTheme'
import { BreakpointState, BreakpointSystem } from '../common/breakpointsystem';
import { createGroup1Data, ProxyData } from '../common/ProxyListData';
import ProxyListItem from '../components/Proxy/ProxyListItem';
import { SymbolGlyphModifier } from '@kit.ArkUI';


// 在页面build前执行ThemeControl，就可以改变主题颜色
//ThemeControl.setDefaultTheme(gAppTheme)


@Entry
@Component
struct ProxyPage {
  //系统颜色调用
  @State icon_emphasize: ResourceColor = $r('sys.color.icon_emphasize') //高亮图标，蓝色
  @State font_primary: ResourceColor = $r('sys.color.font_primary') //一级文本色，黑色
  @State font_secondary: ResourceColor = $r('sys.color.font_secondary') //一级文本反色，白色
  @State font_on_primary: ResourceColor = $r('sys.color.font_on_primary') //一级文本反色，白色
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary') //一级图标色，黑色
  @State comp_divider: ResourceColor = $r('sys.color.comp_divider') //四级图标色，黑色
  //长按菜单图标
  @State startIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.star')).fontSize('24vp');
  @State startIconModifier1: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.bolt_filled_on_circle')).fontSize('24vp');
  @State startIconModifier2: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.timer')).fontSize('24vp');
  @State container_background: ResourceColor = ($r('app.color.container_background'));
  @State currentIndex: number = 0;
  @State proxyGroup1List: ProxyData[] = createGroup1Data();
  @State isShow: boolean = false
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
  /*
       预留自定义主题，颜色在AppTheme里面修改
       onWillApplyTheme(theme: Theme) {
          this.backgroundPrimary = theme.colors.backgroundPrimary;
          this.fontPrimary = theme.colors.fontPrimary;
          this.iconOnPrimary = theme.colors.iconOnPrimary;
          this.iconFourth = theme.colors.iconFourth;
       }
   */
  //@State private gridMargin: number = 0
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
  //半模拟态编辑菜单
  BindSheetEdit() {
    Row() {
      Column() {
        Text('分组方式')
          .width('100%')
          .fontSize(16)
          .fontColor(this.font_secondary)
          .padding({ left: 15, bottom: 10 })
          .textAlign(0)

        Column() {
          Row() {
            Text('标签页(默认)')
              .font({ size: 16 })
              .fontColor(this.font_primary)

            Radio({
              value: 'Radio', group: 'radioGroup',
              indicatorType: RadioIndicatorType.TICK
            })
              .checked(false)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
                //   uncheckedBorderColor: this.icon_secondary
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Divider().strokeWidth(0.7).color(this.comp_divider).padding({ left: 5, right: 10 })

          Row() {
            Text('列表')
              .font({ size: 16 })
              .fontColor(this.font_primary)

            Radio({
              value: 'Radio', group: 'radioGroup',
              indicatorType: RadioIndicatorType.TICK
            })
              .checked(false)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
                //   uncheckedBorderColor: this.icon_secondary
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .padding({ left: 15, right: 10 })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({ bottom: 10 })
        .width('100%')
        .height(94)
        .borderRadius(20)
        .backgroundColor(($r('app.color.container_background')))

        Text('排列方式')
          .width('100%')
          .fontSize(16)
          .fontColor(this.font_secondary)
          .padding({ left: 15, bottom: 10 })
          .textAlign(0)

        Column() {
          Row() {
            Text('默认')
              .font({ size: 16 })
              .fontColor(this.font_primary)

            Radio({
              value: 'Radio', group: 'radioGroup',
              indicatorType: RadioIndicatorType.TICK
            })
              .checked(false)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
                //   uncheckedBorderColor: this.icon_secondary
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Divider().strokeWidth(0.7).color(this.comp_divider).padding({ left: 5, right: 10 })

          Row() {
            Text('延迟')
              .font({ size: 16 })
              .fontColor(this.font_primary)

            Radio({
              value: 'Radio', group: 'radioGroup',
              indicatorType: RadioIndicatorType.TICK
            })
              .checked(false)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
                //   uncheckedBorderColor: this.icon_secondary
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Divider().strokeWidth(0.7).color(this.comp_divider).padding({ left: 5, right: 10 })


          Row() {
            Text('名称')
              .font({ size: 16 })
              .fontColor(this.font_primary)

            Radio({
              value: 'Radio', group: 'radioGroup',
              indicatorType: RadioIndicatorType.TICK
            })
              .checked(false)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
                //   uncheckedBorderColor: this.icon_secondary
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .padding({ left: 15, right: 10 })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({ bottom: 10 })
        .width('100%')
        .height(142)
        .borderRadius(20)
        .backgroundColor(($r('app.color.container_background')))


        Text('布局')
          .width('100%')
          .fontSize(16)
          .fontColor(this.font_secondary)
          .padding({ left: 15, bottom: 10 })
          .textAlign(0)

        Column() {
          Row() {
            Text('宽松(单列)')
              .font({ size: 16 })
              .fontColor(this.font_primary)

            Radio({
              value: 'Radio', group: 'radioGroup',
              indicatorType: RadioIndicatorType.TICK
            })
              .checked(false)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
                //   uncheckedBorderColor: this.icon_secondary
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Divider().strokeWidth(0.7).color(this.comp_divider).padding({ left: 5, right: 10 })

          Row() {
            Text('标准(多列)(默认)')
              .font({ size: 16 })
              .fontColor(this.font_primary)

            Radio({
              value: 'Radio', group: 'radioGroup',
              indicatorType: RadioIndicatorType.TICK
            })
              .checked(false)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
                //   uncheckedBorderColor: this.icon_secondary
              })

          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .padding({ left: 15, right: 10 })
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({ bottom: 10 })
        .height(94)
        .borderRadius(20)
        .backgroundColor(($r('app.color.container_background')))
      }
    }
    .padding({ left: 16, right: 16 })
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  //长按菜单相关
  MyMenu() {
    Menu() {
      MenuItemGroup() {
        MenuItem({ symbolStartIcon: this.startIconModifier, content: "收藏" })
      }

      MenuItemGroup() {
        MenuItem({ symbolStartIcon: this.startIconModifier1, content: "测速延迟" })
      }

      MenuItemGroup() {
        MenuItem({ symbolStartIcon: this.startIconModifier2, content: "测试速度" })
      }
    }
    .backgroundColor($r('app.color.container_background'))
    .borderRadius(20)
  }

  @Builder
  TabBuilder(title: ResourceStr, targetIndex: number) {
    Column() {
      Column() {
        Text(title)
          .fontSize(14)
          .fontColor(this.currentIndex === targetIndex ? this.font_on_primary : this.font_secondary)
      }
      .borderRadius(21)
      .height(this.currentIndex === targetIndex ? 36 : 32)
      .width(this.currentIndex === targetIndex ? 96 : 87)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.currentIndex === targetIndex ? this.icon_emphasize : this.container_background)
    } //
    //.alignItems(HorizontalAlign.Start)
    // .justifyContent(FlexAlign.Start)
    // .justifyContent(FlexAlign.Center)
    .height(55)
    .margin({ right: 8, bottom: 10 })
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(this.currentIndex);
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
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
          .textAlign(TextAlign.Start)
        Blank()
        //编辑图标
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.square_and_pencil'))
            .fontSize(24)//      .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)//分层颜色
            .fontColor([this.icon_secondary])
            .onClick(() => {
              this.isShow = true
            })
        }
        .width(40)
        .height(40)
        .backgroundColor($r('app.color.settings_container_background'))
        .bindSheet($$this.isShow, this.BindSheetEdit(), {
          detents: [600, 300, 200],
          backgroundColor: $r('app.color.settings_container_background'),
          blurStyle: BlurStyle.BACKGROUND_REGULAR,
          showClose: true,
          scrollSizeMode: ScrollSizeMode.CONTINUOUS,
          title: { title: "编辑" },
          width: ('100%')
        })
      }
      .padding({ left: this.proxyPageMargin.value, right: this.proxyPageMargin.value })
      .margin({ bottom: 15 })
      .width('98%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Top)

      Column() {
        Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
          TabContent() {
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
                    .width(undefined)
                    .height(56)
                    .bindContextMenu(this.MyMenu, ResponseType.LongPress,
                      {
                        preview: MenuPreviewMode.IMAGE,
                        previewAnimationOptions: { scale: [1.0, 1.1] },
                      })
                }
                .padding({ bottom: 10, right: this.proxyPageMargin.value })
              })
            }
            .lanes(this.ListLanes.value)
            .scrollBar(BarState.Off)
            .width('100%')
            .height('100%')
          }
          //外边距
          //    .margin({ left: this.proxyPageMargin.value,right: this.proxyPageMargin.value })
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
          .tabBar(this.TabBuilder('分组5', 4))

          TabContent() {
          }
          .tabBar(this.TabBuilder('分组6', 5))

          TabContent() {
          }
          .tabBar(this.TabBuilder('分组7', 6))

          TabContent() {
          }
          .tabBar(this.TabBuilder('分组7', 7))

        }
        .padding({ left: this.proxyPageMargin.value })
        .barMode(BarMode.Scrollable)
        .barHeight(55)
        .fadingEdge(true)
        .onChange((index: number) => {
          this.currentIndex = index;
        })
      }
      .width('100%')
      .backgroundColor($r('app.color.background'))
    }
  }
}

export default ProxyPage