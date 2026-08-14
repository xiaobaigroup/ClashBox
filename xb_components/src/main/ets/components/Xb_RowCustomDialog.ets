
/**
 * 开启&关闭提示弹窗组件（横排按钮）
 * @param rightText 传入自定义右按钮文本
 * @param leftText 传入自定义左按钮文本
 */
@CustomDialog
export struct Xb_RowCustomDialog {

  @State theDialogTitle: ResourceStr = ''
  @State contentText: ResourceStr = ''
  @State rightText: ResourceStr = '确认'
  @State leftText: ResourceStr = '取消'
  // 主题色
  @State icon_emphasize: ResourceColor = $r('sys.color.icon_emphasize')

  cancel?: () => void
  confirm?: () => void
  controller: CustomDialogController

  build() {
    Column() {
      // 标题
      Text(this.theDialogTitle)
        .fontWeight(FontWeight.Medium)
        .fontSize(20)
        .margin({ bottom: 15 })
      // 内容文本
      Text(this.contentText)
        .fontWeight(FontWeight.Regular)
        .fontSize(18)
        .margin({bottom: 8 })
      Row() {
        // 左按钮
        Row() {
          Button(this.leftText)
            .width('100%')
            .height(39)
            .fontColor(this.icon_emphasize)
            .backgroundColor($r('app.color.pip_background'))
        }.width('50%')
        .onClick(() => {
          this.controller.close()
          if (this.cancel) {
            this.cancel()
          }

        })
        // 右按钮
        Button(this.rightText)
          .height(39)
          .width('50%')
          .fontColor(Color.White)
          .backgroundColor(this.icon_emphasize)
          .onClick(() => {
            this.controller.close()
            if (this.confirm) {
              this.confirm()
            }
          })
      }.width('100%')
    }
    .padding({left: 16, right: 16, top: 15, bottom: 15})
    .backgroundColor($r('app.color.pip_background'))
    .width('100%')
  }
}