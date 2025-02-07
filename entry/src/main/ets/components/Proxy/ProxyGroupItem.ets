import { hilog } from '@kit.PerformanceAnalysisKit'
import { BreakpointState, BreakpointSystem } from '../../common/breakpointsystem'
import {
  BIND_SHEET_CONTAINER_HEIGHT, LIST_ITEM_HEIGHT,
  TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE } from '../../common/Constants'
import { LengthMetrics, SymbolGlyphModifier,PromptAction } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import {  ProxyItem, ProxyData } from '../../common/ProxyData';
import { EventHub, EventKey } from '../../common/EventHub';
import { ProxySort } from 'proxy_core';
import { intl } from '@kit.LocalizationKit';
import { AppConfig, ProxyCardSize, UIConfig } from '../../entryability/AppState';
import ClashViewModel from '../../entryability/ClashViewModel';
import { ProxyNode } from './ProxyItem';


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

//中文排序
let ProxyCollator = new intl.Collator("zh-CN");

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

  /* 断点布局相关 */
  @State
  private breakPointStateListLanes: BreakpointState<number> = BPS_LIST_LANES_2_2_3_4_4
  @Consume
  private breakPointStateListGutter: BreakpointState<number>

  /* 本页布局相关参数 */
  // 定义ProxyGroupItemSelectedWide的值便于切换布局方式
  @Prop ProxyGroupItemSelected: ProxyCardSize
  //是否显示网络测速半模拟态判定
  @State isShowNetworkSpeed: boolean = false
  //网络测速半模拟态web控制器
  controller: webview.WebviewController = new webview.WebviewController();

  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean

  /* 代理节点数据相关参数  */
  //节点假数据组后期可改可删
  @Prop items: ProxyItem[]
  // 当前代理节点单选选择的值
  @Prop selectedProxy: string
  @Prop disabled: boolean
  @StorageLink('favoriteProxys') favoriteProxys: Map<string, string> = new Map<string, string>([])
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  /**
   * XXX 当前手指触摸的ListItem的对应 `this.configList` 中的 `configId`
   *    List的长按菜单中的响应都是根据这个的对象中的属性来处理的，是个不稳定因素
   */
  private currentTouchProxyData: ProxyItem = {
    name:'',
    latency: 0,
    type: '',
    id: '',
    g: '',
    isShowFavoriteProxy: false
  }


  aboutToAppear(): void {
    hilog.info(0xB000, this.componentName, `#aboutToAppear`)
    BreakpointSystem.getInstance().attach(this.breakPointStateListLanes)
    BreakpointSystem.getInstance().start()
    EventHub.on(EventKey.ProxySort, (sort: ProxySort)=>{
      console.log("ProxySort", sort)
      switch (sort){
        case ProxySort.Default: this.DefaultSortItems(); break;
        case ProxySort.Title: this.NameSortItems(); break;
        case ProxySort.Delay: this.LatencySortItems(); break;
      }
    })
  }
  // 延迟排序
  LatencySortItems() {
    this.items.sort((a, b) => (a.latency ?? 0) - (b.latency ?? 0));
  }

  //按名称排序
  NameSortItems() {
    this.items = this.items.sort((a, b) => {
      return ProxyCollator.compare(a.name, b.name);
    })
  }

  //默认排序
  DefaultSortItems() {
    this.items.sort((a, b) => ProxyCollator.compare(a.id, b.id));
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

  OnProxyChange: ((item: ProxyItem) => void) = () => {

  }

  //长按菜单 start
  @Builder
  //长按菜单相关
  MyMenu(isShowFavoriteProxy:boolean, nodeName: string) {
    Menu() {
      // 根据当前配置信息来判断显示[收藏 /取消收藏] 单独处理 START
      if (isShowFavoriteProxy) {
        MenuItem({
          symbolStartIcon: this.proxyListLongPressCtxMenuForUnFavorite.symbolStartIcon!
            .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE),
          content: this.proxyListLongPressCtxMenuForUnFavorite.content
        })
          .clickEffect({level:this.uiConfig.isAnimation? ClickEffectLevel.MIDDLE:null})
          .contentFontColor($r('sys.color.font_primary'))
          .onClick( () => {
            this.proxyListLongPressCtxMenuForUnFavorite.callback()
          })
      } else {
          MenuItem({
            symbolStartIcon: this.proxyListLongPressCtxMenuForFavorite.symbolStartIcon!
              .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE),
            content: this.proxyListLongPressCtxMenuForFavorite.content
          })
            .clickEffect({level:this.uiConfig.isAnimation? ClickEffectLevel.MIDDLE:null})
            .contentFontColor($r('sys.color.font_primary'))
            .onClick(() => {
              this.proxyListLongPressCtxMenuForFavorite.callback()
          })
      }
      MenuItem({ symbolStartIcon: this.startIconModifier1, content: $r('app.string.Test_Delay') })
        .onClick(()=>{
          EventHub.sendEvent(EventKey.TestDelayAll, nodeName)
          this.ProxyPromptAction.showToast({ message: $r('app.string.Test_Delay_Tip')
          })})
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

  selectProxy(item: ProxyItem){
    if (!this.disabled){
      this.selectedProxy = item.name
      this.appConfig.currentProxyName = item.name
      this.appConfig.currentProxyItem = item
      this.OnProxyChange(item)
    }
  }
  build() {
    List({ space: 10, initialIndex: 0 }) {
      ForEach(this.items, (item: ProxyItem, index: number) => {
        ListItem() {
          ProxyNode({itemSize: this.ProxyGroupItemSelected, item: item, disabled: this.disabled, selected: this.selectedProxy, selectProxy: (p: ProxyItem) => {
            this.selectProxy(p)
          }
          })
        }
        .transition(this.uiConfig.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: index*10+10 })
          .combine(TransitionEffect.scale({x: 0, y: 0})):null)
        .onClick(() => {
          this.selectProxy(item)
        })
        .ListItemStyle()
        .clickEffect({level:this.uiConfig.isAnimation? ClickEffectLevel.MIDDLE:null})
        .height(LIST_ITEM_HEIGHT + (this.ProxyGroupItemSelected === ProxyCardSize.Small ? 32 : 0))
        .bindContextMenu(this.MyMenu(item?.isShowFavoriteProxy ?? false, item.name), ResponseType.LongPress,
          {
            preview: MenuPreviewMode.IMAGE,
            onAppear: (() => {
              this.currentTouchProxyData = item
            }),
            previewAnimationOptions: {
              scale: [0.95, 1.0],
              transition: this.uiConfig.isAnimation ?TransitionEffect.prototype.animation({ tempo: 1.5 }):undefined
            },
          })
      })
    } // TODO 不同大小显示不同的布局
    .lanes(this.ProxyGroupItemSelected === ProxyCardSize.Large ? 0 : this.breakPointStateListLanes.value, this.breakPointStateListGutter.value)
    .ListStyle()
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
    //  收藏节点 & 判断是否已经收藏
    this.ProxyPromptAction.showToast({ message: $r('app.string.Collect_Tip') })
    const p = this.currentTouchProxyData
    p.isShowFavoriteProxy = true
    this.favoriteProxys.set(p.g + '|' + p.name, this.appConfig.currentProfileId ?? "")
  }
  /**
   * 取消收藏配置
   */
  private cancelFavoriteProxy(): void {
    //  取消收藏节点 & 判断是否已经收藏
    this.ProxyPromptAction.showToast({ message: $r('app.string.uncollected_tip') })
    const p = this.currentTouchProxyData
    p.isShowFavoriteProxy = false
    this.favoriteProxys.delete(p.g + '|' + p.name)
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
  .borderRadius(20)
  .backgroundColor($r('app.color.container_background'))
  .width('100%')
}







export default ProxyGroupItem
