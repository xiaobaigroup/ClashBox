import { BreakpointState } from '../../common/breakpointsystem'
import { mediaquery, PromptAction } from '@kit.ArkUI'
import { MarginGenerate } from '../../common/Constants'
import { CardTitle } from './CardTitleBuilder'
import { AppFlowingState, UIConfig } from '../../entryability/AppState'
import ClashViewModel from '../../entryability/ClashViewModel'
import { IpInfo } from 'proxy_core'
import { EventHub, EventKey } from '../../common/EventHub'
import { customVibrator } from '../../utils/VibratorUtil'
import { customAnimationUtil } from '../../utils/Animation'

@Component
struct PublicNetwork {
  //下部文字大小
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @State address: string = '中国大陆'
  @State IP: string = '255.255.255.255'
  phonelistener: mediaquery.MediaQueryListener =
    this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');
  //主页卡片内容IP地址小字体大小
  @Consume('HomeCardIPSmFontSize')
  private HomeCardIPSmFontSize: BreakpointState<number>
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageLink ('isLandscapePhone') private isLandscapePhone: boolean = false
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding') private cardPadding: BreakpointState<MarginGenerate>
  // 主页卡片内容IP地址字体大小
  @Consume('IPfontSize') private IPfontSize: BreakpointState<number>
  // 内容文本字体大小
  @Consume('breakPointStateHomeCardSwitchModeFontSize') private fontSize: BreakpointState<number>
  //编辑按钮点击后显示编辑状态判定
  @Consume isShowHomeEdit: boolean
  // 折叠屏展开状态判定
  @StorageLink ('isFoldStatus') private isFoldStatus: boolean = false
  // 收藏与ping延迟即时动作
  private PromptAction: PromptAction = this.getUIContext()?.getPromptAction()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @Consume remoteIp: IpInfo | null
  aboutToAppear(): void {
    EventHub.on(EventKey.checkIpInfo, async ()=>{
      this.remoteIp = null
      this.remoteIp = await ClashViewModel.checkIpInfo()
    })
  }
  build() {
    Column() {
      CardTitle({ title: $r('app.string.PublicNetwork') })
      Column() {
        if (this.remoteIp?.ip != undefined){
          Text(this.remoteIp?.country ?? " " )
            .fontSize(this.isLandscapePhone ? 12 : this.HomeCardIPSmFontSize.value)
            .fontColor($r('sys.color.font_secondary'))
            .transition(customAnimationUtil.isOpacity(this.uiConfig))

          Text( this.remoteIp?.ip  ?? $r('app.string.loading'))
            .fontSize(this.isLandscapePhone ? 16 :this.isFoldStatus ? 22: this.IPfontSize.value)
            .textAlign(TextAlign.JUSTIFY)
            .fontColor($r('sys.color.font_primary'))
            .transition(customAnimationUtil.isOpacity(this.uiConfig))
        }else {
          Row(){
            LoadingProgress()
              .size({width:24,height:24})
              .color(this.icon_emphasize)

            Text($r('app.string.loading'))
              .fontSize(this.isLandscapePhone ? 15 : this.isFoldStatus ? 22: this.IPfontSize.value)
              .textAlign(TextAlign.JUSTIFY)
              .fontColor($r('sys.color.font_primary'))
          }.transition(customAnimationUtil.isOpacity(this.uiConfig))
        }
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .flexGrow(1)

      Row() {
        Button($r('app.string.refresh_IP'))
          .width('55%')
          .height('25%')
          .labelStyle({ overflow: TextOverflow.Clip,
            maxLines: 1,
            minFontSize: 6,
            maxFontSize: 18,
            font: {
              size: this.fontSize.value,
            }
          })
          .fontColor(this.icon_emphasize)
          //.fontSize(this.isLandscapePhone ? 14 : this.fontSize.value)
          .backgroundColor($r('app.color.home_card_background'))
          .onClick(() => {
            // 在home页编辑卡片状态时，无法操作，点击回调写在if判定里
            if (this.isShowHomeEdit === false) {
                this.remoteIp = null
                EventHub.sendEvent(EventKey.checkIpInfo)
              if (this.uiConfig.isVibrate) {
                customVibrator.vibratorTriggerOfHapticClockTimer()
              }
            }
          })
      }.width('100%').justifyContent(FlexAlign.End)
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
    //.justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .id('PublicNetworkId')
  }
}

export default PublicNetwork