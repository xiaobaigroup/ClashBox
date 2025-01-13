import { hilog } from '@kit.PerformanceAnalysisKit'
import { BreakpointState, BreakpointSystem } from '../../common/breakpointsystem'
import {
  ANIMATION_DURATION_300,
  BIND_SHEET_CONTAINER_HEIGHT, LIST_ITEM_HEIGHT,
  TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE } from '../../common/Constants'
import { LengthMetrics, SymbolGlyphModifier,PromptAction } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import {  Item, ProxyData } from '../../common/ProxyData';


//断点布局
export const BPS_LIST_LANES_2_2_3_4_4: BreakpointState<number> = BreakpointState.of({
  xs: 2,
  sm: 2,
  md: 3,
  lg: 4,
  xl: 4,
  xxl: 5
})

/* 速度与延迟区别弹窗 */
@CustomDialog
struct ProxyCustomDialog {
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor

  controller?: CustomDialogController
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  build() {
    Column() {
      Text($r('app.string.Speed_Delay'))
        .fontSize(20)
        .padding({ bottom: 15 })
        .fontWeight(700)
      Text($r('app.string.Speed_Delay_Content'))
        .fontSize(16)
        .padding({ bottom: 8 })

      Button($r('app.string.Sure'))
        .fontSize(16)
        .width('100%')
        .onClick(() => {
          if (this.controller != undefined) {
            this.controller.close()
            this.isEnableIndexForegroundBlur=false
          }
        })
        .backgroundColor(this.icon_emphasize)
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

  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor

  /* 速度与延迟区别弹窗 */
  ProxyDialogController: CustomDialogController | null = new CustomDialogController({
    builder: ProxyCustomDialog({
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
    // maskColor: $r('app.color.dialog_maskcolor'),
    cancel: this.existApp,
    autoCancel: true,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      console.info("reason=" + JSON.stringify(dismissDialogAction.reason))
      console.log("dialog onWillDismiss")
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
        this.isEnableIndexForegroundBlur=false
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
        this.isEnableIndexForegroundBlur=false
      }
    },
  })

  /*长按菜单相关参数  */
  //长按菜单图标
  @State startIconModifier1: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.bolt_filled_on_circle')).fontSize('24vp');
  @State startIconModifier2: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.timer')).fontSize('24vp');
  @State startIconModifier3: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.questionmark_circle')).fontSize('24vp');

  //报错信息参数
  private componentName: string = 'ProxyPage'

  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  /* 是否开启全局动画判定 */
  @Consume ('isAnimation') isAnimation: boolean

  /* 断点布局相关 */
  @State
  private breakPointStateListLanes: BreakpointState<number> = BPS_LIST_LANES_2_2_3_4_4
  @Consume
  private breakPointStateListGutter: BreakpointState<number>

  /* 本页布局相关参数 */
  // 定义ProxyGroupItemSelectedWide的值便于切换布局方式
  @Consume ProxyGroupItemSelected: string
  //是否显示网络测速半模拟态判定
  @State isShowNetworkSpeed: boolean = false
  //网络测速半模拟态web控制器
  controller: webview.WebviewController = new webview.WebviewController();

  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean

  /* 代理节点数据相关参数  */
  //节点假数据组后期可改可删
  @Consume items: Item[]
  // 当前代理节点单选选择的值
  @Consume private ProxyRadioCheckedValue: number
  // 当前代理节点长按选择的值
  @Consume private ProxyItemLongPressValue: number
  // 当前代理节点收藏的值
  @Consume private FavoriteProxy: number

  aboutToAppear(): void {
    hilog.info(0xB000, this.componentName, `#aboutToAppear`)
    BreakpointSystem.getInstance().attach(this.breakPointStateListLanes)
    BreakpointSystem.getInstance().start()
  }

  //半模态窗口测速网站
  @Builder
  BindSheetNetworkSpeed() {
    Row() {
      Column() {
        Web({ src: 'https://speed.cloudflare.com', controller: this.controller })
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
  //收藏与ping延迟即时动作
  private ProxyPromptAction:PromptAction = this.getUIContext()?.getPromptAction()



  //长按菜单 start
  @Builder
  //长按菜单相关
  MyMenu(isShowFavoriteProxy:boolean) {
    Menu() {
      // 根据当前配置信息来判断显示[收藏 /取消收藏] 单独处理 START
      if (!isShowFavoriteProxy) {
        MenuItem({
          symbolStartIcon: this.proxyListLongPressCtxMenuForFavorite.symbolStartIcon!
            .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE),
          content: this.proxyListLongPressCtxMenuForFavorite.content
        })
          .clickEffect({level: ClickEffectLevel.MIDDLE})
          .contentFontColor($r('sys.color.font_primary'))
          .onClick(() => {
            this.proxyListLongPressCtxMenuForFavorite.callback()
            this.FavoriteProxy = this.ProxyItemLongPressValue
          })
      } else {
        MenuItem({
          symbolStartIcon: this.proxyListLongPressCtxMenuForUnFavorite.symbolStartIcon!
            .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE),
          content: this.proxyListLongPressCtxMenuForUnFavorite.content
        })
          .clickEffect({level: ClickEffectLevel.MIDDLE})
          .contentFontColor($r('sys.color.font_primary'))
          .onClick( () => {
            this.proxyListLongPressCtxMenuForUnFavorite.callback()
            this.FavoriteProxy =-1
          })
      }
      MenuItem({ symbolStartIcon: this.startIconModifier1, content: $r('app.string.Test_Delay') })
        .onClick(()=>{this.ProxyPromptAction.showToast({ message: $r('app.string.Test_Delay_Tip') })})
      MenuItem({ symbolStartIcon: this.startIconModifier2, content: $r('app.string.Test_Speed') })
        .onClick(() => {
          this.isShowNetworkSpeed = true
          this.isEnableIndexForegroundBlur=true
        })
      MenuItem({ symbolStartIcon: this.startIconModifier3, content: $r('app.string.Delay_Speed') })
        .onClick(() => {
          if (this.ProxyDialogController != null) {
            this.ProxyDialogController.open()
            this.isEnableIndexForegroundBlur=true
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
                Text(`${item.text}`).ItemTextStyle()
                Text(`${item.type}`).ItemTypeStyle()

                Blank(10)
                Text(`${item.latency}` + 'ms')
                  .fontColor(ProxyData.getColorForLatency(item.latency))
                  .fontSize(16)
              }.alignItems(HorizontalAlign.Start)
              Blank()
              Radio({ value: 'ProxyRadio' + index, group: 'ProxyGroup' })
                .checked(index === this.ProxyRadioCheckedValue)
                .radioStyle({
                  checkedBackgroundColor: this.icon_emphasize,
                })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.ProxyRadioCheckedValue = index
                  }
                })
            }
            .ListRowStyle()
          }
          .onClick(() => {
            this.ProxyRadioCheckedValue = index
            hilog.info(0xB002, this.componentName, `#ListItem#onClick: `)
          })
          .ListItemStyle()
          .height(LIST_ITEM_HEIGHT + 32)
          .bindContextMenu(this.MyMenu(item?.isShowFavoriteProxy ?? false), ResponseType.LongPress,
            {
              preview: MenuPreviewMode.IMAGE,
              onAppear: (() => {
                this.ProxyItemLongPressValue=index
              }),
              previewAnimationOptions: {
                scale: [0.95, 1.0],
                transition: this.isAnimation ?TransitionEffect.prototype.animation({ tempo: 1.5 }):null
              },
            })
        })
      }
      .ListStyle()
      .transition(this.isAnimation ? TransitionEffect.OPACITY:null)
      .lanes(this.breakPointStateListLanes.value, this.breakPointStateListGutter.value)
      // .divider({ strokeWidth: 1,color:$r('app.color.divider'),startMargin:16,endMargin:16})
      .bindSheet($$this.isShowNetworkSpeed, this.BindSheetNetworkSpeed(), {
        detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.FIT_CONTENT,],
        preferType: SheetType.CENTER,
        backgroundColor: $r('app.color.settings_container_background'),
        showClose: true,
        scrollSizeMode: ScrollSizeMode.CONTINUOUS,
        title: { title: $r('app.string.Test_Speed'), subtitle:$r('app.string.Test_Speed_Explain')  },
        //  maskColor: $r('app.color.dialog_maskcolor'),
        onWillDismiss: () => {
          this.isShowNetworkSpeed = false
          this.isEnableIndexForegroundBlur = false
        }
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
                  Text(`${item.text}`).ItemTextStyle()
                  Text(`${item.type}`).ItemTypeStyle()
                }.alignItems(HorizontalAlign.Start)

                Text(`${item.latency}` + 'ms')
                  .fontColor(ProxyData.getColorForLatency(item.latency))
                  .fontSize(16)
              }.width('90%')
              .justifyContent(FlexAlign.SpaceBetween)

              Blank()
              Radio({ value: 'ProxyRadio' + index, group: 'ProxyGroup' })
                .checked(index === this.ProxyRadioCheckedValue)
                .radioStyle({
                  checkedBackgroundColor: this.icon_emphasize,
                })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.ProxyRadioCheckedValue = index
                  }
                })
            }
            .ListRowStyle()
          }
          .onClick(() => {
            this.ProxyRadioCheckedValue = index
            hilog.info(0xB002, this.componentName, `#ListItem#onClick: `)
          })
          .ListItemStyle()
          .height(LIST_ITEM_HEIGHT)
          .bindContextMenu(this.MyMenu(item?.isShowFavoriteProxy ?? false), ResponseType.LongPress,
            {
              preview: MenuPreviewMode.IMAGE,
              placement: Placement.BottomRight,
              onAppear: (() => {
                this.ProxyItemLongPressValue=index
              }),
              previewAnimationOptions: {
                scale: [0.95, 1.0],
                transition:  this.isAnimation ?TransitionEffect.prototype.animation({ tempo: 1.5 }):null
              }
            })
        })
      }
      .ListStyle()
      .transition(this.isAnimation ? TransitionEffect.OPACITY:null)
      .bindSheet($$this.isShowNetworkSpeed, this.BindSheetNetworkSpeed(), {
        detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.FIT_CONTENT,],
        preferType: SheetType.CENTER,
        backgroundColor: $r('app.color.settings_container_background'),
        showClose: true,
        scrollSizeMode: ScrollSizeMode.CONTINUOUS,
        title: { title: $r('app.string.Test_Speed'), subtitle: '测速功能由CloundFlare提供' },
        //   maskColor: $r('app.color.dialog_maskcolor'),
        onWillDismiss: () => {
          this.isShowNetworkSpeed = false
          this.isEnableIndexForegroundBlur = false
        }
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
                Text(`${item.text}`).ItemTextStyle()
                Row() {
                  Text(`${item.type}`).ItemTypeStyle().maxLines(1).width(50).textOverflow({ overflow: TextOverflow.Clip})
                  Text(`${item.latency}` + 'ms')
                    .fontColor(ProxyData.getColorForLatency(item.latency))
                    .fontSize(14)
                }.justifyContent(FlexAlign.Start)
              }
              .alignItems(HorizontalAlign.Start)

              Blank()
              Radio({ value: 'ProxyRadio' + index, group: 'ProxyGroup' })
                .checked(index === this.ProxyRadioCheckedValue)
                .radioStyle({
                  checkedBackgroundColor: this.icon_emphasize,
                })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.ProxyRadioCheckedValue = index
                  }
                })
            }
            .ListRowStyle()
          }
          .onClick(() => {
            this.ProxyRadioCheckedValue = index
            hilog.info(0xB002, this.componentName, `#ListItem#onClick: `)
          })
          .ListItemStyle()
          .height(LIST_ITEM_HEIGHT)
          .bindContextMenu(this.MyMenu(item?.isShowFavoriteProxy ?? false), ResponseType.LongPress,
            {
              preview: MenuPreviewMode.IMAGE,
              onAppear: (() => {
                this.ProxyItemLongPressValue=index
              }),
              previewAnimationOptions: {
                scale: [0.95, 1.0],
                transition:  this.isAnimation ?TransitionEffect.prototype.animation({ tempo: 1.5 }):null
              }
            })
        })
      }
      .lanes(this.breakPointStateListLanes.value, this.breakPointStateListGutter.value)
      .ListStyle()
      .transition(this.isAnimation ? TransitionEffect.OPACITY:null)
      .bindSheet($$this.isShowNetworkSpeed, this.BindSheetNetworkSpeed(), {
        detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.FIT_CONTENT, ],
        preferType: SheetType.CENTER,
        backgroundColor: $r('app.color.settings_container_background'),
        showClose: true,
        scrollSizeMode: ScrollSizeMode.CONTINUOUS,
        title: { title: $r('app.string.Test_Speed'), subtitle: '测速功能由CloundFlare提供' },
        //     maskColor: $r('app.color.dialog_maskcolor'),
        onWillDismiss: () => {
          this.isShowNetworkSpeed = false
          this.isEnableIndexForegroundBlur = false
        }
      })
    }
  }

  private proxyListLongPressCtxMenuForFavorite: LongPressContextMenuItem = {
    symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.star'))
      .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
    content: '收藏', callback: ()=>{ this.favoriteProxy() }
  }
  private proxyListLongPressCtxMenuForUnFavorite: LongPressContextMenuItem = {
    symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.star_fill'))
      .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.multi_color_11')]),
    content: '取消收藏', callback: ()=>{ this.cancelFavoriteProxy() }
  }
  /**
   * 收藏配置
   */
  private favoriteProxy(): void {
    // TODO 收藏节点 & 判断是否已经收藏
    this.ProxyPromptAction.showToast({ message: $r('app.string.Collect_Tip') })
    this.items[this.ProxyItemLongPressValue].isShowFavoriteProxy = true
  }
  /**
   * 取消收藏配置
   */
  private cancelFavoriteProxy(): void {
    // TODO 取消收藏节点 & 判断是否已经收藏
    this.ProxyPromptAction.showToast({ message: $r('app.string.uncollected_tip') })
    this.items[this.ProxyItemLongPressValue].isShowFavoriteProxy = false
  }
}
/**
 * 长按菜单参数
 */
