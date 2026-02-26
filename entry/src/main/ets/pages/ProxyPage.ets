import {
  TAB_CONTENT_TITLE_HEIGHT,
  BIND_SHEET_CONTAINER_HEIGHT,
  TAB_CONTENT_TITLE_FONT_SIZE,
  BORDER_RADIUS_20,
  CONTENT_END_OFFSET_150,
} from '../common/entity/Constants'
import { hilog } from '@kit.PerformanceAnalysisKit'
import ProxyGroupItem from '../components/Proxy/ProxyGroupItem'
import ProxyArrangement from '../components/Proxy/ProxyArrangement'
import { ProxyGroupItemDataSource, ProxyItem, ProxyItemDataSource } from '../common/datasources/ProxyData'
import ClashViewModel from '../entryability/ClashViewModel'
import { ClashConfig, Profile, ProxyGroup, ProxySort, ProxyType } from 'proxy_core'
import { EventHub, EventKey } from '../common/EventHub'
import { AppConfig, ProxyGroupType, UIConfig } from '../entryability/AppState'
import { curves, PromptAction } from '@kit.ArkUI'
import { ProviderPage } from '../components/Proxy/Provider'
import { indexController } from './Index'
import { customAnimationUtil } from '../common/utils/Animation'
import { ButtonBuilder, icon_tertiary, Nothing, RightDownButton } from '../components/Common/Common'
import { StylesEdit } from '../components/Proxy/StylesEdit'
import { PopTips, PopupBuilder } from '../components/Start/Popup'
import { deviceInfo } from '@kit.BasicServicesKit'
import { customVibrator } from '../common/utils/VibratorUtil'
import { TabBarVertical, TabContentTitleMargin } from '../common/breakpoint/BreakPoint'
import { TopBar } from '../components/Common/TopBar'
import { getResourceString } from '../common/utils/ResourceStringUtil'
import { RoundButton } from '../components/Common/RoundButton'
import { cardManager } from '../common/utils/CardManageUtil'
import { Xb_TabBarVertical, Xb_ToastUtil } from 'xb_components'


// 定义日志组件名
const componentName: string = 'ProxyPage'
// 一级文本色，黑色
const font_primary: ResourceColor = $r('sys.color.font_primary')
// 一级图标色，黑色
const icon_primary: ResourceColor = $r('sys.color.icon_primary')
// 二级图标色，深灰色
const icon_secondary: ResourceColor = $r('sys.color.icon_secondary')
// 二级文本色，深灰色
const font_secondary: ResourceColor = $r('sys.color.font_secondary')
// 一级文本反色，白色
const font_on_primary: ResourceColor = $r('sys.color.font_on_primary')
// 卡片颜色
const container_background: ResourceColor = ($r('app.color.container_background'))

@Entry
@Component
struct ProxyPage {

