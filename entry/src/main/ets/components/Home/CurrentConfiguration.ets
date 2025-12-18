import { BreakpointState } from "../../common/breakpoint/breakpointsystem"
import { CardTitle } from "./CardTitleBuilder"
import { PromptAction } from "@kit.ArkUI"
import { AppConfig, UIConfig } from "../../entryability/AppState"
import { customVibrator } from "../../common/utils/VibratorUtil"
import ClashViewModel from "../../entryability/ClashViewModel"
import { HomeCardFontSize, HomeCardPadding, HomeCardProxyFontSize } from "../../common/breakpoint/BreakPoint"
import { Xb_ToastUtil } from "xb_components"

@Component
struct CurrentConfiguration {

  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 收藏与ping延迟即时动作
  PromptAction:PromptAction = this.getUIContext()?.getPromptAction()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //编辑按钮点击后显示编辑状态判定
  @Consume isShowHomeEdit: boolean


  build() {
    Column() {
      Column() {
        CardTitle({ title: $r('app.string.CurrentConfiguration') })
        Text(this.appConfig.currentProfileName ?? $r('app.string.config_name'))
          .fontSize(HomeCardProxyFontSize(this.widthBp, this.heightBp))
          .fontWeight(FontWeight.Bold)
          .maxLines(2)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      Button($r('app.string.refresh_IP'))
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
        .onClick(() => {
          // 在home页添加按钮的半模拟态里和在编辑卡片状态时，无法操作，点击回调写在if判定里
          if (this.isShowHomeEdit == false) {
            ClashViewModel.updateProfileConfig(this.appConfig.currentProfileId??'')
            if (this.uiConfig.isVibrate) {
              customVibrator.vibratorTriggerOfHapticClockTimer()
            }
          }
        })
    }
    .alignItems(HorizontalAlign.End)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding(HomeCardPadding(this.widthBp, this.heightBp))
    .width('100%')
    .height('100%')
    .id('CurrentConfigurationId')
  }
}

export default CurrentConfiguration