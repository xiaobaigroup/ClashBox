import { CardTitle } from "../components/Home/CardTitleBuilder"
import ProxyINFO from "../components/Home/ProxyINFO"
import SwitchMode from "../components/Home/SwitchMode"
import { AppConfig, UIConfig } from "../entryability/AppState"
import ClashViewModel from "../entryability/ClashViewModel"
import { customAnimationUtil } from "../utils/Animation"
import { curves, PromptAction } from "@kit.ArkUI"
import { customVibrator } from "../utils/VibratorUtil"
import { ConfigData } from "../common/PageArgumentEntity"
import { Timer } from "../common/HHmmssTimer"
import {  ProxyGroup } from "proxy_core"
import { BreakpointState } from "../common/breakpointsystem"
import {  MarginGenerate } from "../common/Constants"
import ProxyPage from "./ProxyPage"
import ConfigurationPage from "./ConfigurationPage"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { number2Time } from "../utils/TimeConvertUtil"
import { getResourceString } from "../utils/ResourceStringUtil"


export enum SwiperPage{
  PXSSHome,
  PXSSProxy,
  PXSSConfiguration
}

@Component
export struct PXSecScreen{
  @Consume isPXSecScreen: boolean
  // 代理启动持续的时间
  @Consume proxyTime:number
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 按钮前Symbol动效
  private ReplaceSymbolEffect: SymbolEffect = EffectScope.WHOLE
  private promptAction: PromptAction = this.getUIContext()?.getPromptAction()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  // 代理启动按钮状态
  @Consume proxyEnabled: boolean
  // 配置页数据表
  @Consume configList: Array<ConfigData>
  // 定时器Controller
  @Consume proxyStartedTimer: Timer
  //节点数据组后期
  @Consume theProxyGroups: ProxyGroup[]
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding')  private cardPadding: BreakpointState<MarginGenerate>
  // 收藏与ping延迟即时动作
  private PXPromptAction: PromptAction = this.getUIContext()?.getPromptAction()
  pageInfosPX: NavPathStack = new NavPathStack()

