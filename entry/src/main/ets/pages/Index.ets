// Index
import { curves, LengthMetrics, mediaquery } from '@kit.ArkUI'
import Home from './HomePage'
import ProxyPage from './ProxyPage'
import { util } from "@kit.ArkTS";
import ConfigurationPage from './ConfigurationPage'
import MorePage from './MorePage'
import { hilog } from '@kit.PerformanceAnalysisKit'
import {
  PROXY_STARTED_DURATION_INIT_VALUE,
  ListMoreData,
  moreData,
  AboutListItemProp,
  BIND_SHEET_CONTAINER_HEIGHT,
  DefaultUpdateInfo,
  CHART_NUMBER,
  TheExperimentData,
  TAB_CONTENT_TITLE_HEIGHT,
  LogData,
  showHomeCard,
  NewConfigData,
  BundleInfo,
  HomeCards,
  filterStringsByBooleans,
  convertMillisecondsToTimeGap,
} from '../common/entity/Constants'
import { ProxyItem, ProxyData, ProxyGroupItemDataSource, ProxyItemDataSource } from '../common/datasources/ProxyData'
import { ClashConfig, IpInfo, Profile, ProxyMode } from 'proxy_core'
import { EventHub, EventKey } from '../common/EventHub'
import ClashViewModel from '../entryability/ClashViewModel'
import { AppConfig, AppFlowingState, AppState, getPackageInfo, UIConfig } from '../entryability/AppState'
import { common } from '@kit.AbilityKit'
import { ChangeLanguage } from '../common/utils/ChangeLanguageUtil'
import { ConfigData, HomeCardInfo, TabBuild } from '../common/entity/PageArgumentEntity'
import { customAnimationUtil } from '../common/utils/Animation'
import { DisclaimerCustomDialog, icon_tertiary, theRowCustomDialog } from '../components/Common/Common'
import { PipManager } from '../common/utils/PipManager'
import { deviceInfo } from '@kit.BasicServicesKit'
import { CrashPage } from '../components/Start/CrashPage'
import { UpdateInfo } from '../common/utils/CheckUpdateUtil'
import { fileUri, picker, ReadOptions } from '@kit.CoreFileKit'
import { fileIo as fs } from '@kit.CoreFileKit';
import { number2Time, timestampToDateTime } from '../common/utils/TimeConvertUtil'
import { PXSecScreen } from './PXSecScreen'
import { getResourceString } from '../common/utils/ResourceStringUtil'
import BackgroundLocateService from '../common/utils/BackgroundLocateService'
import { ConvertedUnit } from '../common/utils/DataUnitConvertUtils'
import { WelcomeUserAgreement } from '../components/Start/WelcomePage'
import { i18n } from '@kit.LocalizationKit'
import {
  FloatTabBarHeight,
  MoreNavMode,
  TabBarAlignItems,
  TabBarAvoidHeight,
  TabBarHeight,
  TabBarJustifyContent,
  TabBarPosition,
  TabBarVertical,
  TabBarWidth,
  TabIconFontSize,
  TabTitleFontSize,
  WindowTabBarWidth
} from '../common/breakpoint/BreakPoint'
import { WindowTopBar } from '../components/Common/TopBar'
import { ImportConfigFromURL } from '../components/Configuration/ImportConfigFromURL'
import { Xb_ChangeThemeColor } from 'xb_components/src/main/ets/utils/ChangeThemeColorUtil'
import {
  StatusBarConfig,
  StatusBarIconResource,
  Xb_BackgroundRunning,
  Xb_ColorModeManager,
  Xb_FloatTabBarAlignCenter,
  Xb_FloatTabBarAlignEnd,
  Xb_FloatTabBarAlignStart,
  Xb_FloatTabBarDirection,
  Xb_Global,
  Xb_KVdbUtil,
  Xb_NotificationUtils,
  Xb_PreferenceUtil,
  Xb_ResourceColorUtil,
  Xb_StatusBarUtils,
  Xb_TabBarVertical,
  Xb_TabIconFontSize,
  Xb_TabTitleFontSize
} from 'xb_components'
import { Xb_GoToWeb } from 'xb_components/src/main/ets/utils/JumpTo'
import BackgroundDownService from '../common/utils/BackgroundDownService'
import { notificationManager } from '@kit.NotificationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { cardManager } from '../common/utils/CardManageUtil'
import LiveViewUtil from '../common/utils/LiveViewUtil'
import { UpdateLog } from '../components/Start/UpdateLog'
import { Xb_AnimationStyle } from 'xb_components';
import { getJsonArrayType } from '../common/entity/utils';
import { holdingHandleUtil } from '../common/utils/HoldingHandleUtil';
import { sortByCustomOrder } from '../common/utils/SortUtil';
import { AccessControlCompatibleMerger } from '../common/utils/AccessControlCompatibleUtil';
import { PCIndex } from './PCIndex';
import { accessControlRdb, AppInfo, ListType } from '../common/datasources/AccessControlRdb';
import { FloatBar } from '../components/Common/FloatBar';

export const indexController: TabsController = new TabsController()
const swiperController: SwiperController = new SwiperController()

const componentName: string = 'Index'

@Entry
@Component
struct Index {
  /**
   * 窗口
   */
  // 高度断点
  @StorageLink('currentHeightBreakpoint') @Watch('onWindowChange') @Watch('isSecondaryChange') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink('currentWidthBreakpoint') @Watch('onWindowChange') @Watch('isSecondaryChange') widthBp: WidthBreakpoint = 1
  // 导航条区域的高度
  @StorageProp('bottomRectHeight') @Watch('onAvoidAreaChange') bottomRectHeight: number = 0
  // 状态栏高度
  @StorageProp('topRectHeight') @Watch('onAvoidAreaChange') topRectHeight: number = 0
  // 应用窗口高度
  @StorageLink('windowHeight') @Watch('onWindowChange') windowHeight: number = 0
  // 应用窗口宽度
  @StorageLink('windowWidth') @Watch('onWindowChange') windowWidth: number = 0
  // 左侧避让宽度
  @StorageProp('LeftAvoidWidth') leftAvoidWidth: number = 0
  // 右侧避让宽度
  @StorageProp('RightAvoidWidth') rightAvoidWidth: number = 0
  // 分屏（正方形窗口）
  @Provide @Watch('isHiddenChange') isSmallSquareScreen: boolean = false
  // 手机横屏判断
  @StorageLink('isLandscapePhone') isLandscapePhone: boolean = false
  @Provide('currentColorMode') currentColorMode: boolean = false
  // 折叠展开状态判断变量
  @StorageLink('isFoldStatus') isFoldStatus: boolean = false
  // 平板竖屏判断变量
  @Provide istabletLandscape: boolean = false
  // px外屏判定
  @Provide isPXSecScreen: boolean = false
  /**
   * 颜色相关变量
   *    示例中主题配置里配置了一个颜色，所以只用`ResourceColor`类型的变量来接收色值，
   *    如果有多个颜色，就把这个变量换成`CustomTheme`类型的变量）
   */
  // 主题色
  @Provide('icon_emphasize') icon_emphasize: ResourceColor = $r('app.color.theme_color_main_cat_blue')
  @StorageLink('ThemeColor') themeColor: string = "#E61E4377"
  // tabs图标文字颜色，修改resources/base(dark)/element/color.json中tabs_icon_text配置选中图标文字深浅模式颜色
  // app.color.tabs_icon_text1配置非选中图标和文字深浅模式颜色
  //  @State fontColorValue:ResourceColor = ($r('app.color.tabs_icon_text'));
  //  @State fontColorValue1:ResourceColor = ($r('app.color.tabs_icon_text1'));

