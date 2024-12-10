import { BreakpointState, BreakpointSystem } from '../common/breakpointsystem'
import {
  TAB_CONTENT_TITLE_FONT_SIZE,
  TAB_CONTENT_TITLE_FONT_WEIGHT,
  BPS_LIST_LANES_1_1_2_3_4,
  BPS_LIST_GUTTER_1_1_2_3_3,
  BPS_TAB_CONTENT_TITLE_MARGIN_12_13_28_36,
  ANIMATION_DURATION_300,
  TAB_CONTENT_TITLE_HEIGHT,
  TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE,
  LIST_ITEM_HEIGHT,
} from '../common/Constants'
import {  LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Callback } from '@ohos.base'
import { IntentionCode } from '@kit.InputKit'
import { webview } from '@kit.ArkWeb'

// 定义一个接口来描述列表项的数据结构,假数据，后期可改可删
interface Item {
  text: string;
  latency: number;
  type:string
}//

//自定义弹窗内容
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

//自定义弹窗内容end

//import { ThemeControl } from '@ohos.arkui.theme'
//import { gAppTheme } from './AppTheme'

// 在页面build前执行ThemeControl，就可以改变主题颜色
//ThemeControl.setDefaultTheme(gAppTheme)

@Entry
@Component
struct ProxyPage1 {
  /* 预留自定义主题，颜色在AppTheme里面修改
 onWillApplyTheme(theme: Theme) {
    this.backgroundPrimary = theme.colors.backgroundPrimary;
    this.fontPrimary = theme.colors.fontPrimary;
    this.iconOnPrimary = theme.colors.iconOnPrimary;
    this.iconFourth = theme.colors.iconFourth;
 } */
  //tabs图标文字颜色，修改resources/base(dark)/element/color.json中tabs_icon_text配置选中图标文字深浅模式颜色
  //系统颜色调用
  @State icon_emphasize: ResourceColor = $r('sys.color.icon_emphasize') //高亮图标，蓝色
  @State font_primary: ResourceColor = $r('sys.color.font_primary') //一级文本色，黑色
  @State font_secondary: ResourceColor = $r('sys.color.font_secondary') //二级文本色，深灰色
  @State container_background: ResourceColor = ($r('app.color.container_background')); //卡片颜色
  /* 配置列表List相关 */
  @State font_on_primary: ResourceColor = $r('sys.color.font_on_primary') //一级文本反色，白色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  /* ContextMenu */
  @State comp_divider: ResourceColor = $r('sys.color.comp_divider') //分割线颜色
  @State background_secondary: ResourceColor = $r('sys.color.background_secondary') //二级背景色，实色
  /* Stack层叠布局 */
  // 所有子组件在容器内的对齐方式 TODO 【用户首选项】在设置里可以更改 Alignment.BottomStart 和 Alignment.BottomEnd Enlin@2024-12-04
  @State
  stackAlignContentAlignment: Alignment = Alignment.BottomEnd
  //编辑按钮点击
  @State isShowEdit: boolean = false
  //分组tabs相关
  @State currentIndex: number = 0;
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
  //长按菜单图标
  @State startIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.star')).fontSize('24vp');
  @State startIconModifier1: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.bolt_filled_on_circle')).fontSize('24vp');
  @State startIconModifier2: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.timer')).fontSize('24vp');
  @State startIconModifier3: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.questionmark_circle')).fontSize('24vp');
  @State isShowNetworkSpeed: boolean = false
  /* 断点布局相关 */
  @State
  private breakPointStateListLanes: BreakpointState<number> = BPS_LIST_LANES_1_1_2_3_4
  @State
  private breakPointStateListGutter: BreakpointState<number> = BPS_LIST_GUTTER_1_1_2_3_3
  /* 配置列表List相关 */
  @State
  private breakPointStateTabContentTitleMargin: BreakpointState<number> = BPS_TAB_CONTENT_TITLE_MARGIN_12_13_28_36
  // 当前手指触摸的ListItem的对应 this.configList[index]
  @State
  private TouchPorxyListIndex: number = -1
  @State private gridMargin: number = 0
  private tabsController: TabsController = new TabsController()
  // 当前单选框选择的配置
  @State
  private PorxyRadioCheckedValue: number = -1

