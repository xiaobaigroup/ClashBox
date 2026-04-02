// 主页 栅格布局、二维断点
import { curves } from '@kit.ArkUI'
import SwitchMode from '../components/Home/SwitchMode'
import CellularData from '../components/Home/CellularData'
import PublicNetwork from '../components/Home/PublicNetwork'
import Speed from '../components/Home/Speed'
import { getGreeting } from '../common/utils/GreetingUtil'
import { hilog } from '@kit.PerformanceAnalysisKit'
import {
  BIND_SHEET_CONTAINER_HEIGHT,
  TAB_CONTENT_TITLE_HEIGHT,
  showHomeCard,
  showHomeCardPC,
  HomeCards,
  BIND_SHEET_TITLE_CONTAINER_HEIGHT,
  BIND_SHEET_DRAG_BAR_HEIGHT,
  LIST_SPACE,
  LIST_ITEM_PADDING,
  BORDER_RADIUS_20,
} from '../common/entity/Constants'
import Settings from '../components/Settings/Settings'
import CurrentNode from '../components/Home/CurrentNode'
import FavoriteProxy from '../components/Home/FavoriteProxy'
import FavoriteConfiguration from '../components/Home/FavoriteConfiguration'
import { CardEdit } from '../components/Home/CardEdit'
import ProxyINFO from '../components/Home/ProxyINFO'
import CurrentConfiguration from '../components/Home/CurrentConfiguration'
import ClashViewModel from '../entryability/ClashViewModel'
import Shortcuts from '../components/Home/Shortcuts'
import { AppConfig, UIConfig } from '../entryability/AppState'
import { ConfigData, HomeCardInfo } from '../common/entity/PageArgumentEntity'
import { customVibrator } from '../common/utils/VibratorUtil'
import { customAnimationUtil } from '../common/utils/Animation'
import { Profile, ProxyMode } from 'proxy_core'
import { ProxyGroupItemDataSource, ProxyItemDataSource } from '../common/datasources/ProxyData'
import { EventHub, EventKey } from '../common/EventHub'
import { PopTips, PopupBuilder } from '../components/Start/Popup'
import { getResourceString } from '../common/utils/ResourceStringUtil'
import { TopBar } from '../components/Common/TopBar'
import {
  HomeCardDeleteButtonSize,
  HomeCardGutter,
  HomeCardSpan346lg, HomeCardSpan346md, HomeCardSpan36sm,
  HomeGridRowPadding,
  HomeTopHeight,
  NavigationListPadding,
  WindowHomeGridRowPadding } from '../common/breakpoint/BreakPoint'
import { RoundButton } from '../components/Common/RoundButton'
import { Xb_GetResourceString, Xb_ToastUtil } from 'xb_components'
import { Xb_AnimationStyle } from 'xb_components'
import { sortByCustomOrder } from '../common/utils/SortUtil'


@Entry
@Component
struct Home {
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 是否开启 `Index` 页面的前景模糊
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  // 编辑按钮点击后显示编辑状态判定
  @Consume @Watch('ShowHomeEditChange') isShowHomeEdit: boolean
  // 前台判断变量
  @StorageProp('ForwardState') @Watch('onForward') isForward: boolean = true
  @Consume isSmallSquareScreen: boolean
  // 删除按钮是否出现判定
  @Consume isShowDeleteButton: boolean
  // 平板横屏
  @Consume istabletLandscape: boolean
  // 编辑卡片半模态页控制变量
  @Consume @Watch('ShowHomeEditChange') isShowCardEdit: boolean
  // 是否为PX外屏
  @Consume isPXSecScreen: boolean
  // 代理启动按钮状态
  @Consume proxyEnabled: boolean
  @Consume isHomePage: boolean
  @Consume isRolling: boolean

  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageLink ('isLandscapePhone') @Watch('isLandscapePhoneScrollTo') isLandscapePhone: boolean = false
  // 弹窗时背景模糊
  @StorageLink('CustomDialog') showCustomDialogBackgroundBlur: boolean = false
  @StorageProp('EnableAPIVersion') apiVersionEnable: boolean = false
  // 折叠屏展开状态判定
  @StorageLink ('isFoldStatus') isFoldStatus: boolean = false
  // 窗口模式区分，true为窗口式，false为普通式
  @StorageProp('WindowMode') windowMode: boolean = false
  // 2in1判定
  @StorageLink ('2in1') is2in1: boolean = false
  // 主页半模态页
  @State showHomeSheet: boolean = false
  // 排序半模态显示
  @State showCardSort: boolean = false

