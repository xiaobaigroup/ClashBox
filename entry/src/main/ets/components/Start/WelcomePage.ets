import { common } from '@kit.AbilityKit'
import { UIConfig } from '../../entryability/AppState'
import { CommonPage } from './CommonPage'
import { customAnimationUtil } from '../../utils/Animation'
import { BackButton } from '../Common'

// 协议顶部标题
@Builder
export function TopTitleText(t:Resource){
  Row(){
    Text(t)
      .fontSize(18)
      .fontWeight(FontWeight.Bold)
  }.width('100%').justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Center).height(70)
  .backgroundColor($r('app.color.background'))
}


// 欢迎入口
@Component
export struct WelcomeUserAgreement {

  // 欢迎页面栈
  @Consume('WelcomeNavPathStack') welcomePageInfos: NavPathStack

  build() {
    Navigation(this.welcomePageInfos) {
      Stack(){
        CommonPage({
          isWelcomeStack: true,
          nextPage: 'privacy-policy',
          docSrc: $rawfile('html/user_agreement.html')
        })

        TopTitleText($r('app.string.user_agreement'))
      }.alignContent(Alignment.TopStart)
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .navDestination(this.WelcomePagesMap)
    .backgroundColor($r('app.color.background'))
  }

  @Builder
  WelcomePagesMap(name: string) {
    if (name == 'privacy-policy') {
      WelcomePrivacyPolicy()
    } else
    if (name == 'welcome') {
      Welcome()
    }
  }
}

// 隐私政策
@Component
export struct WelcomePrivacyPolicy {
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 欢迎页面栈
  @Consume('WelcomeNavPathStack') welcomePageInfos: NavPathStack
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')

  build() {
    NavDestination() {
      Stack() {
        // 返回图标
        Column() {
          BackButton()
        }.zIndex(1)
        .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
        .height(70)
        .alignItems(HorizontalAlign.Start)
        .onClick(() => {
          this.welcomePageInfos.pop(true)
        })

        CommonPage({
          isWelcomeStack: true,
          nextPage: 'welcome',
          docSrc: $rawfile('html/privacy_policy.html')
        })

        TopTitleText($r('app.string.privacy_policy'))
      }
      .alignContent(Alignment.TopStart)
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.welcomePageInfos.pop(true)
      return true
    })
  }
}

@Component
export struct Welcome {
  @Consume isDisclaimer: boolean
  @Consume isShowWelcome: boolean
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 欢迎页面栈
  @Consume('WelcomeNavPathStack') welcomePageInfos: NavPathStack
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear(): void {
    this.isEnableIndexForegroundBlur = true
  }

  build() {
    NavDestination() {
      Stack() {
        // 返回图标
        Column() {
          BackButton()
        }.zIndex(1)
        .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
        .onClick(() => {
          this.welcomePageInfos.pop(true)
        })
        Column() {
          this.content()
        }
      }
      .alignContent(Alignment.TopStart)
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
  }

  @Builder
  content() {
    // Logo&欢迎语
    Column({space: 15}) {
      // logo
      Stack() {
        Image($r('app.media.background_warm'))
          .borderRadius(25)
          .height(106)
          .zIndex(1)
        Image($r("app.media.panda"))
          .height(106)
          .zIndex(2)
      }
      // 名称
      Image($r('app.media.clashbox'))
        .width(192)
    }.width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    // 免责声明
    Column() {
      Text($r('app.string.Disclaimer_Content'))
        .textAlign(TextAlign.Center)
    }.margin({bottom: 10, left: 15, right: 15})
    .alignItems(HorizontalAlign.Center)
    // 提示
    Column() {
      SymbolGlyph($r('sys.symbol.person_shield_fill'))
        .fontSize(20)
        .margin({bottom: 3})
        .fontColor([this.icon_emphasize])
        .onClick(() => {
          this.welcomePageInfos.pop(true)
        })
      Text($r('app.string.welcome_tips'))
        .fontColor($r('sys.color.font_secondary'))
      Flex({
        direction: FlexDirection.Row
      }) {
        Button($r('app.string.welcome_quickly_go'))
          .width('50%')
          .margin({ right: 16})
          .fontColor(this.icon_emphasize)
          .backgroundColor($r('app.color.container_background'))
          .onClick(() => {
            // 关闭背景模糊
            this.isEnableIndexForegroundBlur = false
            // 第一次启动应用
            this.uiConfig.isFirstStart = false
            // 关闭模态页
            this.isShowWelcome = false
          })
        Button($r('app.string.welcome_go'))
          .width('50%')
          .fontColor(Color.White)
          .backgroundColor(this.icon_emphasize)
          .onClick(() => {
            // 关闭背景模糊
            this.isEnableIndexForegroundBlur = false
            // 第一次启动应用
            this.uiConfig.isFirstStart = false
            // 启动所有气泡提示
            this.uiConfig.ShowStartPop = true
            this.uiConfig.ShowConfigPop = true
            this.uiConfig.ShowProxyPop = true
            // 关闭模态页
            this.isShowWelcome = false
          })
      }.width('90%')
      .margin({ top: 12, bottom: 5 })
    }.width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({left: 5, right: 5, bottom: 15})
  }

}