  // TODO 删除 临时模拟数据配置列表数据
  // 显式声明状态变量的类型，假数据组后期可改可删
  @State items: Item[] = [
    { text: '越南①', latency: 20 ,type:'Vmess'},
    { text: '越南②', latency: 500 ,type:'Shadowsocks'},
    { text: '北朝鲜①', latency: 501,type:'Vmess' },
    { text: '中国香港①', latency: 20 ,type:'Trojan'},
    { text: '中国香港②', latency: 1001,type:'Vmess' },
    { text: '中国台湾①', latency: 501, type:'Shadowsocks'},
    { text: '中国台湾②', latency: 20, type:'Vmess'},
    { text: '越南②', latency: 500, type:'Trojan'},
    { text: '美国①', latency: 1001, type:'Shadowsocks'},
  ];


  // 排序函数
  sortItems() {
    this.items.sort((a, b) => a.latency - b.latency);
  }

  // 辅助函数：根据单个Item的latency属性返回颜色
  private getColorForLatency(latency: number): string | ResourceColor {
    if (latency >= 0 && latency <= 500) {
      return '#64BB5C';
    } else if (latency >= 501 && latency <= 1000) {
      return '#f7ce00';
    } else if (latency > 1000) { // 注意这里使用>而不是>=，以避免重叠
      return '#e84026';
    } else {
      return $r('sys.color.font_secondary'); // 默认颜色
    }
  }


  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')
  private isLandscapePhone: boolean = false

  // 按钮宽度
  private proxyStartButtonWidth: Length = $r('app.integer.vp_proxy_not_start_button_width')

  //半模拟态 end
  // 按钮高度
  private proxyStartButtonHeight: Length = $r('app.integer.vp_proxy_not_start_button_height')
  // 按钮Margin
  private proxyStartButtonMargin: Length = $r('app.integer.vp_proxy_start_button_margin')
  // 按钮前Symbol动效
  private ReplaceSymbolEffect: SymbolEffect = EffectScope.WHOLE
  //定义组件名
  private componentName: string = 'ProxyPage'

  //假数据延迟颜色设置
  @State color: ResourceColor = $r('sys.color.font_secondary')
  //栅格点位配置
  aboutToAppear(): void {
    hilog.info(0xB000, this.componentName, `#aboutToAppear`)
    BreakpointSystem.getInstance().attach(this.breakPointStateListLanes)
    BreakpointSystem.getInstance().attach(this.breakPointStateListGutter)
    BreakpointSystem.getInstance().attach(this.breakPointStateTabContentTitleMargin)
    BreakpointSystem.getInstance().start()
  }

