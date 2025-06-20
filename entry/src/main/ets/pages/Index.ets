// Index
import { BreakpointSystem, BreakpointState } from '../common/breakpoint/breakpointsystem'
import { curves, LengthMetrics, promptAction } from '@kit.ArkUI'
import Home from './HomePage'
import ProxyPage from './ProxyPage'
import ConfigurationPage from './ConfigurationPage'
import MorePage from './MorePage'
import { hiAppEvent, hilog } from '@kit.PerformanceAnalysisKit'
import {
  PROXY_STARTED_DURATION_INIT_VALUE,
  ListMoreData,
  moreData,
  AboutListItemProp,
  BIND_SHEET_CONTAINER_HEIGHT,
  DefaultUpdateInfo,CHART_NUMBER,
  TheExperimentData,
  TAB_CONTENT_TITLE_HEIGHT,
  LogData,
  showHomeCard,
  NewConfigData,
} from '../common/entity/Constants'
import { ProxyItem, ProxyData, ProxyGroupItemDataSource, ProxyItemDataSource } from '../common/datasources/ProxyData'
import { ClashConfig, IpInfo, LogLevel, Profile, ProxyGroup, ProxyMode } from 'proxy_core'
import { EventHub, EventKey } from '../common/EventHub'
import ClashViewModel from '../entryability/ClashViewModel'
import { AppConfig, AppFlowingState, AppState, UIConfig } from '../entryability/AppState'
import { common } from '@kit.AbilityKit'
import { setAutoColorMode, setDarkColorMode, setLightColorMode } from '../common/utils/ChangeColorModeUtils'
import { ChangeLanguage } from '../common/utils/ChangeLanguageUtil'
import { ConfigData, TabBuild } from '../common/entity/PageArgumentEntity'
import { customAnimationUtil } from '../common/utils/Animation'
import { DisclaimerCustomDialog, icon_tertiary } from '../components/Common/Common'
import { PipManager } from '../common/utils/PipManager'
import { deviceInfo } from '@kit.BasicServicesKit'
import { CrashPage } from '../components/Start/CrashPage'
import { compareVersions, extractUpdateInfo, getUpdateInfo, UpdateInfo } from '../common/utils/CheckUpdateUtil'
import { fileUri, picker } from '@kit.CoreFileKit'
import { fileIo as fs } from '@kit.CoreFileKit';
import { number2Time, timestampToDateTime } from '../common/utils/TimeConvertUtil'
import { PXSecScreen } from './PXSecScreen'
import { Timer } from '../common/utils/HHmmssTimer'
import { getResourceString } from '../common/utils/ResourceStringUtil'
import BackgroundLocateService from '../common/utils/BackgroundLocateService'
import { ConvertedUnit } from '../common/utils/DataUnitConvertUtils'
import { WelcomeUserAgreement } from '../components/Start/WelcomePage'
import { i18n } from '@kit.LocalizationKit'
import { TabBarAlignItems,
  TabBarAvoidHeight,
  TabBarHeight,
  TabBarJustifyContent,
  TabBarPosition,
  TabBarVertical, TabBarWidth,
  TabIconFontSize,
  TabTitleFontSize,
  WindowTabBarWidth} from '../common/breakpoint/BreakPoint'
import { WindowTopBar } from '../components/Common/TopBar'
import { ImportConfigFromURL } from '../components/Configuration/ImportConfigFromURL'
import { Xb_ChangeThemeColor } from 'xb_components/src/main/ets/utils/ChangeThemeColorUtil'
import { Xb_Global, Xb_UIConfig } from 'xb_components'
import { Xb_GoToWeb } from 'xb_components/src/main/ets/utils/JumpTo'

PersistentStorage.persistProp("persistedMapString", new Map<number, string>([]));
const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
export const indexController: TabsController = new TabsController()
const componentName: string = 'Index'

@Entry
@Component
struct Index {

