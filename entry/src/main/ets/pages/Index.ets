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
  ANIMATION_DURATION_300,
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
  HomeCardCellularDataPadding
} from '../common/Constants'
import { ThemeControl } from '@ohos.arkui.theme'
import { CustomThemeName, CUSTOM_THEME_MAP } from '../common/AppTheme'
import { Item, ProxyData } from '../common/ProxyData'
import { image } from '@kit.ImageKit'
import { Dns, ProxyGroup } from 'proxy_core'
import { EventHub, EventKey } from '../common/EventHub'
import ClashViewModel from '../entryability/ClashViewModel'
import { AppConfig } from '../entryability/AppState'
PersistentStorage.persistProp("persistedMapString", new Map<number, string>([]));


//
interface marginGenerate {
  top: number,
  bottom: number,
  left: number,
  right: number
}

@Entry
@Component
struct Index {
  private componentName: string = 'Index'
   @StorageProp('theme')
  // TODO 使用用户首选项之后 删掉`@State`，取消注释上面的`@StorageProp`
 // @State
  selectedTheme: CustomThemeName = 'blueAppTheme'


  /**
   * 主题色
   *    示例中主题配置里配置了一个颜色，所以只用`ResourceColor`类型的变量来接收色值，
   *    如果有多个颜色，就把这个变量换成`CustomTheme`类型的变量）
   */
  @Provide('icon_emphasize')
  icon_emphasize: ResourceColor = $r('sys.color.icon_emphasize')
  @State icon_tertiary: ResourceColor = $r('sys.color.icon_tertiary') //三级图标色，浅灰色

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
  @State istabletVertical: boolean = false
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0; // 读取导航条区域的高度
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
  @Provide private ProxyRadioCheckedValue: number =-1
  // 当前代理节点长按选择的值
  @Provide private ProxyItemLongPressValue: number = -1
  // 当前代理节点收藏的值
  @Provide private FavoriteProxy: number =-1
  //节点数据组
  @Provide items: Item[] = ProxyData.ProxyItems();

  @Provide proxyGroups: ProxyGroup[] = []
  /**
   * 主页卡片组件截图
   */
  @Provide ('pixmapSpeed')pixmapSpeed: image.PixelMap | undefined = undefined
  @Provide ('pixmapSwitchMode')pixmapSwitchMode: image.PixelMap | undefined = undefined
  @Provide ('pixmapCellularData')pixmapCellularData: image.PixelMap | undefined = undefined
  @Provide ('pixmapCurrentNode')pixmapCurrentNode: image.PixelMap | undefined = undefined
  @Provide ('pixmapPublicNetwork')pixmapPublicNetwork: image.PixelMap | undefined = undefined
  @Provide ('pixmapFavoriteProxy')pixmapFavoriteProxy: image.PixelMap | undefined = undefined
  @Provide ('pixmapFavoriteConfiguration')pixmapFavoriteConfiguration: image.PixelMap | undefined = undefined
  @Provide ('pixmapCurrentConfiguration')pixmapCurrentConfiguration: image.PixelMap | undefined = undefined
  @Provide ('pixmapProxyINFO')pixmapProxyINFO: image.PixelMap | undefined = undefined
  @Provide ('pixmapShortcuts')pixmapShortcuts: image.PixelMap | undefined = undefined

  // 所有子组件在容器内的对齐方式
  @Provide ('stackAlignContentAlignment') stackAlignContentAlignment: Alignment = Alignment.BottomEnd

  /* 是否开启全局动画判定 */
  @Provide ('isAnimation') isAnimation: boolean = true

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
          .effectStrategy(SymbolEffectStrategy.SCALE)

