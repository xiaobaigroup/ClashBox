import { ThemeControl } from '@ohos.arkui.theme'
import { gAppTheme } from '../common/AppTheme'
import { BreakpointState, BreakpointSystem } from '../common/breakpointsystem'
import {
  TAB_CONTENT_TITLE_FONT_SIZE,
  TAB_CONTENT_TITLE_FONT_WEIGHT,
  BPS_LIST_LANES_1_1_2_3_4,
  BPS_LIST_GUTTER_1_1_2_3_3,
  BPS_TAB_CONTENT_TITLE_MARGIN_12_13_28_36,
  ANIMATION_DURATION_300,
  TAB_CONTENT_TITLE_HEIGHT,
  TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE,
} from '../common/Constants'
import { LengthMetrics, promptAction, SymbolGlyphModifier } from '@kit.ArkUI'
import ConfigAdd from '../components/Configuration/ConfigAdd'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Callback } from '@ohos.base'

// 在页面build前执行ThemeControl，就可以改变主题颜色
//ThemeControl.setDefaultTheme(gAppTheme)

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

  /* Stack层叠布局 */
  // 所有子组件在容器内的对齐方式 TODO 【用户首选项】在设置里可以更改 Alignment.BottomStart 和 Alignment.BottomEnd Enlin@2024-12-04
  @State
  stackAlignContentAlignment: Alignment = Alignment.BottomEnd
  // 是否显示添加配置的的bindSheet
  @State
  private bindSheetIsShowOfConfigAddButton: boolean = false

  @Builder
  private ConfigAddBindSheetBuilder(){
    ConfigAdd({breakPointStateTabContentTitleMargin: this.breakPointStateTabContentTitleMargin})
  }

  /* 断点布局相关 */
  @State
  private breakPointStateListLanes: BreakpointState<number> = BPS_LIST_LANES_1_1_2_3_4
  @State
  private breakPointStateListGutter: BreakpointState<number> = BPS_LIST_GUTTER_1_1_2_3_3
  @State
  private breakPointStateTabContentTitleMargin: BreakpointState<number> = BPS_TAB_CONTENT_TITLE_MARGIN_12_13_28_36

  /* 配置列表List相关 */
  // 当前单选框选择的配置
  @State
  private proxyRadioCheckedValue: number = -1
  // 当前手指触摸的ListItem的对应 this.configList[index]
  @State
  private currentTouchConfigListIndex: number = -1

  /* ContextMenu */
  // TODO 删除 临时模拟数据配置列表数据
  private configList:Array<string> = [
    '配置1',
    '配置2',
    '配置3',
    '配置4',
    '配置5',
    '配置6',
    '配置7',
    '配置8',
    '配置9',
    '配置10',
    '配置11',
    '配置12',
    '配置13',
    '配置14']

  // 配置页面ListItem的长按ContextMenu列表项集合
  @State
  private configListLongPressCtxMenus: Array<LongPressContextMenuItem> = [
    { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.star')).fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE), content: '收藏', callback: ()=>{this.favoriteConfig()} },
    { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.square_and_pencil')).fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE), content: '编辑', callback: ()=>{this.editConfig()} },
    { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.arrow_clockwise')).fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE), content: '更新', callback: ()=>{this.updateConfig()} },
    { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.share')).fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE), content: '分享', callback: ()=>{this.shareConfig()} },
    { symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.qrcode')).fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE), content: '生成二维码', callback: ()=>{this.generateQRcode()} },
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
            .onClick( () => {
              // hilog.info(0xC002, this.componentName, `#configListLongPressCtxMenuBuilder#onClick():`)
              item.callback()
            })
        })
        // 文字红色 单独处理
        MenuItem({ symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.trash_fill'))
          .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
          .fontColor(['#E6E54E36']), content: '删除' })
          .contentFontColor('#E6E54E36')
          .onClick( () => {
            this.deleteConfig()
          })
      }
      .backgroundColor($r('app.color.container_background'))
      .borderRadius(20)
      .menuItemDivider({ strokeWidth: LengthMetrics.vp(.4), color: $r('sys.color.comp_divider') })
      .width(200)
      .height('auto')
    }
    .nestedScroll({scrollForward: NestedScrollMode.SELF_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST})
    .edgeEffect(EdgeEffect.Spring)
  }

  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')
  private isLandscapePhone: boolean = false

  // 按钮宽度
  private proxyStartButtonWidth: Length = $r('app.integer.vp_proxy_not_start_button_width')
  // 按钮高度
  private proxyStartButtonHeight: Length = $r('app.integer.vp_proxy_not_start_button_height')
  // 按钮Margin
  private proxyStartButtonMargin: Length = $r('app.integer.vp_proxy_start_button_margin')
  // 按钮前Symbol动效
  private ReplaceSymbolEffect: SymbolEffect = EffectScope.WHOLE

  build() {
    Column() {
      // 标题栏 START
      if (!this.isLandscapePhone) {
        Row() {
          Text($r('app.string.Configuration'))
            .fontSize(TAB_CONTENT_TITLE_FONT_SIZE)
            .fontWeight(TAB_CONTENT_TITLE_FONT_WEIGHT)
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
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
          .onClick(() => {
            // TODO 国际化适配 更新配置中... 更新配置成功
            // TODO 调用 更新配置api
            promptAction.showToast({ message: `配置更新中...` })
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
        List({ space: 10 }) {
          ForEach(this.configList, (item: string, index: number) => {
            ListItem() {
              Row() {
                Column() {
                  Text(item).fontColor(($r('sys.color.font_primary')))
                  Text(`index:${index}`).fontColor($r('sys.color.font_secondary'))
                }.alignItems(HorizontalAlign.Start)
                Blank()
                Radio({ value: 'radio' + index, group: 'proxyConfigurationGroup' })
                  .checked(index === this.proxyRadioCheckedValue)
              }
              .width('100%')
              .padding({ left: 12, right: 12 })
              .alignItems(VerticalAlign.Center)
            }
            .backgroundColor($r('app.color.container_background'))
            .width('100%')
            .height(56)
            .clickEffect({ level: ClickEffectLevel.MIDDLE })
            .borderRadius(20)
            .bindContextMenu(this.configListLongPressCtxMenuBuilder, ResponseType.LongPress | ResponseType.RightClick,
              {
                preview: MenuPreviewMode.IMAGE,
                previewAnimationOptions: { scale: [1.0, 1.1] },
                placement: Placement.BottomRight
              })
            .onClick(() => {
              this.proxyRadioCheckedValue = index
              hilog.info(0xC002, this.componentName, `#ListItem#onClick: `)
            })
            .onTouch((event: TouchEvent) => {
              if (event.type === TouchType.Down) {
                // TODO 现在用来代替获取长按的是哪一个ListItem，这个index也就是 `this.configList` 的index
                this.currentTouchConfigListIndex = index
                hilog.info(0xC002, this.componentName, `#ListItem#onTouch(TouchType.Down): configList[index] is: ${this.currentTouchConfigListIndex},configList[name] is: ${item}`)
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
        .contentEndOffset(110)
        .lanes(this.breakPointStateListLanes.value, this.breakPointStateListGutter.value)
        .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
        .chainAnimation(true)
        // 配置列表 END

        // 悬浮新增配置按钮 START
        Button() {
          Row() {
            Stack({ alignContent: Alignment.Center }) {
              SymbolGlyph($r('sys.symbol.plus'))
                .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
                .fontColor([Color.White])
                .symbolEffect(this.ReplaceSymbolEffect)
                .align(Alignment.Center)
            }
            .width(this.proxyStartButtonHeight)
            .height(this.proxyStartButtonHeight)
          }.width('100%')
        }
        // .backgroundColor($r('app.color.speed_down_icon'))
        .shadow({
          radius: 10,
          color: $r('app.color.speed_down_icon'),
          offsetY: 4,
          type: ShadowType.BLUR
        })
        .margin(this.proxyStartButtonMargin)
        .width(this.proxyStartButtonWidth)
        .height(this.proxyStartButtonHeight)
        .clip(true)
        .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Ease })
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .bindSheet( $$this.bindSheetIsShowOfConfigAddButton, this.ConfigAddBindSheetBuilder, {
          title: { title: $r('app.string.AddConfig') },
          detents: [684, SheetSize.FIT_CONTENT],
          backgroundColor: $r('app.color.background'),
          showClose: true,
          dragBar: true,
          blurStyle: BlurStyle.Thick,
          scrollSizeMode: ScrollSizeMode.CONTINUOUS,
          width: ('100%')
        })
        .onClick( () => {
          this.bindSheetIsShowOfConfigAddButton = !this.bindSheetIsShowOfConfigAddButton
        })
        // 悬浮新增配置按钮 END
      }
      .backgroundColor($r('app.color.dialog_maskcolor'))
      // .padding(this.isLandscapePhone ? '0vp' : { bottom: '45vp' })
      .width('100%')
      .height(this.isLandscapePhone ? '100%' :`calc(100% - ${TAB_CONTENT_TITLE_HEIGHT}vp)`)
      // 主体 END
    }
    .width('100%')
    .height('100%')
  }

  aboutToAppear(): void {
    hilog.info(0xC000, this.componentName, `#aboutToAppear`)
    BreakpointSystem.getInstance().attach(this.breakPointStateListLanes)
    BreakpointSystem.getInstance().attach(this.breakPointStateListGutter)
    BreakpointSystem.getInstance().attach(this.breakPointStateTabContentTitleMargin)
    BreakpointSystem.getInstance().start()
  }

  // aboutToDisappear(): void {
  //   hilog.info(0xC000, this.componentName, `#aboutToDisappear`)
  // }

  /**
   * 收藏配置
   */
  favoriteConfig(): void {
    // TODO 收藏配置
    // this.currentTouchConfigListIndex
    promptAction.showToast({message: `已收藏⭐`})
    hilog.info(0xC010, this.componentName, `#favoriteConfig#收藏配置：${this.currentTouchConfigListIndex}`)
  }
  /**
   * 编辑配置
   */
  private editConfig(): void {
    // TODO 编辑bindSheet
    // this.currentTouchConfigListIndex
    hilog.info(0xC011, this.componentName, `#editConfig#编辑配置：${this.currentTouchConfigListIndex}`)
  }
  /**
   * 更新配置
   */
  private updateConfig(): void {
    // TODO 调用更新配置消息api
    // this.currentTouchConfigListIndex
    promptAction.showToast({message: `配置更新中...`})
    hilog.info(0xC012, this.componentName, `#updateConfig#更新配置：${this.currentTouchConfigListIndex}`)
  }
  /**
   * 分享配置
   */
  shareConfig(): void {
    // TODO 处理待分享数据 并调用系统分享接口
    // this.currentTouchConfigListIndex
    hilog.info(0xC013, this.componentName, `#shareConfig#分享配置：${this.currentTouchConfigListIndex}`)
  }
  /**
   * 生成配置二维码
   */
  generateQRcode(): void {
    // TODO 弹出bindSheet 在其中实现“配置url”生成二维码的功能
    // this.currentTouchConfigListIndex
    hilog.info(0xC014, this.componentName, `#generateQRcode#生成二维码：${this.currentTouchConfigListIndex}`)
  }
  /**
   * 删除配置
   */
  deleteConfig(): void {
    // TODO 删除用户首选项里的此配置
    // TODO 弹confirm框确认是否删除？
    // this.currentTouchConfigListIndex
    hilog.info(0xC014, this.componentName, `#deleteConfig#删除配置：${this.currentTouchConfigListIndex}`)
  }

}
export default ConfigurationPage