  /**
   * Index相关变量
   */
  // 所有子组件在容器内的对齐方式
  @Provide('stackAlignContentAlignment') stackAlignContentAlignment: Alignment = Alignment.BottomEnd
  @StorageLink('clashConfig') /*@Watch('switchMode')*/clashConfig: ClashConfig = new ClashConfig()
  @StorageProp("appFlowingState") appFlowingState: AppFlowingState = new AppFlowingState()
  // 欢迎页面栈
  @Provide('WelcomeNavPathStack') welcomePageInfos: NavPathStack = new NavPathStack()
  // 主页面栈
  @StorageLink('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  @Provide paddingButtom: number | Resource = $r('app.integer.vp_proxy_start_button_left_right_margin')
  @StorageLink('appLinkConfigUrl') @Watch('onOpenConfigLink') appLinkConfigUrl: string = ''
  @StorageLink('appLinkConfigName') @Watch('onOpenConfigLink') appLinkConfigName: string = ''
  // 系统语言显示副标题
  @Provide SystemLanguageSubtitle: ResourceStr = $r('app.string.SimplifiedChinese')
  // 通知权限跳转授权弹窗提示弹窗标题
  @State theToDialogTitle: ResourceStr = $r('app.string.notice_request_to_settings')
  @State barWidth: string | number | undefined = ''
  @State barHeight: string | number | undefined = 0
  @Provide("currentProfile") currentProfile: Profile | null = null
  @Provide remoteIp: IpInfo | null = null
  // 是否开启`Index`页面的前景模糊
  @Provide('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean = false
  // 代理启动变量
  @Provide @Watch('ShowPipChange') proxyEnabled: boolean = false
  // 前台判断变量
  @StorageProp('ForwardState') isForward: boolean = true
  // 初始化是否完成
  @StorageProp('awaitInit') theAwaitInit: boolean = false
  // 窗口模式
  @StorageProp('WindowMode') windowMode: boolean = false
  // 设置模态页控制变量
  @Provide isShowSettings: boolean = false
  // 欢迎页半模态窗口
  @Provide isShowWelcome: boolean = false
  // 是否为免责弹窗
  @Provide isDisclaimer: boolean = false
  // 是否在主页
  @Provide isHomePage: boolean = false

  @StorageProp('EnableAPIVersion') apiVersionEnable: boolean = false
  // 顶部Bar高度
  @Provide heightTop: Length = TAB_CONTENT_TITLE_HEIGHT
  // 主界面当前index
  @Provide tabCurrentPage: number = 0
  // PX外屏-偏移
  @Provide curOffsetRemain: number = 0
  // 恢复时刻
  @Provide theRestoreTime: number = 0
  // 通知更新任务id
  @State updateNoticeJob: number = 0
  // 暂停时刻
  @Provide thePauseTime: number = 0
  // 流量任务id
  private trafficJob: number = 0
  // 通知任务id
  @State noticeJob: number = 0
  private tabList: TabBuild[] = [
    { name: $r('app.string.Home'), icon: $r('sys.symbol.house_fill') },
    { name: $r('app.string.Proxy'), icon: $r('sys.symbol.list_bullet_square_fill') },
    { name: $r('app.string.Configuration'), icon: $r('sys.symbol.folder_fill') },
    { name: $r('app.string.More'), icon: $r('sys.symbol.square_fill_grid_2x2') }
  ]
  private context = this.getUIContext().getHostContext()! as common.UIAbilityContext
  private promptAction = this.getUIContext().getPromptAction()
  private UIContext = this.getUIContext()

  /**
   * 主页相关变量
   */
  @Provide rotateAngle: number = 0
  // 编辑卡片半模态页控制变量
  @Provide isShowCardEdit: boolean = false
  // 编辑按钮点击后显示编辑状态判定
  @Provide isShowHomeEdit: boolean = false
  // 主页删除按钮是否出现判定
  @Provide isShowDeleteButton: boolean = false
  // 当前主页布局
  @Provide theCurrentHomeCard: string[] = showHomeCard
  // 上一次主页布局
  @Provide theLastHomeCard: string[] = showHomeCard
  // 速度卡片图表数据
  @Provide ChartData: number[] | ConvertedUnit[] = []
  // 显示的是更新日志
  @StorageLink('ShowUpdateLog') showUpdateLog: boolean = false
  // 代理启动的计时文本
  @StorageLink('proxyStartingDuration') proxyStartingDuration: string = ''
  // 速度卡片
  @Provide DownloadSpeed: string = ""
  @Provide UploadSpeed: string = ""
  @Provide homeCardList: HomeCardInfo[] = HomeCards
  /**
   * 代理页Provide相关变量
   */
  // 收藏的代理节点
  @StorageLink('favoriteProfiles') favoriteProfiles: Map<string, string> = new Map<string, string>([])
  // 代理页分组数据（懒加载）
  @Provide proxyGroups: ProxyGroupItemDataSource = new ProxyGroupItemDataSource()
  // 节点数据
  @Provide proxyLazyItems: ProxyItemDataSource = new ProxyItemDataSource()
  // 节点数据组
  @Provide items: ProxyItem[] = ProxyData.ProxyItems();
  // 代理页延迟按钮气泡提示
  @Provide isShowDelayPop: boolean = false
  // 当前代理节点长按选择的值
  @Provide ProxyItemLongPressValue: number = -1
  // 当前显示的代理分组
  @Provide currentProxyIndex: number = 0
  // 当前代理节点收藏的值
  @Provide FavoriteProxy: number = -1
  /**
   * 配置页相关变量
   */
  // 配置页模糊变量
  @Provide('isEnableConfigPageBindSheetForegroundBlur') isEnableConfigPageBindSheetForegroundBlur: boolean = false
  // 当前触摸的配置行
  @StorageLink('currentTouchConfigData') currentTouchConfigData: ConfigData = NewConfigData
  // 是否显示配置页bindSheet
  @StorageLink('ShowConfigBindSheet') isShowConfigAddBindSheet: boolean = false
  // 是否为新建配置
  @StorageLink('ConfigNew') isNewConfig: boolean = false
  // 当前选中的配置行
  @Provide currentConfigRadioCheckedConfigData: ConfigData = NewConfigData
  // 路由栈
  @Provide('configAddPageInfos') configAddPageInfos: NavPathStack = new NavPathStack()
  // 配置数据
  @Provide('Configuration') configList: Array<ConfigData> = []
  @StorageLink('ConfigContent') configStr: string = ''
   /**
   * 更多页相关变量
   */
  // 访问控制 -> 在线应用添加
  @StorageLink('OnlineSearchPageInfos') addPageInfos: NavPathStack = new NavPathStack()
  // 更多页面栈
  @StorageLink('MoreNavPathStack') morePageInfos: NavPathStack = new NavPathStack()
  // 更多页面数据
  @Provide moreList: moreData[] = ListMoreData()
  // 日志数据
  @Provide logListData: Array<LogData> = []
  // 更多页标题是否搜索中
  @Provide isSearching: boolean = false
  // 更多页标题是否搜索
  @Provide needSearch: boolean = false
  // 更多页一级页面顶部标题偏移量
  @Provide curYOffsetMore: number = 0
  @Provide curYOffset: number = 0
  // 更多页标题搜索文本
  @Provide searchText: string = ''
  /**
   * 设置页变量
   */
  // 设置页面栈
  @Provide('NavSettingsPathStack') SettingsPageInfos: NavPathStack = new NavPathStack()
  // 设置页语言选中暂存变量
  @Provide currentLanguage: ResourceStr = $r('app.string.Language_Subtitle')
  // 实验功能开关列表行数据
  @Provide ExperimentData: AboutListItemProp = TheExperimentData
  // 应用更新信息
  @Provide theAppVersionInfo: UpdateInfo = DefaultUpdateInfo
  // 是否进入二级界面(Tab区)
  @Provide @Watch('isSecondaryChange') isSecondary: boolean = false
  // 列表是否滚动
  @Provide @Watch('isHiddenChange') isRolling: boolean = false
  // 设置 -> 通知 -> 流量提醒启用状态变量
  @Provide EnableCellularDataReminder: boolean = false
  // 判断设置是否清楚数据
  @Provide isClearData: boolean = false
  @StorageProp('VpnServiceStartTime') VpnServiceStartTime: number = 0
  // 设置 -> 外观 -> 按钮位置变量
  @Provide ButtonPositionOffset: number = 0
  @Provide proxyTime: number = 0
  // TODO 6.0(20)光效
  // @Provide lightSourceType: hdsEffect.PointLightSourceType = hdsEffect.PointLightSourceType.NONE;


  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      // 窗口控制器(窗口模式显示)
      if (this.windowMode && !this.isSearching) {
        WindowTopBar()
          .zIndex(2)
      }
      // 主内容区
      if (this.uiConfig.tabStyle == 'window') {
        PCIndex()
      } else
      if (!this.isPXSecScreen) {
        Navigation(this.pageInfos) {
          this.MainContent()
        }
        .hideTitleBar(true).hideToolBar(true)
        .height('100%').width('100%')
        .mode(NavigationMode.Stack)
      } else {
        // PX外屏样式
        PXSecScreen()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundBlurStyle(this.uiConfig.tabStyle == 'window' ? BlurStyle.BACKGROUND_THICK : undefined)
    .backgroundColor(this.uiConfig.tabStyle == 'window' ? undefined : $r('app.color.background'))
    .foregroundBlurStyle(this.isEnableIndexForegroundBlur && this.uiConfig.isBlurr ? BlurStyle.Thin : BlurStyle.NONE,
      { colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 0.3 })
    // 欢迎页&崩溃页
    .bindSheet($$this.isShowWelcome, this.WelcomeSheet(), {
      detents: [BIND_SHEET_CONTAINER_HEIGHT],
      showClose: (AppStorage.get<boolean>('crash') === true && !this.uiConfig.isFirstStart) ||
        this.appLinkConfigUrl != '' || (this.uiConfig.oldVersionCode !== AppState.versionCode && !this.uiConfig.isFirstStart) || this.showUpdateLog,
      dragBar: false,
      backgroundColor: $r('app.color.background'),
      keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      preferType: SheetType.CENTER,
      onWillDismiss: ((DismissSheetAction: DismissSheetAction) => {
        hilog.debug(0xFF00, "WelcomeTestTag", "弹窗关闭原因：%{public}d", DismissSheetAction.reason)

        // 无论什么原因关闭，都重置状态
        this.showUpdateLog = false
        this.isShowWelcome = false
        this.uiConfig.oldVersionCode = AppState.versionCode

        // 清空 AppLink 相关状态，避免重复导入
        if (this.appLinkConfigUrl != '') {
          this.appLinkConfigUrl = ''
          this.appLinkConfigName = ''
        }

        // 重置设置状态
        this.SettingsPageInfos.clear()
        // 关闭背景模糊
        this.isEnableIndexForegroundBlur = false

        hilog.error(0xFF00, "WelcomeTestTag", `Update 历史应用版本更新为：${this.uiConfig.oldVersionCode} showUpdateLog: ${this.showUpdateLog}`)

        DismissSheetAction.dismiss()
        hilog.info(0xFF00, "WelcomeTestTag", "欢迎页启用状态： %{private}s", this.isShowWelcome)
      }),
      onWillAppear: () => {
        // 启用背景模糊
        this.isEnableIndexForegroundBlur = true
        console.error(`Update Index isShowWelcome：${this.isShowWelcome} showUpdateLog: ${this.showUpdateLog}`)
      },
      onDisappear: async () => {
        // 重置设置状态
        this.SettingsPageInfos.clear()
        // 关闭背景模糊
        this.isEnableIndexForegroundBlur = false
      },
      onWillSpringBackWhenDismiss: () => {} // 注册回调，防止反向回弹
    })
  }

  @Builder
  MainContent() {
    // 主界面
    if (this.uiConfig.tabStyle == 'float' && this.apiVersionEnable) {
      // 悬浮Tab
      this.FloatTab()
    } else {
      // 普通Tab
      this.CustomTab()
    }
  }

  @Builder
  CustomTabBarBuilder(title: ResourceStr, index: number, TabIcon: Resource) {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: TabBarJustifyContent(this.widthBp, this.heightBp),
      alignItems: this.windowMode ? ItemAlign.Center : TabBarAlignItems(this.widthBp, this.heightBp),
      space: { main: LengthMetrics.vp(3) }
    }) {
      SymbolGlyph(TabIcon)
        .fontColor([this.tabCurrentPage === index ? this.icon_emphasize : icon_tertiary])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY) // 分层颜色
        .fontSize(TabIconFontSize(this.widthBp, this.heightBp))
        //.effectStrategy(customAnimationUtil.isIconEffect(this.uiConfig))
        .transition(customAnimationUtil.isTranslate(this.uiConfig))
        .translate({ y: this.tabCurrentPage == index ? -3 : 0 })

      Text(title)
        .fontColor(this.tabCurrentPage === index ? this.icon_emphasize : icon_tertiary)
        .fontWeight(FontWeight.Medium)
        .fontSize(TabTitleFontSize(this.widthBp, this.heightBp))
        .transition(customAnimationUtil.isTranslate(this.uiConfig))
    }
    .width('100%')
    .height('100%')
    .padding({ top: 8 })
  }
  @Builder
  CustomTab() {
    Tabs({
      barPosition: TabBarPosition(this.widthBp, this.heightBp),
      controller: indexController
    }) {
      ForEach(this.tabList, (item: TabBuild, index: number) => {
        TabContent() {
          this.TabContentBuilder(index)
        }
        .tabBar(this.CustomTabBarBuilder(item.name, index, item.icon))
        .gesture(
          // 二级Tabs第一个页签向左拖动时，触发手势事件，当Tab栏竖排时不触发
          PanGesture({
            direction: !TabBarVertical(this.widthBp, this.heightBp) ? PanDirection.Down : PanDirection.None
          })
            .onActionStart((event?: GestureEvent) => {
              console.info('Pan start')
            })// 通过父组件的TabsController的实例，改变其index，达到跳转一级Tabs（首页）的效果
            .onActionEnd(() => {
              if (this.isLandscapePhone || this.istabletLandscape) {
                if (this.tabCurrentPage == 0) {
                  indexController.changeIndex(1)
                  console.info('Pan end')
                }
              }
            }))
      })
    }
    .zIndex(1)
    .backgroundColor($r('app.color.background'))
    .barOverlap(false)
    .scrollable(!this.isSecondary)
    .vertical(TabBarVertical(this.widthBp, this.heightBp))
    .barWidth(this.windowMode ? WindowTabBarWidth(this.widthBp, this.heightBp) :
      TabBarWidth(this.widthBp, this.heightBp))
    .barHeight((this.isSecondary && this.widthBp <= 2 && !this.windowMode) || this.isSmallSquareScreen ?
      this.barHeight : this.bottomRectHeight == 0 ? TabBarHeight(this.widthBp, this.heightBp) :
        TabBarAvoidHeight(this.widthBp, this.heightBp))
    .onTabBarClick((index: number) => {
      Xb_AnimationStyle.animToAPI18(() => {
        this.tabCurrentPage = index
      },this.uiConfig.animationSpeed, 'app', 0)
    })
    .onChange((index) => {
      Xb_AnimationStyle.animToAPI18(() => {
        this.tabCurrentPage = index
        if (index == 0) {
          this.isHomePage = true
          return
        }
        this.isHomePage = false
      },this.uiConfig.animationSpeed, 'app', 0)
    })
    .onAnimationStart((index: number, targetIndex: number) => {
      Xb_AnimationStyle.animToAPI18(() => {
        this.tabCurrentPage = targetIndex;
      },this.uiConfig.animationSpeed, 'app', 0)
    })
    .onAppear(() => {
      indexController.changeIndex(this.tabCurrentPage)
    })
    .width('100%').height('100%')
    .backgroundColor($r('app.color.background')).fadingEdge(true)
    .padding({ top: this.topRectHeight, bottom: this.bottomRectHeight == 0 ? this.bottomRectHeight / 2 : 0 })
  }

  @Builder
  FloatBarFunctionContentBuilder() {
    if (this.widthBp <= 2 && (this.tabCurrentPage == 0 || this.uiConfig.needProxyStart)) {
      Text(this.proxyStartingDuration)
        .fontSize(20).fontWeight(FontWeight.Bold)
        .fontColor(this.proxyEnabled ? Color.White : Color.Transparent)
    }
  }

  @Builder
  FloatTab() {
    Stack() {
      Swiper(swiperController) {
        ForEach(this.tabList, (item: TabBuild, index: number) => {
          this.TabContentBuilder(index)
        })
      }
      // 渐变模糊
     // .linearGradientBlur(this.uiConfig.isBlurr && !this.isRolling ? 100 : 0,
    //    { fractionStops: [[0, 0.3],[0, 0.85],[0.7, 0.9],[1, 1]], direction: GradientDirection.Bottom })
      .cachedCount(0)
      .indicator(false).loop(false)
      .width('100%').height('100%')
      .padding({
        top: this.topRectHeight,
        left: (Xb_TabBarVertical(this.widthBp, this.heightBp)) ? 69 + ((this.leftAvoidWidth != 0 && this.windowHeight <= 520) ? this.leftAvoidWidth + 19 : 0) : 0
      })
      .vertical(Xb_TabBarVertical(this.widthBp, this.heightBp))
      .onAnimationStart((startIndex: number, targetIndex: number, extraInfo: SwiperAnimationEvent) => {
        this.tabCurrentPage = targetIndex
        swiperController.changeIndex(targetIndex, true)
      })

      // tab栏（抽离成组件）
      FloatBar({ tabList: this.tabList, swiperController: swiperController })
    }
    .width('100%')
    .height('100%')
    .align(this.getFloatAlign())
  }

  @Builder
  TabContentBuilder(index: number) {
    if (index == 0) {
      Home()
    } else if (index == 1) {
      ProxyPage()
    } else if (index == 2) {
      ConfigurationPage()
    } else {
      MorePage()
    }
  }

  @Builder
  WelcomeSheet() {
    if (AppStorage.get<boolean>('crash') == true && !this.uiConfig.isFirstStart) {
      CrashPage()
    } else if (this.appLinkConfigUrl != '') {
      ImportConfigFromURL({
        configData: this.currentTouchConfigData,
      })
    } else if (this.uiConfig.isFirstStart) {
      WelcomeUserAgreement()
    } else {
      // 版本更新后显示更新日志
      UpdateLog()
    }
  }

  @Builder
  toNoticeSettingsBuilder() {
    Button($r('app.string.to'))
      .backgroundColor($r('app.color.container_background'))
      .width('100%')
      .height(39)
      .fontColor(this.icon_emphasize)
  }

  /* // 当手机横屏时条件成立
  deviceHeightListener: mediaquery.MediaQueryListener =
   this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp) and (640vp< width <= 1000vp)');
  */
  private colorModeListener: mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(dark-mode: true)')

  // 免责声明 & 检查更新 弹窗控制器
  dialogController: CustomDialogController = new CustomDialogController({
    builder: DisclaimerCustomDialog({
      confirm: () => {
        // 关闭背景模糊
        this.isEnableIndexForegroundBlur = false
        if (!this.isDisclaimer) {
          Xb_GoToWeb(this.theAppVersionInfo.browser_download_url)
        }
      },
      cancel: () => {
        if (this.isDisclaimer) {
          // 拒绝并退出
          this.context.terminateSelf().catch(() => {
            console.log(`#DisclaimerCustomDialog 应用已退出`)
          })
        } else {
          // 关闭背景模糊
          this.isEnableIndexForegroundBlur = false
        }
      },
      isDisclaimer: this.isDisclaimer,
      version: this.isDisclaimer ? '' : this.theAppVersionInfo.tag_name,
      body: this.theAppVersionInfo.body
    }),
    autoCancel: false,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {

      } else if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {

      } else {
        dismissDialogAction.dismiss()
        setTimeout(() => {
          this.isDisclaimer = false
        }, 20)
      }
    }
  })

  // 前往通知设置弹窗
  toDialogController: CustomDialogController = new CustomDialogController({
    builder: theRowCustomDialog({
      theDialogTitle: this.theToDialogTitle,
      contentText: this.uiConfig.EnabledStatusNotice ? $r('app.string.status_bar_to') : $r('app.string.notice_request_to_settings_text'),
      cancel: ()=> {
        if (!this.uiConfig.EnabledStatusNotice) {
          this.uiConfig.Enablednotice = false
        }
      },
      confirm: () => {
        // 跳转至设置界面开启通知权限
        this.context.startAbility({
          bundleName: 'com.huawei.hmos.settings', // 系统设置界面的包名 （固定）
          abilityName: 'com.huawei.hmos.settings.MainAbility', // 系统设置的Ability的名字（固定）
          uri: "application_info_entry", // 系统设置的界面 （固定）
          parameters: {
            pushParams: this.context.applicationInfo.name,
          }
        }).catch(() => {
          console.error(`跳蛛通知权限设置失败`)
        })
      },
      leftButton: this.toNoticeSettingsBuilder
    }),
  })

  /** 获取配置列表 */
  async fetchProfiles(isFirst: boolean = false) {
    console.debug(`Config #fetchProfiles 开始获取配置`)
    const profiles = await ClashViewModel.getProfiles()
    console.error(`Config #fetchProfiles 配置已获取：${JSON.stringify(profiles)}`)
    this.configList = profiles.map((d) => {
      const timeGap = convertMillisecondsToTimeGap(d.autoUpdateDuration)
      return {
        configId: d.id,
        configName: d.name,
        isFavorite: this.favoriteProfiles.has(d.id) ?? false,
        configUrl: d.url,
        sourceType: d.type,
        isConfigAutoUpdate: d.autoUpdate,
        disableUpdate: d.isUpdating,
        configAutoUpdateTimeGapValue: timeGap.value,
        configAutoUpdateTimeGapMs: d.autoUpdateDuration,
        configAutoUpdateTimeGapTextPickerIndex: timeGap.unit,
        lastUpdateDateTime: d.lastUpdateDate,
        subscriptionInfo: d.subscriptionInfo
      } as ConfigData
    })
    // 初始化配置项排序列表
    let configSort = await Xb_PreferenceUtil.get<string>('config_sort', '')
    if (!configSort) {
      configSort = JSON.stringify(this.configList.map(id => id.configId))
      await Xb_PreferenceUtil.put('config_sort', configSort)
      console.info(`ConfigSort #fetchProfiles Xb_PreferenceUtil config_sort 不存在，进行初始化：${configSort}`)
    } else {
      // 当前的排序表
      this.configList = sortByCustomOrder(this.configList, JSON.parse(configSort) as string[], 'configId')
    }
    console.info(`ConfigSort #fetchProfiles Xb_PreferenceUtil config_sort 当前的排序表为，${configSort} 配置列表长度：${this.configList.length}`)
  }

  /**
   *  预留自定义主题，颜色在AppTheme里面修改
   * @param theme
   */
  onWillApplyTheme(theme: Theme) {
    hilog.info(0x1000, componentName, `#onWillApplyTheme`)
    this.icon_emphasize = theme.colors.iconEmphasize;
    // 全局变量同步
    this.themeColor = Xb_ResourceColorUtil(theme.colors.iconEmphasize, this.getUIContext().getHostContext()!)
    // 子模块主题色同步
    Xb_Global.icon_emphasize = theme.colors.iconEmphasize;
    cardManager.pushCartThemeColor(theme.colors.iconEmphasize)
  }

  /**窗口变化监听*/
  onWindowChange() {
    hilog.info(0xFF00, componentName, `#WindowChange#应用窗口状态 width: ${this.windowWidth} height: ${this.windowHeight} ` + ' tab宽度:' + this.barWidth?.toString())
    // 当窗口变化时清除更多页路由
    this.morePageInfos.clear(true)
    // 当处于更多页时清理主路由
    if (this.tabCurrentPage === 3) {
      this.pageInfos.clear(true)
    }
    if (this.windowWidth > 328 || this.windowHeight > 328) {
      if (this.windowHeight === this.windowWidth) {
        hilog.info(0xFF00, componentName,
          `#WindowChange#应用窗口状态 重复执行，跳出`)
        return
      }
    }
    if (320 < this.windowHeight && this.windowHeight <= 500 && 640 < this.windowWidth && this.windowWidth <= 1000) {
      this.isLandscapePhone = true
      hilog.info(0x1000, componentName,
        `#WindowChange#应用窗口状态改变#(320vp< height <= 500vp) and (640vp< width <= 1000vp)手机横屏结果: ${this.isLandscapePhone}`)
    } else if ((640 < this.windowWidth && this.windowWidth < 1000 && 640 < this.windowHeight &&
      this.windowHeight < 1000)) {
      this.isFoldStatus = true
      hilog.info(0xFF00, componentName,
        `#WindowChange#设备折叠状态改变#(640vp< height <= 1000vp) and (640vp< width <= 1000vp)折叠展开结果: ${this.isFoldStatus}`)
    } else if (this.windowWidth > 1000 && this.windowHeight > 530) {
      this.istabletLandscape = true
      hilog.info(0xFF00, componentName,
        `#WindowChange#应用窗口状态改变#(1000vp< width)平板横屏结果: ${this.istabletLandscape}`)
    } else if (328 < this.windowHeight && this.windowHeight < 440 && 328 < this.windowWidth &&
      this.windowWidth <= 440) {
      this.isSmallSquareScreen = true
      hilog.info(0xFF00, componentName,
        `#WindowChange#应用窗口状态改变#(1000vp< width)分屏窗口结果: ${this.isSmallSquareScreen}`)
    } else if (this.windowHeight < 328 && this.windowWidth < 328) {
      this.isPXSecScreen = true
      hilog.info(0xFF00, componentName,
        `#WindowChange#应用窗口状态改变#(328vp< width && 328 < height)PX外屏结果: ${this.isPXSecScreen}`)
    } else {
      this.isLandscapePhone = false
      this.istabletLandscape = false
      this.isSmallSquareScreen = false
      this.isFoldStatus = false
      this.isPXSecScreen = false
      hilog.info(0xFF00, componentName,
        `#WindowChange#设备高度改变，没有命中`)
    }
  }

  async aboutToAppear(): Promise<void> {
    hilog.info(0x1000, componentName, `#aboutToAppear executed`)
    this.registerEvent()

    // 初始化状态栏工具(仅PC设备)
    if (this.windowMode) {
      const iconResource: StatusBarIconResource = {
        white: 'clash_status_white.svg',
        black: 'clash_status_black.svg'
      };
      const statusBarConfig: StatusBarConfig = {
        icon: iconResource,
        title: "entry", // 当前模块的的model-name
        abilityName: '' // 留空，接管并使用默认状态栏图标点击事件
        // menus: [[{
        //   title: "",
        //   menuAction: { abilityName: "" }
        // }]]
      };
      Xb_StatusBarUtils.initStatusBar(this.UIContext, statusBarConfig)
        .then(() => {
          Xb_StatusBarUtils.setIconClickCallback()
        })
        .catch((err: BusinessError) => {
          console.error(`Index #aboutToAppear StatusBarUtils.initStatusBar 状态栏图标初始化失败, Message: ${err.message}`);
        })
    }

    // 首次启动启用通知
    if (!this.uiConfig.isRequestNotification) {
      EventHub.sendEvent(EventKey.EnabledNotice, true)
    }

    // 检查后台运行全局变量的状态
    if (this.uiConfig.backgroundLocateModel || this.uiConfig.backgroundDownModel || this.uiConfig.backgroundPiPModel || this.uiConfig.backgroundKeepTask) {
      this.uiConfig.Enablebackgrounder = true
    } else {
      this.uiConfig.Enablebackgrounder = false
    }

    // 分享包名
    const localStorage = this.getUIContext().getSharedLocalStorage()
    const bundleInfo = localStorage?.get<BundleInfo>('bundleInfo') || new BundleInfo()
    //  冷启动 -> 触发
    if (BundleInfo.isEmpty(bundleInfo)) {
      this.jumpAccessControl(bundleInfo)
    }
    // 运行一次窗口检查
    this.onWindowChange()
    // 除手机外更多页均默认跳转覆写
    if (this.widthBp > 1) {
      this.morePageInfos.pushPathByName('overwrite', null, false)
    }
    // 启动时检查上一次是否崩溃
    if (AppStorage.get<boolean>('crash') === true && !this.uiConfig.isFirstStart) {
      hilog.info(0x1000, componentName, `进入崩溃日志`)
      this.isShowWelcome = true
    }
    // 首次启动打开欢迎页
    if (this.uiConfig.isFirstStart) {
      this.isShowWelcome = true
    }
    // 在页面build前改变主题颜色
    Xb_ChangeThemeColor(this.uiConfig.themeColor)
    hilog.info(0x1000, componentName, `#aboutToAppear#ThemeControl.setDefaultTheme(${this.uiConfig.themeColor})`)
    // 初始化切换颜色模式(深色模式)
    Xb_ColorModeManager.setThemeColorMode(this.context, this.uiConfig.darkMode)
    // 初始化切换按钮位置
    this.switchButtonPosition(this.uiConfig.buttonPositionIndex)

    // 检查版本更新
    /* if (this.uiConfig.autoCheckUpdate) {
       try {
         const updateInfo = await getUpdateInfo()
         hilog.info(0xFF00, "UpdatetestTag", "Update Info: %{public}s", JSON.stringify(updateInfo))
         const theLatest = extractUpdateInfo(updateInfo)
         if (theLatest) {
           // 查询完成
           if (compareVersions(theLatest.tag_name, AppState.versionName)) {
             this.theAppVersionInfo = theLatest
             this.isDisclaimer = false
             this.dialogController.open()
           }
         } else {
           hilog.info(0xFF00, "UpdatetestTag", "提取更新信息失败")
         }
       } catch (err) {
         // 处理错误情况
         const infoError = `Error:${JSON.stringify(err)}`
         hilog.info(0xFF00, "UpdatetestTag", "Info: %{public}s", infoError)
       }
     }*/

    // if(!this.uiConfig.enabledADvanced || !this.uiConfig.isShowExperimentalFunction) {
    //   // 屏蔽分流策略
    //   this.moreList = removeItemsByIndex(this.moreList, [5])
    // }
    // if(this.appConfig.clashCore !== ClashCore.mihomo) {
    //   // 屏蔽请求与连接
    //   this.moreList = removeItemsByIndex(this.moreList, [2,3])
    // }

    // 根据设备选择性开启change监听
    /*if (deviceInfo.deviceType === 'phone') {
      this.deviceHeightListener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
        this.isLandscapePhone = mediaQueryResult.matches
        AppStorage.setOrCreate<boolean>('isLandscapePhone', this.isLandscapePhone)
        hilog.info(0x1000, componentName,
          `#媒体查询#设备高度改变#(320vp< height <= 500vp) and (640vp< width <= 1000vp)手机横屏结果: ${this.isLandscapePhone}`)
      })
    }*/

    this.colorModeListener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.currentColorMode = mediaQueryResult.matches
      // hilog.debug(0x1000, 'Index', `#媒体查询 #深色模式: ${this.currentColorMode}`)
    })

    // 初始化配置列表
    await this.awaitInit()

    // 初始化实况窗
