@Component
struct Start {
  @State DownloadSpeed: number = 0
  @State UploadSpeed: number = 0

  build() {
    Column() {
      Row() {
        Text($r('app.string.Start'))
          .fontSize(36)
          .margin({ top: 10, left: 20 })
      }
      .height(40)
      .width('100%')
      Row() {

      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .flexGrow(1)
      Row() {
        Text() {
          SymbolSpan($r('sys.symbol.chevron_up'))
        }
        Text(this.DownloadSpeed.toString() + 'Kbps')
          .margin({ right: 3 })
        Text() {
          SymbolSpan($r('sys.symbol.chevron_down'))
        }
        Text(this.UploadSpeed.toString() + 'Kbps')
          .margin({ right: 3 })
      }
      .height(24)
      .margin({right:20, bottom: 17})
      .width('100%')
      .justifyContent(FlexAlign.End)

    }
    .width('100%')
    .height('100%')
  }
}

export default Start