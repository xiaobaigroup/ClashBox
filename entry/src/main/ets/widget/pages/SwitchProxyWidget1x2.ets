import ActionUtils from '../model/ActionUtils'
import { ProxyActionType } from '../model/FormCardConstant'

@Entry
@Component
struct SwitchProxyWidget1x2 {
  /** @description 卡片宽度 */
  readonly fullWidthPercent: string = '100%';
  /** @description 卡片高度 */
  readonly fullHeightPercent: string = '100%';
  /** @description 关闭Icon */
  readonly icon1: Resource = $r('sys.symbol.pause')
  /** @description 开启Icon */
  readonly icon2: Resource = $r('sys.symbol.play_fill')
  /** @description 卡片ID */
  @Watch('updateFormId')
  @LocalStorageProp('formId')
  formId: string = ''
  /** @description 开关变量 */
  @LocalStorageProp('proxyEnabled')
  proxyEnabled: boolean = false
  /** @description 主题色 */
  @LocalStorageProp('themeColor')
  themeColor: ResourceColor = '#0A59F7'

  updateFormId() {
    ActionUtils.updateCardIdAction(this, this.formId)
  }

  build() {
    Column() {
      Row() {
        // 文字内容
        Row(){
          Text($r('app.string.click'))
          Text(this.proxyEnabled ? $r('app.string.close') : $r('app.string.open'))
        }

        // 开关按钮
        Button() {
          SymbolGlyph(this.proxyEnabled ? this.icon1 : this.icon2)
            .fontColor([Color.White])
            .fontSize(18)
            .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), true)
        }
        .align(Alignment.Center)
        .width(32)
        .aspectRatio(1)
        .backgroundColor(this.themeColor)
        .shadow({
          radius: 10,
          color: this.themeColor,
          offsetY: 4,
        })
        .clip(true)
        .onClick(() => {
          ActionUtils.SwitchProxyAction(this, this.proxyEnabled ? ProxyActionType.STOP : ProxyActionType.START,
            this.formId)
        })
      }
      .width(this.fullWidthPercent)
      .justifyContent(FlexAlign.SpaceAround)
    }
    .padding(12)
    .width(this.fullWidthPercent)
    .height(this.fullHeightPercent)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      // ActionUtils.jumpApp(this)
      ActionUtils.SwitchProxyAction(this, this.proxyEnabled ? ProxyActionType.STOP : ProxyActionType.START,
        this.formId)
    })
  }
}
