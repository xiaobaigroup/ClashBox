import ActionUtils from '../utils/ActionUtils'
import { ProxyActionType } from '../model/FormCardConstant'

const localStorage = new LocalStorage()

@Entry(localStorage)
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
  @Watch('updateFormId') @LocalStorageProp('formId') formId: string = ''
  /** @description 开关变量 */
  @LocalStorageProp('proxyEnabled') proxyEnabled: boolean = false
  /** @description 主题色 */
  @LocalStorageProp('themeColor') themeColor: ResourceColor = $r('sys.color.icon_emphasize')
  @LocalStorageProp('loading') loading: boolean = false
  @LocalStorageProp('tips') tips: string = ''

  updateFormId() {
    ActionUtils.updateCardIdAction(this, this.formId)
  }
  build() {
    Column() {
      Row() {
        // 文字内容
        Row() {
          if (this.loading) {
            // 加载文本
            Text($r('app.string.card_tips'))
              .fontSize(12)
          } else if (this.tips) {
            // 提示文本
            Text(this.tips)
              .fontSize(12)
          } else {
            // 默认切换文本
            Text($r('app.string.click'))
            Text(this.proxyEnabled ? $r('app.string.close') : $r('app.string.open'))
          }
        }
        .width(70)

        // 开关按钮
        Button() {
          if (this.loading) {
            LoadingProgress()
              .width(24)
              .aspectRatio(1)
              .color(Color.White)
          } else {
            SymbolGlyph(this.proxyEnabled ? this.icon1 : this.icon2)
              .fontColor([Color.White])
              .fontSize(18)
              .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), true)
          }
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
          this.switchProxy()
        })
      }
      .width(this.fullWidthPercent)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding(12)
    .width(this.fullWidthPercent)
    .height(this.fullHeightPercent)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      // ActionUtils.jumpApp(this)
      this.switchProxy()
    })
  }

  private switchProxy() {
    ActionUtils.SwitchProxyAction(this, this.proxyEnabled ? ProxyActionType.STOP : ProxyActionType.START,
      this.formId)
    this.loading = true
  }
}