  /** 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  // 所有子组件在容器内的对齐方式
  @Consume('stackAlignContentAlignment') stackAlignContentAlignment: Alignment
  /** 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor

  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 导航条区域的高度
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  // 代理启动持续的时间
  @StorageProp('proxyStartingDuration') proxyStartingDuration: string = ''
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageLink('isLandscapePhone') isLandscapePhone: boolean = false
  // 是否需要改变节点排列顺序
  @StorageLink('SortChange') needChangeSort: boolean = false
  // 窗口模式
  @StorageProp('WindowMode') windowMode: boolean = false
  // 半模态页
  @State isShowProxyBindSheet: boolean = false
  @Consume isSmallSquareScreen: boolean
  // 是否要打开样式编辑
  @State isStylesEdit: boolean = false
  // 收藏显示判定
  @Provide showStart: boolean = false
  // 代理页延迟按钮气泡提示
  @Consume isShowDelayPop: boolean
  // px外屏
  @Consume isPXSecScreen: boolean
  // 代理启动按钮状态
  @Consume proxyEnabled: boolean
  // 是否滚动
  @Consume isRolling: boolean

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
  @Consume('currentProfile') currentProfile: Profile | null
  // 代理数据(懒加载)
  @Consume proxyGroups: ProxyGroupItemDataSource
  @Consume proxyLazyItems: ProxyItemDataSource
  @Consume paddingButtom: number | Resource
  // 当前代理分组
  @Consume currentProxyIndex: number
  @Consume curOffsetRemain: number
  // page内顶部标题偏移量
  @Consume curYOffset: number
  // px外屏隐藏top和tab偏移
  @Consume heightTop: number

  @StorageLink('favoriteProxys') favoriteProxys: Map<string, string> = new Map<string, string>([])
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  // 代理节点Swiper控制器
  private SwiperController: SwiperController = new SwiperController()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 代理分组tabs控制器
  private ListScroller: Scroller = new Scroller()


  build() {
    Stack() {
      // 标题栏
      if (!this.isPXSecScreen) {
        Row({ space: 12 }) {
          TopBar({
            title: getResourceString($r('app.string.Proxy'), this),
            titleFontSize: this.curYOffset < 0 ? TAB_CONTENT_TITLE_FONT_SIZE - this.curYOffset / 100 : TAB_CONTENT_TITLE_FONT_SIZE,
            iconSize: this.windowMode ? 18 : (this.curYOffset < 0 ? 24 - this.curYOffset / 100 : 24),
            icons: [$r('sys.symbol.heart_slash'), $r('sys.symbol.puzzle'), $r('sys.symbol.square_and_pencil')],
            // 一键取消所有收藏按钮                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              点击事件
            onFClick: () => {
              this.favoriteProxys.clear()
              this.showStart = true
              Xb_ToastUtil.showToast({ message: $r('app.string.uncollected_all_tip') })
            },
            // 提供者按钮
            onSClick: () => {
              this.isStylesEdit = false
              this.isShowProxyBindSheet = true
              this.isEnableIndexForegroundBlur = true
            },
            // 编辑图标
            onTClick: () => {
              this.isStylesEdit = true
              this.isShowProxyBindSheet = true
              this.isEnableIndexForegroundBlur = true
            }
          })
        }
        .zIndex(1)
        .position({x: 0, y:this.isRolling && this.isSmallSquareScreen ? this.heightTop : 0})
        .alignItems(this.windowMode ? VerticalAlign.Top : VerticalAlign.Center)
        .width('100%')
        .transition(customAnimationUtil.isSlide(0, this.uiConfig))
        .backgroundColor($r('app.color.background'))
        .height(this.curYOffset < 0 ? TAB_CONTENT_TITLE_HEIGHT - this.curYOffset : TAB_CONTENT_TITLE_HEIGHT)
      }

      if (this.proxyGroups.totalCount() == 0) {
        Nothing({ name: $r('app.string.None_Proxy') })
      } else {
        Stack({ alignContent: this.stackAlignContentAlignment }) {
          Column() {
            if (!this.isPXSecScreen) {
              Blank().height((this.isRolling && this.isSmallSquareScreen) ? this.heightTop : TAB_CONTENT_TITLE_HEIGHT)
            }
            Scroll() {
              // 标签分组页 start
              Column() {
                // 根据ProxyArrangementSelected的状态决定是否显示
                if (this.appConfig.proxyGroupType === ProxyGroupType.Tabs) {
                  // 代理分组List Start
                  List({ scroller: this.ListScroller, initialIndex: this.currentProxyIndex }) {
                    LazyForEach(this.proxyGroups, (group: ProxyGroup, index: number) => {
                      this.TabBuilder(group.name, index)
                    }, (item: ProxyGroup) => item.name)
                  }
                  .height(55)
                  .width('100%')
                  .scrollBar(BarState.Off)
                  .listDirection(Axis.Horizontal)

                  //此处可以直接用tabs懒加载+swiper懒加载并行实现 tabs start
                  /* Tabs({ barPosition: BarPosition.Start,index:this.currentProxyIndex, controller: this.tabsController }) {
                     LazyForEach(this.proxyGroups, (group: ProxyGroup, index: number) => {
                       TabContent().tabBar(this.TabBuilder(group.name, index))
                     }, (item: ProxyGroup) => item.name)
                   }
                   .barMode(BarMode.Scrollable)
                   .height(55)
                   .width('100%')
                   .animationDuration(this.uiConfig.animationSpeed)
                   .fadingEdge(false)
                   .scrollable(false)*/
                  // 代理分组tabs End

