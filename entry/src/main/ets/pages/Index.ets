//Index 媒体查询
import { BreakpointSystem, BreakpointState } from '../common/breakpointsystem'
import { mediaquery, window } from '@kit.ArkUI'
import Home from './HomePage'
import ProxyPage from './ProxyPage'
import ConfigurationPage from './ConfigurationPage'
import MorePage from './MorePage'
import { hilog } from '@kit.PerformanceAnalysisKit'
import {
  BPS_LIST_LANES_1_1_2_3_4,
  BPS_LIST_GUTTER_1_1_2_3_3,
  BPS_TAB_CONTENT_TITLE_MARGIN_12_13_28_36,
  BPS_NAVIGATION_LIST_PADDING_12_13_13_28_36,
  morePageMargin_12_14_16,
  morePagelistBottom_10_14,
  listHeight_610_590,
  SettingslistHeight_590_500,
  MarginGenerate,
  HomeCardPadding_14_15_16_17,
  HomeCardCellularDatabarMargin,
  HomeCardCellularDatabarHeight_6_5,
  HomeCardCellularDataChevronSize,
  HomeCardCellularDataChevronRowMargin,
  HomeCardCellularDataFontSize,
  HomeCardTitleBottomMargin,
  HomeCardSwitchModeRowMargin,
  HomeCardSwitchModeFontSize,
  HomeCardSwitchModeTextMargin,
  DeleteButtonSize_24_32,
  HomeCardCellularDataSmFontSize,
  HomeCardPrpxySmFontSize,
  HomeCardIPSmFontSize,
  IPfontSize,
  gutterHomeGridcol_12_15,
  gutterHomeGridcol,
  HomeCardAreaPadding,
  HomeCardTitleButtonPadding,
  HomeCardEditHeight,
  CardTitleFontSize_18_20_22_22,
  HomeProxyFontSize_24_26_26_27,
  SpeedfontSize12_14_14_16,
  HomeCardCellularDataPadding,
  PROXY_STARTED_DURATION_INIT_VALUE
} from '../common/Constants'
import { ThemeControl } from '@ohos.arkui.theme'
import { CustomThemeName, CUSTOM_THEME_MAP } from '../common/AppTheme'
import { ProxyItem, ProxyData } from '../common/ProxyData'
import { image } from '@kit.ImageKit'
import { ClashConfig, Dns, LogLevel, Profile, ProxyGroup, ProxyMode } from 'proxy_core'
import { EventHub, EventKey } from '../common/EventHub'
import ClashViewModel from '../entryability/ClashViewModel'
import { AppConfig, ClashCore, UIConfig } from '../entryability/AppState'
import { changeThemeColor } from '../utils/ChangeThemeColorUtil'
import { common } from '@kit.AbilityKit'
import { setAutoColorMode, setDarkColorMode, setLightColorMode } from '../utils/ChangeColorModeUtils'
import { ChangeLanguage } from '../utils/ChangeLanguageUtil'
import { ConfigData, ConfigDataSourceType } from '../common/PageArgumentEntity'

PersistentStorage.persistProp("persistedMapString", new Map<number, string>([]));


//
interface marginGenerate {
  top: number,
  bottom: number,
  left: number,
  right: number
}

// 日志数据（假设）
interface LogData {
  // 日志类型（0：Warning；1：Info）
  logType: LogLevel
  // 日志生成时间(展示的时间)
  logTime: number
  // 日志详情
  LogDetails: string
  // 是否跳转
  logSkip: boolean
}

@Entry
@Component
struct Index {
  private componentName: string = 'Index'
  /**
   * 主题色
   *    示例中主题配置里配置了一个颜色，所以只用`ResourceColor`类型的变量来接收色值，
   *    如果有多个颜色，就把这个变量换成`CustomTheme`类型的变量）
   */
  @Provide('icon_emphasize') icon_emphasize: ResourceColor = $r('sys.color.icon_emphasize')
  //三级图标色，浅灰色
  @State icon_tertiary: ResourceColor = $r('sys.color.icon_tertiary')

