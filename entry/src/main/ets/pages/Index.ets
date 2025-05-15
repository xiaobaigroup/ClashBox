@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Column({space: 10}) {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .onClick(() => {
          this.message = 'Hello mihomo';
        })
      Text('这里是ClashNEXT内核部分')
        .id('tips')
        .fontSize(35)
        .fontWeight(FontWeight.Bold)
        .onClick(() => {
          this.message = 'Hello World';
        })
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
  }
}