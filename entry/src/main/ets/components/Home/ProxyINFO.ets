import { BreakpointState } from "../../common/breakpointsystem"
import { MarginGenerate } from "../../common/Constants"
import { ProxyItem, ProxyData } from "../../common/ProxyData"
import { AppConfig, AppFlowingState, UIConfig } from "../../entryability/AppState"
import { CardTitle } from "./CardTitleBuilder"
import { PromptAction } from "@kit.ArkUI"
import ClashViewModel from "../../entryability/ClashViewModel"
import { JSON } from "@kit.ArkTS"
import { customVibrator } from "../../utils/VibratorUtil"
import { delayText } from "../Proxy/ProxyNodeItem"
import { IpInfo } from "proxy_core"
import { EventHub, EventKey } from "../../common/EventHub"
import { customAnimationUtil } from "../../utils/Animation"

@Component
struct ProxyINFO{
  //自定义主题，颜色在AppTheme里面修改
  @Consume('icon_emphasize') icon_emphasize: ResourceColor //高亮图标,可在apptheme更换
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding')  private cardPadding: BreakpointState<MarginGenerate>
  //节点假数据组后期可改可删
  @Consume items: ProxyItem[]
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageLink ('isLandscapePhone')  private isLandscapePhone: boolean = false
  // 折叠屏展开状态判定
  @StorageLink ('isFoldStatus') private isFoldStatus: boolean = false
  // 主页卡片内容IP地址字体大小
  @Consume('IPfontSize') private IPfontSize: BreakpointState<number>
  //主页卡片内容当前节点字体大小
  @Consume('ProxyFontSize') private ProxyFontSize: BreakpointState<number>
  //主页卡片内容IP地址小字体大小
  @Consume('HomeCardIPSmFontSize') private HomeCardIPSmFontSize: BreakpointState<number>
  //主页卡片内容当前延迟小字体大小（16,20,18,24）
  @Consume('HomeCardPrpxySmFontSize') private HomeCardPrpxySmFontSize: BreakpointState<number>
  //主页卡片内容网络测速字体大小
  @Consume('SpeedfontSize12_14_14_16') private SpeedfontSize12_14_14_16: BreakpointState<number>
  // 内容文本字体大小
  @Consume('breakPointStateHomeCardSwitchModeFontSize') private fontSize: BreakpointState<number>

  //编辑按钮点击后显示编辑状态判定
  @Consume isShowHomeEdit: boolean
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageProp("appFlowingState") appFlowingState: AppFlowingState = new AppFlowingState()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  //收藏与ping延迟即时动作
  private PromptAction:PromptAction = this.getUIContext()?.getPromptAction()
  @Consume remoteIp: IpInfo | null
  // px外屏
  @Consume isPXSecScreen: boolean
  aboutToAppear(): void {
    EventHub.on(EventKey.checkIpInfo, async ()=>{
      this.remoteIp = null
      this.remoteIp = await ClashViewModel.checkIpInfo()
    })
  }

  build() {
    Row() {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween }) {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
          CardTitle({ title: $r('app.string.proxy_info') })
          if (this.appConfig.currentProxyItem) {
            Text(`${this.appConfig.currentProxyName}`)
              .maxLines(2)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
              .textOverflow({ overflow: TextOverflow.Clip })
              .fontSize(this.isLandscapePhone ? 20 : this.ProxyFontSize.value)
          } else {
            Text($r('app.string.proxy_name'))
              .fontSize(this.isLandscapePhone ? 20 : this.ProxyFontSize.value)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.font_primary'))
          }

          if (this.remoteIp?.ip != undefined){
            Row(){
              Text(this.remoteIp?.country ?? " " )
                .fontSize(this.isPXSecScreen? 12 :this.isLandscapePhone ? 12 : this.HomeCardIPSmFontSize.value)
                .fontColor($r('sys.color.font_secondary'))

              Text(' ')
                .fontSize(this.isPXSecScreen? 12 :this.isLandscapePhone ? 12 : this.HomeCardIPSmFontSize.value)
                .fontColor($r('sys.color.font_secondary'))

              Text( this.remoteIp?.ip  ?? $r('app.string.loading'))
                .fontSize(this.isPXSecScreen? 12 :this.isLandscapePhone ? 16 :this.isFoldStatus ?22: this.IPfontSize.value)
                .fontColor($r('sys.color.font_secondary'))
            }.transition(customAnimationUtil.isOpacity(this.uiConfig))
          }else {
            Row(){
              LoadingProgress()
                .size({width:16,height:16})
                .color(this.icon_emphasize)

              Text($r('app.string.loading'))
                .fontSize(this.isPXSecScreen? 12 :this.isLandscapePhone ? 16 :this.isFoldStatus ?22: this.IPfontSize.value)
                .fontColor($r('sys.color.font_secondary'))
            } .transition(customAnimationUtil.isOpacity(this.uiConfig))
          }
        }
        if (this.appConfig.currentProxyItem) {
          Text('ping ' + `${delayText(ClashViewModel.delayMap.get(this.appConfig.currentProxyItem.name)?.delay ?? 0)}`)
            .fontSize(this.isLandscapePhone ? 16 : this.HomeCardPrpxySmFontSize.value)
            .fontColor(ProxyData.getColorForLatency(ClashViewModel.delayMap.get(this.appConfig.currentProxyItem.name)?.delay ?? 0))
        } else {
          Row() {
            Text('ping ')
              .fontSize(this.isLandscapePhone ? 16 : this.HomeCardPrpxySmFontSize.value)
              .fontColor('#64BB5C')
            Text($r('app.string.Delay'))
              .fontSize(this.isLandscapePhone ? 16 : this.HomeCardPrpxySmFontSize.value)
              .fontColor('#64BB5C')
          }
        }
      }.width('60%')
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.End, justifyContent: FlexAlign.SpaceBetween }) {
        Column() {
          Row({space: 5}) {
            Text(this.appFlowingState.traffics.getLast()?.up?.toString() ?? "0 kb")
              .fontSize(this.isLandscapePhone ? 12:this.SpeedfontSize12_14_14_16.value)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.End)

            SymbolGlyph($r('sys.symbol.chevron_up'))
              .fontColor([$r('sys.color.font_primary')])
          }.width('100%').justifyContent(FlexAlign.End)

          Row({space: 5}) {
            Text(this.appFlowingState.traffics.getLast()?.down?.toString() ?? "0 kb")
              .fontSize(this.isLandscapePhone ? 12:this.SpeedfontSize12_14_14_16.value)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.End)

            SymbolGlyph($r('sys.symbol.chevron_down'))
              .fontColor([$r('sys.color.font_primary')])
          }.width('100%').justifyContent(FlexAlign.End)
        }

        Button($r('app.string.refresh_IP2'))
          .width(this.isPXSecScreen? 78 : this.isLandscapePhone ? '60%' : '55%')
          .height(this.isPXSecScreen? 30 : this.isLandscapePhone ? '27%' : '25%')
          .fontColor(this.icon_emphasize)
          .fontSize(this.isPXSecScreen? 14 : this.isLandscapePhone ? 14 : this.fontSize.value)
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
    .padding(this.cardPadding.value)
    .id('ProxyINFOId')
  }
}

export default ProxyINFO