import { IpInfo } from 'proxy_core';
import ActionUtils from '../utils/ActionUtils'
import { ProxyActionType } from '../model/FormCardConstant'

@Entry
@Component
struct CurrentNodeWidget2x2 {
  /** @description 副标题 */
  readonly subTitle: Resource = $r('app.string.CurrentNode');
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
  /** @description IP地址信息 */
  @LocalStorageProp('remoteIp')
  remoteIp: IpInfo = {
    ip: 'Unknown',
    country: '',
  }
  /** @description 节点名 */
  @LocalStorageProp('currentProxyName')
  currentProxyName: string = '节点名'
  /** @description 主题色 */
  @LocalStorageProp('themeColor')
  themeColor: ResourceColor = '#0A59F7'

  updateFormId() {
    ActionUtils.updateCardIdAction(this, this.formId)
  }

  /** @description 根据延迟计算颜色 */
  getColorForLatency(latency: number): string | ResourceColor {
    if (latency >= 0 && latency <= 500) {
      return '#64BB5C'; // 绿色，表示低延迟
    }

    if (latency > 500 && latency <= 1000) {
      return '#f7ce00'; // 黄色，表示中等延迟
    }

    if (latency > 1000) {
      return '#e84026'; // 红色，表示高延迟
    }

    // 默认情况下，返回系统定义的次要字体颜色，适用于无效或未知的延迟值
    return $r('sys.color.font_secondary');
  }

  build() {
    RelativeContainer() {
      // 标题
      Column({ space: 3.5 }) {
        Text(this.subTitle)
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))

        Text(this.currentProxyName)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
      }
      .alignItems(HorizontalAlign.Start)
      .id('title')

      // 运行时间
      if (this.proxyEnabled) {
        Text() {
          Span('IP ')
          Span(this.remoteIp.ip)
        }
        .fontSize(10)
        .fontColor($r('sys.color.font_secondary'))
        .alignRules({
          top: { anchor: 'title', align: VerticalAlign.Bottom }
        })
      }

      // 延迟/按钮
      Row() {
        Text() {
          if (this.proxyEnabled) {
            Span($r('app.string.Delay'))
            Span(': xx ')
            Span('ms')
          } else {
            Span($r('app.string.not_enabled'))
          }
        }
        .fontSize(12)
        .fontColor(this.proxyEnabled ? this.getColorForLatency(1) : $r('sys.color.font_secondary'))

        Button() {
          SymbolGlyph(this.proxyEnabled ? this.icon1 : this.icon2)
            .fontColor([Color.White])
            .fontSize(21)
            .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), true)
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
          ActionUtils.SwitchProxyAction(this, this.proxyEnabled ? ProxyActionType.STOP : ProxyActionType.START,
            this.formId)
        })
      }
      .width(this.fullWidthPercent)
      .justifyContent(FlexAlign.SpaceBetween)
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
    })
  }
}