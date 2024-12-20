import { BreakpointState } from '../common/breakpointsystem'
import {
  TAB_CONTENT_TITLE_FONT_SIZE,
  TAB_CONTENT_TITLE_FONT_WEIGHT,
  ANIMATION_DURATION_300,
  TAB_CONTENT_TITLE_HEIGHT,
  TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE,
  LIST_ITEM_HEIGHT,
  LIST_SPACE,
  BORDER_RADIUS_20,
  BIND_SHEET_CONTAINER_HEIGHT,
  LIST_ITEM_PADDING,
  RouteName,
} from '../common/Constants'
import { LengthMetrics, PromptAction, SymbolGlyphModifier } from '@kit.ArkUI'
import { ConfigAdd } from '../components/Configuration/ConfigAdd'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Callback } from '@ohos.base'
import { ConfigData } from '../common/PageArgumentEntity'

/**
 * 长按菜单参数
 */
interface LongPressContextMenuItem {
  symbolStartIcon?: SymbolGlyphModifier,
  symbolEndIcon?: SymbolGlyphModifier,
  content: ResourceStr
  callback : Callback<void>
}


@Entry
@Component
struct ConfigurationPage {

  private componentName:string = 'ConfigurationPage'

  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor

  private promptAction:PromptAction = this.getUIContext()?.getPromptAction()

  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean

  /* 断点布局相关 相关作用看定义时候的注释 */
  @Consume('breakPointStateListLanes')
  private breakPointStateListLanes: BreakpointState<number>
  @Consume('breakPointStateListGutter')
  private breakPointStateListGutter: BreakpointState<number>
  @Consume('breakPointStateTabContentTitleMargin')
  private breakPointStateTabContentTitleMargin: BreakpointState<number>

  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')
  private isLandscapePhone: boolean = false

  /* NV路由 相关 */
  // 路由栈
  @Provide('configAddPageInfos')
  private configAddPageInfos: NavPathStack = new NavPathStack()

  /* 配置列表List相关 */
  // 当前单选框选择的配置 TODO 待接入用户首选项，先写死 configName，单选框控制现在只用到configName所以先不给值
  // @StorageProp('currentConfigRadioCheckedConfigData')
  @State
  private currentConfigRadioCheckedConfigData: ConfigData = {
    configId: '',
    isNewConfig: false,
    configName: 'VMess-TikTok专用',
    configURL: '',
    isConfigAutoUpdate: false
  }
  // 当前手指触摸的ListItem的对应 `this.configList` 中的 `configName`
  @State
  private currentTouchConfigData: ConfigData = {
    configId: '',
    isNewConfig: false,
    configName: '',
    configURL: '',
    isConfigAutoUpdate: false
  }

