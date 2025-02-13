import { BreakpointState, BreakpointSystem } from '../common/breakpointsystem'
import {
  TAB_CONTENT_TITLE_HEIGHT,
  BIND_SHEET_CONTAINER_HEIGHT,
  TAB_CONTENT_TITLE_FONT_SIZE,
  BORDER_RADIUS_20,
} from '../common/Constants'
import { hilog } from '@kit.PerformanceAnalysisKit'
import ProxyGroupItem from '../components/Proxy/ProxyGroupItem'
import ProxyArrangement from '../components/Proxy/ProxyArrangement'
import { ProxyItem } from '../common/ProxyData'
import ClashViewModel from '../entryability/ClashViewModel'
import { Profile, ProxyGroup, ProxySort, ProxyType } from 'proxy_core'
import { EventHub, EventKey } from '../common/EventHub'
import { AppConfig, ClashCore, isEnd, ProxyCardSize, ProxyGroupType, UIConfig } from '../entryability/AppState'
import { curves, PromptAction } from '@kit.ArkUI'
import { ProviderPage } from '../components/Proxy/Provider'
import { indexController } from './Index'
import { customVibrator } from '../utils/VibratorUtil'
import { customAnimationUtil } from '../utils/Animation'
import { Nothing } from '../components/Common'


@Entry
@Component
struct ProxyPage {
  //系统颜色调用
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean
  // 所有子组件在容器内的对齐方式
  @Consume('stackAlignContentAlignment') stackAlignContentAlignment: Alignment
  @State font_primary: ResourceColor = $r('sys.color.font_primary') //一级文本色，黑色
  @State font_secondary: ResourceColor = $r('sys.color.font_secondary') //二级文本色，深灰色
  @State container_background: ResourceColor = ($r('app.color.container_background')); //卡片颜色
  /* 配置列表List相关 */
  @State font_on_primary: ResourceColor = $r('sys.color.font_on_primary') //一级文本反色，白色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary') //二级图标色，深灰色
  /* Stack层叠布局 */
  //编辑按钮点击
  @State isShowEdit: boolean = false
  @Provide isProviderEdit: boolean = false
  //分组tabs相关
  @State currentIndex: number = 0;
  //假数据延迟颜色设置
  @State color: ResourceColor = $r('sys.color.font_secondary')
  // 定义ProxyArrangementSelected的值便于切换分组方式
  @State ProxyArrangementSelected: string = 'ProxyArrangementSelected1';
  @State ProxyArrangementChecked: boolean = true;
  // 定义ProxyGroupItemSelected的值便于切换布局方式
  @Provide ProxyGroupItemSelected: string = 'ProxyGroupItemSelectedWide'
  @State ProxyGroupItemChecked: boolean = true;
  ProxyGroupItemChecked1: boolean = false;
  @State currentRadioValue1: number = 0 // 分组方式切换
  @State currentRadioValue2: number = 0 // 排列方式切换
  @State currentRadioValue3: number = 0 // 卡片尺寸切换
  @State FristPage: boolean = true
  /*节点相关数据以及排序 */
  //节点假数据组后期可改可删
  @Consume items: ProxyItem[]
  @Consume
  proxyGroups: ProxyGroup[]

  hasGroups() {
    this.FristPage = this.proxyGroups.length == 0;
  }

