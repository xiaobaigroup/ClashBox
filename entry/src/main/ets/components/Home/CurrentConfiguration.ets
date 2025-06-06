import { BreakpointState } from "../../common/breakpoint/breakpointsystem"
import { CardTitle } from "./CardTitleBuilder"
import { PromptAction } from "@kit.ArkUI"
import { AppConfig, UIConfig } from "../../entryability/AppState"
import { customVibrator } from "../../common/utils/VibratorUtil"
import ClashViewModel from "../../entryability/ClashViewModel"
import { HomeCardFontSize, HomeCardPadding, HomeCardProxyFontSize } from "../../common/breakpoint/BreakPoint"

@Component
struct CurrentConfiguration {
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageLink ('isLandscapePhone') private isLandscapePhone: boolean = false
  //编辑按钮点击后显示编辑状态判定
  @Consume isShowHomeEdit: boolean
  //收藏与ping延迟即时动作
  private PromptAction:PromptAction = this.getUIContext()?.getPromptAction()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()


  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.End, justifyContent: FlexAlign.SpaceBetween}) {
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
        CardTitle({ title: $r('app.string.CurrentConfiguration') })
        Text(this.appConfig.currentProfileName ?? $r('app.string.config_name'))
          .fontSize(HomeCardProxyFontSize(this.widthBp, this.heightBp))
          .fontWeight(FontWeight.Bold)
          .maxLines(2)
          .fontColor($r('sys.color.font_primary'))
      }

      Button($r('app.string.refresh_IP'))
        .width('55%')
        .height('34%')
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
          //在home页添加按钮的半模拟态里和在编辑卡片状态时，无法操作，点击回调写在if判定里
          if (this.isShowHomeEdit == false) {
            ClashViewModel.updateProfileConfig(this.appConfig.currentProfileId??'')
            if (this.uiConfig.isVibrate) {
              customVibrator.vibratorTriggerOfHapticClockTimer()
            }
          }
        })
    }
    .padding(HomeCardPadding(this.widthBp, this.heightBp))
    .width('100%')
    .height('100%')
    .id('CurrentConfigurationId')
  }
}

export default CurrentConfiguration