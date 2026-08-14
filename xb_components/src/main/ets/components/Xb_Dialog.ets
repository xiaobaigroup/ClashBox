
/**
 * 通用单Value 多行&单行 文本输入弹窗组件（保存&取消竖排按钮）
 * @param theDialogTitle 弹窗标题-ResourceStr
 * @param theplaceholder 输入框默认文本-ResourceStr
 * @param currentInputValue 实时的输入值-string
 */
@CustomDialog
export struct Xb_SingleValueDialog {

  @State Unit: ResourceStr = ''

  @Prop isArea: boolean
  @Prop currentInputValue: string
  @Prop theplaceholder: ResourceStr
  @Prop theDialogTitle: ResourceStr
  @Prop emphasizeColor: ResourceColor
  @Prop dialogBackgroundColor: ResourceColor = $r('app.color.start_window_background')

  cancel?: () => void
  confirm?: (value: string) => void
  controller: CustomDialogController

  build() {
    Column() {
      Text(this.theDialogTitle)
        .fontWeight(FontWeight.Medium)
        .fontSize(20)
        .margin({ top: 15, bottom: 15 })
      Flex({
        direction: FlexDirection.Row,
        alignItems: ItemAlign.Center
      }) {
        if (this.isArea) {
          TextArea({placeholder: this.theplaceholder, text: this.currentInputValue })
            .onChange((value: string) => {
              this.currentInputValue = value
            })
        } else {
          TextInput({placeholder: this.theplaceholder, text: this.currentInputValue })
            .onChange((value: string) => {
              this.currentInputValue = value
            })
        }
        if (this.Unit) {
          Text(this.Unit)
            .margin({left: 5})
        }
      }.margin({bottom: 8 })
     Row() {
       Button($r('app.string.xb_cancel'))
         .height(39)
         .width('50%')
         .fontColor(this.emphasizeColor ?? $r('sys.color.font_primary'))
         .backgroundColor($r('app.color.start_window_background'))
         .onClick(() => {
           this.controller.close()
           if (this.cancel) {
             this.cancel()
           }
         })
       Button($r('app.string.xb_save'))
         .width('50%')
         .height(39)
         .onClick(() => {
           this.controller.close()
           if (this.confirm) {
             this.confirm(this.currentInputValue)
           }
         })
         .fontColor(this.emphasizeColor)
         .fontColor(Color.White)
     }
    }
    .padding(16)
    .backgroundColor($r('app.color.start_window_background'))
    .width('100%')
  }
}