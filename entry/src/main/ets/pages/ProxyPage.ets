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
  LIST_ITEM_HEIGHT,
  LIST_SPACE,
  BORDER_RADIUS_20,
  BIND_SHEET_CONTAINER_HEIGHT,
} from '../common/Constants'
import { hilog } from '@kit.PerformanceAnalysisKit'
import ProxyGroupItem from '../components/Proxy/ProxyGroupItem'
import ProxyArrangement from '../components/Proxy/ProxyArrangement'


// todo 定义一个接口来描述列表项的数据结构,假数据，后期可改可删
interface Item {
  latency: number;
} //


//import { ThemeControl } from '@ohos.arkui.theme'
//import { gAppTheme } from './AppTheme'

// 在页面build前执行ThemeControl，就可以改变主题颜色
//ThemeControl.setDefaultTheme(gAppTheme)

@Entry
@Component
struct ProxyPage {
  /* 预留自定义主题，颜色在AppTheme里面修改
 onWillApplyTheme(theme: Theme) {
    this.backgroundPrimary = theme.colors.backgroundPrimary;
    this.fontPrimary = theme.colors.fontPrimary;
    this.iconOnPrimary = theme.colors.iconOnPrimary;
    this.iconFourth = theme.colors.iconFourth;
 } */
  //tabs图标文字颜色，修改resources/base(dark)/element/color.json中tabs_icon_text配置选中图标文字深浅模式颜色
  //系统颜色调用
  @State icon_emphasize: ResourceColor = $r('sys.color.icon_emphasize') //高亮图标，蓝色
  @State font_primary: ResourceColor = $r('sys.color.font_primary') //一级文本色，黑色
  @State font_secondary: ResourceColor = $r('sys.color.font_secondary') //二级文本色，深灰色
  @State container_background: ResourceColor = ($r('app.color.container_background')); //卡片颜色
  /* 配置列表List相关 */
  @State font_on_primary: ResourceColor = $r('sys.color.font_on_primary') //一级文本反色，白色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  /* ContextMenu */
  @State background_secondary: ResourceColor = $r('sys.color.background_secondary') //二级背景色，实色
  /* Stack层叠布局 */
  // 所有子组件在容器内的对齐方式 TODO 【用户首选项】在设置里可以更改 Alignment.BottomStart 和 Alignment.BottomEnd Enlin@2024-12-04
  @State
  stackAlignContentAlignment: Alignment = Alignment.BottomEnd
  //编辑按钮点击
  @State isShowEdit: boolean = false
  //分组tabs相关
  @State currentIndex: number = 0;
  //todo 假数据 以后可以删掉
  @State items: Item[] = [
    { latency: 20 },
    { latency: 500 },
    { latency: 1001 },
  ];
  //假数据延迟颜色设置
  @State color: ResourceColor = $r('sys.color.font_secondary')
  // 定义ProxyArrangementSelected的值便于切换分组方式
  @State ProxyArrangementSelected: string = 'ProxyArrangementSelected1';
  @State ProxyArrangementChecked: boolean = true;
  // 定义ProxyGroupItemSelected的值便于切换布局方式
  @Provide ProxyGroupItemSelected: string = 'ProxyGroupItemSelected1'
  @State ProxyGroupItemChecked: boolean = true;
  /* 断点布局相关 相关作用看定义时候的注释 */
  @Consume('breakPointStateListLanes')
  private breakPointStateListLanes: BreakpointState<number>
  @Consume('breakPointStateListGutter')
  private breakPointStateListGutter: BreakpointState<number>
  //半模拟态 end
  @Consume('breakPointStateTabContentTitleMargin')
  private breakPointStateTabContentTitleMargin: BreakpointState<number>
  private tabsController: TabsController = new TabsController()
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
  //定义组件名
  private componentName: string = 'ProxyPage'

  // 排序函数
  sortItems() {
    this.items.sort((a, b) => a.latency - b.latency);
  }

  //栅格点位配置
  aboutToAppear(): void {
    hilog.info(0xB000, this.componentName, `#aboutToAppear`)
    //   BreakpointSystem.getInstance().attach(this.breakPointStateListLanes)
    //   BreakpointSystem.getInstance().attach(this.breakPointStateListGutter)
    //   BreakpointSystem.getInstance().attach(this.breakPointStateTabContentTitleMargin)
    BreakpointSystem.getInstance().start()
  }

