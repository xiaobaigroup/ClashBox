import { getResourceString } from '../../utils/ResourceStringUtil'
import { common } from '@kit.AbilityKit'
import { UIConfig } from '../../entryability/AppState'
import { DisclaimerCustomDialog } from '../Common'


@Component
export struct Welcome {
  @Consume isShowWelcome: boolean
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear(): void {
    this.isEnableIndexForegroundBlur = true
  }

  // 免责声明弹窗控制器
  dialogController: CustomDialogController = new CustomDialogController({
    builder: DisclaimerCustomDialog({
      confirm: () => {
        this.uiConfig.isFirstStartDisclaimer = false
        // 同意
        this.isShowWelcome = true
      }
    }),
    autoCancel: false,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {

      } else if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {

      } else {
        dismissDialogAction.dismiss()
      }
    }
  })

  build() {
    Navigation() {
      // Logo&欢迎语
      Column() {
        Image($r('app.media.foreground'))
          .height(180)
        Row() {
          Text(`${getResourceString($r('app.string.welcome'), this)}Clash`)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
          Text('NEXT')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.icon_emphasize)
        }
      }.width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
     // 提示
     Column() {
       SymbolGlyph($r('sys.symbol.person_shield_fill'))
         .fontSize(20)
         .margin({bottom: 3})
         .fontColor([this.icon_emphasize])
       Text($r('app.string.welcome_tips'))
         .fontColor($r('sys.color.font_secondary'))
       Row() {
         // Text()
         Text($r('app.string.Disclaimer'))
           .fontColor(this.icon_emphasize)
           .onClick(() => {
             this.dialogController.open()
           })
       }
       Row({space: 16}) {
         Button($r('app.string.reject_exit'))
           .width('50%')
           .fontColor(Color.Red)
           .backgroundColor($r('app.color.container_background'))
           .onClick(() => {
             // 拒绝并退出
             this.context.terminateSelf()
           })
           .fontColor(Color.Red)
         Button($r('app.string.agree_continue'))
           .width('50%')
           .fontColor(Color.White)
           .backgroundColor(this.icon_emphasize)
           .onClick(() => {
             // 第一次启动应用
             this.uiConfig.isFirstStart = false
             // 关闭模态页
             this.isShowWelcome = false
           })
       }.width('90%')
       .margin({ top: 12 })
     }.width('100%')
     .justifyContent(FlexAlign.Center)
     .alignItems(HorizontalAlign.Center)
    }.padding(15)
  }
}