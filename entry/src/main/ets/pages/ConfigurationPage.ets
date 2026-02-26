
import {
  TAB_CONTENT_TITLE_FONT_SIZE,
  TAB_CONTENT_TITLE_HEIGHT,
  TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE,
  LIST_SPACE,
  BORDER_RADIUS_20,
  BIND_SHEET_CONTAINER_HEIGHT,
  LIST_ITEM_PADDING,
  CONTENT_END_OFFSET_150,
  NewConfigData,
  APP_LINKING,
  BIND_SHEET_DRAG_BAR_HEIGHT,
  BIND_SHEET_TITLE_CONTAINER_HEIGHT,
} from '../common/entity/Constants'
import { LengthMetrics, SymbolGlyphModifier } from '@kit.ArkUI'
import { ConfigAdd } from '../components/Configuration/ConfigAdd'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Callback } from '@ohos.base'
import { ConfigData } from '../common/entity/PageArgumentEntity'
import {
  CellularData, CustomConfirmDialog, icon_tertiary, Nothing } from '../components/Common/Common'
import { customVibrator } from "../common/utils/VibratorUtil"
import ClashViewModel from '../entryability/ClashViewModel'
import { AppConfig, UIConfig } from '../entryability/AppState'
import { EventHub, EventKey } from '../common/EventHub'
import { getResourceString } from '../common/utils/ResourceStringUtil'
import { convertTime } from '../common/utils/TimeConvertUtil'
import { customAnimationUtil, isON } from '../common/utils/Animation'
import { ProfileType } from 'proxy_core'
import { PopTips, PopupBuilder } from '../components/Start/Popup'
import { ImportConfigFromURL } from '../components/Configuration/ImportConfigFromURL'
import { ImportConfigFromFile } from '../components/Configuration/ImportConfigFromFile'
import { TopBar } from '../components/Common/TopBar'
import { ListGutter, ListLanes, NavigationListPadding, TabContentTitleMargin } from '../common/breakpoint/BreakPoint'
import { RoundButton } from '../components/Common/RoundButton'
import { harmonyShare } from '@kit.ShareKit'
import { uniformTypeDescriptor as utd } from '@kit.ArkData'
import { common, Context } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit';
import { fileUri, fileIo as fs, picker } from '@kit.CoreFileKit'
import { ShareData, Xb_GetResourceString,
  Xb_PreferenceUtil,
  Xb_Share, Xb_TabBarVertical, Xb_ToastUtil } from 'xb_components'
import { QRCodeDialog } from '../components/Configuration/QRCodeComponent'
import { JSON } from '@kit.ArkTS'


/**
 * 长按菜单参数
 */
interface LongPressContextMenuItem {
  symbolStartIcon?: SymbolGlyphModifier,
  symbolEndIcon?: SymbolGlyphModifier,
  content: ResourceStr
  callback : Callback<void>
}

const componentName:string = 'ConfigurationPage'

@Entry
@Component
struct ConfigurationPage {

