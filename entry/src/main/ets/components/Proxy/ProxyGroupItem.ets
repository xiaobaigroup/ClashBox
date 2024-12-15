import { hilog } from '@kit.PerformanceAnalysisKit'
import { BreakpointState, BreakpointSystem } from '../../common/breakpointsystem'
import { BIND_SHEET_CONTAINER_HEIGHT, LIST_ITEM_HEIGHT } from '../../common/Constants'
import { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

//断点布局
export const BPS_LIST_LANES_2_2_3_4_4: BreakpointState<number> = BreakpointState.of({
  xs: 2,
  sm: 2,
  md: 3,
  lg: 4,
  xl: 4,
  xxl: 5
})

// 定义一个接口来描述列表项的数据结构,假数据，后期可改可删
interface Item {
  text: string;
  latency: number;
  type: string
} //

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
    .backgroundColor($r('app.color.container_background'))
    .padding({
      left: 24,
      right: 24,
      top: 16,
      bottom: 16
    })
  }
}

//自定义弹窗内容end

@Entry
@Component
struct ProxyGroupItem {
  // 显式声明状态变量的类型，假数据组后期可改可删
  @State items: Item[] = [
    { text: '越南①', latency: 20, type: 'Vmess' },
    { text: '越南②', latency: 500, type: 'Shadowsocks' },
    { text: '北朝鲜①', latency: 501, type: 'Vmess' },
    { text: '中国香港①', latency: 20, type: 'Trojan' },
    { text: '中国香港②', latency: 1001, type: 'Vmess' },
    { text: '中国台湾①', latency: 501, type: 'Shadowsocks' },
    { text: '中国台湾②', latency: 20, type: 'Vmess' },
    { text: '越南②', latency: 500, type: 'Trojan' },
    { text: '美国①', latency: 1001, type: 'Shadowsocks' },
  ];
  controller: webview.WebviewController = new webview.WebviewController();
  //弹窗
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogExample({
      cancel: () => {
        this.onCancel()
      },
      confirm: () => {
        this.onAccept()
      },
    }),
    alignment: DialogAlignment.Center,
    // offset: { dx: 0, dy: -20 },
    customStyle: false,
    cornerRadius: 32,
    gridCount: 4,
    maskColor: $r('app.color.dialog_maskcolor'),
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
  })
  //长按菜单图标
  @State startIconModifier: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.star')).fontSize('24vp');
  @State startIconModifier1: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.bolt_filled_on_circle')).fontSize('24vp');
  @State startIconModifier2: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.timer')).fontSize('24vp');
  @State startIconModifier3: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.questionmark_circle')).fontSize('24vp');
  // TODO 删除 临时模拟数据配置列表数据
  @State isShowNetworkSpeed: boolean = false
  // 定义ProxyGroupItemSelectedWide的值便于切换布局方式
  @Consume ProxyGroupItemSelected: string

  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')
  private isLandscapePhone: boolean = false
  /* 断点布局相关 */
  @State
  private breakPointStateListLanes: BreakpointState<number> = BPS_LIST_LANES_2_2_3_4_4
  @Consume
  private breakPointStateListGutter: BreakpointState<number>
  private componentName: string = 'ProxyPage'
  // 当前单选框选择的配置
  @State
  private PorxyRadioCheckedValue: number = -1

  aboutToAppear(): void {
    hilog.info(0xB000, this.componentName, `#aboutToAppear`)
    BreakpointSystem.getInstance().attach(this.breakPointStateListLanes)
    BreakpointSystem.getInstance().start()
  }

  // 排序函数
  sortItems() {
    this.items.sort((a, b) => a.latency - b.latency);
  }

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
  } //半模拟态网络测速 end

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
    .menuItemDivider({ color: $r('app.color.divider'), strokeWidth: LengthMetrics.vp(1) })
    .backgroundColor($r('app.color.container_background'))
    .borderRadius(20)
  } //长按菜单end

  build() {
    //多列排列宽
    if (this.ProxyGroupItemSelected === 'ProxyGroupItemSelectedWide') {
      // 节点列表 START
      List({ space: 10, initialIndex: 0 }) {
        ForEach(this.items, (item: Item, index: number) => {
          ListItem() {
            Row() {

              Column() {
                Text(`${item.text}`)
                  .fontColor(($r('sys.color.font_primary')))
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                Text(`${item.type}`).fontColor($r('sys.color.font_secondary')).fontSize(14)

                Blank(10)
                Text(`${item.latency}` + 'ms')
                  .fontColor(this.getColorForLatency(item.latency) as ResourceColor)
                  .fontSize(16)
              }.width('90%').alignItems(HorizontalAlign.Start)


              Blank()
              Radio({ value: 'radio' + index, group: 'configGroup' })
                .checked(index === this.PorxyRadioCheckedValue)
            }
            .width('100%')
            .padding({ left: 14, right: 16 })
            .alignItems(VerticalAlign.Center)

          }
          .onClick(() => {
            this.PorxyRadioCheckedValue = index
            hilog.info(0xB002, this.componentName, `#ListItem#onClick: `)
          })
          .backgroundColor($r('app.color.container_background'))
          //  .width('100%')
          .height(LIST_ITEM_HEIGHT + 20)
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
      .scrollBar(BarState.Off)
      .alignListItem(ListItemAlign.Center)
      .lanes(this.breakPointStateListLanes.value, this.breakPointStateListGutter.value)
      // .divider({ strokeWidth: 1,color:$r('app.color.divider'),startMargin:16,endMargin:16})
      .bindSheet($$this.isShowNetworkSpeed, this.BindSheetNetworkSpeed(), {
        detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.FIT_CONTENT,],
        backgroundColor: $r('app.color.settings_container_background'),
        showClose: true,
        scrollSizeMode: ScrollSizeMode.CONTINUOUS,
        title: { title: $r('app.string.Test_Speed'), subtitle: '测速功能由CloundFlare提供' },
        width: ('100%'),
        maskColor: $r('app.color.dialog_maskcolor')
      })
    }
    //单列排列
    else if (this.ProxyGroupItemSelected === 'ProxyGroupItemSelectedThin') {
      // 节点列表 START
      List({ space: 10, initialIndex: 0 }) {
        ForEach(this.items, (item: Item, index: number) => {
          ListItem() {
            Row() {
              Row() {
                Column() {
                  Text(`${item.text}`).fontColor(($r('sys.color.font_primary'))).fontSize(18).fontWeight(FontWeight.Medium)
                  Text(`${item.type}`).fontColor($r('sys.color.font_secondary')).fontSize(14)
                }.alignItems(HorizontalAlign.Start)

                Text(`${item.latency}` + 'ms')
                  .fontColor(this.getColorForLatency(item.latency) as ResourceColor)
                  .fontSize(16)
              }
              .width('90%')
              .justifyContent(FlexAlign.SpaceBetween)


              Blank()
              Radio({ value: 'radio' + index, group: 'configGroup' })
                .checked(index === this.PorxyRadioCheckedValue)
            }
            .width('100%')
            .padding({ left: 14, right: 16 })
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
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .bindSheet($$this.isShowNetworkSpeed, this.BindSheetNetworkSpeed(), {
        detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.FIT_CONTENT,],
        backgroundColor: $r('app.color.settings_container_background'),
        showClose: true,
        scrollSizeMode: ScrollSizeMode.CONTINUOUS,
        title: { title: $r('app.string.Test_Speed'), subtitle: '测速功能由CloundFlare提供' },
        width: ('100%'),
        maskColor: $r('app.color.dialog_maskcolor')
      })
    }

    //迷你排列
    else if (this.ProxyGroupItemSelected === 'ProxyGroupItemSelectedMini') {
      // 节点列表 START
      List({ space: 10, initialIndex: 0 }) {
        ForEach(this.items, (item: Item, index: number) => {
          ListItem() {
            Row() {
              Column() {
                Text(`${item.text}`).fontColor(($r('sys.color.font_primary'))).fontSize(18).fontWeight(FontWeight.Medium)
                Row() {
                  Text(`${item.type}`).fontColor($r('sys.color.font_secondary')).fontSize(14).maxLines(1).width(50).textOverflow({ overflow: TextOverflow.Clip})
                  Text(`${item.latency}` + 'ms')
                    .fontColor(this.getColorForLatency(item.latency) as ResourceColor)
                    .fontSize(14)
                }.justifyContent(FlexAlign.Start)
              }
              .width('90%')
              .alignItems(HorizontalAlign.Start)


              Blank()
              Radio({ value: 'radio' + index, group: 'configGroup' })
                .checked(index === this.PorxyRadioCheckedValue)
            }
            .width('100%')
            .padding({ left: 14, right: 16 })
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
      .lanes(this.breakPointStateListLanes.value, this.breakPointStateListGutter.value)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .bindSheet($$this.isShowNetworkSpeed, this.BindSheetNetworkSpeed(), {
        detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.FIT_CONTENT,],
        backgroundColor: $r('app.color.settings_container_background'),
        showClose: true,
        scrollSizeMode: ScrollSizeMode.CONTINUOUS,
        title: { title: $r('app.string.Test_Speed'), subtitle: '测速功能由CloundFlare提供' },
        width: ('100%'),
        maskColor: $r('app.color.dialog_maskcolor')
      })
    }
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
}

export default ProxyGroupItem
