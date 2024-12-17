import { FONT_SIZE_16 } from "../../common/Constants"

@CustomDialog
export struct ConfigCustomDialog {
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor

  controller?: CustomDialogController
  // 事件
  cancel: () => void = () => {}
  // 按钮背景颜色
  cancelButtonBackgroundColor?: ResourceColor
  confirm: () => void = () => {}
  confirmButtonBackgroundColor?: ResourceColor


  build() {
    Column() {
      Row(){
        // TODO 国际化
        Text('是否保存当前配置？')
          .fontSize(20)
          .lineHeight(23)
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Bold)
      }
      .height(55)
      .padding({ top: 15, right: 24, bottom: 15, left: 24 })
      Blank()
      Row(){
        Button('取消')
          .width(144)
          .fontSize(FONT_SIZE_16)
          .fontColor($r('sys.color.warning'))
          .backgroundColor(this?.cancelButtonBackgroundColor ?? Color.Transparent)
          .onClick(() => {
            if (this.controller != undefined) {
              this.cancel()
              this.controller.close()
            }
          })
        Text(' ').width(8)
        Button('保存')
          .width(144)
          .fontSize(FONT_SIZE_16)
          .fontColor($r('sys.color.font_on_primary'))
          // .backgroundColor(this?.confirmButtonBackgroundColor ?? $r('sys.color.comp_background_emphasize'))
          .backgroundColor(this.icon_emphasize ?? $r('sys.color.comp_background_emphasize'))
          .onClick(() => {
            if (this.controller != undefined) {
              this.confirm()
              this.controller.close()
            }
          })
      }
      .height(55)
      .padding({ top: 0, right: 16, bottom: 16, left: 16 })
    }
    .alignItems(HorizontalAlign.Center)
    .animation({ duration: 200, curve: Curve.Ease })
  }
}