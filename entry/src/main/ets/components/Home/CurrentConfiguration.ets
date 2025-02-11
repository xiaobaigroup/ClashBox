import { BreakpointState } from "../../common/breakpointsystem"
import { MarginGenerate } from "../../common/Constants"
import { CardTitle } from "./CardTitleBuilder"
import { PromptAction } from "@kit.ArkUI"
import { AppConfig, UIConfig } from "../../entryability/AppState"
import { customVibrator } from "../../utils/VibratorUtil"

@Component
struct CurrentConfiguration {
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 内容文本字体大小
  @Consume('breakPointStateHomeCardSwitchModeFontSize') private fontSize: BreakpointState<number>
  //主页卡片内容当前节点字体大小
  @Consume('ProxyFontSize') private ProxyFontSize: BreakpointState<number>
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding')  private cardPadding: BreakpointState<MarginGenerate>
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
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
        Text(this.appConfig.currentProfileName)
          .fontSize(this.isLandscapePhone ? 24 : this.ProxyFontSize.value)
          .fontWeight(FontWeight.Bold)
          .maxLines(2)
          .fontColor($r('sys.color.font_primary'))
      }

      Button($r('app.string.refresh_IP'))
        .width('55%')
        .height('34%')
        .fontColor(this.icon_emphasize)
        .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
        .backgroundColor($r('app.color.home_card_background'))
        .onClick(() => {
          //在home页添加按钮的半模拟态里和在编辑卡片状态时，无法操作，点击回调写在if判定里
          if (this.isShowHomeEdit==false) {
            this.PromptAction.showToast({ message: $r('app.string.refresh_tips') })
            if (this.uiConfig.isVibrate) {
              customVibrator.vibratorTriggerOfHapticClockTimer()
            }
          }
        })
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
    .id('CurrentConfigurationId')
  }
}

export default CurrentConfiguration