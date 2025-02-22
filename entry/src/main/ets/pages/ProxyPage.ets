import { BreakpointState, BreakpointSystem } from '../common/breakpointsystem'
import {
  TAB_CONTENT_TITLE_HEIGHT,
  BIND_SHEET_CONTAINER_HEIGHT,
  TAB_CONTENT_TITLE_FONT_SIZE,
  BORDER_RADIUS_20,
  CONTENT_END_OFFSET_150,
  FONT_SIZE_16,
  LIST_ITEM_HEIGHT,
} from '../common/Constants'
import { hilog } from '@kit.PerformanceAnalysisKit'
import ProxyGroupItem from '../components/Proxy/ProxyGroupItem'
import ProxyArrangement from '../components/Proxy/ProxyArrangement'
import { ProxyGroupItemDataSource, ProxyItem, ProxyItemDataSource } from '../common/ProxyData'
import ClashViewModel from '../entryability/ClashViewModel'
import { ClashConfig, Profile, ProxyGroup, ProxyMode, ProxySort, ProxyType } from 'proxy_core'
import { EventHub, EventKey } from '../common/EventHub'
import { AppConfig,
  AppState,
  ClashCore, isEnd, ProxyCardSize, ProxyGroupType, UIConfig } from '../entryability/AppState'
import { curves, PromptAction } from '@kit.ArkUI'
import { ProviderPage } from '../components/Proxy/Provider'
import { indexController } from './Index'
import { customAnimationUtil } from '../utils/Animation'
import { Nothing, RightDownButton } from '../components/Common'
import { StylesEdit } from '../components/Proxy/StylesEdit'
import { PopTips, PopupBuilder } from '../components/Start/Popup'


@Entry
@Component
struct ProxyPage {
  //系统颜色调用
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  // 所有子组件在容器内的对齐方式
  @Consume('stackAlignContentAlignment') stackAlignContentAlignment: Alignment
  //一级文本色，黑色
  @State font_primary: ResourceColor = $r('sys.color.font_primary')
  //二级文本色，深灰色
  @State font_secondary: ResourceColor = $r('sys.color.font_secondary')
  //卡片颜色
  @State container_background: ResourceColor = ($r('app.color.container_background'))
  //一级文本反色，白色
  @State font_on_primary: ResourceColor = $r('sys.color.font_on_primary')
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  //二级图标色，深灰色
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary')
  /* Stack层叠布局 */

  // 是否要打开样式编辑
  @State isStylesEdit: boolean = false
  // 半模态页
  @State isShowProxyBindSheet: boolean = false
  // 分组tabs相关
  @State currentIndex: number = 0;
  // 假数据延迟颜色设置
  @State color: ResourceColor = $r('sys.color.font_secondary')
  // 定义ProxyArrangementSelected的值便于切换分组方式
  @State ProxyArrangementSelected: string = 'ProxyArrangementSelected1';
  @State ProxyArrangementChecked: boolean = true;
  // 定义ProxyGroupItemSelected的值便于切换布局方式
  @Provide ProxyGroupItemSelected: string = 'ProxyGroupItemSelectedWide'
  @State ProxyGroupItemChecked: boolean = true;
  ProxyGroupItemChecked1: boolean = false;
  @State currentRadioValue1: number = 0 // 分组方式切换
  @State currentRadioValue2: number = 0 // 排列方式切换
  @State currentRadioValue3: number = 0 // 卡片尺寸切换

  /*节点相关数据以及排序 */
  // 代理原始数据
  @Consume theProxyGroups: ProxyGroup[]
 // @StorageProp("proxyGroups") theProxyGroups: ProxyGroup[] = []
  @Prop proxyitems: ProxyItem[]
  // 代理数据(懒加载)
  @Consume proxyGroups: ProxyGroupItemDataSource
  // 代理分组List控制器
  private ListScroller: Scroller = new Scroller()
  // 代理节点Swiper控制器
  private SwiperController: SwiperController = new SwiperController()