  //收藏与ping延迟即时动作
  private ProxyPromptAction: PromptAction = this.getUIContext()?.getPromptAction()
  /* 断点布局相关 相关作用看定义时候的注释 */
  @Consume('breakPointStateListLanes')
  private breakPointStateListLanes: BreakpointState<number>
  @Consume('breakPointStateListGutter')
  private breakPointStateListGutter: BreakpointState<number>
  @Consume('breakPointStateTabContentTitleMargin')
  private breakPointStateTabContentTitleMargin: BreakpointState<number>
  private tabsController: TabsController = new TabsController()
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')
  private isLandscapePhone: boolean = false
  @StorageProp('istabletLandscape') istabletLandscape: boolean = false
  // 按钮宽度
  private proxyStartButtonWidth: Length = $r('app.integer.vp_proxy_not_start_button_width')
  // 按钮高度
  private proxyStartButtonHeight: Length = $r('app.integer.vp_proxy_not_start_button_height')
  // 按钮前Symbol动效
  private ReplaceSymbolEffect: SymbolEffect = EffectScope.WHOLE
  //定义组件名
  private componentName: string = 'ProxyPage'
  @Consume('currentProfile')
  private currentProfile: Profile | null
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('favoriteProxys') favoriteProxys: Map<string, string> = new Map<string, string>([])
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  /**主页卡片标题按钮间距*/
  @Consume('HomeCardTitleButtonPadding') private HomeCardTitleButtonPadding: BreakpointState<number>
  //page内顶部标题偏移量
  @Consume curYOffset: number
  //栅格点位配置
  aboutToAppear(): void {
    hilog.info(0xB000, this.componentName, `#aboutToAppear`)
    BreakpointSystem.getInstance().start()
    if (this.currentProfile) {
      let tabIndexes = this.proxyGroups.findIndex((d) => d.name == this.currentProfile?.currentGroupName)
      setTimeout(() => {
        if (tabIndexes > -1) {
          this.tabsController.changeIndex(tabIndexes)
          this.currentIndex = tabIndexes
        }
      }, 200)
    }
  }


  changeProxy(g: string, item: ProxyItem) {
    if (this.currentProfile) {
      ClashViewModel.changeProxy(this.currentProfile, g, item.name)
    }
  }