  // 预留自定义主题，颜色在AppTheme里面修改
  /**
   *
   * @param theme
   */
  onWillApplyTheme(theme: Theme) {
    hilog.info(0x1000, this.componentName, `#onWillApplyTheme`)
    this.icon_emphasize = theme.colors.iconEmphasize;

  }

  //tabs图标文字颜色，修改resources/base(dark)/element/color.json中tabs_icon_text配置选中图标文字深浅模式颜色
  // app.color.tabs_icon_text1配置非选中图标和文字深浅模式颜色
  //  @State fontColorValue:ResourceColor = ($r('app.color.tabs_icon_text'));
  //  @State fontColorValue1:ResourceColor = ($r('app.color.tabs_icon_text1'));
  @State currentIndex: number = 0
  // 设备高度是否 (320vp< height <= 500vp) 媒体查询
  @State isLandscapePhone: boolean = false
  // 平板竖屏判断变量
  @State istabletVertical: boolean = false
  // 折叠展开状态判断变量
  @State isFoldStatus: boolean = false
  // 读取导航条区域的高度
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  /* 断点布局相关 相关作用看定义时候的注释 */
  @State compStr: BreakpointState<string> = BreakpointState.of({
    sm: "sm",
    md: "md",
    lg: "lg",
    xl: "xl"
  })
  @State compDirection: BreakpointState<FlexDirection> = BreakpointState.of({
    sm: FlexDirection.Column,
    md: FlexDirection.Column,
    lg: FlexDirection.Column,
    xl: FlexDirection.Column
  });
  @State compBarPose: BreakpointState<BarPosition> = BreakpointState.of({
    sm: BarPosition.End,
    md: BarPosition.End,
    lg: BarPosition.End,
    xl: BarPosition.Start
  });
  @State compVertical: BreakpointState<boolean> = BreakpointState.of({
    sm: false,
    md: false,
    lg: false,
    xl: true
  });
  @State compBarWidth: BreakpointState<string> = BreakpointState.of({
    sm: '100%',
    md: '100%',
    lg: '100%',
    xl: '60vp'
  });
  @State compBarHeight: BreakpointState<string> = BreakpointState.of({
    sm: '55vp',
    md: '55vp',
    lg: '55vp',
    xl: '100%'
  });
  @State TabIconfontSize: BreakpointState<number> = BreakpointState.of({
    sm: 24,
    md: 29,
    lg: 29,
    xl: 29
  });
  @State TabTitlefontSize: BreakpointState<number> = BreakpointState.of({
    sm: 12,
    md: 16,
    lg: 16,
    xl: 16
  });
  @State compMargin: BreakpointState<marginGenerate> = BreakpointState.of({
    sm: ({ top: 4, bottom: 5 } as marginGenerate),
    md: ({ top: 4, bottom: 5 } as marginGenerate),
    lg: ({ top: 5 } as marginGenerate),
    xl: ({ top: 5 } as marginGenerate)
  });