  // 收藏与ping延迟即时动作
  private ProxyPromptAction: PromptAction = this.getUIContext()?.getPromptAction()
  /* 断点布局相关 相关作用看定义时候的注释 */
  @Consume('breakPointStateListLanes')
  private breakPointStateListLanes: BreakpointState<number>
  @Consume('breakPointStateListGutter')
  private breakPointStateListGutter: BreakpointState<number>
  @Consume('breakPointStateTabContentTitleMargin')
  private breakPointStateTabContentTitleMargin: BreakpointState<number>
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') isLandscapePhone: boolean = false
  @StorageProp('isLandscapeStatus') isLandscapeStatus: boolean = false
  // 按钮宽度
  private proxyStartButtonWidth: Length = $r('app.integer.vp_proxy_not_start_button_width')
  // 按钮高度
  private proxyStartButtonHeight: Length = $r('app.integer.vp_proxy_not_start_button_height')
  // 按钮前Symbol动效
  private ReplaceSymbolEffect: SymbolEffect = EffectScope.WHOLE
  //定义组件名
  private componentName: string = 'ProxyPage'
  @Consume('currentProfile') private currentProfile: Profile | null
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('favoriteProxys') favoriteProxys: Map<string, string> = new Map<string, string>([])
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  /**主页卡片标题按钮间距*/
  @Consume('HomeCardTitleButtonPadding') private HomeCardTitleButtonPadding: BreakpointState<number>
  // page内顶部标题偏移量
  @Consume curYOffset: number
  // 收藏显示判定
  @Provide showStart: boolean = false
  @State loading: boolean = false
  // 代理页延迟按钮气泡提示
  @Consume isShowDelayPop: boolean

  aboutToAppear(): void {
    hilog.info(0xB000, this.componentName, `#aboutToAppear`)
    this.isShowDelayPop = this.uiConfig.ShowDelayPop
    BreakpointSystem.getInstance().start()
    if (this.currentProfile) {
      let tabIndex = this.theProxyGroups.findIndex((d) => d.name == this.currentProfile?.currentGroupName)
      setTimeout(() => {
        if (tabIndex > -1) {
          this.ListScroller.scrollToIndex(tabIndex)
          this.currentIndex = tabIndex
        }
      }, 200)
    }

  }
  @Consume proxyLazyItems: ProxyItemDataSource
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()

  aboutToDisappear() {
    EventHub.off(EventKey.FetchProxyGroup)
   // EventHub.off(EventKey.ProxySort)
    EventHub.off(EventKey.TestDelay)
    this.uiConfig.ShowDelayPop = this.isShowDelayPop
  }

  changeProxy(group: string, item: ProxyItem) {
    if (this.currentProfile) {
      ClashViewModel.changeProxy(this.currentProfile, group, item.name)
    }
  }

