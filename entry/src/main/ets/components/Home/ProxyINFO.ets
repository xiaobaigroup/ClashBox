import { BreakpointState } from "../../common/breakpoint/breakpointsystem"
import { ProxyItem, ProxyData } from "../../common/datasources/ProxyData"
import { AppConfig, AppFlowingState, UIConfig } from "../../entryability/AppState"
import { CardTitle } from "./CardTitleBuilder"
import { PromptAction } from "@kit.ArkUI"
import ClashViewModel from "../../entryability/ClashViewModel"
import { customVibrator } from "../../common/utils/VibratorUtil"
import { delayText } from "../Proxy/ProxyNodeItem"
import { IpInfo } from "proxy_core"
import { EventHub, EventKey } from "../../common/EventHub"
import { customAnimationUtil } from "../../common/utils/Animation"
import { HomeCardFontSize,
  HomeCardIPFontSize,
  HomeCardPadding,
  HomeCardPartSmallFontSize,
  HomeCardPartSmFontSize,
  HomeCardProxyFontSize,
  HomeCardSpeedFontSize,
  HomeCardTextMaxLines} from "../../common/breakpoint/BreakPoint"
import { Xb_ToastUtil } from "xb_components"

@Component
struct ProxyINFO {

  @StorageProp("appFlowingState") appFlowingState: AppFlowingState = new AppFlowingState()
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 自定义主题，颜色在AppTheme里面修改
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 是否检查过IP地址
  @StorageLink('isCheckIP') isCheckIP: boolean = false
  // 编辑按钮点击后显示编辑状态判定
  @Consume isShowHomeEdit: boolean
  @Consume remoteIp: IpInfo | null

  //收藏与ping延迟即时动作
  PromptAction:PromptAction = this.getUIContext()?.getPromptAction()

