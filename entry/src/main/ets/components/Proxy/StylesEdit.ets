import { ProxySort } from 'proxy_core'
import { BreakpointState } from '../../common/breakpointsystem'
import { BORDER_RADIUS_20 } from '../../common/Constants'
import { EventHub, EventKey } from '../../common/EventHub'
import { AppConfig, isEnd, ProxyCardSize, ProxyGroupType, UIConfig } from '../../entryability/AppState'
import { customAnimationUtil } from '../../utils/Animation'
import { proxyBindSheetTitleStyle } from '../Common'

@Component
export struct StylesEdit {
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  // 内容外边距
  @Consume('breakPointStateTabContentTitleMargin')
  private breakPointStateTabContentTitleMargin: BreakpointState<number>

  // 编辑页标题
  @Builder
  EditTitleBuilder(title: ResourceStr) {
    Text(title)
      .fontSize(16)
      .textAlign(0)
      .width('100%')
      .margin({ bottom: 10 })
      .fontColor($r('sys.color.font_secondary'))
  }

  build() {
    NavDestination() {
      // 顶部半模拟态标题及按钮
      proxyBindSheetTitleStyle({
        title: $r('app.string.edit_layout'),
        otherButton: (): void => {
        }
      })

      // 代理节点分组方式切换
      this.EditTitleBuilder($r('app.string.Packet_mode'))
      Column() {
        ForEach([{ t: $r('app.string.Tabs'), v: ProxyGroupType.Tabs },
          { t: $r('app.string.List'), v: ProxyGroupType.List }], (n: [Resource, number], i: number) => {
          Row() {
            Text(n["t"])
              .EditText()
            Radio({
              value: 'ProxyArrangementSelected1', group: 'ProxyArrangementSelectedRadioGroup',
              indicatorType: RadioIndicatorType.TICK,
            })
              .checked(this.appConfig.proxyGroupType == n["v"])
              .hitTestBehavior(HitTestMode.None)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
              })
          }
          .EditRow()
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          // 点击后改变ProxyArrangementSelected状态为 标签
          .onClick(() => {
            animateTo({ duration: this.uiConfig.animationSpeed }, () => {
              this.appConfig.proxyGroupType = n["v"]
            })
          })

          if (!isEnd(2, i)) {
            Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })
          }
        })
      }
      .height(94)
      .EditColumn()

      // 代理节点排列切换
      this.EditTitleBuilder($r('app.string.Arrangement'))
      Column() {
        ForEach([
          { t: $r('app.string.Default'), v: ProxySort.Default },
          { t: $r('app.string.Name'), v: ProxySort.Title },
          { t: $r('app.string.Delay'), v: ProxySort.Delay },
        ], (n: [Resource, number], i: number) => {
          Row() {
            Text(n["t"])
              .EditText()
            Radio({
              value: 'SortRadio1', group: 'SortRadioGroup',
              indicatorType: RadioIndicatorType.TICK
            })
              .checked(this.appConfig.proxySort == n["v"])
              .hitTestBehavior(HitTestMode.None)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
              })
          }
          .EditRow()
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .onClick(() => {
            EventHub.sendEvent(EventKey.ProxySort, n["v"])
            animateTo({ duration: this.uiConfig.animationSpeed }, () => {
              this.appConfig.proxySort = n["v"]
            })
          })

          if (!isEnd(3, i))
            Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })
        })
      }
      .height(142)
      .EditColumn()

      // 代理节点卡片尺寸切换
      this.EditTitleBuilder($r('app.string.Card_Size'))
      Column() {
        ForEach([
          { t: $r('app.string.Mini'), v: ProxyCardSize.Mini },
          { t: $r('app.string.Thin'), v: ProxyCardSize.Small },
          { t: $r('app.string.Wide'), v: ProxyCardSize.Large },
        ], (n: [Resource, number], i: number) => {
          Row() {
            Text(n["t"])
              .EditText()
            Radio({
              value: 'ProxyGroupItemSelectedRadio1', group: 'ProxyGroupItemSelectedRadioGroup',
              indicatorType: RadioIndicatorType.TICK
            })
              .checked(this.appConfig.proxyCardSize == n["v"])
              .hitTestBehavior(HitTestMode.None)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
              })
          }
          .EditRow()
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          // 点击后改变ProxyGroupItemSelected状态为 多列
          .onClick(() => {
            animateTo({ duration: this.uiConfig.animationSpeed }, () => {
              this.appConfig.proxyCardSize = n["v"]
            })
          })

          if (!isEnd(3, i)) {
            Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })
          }
        })
      }
      .height(142)
      .EditColumn()

    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .padding({
      left: this.breakPointStateTabContentTitleMargin.value,
      right: this.breakPointStateTabContentTitleMargin.value,
    })
  }
}

// 半模态编辑页Column公共样式（含非通用公共属性采用Extend继承的方式抽取）
@Extend(Column)
function EditColumn() {
  .padding({ left: 12, right: 12 })
  .width('100%')
  .margin({ bottom: 10 })
  .borderRadius(BORDER_RADIUS_20)
  .backgroundColor($r('app.color.container_background'))
  .justifyContent(FlexAlign.SpaceEvenly) // 非通用公共属性
}

// 半模态编辑页Row公共样式（含非通用公共属性采用Extend继承的方式抽取）
@Extend(Row)
function EditRow() {
  .width('100%')
  .justifyContent(FlexAlign.SpaceBetween) // 非通用公共属性
}

// 半模态编辑页Text共同属性（Text独有属性采用Extend继承的方式抽取）
@Extend(Text)
function EditText() {
  .font({ size: 16 })
  .fontColor($r('sys.color.font_primary')) // 一级文本色，黑色
}