  // 标题按钮
  @Builder
  ButtonBuilder(icons: Resource, onCheck: () => void ) {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph(icons)
        .fontSize(24)
        .fontColor([this.icon_primary])
    }
    .width(40)
    .height(40)
    .backgroundColor($r('app.color.settings_container_background'))
    .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
    .onClick(() => {
      onCheck()
    })
    .transition(customAnimationUtil.isSlide(100, this.uiConfig))
  }
  // 标签列表样式标签
  @Builder
  TabBuilder(title: ResourceStr, targetIndex: number) {
    Column() {
      Column() {
        Text(title)
          .fontSize(14)
          .fontColor(this.currentIndex === targetIndex ? this.font_on_primary : this.font_secondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .padding({left:3,right:3})
      }
      .borderRadius(BORDER_RADIUS_20)
      .height(this.currentIndex === targetIndex ? 36 : 32)
      .width(this.currentIndex === targetIndex ? 96 : 87)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.currentIndex === targetIndex ? this.icon_emphasize : this.container_background)
    }
    .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
    .height(55)
    .margin({ right: 8, bottom: 10 })
    .onClick(() => {
      this.currentIndex = targetIndex
      this.SwiperController.changeIndex(this.currentIndex)
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
  }
  // 嵌套分组样式标签头
  @Builder
  itemHead(text: string, icon: Resource) {
    Row() {
      Text(text)
        .fontSize(FONT_SIZE_16)
        .fontColor($r('sys.color.font_primary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      SymbolGlyph(icon)
        .fontSize(25).fontColor([$r('sys.color.icon_primary')])
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 10, right: 10 })
    .borderRadius(BORDER_RADIUS_20)
    .backgroundColor($r('app.color.container_background'))
    .height(LIST_ITEM_HEIGHT)
    .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
  }
  // 半模态页面
  @Builder
  ProxyBindSheet() {
    Column() {
      if (this.isStylesEdit) {
        // 样式编辑
        StylesEdit()
      } else {
        // 提供者
        ProviderPage()
      }
    }
    .width('100%')
  }

  build() {
    Stack() {
      // 标题栏
      Row({ space: this.HomeCardTitleButtonPadding.value }) {
        Text($r('app.string.Proxy'))
          .fontSize(this.curYOffset < 0 ? TAB_CONTENT_TITLE_FONT_SIZE-this.curYOffset / 100 : TAB_CONTENT_TITLE_FONT_SIZE)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .transition(customAnimationUtil.isSlide(200, this.uiConfig))
          .transition(customAnimationUtil.isScaleTran(0, this.uiConfig))
        Blank()
        // 一键取消所有收藏按钮 TODO 判定暂时有问题 不显示先
        /*this.ButtonBuilder($r('sys.symbol.heart_slash'), () => {
           this.favoriteProxys.clear()
           this.showStart=true
           this.ProxyPromptAction.showToast({ message: $r('app.string.uncollected_all_tip') })
         })*/
        // 提供者按钮
        this.ButtonBuilder($r('sys.symbol.puzzle'), () => {
          this.isStylesEdit = false
          this.isShowProxyBindSheet = true
          this.isEnableIndexForegroundBlur = true
        })
        // 编辑图标
        this.ButtonBuilder($r('sys.symbol.square_and_pencil'), () => {
          this.isStylesEdit = true
          this.isShowProxyBindSheet = true
          this.isEnableIndexForegroundBlur = true
        })
      }
      .zIndex(1)
      .height(this.curYOffset < 0 ? TAB_CONTENT_TITLE_HEIGHT - this.curYOffset : TAB_CONTENT_TITLE_HEIGHT)
      .position({x:0})
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .padding({
        left: this.breakPointStateTabContentTitleMargin.value,
        right: this.breakPointStateTabContentTitleMargin.value,
      })
      .transition(customAnimationUtil.isSlide(0, this.uiConfig))

      if (this.theProxyGroups.length == 0) {
        Nothing({ name: $r('app.string.None_Proxy') })
      } else {
        Stack({ alignContent: this.stackAlignContentAlignment }) {
          Column() {
            Blank().height(TAB_CONTENT_TITLE_HEIGHT)
            Scroll() {
              // 标签分组页 start
              Column() {
                //根据ProxyArrangementSelected的状态决定是否显示
                if (this.appConfig.proxyGroupType === ProxyGroupType.Tabs) {
                  // 代理分组List Start
                  List({scroller: this.ListScroller}) {
                    LazyForEach(this.proxyGroups, (group: ProxyGroup, index: number) => {
                      this.TabBuilder(group.name, index)
                    }, (item: ProxyGroup) => item.name)
                  }
                  .height(55)
                  .width('100%')
                  .scrollBar(BarState.Off)
                  .listDirection(Axis.Horizontal)
                  // 代理分组List End
                  // 代理节点Swiper Start
                  Swiper(this.SwiperController) {
                    LazyForEach(this.proxyGroups, (group: ProxyGroup, index: number) => {
                      ProxyGroupItem({
                        proxyGroup: index,
                        proxyitems: group.proxies as ProxyItem[],
                        ProxyGroupItemSelected: this.appConfig.proxyCardSize,
                        disabled: group.type !== ProxyType.Selector,
                        selectedProxy: this.currentProfile?.getSelectedProxy(group) ?? "",
                        OnProxyChange: (item) => {
                          this.changeProxy(group.name, item)
                        }
                      })
                        .width('100%')
                        .height('100%')
                        .padding({bottom:CONTENT_END_OFFSET_150 - 50})
                        .onAppear(() => {
                          hilog.info(0xFF00, "ProxyPageGroupTag", "#onAppear %{public}s", group.proxies.toString())
                        })
                        .onDisAppear(() => {
                          hilog.info(0xFF00, "ProxyPageGroupTag", "#onDisAppear %{public}s", group.toString())
                        })
                    }, (item: ProxyGroup) => item.name)
                  }
                  .loop(false)
                  .cachedCount(2)
                  .indicator(false)
                  .alignSelf(ItemAlign.Center)
                  .onGestureSwipe((index: number, extraInfo: SwiperAnimationEvent) => {
                    hilog.info(0xFF00, "ProxyPagePanTag", "currentOffset: %{private}d", extraInfo.currentOffset)
                    animateTo({ duration: this.uiConfig.animationSpeed, curve: curves.springMotion() }, () => {
                      // 当设备横屏，即主tab栏竖排时不触发切换
                      // hilog.info(0xFF00, "ProxyLandscapeTag", "设备横屏状态: %{public}s", this.isLandscapeStatus)
                      if (!this.isLandscapeStatus) {
                        if (this.currentIndex === 0 && extraInfo.currentOffset > 79) {
                          indexController.changeIndex(0)
                        } else if (this.currentIndex === this.theProxyGroups.length - 1 && extraInfo.currentOffset < -79) {
                          indexController.changeIndex(2)
                        }
                      }
                    })
                  })
                  .onAnimationStart((index: number, targetIndex: number) => {
                    animateTo({ duration: this.uiConfig.animationSpeed, curve: curves.springMotion() }, () => {
                      this.ListScroller.scrollToIndex(targetIndex)
                      this.currentIndex = targetIndex
                      if (this.currentProfile) {
                        this.currentProfile.currentGroupName = this.theProxyGroups[this.currentIndex].name
                        ClashViewModel.updateProfile(this.currentProfile)
                      }
                    })
                  })
                  // 代理节点Swiper End
                }
                // 标签分组页 End
                // 列表分组页 Start
                else if (this.appConfig.proxyGroupType === ProxyGroupType.List) {
                  ProxyArrangement()
                    .padding({ bottom:50 })
                }
              }.width('100%')
              .height('100%')
              .alignItems(HorizontalAlign.Center)
              // 列表排列页 End
            }.width('100%')
            .height('100%')
            .scrollBar(BarState.Off)
            .edgeEffect(this.uiConfig.isAnimation ? EdgeEffect.Spring : null)
            .padding({ left: this.breakPointStateTabContentTitleMargin.value, right: this.breakPointStateTabContentTitleMargin.value})
            .onDidScroll((xOffset: number, yOffset: number, scrollState: ScrollState): void => {
              // 累计计算当前父组件滚动在Y轴方向的偏移量
              if (this.uiConfig.isAnimation){
                this.curYOffset += yOffset
              }
              hilog.info(0xFF00, "ProxyPageTag", "yOffset: %{public}d", this.curYOffset)
            })
          }

          // ClashMeta内核时暂时无法测延迟
          if (this.appConfig.clashCore === ClashCore.FlClash) {
            // 悬浮代理测速按钮 START
            Column() {
              RightDownButton(
                $r('sys.symbol.bolt_filled_on_circle'),
                this.ReplaceSymbolEffect,
              )
            }
            .backgroundColor(this.icon_emphasize)
            .shadow({
              radius: 10,
              color: this.icon_emphasize,
              offsetY: 4,
              type: ShadowType.BLUR
            })
            .borderRadius(100)
            .width(this.proxyStartButtonWidth)
            .height(this.proxyStartButtonHeight)
            .clip(true)
            .hoverEffect(HoverEffect.Scale)
            .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
            .transition(customAnimationUtil.isSlideSwitch(this.uiConfig))
            .margin({bottom:this.isLandscapePhone ? $r('app.integer.vp_proxy_start_button_left_right_margin') : $r('app.integer.vp_proxy_start_button_bottom_margin'),right:$r('app.integer.vp_proxy_start_button_left_right_margin'),left:$r('app.integer.vp_proxy_start_button_left_right_margin')})
            .bindPopup(!!this.isShowDelayPop, {
              builder: PopupBuilder(this, PopTips[3], () => {
                this.isShowDelayPop = false
              }),
              onWillDismiss: false,
              autoCancel: false
            })
            .onClick(async () => {
              if(this.loading){
                return
              }
              this.ProxyPromptAction.showToast({ message: $r('app.string.Test_Delay_Tip') })
              this.loading = true
              await ClashViewModel.testAllDelay(this.theProxyGroups[this.currentIndex].proxies as ProxyItem[])
              this.loading = false
              hilog.info(0xFF00, "ProxyPageLatencyTag", "延迟运行1 %{public}s")
              if (this.appConfig.proxySort == ProxySort.Delay) {
                EventHub.sendEvent(EventKey.ProxySort, ProxySort.Delay)
                hilog.info(0xFF00, "ProxyPageLatencyTag", "延迟运行2 %{public}s")
              }
            })
            // 悬浮代理测速按钮 END
          }
        }
        .backgroundColor($r('app.color.background'))
        .width('100%')
        .height( '100%' )
        // 主体 END
      }
    }
    .width('100%')
    .height('100%')
    // 半模态页
    .bindSheet($$this.isShowProxyBindSheet, this.ProxyBindSheet(), {
      detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.LARGE,],
      backgroundColor: $r('app.color.background'),
      dragBar: false,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      preferType: SheetType.CENTER,
      onWillDismiss: () => {
        this.isShowProxyBindSheet = false
        this.isEnableIndexForegroundBlur = false
        setTimeout(() => {
          this.isStylesEdit = false
        }, 20)
      }
    })
  }
}

export default ProxyPage


// 半模态编辑页Column公共样式（含非通用公共属性采用Extend继承的方式抽取）
@Extend(Column)
function EditColumn() {
  .padding({ left: 12, right: 12 })
  .width('100%')
  .margin({ bottom: 10 })
  .borderRadius(BORDER_RADIUS_20)
  .backgroundColor($r('app.color.container_background'))
  .justifyContent(FlexAlign.SpaceEvenly) // 非通用公共属性
}

// 半模态编辑页Row公共样式（含非通用公共属性采用Extend继承的方式抽取）
@Extend(Row)
function EditRow() {
  .width('100%')
  .justifyContent(FlexAlign.SpaceBetween) // 非通用公共属性
}

// 半模态编辑页Text共同属性（Text独有属性采用Extend继承的方式抽取）
@Extend(Text)
function EditText() {
  .font({ size: 16 })
  .fontColor($r('sys.color.font_primary')) // 一级文本色，黑色
}

// 半模态编辑页标题
@Component
struct EditTitle {
  @State title: ResourceStr = $r('app.string.Packet_mode')
  build() {
    Text(this.title)
      .width('100%')
      .fontSize(16)
      .fontColor($r('sys.color.font_secondary'))
      .textAlign(0)
      .margin({ bottom: 10 })
  }
}