  // 主页卡片内边距
  @Provide('breakPointStateHomeCardPadding')
  private breakPointStateHomeCardPadding: BreakpointState<MarginGenerate> = HomeCardPadding_14_15_16_17
  // 主页卡片标题下边距
  @Provide('breakPointStateHomeCardTitleBottomMargin')
  private breakPointStateHomeCardTitleBottomMargin: BreakpointState<number> = HomeCardTitleBottomMargin
  // 主页模式卡片上下边距
  @Provide('breakPointStateHomeCardSwitchModeRowMargin')
  private breakPointStateHomeCardSwitchModeRowMargin: BreakpointState<number> = HomeCardSwitchModeRowMargin
  // 主页模式卡片内容文本字体大小
  @Provide('breakPointStateHomeCardSwitchModeFontSize')
  private breakPointStateHomeCardSwitchModeFontSize: BreakpointState<number> = HomeCardSwitchModeFontSize
  // 主页模式卡片文本上下边距
  @Provide('breakPointStateHomeCardSwitchModeTextMargin')
  private breakPointStateHomeCardSwitchModeTextMargin: BreakpointState<MarginGenerate> = HomeCardSwitchModeTextMargin
  // 主页流量统计卡片统计条边距
  @Provide('breakPointStateCardCellularDatabarMargin')
  private breakPointStateCellularDatabarMargin: BreakpointState<MarginGenerate> = HomeCardCellularDatabarMargin
  // 主页流量统计卡片统计条高度
  @Provide('breakPointStateCardCellularDatabarHeight')
  private breakPointStateCellularDatabarHeight: BreakpointState<number> = HomeCardCellularDatabarHeight_6_5
  // 主页流量统计卡片上下行箭头图标大小
  @Provide('breakPointStateCardCellularDataChevronSize')
  private breakPointStateCellularDataChevronSize: BreakpointState<number> = HomeCardCellularDataChevronSize
  // 主页流量统计卡片上下行箭头组件部分间距
  @Provide('breakPointStateCardCellularDataChevronRowMargin')
  private breakPointStateCellularDataChevronRowMargin: BreakpointState<number> = HomeCardCellularDataChevronRowMargin
  // 主页流量统计卡片内容文本字体大小
  @Provide('breakPointStateCardCellularDataFontSize')
  private breakPointStateCellularDataFontSize: BreakpointState<number> = HomeCardCellularDataFontSize
  // 主页卡片标题字体大小
  @Provide('breakPointStateCardTitleFontSize')
  private breakPointStateCardTitleFontSize: BreakpointState<number> = CardTitleFontSize_18_20_22_22
  @Provide('breakPointStateListLanes')
  private breakPointStateListLanes: BreakpointState<number> = BPS_LIST_LANES_1_1_2_3_4
  @Provide('breakPointStateListGutter')
  private breakPointStateListGutter: BreakpointState<number> = BPS_LIST_GUTTER_1_1_2_3_3
  @Provide('breakPointStateListHeight')
  private breakPointStateListHeight: BreakpointState<number> = listHeight_610_590
  @Provide('breakPointStateTabContentTitleMargin')
  private breakPointStateTabContentTitleMargin: BreakpointState<number> = BPS_TAB_CONTENT_TITLE_MARGIN_12_13_28_36
  @Provide('breakPointStateNavigationListPadding')
  private breakPointStateNavigationListPadding: BreakpointState<number> = BPS_NAVIGATION_LIST_PADDING_12_13_13_28_36
  @Provide('breakPointStatemorePageMargin')
  private breakPointStatemorePageMargin: BreakpointState<number> = morePageMargin_12_14_16
  @Provide('breakPointStatemorePagelistBottom')
  private breakPointStatemorePagelistBottom: BreakpointState<number> = morePagelistBottom_10_14
  @Provide('breakPointStateSettingslistHeight')
  private breakPointStateSettingslistHeight: BreakpointState<number> = SettingslistHeight_590_500
  //主页编辑模式 删除按钮尺寸
  @Provide('deleteButtonSize')
  private deleteButtonSize: BreakpointState<number> = DeleteButtonSize_24_32
  //主页卡片内容流量统计下部小字体大小（10,16,14,16）
  @Provide('HomeCardCellularDataSmFontSize')
  private HomeCardCellularDataSmFontSize: BreakpointState<number> = HomeCardCellularDataSmFontSize
  //主页卡片内容当前节点延迟字体大小（16,20,18,24）
  @Provide('HomeCardPrpxySmFontSize')
  private HomeCardPrpxySmFontSize: BreakpointState<number> = HomeCardPrpxySmFontSize
  //主页卡片内容当前节点字体大小
  @Provide('HomeProxyFontSize')
  private ProxyFontSize: BreakpointState<number> = HomeProxyFontSize_24_26_26_27
  //主页卡片内容IP地址小字体大小
  @Provide('HomeCardIPSmFontSize')
  private HomeCardIPSmFontSize: BreakpointState<number> = HomeCardIPSmFontSize
  @Provide('IPfontSize') IPfontSize: BreakpointState<number> = IPfontSize

