import ActionUtils from '../utils/ActionUtils'
import { ProxyActionType } from '../model/FormCardConstant'

const localStorage = new LocalStorage()

@Entry(localStorage)
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
  @Watch('updateFormId') @LocalStorageProp('formId') formId: string = ''
  /** @description 开关变量 */
  @LocalStorageProp('proxyEnabled') proxyEnabled: boolean = false
  /** @description 服务启动时间戳 */
  @LocalStorageProp('proxyStartingDuration') proxyStartingDuration: string = '00:00:00'
  /** @description 代理启动的计时文本 */
  // proxyStartedTimer: Timer = timerUtil
  /** @description 主题色 */
  @LocalStorageProp('themeColor') themeColor: ResourceColor = $r('sys.color.icon_emphasize')
  @LocalStorageProp('loading') loading: boolean = false
  @LocalStorageProp('tips') tips: string = ''

  updateFormId() {
    ActionUtils.updateCardIdAction(this, this.formId)
  }

  build() {
    RelativeContainer() {
      Column({ space: 3.5 }) {
        // 应用名
        Text(this.subTitle)
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))

        // 提示文本
        if (this.tips) {
          Text(this.tips)
            .fontSize(12)
        } else {
          // 卡片名
          Text(this.title)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .id('title')

      // 运行时间
      Text() {
        if (this.proxyEnabled) {
          Span($r('app.string.px_sec_screen_use_time'))
          Span(': ')
          Span(this.proxyStartingDuration)
        } else if (this.loading) {
          // 加载文本
          Span($r('app.string.card_tips'))
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
        if (this.loading) {
          LoadingProgress()
            .layoutWeight(1)
            .color(Color.White)
        } else {
          Text(this.proxyEnabled ? $r('app.string.close') : $r('app.string.open'))
            .fontColor(Color.White)
        }
      }
      .width('100%')
      .aspectRatio(3.4)
      .align(Alignment.Center)
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
      .alignRules({
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
      })
    }
    .padding(12)
    .width(this.fullWidthPercent)
    .height(this.fullHeightPercent)
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