  // 所有子组件在容器内的对齐方式
  @Consume ('stackAlignContentAlignment') stackAlignContentAlignment: Alignment
  // 设置页面栈
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack

  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 滚动控制
  private scrollerForScroll: Scroller = new Scroller()
  private uiContext = this.getUIContext()!

  // 代理页分组数据（懒加载）
  @Consume proxyGroups: ProxyGroupItemDataSource
  // 节点数据
  @Consume proxyLazyItems: ProxyItemDataSource
  // 配置页数据表
  @Consume('Configuration') configList: Array<ConfigData>
  // 当前主页布局
  @Consume theCurrentHomeCard: string[]
  // 上一次主页布局
  @Consume theLastHomeCard: string[]

  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 状态栏高度
  @StorageProp('topRectHeight') topRectHeight: number = 0
  // 当前触摸序号
  @State currentTouchIndex: number = 0

  // 代理启动持续的时间
  @StorageProp('proxyStartingDuration') proxyStartingDuration: string = ''
  @Consume ("currentProfile") currentProfile: Profile | null
  // 页面名称 主页
  private componentName: string = 'HomePage'
  // 主界面当前index
  @Consume tabCurrentPage: number
  @Consume curOffsetRemain: number
  // 恢复时刻
  @Consume theRestoreTime: number
  // 暂停时刻
  @Consume thePauseTime: number
  @Consume rotateAngle : number
  // page内顶部标题偏移量
  @Consume curYOffset: number
  // 小窗口隐藏top和tab偏移
  @Consume heightTop: number
  @Consume homeCardList: HomeCardInfo[]

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 标题栏
      Row() {
        if (!this.isShowHomeEdit) {
          // 编辑布局按钮判定：非编辑状态
          // 顶栏
          TopBar({
            title: this.uiConfig.isGreeting ? Xb_GetResourceString(getGreeting(), this) : 'ClashBox',
            icons: [$r('sys.symbol.square_and_pencil'), $r('sys.symbol.gearshape')],
            iconSize: this.windowMode ? 18 : (this.curYOffset < 0 ? 24 - this.curYOffset / 100 : 24),
            // 编辑按钮
            onFClick: () => {
              this.isShowHomeEdit = true
              // 编辑布局前储存之前的布局变量
              hilog.info(0xFF00, "HomeTestTag", "上一次布局1： %{public}s", JSON.stringify(this.theLastHomeCard))
              this.theLastHomeCard = JSON.parse(this.uiConfig.isShowHomeCard)
              hilog.info(0xFF00, "HomeTestTag", "上一次布局2： %{public}s", JSON.stringify(this.theLastHomeCard))
              if (this.uiConfig.isAnimation) {
                this.uiContext.animateTo({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear }, () => {
                  this.isShowDeleteButton = true
                })
              } else {
                this.isShowDeleteButton = true
              }
            },
            // 设置按钮
            onSClick: () => {
              this.isShowCardEdit = false
              this.showHomeSheet = true
              this.isEnableIndexForegroundBlur = true
            }
          })
        } else {
          // 编辑布局按钮判定：是编辑状态
          TopBar({
            title: `${getResourceString($r('app.string.home_edit'), this)}`,
            titleFontSize: this.windowMode ? 20 : 24,
            iconSize: this.windowMode ? 18 : (this.curYOffset < 0 ? 24 - this.curYOffset / 100 : 24),
            icons: [$r('sys.symbol.sort'), $r('sys.symbol.plus'), $r('sys.symbol.save'), $r('sys.symbol.xmark')],
            // 排序按钮
            onFClick: () => {
              this.isShowCardEdit = true
              this.showCardSort = true
              this.showHomeSheet = true
              this.isEnableIndexForegroundBlur = true
            },
            // 添加按钮
            onSClick: () => {
              this.isShowCardEdit = true
              this.showHomeSheet = true
              this.isEnableIndexForegroundBlur = true
            },
            onTClick: () => {
              this.saveHomeLayout()
            },
            onFoClick: () => {
              if (this.SaveDialogController != null) {
                this.SaveDialogController.open()
                this.isEnableIndexForegroundBlur = true
              }
            }
          })
        }

      }
      .zIndex(1)
      .width('100%')
      .geometryTransition("Button")
      .backgroundColor($r('app.color.background'))
      .height(this.windowMode ? undefined : (this.curYOffset < 0 ? TAB_CONTENT_TITLE_HEIGHT - this.curYOffset : TAB_CONTENT_TITLE_HEIGHT))
      .margin({ top: this.topRectHeight == 0 ? 0 : HomeTopHeight(this.widthBp, this.heightBp) })
      .position(this.windowMode ? undefined : {x: 0, y: this.isRolling && this.isSmallSquareScreen ? this.heightTop : 0})

