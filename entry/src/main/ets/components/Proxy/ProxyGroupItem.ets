import { hilog } from '@kit.PerformanceAnalysisKit'
import { BreakpointState, BreakpointSystem } from '../../common/breakpointsystem'
import {
  BIND_SHEET_CONTAINER_HEIGHT,
  BORDER_RADIUS_20,
  CONTENT_END_OFFSET_150,
  LIST_ITEM_HEIGHT,
  TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE } from '../../common/Constants'
import { LengthMetrics, SymbolGlyphModifier,PromptAction, curves } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { ProxyGroupItemDataSource, ProxyItem, ProxyItemDataSource } from '../../common/ProxyData';
import { EventHub, EventKey } from '../../common/EventHub';
import { Profile, ProxyGroup, ProxySort } from 'proxy_core';
import { AppConfig, AppState, ClashCore, ProxyCardSize, ProxyGroupType, UIConfig } from '../../entryability/AppState';
import { ProxyNode } from './ProxyNodeItem';
import { customAnimationUtil } from '../../utils/Animation';
import { customVibrator } from '../../utils/VibratorUtil';
import ClashViewModel, { DelayInfo } from '../../entryability/ClashViewModel';
import { PopTips, PopupBuilder } from '../Start/Popup';


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


@Component
struct ProxyGroupItem {
  // 组件名
  private componentName: string = 'ProxyPage'
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
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
    customStyle: false,
    cornerRadius: 32,
    gridCount: 4,
    cancel: this.existApp,
    autoCancel: true,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      console.info("reason=" + JSON.stringify(dismissDialogAction.reason))
      console.log("dialog onWillDismiss")
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
        this.isEnableIndexForegroundBlur = false
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
        this.isEnableIndexForegroundBlur = false
      }
    },
  })

  /*长按菜单相关参数  */
  //长按菜单图标
  @State startIconModifier1: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.bolt_filled_on_circle')).fontSize('24vp');
  @State startIconModifier2: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.timer')).fontSize('24vp');
  @State startIconModifier3: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.questionmark_circle')).fontSize('24vp');
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false

  /* 断点布局相关 */
  @Consume ProxyListLanes: BreakpointState<number>
  @Consume private breakPointStateListGutter: BreakpointState<number>

  // 主界面index
  @Consume IndexCurrentindex: number

  /* 本页布局相关参数 */
  // 定义ProxyGroupItemSelectedWide的值便于切换布局方式
  @Prop ProxyGroupItemSelected: ProxyCardSize
  //是否显示网络测速半模拟态判定
  @State isShowNetworkSpeed: boolean = false
  //网络测速半模拟态web控制器
  controller: webview.WebviewController = new webview.WebviewController();
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  /* 代理节点数据相关参数  */
  //节点数据组
  @Prop proxyitems: ProxyItem[]
  // 代理分组序号[0 ~ +∞]
  @Prop proxyGroup: number
  // 代理原始数据
  @Consume theProxyGroups: ProxyGroup[]
  @State proxyLazyItems: ProxyItemDataSource = new ProxyItemDataSource()
  @Consume('currentProfile') private currentProfile: Profile | null
  // 当前代理节点单选选择的值
  @Prop selectedProxy: string
  @Prop disabled: boolean
  @StorageLink('favoriteProxys') favoriteProxys: Map<string, string> = new Map<string, string>([])
  @StorageLink('appConfig') @Watch('switchSort') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 收藏显示判定
  @Consume showStart:boolean
  // 代理页延迟按钮气泡提示
  @Consume isShowDelayPop: boolean
  // 列表滚动判断
  @Consume isRolling: boolean
  // px外屏隐藏top和tab偏移
  @Consume curOffsetRemain: number
  // px外屏
  @Consume isPXSecScreen: boolean
  //延迟排序判定
  @Consume @Watch('switchSort')isLatencySort: boolean
  /**
   * XXX 当前手指触摸的ListItem的对应 `this.configList` 中的 `configId`
   *    List的长按菜单中的响应都是根据这个的对象中的属性来处理的，是个不稳定因素
   */
  public static currentTouchProxyData: ProxyItem = {
    name: '',
    latency: 0,
    type: '',
    id: '',
    g: '',
    isShowFavoriteProxy: false
  }

  async aboutToAppear(): Promise<void> {
    hilog.info(0xB000, this.componentName, `#aboutToAppear`)
    this.switchSort()
    /*EventHub.on(EventKey.ProxySort, async (sort: ProxySort) => {
      console.log("ProxySort", sort)
      // hilog.info(0xFF00, "ProxyPageLatencyTag", "延迟运行4 %{public}s")
      // hilog.info(0xFF00, "ProxyPageLatencyTag", "this.proxyitems %{public}s", JSON.stringify(this.proxyitems))
    })*/
   }

   switchSort(){
     if (this.appConfig.proxySort == ProxySort.Default){
       this.proxyLazyItems.DefaultSortItems(this.proxyitems)
     } else if (this.appConfig.proxySort == ProxySort.Title){
       this.proxyLazyItems.NameSortItems(this.proxyitems)
     } else if (this.appConfig.proxySort == ProxySort.Delay ||(this.appConfig.proxySort == ProxySort.Delay && this.isLatencySort==true)){
       this.proxyLazyItems.LatencySortItems(this.proxyitems)
       hilog.info(0xFF00, "ProxySort ProxyPageLatencyTag", "延迟排序 %{public}s", this.appConfig.proxySort)
     }
   }

   aboutToDisappear() {
    // EventHub.off(EventKey.ProxySort)
   }

   /**
    * 半模态窗口测速网站
    */
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
  }
  //半模态网络测速 end

  onCancel() {
    console.info('Callback when the first button is clicked')
  }

  onAccept() {
    console.info('Callback when the second button is clicked')
  }

  existApp() {
    console.info('Click the callback in the blank area')
  }

  // 收藏与ping延迟即时动作
  private ProxyPromptAction: PromptAction = this.getUIContext()?.getPromptAction()

  OnProxyChange: ((item: ProxyItem) => void) = () => {

  }

  // 长按菜单 start
  @Builder
  // 长按菜单相关
  MyMenu(isShowFavoriteProxy: boolean, nodeName: string) {
    Menu() {
      // 根据当前配置信息来判断显示[收藏 /取消收藏] 单独处理 START
      if (isShowFavoriteProxy && this.favoriteProxys.size>0 ) {
        MenuItem({
          symbolStartIcon: this.proxyListLongPressCtxMenuForUnFavorite.symbolStartIcon!
            .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE),
          content: this.proxyListLongPressCtxMenuForUnFavorite.content
        })
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .contentFontColor($r('sys.color.font_primary'))
          .onClick(() => {
            this.proxyListLongPressCtxMenuForUnFavorite.callback()
          })
      } else {
        MenuItem({
          symbolStartIcon: this.proxyListLongPressCtxMenuForFavorite.symbolStartIcon!
            .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE),
          content: this.proxyListLongPressCtxMenuForFavorite.content
        })
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .contentFontColor($r('sys.color.font_primary'))
          .onClick(() => {
            this.proxyListLongPressCtxMenuForFavorite.callback()
          })
      }
      // ClashMeta内核时暂时不能测速及延迟  暂时先屏蔽
      if (this.appConfig.clashCore === ClashCore.FlClash) {
        MenuItem({ symbolStartIcon: this.startIconModifier1, content: $r('app.string.Test_Delay') })
          .onClick(() => {
            ClashViewModel.testDelay(nodeName)
          })
        }
      //暂时先屏蔽网站测速功能
      /* MenuItem({ symbolStartIcon: this.startIconModifier2, content: $r('app.string.Test_Speed') })
         .onClick(() => {
           this.isShowNetworkSpeed = true
           this.isEnableIndexForegroundBlur = true
         })

      MenuItem({ symbolStartIcon: this.startIconModifier3, content: $r('app.string.Delay_Speed') })
        .onClick(() => {
          if (this.ProxyDialogController != null) {
            this.ProxyDialogController.open()
            this.isEnableIndexForegroundBlur = true
          }
        })*/
    }
    //分割线
    .menuItemDivider({ color: $r('app.color.divider'), strokeWidth: LengthMetrics.vp(1) })
    .backgroundColor($r('app.color.container_background'))
    .borderRadius(BORDER_RADIUS_20)
    .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
  } // 长按菜单end

  selectProxy(item: ProxyItem) {
    if (!this.disabled) {
      this.appConfig.currentProxyName = item.name
      this.appConfig.currentProxyItem = item
      this.OnProxyChange(item)
    }
  }

  build() {
    List({ space: 10, initialIndex: 0 }) {
      LazyForEach(this.proxyLazyItems, (item: ProxyItem, index: number) => {
        ListItem() {
          ProxyNode({
            itemSize: this.ProxyGroupItemSelected,
            item: item,
            disabled: this.disabled,
            selected: this.selectedProxy,
            selectProxy: (p: ProxyItem) => {
              this.selectProxy(p)
            },
            onLatencyChange:(p:number) =>{
              item.latency = p
              // hilog.info(0xFF00, "ProxyPageLatencyTag", "延迟运行3 延迟更新为%{public}d", p)
              // const nodeItem = this.theProxyGroups[this.proxyGroup]
              // nodeItem.proxies[index].latency = p
              // this.theProxyGroups.splice(this.proxyGroup, 1, nodeItem)
              // hilog.info(0xFF00, "ProxyPageLatencyTag", "延迟运行3 %{public}s", JSON.stringify(nodeItem))
            }
          })
        }
        .transition(customAnimationUtil.isScaleTran(index, this.uiConfig))
        .onClick(() => {
          this.selectProxy(item)
        })
        .ListItemStyle()
        .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
        .height(LIST_ITEM_HEIGHT + (this.ProxyGroupItemSelected === ProxyCardSize.Small ? 32 : 0))
        .bindContextMenu(this.isPXSecScreen ? null : this.MyMenu(item.isShowFavoriteProxy ?? false, item.name), ResponseType.LongPress,
          {
            preview: MenuPreviewMode.IMAGE,
            onAppear: (() => {
                ProxyGroupItem.currentTouchProxyData = item
              if (this.uiConfig.isVibrate) {
                customVibrator.vibratorTriggerOfHapticClockTimer()
              }
            }),
            previewAnimationOptions: {
              scale: [0.95, 1.0],
              transition: this.uiConfig.isAnimation ? TransitionEffect.prototype.animation({ tempo: 1.5 }) : undefined
            },
          })
        .bindPopup((this.uiConfig.ShowProxyPop && this.proxyGroup === 0 && index === 0 && this.IndexCurrentindex === 1), {
          builder: PopupBuilder(this, PopTips[2], () => {
            this.uiConfig.ShowProxyPop = false
            this.isShowDelayPop = true
          }),
          onWillDismiss: false,
          autoCancel: false
        })
      }, (item: ProxyItem,i: number) => item.name + '-' + i.toString())
    }.cachedCount(4)
    .onScrollFrameBegin((offset: number) => {
      this.curOffsetRemain  += offset
      if (offset>0) {
        this.isRolling = true
      }else if(offset<0){
        this.isRolling = false
        this.curOffsetRemain = 0
      }
      console.info("offsetRemain:" + offset + '/' +this.curOffsetRemain);
      return { offsetRemain: offset }
    })
    .lanes(this.ProxyGroupItemSelected === ProxyCardSize.Large ? 0 : this.ProxyListLanes.value,
      this.breakPointStateListGutter.value)
    .ListStyle()
    .nestedScroll({
      scrollForward: this.isPXSecScreen ? NestedScrollMode.SELF_ONLY: NestedScrollMode.PARENT_FIRST,
      scrollBackward: this.isPXSecScreen ? NestedScrollMode.SELF_ONLY:NestedScrollMode.SELF_FIRST
    })
    .contentEndOffset(this.isPXSecScreen? 65: this.appConfig.proxyGroupType === ProxyGroupType.List ? 10 : CONTENT_END_OFFSET_150)
   /* .bindSheet($$this.isShowNetworkSpeed, this.BindSheetNetworkSpeed(), {
      detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.FIT_CONTENT,],
      preferType: SheetType.CENTER,
      backgroundColor: $r('app.color.settings_container_background'),
      showClose: true,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      title: { title: $r('app.string.Test_Speed'), subtitle: $r('app.string.Test_Speed_Explain') },
      //  maskColor: $r('app.color.dialog_maskcolor'),
      onWillDismiss: () => {
        this.isShowNetworkSpeed = false
        this.isEnableIndexForegroundBlur = false
      }
    })*/
  }

  public proxyListLongPressCtxMenuForFavorite: LongPressContextMenuItem = {
    symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.star'))
      .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
    content: '收藏', callback: () => {
      this.favoriteProxy()
    }
  }
  public proxyListLongPressCtxMenuForUnFavorite: LongPressContextMenuItem = {
    symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.star_fill'))
      .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.multi_color_11')]),
    content: '取消收藏', callback: () => {
      this.cancelFavoriteProxy()
    }
  }

  /**
   * 收藏配置
   */
  private favoriteProxy(): void {
    //  收藏节点 & 判断是否已经收藏
    const p = ProxyGroupItem.currentTouchProxyData
    if (!p.isShowFavoriteProxy && AppState.fetchFavoriteProxys(this.favoriteProxys, this.theProxyGroups).length<3){
      this.ProxyPromptAction.showToast({ message: $r('app.string.Collect_Tip') })
      p.isShowFavoriteProxy = true
      this.favoriteProxys.set(p.g + '|' + p.name, this.appConfig.currentProfileId ?? "")
      console.info('favoriteProxys',`${JSON.stringify(this.favoriteProxys)}`)
    }else {
      this.ProxyPromptAction.showToast({ message: $r('app.string.favorite_proxy_no') })
    }
  }

  /**
   * 取消收藏配置
   */
  private cancelFavoriteProxy(): void {
    this.ProxyPromptAction.showToast({ message: $r('app.string.uncollected_tip') })
    const p = ProxyGroupItem.currentTouchProxyData
    p.isShowFavoriteProxy = false
    this.favoriteProxys.delete(p.g + '|' + p.name)
    console.info('favoriteProxys',`${JSON.stringify(this.favoriteProxys)}`)
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
  .width('100%')
  .height('100%')
  .chainAnimation(true)
  .scrollBar(BarState.Off)
  .edgeEffect(EdgeEffect.Spring)
  .constraintSize({minHeight: 120})
  .alignListItem(ListItemAlign.Center)
}

//ListItem公用样式
@Extend(ListItem)
function ListItemStyle() {
  .width('100%')
  .borderRadius(BORDER_RADIUS_20)
  .backgroundColor($r('app.color.container_background'))
}







export default ProxyGroupItem