  build() {
    Row() {
      Flex({
        direction: FlexDirection.Column,
        alignItems: ItemAlign.Start,
        justifyContent: FlexAlign.SpaceBetween })
      {
        Flex({
          direction: FlexDirection.Column,
          alignItems: ItemAlign.Start,
          justifyContent: FlexAlign.Start })
        {
          CardTitle({ title: $r('app.string.proxy_info') })
          if (this.appConfig.currentProxyItem) {
            Text(`${this.appConfig.currentProxyName}`)
              .maxLines(HomeCardTextMaxLines(this.widthBp, this.heightBp))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
              .textOverflow({ overflow: TextOverflow.Clip })
              .fontSize(HomeCardProxyFontSize(this.widthBp, this.heightBp))
          } else {
            Text($r('app.string.proxy_name'))
              .fontSize(HomeCardProxyFontSize(this.widthBp, this.heightBp))
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
          }

          if (this.remoteIp?.ip != undefined){
            Row(){
              Text(this.remoteIp?.country ?? " " )
                .fontSize(HomeCardPartSmallFontSize(this.widthBp, this.heightBp))
                .fontColor($r('sys.color.font_secondary'))

              Text(' ')
                .fontSize(HomeCardPartSmallFontSize(this.widthBp, this.heightBp))
                .fontColor($r('sys.color.font_secondary'))

              Text( this.remoteIp?.ip  ?? $r('app.string.loading'))
                .fontSize(HomeCardIPFontSize(this.widthBp, this.heightBp))
                .fontColor($r('sys.color.font_secondary'))
            }.transition(customAnimationUtil.isOpacity(this.uiConfig))
          }else {
            Row(){
              LoadingProgress()
                .size({width:16,height:16})
                .color(this.icon_emphasize)

              Text($r('app.string.loading'))
                .fontSize(HomeCardIPFontSize(this.widthBp, this.heightBp))
                .fontColor($r('sys.color.font_secondary'))
            } .transition(customAnimationUtil.isOpacity(this.uiConfig))
          }
        }
        if (this.appConfig.currentProxyItem) {
          Text('ping ' + `${delayText(ClashViewModel.delayMap.get(this.appConfig.currentProxyItem.name)?.delay ?? 0)}`)
            .fontSize(HomeCardPartSmFontSize(this.widthBp, this.heightBp))
            .fontColor(ProxyData.getColorForLatency(ClashViewModel.delayMap.get(this.appConfig.currentProxyItem.name)?.delay ?? 0))
        } else {
          Row() {
            Text('ping ')
              .fontSize(HomeCardPartSmFontSize(this.widthBp, this.heightBp))
              .fontColor('#64BB5C')
            Text($r('app.string.Delay'))
              .fontSize(HomeCardPartSmFontSize(this.widthBp, this.heightBp))
              .fontColor('#64BB5C')
          }
        }
      }.width('60%')

      Flex({
        direction: FlexDirection.Column,
        alignItems: ItemAlign.End,
        justifyContent: FlexAlign.SpaceBetween })
      {
        Column() {
          Row({space: 5}) {
            Text(this.appFlowingState.traffics.getLast()?.up?.toString() ?? "0 kb")
              .fontSize(HomeCardSpeedFontSize(this.widthBp, this.heightBp))
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.End)

            SymbolGlyph($r('sys.symbol.chevron_up'))
              .fontColor([$r('sys.color.font_primary')])
          }.width('100%').justifyContent(FlexAlign.End)

          Row({space: 5}) {
            Text(this.appFlowingState.traffics.getLast()?.down?.toString() ?? "0 kb")
              .fontSize(HomeCardSpeedFontSize(this.widthBp, this.heightBp))
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.End)

            SymbolGlyph($r('sys.symbol.chevron_down'))
              .fontColor([$r('sys.color.font_primary')])
          }.width('100%').justifyContent(FlexAlign.End)
        }

        Button($r('app.string.refresh_IP2'))
          .width(Xb_ToastUtil.px2vp(212))
          .height(Xb_ToastUtil.px2vp(95))
          .labelStyle({ overflow: TextOverflow.Clip,
            maxLines: 1,
            minFontSize: 6,
            maxFontSize: 18,
            font: {
              size: HomeCardFontSize(this.widthBp, this.heightBp),
            }
          })
          .fontColor(this.icon_emphasize)
          .fontSize(HomeCardFontSize(this.widthBp, this.heightBp))
          .backgroundColor($r('app.color.home_card_background'))
          .onClick(async () => {
            //在home页在编辑卡片状态时，无法操作，点击回调写在if判定里
            if ( this.isShowHomeEdit===false) {
              this.remoteIp = null
              EventHub.sendEvent(EventKey.checkIpInfo)
              if (this.uiConfig.isVibrate) {
                customVibrator.vibratorTriggerOfHapticClockTimer()
              }
            }
          })
      }
      .width('40%')
    }
    .width('100%')
    .height('100%')
    .padding(HomeCardPadding(this.widthBp, this.heightBp))
    .id('ProxyINFOId')
    .onVisibleAreaChange([0],(isExpanding: boolean, currentRatio: number) => {
      console.debug('显示 ProxyINFO -', isExpanding, currentRatio)

      // 当组件显示的时候 -> 执行一次 IP刷新
      if (isExpanding) {
        EventHub.sendEvent(EventKey.checkIpInfo)
      }
    })
  }

  aboutToAppear(): void {
    // 检查IP事件(按需执行)
    if (!this.isCheckIP) {
      this.isCheckIP = true
      EventHub.on(EventKey.checkIpInfo, async () => {
        // 检查IP是否正在刷新中
        const isCheckIpInfo = AppStorage.get<boolean>('isCheckIpInfo') ?? false
        if (isCheckIpInfo) {
          return
        }

        AppStorage.setOrCreate("isCheckIpInfo", true) // 标记IP正在刷新中
        this.remoteIp = null
        this.remoteIp = await ClashViewModel.checkIpInfo()
        AppStorage.delete("isCheckIpInfo") // 刷新完成移除临时的全局变量，减少内存开销
      })
    }
  }

}

export default ProxyINFO