      // 内容区
      Stack({ alignContent: this.stackAlignContentAlignment }) {
        // 主页卡片
        Scroll() {
          Column() {
            Row()
              .height(56)
            GridRow({
              columns: 12,
              gutter: HomeCardGutter(this.widthBp, this.heightBp),
            })
            {
              ForEach(this.homeCardList, (item: HomeCardInfo, index: number) => {
                HomeCard({
                  item: item,
                  index: index
                })
              }, /*(item: HomeCardInfo) => item.key*/)
            }
            Blank().height(100)
          }
        }
        .height('100%')
        .width("100%")
        .layoutWeight(1)
        .align(Alignment.Top)
        .scrollBar(BarState.Off)
        .enableScrollInteraction(true)
        .padding(this.windowMode ? WindowHomeGridRowPadding(this.widthBp, this.heightBp) : HomeGridRowPadding(this.widthBp, this.heightBp))
        .edgeEffect(this.uiConfig.isAnimation ? EdgeEffect.Spring : null)
        .onScrollFrameBegin((offset: number) => {
          this.curOffsetRemain += offset
          if (offset > 0) {
            this.isRolling = true
          } else if (offset < 0) {
            this.isRolling = false
            this.curOffsetRemain = 0
          }
          // console.info("offsetRemain:" + offset + '/' +this.curOffsetRemain);
          return { offsetRemain: offset }
        })
        .onDidScroll((xOffset: number, yOffset: number, scrollState: ScrollState): void => {
          if (!this.windowMode) {
            // 累计计算当前父组件滚动在Y轴方向的偏移量
            if (this.uiConfig.isAnimation){
              this.curYOffset += yOffset
            }
            // console.info("yOffset:" + yOffset)
          }
        })

        // 代理启动按钮层
        if ((!this.isShowHomeEdit && this.uiConfig.tabStyle == 'custom') || (this.widthBp > 2 && this.proxyEnabled) || !this.apiVersionEnable) {
          RoundButton({
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

      }
      .backgroundColor($r('app.color.background'))
      .height('100%')
      .width("100%")
      .bindSheet($$this.showHomeSheet, this.HomeSheet(), {
        detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.LARGE],
        preferType: SheetType.CENTER,
        scrollSizeMode: ScrollSizeMode.CONTINUOUS,
        backgroundColor: $r('app.color.background'),
        dragBar: false,
        title: this.isShowCardEdit && !this.showCardSort ? { title: $r('app.string.add_home_card') } : undefined,
        keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
        onWillDismiss: () => {
          this.isShowCardEdit = false
          this.showHomeSheet = false
          this.showCardSort = false
          this.isEnableIndexForegroundBlur = false
          this.SettingsPageInfos.clear()
        },
        onWillSpringBackWhenDismiss: () => {} // 注册回调，防止反向回弹
      })
    }.width('100%').height('100%')
  }