  //分组tabs内容
  @Builder
  TabBuilder(title: ResourceStr, targetIndex: number) {
    Column() {
      Column() {
        Text(title)
          .fontSize(14)
          .fontColor(this.currentIndex === targetIndex ? this.font_on_primary : this.font_secondary)
      }
      .borderRadius(21)
      .height(this.currentIndex === targetIndex ? 36 : 32)
      .width(this.currentIndex === targetIndex ? 96 : 87)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.currentIndex === targetIndex ? this.icon_emphasize : this.container_background)
    } //
    .height(55)
    .margin({ right: 8, bottom: 10 })
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(this.currentIndex);
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  //半模态编辑菜单
  ProxyBindSheetEdit() {
    Column() {
      Text($r('app.string.Packet_mode'))
        .width('100%')
        .fontSize(16)
        .fontColor(this.font_secondary)
        .padding({ left: 15, bottom: 10 })
        .textAlign(0)

      Column() {
        Row() {
          Text($r('app.string.Tabs'))
            .font({ size: 16 })
            .fontColor(this.font_primary)

          Radio({
            value: 'Radio1', group: 'radioGroup1',
            indicatorType: RadioIndicatorType.TICK,
          })
            .checked(this.ProxyArrangementChecked)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.ProxyArrangementSelected = 'ProxyArrangementSelected1'
              }
            })
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        // 点击时改变ProxyArrangementSelected状态
        .onClick(() => {
          this.ProxyArrangementSelected = 'ProxyArrangementSelected1';
          this.ProxyArrangementChecked = true
          hilog.info(0xB003, this.componentName, `#ProxyBindSheetEditRadio#onClick: `)
        })
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)


        Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })

        Row() {
          Text($r('app.string.List'))
            .font({ size: 16 })
            .fontColor(this.font_primary)

          Radio({
            value: 'Radio2', group: 'radioGroup1',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(!this.ProxyArrangementChecked)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.ProxyArrangementSelected = 'ProxyArrangementSelected2'
              }
            })
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        .onClick(() => {
          this.ProxyArrangementSelected = 'ProxyArrangementSelected2';
          this.ProxyArrangementChecked = false
          hilog.info(0xB003, this.componentName, `#ProxyBindSheetEditRadio#onClick: `)
        })
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .padding({ left: 15, right: 10 })
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: 10 })
      .width('100%')
      .height(94)
      .borderRadius(20)
      .backgroundColor(($r('app.color.container_background')))

      Text($r('app.string.Arrangement'))
        .width('100%')
        .fontSize(16)
        .fontColor(this.font_secondary)
        .padding({ left: 15, bottom: 10 })
        .textAlign(0)

      Column() {
        Row() {
          Text($r('app.string.Default'))
            .font({ size: 16 })
            .fontColor(this.font_primary)

          Radio({
            value: 'Radio3', group: 'radioGroup2',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(true)
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        //   .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })

        Row() {
          Text($r('app.string.Delay'))
            .font({ size: 16 })
            .fontColor(this.font_primary)

          Radio({
            value: 'Radio4', group: 'radioGroup2',
            indicatorType: RadioIndicatorType.TICK
          })
            .onClick(() => this.sortItems())//按延迟排序
            .checked(false)
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        //  .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })


        Row() {
          Text($r('app.string.Name'))
            .font({ size: 16 })
            .fontColor(this.font_primary)

          Radio({
            value: 'Radio5', group: 'radioGroup2',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(false)
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        //  .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .padding({ left: 15, right: 10 })
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: 10 })
      .width('100%')
      .height(142)
      .borderRadius(20)
      .backgroundColor(($r('app.color.container_background')))


      Text($r('app.string.Layout'))
        .width('100%')
        .fontSize(16)
        .fontColor(this.font_secondary)
        .padding({ left: 15, bottom: 10 })
        .textAlign(0)

      Column() {
        Row() {
          Text($r('app.string.Relax'))
            .font({ size: 16 })
            .fontColor(this.font_primary)

          Radio({
            value: 'Radio6', group: 'radioGroup3',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(!this.ProxyGroupItemChecked)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.ProxyGroupItemSelected = 'ProxyGroupItemSelected2'
              }
            })
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        // 点击时改变ProxyGroupItemSelected状态
        .onClick(() => {
          this.ProxyGroupItemSelected = 'ProxyGroupItemSelected2';
          this.ProxyGroupItemChecked = false
          hilog.info(0xB003, this.componentName, `#ProxyBindSheetEditRadio#onClick: `)
        })
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })

        Row() {
          Text($r('app.string.Compact'))
            .font({ size: 16 })
            .fontColor(this.font_primary)

          Radio({
            value: 'Radio7', group: 'radioGroup3',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(this.ProxyGroupItemChecked)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.ProxyGroupItemSelected = 'ProxyGroupItemSelected1'
              }
            })
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })

        }
        // 点击时改变ProxyGroupItemSelected状态
        .onClick(() => {
          this.ProxyGroupItemSelected = 'ProxyGroupItemSelected1';
          this.ProxyGroupItemChecked = true
          hilog.info(0xB003, this.componentName, `#ProxyBindSheetEditRadio#onClick: `)
        })
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .padding({ left: 15, right: 10 })
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: 10 })
      .height(94)
      .borderRadius(20)
      .backgroundColor(($r('app.color.container_background')))
    }
    .padding({ left: 16, right: 16 })
    .width('100%')
  } //半模拟态编辑菜单end

  build() {
    Column() {
      // 标题栏
          if (!this.isLandscapePhone) {
            Row() {
              Text($r('app.string.Proxy'))
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center)

              Blank()
              //编辑图标
              Button({ type: ButtonType.Circle, stateEffect: true }) {
                SymbolGlyph($r('sys.symbol.square_and_pencil'))
                  .fontSize(24)//      .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)//分层颜色
                  .fontColor([this.icon_primary])
              }
              .width(40)
              .height(40)
              .backgroundColor($r('app.color.settings_container_background'))
              .clickEffect({ level: ClickEffectLevel.MIDDLE })
              .onClick(() => {
                this.isShowEdit = true
                hilog.info(0xB001, this.componentName, `#button#onClick()#编辑代理`)
              })
              .bindSheet($$this.isShowEdit, this.ProxyBindSheetEdit(), {
                detents: [684, SheetSize.FIT_CONTENT],
                backgroundColor: $r('app.color.background'),
                //  blurStyle: BlurStyle.BACKGROUND_REGULAR,
                showClose: true,
                scrollSizeMode: ScrollSizeMode.CONTINUOUS,
                title: { title: $r('app.string.Edit') },
                //   width: ('100%'),
                preferType: SheetType.CENTER,
                maskColor: $r('app.color.dialog_maskcolor')
              })
            }
            .alignItems(VerticalAlign.Center)
            .width('100%')
            .height(TAB_CONTENT_TITLE_HEIGHT)
            .padding({
              left: this.breakPointStateTabContentTitleMargin.value,
              right: this.breakPointStateTabContentTitleMargin.value,
            })
          }
      //    }


      // 代理页分组TAB+list主体
      Stack({ alignContent: this.stackAlignContentAlignment }) {
        // A组件，根据isProxyLayoutShown的状态决定是否显示
        if (this.ProxyArrangementSelected === 'ProxyArrangementSelected1') {
          Column() { //分组标签页 start
            Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
              TabContent() {
                List() {
                  ProxyGroupItem() //list相关在components/ProxyGroupItem.ets文件里
                }
                .width('100%')
                .height('100%')
                .contentEndOffset(110)
                //      .lanes(this.breakPointStateListLanes.value, this.breakPointStateListGutter.value)
                .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
                .chainAnimation(true)
                .padding({
                  left: this.breakPointStateTabContentTitleMargin.value,
                  right: this.breakPointStateTabContentTitleMargin.value,
                })
              }
              // 节点列表 END

              //TODO 删除 临时模拟分组数据
              .tabBar(this.TabBuilder('分组1', 0))

              TabContent() {
              }
              .tabBar(this.TabBuilder('分组2', 1))

              TabContent() {
              }
              .tabBar(this.TabBuilder('分组3', 2))

              TabContent() {
              }
              .tabBar(this.TabBuilder('分组4', 3))

              TabContent() {
              }
              .tabBar(this.TabBuilder('分组5', 4))

              TabContent() {
              }
              .tabBar(this.TabBuilder('分组6', 5))

              TabContent() {
              }
              .tabBar(this.TabBuilder('分组7', 6))

              TabContent() {
              }
              .tabBar(this.TabBuilder('分组8', 7))
            }
            .barMode(BarMode.Scrollable)
            .barHeight(55)
            .fadingEdge(true)
            .onChange((index: number) => {
              this.currentIndex = index;
            })
          }

          //分组tabs end
        }

        // 列表排列
        else if (this.ProxyArrangementSelected === 'ProxyArrangementSelected2') {
          ProxyArrangement()
        }
        //列表排列end

        // 悬浮新增配置按钮 START
        Button() {
          Stack({ alignContent: Alignment.Center }) {
            SymbolGlyph($r('sys.symbol.bolt_filled_on_circle'))
              .fontSize(24)
              .fontColor([Color.White])
              .symbolEffect(this.ReplaceSymbolEffect)
              .align(Alignment.Center)
          }.width('100%')
        }
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

        // 悬浮新增配置按钮 END
      }
      .backgroundColor($r('app.color.background'))
      // .padding(this.isLandscapePhone ? '0vp' : { bottom: '45vp' })
      .width('100%')
      .height(this.isLandscapePhone ? '100%' : `calc(100% - ${TAB_CONTENT_TITLE_HEIGHT}vp)`)

      // 主体 END
    }
    .width('100%')
    .height('100%')
  }
}


export default ProxyPage