        Text(title)
          .fontColor(this.currentIndex === index ? this.icon_emphasize : this.icon_tertiary)
          .fontWeight(FontWeight.Medium)
          .margin(this.compMargin.value)
          .fontSize(this.isLandscapePhone ? 12 : this.TabTitlefontSize.value)
      }
      .margin(this.isLandscapePhone ? { left: 39 } : '0vp')
    }
    .width('100%')
    .height('100%')
  }

  /* 是否开启 `Index` 页面的前景模糊 */
  @Provide('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean = false

  // 当设备横屏时条件成立 ps:现在用于判定是否手机(大折叠除外)横屏
  deviceHeightListener: mediaquery.MediaQueryListener =
    this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');
  // 平板竖屏判断
  tabletHeightListener:mediaquery.MediaQueryListener =
    this.getUIContext().getMediaQuery().matchMediaSync('(1000vp< height)');


  aboutToAppear() {
    hilog.info(0x1000, this.componentName, `#aboutToAppear executed`)

    // 在页面build前执行ThemeControl，就可以改变主题颜色
    ThemeControl.setDefaultTheme(CUSTOM_THEME_MAP.get(this.selectedTheme))
    hilog.info(0x1000, this.componentName, `#aboutToAppear#ThemeControl.setDefaultTheme(${this.selectedTheme})`)

    // 开启change监听
    this.deviceHeightListener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.isLandscapePhone = mediaQueryResult.matches
      AppStorage.setOrCreate<boolean>('isLandscapePhone', this.isLandscapePhone)
      hilog.info(0x1000, this.componentName,
        `#媒体查询#设备高度改变#(320vp< height <= 500vp)结果: ${this.isLandscapePhone}`)
    });
    this.tabletHeightListener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.istabletVertical = mediaQueryResult.matches
      AppStorage.setOrCreate<boolean>('istabletVertical', this.istabletVertical)
      hilog.info(0xFF00, this.componentName,
        `#媒体查询#设备高度改变#(1000vp< height)平板竖屏结果: ${this.istabletVertical}`)
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
    setTimeout(()=>{
      ClashViewModel.initProfile()
    }, 500)
    EventHub.on(EventKey.FetchProxyGroup, async ()=>{
      this.proxyGroups = await ClashViewModel.getProxyGroups()
    })

  }
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()


  aboutToDisappear() {
    hilog.info(0x1000, this.componentName, `#aboutToDisappear executed`)
    // 停止监听断点事件，并清空断点对应数据
    BreakpointSystem.getInstance().stop()

    // 解绑listener中注册的回调函数
    this.deviceHeightListener.off('change');
    this.tabletHeightListener.off('change')
  }

  // 改变设备横竖屏状态函数
  /*private changeOrientation(isLandscapePhone: boolean) {
    // 获取UIAbility实例的上下文信息
    let context:common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    // 调用该接口手动改变设备横竖屏状态
    window.getLastWindow(context).then((lastWindow) => {
      lastWindow.setPreferredOrientation(isLandscapePhone ? window.Orientation.LANDSCAPE : window.Orientation.PORTRAIT)
    });
  }*/

  build() {
    Column() {

      Tabs({
        barPosition: this.isLandscapePhone ? BarPosition.Start : this.compBarPose.value
      }) {
        TabContent() {
          Home()
        }
        .tabBar(this.TabBarBuilder($r('app.string.Home'), 0, $r('sys.symbol.house_fill')))

        TabContent() {
          ProxyPage()
        }
        .tabBar(this.TabBarBuilder($r('app.string.Proxy'), 1, $r('sys.symbol.list_bullet_square_fill')))

        TabContent() {
          ConfigurationPage()
        }
        .tabBar(this.TabBarBuilder($r('app.string.Configuration'), 2, $r('sys.symbol.folder_fill')))

        TabContent() {
          MorePage()
        }
        .tabBar(this.TabBarBuilder($r('app.string.More'), 3, $r('sys.symbol.square_fill_grid_2x2')))
      }
      //.barOverlap(true)
      /*.backgroundBrightness({
        rate: 0.5,
        lightUpDegree: 0.5 })*/
      .backgroundColor($r('app.color.background'))
      //.backdropBlur(60)
    //  .barOverlap(true)  //模糊效果，需要重新调整tab高度，此效果会加上tab的高度
      .vertical(this.isLandscapePhone ? true : this.compVertical.value) /**/
      .barWidth(this.isLandscapePhone ? '63vp' : this.compBarWidth.value) /**/
      .barHeight(this.isLandscapePhone ? '100%' : this.compBarHeight.value) /**/
      .padding(this.compMargin.value)
      .animationDuration(200)
      .onChange((index: number) => {
        this.currentIndex = index
      })

    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
    .foregroundBlurStyle(
      this.isEnableIndexForegroundBlur ? BlurStyle.Thin : BlurStyle.NONE,
      { colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 0.3 }
    )
    .padding({ top:px2vp(this.topRectHeight) , bottom: this.isLandscapePhone ? 0 :px2vp(this.bottomRectHeight) -15})
    .animation(this.isAnimation ? { duration: ANIMATION_DURATION_300, curve: Curve.Ease }:null)
  }
}