  @Builder
  HomeSheet() {
    if (this.isShowCardEdit) {
      if (this.showCardSort) {
        // 卡片排序
        this.SortBuilder()
      } else {
        // 卡片编辑半模态
        CardEdit()
      }
    } else {
      // 设置模态界面
      Column() {
        Settings()
      }
      .width('100%')
      .height('100%')
      .foregroundBlurStyle(this.showCustomDialogBackgroundBlur && this.uiConfig.isBlurr ? BlurStyle.Thin : BlurStyle.NONE,
        { colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 0.3 })
    }
  }

  @Builder
  SortBuilder() {
    Column() {
      Row() {
        Text($r('app.string.sort'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))
          .textOverflow({overflow: TextOverflow.MARQUEE})
          .animation({ duration: this.uiConfig.animationSpeed, curve: Curve.Ease })
      }.width('100%')
      .margin({ left: 5 })
      .alignItems(VerticalAlign.Center)
      .height(BIND_SHEET_TITLE_CONTAINER_HEIGHT + BIND_SHEET_DRAG_BAR_HEIGHT)
      .padding({
        left: NavigationListPadding(this.widthBp, this.heightBp),
        right: NavigationListPadding(this.widthBp, this.heightBp)
      })
      List({ space: LIST_SPACE }) {
        ForEach(this.homeCardList, (item: HomeCardInfo, index: number) => {
          ListItem() {
            Row() {
              // 名称
              Text(item.name).fontColor(($r('sys.color.font_primary'))).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
              SymbolGlyph($r('sys.symbol.sort'))
                .fontSize(24)
                .fontColor([$r('sys.color.font_primary')])
            }
            .height(56)
            .width('100%')
            .padding(LIST_ITEM_PADDING)
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
          .backgroundColor($r('app.color.container_background'))
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .borderRadius(BORDER_RADIUS_20)
          .hoverEffect(HoverEffect.Scale)
        }, (item: HomeCardInfo) => item.key)
          .onMove((from: number, to: number) => {
            let tmp = this.homeCardList.splice(from, 1)
            this.homeCardList.splice(to, 0, tmp[0])
            const currentCards = this.theCurrentHomeCard.splice(from, 1)
            this.theCurrentHomeCard.splice(to, 0, currentCards[0])
            // 更新保存的排序表
            // this.uiConfig.isShowHomeCard = JSON.stringify(this.homeCardList.map(id => id.key))
            // console.info(`HomeCardSort uiConfig.isShowHomeCard 更新为，${this.uiConfig.isShowHomeCard}`)
          })
      }
      .width('100%')
      .contentEndOffset(86)
      .padding({
        left: NavigationListPadding(this.widthBp, this.heightBp),
        right: NavigationListPadding(this.widthBp, this.heightBp)
      })
    }
    .width('100%')
    .height('100%')
  }

  /**是否保存布局弹窗*/
  SaveDialogController: CustomDialogController | null = new CustomDialogController({
    builder: SaveCustomDialog({
      cancel: () => {
        this.onCancel()
        this.uiContext.animateTo({ duration: 0,iterations:0 }, () => {
          this.rotateAngle = 0
        })
      },
      confirm: () => {
        this.onAccept()
        this.uiContext.animateTo({ duration: 0,iterations:0 }, () => {
          this.rotateAngle = 0
        })
      }
    }),
    cancel: this.existApp,
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: false,
    cornerRadius: 32,
  })

  aboutToAppear(): void {
    // 初始化主页卡片布局
    if (this.uiConfig.isShowHomeCard)
      this.theCurrentHomeCard = JSON.parse(this.uiConfig.isShowHomeCard)
    hilog.info(0xFF00, "HomeTestTag", "布局初始化为： %{public}s", JSON.stringify(this.theCurrentHomeCard))
    this.homeCardList = sortByCustomOrder(HomeCards.filter(value => this.theCurrentHomeCard.includes(value.key)), this.theCurrentHomeCard, 'key')
    if (this.tabCurrentPage == 0) {
      this.isHomePage = true
    }
    EventHub.on(EventKey.SwitchModeCard, async (mode: ProxyMode) => {
      // 清空数据
      this.proxyGroups.empty()
      this.proxyLazyItems.empty()
      if (this.currentProfile) {
        await ClashViewModel.loadConfig(true, 'HomePage-EventKey.SwitchModeCard')
        // 写入数据
        const proxyData = await ClashViewModel.getProxyGroups(mode)
        this.proxyGroups.pushData(proxyData)
      }
    })
    // 注册代理启动事件
    EventHub.on(EventKey.ChangeProxy, () => {
      this.switchProxyMode()
    })
    // 只有当PC首次启动时重置主页布局
    if (this.is2in1 && this.uiConfig.isShowHomeCard === JSON.stringify(showHomeCard)) {
      this.theCurrentHomeCard = showHomeCardPC
      // 更新PC布局持久化, 避免二次启动重复调用覆盖
      this.uiConfig.isShowHomeCard = JSON.stringify(showHomeCardPC)
    }
  }

  aboutToDisappear() {
    // 将dialogController置空
    this.SaveDialogController = null
    EventHub.off(EventKey.SwitchModeCard)
  }

  /** @description 切换代理状态 */
  async switchProxyMode() {
    if (this.configList.length === 0 || this.proxyGroups.totalCount() === 0) {
      if (this.uiConfig.isVibrate) {
        customVibrator.vibratorTriggerOfHapticClockTimer()
      }
      // 配置页没有数据，或者代理节点未加载
      Xb_ToastUtil.showToast({message: $r('app.string.start_prompt')})
      // vpn小钥匙可能卡死，关闭vpn小钥匙
      await ClashViewModel.StopVpn()
    } else {
      this.proxyEnabled = !this.proxyEnabled
      hilog.info(0xA002, this.componentName, `主页按钮点击后 代理启动按钮状态：${this.proxyEnabled}`)
      if (this.proxyEnabled) {
        await ClashViewModel.StartVpn()
      } else {
        console.log(`Home BackgroundDownService Clash已经停止`)
        await ClashViewModel.StopVpn()
      }
      if (this.uiConfig.isVibrate) {
        customVibrator.vibratorTriggerOfHapticClockTimer()
      }
    }
  }

  // 在自定义组件即将析构销毁时将dialogController置空
  onCancel() {
    this.restoreLayout()
    this.isEnableIndexForegroundBlur = false
    hilog.info(0xA000, this.componentName, '#onCancel: Callback when the first button is clicked')
  }

  onAccept() {
    this.saveHomeLayout()
    this.isEnableIndexForegroundBlur = false
    hilog.info(0xA000, this.componentName, '#onAccept: Callback when the second button is clicked')
  }

  existApp() {
    this.isEnableIndexForegroundBlur = false
    hilog.info(0xA000, this.componentName, '#existApp: Click the callback in the blank area')
  }

  /** 横屏HOME页滚动到中间 */
  isLandscapePhoneScrollTo() {
    if (this.isLandscapePhone) {
      this.scrollerForScroll.scrollTo({xOffset: 0,yOffset: '50%',animation: true})
    }
  }

  // 卡片摇摆动画
  startAnim() {
    this.rotateAngle = 0
    Xb_AnimationStyle.animToCustomAPI18({
      duration: this.uiConfig.animationSpeed,
      curve: Curve.Linear,
      iterations:-1,
      playMode:PlayMode.Alternate
    }, () => {
      this.rotateAngle = 1
    })
  }

  stopAnim() {
    Xb_AnimationStyle.animToCustomAPI18({
      delay: 0,
      duration: 0,
      iterations: 0,
      curve: Curve.Linear,
    }, () => {
      this.rotateAngle = 0
    })
  }

  /**保存主页卡片布局*/
  saveHomeLayout() {
    // 保存布局
    this.uiConfig.isShowHomeCard = JSON.stringify(this.theCurrentHomeCard)
    hilog.info(0xFF00, "HomeTestTag", "保存的布局： %{public}s", this.uiConfig.isShowHomeCard)
    Xb_ToastUtil.showToast({ message: `${Xb_GetResourceString($r('app.string.layout_saved'), this)}💾` })
    this.isShowHomeEdit = false
    if (this.uiConfig.isAnimation) {
      Xb_AnimationStyle.animToAPI18(() => {
        this.isShowDeleteButton = false
      }, this.uiConfig.animationSpeed, 'app', 0, Curve.Linear)
    } else { this.isShowDeleteButton = false }
  }

  /**还原主页卡片布局*/
  restoreLayout() {
    // 还原布局
    this.theCurrentHomeCard = this.theLastHomeCard
    this.uiConfig.isShowHomeCard = JSON.stringify(this.theLastHomeCard)
    this.homeCardList = sortByCustomOrder(HomeCards.filter(value => this.theCurrentHomeCard.includes(value.key)), this.theCurrentHomeCard, 'key')
    hilog.info(0xFF00, "HomeTestTag", "布局还原为： %{public}s", JSON.stringify(this.theCurrentHomeCard))
    Xb_ToastUtil.showToast({ message: `${Xb_GetResourceString($r('app.string.layout_restored'), this)}🫡` })
    this.isShowHomeEdit = false
    Xb_AnimationStyle.animToAPI18(() => {
      this.isShowDeleteButton = false
    }, this.uiConfig.animationSpeed, 'app', 0, Curve.Linear)
  }

  /** 卡片编辑页面显示监听 */
  ShowHomeEditChange() {
    hilog.info(0xFF00, "HomeTestTag", "进入卡片编辑页面显示监听  %{public}s")
    if (this.isShowHomeEdit && !this.isShowCardEdit) {
      this.stopAnim()
      this.startAnim()
    }else{
      this.stopAnim()
    }
    console.info('编辑按钮状况：', this.isShowHomeEdit)
  }

  onForward() {
  }

}

export default Home

@Component
struct HomeCard {