  //分组tans内容
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
    .height(55)
    .margin({ right: 8, bottom: 10 })
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(this.currentIndex);
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
  }

  @State private isClickable: boolean = false; // 控制按钮是否可点击
  @Builder
  //半模拟态编辑菜单
  ProxyBindSheetEdit() {
    Column() {
      Text($r('app.string.Packet_mode'))
        .width('100%')
        .fontSize(16)
        .fontColor(this.font_secondary)
        .padding({ left: 15, bottom: 10 })
        .textAlign(0)

      Column() {
        Row() {
          Text($r('app.string.Tabs'))
            .font({ size: 16 })
            .fontColor(this.font_primary)

          Radio({
            value: 'Radio1', group: 'radioGroup1',
            indicatorType: RadioIndicatorType.TICK,
          })
            .checked(this.isClickable)
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
          /* 选中改变，后期接入
          .onChange((isChecked: boolean) => {
            if (isChecked) {
              promptAction.showToast({ message: 'Vibration mode.' })
            }
          })*/
        }
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Divider().strokeWidth(0.7).color(this.comp_divider).padding({ left: 5, right: 10 })

        Row() {
          Text($r('app.string.List'))
            .font({ size: 16 })
            .fontColor(this.font_primary)

          Radio({
            value: 'Radio2', group: 'radioGroup1',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(false)
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
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

      Text($r('app.string.Arrangement'))
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
            value: 'Radio3', group: 'radioGroup2',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(false)
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Divider().strokeWidth(0.7).color(this.comp_divider).padding({ left: 5, right: 10 })

        Row() {
          Text($r('app.string.Delay'))
            .font({ size: 16 })
            .fontColor(this.font_primary)

          Radio({
            value: 'Radio4', group: 'radioGroup2',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(false)
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        .onClick(() => this.sortItems())//按延迟排序
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Divider().strokeWidth(0.7).color(this.comp_divider).padding({ left: 5, right: 10 })


        Row() {
          Text($r('app.string.Name'))
            .font({ size: 16 })
            .fontColor(this.font_primary)

          Radio({
            value: 'Radio5', group: 'radioGroup2',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(false)
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
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


      Text($r('app.string.Layout'))
        .width('100%')
        .fontSize(16)
        .fontColor(this.font_secondary)
        .padding({ left: 15, bottom: 10 })
        .textAlign(0)

      Column() {
        Row() {
          Text($r('app.string.Relax'))
            .font({ size: 16 })
            .fontColor(this.font_primary)

          Radio({
            value: 'Radio6', group: 'radioGroup3',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(false)
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Divider().strokeWidth(0.7).color(this.comp_divider).padding({ left: 5, right: 10 })

        Row() {
          Text($r('app.string.Compact'))
            .font({ size: 16 })
            .fontColor(this.font_primary)

          Radio({
            value: 'Radio7', group: 'radioGroup3',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(false)
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })

        }
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
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
    .padding({ left: 16, right: 16 })
    .width('100%')
  }//半模拟态编辑菜单end

//半模拟态网络测速
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
  }//半模拟态网络测速 end

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

  //长按菜单 start
  @Builder
  //长按菜单相关
  MyMenu() {
    Menu() {
      MenuItem({ symbolStartIcon: this.startIconModifier, content: $r('app.string.Collect') })
      MenuItem({ symbolStartIcon: this.startIconModifier1, content: $r('app.string.Test_Delay') })
      MenuItem({ symbolStartIcon: this.startIconModifier2, content: $r('app.string.Test_Speed') })
        .onClick(() => {
          this.isShowNetworkSpeed = true
        })
      MenuItem({ symbolStartIcon: this.startIconModifier3, content: $r('app.string.Delay_Speed') })
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
  //长按菜单end


  build() {
    Column() {
      // 标题栏
      if (!this.isLandscapePhone) {
        Row() {
          Text($r('app.string.Proxy'))
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .bindSheet($$this.isShowNetworkSpeed, this.BindSheetNetworkSpeed(), {
              detents: [684, SheetSize.FIT_CONTENT],
              backgroundColor: $r('app.color.settings_container_background'),
              //       blurStyle: BlurStyle.BACKGROUND_REGULAR,
              showClose: true,
              scrollSizeMode: ScrollSizeMode.CONTINUOUS,
              title: { title: $r('app.string.Test_Speed'), subtitle: '测速功能由CloundFlare提供' },
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
          }
          .width(40)
          .height(40)
          .backgroundColor($r('app.color.settings_container_background'))
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
          .onClick(() => {
            this.isShowEdit = true
            hilog.info(0xB001, this.componentName, `#button#onClick()#编辑代理`)
          })
          .bindSheet($$this.isShowEdit, this.ProxyBindSheetEdit(), {
            detents: [684, SheetSize.FIT_CONTENT],
            backgroundColor: $r('app.color.background'),
            //  blurStyle: BlurStyle.BACKGROUND_REGULAR,
            showClose: true,
            scrollSizeMode: ScrollSizeMode.CONTINUOUS,
            title: { title: $r('app.string.Edit') },
            width: ('100%'),
            maskColor: $r('app.color.dialog_maskcolor')
          })
        }
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .height(TAB_CONTENT_TITLE_HEIGHT)
        .padding({
          left: this.breakPointStateTabContentTitleMargin.value,
          right: this.breakPointStateTabContentTitleMargin.value,
        })
      }


      // 代理页分组TAB+list主体
      Stack({ alignContent: this.stackAlignContentAlignment }) {
        Column() { //分组标签页 start
          Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
            TabContent() {
              // 节点列表 START
              List({ space: 10 }) {
                ForEach(this.items, (item: Item, index: number) => {
                  ListItem() {
                    Row() {
                      Row() {
                        Column() {
                          Text(`${item.text}`).fontColor(($r('sys.color.font_primary'))).fontSize(20)
                          Text(`${item.type}`).fontColor($r('sys.color.font_secondary')).fontSize(14)
                        }.alignItems(HorizontalAlign.Start)

                        Text(`${item.latency}`+'ms').fontColor(this.getColorForLatency(item.latency) as ResourceColor).fontSize(18)
                      }
                      .width('90%')
                      .justifyContent(FlexAlign.SpaceBetween)


                      Blank()
                      Radio({ value: 'radio' + index, group: 'configGroup' })
                        .checked(index === this.PorxyRadioCheckedValue)
                    }
                    .width('100%')
                    .padding({ left: 12, right: 12 })
                    .alignItems(VerticalAlign.Center)
                  }
                  .onClick(() => {
                    this.PorxyRadioCheckedValue = index
                    hilog.info(0xB002, this.componentName, `#ListItem#onClick: `)
                  })
                  .backgroundColor($r('app.color.container_background'))
                  .width('100%')
                  .height(LIST_ITEM_HEIGHT)
                  .clickEffect({ level: ClickEffectLevel.MIDDLE })
                  .borderRadius(20)
                  .bindContextMenu(this.MyMenu, ResponseType.LongPress,
                    {
                      preview: MenuPreviewMode.IMAGE,
                      previewAnimationOptions: {
                        scale: [0.95, 1.0],
                        transition: TransitionEffect.prototype.animation({ tempo: 1.5 })
                      }
                    })
                })
              }
              .width('100%')
              .height('100%')
              .contentEndOffset(110)
              .lanes(this.breakPointStateListLanes.value, this.breakPointStateListGutter.value)
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
              .chainAnimation(true)
              .padding({
                left: this.breakPointStateTabContentTitleMargin.value,
                right: this.breakPointStateTabContentTitleMargin.value,
              })

              //list end
            }
            // 节点列表 END

            //TODO 删除 临时模拟分组数据
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
            .tabBar(this.TabBuilder('分组8', 7))
          }
          .barMode(BarMode.Scrollable)
          .barHeight(55)
          .fadingEdge(true)
          .onChange((index: number) => {
            this.currentIndex = index;
          })
        }

        //分组tabs end

        // 悬浮新增配置按钮 START
        Button() {
          Stack({ alignContent: Alignment.Center }) {
            SymbolGlyph($r('sys.symbol.bolt_filled_on_circle'))
              .fontSize(24)
              .fontColor([Color.White])
              .symbolEffect(this.ReplaceSymbolEffect)
              .align(Alignment.Center)
          }.width('100%')
        }
        .shadow({
          radius: 10,
          color: $r('app.color.speed_down_icon'),
          offsetY: 4,
          type: ShadowType.BLUR
        })
        .margin(this.proxyStartButtonMargin)
        .width(this.proxyStartButtonWidth)
        .height(this.proxyStartButtonHeight)
        .clip(true)
        .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Ease })
        .clickEffect({ level: ClickEffectLevel.MIDDLE })

        // 悬浮新增配置按钮 END
      }
      .backgroundColor($r('app.color.background'))
      // .padding(this.isLandscapePhone ? '0vp' : { bottom: '45vp' })
      .width('100%')
      .height(this.isLandscapePhone ? '100%' : `calc(100% - ${TAB_CONTENT_TITLE_HEIGHT}vp)`)

      // 主体 END
    }
    .width('100%')
    .height('100%')

  }
}


export default ProxyPage1