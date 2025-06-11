import { BreakpointState } from '../../common/breakpoint/breakpointsystem'
import { mediaquery, PromptAction } from '@kit.ArkUI'
import { CardTitle } from './CardTitleBuilder'
import { UIConfig } from '../../entryability/AppState'
import ClashViewModel from '../../entryability/ClashViewModel'
import { IpInfo } from 'proxy_core'
import { EventHub, EventKey } from '../../common/EventHub'
import { customVibrator } from '../../common/utils/VibratorUtil'
import { customAnimationUtil } from '../../common/utils/Animation'
import { HomeCardFontSize,
  HomeCardIPFontSize,
  HomeCardPadding, HomeCardPartSmallFontSize } from '../../common/breakpoint/BreakPoint'

@Component
struct PublicNetwork {

  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 折叠屏展开状态判定
  @StorageLink ('isFoldStatus') private isFoldStatus: boolean = false
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //编辑按钮点击后显示编辑状态判定
  @Consume isShowHomeEdit: boolean
  @Consume remoteIp: IpInfo | null

  // 收藏与ping延迟即时动作
  PromptAction: PromptAction = this.getUIContext()?.getPromptAction()

  build() {
    Column() {
      CardTitle({ title: $r('app.string.PublicNetwork') })
      Column() {
        if (this.remoteIp?.ip != undefined){
          Text(this.remoteIp?.country ?? " " )
            .fontSize(HomeCardPartSmallFontSize(this.widthBp, this.heightBp))
            .fontColor($r('sys.color.font_secondary'))
            .transition(customAnimationUtil.isOpacity(this.uiConfig))

          Text( this.remoteIp?.ip  ?? $r('app.string.loading'))
            .fontSize(HomeCardIPFontSize(this.widthBp, this.heightBp))
            .textAlign(TextAlign.JUSTIFY)
            .fontColor($r('sys.color.font_primary'))
            .transition(customAnimationUtil.isOpacity(this.uiConfig))
        } else {
          Row(){
            LoadingProgress()
              .size({width:24,height:24})
              .color(this.icon_emphasize)

            Text($r('app.string.loading'))
              .fontSize(HomeCardIPFontSize(this.widthBp, this.heightBp))
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
              size: HomeCardFontSize(this.widthBp, this.heightBp),
            }
          })
          .fontColor(this.icon_emphasize)
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
    .padding(HomeCardPadding(this.widthBp, this.heightBp))
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .id('PublicNetworkId')
  }

  aboutToAppear(): void {
    EventHub.on(EventKey.checkIpInfo, async ()=>{
      this.remoteIp = null
      this.remoteIp = await ClashViewModel.checkIpInfo()
    })
  }

}

export default PublicNetwork