  @Prop index: number
  @Prop item: HomeCardInfo
  @Consume isHomePage: boolean
  @Consume rotateAngle : number
  @Consume homeCardList: HomeCardInfo[]
  // 删除按钮是否出现判定
  @Consume isShowDeleteButton: boolean
  // 当前主页布局
  @Consume theCurrentHomeCard: string[]
  // 前台判断变量
  @StorageProp('ForwardState') isForward: boolean = true
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0

  build() {
    GridCol({
      span: {
        sm: HomeCardSpan36sm(this.widthBp, this.heightBp) * this.item.spanMultiple,
        md: HomeCardSpan346md(this.widthBp, this.heightBp) * this.item.spanMultiple,
        lg: HomeCardSpan346lg(this.widthBp, this.heightBp) * this.item.spanMultiple
      },
      order: this.index
    })
    {
      Stack({ alignContent: Alignment.TopEnd }) {
        // 卡片主体
        this.HomeCardContent(this.item.key)
        // 删除角标
        if (this.isShowDeleteButton) {
          DeleteButton()
            .position({ x: this.item.spanMultiple == 2 ? '95%' : '92%', y: -4 })
            .onClick(() => {
              Xb_AnimationStyle.animToAPI18(() => {
                const index = this.homeCardList.findIndex(value => this.item.key == value.key)
                this.homeCardList.splice(index, 1)
                const keyIndex = this.theCurrentHomeCard.findIndex(value => this.item.key == value)
                this.theCurrentHomeCard.splice(keyIndex, 1)
              }, this.uiConfig.animationSpeed, 'app', 0, Curve.Linear)
            })
        }
      }
    }
    .height(160)
    .borderRadius(20)
    .aspectRatio(this.item.aspectRatio)
    .backgroundColor($r('app.color.container_background'))
    // .borderWidth(2).borderColor(Color.Red)
    .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
    .transition(customAnimationUtil.isScaleTran(this.index, this.uiConfig))
    // 消失触发回调
    // .onDetach(() => {
    //   console.log(`HomeCard 前后台状态：${this.isForward} 当前注销：${this.index}`)
    // })
    // 显示时触发回调
    .onAttach(() => {
      console.log(`HomeCard 前后台状态：${this.isForward} 当前显示sm：${HomeCardSpan36sm(this.widthBp, this.heightBp) * this.item.spanMultiple}`)
    })
    // 编辑模式下跳动动画
    .rotate({ angle: this.uiConfig.isAnimation ? this.rotateAngle : null })
  }