  /* 配置页面内ListItem长按ContextMenu相关 */
  // TODO 删除 临时模拟数据配置列表数据
  private configList: Array<ConfigData> = [
    {
      configId: 'SS-Youtube速度快',
      isNewConfig: false,
      configName: 'SS-Youtube速度快',
      configURL: 'https://aaa.com:8344',
      isConfigAutoUpdate: true,
      configAutoUpdateTimeGapValue: 10,
      configAutoUpdateTimeGapTextPickerIndex: 1,
      createdDate: new Date('2024-05-21 21:21:21'),
      lastUpdateDateTime: new Date('2024-12-18 17:51:00'),
      trafficUsed: '1329.43GB',
      trafficTotal: '5000GB'
    },
    {
      configId: 'Trojan-INS专用',
      isNewConfig: false,
      configName: 'Trojan-INS专用',
      configURL: 'http://ealion.com/ins-test',
      isConfigAutoUpdate: true,
      configAutoUpdateTimeGapValue: 233,
      configAutoUpdateTimeGapTextPickerIndex: 0,
      createdDate: new Date('2023-12-20 04:14:35'),
      lastUpdateDateTime: new Date('2024-12-18 15:00:00'),
      trafficUsed: '234.42GB',
      trafficTotal: '700GB'
    },
    {
      configId: 'VMess-TikTok专用',
      isNewConfig: false,
      configName: 'VMess-TikTok专用',
      configURL: 'https://enlin.com:2333',
      isConfigAutoUpdate: false,
      createdDate: new Date('2024-06-16 12:34:56'),
      lastUpdateDateTime: new Date('2024-12-18 12:00:00'),
      trafficUsed: '874.04GB',
      trafficTotal: '2000GB'
    },
    {
    configId: 'VMess-TG专用',
    isNewConfig: false,
    configName: 'VMess-TG专用',
    configURL: 'https://telegram-vmess.enlin.com',
    isConfigAutoUpdate: true,
    configAutoUpdateTimeGapValue: 7,
    configAutoUpdateTimeGapTextPickerIndex: 2,
    createdDate: new Date('2024-01-01 12:24:34'),
    lastUpdateDateTime: new Date('2024-12-19 08:00:00'),
    trafficUsed: '34.05GB',
    trafficTotal: '800GB'
  },
  ]
  // ContextMenu列表项集合 TODO 国际化
  @State
  private configListLongPressCtxMenus: Array<LongPressContextMenuItem> = [
    { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.star'))
        .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
      content: '收藏', callback: ()=>{this.favoriteConfig()}
    },
    { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.square_and_pencil'))
        .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
      content: '编辑', callback: ()=>{this.editConfig()}
    },
    { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.arrow_clockwise'))
        .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
      content: '更新', callback: ()=>{this.updateConfig()}
    },
    { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.share'))
        .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
      content: '分享', callback: ()=>{this.shareConfig()}
    },
    { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.qrcode'))
        .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
      content: '生成二维码', callback: ()=>{this.generateQRcode()}
    },
  ]
  // 配置页面ListItem的长按ContextMenu的Builder
  @Builder
  configListLongPressCtxMenuBuilder() {
    // 当菜单过多（横屏时），自身的滚动条不支持回弹，套一层Scroll
    Scroll(){
      Menu() {
        ForEach(this.configListLongPressCtxMenus, (item: LongPressContextMenuItem, index: number) => {
          MenuItem({ symbolStartIcon: item?.symbolStartIcon, content: item?.content })
            .clickEffect({level: ClickEffectLevel.MIDDLE})
            .contentFontColor($r('sys.color.font_primary'))
            .onClick( () => {
              // hilog.info(0xC002, this.componentName, `#configListLongPressCtxMenuBuilder#onClick():`)
              item.callback()
            })
        })
        // 文字红色 单独处理
        MenuItem({
          symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.trash_fill'))
            .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
            .fontColor(['#E6E54E36']),
          content: '删除'
        })
          .contentFontColor('#E6E54E36')
          .onClick( () => {
            this.deleteConfig()
          })
      }
      .backgroundColor($r('app.color.container_background'))
      .borderRadius(BORDER_RADIUS_20)
      .menuItemDivider({ strokeWidth: LengthMetrics.vp(.4), color: $r('sys.color.comp_divider') })
      .width(200)
      .height('auto')
    }
    .nestedScroll({scrollForward: NestedScrollMode.SELF_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST})
    .edgeEffect(EdgeEffect.Spring)
  }

  /* Stack层叠布局 */
  // 所有子组件在容器内的对齐方式 TODO 【用户首选项】在设置里可以更改 Alignment.BottomStart 和 Alignment.BottomEnd Enlin@2024-12-04

  /* 配置添加按钮bindSheet相关 */
  // 按钮在Stack布局里的位置
  @State
  stackAlignContentAlignment: Alignment = Alignment.BottomEnd
  // 是否显示bindSheet
  @State
  private isShowConfigAddBindSheet: boolean = false
  // 是否需要往`bindSheet`里`push`路由页面
  private isPushRoute2BindSheet: boolean = false
  // 内容Builder
  @Builder
  private ConfigAddBindSheetBuilder(){
    ConfigAdd()
  }

  /* 页面布局相关 */
  // 配置添加按钮宽度
  private proxyStartButtonWidth: Length = $r('app.integer.vp_proxy_not_start_button_width')
  // 配置添加按钮高度
  private proxyStartButtonHeight: Length = $r('app.integer.vp_proxy_not_start_button_height')
  // 配置添加按钮Margin
  private proxyStartButtonMargin: Length = $r('app.integer.vp_proxy_start_button_margin')
  // 配置添加按钮前Symbol动效
  private ReplaceSymbolEffect: SymbolEffect = EffectScope.WHOLE