  @StorageLink('favoriteProfiles') favoriteProfiles: Map<string, string> = new Map<string, string>([])
  @StorageLink('appConfig') @Watch('onChangeConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @StorageLink('ConfigContent') configStr: string = ''

  // 所有子组件在容器内的对齐方式
  @Consume ('stackAlignContentAlignment') stackAlignContentAlignment: Alignment
  // 路由栈
  @Consume('configAddPageInfos') configAddPageInfos: NavPathStack

  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 导航条区域的高度
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  // 主窗口ID
  @StorageProp('MainWindowId') mainWindowId: number = 1
  // 开关不触发list转场动画判定
  @State isON: isON = new isON()

  // 前台判断变量
  @StorageProp('ForwardState') @Watch('onForwardChange') isForward: boolean = false
  // 窗口模式
  @StorageProp('WindowMode') windowMode: boolean = false
  // 是否为新建配置
  @StorageLink('ConfigNew') isNewConfig: boolean = false
  @State isRefreshing: boolean = false
  @State isShowMenu: boolean = false
  // 是否来自文件导入
  @State isFromFile: boolean = false
  // loading动画
  @State isLoading : boolean = false
  // 展示排序界面
  @State showSort: boolean = false

  // 是否显示bindSheet
  @StorageLink('ShowConfigBindSheet') isShowConfigAddBindSheet: boolean = false
  @StorageLink('ConfigDownloading') isConfigDownloading: boolean = false
  // 是否显示二维码半模态
  @State isShowQRCode: boolean = false
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  // 是否小窗口
  @Consume isSmallSquareScreen: boolean
  // px外屏
  @Consume isPXSecScreen: boolean
  // 判断设置是否清楚数据
  @Consume isClearData: boolean
  // 列表是否滚动中
  @Consume isRolling: boolean

  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @Consume paddingButtom: number | Resource
  // 主界面当前index
  @Consume @Watch('onForwardChange') tabCurrentPage: number
  @Consume curOffsetRemain: number
  // px外屏隐藏top和tab偏移
  @Consume heightTop: number
  // page内顶部标题偏移量
  @Consume curYOffset: number

  /**
   * 配置页面内长按触摸项
   */
  @StorageLink('currentTouchConfigData') currentTouchConfigData: ConfigData = NewConfigData
  @Consume('Configuration') @Watch('onConfigListChange') configList: Array<ConfigData>
  @State currentRadioConfigData: ConfigData = NewConfigData

  build() {
    Stack() {
      // 标题栏 START
      if (!this.isPXSecScreen) {
        Row() {
          TopBar({
            title: getResourceString($r('app.string.Configuration'), this),
            titleFontSize: this.curYOffset < 0 ? TAB_CONTENT_TITLE_FONT_SIZE - this.curYOffset / 100 : TAB_CONTENT_TITLE_FONT_SIZE,
            icons: [$r('sys.symbol.sort'), $r('sys.symbol.arrow_clockwise')],
            iconSize: this.windowMode ? 18 : (this.curYOffset < 0 ? 24 - this.curYOffset / 100 : 24),
            // 排序按钮
            onFClick: () => {
              this.showSort = true
              this.isShowConfigAddBindSheet = true
            },
            // 刷新图标
            onSClick: () => {
              this.isON.toggleAnim = true
              hilog.info(0xC001, componentName, `#button#onClick()#更新配置`)
              this.updateConfig()
            }
          })
        }
        .zIndex(1)
        .backgroundColor($r('app.color.background'))
        .height(this.curYOffset < 0 ? TAB_CONTENT_TITLE_HEIGHT - this.curYOffset : TAB_CONTENT_TITLE_HEIGHT)
        .position({ x: 0, y: this.isRolling && this.isSmallSquareScreen && !this.windowMode ? this.heightTop : 0 })
        .alignItems(this.windowMode ? VerticalAlign.Top : VerticalAlign.Center)
        .width('100%')
      }
      // 标题栏 END

      // 主体 START
      Stack({ alignContent: this.stackAlignContentAlignment }) {
        if (this.configList.length === 0) {
          Nothing({ name: $r('app.string.Configuration') })
            .height('90%')
        } else {
          Column() {
            if (!this.isPXSecScreen) {
              Blank().height((this.isRolling && this.isSmallSquareScreen) ? this.heightTop : TAB_CONTENT_TITLE_HEIGHT)
            }
            Refresh({refreshing: $$this.isRefreshing, builder: this.LoadingBuilder()}) {
              // 配置列表 START
              List({ space: LIST_SPACE }) {
                ForEach(this.configList, (item: ConfigData, index: number) => {
                  ListItem() {
                    Stack() {
                      // 名称
                      Column({ space: 2 }) {
                        Text(item.configName).fontColor(($r('sys.color.font_primary'))).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                        // Text(`当前id：${item.configId}`)
                        // Text(`当前选中：${this.appConfig.currentProfileId}`)
                        Row() {
                          Text($r('app.string.update_by'))
                            .fontColor($r('sys.color.font_secondary')).fontSize(14)
                          Text(convertTime(item.lastUpdateDateTime))
                            .fontColor($r('sys.color.font_secondary')).fontSize(14).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                          // Text(`type: ${item.sourceType}`)
                        }

                        // 进度条组件: 使用流量 / 总流量
                        if (item.subscriptionInfo){
                          CellularData({ info: item.subscriptionInfo })
                        }

                      }
                      .width('100%')
                      .padding({top: 10, bottom: 10})
                      .alignItems(HorizontalAlign.Start)
                      // 进度条 & 单选框
                      Row() {
                        if (item.configId === this.appConfig.currentProfileId && this.isLoading){
                          LoadingProgress()
                            .color(this.icon_emphasize)
                            .width(25).height(25)
                            .transition(customAnimationUtil.isOpacity(this.uiConfig))
                        }
                        Radio({ value: 'radio' + index, group: 'configGroup'})
                          .checked(item.configId === this.appConfig.currentProfileId)
                          .radioStyle({
                            checkedBackgroundColor: this.icon_emphasize,
                          })
                          .hitTestBehavior(HitTestMode.None)
                      }.width('100%').justifyContent(FlexAlign.End)
                    }
                    .width('100%')
                    .padding(LIST_ITEM_PADDING)

                  }
                  .width('100%')
                  .backgroundColor($r('app.color.container_background'))
                  .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                  .borderRadius(BORDER_RADIUS_20)
                  .hoverEffect(HoverEffect.Scale)
                  .transition(this.isON.toggleAnim ? null : customAnimationUtil.isScaleTran(index, this.uiConfig))
                  .bindContextMenu(this.isShowMenu && this.currentTouchConfigData.configId == item.configId, this.isPXSecScreen ? null : this.configListLongPressCtxMenuBuilder(item),
                    {
                      preview: MenuPreviewMode.IMAGE,
                      previewAnimationOptions: { scale: [1.0, 1.1] },
                      placement: Placement.BottomRight,
                      aboutToAppear: () => {
                        if (this.uiConfig.isVibrate) {
                          customVibrator.vibratorTriggerOfHapticClockTimer()
                        }
                      },
                      aboutToDisappear: () => {
                        this.isShowMenu = false
                      }
                    })
                  .gesture(
                    TapGesture({ count: 2 })
                      .onAction(async (event: GestureEvent) => {
                        if (event) {
                          hilog.debug(0xC020, componentName, `#TapGesture 配置列表项双击`)
                          await this.loadConfig(item)
                        }
                      })
                  )
                  .gesture(
                    TapGesture({ count: 1 })
                      .onAction((event: GestureEvent) => {
                        if (event) {
                          hilog.debug(0xC020, componentName, `#TapGesture 配置列表项单击`)
                          this.isON.toggleAnim = true
                          if (this.currentRadioConfigData.configId != item.configId) {
                            this.loadConfig(item)
                          }
                          // 更新当前选中
                          this.currentRadioConfigData = item
                        }
                      })
                  )
                  .onMouse((event) => {
                    // 右键菜单
                    if (event.action == MouseAction.Press && event.button == MouseButton.Right) {
                      this.currentTouchConfigData = item
                      this.isShowMenu = true
                    }
                  })
                  .gesture(LongPressGesture()
                    .onAction(() => {
                      // 赋值当前长按触摸列表项
                      this.currentTouchConfigData = item
                      // 显示菜单
                      this.isShowMenu = true
                    }))
                  .bindPopup(!!this.uiConfig.ShowConfigPop, {
                    builder: PopupBuilder(this, PopTips[1], () => {
                      this.uiConfig.ShowConfigPop = false
                    }),
                    onWillDismiss: false,
                    autoCancel: false
                  })
                }, /*(item: ConfigData) => item.configId*/) // TODO 这id明明挺唯一的说
              }
              .zIndex(3)
              .width('100%')
              .height('100%')
              .onScrollFrameBegin((offset: number) => {
                this.curOffsetRemain += offset
                if (offset > 0) {
                  this.isRolling = true
                } else if(offset < 0) {
                  this.isRolling = false
                  this.curOffsetRemain = 0
                }
                // console.info("offsetRemain:" + offset + '/' +this.curOffsetRemain);
                return { offsetRemain: offset }
              })
              .padding({
                left: TabContentTitleMargin(this.widthBp, this.heightBp),
                right: TabContentTitleMargin(this.widthBp, this.heightBp),
              })
              // 110 = app.integer.vp_proxy_start_button_margin *2 + app.integer.vp_proxy_not_start_button_width
              .contentEndOffset(this.isPXSecScreen? 65 : CONTENT_END_OFFSET_150)
              .lanes(ListLanes(this.widthBp, this.heightBp), ListGutter(this.widthBp, this.heightBp))
              .edgeEffect(EdgeEffect.Spring)
              .chainAnimation(true)
              .nestedScroll({
                scrollForward: NestedScrollMode.PARENT_FIRST,
                scrollBackward: NestedScrollMode.SELF_FIRST
              })
              // 配置列表 END
            }.zIndex(2)
            .refreshOffset(64)
            .pullToRefresh(true)
            .onRefreshing(() => {
              this.updateConfig()
            })

          }
        }

        // 悬浮新增配置按钮 START — 按位置选择转场方向，三元简化判断
        if (this.uiConfig.isFloatButtonVisible) {
          if (!this.isPXSecScreen && this.uiConfig.tabStyle == 'custom') {
            RoundButton({ Icon2: $r('sys.symbol.plus') })
              .transition(customAnimationUtil.getFloatButtonTransition(this.uiConfig, this.uiConfig.buttonPositionIndex))
              .onClick(() => { EventHub.sendEvent(EventKey.AddConfig) })
          } else {
            this.FloatAddButton()
          }
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
    .alignContent(Alignment.Top)
    // .animation({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear, delay: 0 })
    .bindSheet($$this.isShowConfigAddBindSheet, this.ConfigAddBindSheetBuilder(), {
      detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.LARGE,], // SheetSize.LARGE
      backgroundColor: $r('app.color.background'),
      showClose: this.isShowQRCode ? false : true,
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
        hilog.info(0xC020, componentName, `#button#bindSheet#onWillAppear() executed`)
        this.isEnableIndexForegroundBlur = true
        this.onForwardChange()
      },
      // 半模态页面交互式关闭回调函数
      onWillDismiss: async (dismissSheet: DismissSheetAction) => {
        // 在二级路由页面内只能通过点击关闭按钮才能关掉bindSheet
        if (this.configAddPageInfos.size() <= 0 || (dismissSheet.reason === DismissReason.CLOSE_BUTTON)) {
          dismissSheet.dismiss()
          this.isShowConfigAddBindSheet = false
          if (!this.isConfigDownloading) {
            this.isEnableIndexForegroundBlur = false
          }
          this.configAddPageInfos.clear(true)
          hilog.info(0xC020, componentName,
            `#button#bindSheet#onWillDismiss()#关闭配置添加按钮的bindSheet：DismissSheetAction.dismiss()`)
        }
      },
      onWillDisappear: async () => {},
      onDisappear: () => {
        Xb_PreferenceUtil.save().then(() => {
          hilog.debug(0xC020, componentName,
            `#button#bindSheet#onWillDismiss()#关闭配置添加按钮的bindSheet：DismissSheetAction.dismiss() ConfigSort Xb_PreferenceUtil 首选项保存成功`)
        }).catch((err: BusinessError) => {
          hilog.error(0xC020, componentName,
            `#button#bindSheet#onWillDismiss()#关闭配置添加按钮的bindSheet：DismissSheetAction.dismiss() ConfigSort Xb_PreferenceUtil 首选项保存失败，message：${err.message}`)
        })
        setTimeout(() => {
          // 关闭背景模糊 TODO 此处添加是为了修复添加配置关闭半模态背景模糊未能正常关闭
          if (!this.isConfigDownloading) {
            this.isEnableIndexForegroundBlur = false
          }
        })
        this.isNewConfig = false
        this.showSort = false
        this.onForwardChange()
        this.configStr = ''  // 置空配置文本
      },
      // onWillSpringBackWhenDismiss: (springBack: SpringBackAction) => {
      //   springBack.springBack()
      // },
      onWillSpringBackWhenDismiss: () => {} // 注册回调，防止反向回弹
    })
  }

  // ContextMenu 列表项 动态替换用
  configListLongPressCtxMenuForUnFavorite: LongPressContextMenuItem = {
    symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.star_fill'))
      .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.multi_color_11')]),
    content: $r('app.string.uncollected'), callback: () => { this.cancelFavoriteConfig() }
  }

  configListLongPressCtxMenuForFavorite: LongPressContextMenuItem = {
    symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.star'))
      .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
    content: $r('app.string.Collect'), callback: () => { this.favoriteConfig() }
  }

  /* 自定义弹框 */
  // 配置是否保存弹框 Controller定义
  configCustomDialogController: CustomDialogController | null = new CustomDialogController({
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
      confirm: () => {
        this.isEnableIndexForegroundBlur = false
        Xb_ToastUtil.showToast({ message: $r('app.string.click_error_prompt') })
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

  /**
   * ContextMenu列表项集合
   */
  configListLongPressCtxMenus(item: ConfigData): Array<LongPressContextMenuItem> {
    return [
      { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.square_and_pencil')).fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
        content: $r('app.string.Edit'),
        callback: () => {
         this.isShowQRCode = false
         this.isNewConfig = false
         this.editConfig()
        }
      },
      ...(!item.disableUpdate ? [
        { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.arrow_clockwise'))
          .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
          content: $r('app.string.update'), callback: () => { this.updateConfig(this.currentTouchConfigData.configId) }
        } as LongPressContextMenuItem] : []),
      ...(this.currentTouchConfigData.sourceType === ProfileType.Url ? [
        { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.share'))
        .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
        content: $r('app.string.share'), callback: () => { this.shareConfigUrl() }
      } as LongPressContextMenuItem ] : []),
      // 二维码分享
      { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.qrcode'))
       .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
       content: $r('app.string.generate_QR_code'), callback: ()=>{ this.generateQRcode() }
     },
      // 导出配置文件
      { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.doc_text'))
        .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
        content: $r('app.string.export_config_file'), callback: () => { this.exportConfig() }
      },
   /*  { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.plus_square_on_square'))
       .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE).fontColor([$r('sys.color.font_primary')]),
       content: $r('app.string.create_copy'), callback: ()=>{ this.generateQRcode() }
     },*/
    ]

  }

  @Builder
  FloatAddButton() {
    Row() {
      SymbolGlyph($r('sys.symbol.plus'))
        .fontSize(27).fontColor([icon_tertiary])
    }
    .backdropBlur(this.uiConfig.isBlurr ? 30 : 0)
    .backgroundColor(this.uiConfig.isBlurr ? $r('app.color.float_tab_background_blur') : $r('app.color.background'))
    .borderRadius(30)
    .margin({ bottom: 20})
    .size({width: 50, height: 50})
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .shadow({
      radius: 15,
      offsetY: 4,
      color: $r('app.color.shadow_button'),
      type: ShadowType.COLOR
    })
    .margin({
      bottom: Xb_TabBarVertical(this.widthBp, this.heightBp) || this.uiConfig.tabStyle == 'custom' ? 15 : this.bottomRectHeight == 0 ? 85 : this.bottomRectHeight + 63.5,
      right: 15,
      left: 15,
    })
    .onClick(() => {
      // 新配置
      EventHub.sendEvent(EventKey.AddConfig)
    })
    .transition(customAnimationUtil.getFloatButtonTransition(this.uiConfig, this.uiConfig.buttonPositionIndex))
  }

  /**
   * 配置页面ListItem的长按ContextMenu的Builder
   */
  @Builder
  configListLongPressCtxMenuBuilder(data: ConfigData) {
    // 当菜单过多（横屏时），自身的滚动条不支持回弹，套一层Scroll
    Scroll(){
      Menu() {
        // 根据当前配置信息来判断显示[收藏 /取消收藏] 单独处理 START
        if (this.favoriteProfiles.has(data.configId)) {
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
        ForEach(this.configListLongPressCtxMenus(data), (item: LongPressContextMenuItem) => {
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

  @Builder
  ConfigAddBindSheetBuilder() {
    if (this.isNewConfig) {
      ConfigAdd()
    }
    // 分享二维码
    else if (this.isShowQRCode) {
      QRCodeDialog({
        theDialogTitle: $r('app.string.qrcode_share'),
        QRCodeParam: { // 二维码参数
          // TODO PC端需适配
          url: this.currentTouchConfigData.configUrl,
          name: this.currentTouchConfigData.configName,
        },
        confirm: async () => {
          // 关闭二级界面
          this.isShowQRCode = false
          this.isShowConfigAddBindSheet = false
        },
        cancel: () => {
          // 关闭二级界面
          this.isShowQRCode = false
          this.isShowConfigAddBindSheet = false
        },
      })
    } else if (this.showSort) {
      // 排序窗口
      this.SortBuilder()
    } else {
      // 二级编辑界面
      if (this.isFromFile) {
        // 文件导入的
        ImportConfigFromFile({ configData: this.currentTouchConfigData })
      } else {
        // URL导入的
        ImportConfigFromURL({ configData: this.currentTouchConfigData })
      }
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
        ForEach(this.configList, (item: ConfigData, index: number) => {
          ListItem() {
            Row() {
              // 名称
              Text(item.configName).fontColor(($r('sys.color.font_primary'))).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
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
          .transition(this.isON.toggleAnim ? null : customAnimationUtil.isScaleTran(index, this.uiConfig))
        }, (item: ConfigData) => item.configId)
          .onMove((from: number, to: number) => {
            let tmp = this.configList.splice(from, 1)
            this.configList.splice(to, 0, tmp[0])
            // 更新保存的排序表
            Xb_PreferenceUtil.putSync('config_sort', JSON.stringify(this.configList.map(id => id.configId)))
            console.info(`ConfigSort  Xb_PreferenceUtil config_sort 更新为，${JSON.stringify(this.configList.map(id => id.configId))}`)
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

  async aboutToAppear(): Promise<void> {
    hilog.info(0xC000, componentName, `#aboutToAppear executed`)
    // 初始化当前选中项数据
    this.currentRadioConfigData = this.configList.find((data: ConfigData) => data.configId === this.appConfig.currentProfileId) ?? NewConfigData
    // 初始化分享工具
    Xb_Share.inputInfo(this.getUIContext())
    // 注册打开添加配置弹窗事件
    EventHub.on(EventKey.AddConfig, async () => {
      this.isNewConfig = true
      this.currentTouchConfigData = NewConfigData
      this.isShowConfigAddBindSheet = true
      this.isEnableIndexForegroundBlur = true
      if (this.uiConfig.isVibrate) {
        customVibrator.vibratorTriggerOfHapticClockTimer()
      }
    })
  }

  async onDidBuild(): Promise<void> {
    await this.openShare()
  }

  async onIndexChange() {
    if (this.configList.length !== 0 && this.tabCurrentPage === 2) {
      await ClashViewModel.updateProfileConfig(null)
      Xb_ToastUtil.showToast({ message: '更新所有配置成功' })
    }
  }

  async loadConfig(item: ConfigData, needUpdated: boolean = true) {
    hilog.info(0xC011, componentName, `EditConfig UpdateConfig #loadConfig#加载配置: configName is [${this.currentTouchConfigData.configName}] 是否需要更新：${needUpdated && !item.disableUpdate} 更新时间：${item.updateTime}`)
    if (this.isLoading)
      return
    this.getUIContext().animateTo({
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
      if (needUpdated && !item.disableUpdate) {
        ClashViewModel.updateProfileConfig(item.configId)
      }
      await ClashViewModel.socketProxy.reset()
      await ClashViewModel.loadConfig(false, '配置页-加载')
      hilog.info(0xC011, componentName, `EditConfig #loadConfig#更新并加载完成 configName is [${this.currentTouchConfigData.configName}]`)
    } catch (e) {
      console.debug("loadConfigList", e.message, JSON.stringify(e))
      Xb_ToastUtil.showToast({message: `${getResourceString($r('app.string.failed_load_config'), this)}` + (e.message || e), duration: 3000 })
    }
    this.getUIContext().animateTo({
      duration: this.uiConfig.animationSpeed,
      iterations: 1,
      playMode: PlayMode.Normal,
      curve:Curve.Ease,
    }, () => {
      this.isLoading = false;
    })
  }

  async onConfigListChange() {
    hilog.info(0xC011, componentName, `EditConfig #onConfigListChange#配置列表长度: [${this.configList.length}]`)
    if (!this.uiConfig.isFirstImportConfig || this.isClearData) {
      hilog.info(0xC011, componentName, `EditConfig #onConfigListChange#设置数据清除: [${this.isClearData}]`)
      this.isClearData = false
      hilog.info(0xC011, componentName, `EditConfig #onConfigListChange#设置数据清除: [${this.isClearData}]`)
      return
    }
    // 首次导入配置自动选中
    if (this.configList.length === 1 && this.uiConfig.isFirstImportConfig) {
      this.isON.toggleAnim = true
      await this.loadConfig(this.configList[0])
      this.uiConfig.isFirstImportConfig = false
      hilog.info(0xC002, componentName,
        `EditConfig #onConfigListChange: 首次导入：${this.uiConfig.isFirstImportConfig} configName is [${this.configList[0].configName}]`)
    }
  }

  aboutToDisappear(): void {
    hilog.info(0xC000, componentName, `#aboutToDisappear executed`)
    EventHub.off(EventKey.AddConfig)
    this.configCustomDialogController = null
    this.isEnableIndexForegroundBlur = false
    hilog.info(0xC000, componentName, `#aboutToDisappear#置空[配置页\`bindSheet\`内提示是否删除配置信息的自定义弹框]`)
    Xb_Share.immersiveDisablingListening('all')
  }

  /**
   * 收藏配置
   */
  private favoriteConfig(): void {
    hilog.info(0xC010, componentName, `#favoriteConfig#收藏配置: configName is [${this.currentTouchConfigData.configName}]`)
    if (this.favoriteProfiles.size <= 5) {
      this.currentTouchConfigData.isFavorite = true
      this.favoriteProfiles.set(this.currentTouchConfigData.configId, this.currentTouchConfigData.configName)
      Xb_ToastUtil.showToast({ message: $r('app.string.Collect_Tip') })
    } else {
      Xb_ToastUtil.showToast({ message: $r('app.string.favorite_config_no') })
    }
  }

  /**
   * 取消收藏配置
   */
  private cancelFavoriteConfig(): void {
    hilog.info(0xC010, componentName, `#favoriteConfig#取消收藏配置: configName is [${this.currentTouchConfigData.configName}]`)
    this.currentTouchConfigData.isFavorite = false
    this.favoriteProfiles.delete(this.currentTouchConfigData.configId)
    Xb_ToastUtil.showToast({ message: $r('app.string.uncollected_tip') })
  }

  /**
   * 编辑配置
   */
  private editConfig(): void {
    hilog.info(0xC011, componentName, `#editConfig#编辑配置: configName is [${this.currentTouchConfigData.configName}]`)
    // 识别配置导入途径
    this.isFromFile = this.currentTouchConfigData.configUrl.toLowerCase().startsWith('file://')
    // 切换为二级界面
    this.isNewConfig = false
    // 赋值为false
    this.currentTouchConfigData.isNewConfig = false
    // 提前加载配置文本
    EventHub.sendEvent(EventKey.LoadConfigStr)
    // 显示半模态编辑弹窗
    this.isShowConfigAddBindSheet = true
  }

  /**更新配置*/
  private async updateConfig(configId?: string): Promise<void> {
    Xb_ToastUtil.showToast({message: $r('app.string.updating_config')})
    this.loadConfig(this.currentRadioConfigData, !this.currentRadioConfigData.disableUpdate)
    if (configId) {
      this.isRefreshing = false
      // 使开关点击时不触发转场动画
      this.isON.toggleAnim = true
      await ClashViewModel.updateProfileConfig(configId)
      hilog.info(0xC012, componentName, `#updateConfig#更新配置{单个}: configUrl is [${this.currentTouchConfigData.configUrl}], configId is [${this.currentTouchConfigData.configId}]`)

    } else {
      // 使开关点击时不触发转场动画
      this.isON.toggleAnim = true
      hilog.info(0xC012, componentName, `#updateConfig#更新配置{所有}`)
      await ClashViewModel.updateProfileConfig(null)
      this.isRefreshing = false
      Xb_ToastUtil.showToast({message: $r('app.string.updated_success_config')})
    }
  }

  /**分享配置的URL*/
  private async shareConfigUrl(): Promise<void> {
    // 处理待分享数据 并调用系统分享接口 只有URL导入的配置才可以分享链接
    let shareData = await this.getShareData('touch')

    if (shareData) {
      const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      Xb_Share.shareData = shareData
      // 进行分享面板分享
      try {
        await Xb_Share.sharePlant(context)
      } finally {
        // TODO 现存问题，分享后的碰一碰，隔空投递的配置项会被覆盖。下面逻辑是临时解决办法
        shareData = await this.getShareData('radio')
        Xb_Share.shareData = shareData
      }
    }
  }

  // TODO 待最低版本兼容为6.0后需绑定窗口ID
  async onForwardChange() {
    if (this.isForward && this.tabCurrentPage === 2) {
      // 前台时注册碰一碰分享事件
      Xb_Share.immersiveListening('all')
      const capabilityRegistry: harmonyShare.SendCapabilityRegistry = {
        windowId: this.mainWindowId
      }
    } else {
      // 后台时解除
      const capabilityRegistry: harmonyShare.SendCapabilityRegistry = {
        windowId: this.mainWindowId
      }
      // 解除隔空投递、碰一碰 分享监听事件
      Xb_Share.immersiveDisablingListening('all')
      console.log(`onForwardChange 解除碰一碰事件`)
    }
  }

  /**
   *  @description 获取分享的数据
   *  @param type touch | radio -> touch 长按选中的配置项，radio 当前选中的配置项
   */
  private async getShareData(type: 'touch' | 'radio' = 'radio'): Promise<ShareData> {
    const currentConfigData = type === 'touch' ? this.currentTouchConfigData : this.currentRadioConfigData

    // 将背景图写入沙箱中并获取
    const ctx: Context = this.getUIContext().getHostContext() as Context;
    const filePath = ctx.filesDir + '/shared.jpg';
    // 获取应用图标
    try {
      let file = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      fs.writeSync(file.fd,
        (ctx.resourceManager.getMediaContentSync($r('app.media.shared').id) as Uint8Array).buffer);
      fs.closeSync(file);
      hilog.info(0xC014, componentName, `将背景图写入沙箱中并获取: ${filePath}`)
    } catch (e) {
      hilog.error(0xC014, componentName, `error: ${JSON.stringify(e)}`)
    }

    // TODO 构造分享数据 AppLink 携带订阅 URL 完成 => 应用直达订阅分享
    const shareData: ShareData = {
      utd: utd.UniformDataType.HYPERLINK,
      content: `${APP_LINKING}?configUrl=${currentConfigData.configUrl}&configName=${currentConfigData.configName}`,
      thumbnailUri: fileUri.getUriFromPath(filePath),
      title: $r('app.string.configuration_shared'),
      description: currentConfigData.configName,
      label: '',
      uri: ''
    };

    hilog.info(0xC014, componentName, `碰一碰 - 分享的 configUrl: ${JSON.stringify(currentConfigData)}`)

    return shareData
  }
  
  /**
   * @description 开启 隔空投递、碰一碰 分享监听
   */
  private async openShare() {
    if (canIUse('SystemCapability.Collaboration.HarmonyShare')) {
      const shareData = await this.getShareData('radio')
      if (shareData) {
        Xb_Share.shareData = shareData
        // 隔空投递、碰一碰 分享监听
        Xb_Share.immersiveListening('all')

        // Xb_ToastUtil.showToast({
        //   message: '碰一碰，分享当前配置！📄',
        //   duration: 3000
        // })
      }
    } else {
      Xb_ToastUtil.showToast({
        message: '当前设备暂不支持系统分享功能！'
      })
    }
  }

  /**
   * 生成配置的URL转成的二维码
   *    1. URL & 二维码 导入的配置用对应URL生成二维码
   *    2. 其他方式导入的配置不能生成二维码
   */
  private generateQRcode(): void {
    this.isShowQRCode = true
    this.isShowConfigAddBindSheet = true
    hilog.info(0xC014, componentName, `#generateQRcode#生成二维码: configName is [${this.currentTouchConfigData.configName}]`)
  }

  /**
   * 导出配置文件
   */
  private async exportConfig(): Promise<void> {
    hilog.info(0xC015, componentName, `#exportConfig #导出配置文件: configName is [${this.currentTouchConfigData.configName}]`)
    const context = this.getUIContext().getHostContext()!
    // 提取配置名称
    const fileNameDotIndex = this.currentTouchConfigData.configName.lastIndexOf('.')
    const fileName = (fileNameDotIndex == -1 || fileNameDotIndex == 0) ? this.currentTouchConfigData.configName : this.currentTouchConfigData.configName.slice(0, fileNameDotIndex)
    console.debug(`待导出配置文件的 fileName: ${fileName}`)
    const sandPath = context.filesDir + `/ClashBox/profiles/` + this.currentTouchConfigData.configId + '/config.yaml'
    const sandUri = fileUri.getUriFromPath(sandPath)
    const filePicker = new picker.DocumentViewPicker(context)
    const options = new picker.DocumentSaveOptions()
    options.newFileNames = [fileName]
    options.fileSuffixChoices = ["'文档|.yaml'"]
    options.pickerMode = picker.DocumentPickerMode.DOWNLOAD
    const result = await filePicker.save(options)
    const exportUri = fileUri.getUriFromPath(result[0] + `/${fileName}.yaml`)
    console.debug(`待导出配置文件的 沙箱目录Uri: ${sandUri} 下载目录Uri: ${exportUri}`)
    try {
      // 导出至下载文件夹
      fs.copy(sandUri, exportUri).then(() => {
        console.info("Succeeded in copying.");
        Xb_ToastUtil.showToast({ message: Xb_GetResourceString($r('app.string.export_config_file_success'), this) + `: ${result[0] + `/${fileName}.yaml`}`})
      }).catch((err: BusinessError) => {
        console.error(`Failed to copy. Code: ${err.code}, message: ${err.message}`);
        Xb_ToastUtil.showToast({ message: `配置文件导出失败. Code: ${err.code}, message: ${err.message}`})
      })
    } catch (error) {
      console.error(`配置文件导出失败，name：${error.name} message：${error.message}`)
      Xb_ToastUtil.showToast({ message: `配置文件导出失败. Code: ${error.code}, message: ${error.message}`})
    }
  }

  /**删除配置*/
  private async deleteConfig(): Promise<void> {
    hilog.info(0xC016, componentName, `#deleteConfig#删除配置: configName is [${this.currentTouchConfigData.configName}]`)
    await ClashViewModel.deleteProfile(this.currentTouchConfigData.configId)
    this.appConfig.currentProxyName = undefined
    this.appConfig.currentProfileName = undefined
    this.favoriteProfiles.delete(this.currentTouchConfigData.configId)
    // 加载配置
    EventHub.sendEvent(EventKey.FetchProfile)
    Xb_ToastUtil.showToast({ message: `${getResourceString($r('app.string.configuration_deleted'), this)}💔` })
  }

  /**
   * @description 监听选中的配置项变化
   */
  async onChangeConfig() {
    // 选中项变更重新监听分享
    try {
      Xb_Share.immersiveDisablingListening('all')
    } catch (e) {
      hilog.error(0xC014, componentName, `选中项变更取消监听分享 - error: ${JSON.stringify(e)}`)
    }
    await this.openShare()
  }

}


export default ConfigurationPage
