@Entry
@Component
struct WidgetCard {
  /*
   * The title.
   */
  readonly title: string = 'Hello World';
  /*
   * The action type.
   */
  readonly actionType: string = 'router';
  /*
   * The ability name.
   */
  readonly abilityName: string = 'EntryAbility';
  /*
   * The message.
   */
  readonly message: string = 'add detail';
  /*
   * The width percentage setting.
   */
  readonly fullWidthPercent: string = '100%';
  /*
   * The height percentage setting.
   */
  readonly fullHeightPercent: string = '100%';
  @State Switch: boolean = false
  private Icon1: Resource = $r('sys.symbol.pause')
  private Icon2: Resource = $r('sys.symbol.play_fill')

  build() {
    Column() {
      Row() {
        Text('点击开启')

        SymbolGlyph(this.Switch ? this.Icon1 : this.Icon2)
          .fontColor([Color.White])
          .align(Alignment.Center)
          .width(32)
          .height(32)
          .borderRadius(36)
          .fontSize(18)
          .backgroundColor("#0a59f7")
      }
      .width(this.fullWidthPercent)
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width(this.fullWidthPercent)
    .height(this.fullHeightPercent)
    .justifyContent(FlexAlign.Center)
  }
}