  //主页卡片内容网络测速字体大小
  @Provide('SpeedfontSize12_14_14_16')
  private SpeedfontSize12_14_14_16: BreakpointState<number> = SpeedfontSize12_14_14_16
  //主页栅格卡片间距
  @Provide('gutterHomeGridcol_12_15')
  private gutterHomeGridcol_12_15: BreakpointState<gutterHomeGridcol> = gutterHomeGridcol_12_15
  //主页整个卡片区域边距
  @Provide('HomeCardAreaPadding')
  private HomeCardAreaPadding: BreakpointState<MarginGenerate> = HomeCardAreaPadding
  /**
   * 主页添加卡片半模拟态卡片高度
   */
  @Provide('HomeCardTitleButtonPadding')
  private HomeCardTitleButtonPadding: BreakpointState<number> = HomeCardTitleButtonPadding
  /**
   * 主页流量统计卡片padding高度
   */
  @Provide('HomeCardCellularDataPadding')
  private HomeCardCellularDataPadding: BreakpointState<number> = HomeCardCellularDataPadding

  /**
   * 主页卡片标题按钮间距
   */
  @Provide('HomeCardEditHeight')
  private HomeCardEditHeight: BreakpointState<number> = HomeCardEditHeight
/*
代理页Provide相关数据
 */
  // 当前代理节点单选选择的值
 // @Provide private ProxyRadioCheckedValue: number =-1
  // 当前代理节点长按选择的值
  @Provide private ProxyItemLongPressValue: number = -1
  // 当前代理节点收藏的值
  @Provide private FavoriteProxy: number =-1
  //节点数据组
  @Provide items: ProxyItem[] = ProxyData.ProxyItems();
  // 日志页临时数据
  @Provide
  private logListData: Array<LogData> = [
  ]

  @Provide configList: Array<ConfigData> = [
    {
      configId: 'a4e2593d-9927-4f57-8868-f316190657a1',
      isNewConfig: false,
      configName: 'SS-Youtube速度快',
      configUrl: 'https://aaa.com:8344',
      isConfigAutoUpdate: true,
      configAutoUpdateTimeGapValue: 10,
      configAutoUpdateTimeGapTextPickerIndex: 1,
      createdDate: '2024-05-21 21:21:21',
      lastUpdateDateTime: 0,
      updateTime: 0,
      trafficUsed: '1329.43GB',
      trafficTotal: '5000GB',
      isFavorite: false,
      sourceType: ConfigDataSourceType.URL,
    },
  ]

  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext
  // 所有子组件在容器内的对齐方式
  @Provide ('stackAlignContentAlignment') stackAlignContentAlignment: Alignment = Alignment.BottomEnd
  @StorageLink('favoriteProfiles') favoriteProfiles: Map<string, string> = new Map<string, string>([])
  @Provide('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
// 设置页变量
  // 设置页面栈
  @Provide('NavSettingsPathStack') SettingsPageInfos: NavPathStack = new NavPathStack()
  // 设置 -> 备份与恢复 -> 是否启用云备份配置
  @Provide isShowCloudconfig: boolean = false
  // 设置页语言选中暂存变量
  @Provide currentLanguage: ResourceStr = $r('app.string.Language_Subtitle')
  // 设置 -> 通知 -> 流量提醒启用状态变量
  @Provide EnableCellularDataReminder: boolean = false
  // 设置页实验功能提示框显示变量
  @Provide isShowExperimentalFunction: boolean = true
  // 设置 -> 外观 -> 按钮位置变量
  @Provide ButtonPositionOffset: number = 0

  // 代理启动的计时文本
  @Provide private proxyStartingDuration: string = PROXY_STARTED_DURATION_INIT_VALUE

  // 是否进入二级界面(Tab区)
  @Provide isSecondary: boolean = false

  @Builder
  TabBarBuilder(title: ResourceStr, index: number, TabIcon: Resource) {

    Flex({
      direction: this.compDirection.value,
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Center
    }) {
      Column() {
        SymbolGlyph(TabIcon)
          .fontColor([this.currentIndex === index ? this.icon_emphasize : this.icon_tertiary])
          .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)//分层颜色
          .fontSize(this.isLandscapePhone ? 24 : this.TabIconfontSize.value)
          .margin({ top: 5 })
          .effectStrategy(this.uiConfig.isAnimation?SymbolEffectStrategy.SCALE:null)

        Text(title)
          .fontColor(this.currentIndex === index ? this.icon_emphasize : this.icon_tertiary)
          .fontWeight(FontWeight.Medium)
          .margin(this.compMargin.value)
          .fontSize(this.isLandscapePhone ? 12 : this.TabTitlefontSize.value)
      }
      .margin(this.isLandscapePhone ? { left: 39 } : '0vp')
    }
    .animation(
      {
        duration: this.uiConfig.animationSpeed,
        tempo:0.3,
        curve: Curve.Ease,
        iterations: 1,
        playMode: PlayMode.Normal
      })
    .width('100%')
    .height('100%')
  }

