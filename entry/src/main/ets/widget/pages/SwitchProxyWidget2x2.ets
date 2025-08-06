import ActionUtils from '../model/ActionUtils'
import { ProxyActionType } from '../model/FormCardConstant'

@Entry
@Component
struct SwitchProxyWidget2x2 {
  /** @description 主标题 */
  readonly title: Resource = $r('app.string.switch_proxy_title');
  /** @description 副标题 */
  readonly subTitle: string = 'ClashBox';
  /** @description 卡片宽度 */
  readonly fullWidthPercent: string = '100%';
  /** @description 卡片高度 */
  readonly fullHeightPercent: string = '100%';
  /** @description 卡片ID */
  @Watch('updateFormId')
  @LocalStorageProp('formId')
  formId: string = ''
  /** @description 开关变量 */
  @LocalStorageProp('proxyEnabled')
  proxyEnabled: boolean = false
  /** @description TODO 主题色 */
  @LocalStorageProp('icon_emphasize')
  icon_emphasize: ResourceColor = '#0A59F7'

  updateFormId() {
    ActionUtils.updateCardIdAction(this, this.formId)
  }

  build() {
    RelativeContainer() {
      // 标题
      Column({ space: 3.5 }) {
        Text(this.subTitle)
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))

        Text(this.title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
      }
      .alignItems(HorizontalAlign.Start)
      .id('title')

      // 运行时间
      Text() {
        if (this.proxyEnabled) {
          Span($r('app.string.px_sec_screen_use_time'))
          Span(': xx:xx:xx')
        } else {
          Span($r('app.string.not_enabled'))
        }
      }
      .fontSize(10)
      .fontColor($r('sys.color.font_secondary'))
      .alignRules({
        top: { anchor: 'title', align: VerticalAlign.Bottom }
      })

      // 开关按钮
      Button() {
        Text(this.proxyEnabled ? $r('app.string.close') : $r('app.string.open'))
          .fontColor(Color.White)
      }
      .width(this.fullWidthPercent)
      .aspectRatio(3.22)
      .align(Alignment.Center)
      .backgroundColor(this.icon_emphasize)
      .shadow({
        radius: 10,
        color: this.icon_emphasize,
        offsetY: 4,
      })
      .clip(true)
      .onClick(() => {
        ActionUtils.SwitchProxyAction(this, this.proxyEnabled ? ProxyActionType.STOP : ProxyActionType.START,
          this.formId)
      })
      .alignRules({
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
      })
    }
    .padding(12)
    .width(this.fullWidthPercent)
    .height(this.fullHeightPercent)
    .onClick(() => {
      ActionUtils.jumpApp(this)
    })
  }
}