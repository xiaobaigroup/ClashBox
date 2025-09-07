import { IpInfo } from 'proxy_core';
import ActionUtils from '../utils/ActionUtils'
import { ProxyActionType } from '../model/FormCardConstant'

const localStorage = new LocalStorage()

@Entry(localStorage)
@Component
struct IPAddressWidget2x2 {
  /** @description 副标题 */
  readonly subTitle: Resource = $r('app.string.PublicNetwork');
  /** @description 卡片宽度 */
  readonly fullWidthPercent: string = '100%';
  /** @description 卡片高度 */
  readonly fullHeightPercent: string = '100%';
  /** @description 刷新Icon */
  readonly icon: Resource = $r('sys.symbol.arrow_clockwise')
  /** @description 卡片ID */
  @Watch('updateFormId') @LocalStorageProp('formId') formId: string = ''
  /** @description 开关变量 */
  @LocalStorageProp('proxyEnabled') proxyEnabled: boolean = false
  /** @description IP地址信息 */
  @LocalStorageProp('remoteIp') remoteIp: IpInfo = {
    ip: 'Unknown',
    country: '',
  }
  /** @description 主题色 */
  @LocalStorageProp('themeColor') themeColor: ResourceColor = '#0A59F7'
  @State loading: boolean = false

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

        if (this.remoteIp.ip === '') {
          Row() {
            LoadingProgress()
              .size({ width: 18, height: 18 })
              .color(this.themeColor)

            Text($r('app.string.loading'))
              .fontSize(16)
          }.transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.Ease, delay: 0 }))
        } else {
          Text(this.remoteIp.ip)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .id('title')

      // 地理位置
      if (this.remoteIp.country) {
        Text(this.remoteIp.country)
          .fontSize(10)
          .fontColor($r('sys.color.font_secondary'))
          .alignRules({
            top: { anchor: 'title', align: VerticalAlign.Bottom }
          })
      }

      // 按钮
      Row() {
        Button() {
          SymbolGlyph(this.icon)
            .fontColor([Color.White])
            .fontSize(21)
            .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), true)
           // TODO 动画
        }
        .align(Alignment.Center)
        .width(36)
        .aspectRatio(1)
        .backgroundColor(this.themeColor)
        .shadow({
          radius: 10,
          color: this.themeColor,
          offsetY: 4,
        })
        .clip(true)
        .onClick(() => {
          this.remoteIp = {
            ip: '',
            country: '',
          }
          ActionUtils.refreshState(this)
        })
      }
      .alignItems(VerticalAlign.Bottom)
      .width(this.fullWidthPercent)
      .justifyContent(FlexAlign.End)
      .alignRules({
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
      })
    }
    .padding({
      top: 12,
      left: 12,
      right: 12,
      bottom: 14
    })
    .width(this.fullWidthPercent)
    .height(this.fullHeightPercent)
    .onClick(() => {
      ActionUtils.jumpApp(this)
      // ActionUtils.refreshState(this)
    })
  }
}