  /**
   * 窗口
   */
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') @Watch('onWindowChange') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') @Watch('onWindowChange') widthBp: WidthBreakpoint = 1
  // 导航条区域的高度
  @StorageProp('bottomRectHeight') @Watch('onAvoidAreaChange') bottomRectHeight: number = 0
  // 状态栏高度
  @StorageProp('topRectHeight') @Watch('onAvoidAreaChange') topRectHeight: number = 0
  // 应用窗口高度
  @StorageLink('windowHeight') @Watch('onWindowChange') windowHeight: number = 0
  // 应用窗口宽度
  @StorageLink('windowWidth') @Watch('onWindowChange') windowWidth: number = 0
  // 分屏（正方形窗口）
  @Provide @Watch('isHiddenChange')isSmallSquareScreen: boolean = false
  // 手机横屏判断
  @StorageLink ('isLandscapePhone') isLandscapePhone: boolean = false
  // 折叠展开状态判断变量
  @StorageLink ('isFoldStatus') isFoldStatus: boolean = false
  // 平板竖屏判断变量
  @Provide istabletLandscape: boolean = false
  // PC判定
  @StorageLink ('2in1') is2in1: boolean = false
  // px外屏判定
  @Provide isPXSecScreen: boolean = false

  /**
   * 颜色相关变量
   *    示例中主题配置里配置了一个颜色，所以只用`ResourceColor`类型的变量来接收色值，
   *    如果有多个颜色，就把这个变量换成`CustomTheme`类型的变量）
   */
  // 主题色
  @Provide('icon_emphasize') icon_emphasize: ResourceColor = $r('app.color.theme_color_main_yellow')
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
  // 欢迎页面栈
  @Provide('WelcomeNavPathStack') welcomePageInfos: NavPathStack = new NavPathStack()
  @StorageLink('uiConfig') @Watch('ShowPipChange')uiConfig: UIConfig = new UIConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @Provide paddingButtom: number | Resource = $r('app.integer.vp_proxy_start_button_left_right_margin')
  @StorageLink('openLinkConfigUrl') openLinkConfigUrl: string = ''
  // 系统语言显示副标题
  @Provide SystemLanguageSubtitle: ResourceStr = $r('app.string.SimplifiedChinese')
  @State barWidth: string | number | undefined = ''
  @State barHeight: string | number | undefined = 0
  @Provide("currentProfile") currentProfile: Profile | null = null
  @Provide remoteIp: IpInfo | null = null
  // 是否开启`Index`页面的前景模糊
  @Provide('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean = false
  // 代理启动变量
  @Provide @Watch('ShowPipChange')proxyEnabled: boolean = false
  @StorageProp('WindowMode') windowMode: boolean = false
  // 设置模态页控制变量
  @Provide isShowSettings: boolean = false
  // 欢迎页半模态窗口
  @Provide isShowWelcome: boolean = false
  // 是否为免责弹窗
  @Provide isDisclaimer: boolean = false
  // 是否在主页
  @Provide isHomePage: boolean = false
  // 前台判断变量
  @Provide isForeward: boolean = false
  // 顶部Bar高度
  @Provide heightTop: Length = TAB_CONTENT_TITLE_HEIGHT
  // 主界面当前index
  @Provide IndexCurrentindex: number = 0
  // PX外屏-偏移
  @Provide curOffsetRemain: number = 0
  // 恢复时刻
  @Provide theRestoreTime: number = 0
  // 暂停时刻
  @Provide thePauseTime: number = 0
  // 流量任务id
  @State trafficJob: number = 0
  @State
  tabList: TabBuild[] = [
    { name: $r('app.string.Home'), icon: $r('sys.symbol.house_fill')},
    { name: $r('app.string.Proxy'), icon: $r('sys.symbol.list_bullet_square_fill')},
    { name: $r('app.string.Configuration'), icon: $r('sys.symbol.folder_fill')},
    { name: $r('app.string.More'), icon: $r('sys.symbol.square_fill_grid_2x2')}
  ]

  /**
   * 主页相关变量
   */
  @Provide rotateAngle : number  = 0
  // 编辑按钮点击后显示编辑状态判定
  @Provide isShowHomeEdit: boolean = false
  // 主页删除按钮是否出现判定
  @Provide isShowDeleteButton: boolean = false
  // 当前主页布局
  @Provide theCurrentHomeCard: boolean[] = showHomeCard
  // 上一次主页布局
  @Provide theLastHomeCard: boolean[] = showHomeCard
  // 速度卡片图表数据
  @Provide ChartData: number[] | ConvertedUnit[] = []
  // 代理启动的计时文本
  @Provide proxyStartingDuration: string = ''
  // 速度卡片
  @Provide DownloadSpeed: string = ""
  @Provide UploadSpeed: string = ""

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
  // 代理页原始数据
  @Provide theProxyGroups: ProxyGroup[] = []
  // 代理页延迟按钮气泡提示
  @Provide isShowDelayPop: boolean = false
  // 延迟排序判定
  @Provide isLatencySort: boolean = false
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
  // 是否显示bindSheet
  @Provide isShowConfigAddBindSheet: boolean = false
  // 当前触摸的配置行
  @Provide('currentTouchConfigData') currentTouchConfigData: ConfigData = NewConfigData
  // 当前选中的配置行
  @Provide currentConfigRadioCheckedConfigData: ConfigData = NewConfigData
  // 路由栈
  @Provide('configAddPageInfos') configAddPageInfos: NavPathStack = new NavPathStack()
  // 配置数据
  @Provide configList: Array<ConfigData> = []

  /**
   * 更多页相关变量
   */
  // 更多页面栈
  @Provide('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
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
  // 设置页实验功能提示框显示变量
  @Provide isShowExperimentalFunction: boolean = true
  // 设置 -> 备份与恢复 -> 是否启用云备份配置
  @Provide isShowCloudconfig: boolean = false
  // 判断设置是否清楚数据
  @Provide isClearData: boolean = false
  // 设置 -> 外观 -> 按钮位置变量
  @Provide ButtonPositionOffset: number = 0

  // 代理计时器Controller
  @Provide proxyStartedTimer: Timer = new Timer()
  @Provide proxyTime:number = 0

  build() {
    if (!this.isPXSecScreen){
      Stack({alignContent: Alignment.TopEnd}) {
        // 窗口控制器(窗口模式显示)
        if (this.windowMode) {
          WindowTopBar()
            .zIndex(2)
        }
        // 主界面
        Tabs({
          barPosition: TabBarPosition(this.widthBp, this.heightBp),
          index: this.IndexCurrentindex,
          controller: indexController
        })
        {
          ForEach(this.tabList, (item: TabBuild, index: number) => {
            TabContent() { this.TabContentBuilder(index) }
            .tabBar(this.TabBarBuilder(item.name, index, item.icon))
            .gesture(
              // 二级Tabs第一个页签向左拖动时，触发手势事件，当Tab栏竖排时不触发
              PanGesture({direction: !TabBarVertical(this.widthBp, this.heightBp) ? PanDirection.Down : PanDirection.None})
                .onActionStart((event?: GestureEvent) => {
                  console.info('Pan start')
                })// 通过父组件的TabsController的实例，改变其index，达到跳转一级Tabs（首页）的效果
                .onActionEnd(() => {
                  if (this.isLandscapePhone || this.istabletLandscape) {
                    if (this.IndexCurrentindex == 0) {
                      indexController.changeIndex(1)
                      console.info('Pan end')
                    }
                  }
                }))
          })

        }
        .zIndex(1)
        .backgroundColor( $r('app.color.background'))
        // .barBackgroundBlurStyle(this.uiConfig.isBlurr ? BlurStyle.Thin: null)
        // .backgroundBrightness({rate:0.5,lightUpDegree:0.5})
        //  .backdropBlur(this.uiConfig.isBlurr ? 0.3 : 0)
        .barOverlap(false)
        .scrollable(this.isSecondary ? false : true)
        .vertical(TabBarVertical(this.widthBp, this.heightBp))
        .barWidth(this.windowMode ? WindowTabBarWidth(this.widthBp, this.heightBp) : TabBarWidth(this.widthBp, this.heightBp))
        .barHeight((this.isSecondary && this.widthBp <= 2 && !this.windowMode) || this.isSmallSquareScreen ? this.barHeight : this.bottomRectHeight == 0 ? TabBarHeight(this.widthBp, this.heightBp) : TabBarAvoidHeight(this.widthBp, this.heightBp))
        .onChange((index: number) => {
          this.IndexCurrentindex = index
          if (index == 0) {
            this.isHomePage = true
          } else {
            this.isHomePage = false
          }
        })
        .onAnimationStart((index: number, targetIndex: number) => {
          animateTo({ duration: this.uiConfig.animationSpeed, curve: curves.springMotion(), }, () => {
            if (index == targetIndex) {
              return
            }
            this.IndexCurrentindex = targetIndex;
          })
        })
        .width('100%')
        .height('100%')
        .backgroundColor($r('app.color.background'))
        .foregroundBlurStyle(
          this.isEnableIndexForegroundBlur && this.uiConfig.isBlurr ? BlurStyle.Thin : BlurStyle.NONE,
          { colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 0.3 }
        )
        .fadingEdge(true)
        .padding({ top: this.topRectHeight })
      }
      .width('100%')
      .height('100%')
      .backgroundColor( $r('app.color.background'))
      // 欢迎页&崩溃页
      .bindSheet($$this.isShowWelcome, this.WelcomeSheet(), {
        detents: [BIND_SHEET_CONTAINER_HEIGHT],
        showClose: (AppStorage.get<boolean>('crash') === true && !this.uiConfig.isFirstStart) || this.openLinkConfigUrl != '' ? true : false,
        dragBar: false,
        backgroundColor: $r('app.color.background'),
        keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
        scrollSizeMode: ScrollSizeMode.CONTINUOUS,
        preferType: SheetType.CENTER,
        onWillDismiss: ((DismissSheetAction: DismissSheetAction) => {
          if (!this.isShowWelcome || DismissSheetAction.reason === DismissReason.CLOSE_BUTTON || this.openLinkConfigUrl != '') {
            // 关闭背景模糊
            this.isEnableIndexForegroundBlur = false
            DismissSheetAction.dismiss()
            hilog.info(0xFF00, "WelcomeTestTag", "欢迎页启用状态： %{private}s", this.isShowWelcome)
          }
        }),
        onDisappear: async () => {
        }
      })
    } else {
      // PX外屏样式
      PXSecScreen()
    }
  }

  @Builder
  TabBarBuilder(title: ResourceStr, index: number, TabIcon: Resource) {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: TabBarJustifyContent(this.widthBp, this.heightBp),
      alignItems: this.windowMode ? ItemAlign.Center : TabBarAlignItems(this.widthBp, this.heightBp),
      space: {main: LengthMetrics.vp(3)}
    })
    {
      SymbolGlyph(TabIcon)
        .fontColor([this.IndexCurrentindex === index ? this.icon_emphasize : icon_tertiary])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY) // 分层颜色
        .fontSize(TabIconFontSize(this.widthBp, this.heightBp))
          //.effectStrategy(customAnimationUtil.isIconEffect(this.uiConfig))
        .transition(customAnimationUtil.isTranslate(this.uiConfig))
        .translate({y: this.IndexCurrentindex == index ? -3 : 0})

      Text(title)
        .fontColor(this.IndexCurrentindex === index ? this.icon_emphasize : icon_tertiary)
        .fontWeight(FontWeight.Medium)
        .fontSize(TabTitleFontSize(this.widthBp, this.heightBp))
        .transition(customAnimationUtil.isTranslate(this.uiConfig))
    }
    .width('100%')
    .height('100%')
    .padding({top: 8})
    .animation(this.isSecondary === true ? {
      duration: this.uiConfig.animationSpeed,
      tempo: 0.3,
      curve: curves.springMotion(),
      iterations: 1,
      playMode: PlayMode.Normal
    } : null)
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
    } else if (this.openLinkConfigUrl != '') {
      ImportConfigFromURL({
        configData: this.currentTouchConfigData,
      })
    } else {
      WelcomeUserAgreement()
    }
  }

  /* // 当手机横屏时条件成立
  deviceHeightListener: mediaquery.MediaQueryListener =
   this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp) and (640vp< width <= 1000vp)');
  */

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
          context.terminateSelf()
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

  // 获取配置列表
  async fetchProfiles() {
    const profiles = await ClashViewModel.getProfiles()
    this.configList = profiles.map((d) => {
      return {
        configId: d.id,
        configName: d.name,
        isFavorite: this.favoriteProfiles.has(d.id) ?? false,
        configUrl: d.url,
        isConfigAutoUpdate: d.autoUpdate,
        configAutoUpdateTimeGapValue: d.autoUpdateDuration,
        lastUpdateDateTime: d.lastUpdateDate,
        subscriptionInfo: d.subscriptionInfo
      } as ConfigData
    })
  }

  /**
   *  预留自定义主题，颜色在AppTheme里面修改
   *  @param theme
   */
  onWillApplyTheme(theme: Theme) {
    hilog.info(0x1000, componentName, `#onWillApplyTheme`)
    this.icon_emphasize = theme.colors.iconEmphasize;
    // 子模块主题色同步
    Xb_Global.icon_emphasize = theme.colors.iconEmphasize;
  }

  /**窗口变化监听*/
  onWindowChange() {
    hilog.info(0xFF00, componentName,
      `#WindowChange#应用窗口状态 width: ${this.windowWidth} height: ${this.windowHeight} `+' tab宽度:'+ this.barWidth?.toString())
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
    } else if ((640 < this.windowWidth && this.windowWidth < 1000 && 640 < this.windowHeight && this.windowHeight < 1000)) {
      this.isFoldStatus = true
      hilog.info(0xFF00, componentName,
        `#WindowChange#设备折叠状态改变#(640vp< height <= 1000vp) and (640vp< width <= 1000vp)折叠展开结果: ${this.isFoldStatus}`)
    } else if (this.windowWidth > 1000 && this.windowHeight > 530) {
      this.istabletLandscape = true
      hilog.info(0xFF00, componentName,
        `#WindowChange#应用窗口状态改变#(1000vp< width)平板横屏结果: ${this.istabletLandscape}`)
    } else if (328<this.windowHeight && this.windowHeight < 440 && 328<this.windowWidth && this.windowWidth <= 440) {
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
    let appFlowingState = AppStorage.get<AppFlowingState>("appFlowingState") ?? new AppFlowingState()
    // 启动Clash
    EventHub.on(EventKey.StartedClash, ()=>{
      const job = async ()=>{
        let onlyProxy = AppStorage.get<ClashConfig>("clashConfig")?.['only-proxy'] as boolean ?? true
        hilog.info(0xFF00, "EntryAbilityTestTag", 'onlyProxy: %{public}s', onlyProxy)
        let now = await ClashViewModel.getTraffic(onlyProxy)
        let total = await ClashViewModel.getTotalTraffic(onlyProxy)
        appFlowingState.traffics.enqueue(now)
        appFlowingState.totalTraffic = total
      }
      job()
      this.trafficJob = setInterval(job, 1000)
      // 当模拟下载和通知均启用时
      if(this.uiConfig.backgroundLocateModel && this.uiConfig.Enablednotice) {
        BackgroundLocateService.start(getContext(this))
      }
      // 启动前先初始化一下显示文本
      this.proxyStartingDuration = PROXY_STARTED_DURATION_INIT_VALUE
      // 启动代理计时器, 启用时间样式 XX小时XX分 或 XX:XX:XX
      this.proxyStartedTimer.start(time => {
        this.proxyTime = time
        this.proxyStartingDuration = number2Time(time)
      })
    })
    // 停止Clash
    EventHub.on(EventKey.StopedClash, ()=>{
      clearInterval(this.trafficJob)
      if(this.uiConfig.backgroundLocateModel) {
        BackgroundLocateService.stop(getContext(this))
      }
      // 代理计时器重置
      this.proxyStartedTimer.reset()
      this.proxyStartingDuration = ''
      // 速度卡片重置
      this.DownloadSpeed = ''
      this.UploadSpeed = ''
      this.ChartData = CHART_NUMBER
    })
    // 运行一次窗口检查
    this.onWindowChange()


    // 除手机外更多页均默认跳转覆写
    if (500 < this.windowWidth && !this.isLandscapePhone) {
      this.pageInfos.pushPathByName(this.moreList[4].name, false)
    }

    // 启动时检查上一次是否崩溃
    if (AppStorage.get<boolean>('crash') === true && !this.uiConfig.isFirstStart) {
      hilog.info(0x1000, componentName, `进入崩溃日志`)
      this.isShowWelcome = true
    }

    // 首次启动打开欢迎页
    if (this.uiConfig.isFirstStart) {
      this.isShowWelcome = false
    }

    let nowDate = new Date().getTime()
    // 检查是否要弹出免责声明
    if (nowDate - this.uiConfig.useTime >= 1296000000) {
      this.isDisclaimer = true
      // 大于等于15天打开弹窗
      this.dialogController.open()
    }

    // 在页面build前改变主题颜色
    Xb_ChangeThemeColor(this.uiConfig.themeColor)
    hilog.info(0x1000, componentName, `#aboutToAppear#ThemeControl.setDefaultTheme(${this.uiConfig.themeColor})`)
    // 初始化切换颜色模式(深色模式)
    this.switchColorMode(this.uiConfig.darkModeIndex)
    // 初始化切换按钮位置
    this.switchButtonPosition(this.uiConfig.buttonPositionIndex)
    // 初始化实验功能显示状态
    this.isShowExperimentalFunction = this.uiConfig.isShowExperimentalFunction
    // 检查版本更新
    if (this.uiConfig.autoCheckUpdate) {
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
    }
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

    // TODO
    this.fetchProfiles()
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
    EventHub.on(EventKey.FetchProxyGroup, async () => {
      if (this.appConfig.currentProfileId) {
        this.currentProfile = await ClashViewModel.getProfile(this.appConfig.currentProfileId)
        if (this.currentProfile) {
          // 写入数据
          this.proxyGroups.empty()
          this.theProxyGroups = []
          let TheProxyGroups = await ClashViewModel.getProxyGroups(this.clashConfig.mode ?? ProxyMode.Rule)
          this.theProxyGroups = TheProxyGroups.filter(item => item.hidden !== true)
          this.proxyGroups.pushData(this.theProxyGroups)
          this.proxyGroups.refresh()
        }
      } else {
        this.proxyGroups = new ProxyGroupItemDataSource([])
      }
    })
    EventHub.on(EventKey.ClearLog, () => {
      this.logListData = []
    })
    EventHub.on(EventKey.ExportLog, (LogData?: LogData) => {
      try {
        let filePicker = new picker.DocumentViewPicker(getContext(this))
        let options = new picker.DocumentSaveOptions()
        options.newFileNames = LogData ? [`clash_next_${LogData.logTime}_${Date.now()}.log`] : ["clash_next.log"]
        options.fileSuffixChoices = ["'文档|.txt'"]
        options.pickerMode = picker.DocumentPickerMode.DOWNLOAD
        filePicker.save(options).then(async (result)=>{
          const path = new fileUri.FileUri(result[0] + '/' +`clash_next${LogData ? '_' + LogData.logTime + '_' +  Date.now() : ''}.txt`).path
          await this.saveLog(path, LogData)
        }).catch((e:Error) =>{
          hilog.debug(0xFF00, 'ExportLog', 'err ', e)
        })
      }catch (e) {
        hilog.info(0xFF00, "ExportLog", "err %{public}s", e)
      }

    })

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
      promptAction.showToast({message: $r('app.string.saved_download')})
    } catch (e) {
      promptAction.showToast({message: `${getResourceString($r('app.string.export_failed'), this)} ${e.message}`, duration: 3000})
      hilog.info(0xFF00, "ExportLog", "Err: %{public}s", e.message)
    }
  }

  /**分流模式选择数据变化监控*/
  async switchMode() {
    if(this.clashConfig.mode==ProxyMode.Rule){
      this.theProxyGroups = await ClashViewModel.getProxyGroups(this.clashConfig.mode = ProxyMode.Rule)
      this.proxyGroups.refresh()
    }else if(this.clashConfig.mode==ProxyMode.Global){
      this.theProxyGroups = await ClashViewModel.getProxyGroups(this.clashConfig.mode = ProxyMode.Global)
      this.proxyGroups.refresh()
    }else if(this.clashConfig.mode==ProxyMode.Direct){
      this.theProxyGroups = await ClashViewModel.getProxyGroups(this.clashConfig.mode = ProxyMode.Direct)
      this.proxyGroups.refresh()
    }
  }

  aboutToDisappear() {
    hilog.info(0x1000, componentName, `#aboutToDisappear executed`)
    // 纪录软件关闭时间
    this.uiConfig.useTime = new Date().getTime()
    // 停止监听断点事件，并清空断点对应数据
    BreakpointSystem.getInstance().stop()
    // 解注册画中画生命周期及状态回调
    PipManager.getInstance().unregisterPipStateChangeListener()
    // 解绑listener中注册的回调函数
    // this.deviceHeightListener.off('change');
  }

  /**
   * 画中画根据代理启动和后台按钮监听是否开启
   */
  ShowPipChange() {
    if (deviceInfo.deviceType === 'tablet') {
      PipManager.getInstance().updateContentSize(80, 30)
    }
    if(this.uiConfig.backgroundPiPModel && this.proxyEnabled) {
      // 创建画中画控制器
      PipManager.getInstance().init(getContext(this))
      // 禁用自动启用
      PipManager.getInstance().setAutoStart(true)
      hilog.info(0xFF00, "PipTag", "代理启用状态： %{private}s", this.proxyEnabled)
      hilog.info(0xFF00, "PipTag", "画中画启用状态： %{private}s", this.uiConfig.backgroundPiPModel)
    } else {
      PipManager.getInstance().setAutoStart(false)
    }
  }

  onPageShow(): void {
    hilog.info(0xFF00, "TimertestTag", "#onPageShow")
    hilog.info(0xFF00, "PoptestTag", "startPop: %{private}d", this.uiConfig.ShowStartPop)
    hilog.info(0x0000, 'WindowLog #Index', '窗口顶部避让高度：%{public}d', px2vp(this.topRectHeight))
    // 刷新问候语
    if (this.proxyEnabled) {
      this.theRestoreTime = new Date().getTime()
      hilog.info(0xFF00, "TimertestTag", "恢复的时刻： %{private}d", this.theRestoreTime)
    }
    this.isForeward = true
    this.ShowPipChange()
    this.initLanguage()
    PipManager.getInstance().stopPip()
    hilog.info(0x1000, componentName, `#aboutToAppear#Language 用户选择语言：${this.uiConfig.userLanguage}`)
    hilog.info(0x1000, componentName, `#aboutToAppear#Language 当前语言文本：${getResourceString(this.currentLanguage, this)}`)
    hilog.info(0x1000, componentName, `#aboutToAppear#Language 当前系统语言文本：${getResourceString(this.SystemLanguageSubtitle, this)}`)
    this.onOpenConfigLink()
  }

  /**通过openLink导入配置*/
  onOpenConfigLink() {
    if (this.openLinkConfigUrl != '') {
      this.currentTouchConfigData.isNewConfig = true
      this.currentTouchConfigData.configUrl = this.openLinkConfigUrl
      this.isShowWelcome = true
    }
  }

  onPageHide(): void {
    PipManager.getInstance().setAutoStart(true)
    hilog.info(0xFF00, "TimertestTag", "#onPageHide")
    if (this.proxyEnabled) {
      this.thePauseTime = new Date().getTime()
      hilog.info(0xFF00, "TimertestTag", "暂停的时刻： %{private}d", this.thePauseTime)
    }
    this.isForeward = false
    hilog.info(0xFF00, "PipTag", "代理启用状态： %{private}s", this.proxyEnabled)
    hilog.info(0xFF00, "PipTag", "画中画启用状态： %{private}s", this.uiConfig.backgroundPiPModel)
    this.ShowPipChange()
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
        this.currentLanguage =  $r('app.string.Language_Subtitle')
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
        this.SystemLanguageSubtitle  = $r('app.string.English_Subtitle')
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
        this.SystemLanguageSubtitle  = $r('app.string.TraditionalChinese_TW_Subtitle')
        this.uiConfig.systemLanguage = 'zh-TW'
        break
      default:
        this.SystemLanguageSubtitle  =  $r('app.string.Language_Subtitle')
      // 超出范围保存为系统返回值
        this.uiConfig.systemLanguage = systemLanguage
    }
  }

  /**
   * 切换颜色模式
   * @param index 颜色模式序号
   */
  switchColorMode(index: number) {
    switch (index) {
      case 0:
        // 跟随系统
        setAutoColorMode(context)
        break;
      case 1:
        // 始终浅色
        setLightColorMode(context)
        break
      case 2:
        // 始终深色
        setDarkColorMode(context)
        break
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
    animateTo({
      duration: this.uiConfig.animationSpeed,
      curve: Curve.Linear,
      iterations: 1,
      playMode: PlayMode.Normal,
    }, () => {
    //    if (this.uiConfig.isBlurr) {
     //     indexController.setTabBarTranslate(this.isLandscapePhone ? { x: '-100%' } : { y: '100%' })
   //     } else {
          indexController.setTabBarTranslate({ y: '100%' })
          this.barHeight = 0
     //   }

      if (this.isLandscapePhone || this.istabletLandscape ) {
        indexController.setTabBarTranslate({ x: '-100%' })
        this.barWidth = 0
      }
    })
  }

  /**tab移动停止动画*/
  stopAnim() {
    animateTo({
      duration: this.uiConfig.animationSpeed,
      curve: Curve.Linear,
      iterations: 1,
      playMode: PlayMode.Normal,
    }, async () => {
      if (!this.isSmallSquareScreen || !this.isRolling) {
        indexController.setTabBarTranslate({ y: 0 })
        this.barHeight = TabBarHeight(this.widthBp, this.heightBp)

        if (this.isLandscapePhone || this.istabletLandscape ) {
          indexController.setTabBarTranslate({ x: 0 })
          this.barWidth = WindowTabBarWidth(this.widthBp, this.heightBp)
        }
      }
    })
  }

  /**是否进入主二级界面(更多页二级)*/
  isSecondaryChange() {
    // 监听二级页面布尔判定动画是否执行 监听小屏是否滚动
    if ((this.isSecondary && this.isSmallSquareScreen && !this.isRolling)|| (this.isSecondary && !this.isSmallSquareScreen )) {
      this.startAnim()
    } else {
      this.stopAnim()
    }
  }

  /*px外屏手势动画*/
  // tab隐藏
  startAnimPX(){
    this.getUIContext().animateTo({
      duration: this.uiConfig.animationSpeed,
      curve: Curve.Linear,
      iterations: 1,
      playMode: PlayMode.Normal,
    }, () => {
      indexController.setTabBarTranslate({ y: '100%' })
      this.barHeight = 0

      this.heightTop = -TAB_CONTENT_TITLE_HEIGHT
    })
  }

  // tab显示
  stopAnimPX(){
      this.getUIContext().animateTo({
        duration: this.uiConfig.animationSpeed,
        curve: Curve.EaseOut,
        iterations: 1,
        playMode: PlayMode.Normal,
        onFinish:()=>{
        }
      }, () => {
        indexController.setTabBarTranslate({ y: 0 })
        this.barHeight = TabBarHeight(this.widthBp, this.heightBp)
        this.heightTop = 0
      })
  }

  /**监听上下滚动时，tab是否隐藏*/
  isHiddenChange(){
    if (this.isSmallSquareScreen && this.isRolling){
      this.stopAnimPX()
      this.startAnimPX()
    } else {
      this.stopAnimPX()
    }
  }// px外屏手势动画 end

  /**避让状态改变*/
  onAvoidAreaChange() {
    hilog.info(0x0000, 'Index', '#onAvoidAreaChange 动态避让高度 Top：%{public}d Bottom: %{public}i', this.topRectHeight, this.bottomRectHeight)
  }

}