import { UIConfig } from "../../entryability/AppState"
import { customAnimationUtil } from "../../utils/Animation"
import { BackButton } from "../Common"
import { CommonPage } from "../Start/CommonPage"

/*设置入口*/
// 用户协议
@Component
export struct UserAgreement {

  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack

  build() {
    NavDestination() {
      Stack() {
        Column() {
          BackButton()
        }.zIndex(1)
        .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
        .onClick(() => {
          this.SettingsPageInfos.pop(true)
        })
        CommonPage({
          isWelcomeStack: false,
          nextPage: 'privacy-policy',
          docSrc: $rawfile('html/user_agreement.html')
        })
      }.alignContent(Alignment.TopStart)
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
  }
}

// 隐私政策
@Component
export struct PrivacyPolicy {

  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack

  build() {
    NavDestination() {
      Stack() {
        Column() {
          BackButton()
        }.zIndex(1)
        .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
        .onClick(() => {
          this.SettingsPageInfos.pop(true)
        })
        CommonPage({
          isEnd: true,
          isWelcomeStack: false,
          docSrc: $rawfile('html/privacy_policy.html')
        })
      }.alignContent(Alignment.TopStart)
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
  }
}