  build() {
    Column() {
      // 标题栏 START
      if (!this.isLandscapePhone) {
        Row() {
          Text($r('app.string.Configuration'))
            .fontSize(TAB_CONTENT_TITLE_FONT_SIZE)
            .fontWeight(TAB_CONTENT_TITLE_FONT_WEIGHT)
            .fontColor($r('sys.color.font_primary'))
          Blank()
          //  刷新图标
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            SymbolGlyph($r('sys.symbol.arrow_clockwise'))
              .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
              .fontColor([$r('sys.color.icon_secondary')])
          }
          .width(40)
          .height(40)
          .backgroundColor($r('app.color.settings_container_background'))
          .clickEffect({ level: ClickEffectLevel.LIGHT })
          .onClick(() => {
            // TODO 国际化适配 更新配置中... 更新配置成功
            // TODO 调用 更新配置api
            this.promptAction.showToast({ message: `配置更新中...` })
            hilog.info(0xC001, this.componentName, `#button#onClick()#更新配置`)
          })
        }
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .height(TAB_CONTENT_TITLE_HEIGHT)
        .padding({
          left: this.breakPointStateTabContentTitleMargin.value,
          right: this.breakPointStateTabContentTitleMargin.value,
        })
        // .margin({ bottom: 15 })
      }
      // 标题栏 END

      // 主体 START
      Stack({ alignContent: this.stackAlignContentAlignment }) {
        // 配置列表 START
        List({ space: LIST_SPACE }) {
          ForEach(this.configList, (item: ConfigData, index: number) => {
            ListItem() {
              Row() {
                Column() {
                  Text(item.configName).fontColor(($r('sys.color.font_primary')))
                  Text(`index:${index}`).fontColor($r('sys.color.font_secondary'))
                }.alignItems(HorizontalAlign.Start)
                Blank()
                Radio({ value: 'radio' + index, group: 'configGroup' })
                  .checked(item.configName === this.currentConfigRadioCheckedConfigData.configName)
                  .radioStyle({
                    checkedBackgroundColor: this.icon_emphasize,
                  })
              }
              .width('100%')
              .padding(LIST_ITEM_PADDING)
              .alignItems(VerticalAlign.Center)
            }
            .backgroundColor($r('app.color.container_background'))
            .width('100%')
            .height(LIST_ITEM_HEIGHT)
            .clickEffect({ level: ClickEffectLevel.MIDDLE })
            .borderRadius(BORDER_RADIUS_20)
            .hoverEffect(HoverEffect.Scale)
            .bindContextMenu(this.configListLongPressCtxMenuBuilder, ResponseType.LongPress | ResponseType.RightClick,
              {
                preview: MenuPreviewMode.IMAGE,
                previewAnimationOptions: { scale: [1.0, 1.1] },
                placement: Placement.BottomRight
              })
            .onClick(() => {
              this.currentConfigRadioCheckedConfigData = item
              hilog.info(0xC002, this.componentName, `#ListItem#onClick:configName is [${this.currentConfigRadioCheckedConfigData.configName}]`)
            })
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                // TODO 现在用来代替获取长按的是哪一个ListItem，目前用`configName`作为每一个item的唯一性属性
                this.currentTouchConfigData = item
                hilog.info(0xC002, this.componentName, `#ListItem#onTouch(TouchType.Down): configName is [${this.currentTouchConfigData.configName}]`)
              }
            })
            // .gesture(LongPressGesture({ repeat: false }).onAction(() => {
            //   this.isShownConfigListCtxMenu = !this.isShownConfigListCtxMenu
            //   hilog.info(0xC002, this.componentName, `#gesture#LongPressGesture:`)
            // }))
          })
        }
        .width('100%')
        .height('100%')
        .padding({
          left: this.breakPointStateTabContentTitleMargin.value,
          right: this.breakPointStateTabContentTitleMargin.value,
        })
        // 110 = app.integer.vp_proxy_start_button_margin *2 + app.integer.vp_proxy_not_start_button_width
        .contentEndOffset(110)
        .lanes(this.breakPointStateListLanes.value, this.breakPointStateListGutter.value)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .chainAnimation(true)
        // 配置列表 END

        // 悬浮新增配置按钮 START
        Column() {
          Stack({ alignContent: Alignment.Center }) {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
              .fontColor([Color.White])
              .symbolEffect(this.ReplaceSymbolEffect)
              .align(Alignment.Center)
          }
          .width('100%')
          .height('100%')
        }
        // .backgroundColor($r('app.color.speed_down_icon'))
        .shadow({
          radius: 10,
          color: $r('app.color.speed_down_icon'),
          offsetY: 4,
          type: ShadowType.BLUR
        })
        .borderRadius(100)
        .margin(this.proxyStartButtonMargin)
        .width(this.proxyStartButtonWidth)
        .height(this.proxyStartButtonHeight)
        .backgroundColor(this.icon_emphasize)
        .clip(true)
        .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Ease })
        .clickEffect({ level: ClickEffectLevel.LIGHT })
        .hoverEffect(HoverEffect.Scale)
        .bindSheet( this.isShowConfigAddBindSheet, this.ConfigAddBindSheetBuilder, {
          // title: { title: $r('app.string.AddConfig') },
          detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.FIT_CONTENT, ],// SheetSize.LARGE
          backgroundColor: $r('app.color.container_background'),
          showClose: true,
          dragBar: false,
          preferType: SheetType.CENTER,
          // blurStyle: BlurStyle.COMPONENT_ULTRA_THICK,
          blurStyle: BlurStyle.BACKGROUND_REGULAR,
          scrollSizeMode: ScrollSizeMode.CONTINUOUS,
          // width: ('100%'),
          /**
           * 半模态页面显示（动画开始前）回调函数
           *    目前`通过URL(链接)导入`和`长按配置编辑`是用的同一个页面，
           *    这里主要是用来处理拉起`bindSheet`之后可以等`bindSheet`渲染完毕之后正确传入路由信息
           */
          onWillAppear: () => {
            hilog.info(0xC020, this.componentName, `#button#bindSheet#onWillAppear() executed`)
            if (this.isPushRoute2BindSheet) {
              this.pushEditConfigRoute2BindSheet()
              this.isPushRoute2BindSheet = false
            }
          },
          // 半模态页面交互式关闭回调函数
          onWillDismiss: (dismissSheet :DismissSheetAction) => {
          // 在二级路由页面内只能通过点击关闭按钮才能关掉bindSheet
            if (this.configAddPageInfos.size() <= 0 || (dismissSheet.reason === DismissReason.CLOSE_BUTTON)) {
              dismissSheet.dismiss()
              this.isShowConfigAddBindSheet = false
              this.isEnableIndexForegroundBlur = false
              this.configAddPageInfos.clear(true)
              hilog.info(0xC020, this.componentName, `#button#bindSheet#onWillDismiss()#关闭配置添加按钮的bindSheet：DismissSheetAction.dismiss()`)
            }
          },
          onWillSpringBackWhenDismiss: (springBack: SpringBackAction)=> {
            springBack.springBack()
          }
        })
        .onClick( () => {
          this.isShowConfigAddBindSheet = true
          this.isEnableIndexForegroundBlur = true
        })
        // 悬浮新增配置按钮 END
      }
      .backgroundColor($r('app.color.background'))
      // .padding(this.isLandscapePhone ? '0vp' : { bottom: '45vp' })
      .width('100%')
      .height(this.isLandscapePhone ? '100%' :`calc(100% - ${TAB_CONTENT_TITLE_HEIGHT}vp)`)
      // 主体 END
    }
    .width('100%')
    .height('100%')
    .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Linear, delay: 0 })
  }

  aboutToAppear(): void {
    hilog.info(0xC000, this.componentName, `#aboutToAppear executed`)
  }

  aboutToDisappear(): void {
    hilog.info(0xC000, this.componentName, `#aboutToDisappear executed`)
  }

  /**
   * 页面内通用 `配置NV路由` push方法
   * @param routeName 将要路由的页面名称
   * @param param     路由参数
   * @param animated  是否启用转场动画
   */
  pushDestinationByName(routeName: RouteName, param: Object | null, animated?: boolean): void {
    this.configAddPageInfos.pushDestinationByName(routeName, param, animated)
    hilog.info(0xC000, this.componentName, `#pushDestinationByName#NavPathStack.pushDestinationByName(${routeName}, ${JSON.stringify(param)}, ${animated})`)

  }

  /**
   * 拉起配置编辑页 并传参
   */
  pushEditConfigRoute2BindSheet(){
    this.pushDestinationByName(RouteName.ImportConfigFromURL, this.currentTouchConfigData)
  }

  /**
   * 收藏配置
   */
  favoriteConfig(): void {
    // TODO 收藏配置 & 判断是否已经收藏
    this.promptAction.showToast({message: `已收藏⭐`})
    // this.promptAction.showToast({message: `已经收藏过了哦~⭐`})
    hilog.info(0xC010, this.componentName, `#favoriteConfig#收藏配置: configName is [${this.currentTouchConfigData.configName}]`)
  }
  /**
   * 编辑配置
   */
  private editConfig(): void {
    // TODO 编辑bindSheet
    hilog.info(0xC011, this.componentName, `#editConfig#编辑配置: configName is [${this.currentTouchConfigData.configName}]`)
    this.isShowConfigAddBindSheet = true
    this.isPushRoute2BindSheet = true
  }
  /**
   * 更新配置
   */
  private updateConfig(): void {
    // TODO 调用更新配置消息api
    this.promptAction.showToast({message: `配置更新中...`})
    hilog.info(0xC012, this.componentName, `#updateConfig#更新配置: configName is [${this.currentTouchConfigData.configName}]`)
  }
  /**
   * 分享配置
   */
  shareConfig(): void {
    // TODO 处理待分享数据 并调用系统分享接口
    hilog.info(0xC013, this.componentName, `#shareConfig#分享配置: configName is [${this.currentTouchConfigData.configName}]`)
  }
  /**
   * 生成配置二维码
   */
  generateQRcode(): void {
    // TODO 弹出bindSheet 在其中实现“配置url”生成二维码的功能
    hilog.info(0xC014, this.componentName, `#generateQRcode#生成二维码: configName is [${this.currentTouchConfigData.configName}]`)
  }
  /**
   * 删除配置
   */
  deleteConfig(): void {
    // TODO 删除用户首选项里的此配置
    // TODO 弹confirm框确认是否删除？
    hilog.info(0xC015, this.componentName, `#deleteConfig#删除配置: configName is [${this.currentTouchConfigData.configName}]`)
  }

}


export default ConfigurationPage