                  // 代理节点Swiper Start
                  Swiper(this.SwiperController) {
                    LazyForEach(this.proxyGroups, (group: ProxyGroup, index: number) => {
                      ProxyGroupItem({
                        proxyGroup: index,
                        proxyitems: group.proxies as ProxyItem[] ?? [],
                        ProxyGroupItemSelected: this.appConfig.proxyCardSize,
                        disabled: group.type !== ProxyType.Selector,
                        selectedProxy: this.currentProfile?.getSelectedProxy(group) ??
                        this.appConfig.currentProxyName ?? '',
                        OnProxyChange: (item) => {
                          this.changeProxy(group.name, item)
                        }
                      })
                        .width('100%')
                        .height('100%')
                        .padding({
                          bottom: this.isPXSecScreen || (this.isSmallSquareScreen && this.isRolling) ? 0 :
                            !this.uiConfig.isBlurr ? CONTENT_END_OFFSET_150 - 100 : CONTENT_END_OFFSET_150 - 50
                        })
                      // .onAppear(() => {
                      //promptAction.showToast({message: `当前选中：${this.currentProfile?.getSelectedProxy(group) ?? ""}`, duration: 2000 })
                      //  hilog.info(0xFF00, "ProxyPageGroupTag", "#onAppear %{public}s", group.proxies.toString())
                      // hilog.info(0xFF00, "ProxyPageGroupTag", "#onAppear hidden: %{public}s %{public}d", group.hidden, index)
                      //})
                      // .onDisAppear(() => {
                      //   hilog.info(0xFF00, "ProxyPageGroupTag", "#onDisAppear %{public}s", group.toString())
                      // })
                    }, (item: ProxyGroup) => item.name + Date.now())
                  }
                  .index(this.currentProxyIndex)
                  .loop(false)
                  .effectMode(EdgeEffect.None)
                  .nestedScroll(SwiperNestedScrollMode.SELF_FIRST)
                  .cachedCount(0)
                  .indicator(false)
                  .alignSelf(ItemAlign.Center)
                  .onGestureSwipe((index: number, extraInfo: SwiperAnimationEvent) => {
                    hilog.info(0xFF00, "ProxyPagePanTag", "currentOffset: %{private}d", extraInfo.currentOffset)
                    this.getUIContext().animateTo({ duration: this.uiConfig.animationSpeed }, () => {
                      // 当主tab栏竖排时不触发切换
                      // hilog.info(0xFF00, "ProxyLandscapeTag", "tab栏竖排状态: %{public}s", this.compVertical.value)
                      // hilog.info(0xFF00, "ProxyLandscapeTag", "手机横屏状态状态: %{public}s", this.isLandscapePhone)
                      if (TabBarVertical(this.widthBp, this.heightBp)) {
                        if (this.currentProxyIndex === 0 && extraInfo.currentOffset > 79) {
                          indexController.changeIndex(0)
                        } else if (this.currentProxyIndex === this.proxyGroups.totalCount() - 1 &&
                          extraInfo.currentOffset < -79) {
                          indexController.changeIndex(2)
                        }
                      }
                    })
                  })
                  .onAnimationStart((index: number, targetIndex: number) => {
                    this.getUIContext().animateTo({ duration: this.uiConfig.animationSpeed }, () => {
                      this.ListScroller.scrollToIndex(targetIndex)
                      //  this.tabsController.changeIndex(targetIndex)
                      this.currentProxyIndex = targetIndex
                      if (this.currentProfile) {
                        this.currentProfile.currentGroupName = this.proxyGroups.getData(this.currentProxyIndex).name
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
                    .padding({ bottom: !this.uiConfig.isBlurr ? 20 : 50 })
                }
              }.width('100%')
              .height('100%')
              .alignItems(HorizontalAlign.Center)

              // 列表排列页 End
            }
            .width('100%')
            .height('100%')
            .scrollBar(BarState.Off)
            .enableScrollInteraction(this.isPXSecScreen ? false : true)
            .edgeEffect(this.uiConfig.isAnimation ? EdgeEffect.Spring : null)
            .padding({
              left: TabContentTitleMargin(this.widthBp, this.heightBp),
              right: TabContentTitleMargin(this.widthBp, this.heightBp)
            })
            .onDidScroll((xOffset: number, yOffset: number, scrollState: ScrollState): void => {
              // 累计计算当前父组件滚动在Y轴方向的偏移量
              if (this.uiConfig.isAnimation) {
                this.curYOffset += yOffset
              }
              // hilog.info(0xFF00, "ProxyPageTag", "yOffset: %{public}d", this.curYOffset)
            })
            .onScrollFrameBegin((offset: number) => {
              this.curOffsetRemain += offset
              if (offset > 0) {
                this.isRolling = true
              } else if (offset < 0) {
                this.isRolling = false
                this.curOffsetRemain = 0
              }
              // console.info("offsetRemain:" + offset + '/' + this.curOffsetRemain);
              return { offsetRemain: offset }
            })
          }

          // 悬浮代理测速按钮 START — 按位置选择转场与按钮顺序，三元简化判断
          if (!this.isPXSecScreen && this.uiConfig.isFloatButtonVisible) {
            Row({ space: 7 }) {
              // 判断是否需要显示启动按钮
              if (this.uiConfig.buttonPositionIndex !== 1 &&
                this.uiConfig.needProxyStart &&
                this.uiConfig.tabStyle == 'custom') {
                // 左侧按钮
                if (this.uiConfig.buttonPositionIndex === 2) {
                  this.startButton()
                }
                this.delayButton()
                // 右侧按钮
                if (this.uiConfig.buttonPositionIndex === 0) {
                  this.startButton()
                }
              } else {
                this.delayButton()
              }
            }.height(50)
            .alignItems(VerticalAlign.Center)
            .backgroundColor(Color.Transparent)
            .transition(customAnimationUtil.getFloatButtonTransition(this.uiConfig, this.uiConfig.buttonPositionIndex))
            .margin({
              bottom: Xb_TabBarVertical(this.widthBp, this.heightBp) || this.uiConfig.tabStyle == 'custom' ? 15 : this.bottomRectHeight == 0 ? 85 : this.bottomRectHeight + 63.5,
              right: $r('app.integer.vp_proxy_start_button_left_right_margin'),
              left: $r('app.integer.vp_proxy_start_button_left_right_margin')
            })
          }
          // 悬浮代理测速按钮 END
        }
        .backgroundColor($r('app.color.background'))
        .width('100%')
        .height('100%')
        // 主体 END
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
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
      },
      onWillSpringBackWhenDismiss: () => {} // 注册回调，防止反向回弹
    })
  }

  // 测速按钮
  @Builder
  delayButton() {
    Column() {
      if (this.uiConfig.tabStyle == 'float') {
        Row() {
          SymbolGlyph($r('sys.symbol.bolt_filled_on_circle'))
            .fontSize(27).fontColor([icon_tertiary])
        }
        .backdropBlur(this.uiConfig.isBlurr ? 30 : 0)
        .backgroundColor(this.uiConfig.isBlurr ? $r('app.color.float_tab_background_blur') : $r('app.color.background'))
        .borderRadius(30)
        .size({width: 50, height: 50})
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .shadow({
          radius: 15,
          offsetY: 4,
          color: $r('app.color.shadow_button'),
          type: ShadowType.COLOR
        })
        .transition(customAnimationUtil.getFloatButtonTransition(this.uiConfig, this.uiConfig.buttonPositionIndex))
      }
      else if (this.uiConfig.buttonPositionIndex === 1 || !this.uiConfig.needProxyStart) {
        RoundButton({
          needMargin: false,
          Icon2: $r('sys.symbol.bolt_filled_on_circle'),
        })
      }
      else {
        ButtonBuilder({
          enableClick: false,
          icon: $r('sys.symbol.bolt_filled_on_circle')
        })
          .offset({y: 3})
      }
    }
    .bindPopup(!!this.isShowDelayPop, {
      builder: PopupBuilder(this, PopTips[3], () => {
        this.isShowDelayPop = false
      }),
      onWillDismiss: false,
      autoCancel: false
    })
    .onClick(async () => {
      EventHub.sendEvent(EventKey.TestAllDelay)
    })
  }
  // 开始按钮
  @Builder
  startButton() {
    RoundButton({
      needMargin: false,
      Icon1: $r('sys.symbol.pause'),
      Icon2: $r('sys.symbol.play_fill'),
      Switch: this.proxyEnabled,
      SubText: this.proxyStartingDuration
    })
      .onClick(async () => {
        // 触发代理启动事件
        EventHub.sendEvent(EventKey.ChangeProxy)
      })
      .bindPopup(!!this.uiConfig.ShowStartPop, {
        builder: PopupBuilder(this, PopTips[0], () => {
          this.uiConfig.ShowStartPop = false
        }),
        onWillDismiss: false,
        autoCancel: false
      })
  }
  // 标题按钮
  @Builder
  ButtonBuilder(icons: Resource, onCheck: () => void ) {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph(icons)
        .fontSize(24)
        .fontColor([icon_primary])
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
      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.Center,
        alignItems: ItemAlign.Center
      })
      {
        Text(`${title}`) // ${targetIndex}
          .fontColor(this.currentProxyIndex === targetIndex ? font_on_primary : font_secondary)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .padding({left: 6, right: 6})
          .fontSize(14)
          .maxLines(1)
      }
      .constraintSize({minWidth: 86})
      .borderRadius(BORDER_RADIUS_20)
      .height(this.currentProxyIndex === targetIndex ? 36 : 32)
      .backgroundColor(this.currentProxyIndex === targetIndex ? this.icon_emphasize : container_background)
    }
    .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
    .height(55)
    .margin({ right: 8, bottom: 10 })
    .onClick(() => {
      this.getUIContext().animateTo({ duration: this.uiConfig.animationSpeed }, () => {
        this.currentProxyIndex = targetIndex
      })
      this.SwiperController.changeIndex(targetIndex, this.uiConfig.animationSpeed != 0 ? true : false)
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
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

  aboutToAppear(): void {
    hilog.info(0xB000, componentName, `#aboutToAppear`)
    this.isShowDelayPop = this.uiConfig.ShowDelayPop
    /*if (this.currentProfile) {
      let tabIndex = this.theProxyGroups.findIndex((d) => d.name == this.currentProfile?.currentGroupName)
      setTimeout(() => {
        if (tabIndex > -1 && this.currentProxyIndex === 0) {
          this.ListScroller.scrollToIndex(tabIndex)
          this.currentProxyIndex = tabIndex
          this.SwiperController.changeIndex(this.currentProxyIndex)
        } else {
          this.ListScroller.scrollToIndex(this.currentProxyIndex)
          this.SwiperController.changeIndex(this.currentProxyIndex)
        }
      }, 200)
    }*/
    EventHub.on(EventKey.TestAllDelay, async () => {
      Xb_ToastUtil.showToast({ message: $r('app.string.Test_Delay_Tip') })
      let results: number[] = []
      try {
        results = await ClashViewModel.testAllDelay(this.proxyGroups.getData(this.currentProxyIndex).proxies as ProxyItem[])
        console.log(`ProxySort results: ${JSON.stringify(results)}`)
        // 测速完成后如果配置为延迟排序则触发一次排序事件
        if (this.appConfig.proxySort === ProxySort.Delay && results) {
          this.needChangeSort = true
        }
        // 卡片延迟
        const delay = ClashViewModel.delayMap.get(this.appConfig.currentProxyItem?.name ?? '')?.delay ?? 0
        cardManager.pushCartDelay(delay)
      } catch (err) {
        if (this.appConfig.proxySort === ProxySort.Delay && results) {
          this.needChangeSort = true
        }
        console.error(`ProxySort message: ${err.message}, code: ${err.code}`)
      }
      if (!results) {
        Xb_ToastUtil.showToast({ message: `延迟测试失败，请检查测试用链接`, duration: 3000})
      }
      if (this.uiConfig.isVibrate) {
        customVibrator.vibratorTriggerOfHapticClockTimer()
      }
    })
  }

  aboutToDisappear() {
    EventHub.off(EventKey.TestAllDelay)
    EventHub.off(EventKey.TestDelay)
    this.uiConfig.ShowDelayPop = this.isShowDelayPop
  }

  changeProxy(group: string, item: ProxyItem) {
    console.debug(`FavoriteProxy [ProxyPage] Group：${group} node: ${item.name}`)
    if (this.currentProfile) {
      ClashViewModel.changeProxy(this.currentProfile, group, item.name)
      // 首选项持久化存储 -> 供卡片使用
      cardManager.setSelectedProxyNode(this.currentProfile, group, item.name)
    }
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