  //分组tabs内容
  @Builder
  TabBuilder(title: ResourceStr, targetIndex: number) {
    Column() {
      Column() {
        Text(title)
          .fontSize(14)
          .fontColor(this.currentIndex === targetIndex ? this.font_on_primary : this.font_secondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .borderRadius(21)
      .height(this.currentIndex === targetIndex ? 36 : 32)
      .width(this.currentIndex === targetIndex ? 96 : 87)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.currentIndex === targetIndex ? this.icon_emphasize : this.container_background)
    }
    .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
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
  //半模态编辑菜单Start
  ProxyBindSheetEdit() {
    Column() {
      //代理节点分组方式切换
      EditTitle({ title: $r('app.string.Packet_mode') })

      Column() {
        ForEach([{ t: $r('app.string.Tabs'), v: ProxyGroupType.Tabs },
          { t: $r('app.string.List'), v: ProxyGroupType.List }], (n: [Resource, number], i: number) => {
          Row() {
            Text(n["t"])
              .EditText()
            Radio({
              value: 'ProxyArrangementSelected1', group: 'ProxyArrangementSelectedRadioGroup',
              indicatorType: RadioIndicatorType.TICK,
            })
              .checked(this.appConfig.proxyGroupType == n["v"])
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  animateTo({ duration: this.uiConfig.animationSpeed }, () => {
                    this.appConfig.proxyGroupType = n["v"]
                  })
                }
              })
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
                //   uncheckedBorderColor: this.icon_secondary
              })
          }
          .EditRow()
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          // 点击后改变ProxyArrangementSelected状态为 标签
          .onClick(() => {
            animateTo({ duration: this.uiConfig.animationSpeed }, () => {
              this.appConfig.proxyGroupType = n["v"]
            })
          })

          if (!isEnd(2, i)) {
            Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })
          }
        })
      }
      .height(94)
      .EditColumn()

      //代理节点排列切换
      EditTitle({ title: $r('app.string.Arrangement') })
      Column() {
        ForEach([
          { t: $r('app.string.Default'), v: ProxySort.Default },
          { t: $r('app.string.Delay'), v: ProxySort.Delay },
          { t: $r('app.string.Name'), v: ProxySort.Title }
        ], (n: [Resource, number], i: number) => {
          Row() {
            Text(n["t"])
              .EditText()
            Radio({
              value: 'SortRadio1', group: 'SortRadioGroup',
              indicatorType: RadioIndicatorType.TICK
            })
              .checked(this.appConfig.proxySort == n["v"])
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  EventHub.sendEvent(EventKey.ProxySort, n["v"])
                  animateTo({ duration: this.uiConfig.animationSpeed }, () => {
                    this.appConfig.proxySort = n["v"]
                  })
                }
              })
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
              })
          }
          .EditRow()
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .onClick(() => {
            EventHub.sendEvent(EventKey.ProxySort, n["v"])
            animateTo({ duration: this.uiConfig.animationSpeed }, () => {
              this.appConfig.proxySort = n["v"]
            })
          })

          if (!isEnd(3, i))
            Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })
        })
      }
      .height(142)
      .EditColumn()

      //代理节点卡片尺寸切换
      EditTitle({ title: $r('app.string.Card_Size') })
      Column() {
        ForEach([
          { t: $r('app.string.Mini'), v: ProxyCardSize.Mini },
          { t: $r('app.string.Thin'), v: ProxyCardSize.Small },
          { t: $r('app.string.Wide'), v: ProxyCardSize.Large },
        ], (n: [Resource, number], i: number) => {
          Row() {
            Text(n["t"])
              .EditText()
            Radio({
              value: 'ProxyGroupItemSelectedRadio1', group: 'ProxyGroupItemSelectedRadioGroup',
              indicatorType: RadioIndicatorType.TICK
            })
              .checked(this.appConfig.proxyCardSize == n["v"])
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  animateTo({ duration: this.uiConfig.animationSpeed }, () => {
                    this.currentRadioValue3 = 0
                    this.appConfig.proxyCardSize = n["v"]
                  })
                }
              })
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
                //   uncheckedBorderColor: this.icon_secondary
              })
          }
          .EditRow()
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          // 点击后改变ProxyGroupItemSelected状态为 多列
          .onClick(() => {
            animateTo({ duration: this.uiConfig.animationSpeed }, () => {
              this.appConfig.proxyCardSize = n["v"]
            })
          })

          if (!isEnd(3, i)) {
            Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })
          }
        })
      }
      .height(142)
      .EditColumn()

    }
    .padding({
      left: this.breakPointStateTabContentTitleMargin.value,
      right: this.breakPointStateTabContentTitleMargin.value,
    })
    .width('100%')
  } //半模态编辑菜单end

  @Builder
  ProviderBindSheetEdit() {
    ProviderPage()
      .padding({
        left: this.breakPointStateTabContentTitleMargin.value,
        right: this.breakPointStateTabContentTitleMargin.value,
      })
      .width('100%')
  }


  build() {
    Stack(){
      // 标题栏
     // if (!this.isLandscapePhone || this.appConfig.proxyGroupType === ProxyGroupType.List) {
        Row({ space: this.HomeCardTitleButtonPadding.value }) {
          Text($r('app.string.Proxy'))
            .fontSize(this.curYOffset<0?TAB_CONTENT_TITLE_FONT_SIZE-this.curYOffset/100:TAB_CONTENT_TITLE_FONT_SIZE)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .transition(customAnimationUtil.isSlide(200, this.uiConfig))
            .transition(customAnimationUtil.isScaleTran(0, this.uiConfig))
              //提供者半模拟态
            .bindSheet($$this.isProviderEdit, this.ProviderBindSheetEdit(), {
              detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.LARGE,],
              backgroundColor: $r('app.color.background'),
              showClose: false,
              dragBar: false,
              scrollSizeMode: ScrollSizeMode.CONTINUOUS,
              preferType: SheetType.CENTER,
              onWillDismiss: () => {
                this.isProviderEdit = false
                this.isEnableIndexForegroundBlur = false
              }
            })
          Blank()

          //提供者按钮
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            SymbolGlyph($r('sys.symbol.puzzle'))
              .fontSize(24)//      .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)//分层颜色
              .fontColor([this.icon_primary])
          }
          .width(40)
          .height(40)
          .backgroundColor($r('app.color.settings_container_background'))
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .onClick(() => {
            this.isProviderEdit = true
            this.isEnableIndexForegroundBlur = true
          })
          .transition(customAnimationUtil.isSlide(100, this.uiConfig))
          //代理样式编辑半模拟态
          .bindSheet($$this.isShowEdit, this.ProxyBindSheetEdit(), {
            detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.LARGE,],
            backgroundColor: $r('app.color.background'),
            showClose: true,
            dragBar: false,
            scrollSizeMode: ScrollSizeMode.CONTINUOUS,
            title: { title: $r('app.string.Edit') },
            preferType: SheetType.CENTER,
            onWillDismiss: () => {
              this.isShowEdit = false
              this.isEnableIndexForegroundBlur = false
            }
          })

          //编辑图标
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            SymbolGlyph($r('sys.symbol.square_and_pencil'))
              .fontSize(24)//      .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)//分层颜色
              .fontColor([this.icon_primary])
          }
          .width(40)
          .height(40)
          .backgroundColor($r('app.color.settings_container_background'))
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .onClick(() => {
            this.isShowEdit = true
            this.isEnableIndexForegroundBlur = true
            hilog.info(0xB001, this.componentName, `#button#onClick()#编辑代理`)
          })
        }
        .zIndex(1)
        .height(this.curYOffset<0?TAB_CONTENT_TITLE_HEIGHT-this.curYOffset:TAB_CONTENT_TITLE_HEIGHT)
        .position({x:0})
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .padding({
          left: this.breakPointStateTabContentTitleMargin.value,
          right: this.breakPointStateTabContentTitleMargin.value,
        })
        .transition(customAnimationUtil.isSlide(0, this.uiConfig))
    //  }

      if (this.proxyGroups.length == 0) {
        Column() {
          Nothing({ name: $r('app.string.None_Proxy') })
        }

      } else if (this.proxyGroups.length > 0) {
        // 代理页分组TAB+list主体
        Stack({ alignContent: this.stackAlignContentAlignment }) {
                    Column(){
            Blank().height(TAB_CONTENT_TITLE_HEIGHT)
            Scroll() {
          //根据ProxyArrangementSelected的状态决定是否显示
          if (this.appConfig.proxyGroupType === ProxyGroupType.Tabs) {
            Column() { //分组标签页 start
              Tabs({ barPosition: BarPosition.Start, controller: this.tabsController, index: this.currentIndex }) {
                ForEach(this.proxyGroups, (g: ProxyGroup, i: number) => {
                  TabContent() {
                    //    if ( this.currentIndex === i) {//为实现listltem转场动画的的if
                    ProxyGroupItem({
                      items: g.proxies as ProxyItem[],
                      ProxyGroupItemSelected: this.appConfig.proxyCardSize,
                      disabled: g.type !== ProxyType.Selector,
                      selectedProxy: this.currentProfile?.getSelectedProxy(g) ?? "",
                      OnProxyChange: (item) => {
                        console.log("xxxxx", item)
                        this.changeProxy(g.name, item)
                      }
                    })//list相关在components/ProxyGroupItem.ets文件里
                      .padding({ right: this.breakPointStateTabContentTitleMargin.value, })
                      .width('100%')
                      .height('100%')

                  }
                  .tabBar(this.TabBuilder(g.name, i))
                  .gesture(
                    // 二级Tabs第一个页签向左拖动时，触发手势事件
                    PanGesture({direction: this.currentIndex === 0 ? PanDirection.Right: this.currentIndex === this.proxyGroups.length - 1 ? PanDirection.Left:PanDirection.None})
                      .onActionStart((event?: GestureEvent) => {
                        console.info('Pan start')
                      })// 通过父组件的TabsController的实例，改变其index，达到跳转一级Tabs（首页）的效果
                      .onActionEnd(() => {
                        if (!this.isLandscapePhone) {
                          if (this.currentIndex === 0) {
                            indexController.changeIndex(0)
                            console.info('Pan end')
                          } else if (this.currentIndex === this.proxyGroups.length - 1) {
                            indexController.changeIndex(2)
                          }
                        }else if (this.istabletLandscape){}
                      })
                  )
                  .onWillShow(() => {
                    animateTo(this.uiConfig.isAnimation?{ duration: this.uiConfig.animationSpeed, curve: curves.springMotion() }:null, () => {
                      this.currentIndex = i;
                      if(this.currentProfile){
                        this.currentProfile.currentGroupName = this.proxyGroups[i].name
                        ClashViewModel.updateProfile(this.currentProfile)
                      }
                    })
                  })
                })
              }
              .barMode(BarMode.Scrollable)
              .barHeight(55)
              .fadingEdge(false)
              .onAnimationStart((index: number, targetIndex: number) => {
                if (this.uiConfig.animationSpeed===0) {
                  this.currentIndex = targetIndex;
                }
              })
            }
            .padding({
              left: this.breakPointStateTabContentTitleMargin.value,
            })
            .width('100%')
            .foregroundBlurStyle(
              this.isEnableIndexForegroundBlur ? BlurStyle.Thin : BlurStyle.NONE,
              { colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 0.3 }
            )
            //分组tabs end
          }

          // 列表排列
          else if (this.appConfig.proxyGroupType === ProxyGroupType.List) {
            ProxyArrangement()
          }
          //列表排列end
            }
            .edgeEffect(this.uiConfig.isAnimation?EdgeEffect.Spring:null)
            .onDidScroll((xOffset: number, yOffset: number, scrollState: ScrollState): void => {
              // 累计计算当前父组件滚动在Y轴方向的偏移量
              if (this.uiConfig.isAnimation){
                this.curYOffset += yOffset
              }
              console.info("yOffset" + this.curYOffset);
            })
   }

          // ClashMeta内核时暂时无法测延迟
          if (this.appConfig.clashCore === ClashCore.FlClash) {
            // 悬浮代理测速按钮 START
            Column() {
              Stack({ alignContent: Alignment.Center }) {
                SymbolGlyph($r('sys.symbol.bolt_filled_on_circle'))
                  .fontSize(24)
                  .fontColor([Color.White])
                  .symbolEffect(this.ReplaceSymbolEffect)
                  .align(Alignment.Center)
              }.onClick(() => {
                EventHub.sendEvent(EventKey.TestDelayAll)
                if (this.uiConfig.isVibrate) {
                  customVibrator.vibratorTriggerOfHapticClockTimer()
                }
                this.ProxyPromptAction.showToast({ message: $r('app.string.Test_Delay_Tip') })
              })
              .width('100%')
              .height('100%')
            }
            .shadow({
              radius: 10,
              color: this.icon_emphasize,
              offsetY: 4,
              type: ShadowType.BLUR
            })
            .borderRadius(100)
            .backgroundColor(this.icon_emphasize)
            .margin({bottom:this.isLandscapePhone ? $r('app.integer.vp_proxy_start_button_left_right_margin') : $r('app.integer.vp_proxy_start_button_bottom_margin'),right:$r('app.integer.vp_proxy_start_button_left_right_margin'),left:$r('app.integer.vp_proxy_start_button_left_right_margin')})
            .width(this.proxyStartButtonWidth)
            .height(this.proxyStartButtonHeight)
            .clip(true)
            .animation({ duration: this.uiConfig.animationSpeed, curve: Curve.Ease })
            .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
            .transition(customAnimationUtil.isSlideSwitch(this.uiConfig))
            // 悬浮代理测速按钮 END
          }

        }
        .backgroundColor($r('app.color.background'))
        // .padding(this.isLandscapePhone ? '0vp' : { bottom: '45vp' })
        .width('100%')
        .height( '100%' )
        // 主体 END
      }
    }
    .width('100%')
    .height('100%')
    }
}

export default ProxyPage


// 半模态编辑页Column公共样式（含非通用公共属性采用Extend继承的方式抽取）
@Extend(Column)
function EditColumn() {
  .padding({ left: 12, right: 12 })
  .width('100%')
  .margin({ bottom: 10 })
  .borderRadius(20)
  .backgroundColor($r('app.color.container_background'))
  .justifyContent(FlexAlign.SpaceEvenly) // 非通用公共属性
}

// 半模态编辑页Row公共样式（含非通用公共属性采用Extend继承的方式抽取）
@Extend(Row)
function EditRow() {
  .width('100%')
  .justifyContent(FlexAlign.SpaceBetween) // 非通用公共属性
}

// 半模态编辑页Text共同属性（Text独有属性采用Extend继承的方式抽取）
@Extend(Text)
function EditText() {
  .font({ size: 16 })
  .fontColor($r('sys.color.font_primary')) // 一级文本色，黑色
}

// 半模态编辑页标题
@Component
struct EditTitle {
  @State title: ResourceStr = $r('app.string.Packet_mode')

  build() {
    Text(this.title)
      .width('100%')
      .fontSize(16)
      .fontColor($r('sys.color.font_secondary'))
      .textAlign(0)
      .margin({ bottom: 10 })
  }
}