  /* 是否开启 `Index` 页面的前景模糊 */
  @Provide('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean = false

  // 当手机横屏时条件成立
  deviceHeightListener: mediaquery.MediaQueryListener =
    this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp) and (640vp< width <= 1000vp)');
  // 平板竖屏判断
  tabletHeightListener:mediaquery.MediaQueryListener =
    this.getUIContext().getMediaQuery().matchMediaSync('(1000vp< height)');
  // 折叠屏展开判断
  foldPhoneOpenListener:mediaquery.MediaQueryListener =
    this.getUIContext().getMediaQuery().matchMediaSync('(640vp< height <= 1000vp) and (640vp< width <= 1000vp)');

  // 获取配置列表
  async fetchProfiles(){
    const profiles = await ClashViewModel.getProfiles()
    this.configList = profiles.map((d)=>{
      return {
        configId: d.id,
        configName: d.name,
        isFavorite: this.favoriteProfiles.has(d.id) ?? false,
        configUrl: d.url,
        isConfigAutoUpdate: d.autoUpdate,
        configAutoUpdateTimeGapValue: d.autoUpdateDuration,
        lastUpdateDateTime: d.lastUpdateDate
      } as ConfigData
    })
  }

  async aboutToAppear(): Promise<void>{
    hilog.info(0x1000, this.componentName, `#aboutToAppear executed`)

    this.fetchProfiles()
    EventHub.on(EventKey.FetchProfile, () => {
      this.fetchProfiles()
    })

    // 在页面build前改变主题颜色
    changeThemeColor(this.uiConfig.themeColor)
    hilog.info(0x1000, this.componentName, `#aboutToAppear#ThemeControl.setDefaultTheme(${this.uiConfig.themeColor})`)
    // 初始化切换颜色模式(深色模式)
    this.switchColorMode(this.uiConfig.darkModeIndex)
    // 初始化切换按钮位置
    this.switchButtonPosition(this.uiConfig.buttonPositionIndex)
    // 初始化实验功能显示状态
    this.isShowExperimentalFunction = this.uiConfig.isShowExperimentalFunction
    // 初始化用户语言
    if (this.uiConfig.userLanguage){
      ChangeLanguage(this.uiConfig.userLanguage)
    }

    // 开启change监听
    this.deviceHeightListener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.isLandscapePhone = mediaQueryResult.matches
      AppStorage.setOrCreate<boolean>('isLandscapePhone', this.isLandscapePhone)
      hilog.info(0x1000, this.componentName,
        `#媒体查询#设备高度改变#(320vp< height <= 500vp) and (640vp< width <= 1000vp)手机横屏结果: ${this.isLandscapePhone}`)
    });
    this.tabletHeightListener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.istabletVertical = mediaQueryResult.matches
      AppStorage.setOrCreate<boolean>('istabletVertical', this.istabletVertical)
      hilog.info(0xFF00, this.componentName,
        `#媒体查询#设备高度改变#(1000vp< height)平板竖屏结果: ${this.istabletVertical}`)
    });
    this.foldPhoneOpenListener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.isFoldStatus = mediaQueryResult.matches
      AppStorage.setOrCreate<boolean>('isFoldStatus', this.isFoldStatus)
      hilog.info(0xFF00, this.componentName,
        `#媒体查询#设备折叠状态改变#(640vp< height <= 1000vp) and (640vp< width <= 1000vp)折叠展开结果: ${this.isFoldStatus}`)
    });

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.compDirection)
    BreakpointSystem.getInstance().attach(this.compBarPose)
    BreakpointSystem.getInstance().attach(this.compVertical)
    BreakpointSystem.getInstance().attach(this.compBarWidth)
    BreakpointSystem.getInstance().attach(this.compBarHeight)
    BreakpointSystem.getInstance().attach(this.compMargin)
    BreakpointSystem.getInstance().attach(this.TabIconfontSize)
    BreakpointSystem.getInstance().attach(this.TabTitlefontSize)
    BreakpointSystem.getInstance().attach(this.breakPointStateHomeCardPadding)
    BreakpointSystem.getInstance().attach(this.breakPointStateListLanes)
    BreakpointSystem.getInstance().attach(this.breakPointStateListGutter)
    BreakpointSystem.getInstance().attach(this.breakPointStateTabContentTitleMargin)
    BreakpointSystem.getInstance().attach(this.breakPointStateNavigationListPadding)
    BreakpointSystem.getInstance().attach(this.breakPointStatemorePageMargin)
    BreakpointSystem.getInstance().attach(this.breakPointStatemorePagelistBottom)
    BreakpointSystem.getInstance().attach(this.breakPointStateListHeight)
    BreakpointSystem.getInstance().attach(this.breakPointStateSettingslistHeight)
    BreakpointSystem.getInstance().attach(this.breakPointStateCellularDataChevronSize)
    BreakpointSystem.getInstance().attach(this.breakPointStateCellularDataChevronRowMargin)
    BreakpointSystem.getInstance().attach(this.breakPointStateHomeCardSwitchModeTextMargin)
    BreakpointSystem.getInstance().attach(this.breakPointStateHomeCardTitleBottomMargin)
    BreakpointSystem.getInstance().attach(this.breakPointStateHomeCardSwitchModeRowMargin)
    BreakpointSystem.getInstance().attach(this.breakPointStateHomeCardSwitchModeFontSize)
    BreakpointSystem.getInstance().attach(this.breakPointStateCellularDatabarMargin)
    BreakpointSystem.getInstance().attach(this.breakPointStateCellularDatabarHeight)
    BreakpointSystem.getInstance().attach(this.breakPointStateCellularDataFontSize)
    BreakpointSystem.getInstance().attach(this.breakPointStateCardTitleFontSize)
    BreakpointSystem.getInstance().attach(this.deleteButtonSize)
    BreakpointSystem.getInstance().attach(this.HomeCardCellularDataSmFontSize)
    BreakpointSystem.getInstance().attach(this.HomeCardPrpxySmFontSize)
    BreakpointSystem.getInstance().attach(this.ProxyFontSize)
    BreakpointSystem.getInstance().attach(this.HomeCardIPSmFontSize)
    BreakpointSystem.getInstance().attach(this.IPfontSize)
    BreakpointSystem.getInstance().attach(this.SpeedfontSize12_14_14_16)
    BreakpointSystem.getInstance().attach(this.gutterHomeGridcol_12_15)
    BreakpointSystem.getInstance().attach(this.HomeCardAreaPadding)
    BreakpointSystem.getInstance().attach(this.HomeCardTitleButtonPadding)
    BreakpointSystem.getInstance().attach(this.HomeCardEditHeight)
    BreakpointSystem.getInstance().attach(this.HomeCardCellularDataPadding)
    BreakpointSystem.getInstance().start()
    // TODO


    EventHub.on(EventKey.FetchProxyGroup, async ()=>{
      if(this.appConfig.currentProfileId){
        this.currentProfile = await ClashViewModel.getProfile(this.appConfig.currentProfileId)
        if (this.currentProfile) {
          this.proxyGroups = await ClashViewModel.getProxyGroups(this.clashConfig.mode ?? ProxyMode.Rule)
        }
      }
    })
    EventHub.on(EventKey.SwitchModeCard, async (mode: ProxyMode)=>{
      if (this.currentProfile) {
        this.proxyGroups = await ClashViewModel.getProxyGroups(mode)
      }
    })
    EventHub.on(EventKey.StartLog, async (enable: boolean)=>{
      ClashViewModel.startLog(enable, (log)=>{
        this.logListData.push({
          logType: log.logLevel,
          logTime: log.time,
          LogDetails: log.payload,
          // TODO
          logSkip: log.payload.length > 30
        })
      })
    })
    EventHub.on(EventKey.ClearLog, ()=>{
      this.logListData = []
    })
    EventHub.on(EventKey.ExportLog, ()=>{
      // TODO 导出日志
    })
  }
  @Provide proxyGroups: ProxyGroup[] = []
  @Provide("currentProfile") currentProfile: Profile | null = null
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()


  aboutToDisappear() {
    hilog.info(0x1000, this.componentName, `#aboutToDisappear executed`)
    // 停止监听断点事件，并清空断点对应数据
    BreakpointSystem.getInstance().stop()

    // 解绑listener中注册的回调函数
    this.deviceHeightListener.off('change');
    this.tabletHeightListener.off('change')
    this.foldPhoneOpenListener.off('change')
  }

  /**
   * 切换颜色模式
   * @param index 颜色模式序号
   */
  switchColorMode(index: number) {
    switch (index) {
      case 0:
        // 跟随系统
        setAutoColorMode(this.context)
        break;
      case 1:
        // 始终浅色
        setLightColorMode(this.context)
        break
      case 2:
        // 始终深色
        setDarkColorMode(this.context)
        break
    }
  }

  /**
   * 切换按钮位置
   */
  switchButtonPosition(index:number) {
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


  build() {
    Column() {
      Tabs({
        barPosition: this.isLandscapePhone ? BarPosition.Start : this.compBarPose.value
      }) {
        TabContent() {
       //   if (this.currentIndex===0){
          Home()
      //    }
        }
        .tabBar(this.TabBarBuilder($r('app.string.Home'), 0, $r('sys.symbol.house_fill')))
        .onWillShow(() => {
          this.currentIndex = 0
        })

        TabContent() {
         // if (this.currentIndex===1) {
            ProxyPage()
        //  }
        }
        .tabBar(this.TabBarBuilder($r('app.string.Proxy'), 1, $r('sys.symbol.list_bullet_square_fill')))
        .onWillShow(() => {
          this.currentIndex = 1
        })

        TabContent() {
        //  if (this.currentIndex===2) {
            ConfigurationPage()
        //  }
        }
        .tabBar(this.TabBarBuilder($r('app.string.Configuration'), 2, $r('sys.symbol.folder_fill')))
        .onWillShow(() => {
          this.currentIndex = 2
        })

        TabContent() {
       //   if (this.currentIndex===3) {
            MorePage()
       //   }
        }
        .tabBar(this.TabBarBuilder($r('app.string.More'), 3, $r('sys.symbol.square_fill_grid_2x2')))
        .onWillShow(() => {
          this.currentIndex = 3
        })
      }
      //.barOverlap(true)
      /*.backgroundBrightness({
        rate: 0.5,
        lightUpDegree: 0.5 })*/
      .backgroundColor($r('app.color.background'))
      //.backdropBlur(60)
    //  .barOverlap(true)  //模糊效果，需要重新调整tab高度，此效果会加上tab的高度
      .scrollable(this.isSecondary ? false : true)
      .vertical(this.isLandscapePhone ? true : this.compVertical.value) /**/
      .barWidth(this.isSecondary === false ? (this.isLandscapePhone ? '63vp' : this.compBarWidth.value) : 0) /**/
      .barHeight(this.isSecondary === false ? (this.isLandscapePhone ? '100%' : this.compBarHeight.value) : 0) /**/
      .padding(this.compMargin.value)
      .animationDuration(this.uiConfig.animationSpeed)
      .onChange((index: number) => {
        this.currentIndex = index
      })

    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
    .foregroundBlurStyle(
      this.isEnableIndexForegroundBlur && this.uiConfig.isBlurr ? BlurStyle.Thin : BlurStyle.NONE,
      { colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 0.3 }
    )
    .padding({ top:px2vp(this.topRectHeight) , bottom: this.isLandscapePhone ? 0 :px2vp(this.bottomRectHeight) -15})
    .animation(this.uiConfig.isAnimation ? { duration: this.uiConfig.animationSpeed, curve: Curve.Ease }:null)
  }
}