import { BreakpointState } from '../common/breakpointsystem'
import {
  TAB_CONTENT_TITLE_FONT_SIZE,
  TAB_CONTENT_TITLE_FONT_WEIGHT,
  TAB_CONTENT_TITLE_HEIGHT,
  TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE,
  LIST_SPACE,
  BORDER_RADIUS_20,
  BIND_SHEET_CONTAINER_HEIGHT,
  LIST_ITEM_PADDING,
  RouteName,
  CONTENT_END_OFFSET_150,
} from '../common/Constants'
import { LengthMetrics, promptAction, PromptAction, SymbolGlyphModifier } from '@kit.ArkUI'
import { ConfigAdd } from '../components/Configuration/ConfigAdd'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Callback } from '@ohos.base'
import { ConfigData, ConfigDataSourceType } from '../common/PageArgumentEntity'
import { CellularData, CustomConfirmDialog, Nothing, RightDownButton } from '../components/Common'
import { customVibrator } from "../utils/VibratorUtil"
import { common } from '@kit.AbilityKit'
import { configShare } from '../utils/SystemShareUtil'
import { showFileNameListOfFileDir } from '../utils/FileUtil'
import ClashViewModel from '../entryability/ClashViewModel'
import { AppConfig, UIConfig } from '../entryability/AppState'
import { EventHub, EventKey } from '../common/EventHub'
import { getResourceString } from '../utils/ResourceStringUtil'
import { convertTime } from '../utils/TimeConvertUtil'
import { customAnimationUtil, isON } from '../utils/Animation'
import { ProxyGroup } from 'proxy_core'
import { ProxyItem } from '../common/ProxyData'
import { PopTips, PopupBuilder } from '../components/Start/Popup'
import { ImportConfigFromURL } from '../components/Configuration/ImportConfigFromURL'
import { ImportConfigFromFile } from '../components/Configuration/ImportConfigFromFile'


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
  private context = getContext() as common.UIAbilityContext

  // 获取应用沙箱文件路径
  private pathOfContextFilesDir = this.context.filesDir
  // 列表是否滚动中
  @Consume isRolling: boolean
  // 是否来自文件导入
  @State isFromFile: boolean = false
  // 主界面当前index
  @Consume /*@Watch('onIndexChange')*/ IndexCurrentindex: number
  // 是否小窗口
  @Consume isSmallSquareScreen: boolean
  @State isRefreshing: boolean = false
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 所有子组件在容器内的对齐方式
  @Consume ('stackAlignContentAlignment') stackAlignContentAlignment: Alignment

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
  @StorageLink('isLandscapePhone') private isLandscapePhone: boolean = false

  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 开关不触发list转场动画判定
  @State isON:isON = new isON()
  // 节点数据组
  @Prop items: ProxyItem[]
  @Consume proxyGroups: ProxyGroup[]
  /* NV路由 相关 */
  // 路由栈
  @Provide('configAddPageInfos')
  private configAddPageInfos: NavPathStack = new NavPathStack()
  // page内顶部标题偏移量
  @Consume curYOffset: number
  //loading动画
  @State isLoading : boolean = false
  //px外屏隐藏top和tab偏移
  @Consume heightTop: number
  @Consume curOffsetRemain: number
  @Consume paddingButtom:number|Resource
  // px外屏
  @Consume isPXSecScreen: boolean
  // 平板竖屏判断变量
  @Consume istabletLandscape: boolean
  /* 配置列表List相关 */
  // 当前单选框选择的配置
  @Consume currentConfigRadioCheckedConfigData: ConfigData
  /**
   * XXX 当前手指触摸的ListItem的对应 `this.configList` 中的 `configId`
   *    List的长按菜单中的响应都是根据这个的对象中的属性来处理的，是个不稳定因素
   */
  @Consume('currentTouchConfigData') currentTouchConfigData: ConfigData

  /* 配置页面内ListItem长按ContextMenu相关 */
  @Consume @Watch('onConfigListChange') configList: Array<ConfigData>
  // ContextMenu 列表项 动态替换用
  private configListLongPressCtxMenuForUnFavorite: LongPressContextMenuItem = {
    symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.star_fill'))
      .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.multi_color_11')]),
    content: $r('app.string.uncollected'), callback: ()=>{ this.cancelFavoriteConfig() }
  }
  private configListLongPressCtxMenuForFavorite: LongPressContextMenuItem = {
    symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.star'))
      .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
    content: $r('app.string.Collect'), callback: ()=>{ this.favoriteConfig() }
  }
  // ContextMenu列表项集合
  private configListLongPressCtxMenus: Array<LongPressContextMenuItem> = [
  // { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.star'))
  //     .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
  //   content: '收藏', callback: ()=>{this.favoriteConfig()}
  // },
    { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.square_and_pencil'))
      .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
      content: $r('app.string.Edit'), callback: ()=>{ this.editConfig() }
    },
    { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.arrow_clockwise'))
      .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
      content: $r('app.string.update'), callback: ()=>{ this.updateConfig(this.currentTouchConfigData.configId) }
    },
    // TODO 配置分享、生成二维码、创建副本
   /* { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.share'))
      .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
      content: $r('app.string.share'), callback: ()=>{ this.shareConfigUrl() }
    },
    { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.qrcode'))
      .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
      content: $r('app.string.generate_QR_code'), callback: ()=>{ this.generateQRcode() }
    },*/
    // XXX 分享链接和导出配置文件都已经集成到了“分享”菜单里
    /*    { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.doc_text'))
          .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
          content: '导出配置文件', callback: ()=>{ this.generateQRcode() }
        },*/
   /* { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.plus_square_on_square'))
      .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
      content: $r('app.string.create_copy'), callback: ()=>{ this.generateQRcode() }
    },*/
  ]
  // 配置页面ListItem的长按ContextMenu的Builder
  @Builder
  configListLongPressCtxMenuBuilder(isFavorite:boolean) {
    // 当菜单过多（横屏时），自身的滚动条不支持回弹，套一层Scroll
    Scroll(){
      Menu() {
        // 根据当前配置信息来判断显示[收藏 /取消收藏] 单独处理 START
        if (isFavorite) {
          MenuItem({
            symbolStartIcon: this.configListLongPressCtxMenuForUnFavorite.symbolStartIcon!
              .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE),
            content: this.configListLongPressCtxMenuForUnFavorite.content
          })
            .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
            .contentFontColor($r('sys.color.font_primary'))
            .onClick( () => {
              this.configListLongPressCtxMenuForUnFavorite.callback()
            })
        } else {
          MenuItem({
            symbolStartIcon: this.configListLongPressCtxMenuForFavorite.symbolStartIcon!
              .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE),
            content: this.configListLongPressCtxMenuForFavorite.content
          })
            .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
            .contentFontColor($r('sys.color.font_primary'))
            .onClick( () => {
              this.configListLongPressCtxMenuForFavorite.callback()
            })
        }
        // 根据当前配置信息来判断显示[收藏 /取消收藏] 单独处理 END

        // 遍历其他菜单 START
        ForEach(this.configListLongPressCtxMenus, (item: LongPressContextMenuItem, index: number) => {
          MenuItem({ symbolStartIcon: item?.symbolStartIcon, content: item?.content })
            .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
            .contentFontColor($r('sys.color.font_primary'))
            .onClick( () => {
              // hilog.info(0xC002, this.componentName, `#configListLongPressCtxMenuBuilder#onClick():`)
              item.callback()
            })
        })
        // 遍历其他菜单 END

        // 删除配置 文字红色 单独处理 START
        // 删除配置 文字红色 单独处理 START
        MenuItem({
          symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.trash_fill'))
            .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
            .fontColor(['#E6E54E36']),
          content: $r('app.string.delete')
        })
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .contentFontColor('#E6E54E36')
          .onClick( () => {
            this.configCustomDialogController?.open()
            this.isEnableIndexForegroundBlur = true
          })
        // 删除配置 文字红色 单独处理 END
      }
      .backgroundColor($r('app.color.container_background'))
      .borderRadius(BORDER_RADIUS_20)
      .menuItemDivider({ strokeWidth: LengthMetrics.vp(.4), color: $r('sys.color.comp_divider') })
      .width(200)
      .height('auto')
      .transition(this.uiConfig.isAnimation ? TransitionEffect.asymmetric(TransitionEffect.move(TransitionEdge.END), TransitionEffect.move(TransitionEdge.START))
        .animation({ duration: this.uiConfig.animationSpeed, curve: Curve.Ease })
        .combine(TransitionEffect.OPACITY):null
      )
    }
    .nestedScroll({scrollForward: NestedScrollMode.SELF_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST})
    .edgeEffect(EdgeEffect.Spring)
  }
  /* 自定义弹框 */
  // 配置是否保存弹框 Controller定义
  private configCustomDialogController: CustomDialogController | null= new CustomDialogController({
    builder: CustomConfirmDialog({
      title: $r('app.string.delete_current_configuration'),
      cancelText: $r('app.string.delete'),
      confirmText: $r('app.string.Cancel'),
      cancelButtonBackgroundColor: Color.Transparent,
      // 不可以使用`@Consume`注解的变量
      // confirmButtonBackgroundColor: this.icon_emphasize,
      cancel: () => {
        this.isEnableIndexForegroundBlur = false
        this.deleteConfig()
      },
      confirm: ()=> {
        this.isEnableIndexForegroundBlur = false
        this.promptAction.showToast({ message: $r('app.string.click_error_prompt') })
      }
    }),
    cancel: () => {
      this.isEnableIndexForegroundBlur = false
    },
    autoCancel: true,
    alignment: DialogAlignment.Center,
    width: 328,
    backgroundColor: $r('app.color.list_item_background_color'),
  })

  /* Stack层叠布局 */
  // 所有子组件在容器内的对齐方式

  /* 配置添加按钮bindSheet相关 */

  // 是否显示bindSheet
  @Provide private isShowConfigAddBindSheet: boolean = false
  // 是否需要往`bindSheet`里`push`路由页面
  private isPushRoute2BindSheet: boolean = false
  // 是否为二级半模态页
  private isSecondBindSheet: boolean = false
  // 内容Builder
  @Builder
  private ConfigAddBindSheetBuilder(){
    if (this.isPushRoute2BindSheet) {
      // 二级界面
      if (this.isFromFile) {
        // 文件导入的
        ImportConfigFromFile({ configData: this.currentTouchConfigData })
      } else {
        // URL导入的
        ImportConfigFromURL({ configData: this.currentTouchConfigData })
      }
    } else {
      ConfigAdd()
    }
  }
  @Builder
  LoadingBuilder() {
    LoadingProgress()
      .color(this.icon_emphasize)
      .width(40)
      .height(40)
      .margin({bottom: 15})
  }

  /* 页面布局相关 */
  // 配置添加按钮宽度
  private proxyStartButtonWidth: Length = $r('app.integer.vp_proxy_not_start_button_width')
  // 配置添加按钮高度
  private proxyStartButtonHeight: Length = $r('app.integer.vp_proxy_not_start_button_height')
  // 配置添加按钮前Symbol动效
  private ReplaceSymbolEffect: SymbolEffect = EffectScope.WHOLE

  build() {
    Stack() {
      // 标题栏 START
      if (!this.isPXSecScreen) {
        Row() {
          Text($r('app.string.Configuration'))
            .fontSize(this.curYOffset < 0 ? TAB_CONTENT_TITLE_FONT_SIZE - this.curYOffset / 100 :
              TAB_CONTENT_TITLE_FONT_SIZE)
            .fontWeight(TAB_CONTENT_TITLE_FONT_WEIGHT)
            .fontColor($r('sys.color.font_primary'))
            .transition(customAnimationUtil.isSlide(200, this.uiConfig))
          Blank()
          // 刷新图标
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            SymbolGlyph($r('sys.symbol.arrow_clockwise'))
              .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
              .fontColor([$r('sys.color.icon_primary')])
              .effectStrategy(customAnimationUtil.isIconEffect(this.uiConfig))
          }
          .width(40)
          .height(40)
          .backgroundColor($r('app.color.settings_container_background'))
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .onClick(() => {
            this.isON.toggleAnim = true
            hilog.info(0xC001, this.componentName, `#button#onClick()#更新配置`)
            this.updateConfig()
          })
          .transition(customAnimationUtil.isSlide(0, this.uiConfig))
        }
        .zIndex(1)
        .height(this.curYOffset < 0 ? TAB_CONTENT_TITLE_HEIGHT - this.curYOffset : TAB_CONTENT_TITLE_HEIGHT)
        .position({ x: 0, y: this.isRolling && this.isSmallSquareScreen ? this.heightTop : 0 })
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .padding({
          left: this.breakPointStateTabContentTitleMargin.value,
          right: this.breakPointStateTabContentTitleMargin.value,
        })
      }
      // 标题栏 END

      // 主体 START
      Stack({ alignContent: this.stackAlignContentAlignment }) {
        if (this.configList.length === 0) {
          Nothing({ name: $r('app.string.Configuration') })
            .height('90%')
        } else {
          Column(){
            if (!this.isPXSecScreen) {
              Blank().height((this.isRolling && this.isSmallSquareScreen) ? this.heightTop : TAB_CONTENT_TITLE_HEIGHT)
            }
            Refresh({refreshing: $$this.isRefreshing, builder: this.LoadingBuilder()}) {
              // 配置列表 START
              List({ space: LIST_SPACE }) {
                ForEach(this.configList, (item: ConfigData, index: number) => {
                  ListItem() {
                    Row() {
                      Column({ space: 2 }) {
                        Text(item.configName).fontColor(($r('sys.color.font_primary'))).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                        Row() {
                          Text($r('app.string.update_by'))
                            .fontColor($r('sys.color.font_secondary')).fontSize(14)
                          Text(convertTime(item.lastUpdateDateTime))
                            .fontColor($r('sys.color.font_secondary')).fontSize(14).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                        }

                        // 进度条组件: 使用流量 / 总流量
                        if (item.subscriptionInfo){
                          CellularData({ info: item.subscriptionInfo })
                        }

                      }.alignItems(HorizontalAlign.Start).width('85%').padding({top:10,bottom:10})

                      Blank()
                      if (item.configId === this.appConfig.currentProfileId && this.isLoading){
                        LoadingProgress()
                          .color(this.icon_emphasize)
                          .width(25).height(25)
                          .transition(customAnimationUtil.isOpacity(this.uiConfig))
                      }
                        Radio({ value: 'radio' + index, group: 'configGroup'})
                          .checked(item.configId === this.currentConfigRadioCheckedConfigData.configId)
                          .radioStyle({
                            checkedBackgroundColor: this.icon_emphasize,
                          })
                          .hitTestBehavior(HitTestMode.None)
                    }
                    .width('100%')
                    .padding(LIST_ITEM_PADDING)
                    .alignItems(VerticalAlign.Center)
                  }.width('100%')
                  .backgroundColor($r('app.color.container_background'))
                  .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                  .borderRadius(BORDER_RADIUS_20)
                  .hoverEffect(HoverEffect.Scale)
                  .transition(this.isON.toggleAnim ? null : customAnimationUtil.isScaleTran(index, this.uiConfig))
                  .bindContextMenu(this.isPXSecScreen ? null :this.configListLongPressCtxMenuBuilder(item?.isFavorite ?? false),
                    ResponseType.LongPress | ResponseType.RightClick,
                    {
                      preview: MenuPreviewMode.IMAGE,
                      previewAnimationOptions: { scale: [1.0, 1.1] },
                      placement: Placement.BottomRight,
                      aboutToAppear: () => {
                        if (this.uiConfig.isVibrate) {
                          customVibrator.vibratorTriggerOfHapticClockTimer()
                        }
                      }
                    })
                  .onClick(async () => {
                    this.isON.toggleAnim = true
                    // 更新当前选中
                    this.currentConfigRadioCheckedConfigData = item
                    await this.loadConfig(item)
                    hilog.info(0xC002, this.componentName, `#ListItem#onClick:configName is [${this.currentConfigRadioCheckedConfigData.configName}]`)
                  })
                  .onTouch((event: TouchEvent) => {
                    if (event.type === TouchType.Down) {
                      // TODO 现在用来代替获取长按的是哪一个ListItem，目前用`configName`作为每一个item的唯一性属性
                      this.currentTouchConfigData = item
                      hilog.info(0xC002, this.componentName,
                        `EditConfig #ListItem#onTouch(TouchType.Down): configUrl is [${this.currentTouchConfigData.configUrl}]`)
                    }
                  })
                  .bindPopup(!!this.uiConfig.ShowConfigPop, {
                    builder: PopupBuilder(this, PopTips[1], () => {
                      this.uiConfig.ShowConfigPop = false
                    }),
                    onWillDismiss: false,
                    autoCancel: false
                  })

                })
              }
              .width('100%')
              .height('100%')
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
              .padding({
                left: this.breakPointStateTabContentTitleMargin.value,
                right: this.breakPointStateTabContentTitleMargin.value,
              })
              // 110 = app.integer.vp_proxy_start_button_margin *2 + app.integer.vp_proxy_not_start_button_width
              .contentEndOffset(this.isPXSecScreen? 65:CONTENT_END_OFFSET_150)
              .lanes(this.breakPointStateListLanes.value, this.breakPointStateListGutter.value)
              .edgeEffect(EdgeEffect.Spring)
              .chainAnimation(true)
              .nestedScroll({
                scrollForward: NestedScrollMode.PARENT_FIRST,
                scrollBackward: NestedScrollMode.SELF_FIRST
              })
              // 配置列表 END
            }
            .refreshOffset(64)
            .pullToRefresh(true)
            .onRefreshing(() => {
              this.updateConfig()
            })
            /*Scroll() {
            }
            .edgeEffect(this.uiConfig.isAnimation?EdgeEffect.Spring:null)//,{alwaysEnabled:true})
            .onDidScroll((xOffset: number, yOffset: number, scrollState: ScrollState): void => {
              // 累计计算当前父组件滚动在Y轴方向的偏移量
              if (this.uiConfig.isAnimation){
                this.curYOffset += yOffset
              }
              console.info("yOffset" + this.curYOffset);
            })*/
          }
        }

        // 悬浮新增配置按钮 START
        if (!this.isPXSecScreen) {
          Column() {
            RightDownButton(
              $r('sys.symbol.plus'),
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
          .margin({
            bottom: this.isLandscapePhone || this.istabletLandscape || !this.uiConfig.isBlurr ?
            $r('app.integer.vp_proxy_start_button_left_right_margin') : (this.isRolling && this.isSmallSquareScreen) ?
              this.paddingButtom : $r('app.integer.vp_proxy_start_button_bottom_margin'),
            right: $r('app.integer.vp_proxy_start_button_left_right_margin'),
            left: $r('app.integer.vp_proxy_start_button_left_right_margin')
          })
          .bindSheet(this.isShowConfigAddBindSheet, this.ConfigAddBindSheetBuilder, {
            detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.LARGE,], // SheetSize.LARGE
            backgroundColor: $r('app.color.background'),
            showClose: true,
            dragBar: false,
            preferType: SheetType.CENTER,
            scrollSizeMode: ScrollSizeMode.CONTINUOUS,
            // width: ('100%'),
            /**
             * 半模态页面显示（动画开始前）回调函数
             *    目前`通过URL(链接)导入`和`长按配置编辑`是用的同一个页面，
             *    这里主要是用来处理拉起`bindSheet`之后可以等`bindSheet`渲染完毕之后正确传入路由信息
             */
            onWillAppear: () => {
              hilog.info(0xC020, this.componentName, `#button#bindSheet#onWillAppear() executed`)
              this.isEnableIndexForegroundBlur = true
              if (this.isPushRoute2BindSheet) {
                // this.pushEditConfigRoute2BindSheet()
                this.isSecondBindSheet = true
                this.isPushRoute2BindSheet = false
              }
            },
            // 半模态页面交互式关闭回调函数
            onWillDismiss: async (dismissSheet: DismissSheetAction) => {
              // 在二级路由页面内只能通过点击关闭按钮才能关掉bindSheet
              if (this.configAddPageInfos.size() <= 0 || (dismissSheet.reason === DismissReason.CLOSE_BUTTON)) {
                dismissSheet.dismiss()
                this.isShowConfigAddBindSheet = false
                this.isEnableIndexForegroundBlur = false
                this.configAddPageInfos.clear(true)
                hilog.info(0xC020, this.componentName,
                  `#button#bindSheet#onWillDismiss()#关闭配置添加按钮的bindSheet：DismissSheetAction.dismiss()`)
              }
            },
            onWillDisappear: async () => {
              if (this.isSecondBindSheet) {
                hilog.info(0xC020, this.componentName, `EditConfig #button#bindSheet#onWillDisappear 名称 ${this.currentTouchConfigData.configName}`)
                this.isSecondBindSheet = false
              }
            },
            onWillSpringBackWhenDismiss: (springBack: SpringBackAction) => {
              springBack.springBack()
            }
          })
          .onClick(() => {
            this.isShowConfigAddBindSheet = true
            this.isEnableIndexForegroundBlur = true
            if (this.uiConfig.isVibrate) {
              customVibrator.vibratorTriggerOfHapticClockTimer()
            }
          })
        }
        // 悬浮新增配置按钮 END
      }
      .backgroundColor($r('app.color.background'))
      .width('100%')
      .height('100%')
      // 主体 END
    }
    .width('100%')
    .height('100%')
    .animation({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear, delay: 0 })
  }

  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('favoriteProfiles') favoriteProfiles: Map<string, string> = new Map<string, string>([])

  aboutToAppear(): void {
    hilog.info(0xC000, this.componentName, `#aboutToAppear executed`)
    // XXX 删除 这里模拟获取所有hap沙箱路径配置文件的文件名
    showFileNameListOfFileDir(this.context.filesDir)
    EventHub.on(EventKey.FetchProfile, () => {
      this.fetchProfiles()
    })
    if (this.configList.length !== 0) {
      this.currentConfigRadioCheckedConfigData = this.configList.find(obj => obj.configId === this.appConfig.currentProfileId) as ConfigData
    }
  }

  async onIndexChange() {
    if (this.configList.length !== 0 && this.IndexCurrentindex === 2) {
      await ClashViewModel.updateProfileConfig(null)
      this.promptAction.showToast({message: '更新所有配置成功'})
    }
  }

  async loadConfig(item: ConfigData, needUpdated = false){
    hilog.info(0xC011, this.componentName, `EditConfig #loadConfig#加载配置: configName is [${this.currentTouchConfigData.configName}]`)
    if (this.isLoading)
      return
    animateTo({
      duration: this.uiConfig.animationSpeed,
      iterations: 1,
      playMode: PlayMode.Normal,
      curve:Curve.Ease,
    }, () => {
      this.isLoading = true;
    })
    this.appConfig.currentProfileName = item.configName
    this.appConfig.currentProfileId = item.configId
    try {
      if(needUpdated){
        ClashViewModel.updateProfileConfig(item.configId)
      }
      ClashViewModel.socketProxy.reset()
      await ClashViewModel.loadConfig(false)
    }catch (e) {
      console.debug("loadConfigList", e.message, JSON.stringify(e))
      promptAction.showToast({message: `${getResourceString($r('app.string.failed_load_config'), this.context)}` + (e.message || e) })
    }
    animateTo({
      duration: this.uiConfig.animationSpeed,
      iterations: 1,
      playMode: PlayMode.Normal,
      curve:Curve.Ease,
    }, () => {
      this.isLoading = false;
    })
  }

  async onConfigListChange() {
    hilog.info(0xC011, this.componentName, `EditConfig #onConfigListChange#配置列表第一项: configName is [${this.configList[0].configName}]`)
    if (!this.uiConfig.isFirstImportConfig) {
      return
    }
    // 首次导入配置自动选中
    if (this.configList.length === 1 && this.uiConfig.isFirstImportConfig) {
      this.isON.toggleAnim = true
      hilog.info(0xC011, this.componentName, `EditConfig #onConfigListChange#配置列表的第一项: configName is [${this.configList[0].configName}]`)
      await this.loadConfig(this.configList[0])
      this.currentConfigRadioCheckedConfigData = this.configList[0]
      this.uiConfig.isFirstImportConfig = false
      hilog.info(0xC002, this.componentName,
        `EditConfig #onConfigListChange: 首次导入：${this.uiConfig.isFirstImportConfig} configName is [${this.currentConfigRadioCheckedConfigData.configName}]`)
    }
  }

  // 获取完整配置列表
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
        lastUpdateDateTime: d.lastUpdateDate,
        subscriptionInfo: d.subscriptionInfo
      } as ConfigData
    })
  }

  aboutToDisappear(): void {
    hilog.info(0xC000, this.componentName, `#aboutToDisappear executed`)
    EventHub.off(EventKey.FetchProfile)
    this.configCustomDialogController = null
    this.isEnableIndexForegroundBlur = false
    hilog.info(0xC000, this.componentName, `#aboutToDisappear#置空[配置页\`bindSheet\`内提示是否删除配置信息的自定义弹框]`)
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
  private pushEditConfigRoute2BindSheet(){
    this.pushDestinationByName(RouteName.IMPORT_CONFIG_FROM_URL, this.currentTouchConfigData)
  }

  /**
   * 收藏配置
   */
  private favoriteConfig(): void {
    // TODO 收藏配置 & 判断是否已经收藏
    if (this.favoriteProfiles.size<=3){
    this.promptAction.showToast({ message: $r('app.string.Collect_Tip') })
    hilog.info(0xC010, this.componentName, `#favoriteConfig#收藏配置: configName is [${this.currentTouchConfigData.configName}]`)
    this.currentTouchConfigData.isFavorite = true
    this.favoriteProfiles.set(this.currentTouchConfigData.configId, this.currentTouchConfigData.configName)
    }else {
      this.promptAction.showToast({ message: $r('app.string.favorite_config_no') })
    }
  }
  /**
   * 取消收藏配置
   */
  private cancelFavoriteConfig(): void {
    // TODO 取消收藏配置 & 判断是否已经收藏
    this.promptAction.showToast({ message: $r('app.string.uncollected_tip') })
    hilog.info(0xC010, this.componentName, `#favoriteConfig#取消收藏配置: configName is [${this.currentTouchConfigData.configName}]`)
    this.currentTouchConfigData.isFavorite = false
    this.favoriteProfiles.delete(this.currentTouchConfigData.configId)
  }
  /**
   * 编辑配置
   */
  private editConfig(): void {
    hilog.info(0xC011, this.componentName, `#editConfig#编辑配置: configName is [${this.currentTouchConfigData.configName}]`)
    // 识别配置导入途径
    this.isFromFile = this.currentTouchConfigData.configUrl.toLowerCase().startsWith('file://')
    // 切换为二级界面
    this.isPushRoute2BindSheet = true
    // 赋值为false
    this.currentTouchConfigData.isNewConfig = false
    this.isShowConfigAddBindSheet = true
  }
  /**
   * 更新配置
   */
  private async updateConfig(configId?: string): Promise<void> {
    this.promptAction.showToast({message: $r('app.string.updating_config')})
    if (configId){
      this.isRefreshing = false
      // 使开关点击时不触发转场动画
      this.isON.toggleAnim = true
      await this.loadConfig(this.currentTouchConfigData, true)
      hilog.info(0xC012, this.componentName, `#updateConfig#更新配置{单个}: configUrl is [${this.currentTouchConfigData.configUrl}], configId is [${this.currentTouchConfigData.configId}]`)
      this.promptAction.showToast({message: $r('app.string.updated_success_config')})
    } else {
      // 使开关点击时不触发转场动画
      this.isON.toggleAnim = true
      hilog.info(0xC012, this.componentName, `#updateConfig#更新配置{所有}`)
      // TODO loading and try
      await ClashViewModel.updateProfileConfig(null)
      this.isRefreshing = false
      this.promptAction.showToast({message: $r('app.string.updated_success_config')})
    }

  }
  /**
   * 分享配置的URL
   */
  private shareConfigUrl(): void {
    // TODO 处理待分享数据 并调用系统分享接口 只有URL导入的配置才可以分享链接
    hilog.info(0xC013, this.componentName, `#shareConfig#分享配置: configName is [${this.currentTouchConfigData.configName}]`)
    let systemShareResult: boolean = configShare(this.context, this.currentTouchConfigData.configUrl, this.currentTouchConfigData.configId)
    if (!systemShareResult) {
      this.promptAction.showToast({ message: `分享错误，请联系开发者！🐛` })
    }
  }
  /**
   * 生成配置的URL转成的二维码
   *    1. URL & 二维码 导入的配置用对应URL生成二维码
   *    2. 其他方式导入的配置不能生成二维码
   */
  private generateQRcode(): void {
    // TODO 弹框CustomDialog，在其中实现“配置url”生成二维码的功能
    if (this.currentTouchConfigData.sourceType !== ConfigDataSourceType.URL &&
      this.currentTouchConfigData.sourceType !== ConfigDataSourceType.QR_CODE ) {
      this.promptAction.showToast({ message: `${getResourceString($r('app.string.config_share_prompt'), this)}~🫡` })
    }
    hilog.info(0xC014, this.componentName, `#generateQRcode#生成二维码: configName is [${this.currentTouchConfigData.configName}]`)
  }
  /**
   * 导出配置
   */
  private exportConfig(): void {
    // TODO 导出配置
    hilog.info(0xC015, this.componentName, `#deleteConfig#删除配置: configName is [${this.currentTouchConfigData.configName}]`)
  }
  /**
   * 删除配置
   */
  private async  deleteConfig(): Promise<void> {
    this.promptAction.showToast({ message: `${getResourceString($r('app.string.configuration_deleted'), this)}💔` })
    hilog.info(0xC016, this.componentName, `#deleteConfig#删除配置: configName is [${this.currentTouchConfigData.configName}]`)
    await ClashViewModel.deleteProfile(this.currentTouchConfigData.configId)
    this.appConfig.currentProxyName=undefined
    this.appConfig.currentProfileName=undefined
    this.fetchProfiles()
  }
}


export default ConfigurationPage