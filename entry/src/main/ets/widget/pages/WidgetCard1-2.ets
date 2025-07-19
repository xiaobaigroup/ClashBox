@Entry
@Component
struct WidgetCard {
  /** @description 开关变量 */
  @LocalStorageProp('proxyEnabled')
  proxyEnabled: boolean = false
  /** @description 卡片宽度 */
  readonly fullWidthPercent: string = '100%';
  /** @description 卡片高度 */
  readonly fullHeightPercent: string = '100%';
  /** @description 关闭Icon */
  private icon1: Resource = $r('sys.symbol.pause')
  /** @description 开启Icon */
  private icon2: Resource = $r('sys.symbol.play_fill')
  /** @description 卡片ID */
  @Watch('updateFormId')
  @LocalStorageProp('formId')
  formId: string = ''
  /** @description TODO 主题色 */
  @LocalStorageProp('icon_emphasize')
  icon_emphasize: ResourceColor = '#0A59F7'

  updateFormId() {
    postCardAction(this, {
      action: 'call',
      bundleName: 'org.xbgroup.clashboxb',
      abilityName: 'EntryAbility',
      params: {
        method: 'updateFormId',
        formId: this.formId
      }
    })
  }

  build() {
    Column() {
      Row() {
        Text(`点击${this.proxyEnabled ? '关闭' : '开启'}`)

        Button() {
          SymbolGlyph(this.proxyEnabled ? this.icon1 : this.icon2)
            .fontColor([Color.White])
            .fontSize(18)
        }
        .align(Alignment.Center)
        .width(32)
        .height(32)
        .borderRadius(36)
        .backgroundColor(this.icon_emphasize)
        .shadow({
          radius: 10,
          color: this.icon_emphasize,
          offsetY: 4,
        })
        .borderRadius(100)
        .width(32)
        .height(32)
        .clip(true)
        .onClick(() => {
          postCardAction(this, {
            action: 'call',
            bundleName: 'org.xbgroup.clashboxb',
            abilityName: 'EntryAbility',
            params: {
              method: 'cardChangeProxy',
              formId: this.formId
            }
          })
        })
      }
      .width(this.fullWidthPercent)
      .justifyContent(FlexAlign.SpaceAround)
    }
    .padding(12)
    .width(this.fullWidthPercent)
    .height(this.fullHeightPercent)
    .justifyContent(FlexAlign.Center)
  }
}