  @Builder
  HomeCardContent(key: string) {
    if (key === 'speed') {
      Speed()
    } else if (key === 'mode') {
      SwitchMode()
    } else if (key === 'data') {
      CellularData()
    } else if (key === 'node') {
      CurrentNode()
    } else if (key === 'ip') {
      PublicNetwork()
    } else if (key === 'f_node') {
      FavoriteProxy()
    } else if (key === 'f_config') {
      FavoriteConfiguration()
    } else if (key === 'config') {
      CurrentConfiguration()
    } else if (key === 'fast') {
      Shortcuts()
    } else if (key === 'node_info') {
      ProxyINFO()
    }
  }

}

/**
 * 保存样式和内容弹窗控制器
 */
@CustomDialog
struct SaveCustomDialog {
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  controller?: CustomDialogController
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean

  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  build() {
    Column() {
      Text($r('app.string.home_save_layout'))
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))

      Row() {
        Button($r('app.string.Give_Up'))
          .fontSize(16)
          .width(144)
          .fontColor(Color.Red)
          .backgroundColor('#00ffffff')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
            }
            this.cancel()
            this.isEnableIndexForegroundBlur = false
          })
        Blank(8)
        Button($r('app.string.Save'))
          .fontSize(16)
          .width(144)
          .backgroundColor(this.icon_emphasize)
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
            }
            this.confirm()
            this.isEnableIndexForegroundBlur = false
          })
      }.padding({ top: 23 })
    }
    .width('100%')
    .height(undefined)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.container_background'))
    .padding({ top: 16, bottom: 16 })
  }

}

// 小卡片共有属性
@Extend(GridCol)
function GridColStyle() {
  .aspectRatio(1)
  .borderRadius(20)
  .backgroundColor($r('app.color.container_background'))
}

// 网络测速大卡片里的删除按钮
@Component
struct DeleteButton {
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageLink ('isLandscapePhone') private isLandscapePhone: boolean = false
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 折叠屏展开状态判定
  @StorageLink ('isFoldStatus') private isFoldStatus: boolean = false
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  build() {
    Button() {
      SymbolGlyph($r('sys.symbol.xmark'))
        .fontSize(16)
        .fontColor(['#fff'])
    }
    .borderRadius(20)
    .width(HomeCardDeleteButtonSize(this.widthBp, this.heightBp))
    .height(HomeCardDeleteButtonSize(this.widthBp, this.heightBp))
    .backgroundColor('#ffe84026')
    .transition(this.uiConfig.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: this.uiConfig.animationSpeed,curve:curves.springMotion() }):null)
  }
}


