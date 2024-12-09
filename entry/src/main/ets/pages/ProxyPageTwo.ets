import { CustomColors, ThemeControl } from '@ohos.arkui.theme'
import { gAppTheme } from '../common/AppTheme'
import { BreakpointState, BreakpointSystem } from '../common/breakpointsystem';
import { createGroup1Data, ProxyData } from '../common/ProxyListData';
import ProxyListItem from '../components/Proxy/ProxyListItem';
import { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import NetworkSpeedButton from '../components/Proxy/NetworkSpeedButton'



@CustomDialog
struct CustomDialogExample {
  controller?: CustomDialogController
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  build() {
    Column() {
      Text('速度和延迟的区别')
        .fontSize(20)
        .padding({ bottom: 15 })
        .fontWeight(700)
      Text('速度：通常指网络带宽，决定你下载文件及看视频、图片加载的速度。\n' +
        '延迟：通常指网络ping的时间，决定你打游戏的体验和访问网页的速度。\n' +
        '通常情况下，速度快不代表延迟低，延迟低也不能代表速度快，他们之间没有直接关系。')
        .fontSize(16)
        .padding({ bottom: 8 })

      Button('确定')
        .fontSize(16)
        .width('100%')
        .onClick(() => {
          if (this.controller != undefined) {
            this.controller.close()
          }
        })
    }
    .padding({
      left: 24,
      right: 24,
      top: 16,
      bottom: 16
    })
  }
}


@Entry
@Component
struct ProxyPage {
  //系统颜色调用
  @State icon_emphasize: ResourceColor = $r('sys.color.icon_emphasize') //高亮图标，蓝色
  @State font_primary: ResourceColor = $r('sys.color.font_primary') //一级文本色，黑色
  @State font_secondary: ResourceColor = $r('sys.color.font_secondary') //二级文本色，深灰色
  @State font_on_primary: ResourceColor = $r('sys.color.font_on_primary') //一级文本反色，白色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  @State comp_divider: ResourceColor = $r('sys.color.comp_divider') //分割线颜色
  @State background_secondary: ResourceColor = $r('sys.color.background_secondary') //二级背景色，实色

  //长按菜单图标
  @State startIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.star')).fontSize('24vp');
  @State startIconModifier1: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.bolt_filled_on_circle')).fontSize('24vp');
  @State startIconModifier2: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.timer')).fontSize('24vp');
  @State startIconModifier3: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.questionmark_circle')).fontSize('24vp');
  @State container_background: ResourceColor = ($r('app.color.container_background'));
  @State currentIndex: number = 0;
  @State proxyGroup1List: ProxyData[] = createGroup1Data();
  @State isShowEdit: boolean = false
  @State isShowNetworkSpeed: boolean = false
  @StorageProp('bottomRectHeight')
  bottomRectHeight: number = 0;
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @StorageProp('topRectHeight') topRectHeight: number = 0;
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
  @State GridRowHeight: BreakpointState<string> = BreakpointState.of({
    xs: '715vp',
    sm: '715vp',
    md: '1050vp',
    lg: '550vp',
    xl: '550vp'
  });

  controller: webview.WebviewController = new webview.WebviewController();
  //弹窗
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogExample({
      cancel: () => {
        this.onCancel()
      },
      confirm: () => {
        this.onAccept()
      }
    }),
    cancel: this.existApp,
    autoCancel: true,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      console.info("reason=" + JSON.stringify(dismissDialogAction.reason))
      console.log("dialog onWillDismiss")
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
      }
    },
    alignment: DialogAlignment.Center,
    // offset: { dx: 0, dy: -20 },
    customStyle: false,
    cornerRadius: 32,
    gridCount: 4,
    backgroundColor: ($r('app.color.container_background')),
    maskColor: ($r('app.color.dialog_maskcolor')),
    // backgroundBlurStyle:BlurStyle.Thick
  })
  /*
       预留自定义主题，颜色在AppTheme里面修改
       onWillApplyTheme(theme: Theme) {
          this.backgroundPrimary = theme.colors.backgroundPrimary;
          this.fontPrimary = theme.colors.fontPrimary;
          this.iconOnPrimary = theme.colors.iconOnPrimary;
          this.iconFourth = theme.colors.iconFourth;
       }
   */
  @State private gridMargin: number = 0
  private tabsController: TabsController = new TabsController()

  // 在自定义组件即将析构销毁时将dialogController置空

  onCancel() {
    console.info('Callback when the first button is clicked')
  }

  onAccept() {
    console.info('Callback when the second button is clicked')
  }

  existApp() {
    console.info('Click the callback in the blank area')
  }

  aboutToAppear(): void {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.proxyPageMargin)
    BreakpointSystem.getInstance().attach(this.ListLanes)
    BreakpointSystem.getInstance().attach(this.ListGutter)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear(): void {
    this.dialogController = null // 将dialogController置空
  }

  @Builder
  BindSheetNetworkSpeed() {
    Row() {
      Column() {
        /*    Text('Webview')
              .fontSize(48)
            Text('访问https://speed.cloudflare.com')
              .fontSize(18)*/
        Web({ src: 'https://speed.cloudflare.com', controller: this.controller })//测速网页得重新换个
          .javaScriptAccess(true)
          .onlineImageAccess(true)
          .imageAccess(true)
          .domStorageAccess(true)
      }
    }
    .width('100%')
    .height('100%')
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    //   .padding({bottom:100})
    .backgroundColor(($r('app.color.container_background')))
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
              value: 'Radio', group: 'radioGroup1',
              indicatorType: RadioIndicatorType.TICK
            })
              .checked(true)
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
              value: 'Radio', group: 'radioGroup1',
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
              value: 'Radio', group: 'radioGroup2',
              indicatorType: RadioIndicatorType.TICK
            })
              .checked(true)
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
              value: 'Radio', group: 'radioGroup2',
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
              value: 'Radio', group: 'radioGroup2',
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
              value: 'Radio', group: 'radioGroup3',
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
              value: 'Radio', group: 'radioGroup3',
              indicatorType: RadioIndicatorType.TICK
            })
              .checked(true)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
                //   uncheckedBorderColor: this.icon_secondary
              })

          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .padding({ left: 15, right: 10 })
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({ bottom: 10 })
        .height(94)
        .borderRadius(20)
        .backgroundColor(($r('app.color.container_background')))
      }
    }
    .padding({ left: 16, right: 16 })
    .width('100%')
  }

  @Builder
  //长按菜单相关
  MyMenu() {
    Menu() {
      MenuItem({ symbolStartIcon: this.startIconModifier, content: "收藏" })
      MenuItem({ symbolStartIcon: this.startIconModifier1, content: "测速延迟" })
      MenuItem({ symbolStartIcon: this.startIconModifier2, content: "测试速度" })
        .onClick(() => {
          this.isShowNetworkSpeed = true
        })
      MenuItem({ symbolStartIcon: this.startIconModifier3, content: "速度和延迟的区别" })
        .onClick(() => {
          if (this.dialogController != null) {
            this.dialogController.open()
          }
        })
    }
    //分割线
    .menuItemDivider({ color: this.comp_divider, strokeWidth: LengthMetrics.vp(1) })
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
    this.proxyGroup1List.splice(index, 1, itemData)
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.Proxy'))
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
          .bindSheet($$this.isShowNetworkSpeed, this.BindSheetNetworkSpeed(), {
            detents: [SheetSize.LARGE, 200],
            backgroundColor: $r('app.color.settings_container_background'),
            //       blurStyle: BlurStyle.BACKGROUND_REGULAR,
            showClose: true,
            scrollSizeMode: ScrollSizeMode.CONTINUOUS,
            title: { title: "测试速度", subtitle: '测速功能由CloundFlare提供' },
            width: ('100%'),
            maskColor: $r('app.color.dialog_maskcolor')
            //onWillAppear:()
          })
        Blank()
        //编辑图标
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.square_and_pencil'))
            .fontSize(24)//      .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)//分层颜色
            .fontColor([this.icon_primary])
            .onClick(() => {
              this.isShowEdit = true
            })
        }
        .width(40)
        .height(40)
        .backgroundColor($r('app.color.settings_container_background'))
        .bindSheet($$this.isShowEdit, this.BindSheetEdit(), {
          detents: [SheetSize.LARGE, 200],
          backgroundColor: $r('app.color.background'),
          //  blurStyle: BlurStyle.BACKGROUND_REGULAR,
          showClose: true,
          scrollSizeMode: ScrollSizeMode.CONTINUOUS,
          title: { title: "编辑" },
          width: ('100%'),
          maskColor: $r('app.color.dialog_maskcolor')
        })
      }
      .padding({ left: this.proxyPageMargin.value, right: this.proxyPageMargin.value })
      .margin({ bottom: 9.5 })
      .width('98%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Top)

      Stack() {
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
                      .height(undefined)
                      .bindContextMenu(this.MyMenu, ResponseType.LongPress,
                        {
                          preview: MenuPreviewMode.IMAGE,
                          previewAnimationOptions: {
                            scale: [0.95, 1.0],
                            transition: TransitionEffect.prototype.animation({ tempo: 1.5 })
                          }
                        })
                    /*      .onClick(() => {
                             if (isChecked.checked) {
                               isChecked.triggerChange(false)
                             } else {
                               isChecked.triggerChange(true)
                             }
                           })*/
                  }
                  .padding({ bottom: 10, right: 32})
                })
              }
              .lanes(this.ListLanes.value)
              .scrollBar(BarState.Off)
              .width('100%')
              .height('100%')
              .edgeEffect(EdgeEffect.Spring)
              .offset({left:16})

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
          .barMode(BarMode.Scrollable)
          .barHeight(55)
          .fadingEdge(true)
          .onChange((index: number) => {
            this.currentIndex = index;
          })
        }
        .padding({bottom: 45 })

        NetworkSpeedButton().padding(this.isLandscapePhone ? '40vp' : { bottom: '40vp' })
      }
      .align(Alignment.BottomEnd)
    }
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.background'))
  }
}

export default ProxyPage