/*    const isLive = await LiveViewUtil.init(this.getUIContext().getHostContext()!)
    if (isLive) {
      console.log(`LiveViewUtil 实况窗初始化成功`)
    } else {
      console.error(`LiveViewUtil 实况窗初始化失败`)
    }*/

    // 更新应用版本号
    const packageInfo = await getPackageInfo()
    AppState.versionCode = packageInfo.versionCode
    AppState.versionName = packageInfo.versionName
    console.error(`Update 历史应用版本：${this.uiConfig.oldVersionCode} 当前应用版本：${AppState.versionCode}`)

    if (this.uiConfig.oldVersionCode !== AppState.versionCode) {
      this.isEnableIndexForegroundBlur = true
      this.isShowWelcome = true
      this.updateData()   // TODO 强制更新数据函数
    }

    Xb_AnimationStyle.setContext(this.UIContext)
    if (this.apiVersionEnable) {
      // 需要确保兼容最低API版本(17)
      holdingHandleUtil.setContext(this.UIContext)
    }
  }

  /** @description 统一注册事件 */
  registerEvent() {
    // 通知事件
    EventHub.on(EventKey.EnabledNotice, async (enadblNotice: boolean) => {
      try {
        // 先获取最新权限状态
        const currentStatus = await notificationManager.isNotificationEnabled()
        if (currentStatus) {
          // 已有权限时
          // 显示通知设置 显式动画
          this.uiConfig.Enablednotice = enadblNotice ?? true
        } else {
          // 没有授权时
          if (!this.uiConfig.isRequestNotification) {
            // 首次请求权限
            try {
              await notificationManager.requestEnableNotification(this.context)
              this.uiConfig.isRequestNotification = true
              this.uiConfig.Enablednotice = true
            } catch (err) {
              if ((err as BusinessError).code === 1600004) {
                hilog.error(0xFF00, 'Index-Notice', '用户拒绝授权')
                // 关闭总通知
                this.uiConfig.Enablednotice = false
                // 关闭模拟下载
                this.uiConfig.backgroundDownModel = false
                // 标记已经请求过授权
                this.uiConfig.isRequestNotification = true
                this.promptAction.showToast({ message: $r('app.string.enable_notice_failed') })
              }
            }
          } else {
            // 已请求过权限且通知开关未启用，进入跳转设置
            if(!this.uiConfig.Enablednotice) {
              this.toDialogController.open()
            }
          }
        }
      } catch (err) {
        hilog.error(0xFF00, 'Index', `Toggle Error: ${(err as BusinessError).code}, ${(err as BusinessError).message}`);
      }
    })
    const appFlowingState = AppStorage.get<AppFlowingState>("appFlowingState") ?? new AppFlowingState()
    // 启动Clash后
    EventHub.on(EventKey.StartedClash, () => {
      const job = async () => {
        const onlyProxy = AppStorage.get<ClashConfig>("clashConfig")?.['only-proxy'] as boolean ?? true
        hilog.info(0xFF00, "EntryAbilityTestTag", 'onlyProxy: %{public}s', onlyProxy)
        const now = await ClashViewModel.getTraffic(onlyProxy)
        const total = await ClashViewModel.getTotalTraffic(onlyProxy)
        appFlowingState.traffics.enqueue(now)
        appFlowingState.totalTraffic = total
      }
      job()
      this.trafficJob = setInterval(job, 1000)
      // TODO 卡片后台启动服务后拉起应用关闭再开启会出现一秒的时间显示错误
      this.proxyStartingDuration = PROXY_STARTED_DURATION_INIT_VALUE
      // 发布常驻通知(默认为当未启用长时后台运行时)
      if (this.uiConfig.Enablednotice && this.uiConfig.EnabledPermanentnotice && (!this.uiConfig.Enablebackgrounder || this.uiConfig.EnabledCoexistNotice)) {
        this.noticeJob = Date.now()
        let up = '0'
        let down = '0'
        try {
          Xb_NotificationUtils.publishTextNotification(this.context, this.noticeJob,
            {
              title: `${this.appConfig.currentProxyName ?? 'ClashBox'}`,
              text: `${up}/s ↑ ${down}/s ↓`,
            },
            this.uiConfig.EnabledStatusNotice ? notificationManager.SlotType.SERVICE_INFORMATION :
              notificationManager.SlotType.CONTENT_INFORMATION,
            // 服务提醒类型 -> LEVEL_HIGH; CONTENT_INFORMATION -> LEVEL_MIN
            { abilityName: 'EntryAbility' })
        } catch (err) {
          hilog.info(0xFF00, 'NotificationUtils', `文本通知ID: ${this.noticeJob}发布错误: ${err} `);
        }
        // 更新通知
        this.updateNoticeJob = setInterval(async () => {
          up = this.appFlowingState.traffics.getLast()?.up?.toString() ?? "0"
          down = this.appFlowingState.traffics.getLast()?.down?.toString() ?? "0"
          hilog.info(0xFF00, 'NotificationUtils', `文本通知ID: ${this.noticeJob}更新文本: ${up}/s ↑ ${down}/s ↓ `);
          try {
            Xb_NotificationUtils.updateTextNotification(
              this.noticeJob,
              {
                title: `${this.appConfig.currentProxyName ?? 'ClashBox'}`,
                text: `${up}/s ↑ ${down}/s ↓`,
              },
              this.uiConfig.EnabledStatusNotice ? notificationManager.SlotType.SERVICE_INFORMATION :
                notificationManager.SlotType.CONTENT_INFORMATION, // 服务提醒类型 -> LEVEL_HIGH; CONTENT_INFORMATION -> LEVEL_MIN
            )
          } catch (err) {
            hilog.info(0xFF00, 'NotificationUtils', `文本通知ID: ${this.noticeJob}更新错误: ${err} `);
          }
        }, 1500)
      }
      // 发布模拟下载通知
      if (this.uiConfig.backgroundDownModel && this.uiConfig.Enablednotice) {
        BackgroundDownService.start(this.getUIContext().getHostContext()!)
      }
      // 发布模拟定位通知
      if (this.uiConfig.backgroundLocateModel && !this.uiConfig.backgroundKeepTask && this.uiConfig.Enablednotice) {
        BackgroundLocateService.start(this.getUIContext().getHostContext()!)
      }
      // 发布任务保持通知
      if (!this.uiConfig.backgroundLocateModel && this.uiConfig.backgroundKeepTask && this.uiConfig.Enablednotice) {
        Xb_BackgroundRunning.start(this.getUIContext().getHostContext()!)
      }
      // 发布实况窗
      LiveViewUtil.startLiveView().then((result) => {
        console.log(`LiveViewUtil 实况窗启动 result: ${result.resultCode} message: ${result.message}`)
      }).catch((err: BusinessError) => {
        console.error(`LiveViewUtil 实况窗启动失败：name: ${err.name} message: ${err.message} code: ${err.code}`)
      })

    })
    // 停止Clash后
    EventHub.on(EventKey.StopedClash, () => {
      // 停止模拟下载
      if (this.uiConfig.backgroundDownModel) {
        console.log(`BackgroundDownService 即将执行模拟下载停止`)
        BackgroundDownService.stop(this.context)
      }
      // 停止模拟定位
      if (this.uiConfig.backgroundLocateModel) {
        console.log(`BackgroundLocateService 即将执行模拟定位停止`)
        BackgroundLocateService.stop(this.context)
      }
      // 停止任务保持
      if (this.uiConfig.backgroundKeepTask) {
        console.log(`BackgroundLocateService 即将执行任务保持停止`)
        Xb_BackgroundRunning.stop(this.context)
      }
      clearInterval(this.trafficJob)
      // 取消通知
      if (this.uiConfig.Enablednotice && this.uiConfig.EnabledPermanentnotice) {
        Xb_NotificationUtils.cancelNotification(this.noticeJob)
        clearInterval(this.updateNoticeJob)
      }
      // 关闭实况窗
      LiveViewUtil.stopLiveView().then((result) => {
        console.log(`LiveViewUtil 实况窗停止 result: ${result.resultCode} message: ${result.message}`)
      }).catch((err: BusinessError) => {
        console.error(`LiveViewUtil 实况窗停止失败：name: ${err.name} message: ${err.message} code: ${err.code}`)
      })
      // 代理计时器重置
      this.proxyStartingDuration = ''
      // 速度卡片重置
      this.DownloadSpeed = ''
      this.UploadSpeed = ''
      this.ChartData = CHART_NUMBER
    })
    // 代理时长
    EventHub.on(EventKey.ProxyDuration, (time:number) => {
      this.proxyTime = time
      this.proxyStartingDuration = number2Time(time)
    })
    // 热启动 -> 通过事件监听触发
    EventHub.on(EventKey.ShareBundle, (bundleInfo: BundleInfo) => {
      this.jumpAccessControl(bundleInfo)
    })
    // 日志启用事件
    EventHub.on(EventKey.StartLog, async (enable: boolean) => {
      ClashViewModel.startLog(enable, (log) => {
        this.logListData.push({
          logType: log.logLevel,
          logTime: log.time,
          LogDetails: log.payload,
          logSkip: log.payload.length > 30
        })
      })
    })
    // 获取代理分组事件
    EventHub.on(EventKey.FetchProxyGroup, async () => {
      if (this.appConfig.currentProfileId) {
        this.currentProfile = await ClashViewModel.getProfile(this.appConfig.currentProfileId)
        if (this.currentProfile) {
          // 写入数据
          this.proxyGroups.empty()
          const rawProxyGroups = await ClashViewModel.getProxyGroups(this.clashConfig.mode ?? ProxyMode.Rule)
          const ProxyGroups = rawProxyGroups.filter(item => item.hidden !== true)
          // hilog.info(0xB000, componentName, `ProxySort #Index 节点数据：${JSON.stringify(rawProxyGroups[0].proxies[0])}`)
          this.proxyGroups.pushData(ProxyGroups)
          this.proxyGroups.refresh()
        }
      } else {
        this.proxyGroups = new ProxyGroupItemDataSource([])
      }
    })
    // 清理日志事件
    EventHub.on(EventKey.ClearLog, () => {
      this.logListData = []
    })
    // 导出日志事件
    EventHub.on(EventKey.ExportLog, (LogData?: LogData) => {
      try {
        let filePicker = new picker.DocumentViewPicker(this.context)
        let options = new picker.DocumentSaveOptions()
        options.newFileNames = LogData ? [`clash_next_${LogData.logTime}_${Date.now()}.log`] : ["clash_next.log"]
        options.fileSuffixChoices = ["'文档|.txt'"]
        options.pickerMode = picker.DocumentPickerMode.DOWNLOAD
        filePicker.save(options).then(async (result) => {
          const path = new fileUri.FileUri(result[0] + '/' +
            `clash_next${LogData ? '_' + LogData.logTime + '_' + Date.now() : ''}.txt`).path
          await this.saveLog(path, LogData)
        }).catch((e: Error) => {
          hilog.debug(0xFF00, 'ExportLog', 'err： ', e)
        })
      } catch (e) {
        hilog.info(0xFF00, "ExportLog", "err %{public}s", e)
      }

    })
    // 注册配置加载事件
    EventHub.on(EventKey.FetchProfile, async () => {
      this.fetchProfiles()
    })
    console.log(`ConfigSort EventKey.FetchProfile on 获取配置信息事件已注册`)
    // 注册配置详情加载事件
    EventHub.on(EventKey.LoadConfigStr, () => {
      const context = this.getUIContext().getHostContext()!
      const sandPath = context.filesDir + `/ClashBox/profiles/` + this.currentTouchConfigData.configId + '/config.yaml'
      const sandUri = fileUri.getUriFromPath(sandPath)
      try {
        const file = fs.openSync(sandUri, fs.OpenMode.READ_ONLY);
        try {
          console.log('#EditConfigContent.loadConfigContent file fd:', file.fd);
          const stats = fs.statSync(file.path);
          const fileSize = stats.size;
          console.log('#EditConfigContent.loadConfigContentile fileSize:', fileSize);
          let buffer = new ArrayBuffer(fileSize);
          const readOptions: ReadOptions = {
            offset: 0,
            length: fileSize
          };
          console.log('#EditConfigContent.loadConfigContent readOptions:', JSON.stringify(readOptions));
          fs.readSync(file.fd, buffer, readOptions);
          let textDecoder = util.TextDecoder.create("UTF-8", { ignoreBOM: false });
          this.configStr = textDecoder.decodeToString(new Uint8Array(buffer));
          console.debug(`读取到的配置内容：${this.configStr}`)
        } catch (err) {
          console.error(`读取配置文件失败，name: ${err.name} message: ${err.message}`)
        } finally {
          // 关闭文件
          fs.closeSync(file)
        }
      } catch (error) {
        console.error(`打开配置文件失败，name: ${error.name} message: ${error.message}`)
      }
    })
    // 注册监听切换按钮位置事件
    EventHub.on(EventKey.SwitchButtonPosition, (buttonPositionIndex: number) => {
      this.getUIContext().animateTo(this.uiConfig.isAnimation ?
        { duration: this.uiConfig.animationSpeed, curve: curves.springMotion() } : null,
        () => {
          this.switchButtonPosition(buttonPositionIndex)
        })
    })
  }

  aboutToDisappear() {
    hilog.info(0x1000, componentName, `#aboutToDisappear executed`)
    // 统一注销根目录事件
    EventHub.off(EventKey.FetchProfile)
    EventHub.off(EventKey.FetchProxyGroup)
    // 取消通知
    if (this.uiConfig.Enablednotice && this.uiConfig.EnabledPermanentnotice) {
      Xb_NotificationUtils.cancelNotification(this.noticeJob)
      clearInterval(this.updateNoticeJob)
    }
    // 纪录软件关闭时间
    this.uiConfig.useTime = new Date().getTime()
    // 解注册画中画生命周期及状态回调
    PipManager.getInstance().unregisterPipStateChangeListener()
    this.unRegisterEvent()
    // 解绑listener中注册的回调函数
    // this.deviceHeightListener.off('change');
    Xb_KVdbUtil.closeKVStore().catch((err: BusinessError) => {
      console.error(`KvDb #aboutToDisappear Xb_KVdbUtil.closeKVStore() 失败，message，${err.message}`)
    })
  }

  /** @description 统一取消监听事件 */
  unRegisterEvent() {
    EventHub.off(EventKey.ChangeProxy)
    EventHub.off(EventKey.FetchProxyGroup)
    EventHub.off(EventKey.ShareBundle)
    EventHub.off(EventKey.EnabledNotice)
    EventHub.off(EventKey.StopedClash)
    EventHub.off(EventKey.StartedClash)
    EventHub.off(EventKey.ExportLog)
    EventHub.off(EventKey.ClearLog)
    EventHub.off(EventKey.StartLog)
    EventHub.off(EventKey.LoadConfigStr)
    EventHub.off(EventKey.SwitchButtonPosition)
  }

  // 更新后强化赋值一次
  async updateData() {
    if (this.clashConfig.tun && this.clashConfig.tun['tun-ip']) {
      this.clashConfig.tun['tun-ip'] = '172.19.0.1/30'
    }
    const type = getJsonArrayType(this.uiConfig.isShowHomeCard)
    if (type === 'boolean') {
      const str = this.uiConfig.isShowHomeCard
      // 转化字符串
      this.uiConfig.isShowHomeCard = filterStringsByBooleans(str, 'string') as string
      this.theCurrentHomeCard = filterStringsByBooleans(str, 'array') as string[]
    } else if (typeof type == 'undefined') {
      this.uiConfig.isShowHomeCard = JSON.stringify(showHomeCard)
    }
    if (typeof this.uiConfig.editWordWrap != 'boolean') {
      this.uiConfig.editWordWrap = true
    }
    // 确保tabStyle有值
    if (!this.uiConfig.tabStyle) {
      this.uiConfig.tabStyle = 'custom'
    }
    if (this.uiConfig.isHoldingHand === undefined) {
      this.uiConfig.isHoldingHand = false
    }
    if (this.uiConfig.isFloatButtonVisible === undefined) {
      this.uiConfig.isFloatButtonVisible = true
    }

    setTimeout(async () => {
      // 等待 PreferenceUtil 完成初始化后，更新访问控制数据
      console.log(`AccessControl Index #updateData 准备数据迁移`)

      // 读取旧版应用列表
      const appsString = await Xb_PreferenceUtil.get<string>('access_control_apps', "[]")
      let currentApps = JSON.parse(appsString) as AppInfo[]
      let finalAppsString = appsString

      // 处理“列表为空”的情况
      if (currentApps.length === 0) {
        console.log(`AccessControl Index #updateData 列表为空...`)
        // 注入默认应用列表到 Preference
        if (this.appConfig.accessControlAppInfo) {
          await Xb_PreferenceUtil.put('access_control_apps', this.appConfig.accessControlAppInfo)
          finalAppsString = this.appConfig.accessControlAppInfo
        }
        // 注入默认黑白名单到 KVStore (兼容层逻辑)
        const defaultAcceptList = this.appConfig.accessControlAcceptList || "[]"
        const defaultRejectList = this.appConfig.accessControlRejectList || "[]"
        if (defaultAcceptList !== "[]" || defaultRejectList !== "[]") {
          const currentAcceptEntries = await Xb_KVdbUtil.getEntriesByPrefix('accept_');
          const currentRejectEntries = await Xb_KVdbUtil.getEntriesByPrefix('reject_');
          const currentAcceptSet = new Set(currentAcceptEntries.map(entry => entry.key.substring('accept_'.length)));
          const currentRejectSet = new Set(currentRejectEntries.map(entry => entry.key.substring('reject_'.length)));
          // 计算并合并差异
          const mergeResult = AccessControlCompatibleMerger.calculateMergeDifferences(
            currentAcceptSet,
            currentRejectSet,
            defaultAcceptList,
            defaultRejectList
          );
          if (mergeResult.keysToDelete.length > 0) {
            await Xb_KVdbUtil.deleteKeysBatch(mergeResult.keysToDelete);
          }
          if (mergeResult.entriesToAdd.length > 0) {
            await Xb_KVdbUtil.putEntriesBatch(mergeResult.entriesToAdd);
          }
        }
      }

      // 读取最终的旧版黑白名单状态
      const finalAcceptEntries = await Xb_KVdbUtil.getEntriesByPrefix('accept_');
      const finalRejectEntries = await Xb_KVdbUtil.getEntriesByPrefix('reject_');

      // 执行迁移到新数据库 RDB
      // 只要 Preference 或 KVStore 中有任意数据，就执行迁移
      if (finalAppsString !== "[]" || finalAcceptEntries.length > 0 || finalRejectEntries.length > 0) {
        console.log(`AccessControl Index #updateData 检测到旧数据，开始迁移到 RDB...`)
        try {
          await accessControlRdb.migrateFromOldStorage(
            finalAppsString,
            finalAcceptEntries,
            finalRejectEntries,
            this.appConfig.accessControlMode == 'AcceptSelected' ? ListType.WHITE_UNSELECTED : ListType.BLACK_UNSELECTED
          )
          console.log(`AccessControl Index #updateData 迁移完成`)
        } catch (e) {
          console.error(`AccessControl Index #updateData 迁移失败: ${JSON.stringify(e)}`)
        }
      } else {
        console.log(`AccessControl Index #updateData 无旧数据，跳过迁移`)
      }
    }, 3000)

  }

  // 等待配置数据库初始化完成
  async awaitInit() {
    const checkInterval = setInterval(() => {
      if (this.theAwaitInit) {
        // 获取配置列表
        this.fetchProfiles(true)
        clearInterval(checkInterval)
      }
    }, 100);
  }

  async saveLog(uri: string, logDdata?: LogData): Promise<void> {
    try {
      const file = fs.openSync(uri, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      // 生成日志内容
      const message = logDdata ?
        [logDdata].map((d) => d.logType + " " + timestampToDateTime(d.logTime * 1000) + "\n" + d.LogDetails)
          .join("\n") :
        this.logListData.map((d) => d.logType + " " + timestampToDateTime(d.logTime * 1000) + "\n" + d.LogDetails)
          .join("\n")
      // hilog.info(0xFF00, "ExportLog", "保存内容: %{public}s", message)
      fs.writeSync(file.fd, message);
      fs.fsync(file.fd);
      this.promptAction.showToast({ message: $r('app.string.saved_download') })
    } catch (e) {
      this.promptAction.showToast({
        message: `${getResourceString($r('app.string.export_failed'), this)} ${e.message}`,
        duration: 3000
      })
      hilog.info(0xFF00, "ExportLog", "Err: %{public}s", e.message)
    }
  }

  /**
   * 分流模式选择数据变化监控
   */
  async switchMode() {
    this.proxyGroups.refresh()
  }

  /**
   * 画中画根据代理启动和后台按钮监听是否开启
   */
  ShowPipChange() {
    if (deviceInfo.deviceType === 'tablet') {
      PipManager.getInstance().updateContentSize(80, 30)
    }
    if (this.uiConfig.backgroundPiPModel && this.proxyEnabled) {
      // 创建画中画控制器
      PipManager.getInstance().init(this.context)
      // 禁用自动启用
      PipManager.getInstance().setAutoStart(true)
      hilog.info(0xFF00, "PipTag", "代理启用状态： %{public}s", this.proxyEnabled)
      hilog.info(0xFF00, "PipTag", "画中画启用状态： %{public}s", this.uiConfig.backgroundPiPModel)
    } else {
      PipManager.getInstance().setAutoStart(false)
    }
  }

  onPageShow(): void {
    hilog.info(0xFF00, "TimertestTag", "#onPageShow")
    hilog.info(0xFF00, "PoptestTag", "startPop: %{public}d", this.uiConfig.ShowStartPop)
    hilog.info(0x0000, 'WindowLog #Index', '窗口顶部避让高度：%{public}d', px2vp(this.topRectHeight))
    if (this.proxyEnabled) {
      this.theRestoreTime = new Date().getTime()
      hilog.info(0xFF00, "TimertestTag", "恢复的时刻： %{public}d", this.theRestoreTime)
    }
    this.proxyEnabled = ClashViewModel.vpnStarted
    console.log(`HomeCard 前后台状态：${this.isForward}`)
    this.ShowPipChange()
    this.initLanguage()
    PipManager.getInstance().stopPip()
    hilog.info(0x1000, componentName, `#aboutToAppear#Language 用户选择语言：${this.uiConfig.userLanguage}`)
    hilog.info(0x1000, componentName,
      `#aboutToAppear#Language 当前语言文本：${getResourceString(this.currentLanguage, this)}`)
    hilog.info(0x1000, componentName,
      `#aboutToAppear#Language 当前系统语言文本：${getResourceString(this.SystemLanguageSubtitle, this)}`)
    this.onOpenConfigLink()
    holdingHandleUtil.start()
  }

  /**通过AppLink导入配置*/
  onOpenConfigLink() {
    // 赋值配置链接
    if (this.appLinkConfigUrl != '') {
      this.currentTouchConfigData.isNewConfig = true
      this.currentTouchConfigData.disableUpdate = false
      this.currentTouchConfigData.isConfigAutoUpdate = false
      this.currentTouchConfigData.configUrl = this.appLinkConfigUrl
      this.isShowWelcome = true
    }
    // 赋值配置名称
    if ( this.appLinkConfigName != '') {
      this.currentTouchConfigData.configName = this.appLinkConfigName
    }
  }

  onPageHide(): void {
    PipManager.getInstance().setAutoStart(true)
    hilog.info(0xFF00, "TimertestTag", "#onPageHide")
    if (this.proxyEnabled) {
      this.thePauseTime = new Date().getTime()
      hilog.info(0xFF00, "TimertestTag", "暂停的时刻： %{public}d", this.thePauseTime)
    }
    console.log(`HomeCard 前后台状态：${this.isForward}`)
    hilog.info(0xFF00, "PipTag", "代理启用状态： %{public}s", this.proxyEnabled)
    hilog.info(0xFF00, "PipTag", "画中画启用状态： %{public}s", this.uiConfig.backgroundPiPModel)
    this.ShowPipChange()
    holdingHandleUtil.stop()
  }

  /**初始化应用语言*/
  initLanguage() {
    const systemLanguage = i18n.System.getSystemLanguage()
    let currentLanguage = ''
    if (this.uiConfig.userLanguage !== 'default') {
      currentLanguage = this.uiConfig.userLanguage
      ChangeLanguage(this.uiConfig.userLanguage)
    } else {
      currentLanguage = systemLanguage
      ChangeLanguage(systemLanguage)
    }
    // 初始化当前语言显示
    switch (currentLanguage) {
      case 'zh-Hans-CN':
      case 'zh-Hans':
        this.currentLanguage = $r('app.string.Language_Subtitle')
        break
      case 'en-Latn-US':
      case 'en-Latn':
        this.currentLanguage = $r('app.string.English_Subtitle')
        break
      case 'zh-Hant-HK':
      case 'zh-Hant':
      case 'zh-HK':
        this.currentLanguage = $r('app.string.TraditionalChinese_HK_Subtitle')
        break
      case 'zh-Hant-TW':
      case 'zh-TW':
        this.currentLanguage = $r('app.string.TraditionalChinese_TW_Subtitle')
        break
      default:
        this.currentLanguage = $r('app.string.Language_Subtitle')
    }
    // 标准化系统语言
    switch (systemLanguage) {
      case 'zh-Hans-CN':
      case 'zh-Hans':
        this.SystemLanguageSubtitle = $r('app.string.Language_Subtitle')
        this.uiConfig.systemLanguage = 'zh-Hans'
        break
      case 'en-Latn-US':
      case 'en-Latn':
        this.SystemLanguageSubtitle = $r('app.string.English_Subtitle')
        this.uiConfig.systemLanguage = 'en-Latn'
        break
      case 'zh-Hant-HK':
      case 'zh-Hant':
      case 'zh-HK':
        this.SystemLanguageSubtitle = $r('app.string.TraditionalChinese_HK_Subtitle')
        this.uiConfig.systemLanguage = 'zh-HK'
        break
      case 'zh-Hant-TW':
      case 'zh-TW':
        this.SystemLanguageSubtitle = $r('app.string.TraditionalChinese_TW_Subtitle')
        this.uiConfig.systemLanguage = 'zh-TW'
        break
      default:
        this.SystemLanguageSubtitle = $r('app.string.Language_Subtitle')
      // 超出范围保存为系统返回值
        this.uiConfig.systemLanguage = systemLanguage
    }
  }

  /**切换按钮位置*/
  switchButtonPosition(index: number) {
    switch (index) {
      case 0:
        // 右侧
        this.ButtonPositionOffset = 16
        this.stackAlignContentAlignment = Alignment.BottomEnd
        break
      case 1:
        // 中间
        this.ButtonPositionOffset = 0
        this.stackAlignContentAlignment = Alignment.Bottom
        break
      case 2:
        // 左侧
        this.ButtonPositionOffset = -16
        this.stackAlignContentAlignment = Alignment.BottomStart
        break
    }
  }

  /**tab移动开始动画*/
  startAnim() {
    indexController.setTabBarTranslate({ y: 0 })
    Xb_AnimationStyle.animToAPI18(()=>{
      indexController.setTabBarTranslate({ y: '100%' })
      this.barHeight = 0
      console.info('tab横竖：', `${TabBarVertical(this.widthBp, this.heightBp)}`)
    },this.uiConfig.animationSpeed, 'app', 0)
  }

  /**tab移动停止动画*/
  stopAnim() {
    Xb_AnimationStyle.animToAPI18(()=>{
      if (!this.isSmallSquareScreen || !this.isRolling) {
        indexController.setTabBarTranslate({ y: 0 })
        this.barHeight = this.bottomRectHeight == 0 ? TabBarHeight(this.widthBp, this.heightBp) :
          TabBarAvoidHeight(this.widthBp, this.heightBp)
      }
    },this.uiConfig.animationSpeed, 'app', 0)
  }

  /**是否进入主二级界面(更多页二级)*/
  isSecondaryChange() {
    // 监听二级页面布尔判定动画是否执行 监听小屏是否滚动
    if (this.isSecondary && MoreNavMode(this.widthBp, this.heightBp) === NavigationMode.Stack) {
      this.stopAnim()
      this.startAnim()
    } else {
      this.stopAnim()
    }
  }

  /*px外屏手势动画*/
  // tab隐藏
  startAnimPX() {
    Xb_AnimationStyle.animToAPI18(()=>{
      indexController.setTabBarTranslate({ y: '100%' })
      this.barHeight = 0

      this.heightTop = -TAB_CONTENT_TITLE_HEIGHT
    },this.uiConfig.animationSpeed, 'app', 0)
  }

  // tab显示
  stopAnimPX() {
    Xb_AnimationStyle.animToAPI18(()=>{
      indexController.setTabBarTranslate({ y: 0 })
      this.barHeight = TabBarHeight(this.widthBp, this.heightBp)
      this.heightTop = 0
    },this.uiConfig.animationSpeed, 'app', 0)
  }

  /**监听上下滚动时，tab是否隐藏*/
  isHiddenChange() {
    if (this.isSmallSquareScreen && this.isRolling) {
      this.stopAnimPX()
      this.startAnimPX()
    } else {
      this.stopAnimPX()
    }
  } // px外屏手势动画 end

  /**避让状态改变*/
  onAvoidAreaChange() {
    hilog.info(0x0000, 'Index', '#onAvoidAreaChange 动态避让高度 Top：%{public}d Bottom: %{public}i', this.topRectHeight, this.bottomRectHeight)
  }

  /**
   * @description 跳转到访问控制添加包名
   */
  jumpAccessControl(bundleInfo: BundleInfo) {
    if (this.uiConfig.tabStyle == 'custom') {
      indexController.changeIndex(3)
    } else if (this.uiConfig.tabStyle == 'float') {
      swiperController.changeIndex(3)
    }
    if (this.widthBp <= 1) {
      const mainPath = this.pageInfos.getAllPathName()
      if (mainPath[0] !== 'access_control' || mainPath.length === 0) {
        this.pageInfos.pushPathByName('access_control', false)
      }
    } else {
      const morePath = this.morePageInfos.getAllPathName()
      if (morePath[0] !== 'access_control' || morePath.length === 0) {
        this.morePageInfos.replacePathByName('access_control', false)
      }
    }

    setTimeout(() => {
      EventHub.sendEvent(EventKey.AddAPP, bundleInfo)
    }, 400)
  }

  /**
   * 获取悬浮tab状态
   */
  getFloatAlign() {
    const value = this.uiConfig.buttonPositionIndex == 0 ? Xb_FloatTabBarAlignEnd(this.widthBp, this.heightBp) :
      (this.uiConfig.buttonPositionIndex == 1 ? Xb_FloatTabBarAlignCenter(this.widthBp, this.heightBp) : Xb_FloatTabBarAlignStart(this.widthBp, this.heightBp))
    // Xb_ToastUtil.showToast({ message: `getFloatAlign: ${value}`})
    return value
  }

  // getFloatBottom() 已迁移至 FloatBar 组件
  // functionButtonStyle @Extend 已迁移至 FloatControlButton 组件
}