interface LongPressContextMenuItem {
  symbolStartIcon?: SymbolGlyphModifier,
  symbolEndIcon?: SymbolGlyphModifier,
  content: ResourceStr
  callback : Callback<void>
}

  //list公用样式
  @Extend(List)
  function ListStyle() {
    // transition保证组件离场不被立即析构，可设置其他转场效果
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .contentEndOffset(110)
  }

  //ListItem公用样式
  @Extend(ListItem)
  function ListItemStyle() {
    .clickEffect({ level: ClickEffectLevel.MIDDLE })
    .borderRadius(20)
    .backgroundColor($r('app.color.container_background'))
    .width('100%')
  }

  //List中Row公用样式
  @Extend(Row)
  function ListRowStyle() {
    .width('100%')
    .padding({ left: 14, right:8})
    .alignItems(VerticalAlign.Center)
  }

  //Item中text（节点国家）公用样式
  @Extend(Text)
  function ItemTextStyle() {
    .fontColor(($r('sys.color.font_primary')))
    .fontSize(18)
    .fontWeight(FontWeight.Medium)
  }

  //Item中type（节点类型）公用样式
  @Extend(Text)
  function ItemTypeStyle() {
    .fontColor($r('sys.color.font_secondary'))
    .fontSize(14)
  }



  export default ProxyGroupItem