  // 外屏三页
  @Builder
  PXSS(i: number){
    if (i==SwiperPage.PXSSHome){
      Column({ space: 8 }){
        Column(){
          ProxyINFO()
        }
        .aspectRatio(2.05)
        .width(290)
        .borderRadius(20)
        .backgroundColor($r('app.color.container_background'))
        .transition(customAnimationUtil.isScaleTran(1, this.uiConfig))
        .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
        Row({ space: 8 }){
          Column(){
            SwitchMode()
          }
          .aspectRatio(1)
          .width(141)
          .borderRadius(20)
          .backgroundColor($r('app.color.container_background'))
          .transition(customAnimationUtil.isScaleTran(2, this.uiConfig))
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          Column(){
            Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween }) {
              Column(){
                CardTitle({ title: $r('app.string.px_sec_screen_start') })
                // 计时器文本
                if(this.proxyEnabled) {
                  Text((getResourceString($r('app.string.px_sec_screen_use_time'), this) + number2Time(Number(this.proxyTime), true)))
                    .fontSize(14)// 使用透明度控制是否显示计时器，是因为用 `visibility` 来控制的话，不显示的时间长了之后，再次显示时候会延迟一秒，体验不好
                    .fontColor($r('sys.color.font_secondary'))
                    .transition(customAnimationUtil.isSlideR(0, this.uiConfig))
                }
              }.width('100%').alignItems(HorizontalAlign.Start)

              // 悬浮按钮 START
              Column(){
                Stack(){
                  SymbolGlyph(this.proxyEnabled ? $r('sys.symbol.pause') : $r('sys.symbol.play_fill'))
                    .fontColor([Color.White])
                    .align(Alignment.Center)
                    .fontSize(20)
                }
                .backgroundColor(this.icon_emphasize)
                .shadow({
                  radius: 10,
                  color: this.icon_emphasize,
                  offsetY: 4,
                  type: ShadowType.BLUR
                })
                .borderRadius(100)
                .width(42)
                .height(42)
                .clip(true)
                .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                .onClick(async (event: ClickEvent) => {
                  if(this.configList.length === 0 || this.theProxyGroups.length === 0) {
                    if (this.uiConfig.isVibrate) {
                      customVibrator.vibratorTriggerOfHapticClockTimer()
                    }
                    // 配置页没有数据，或者代理节点未加载
                    this.promptAction.showToast({ message: `${getContext().resourceManager.getStringSync($r('app.string.start_prompt'))}` })
                    // vpn小钥匙可能卡死，关闭vpn小钥匙
                    await ClashViewModel.StopVpn()
                  } else {
                    hilog.info(0xFF00, 'StartProxy', `#WindowChange#Timer PX外屏点击事件`)
                    this.proxyEnabled = !this.proxyEnabled
                    if (this.proxyEnabled) {
                      await ClashViewModel.StartVpn()
                    } else {
                      await ClashViewModel.StopVpn()
                    }
                    if (this.uiConfig.isVibrate) {
                      customVibrator.vibratorTriggerOfHapticClockTimer()
                    }
                  }
                })
                // 悬浮按钮 END
              }.alignItems(HorizontalAlign.End).width('100%')
            }
            .width('100%')
            .height('100%')
            .padding(this.cardPadding.value)
          }
          .aspectRatio(1)
          .width(141)
          .borderRadius(20)
          .backgroundColor($r('app.color.container_background'))
          .transition(customAnimationUtil.isScaleTran(3, this.uiConfig))
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
        }
      }
      .width('100%')
      .height('100%')
      .margin({top:14})
      .justifyContent(FlexAlign.Start)
    }else if (i==SwiperPage.PXSSProxy){
      ProxyPage()
        .padding({top:4})
    }else if (i==SwiperPage.PXSSConfiguration){
      ConfigurationPage()
        .padding({top:14,bottom:14})
    }
  }

  private swiperController2: SwiperController = new SwiperController()
  private indicatorController: IndicatorComponentController = new IndicatorComponentController()

  @State isTabSelect: boolean = false
  @State translateX: number | string = '-100%'
  @State tabsSelect: TabsSelect = new TabsSelect()
  @State tabsIconScale: number = 1

  // 底部切换页面组件
  @Builder
  tabSelect(){
    Stack(){
      Button({type: ButtonType.Normal})
        .backgroundColor($r('app.color.container_background'))
        .shadow({ radius:10,color:$r('app.color.shadow')})
        .height(56)
        .width('32.8%')
        .borderRadius(18)
        .translate({x:this.translateX})

      Row(){
        ForEach(TabsList, (n: TabsItem, i: number) => {
          Column({space:6}) {
            SymbolGlyph(n.icon)
              .fontSize(24)
              .fontColor([this.tabsSelect.swiperPage == n.swiperPage ? this.icon_emphasize : $r('sys.color.icon_tertiary')])
            Text(n.text)
              .fontSize(14)
              .fontColor(this.tabsSelect.swiperPage == n.swiperPage ? this.icon_emphasize : $r('sys.color.icon_tertiary'))
          }
          .scale(this.tabsSelect.swiperPage == n.swiperPage ?{x: this.tabsIconScale,y: this.tabsIconScale }:{x:1,y:1})
          .onTouch((event:TouchEvent)=>{
            animateTo({
              duration: this.uiConfig.animationSpeed,
              iterations: 1,
              playMode: PlayMode.Normal,
              curve:Curve.Ease,
            }, () => {
              if (event.type==TouchType.Down){
                this.switchTranslateX(i)
                this.tabsSelect.swiperPage = n.swiperPage

                console.info('索引',i)
                this.tabsIconScale = 0.8
              }else if (event.type==TouchType.Up){
                this.tabsIconScale = 1
              }
            })
          })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .alignItems(VerticalAlign.Center)
    }
    .height(60)
    .backgroundColor($r('app.color.px_sec_screen_tabs'))
    .borderRadius(20)
    .margin({left:16,right:16,bottom:8})
    .transition(customAnimationUtil.isSlideScaleBig(0, this.uiConfig))
    .geometryTransition("picture", { follow: false })
  }

  // 平移选择动画参数切换
  switchTranslateX(index: SwiperPage) {
    switch (index) {
      case SwiperPage.PXSSHome:
        this.translateX='-100%'
        this.swiperController2.changeIndex(0,true)
        break;
      case SwiperPage.PXSSProxy:
        this.translateX=0
        this.swiperController2.changeIndex(1,true)
        break
      case SwiperPage.PXSSConfiguration:
        this.translateX='100%'
        this.swiperController2.changeIndex(2,true)
        break
    }
  }

  build() {
    Stack(){
      Swiper(this.swiperController2){
        ForEach(TabsList,(n:TabsItem)=>{
          this.PXSS(n.swiperPage)
        })
      }
      .cachedCount(0)
      .indicator(false)
      .loop(false)
      .width('100%')
      .height('100%')
      .indicator(this.indicatorController)
      .onAnimationStart((index: number,targetIndex: number,extraInfo: SwiperAnimationEvent) => {
        animateTo({
          duration: this.uiConfig.animationSpeed,
          iterations: 1,
          playMode: PlayMode.Normal,
          curve: curves.interpolatingSpring(10, 1, 228, 30),
       }, () => {
          this.tabsSelect.swiperPage = targetIndex
          this.switchTranslateX(targetIndex)
        })
       console.info('swiper索引:',extraInfo.targetOffset)
      })
      // 单指长按文本触发该手势事件
      .gesture(
        LongPressGesture({ repeat: true })
          .onAction((event: GestureEvent) => {
            if (event) {
              this.PXPromptAction.showToast({ message: $r('app.string.px_sec_screen_tips') ,bottom:36})
            }
          })
      )

      if (!this.isTabSelect) {
        Stack() {
          IndicatorComponent(this.indicatorController)
            .hitTestBehavior(HitTestMode.None)
            .initialIndex(0)
            .style(
              new DotIndicator()
                .itemWidth(8)
                .itemHeight(8)
                .selectedItemWidth(12)
                .selectedItemHeight(8)//.color(Color.Gray)
                .selectedColor(this.icon_emphasize))
            .loop(false)
            .count(3)
            .onChange((index: number) => {
                console.info('dot索引：',index)
            })
        }
        .width(60)
        .height(20)
        .backgroundColor($r('app.color.px_sec_screen_dot'))
        .align(Alignment.Center)
        .borderRadius(20)
        .margin({ bottom: 8 })
        .shadow({
          radius: 10,
          color: $r('app.color.shadow'),
          offsetY: 4,
          type: ShadowType.BLUR
        })
        .onClick(() => {
          animateTo({
            duration: this.uiConfig.animationSpeed,
            iterations: 1,
            playMode: PlayMode.Normal,
            curve: curves.interpolatingSpring(10, 1, 228, 30),
          }, () => {
            this.isTabSelect = true
            setTimeout(() => {
              this.isTabSelect = false
            }, 3500)
          })
        })
      //  .geometryTransition("picture")
        .transition(customAnimationUtil.isSlideScaleSmall(0, this.uiConfig))
      }else{
        this.tabSelect()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
    .align(Alignment.Bottom)
  }
}


export interface TabsItem {
  text:Resource
  icon:Resource
  swiperPage:SwiperPage
}

export const TabsList:TabsItem[] = [
  {text:$r('app.string.Home'),icon:$r('sys.symbol.house_fill'),swiperPage:SwiperPage.PXSSHome},
  {text:$r('app.string.Proxy'),icon: $r('sys.symbol.list_bullet_square_fill'),swiperPage:SwiperPage.PXSSProxy},
  {text:$r('app.string.Configuration'),icon:$r('sys.symbol.folder_fill'),swiperPage:SwiperPage.PXSSConfiguration}
]

class TabsSelect{
  swiperPage?:SwiperPage = SwiperPage.PXSSHome
}
