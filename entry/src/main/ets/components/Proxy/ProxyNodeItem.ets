import { EventHub, EventKey } from '../../common/EventHub'
import { ProxyItem as ProxyItem, ProxyData } from '../../common/datasources/ProxyData'
import { AppConfig, ProxyCardSize, UIConfig } from '../../entryability/AppState'
import ClashViewModel, { DelayInfo } from '../../entryability/ClashViewModel'
import { customVibrator } from '../../common/utils/VibratorUtil'
import { hilog } from '@kit.PerformanceAnalysisKit'

// 复用组件装饰器
@Reusable
@Component
export struct ProxyNode {
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @Prop item: ProxyItem
  @Prop disabled: boolean
  @State delay: number = 0
  @Prop selected: string
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @Consume isPXSecScreen: boolean
  selectProxy?: (item: ProxyItem) => void
  onLatencyChange?: (l: number) => void

  // 使用 @Reusable 必须实现 aboutToReuse 函数
  aboutToReuse(params: Record<string, Object>): void {
    this.item = params.item as ProxyItem
    this.disabled = params.disabled as boolean
    this.selected = params.selected as string
    this.selectProxy = params.selectProxy as (item: ProxyItem) => void
    this.onLatencyChange = params.onLatencyChange as (l: number)=> void
  }

  aboutToAppear(): void {
    this.delay = ClashViewModel.delayMap.get(this.item.name)?.delay ?? 0
    EventHub.on(EventKey.TestDelay, async (delay: DelayInfo)=>{
      if (delay.name == this.item.name){
        this.delay = delay.delay
      }
    }, false) // 批量监听
  }

  aboutToDisappear() {
  }


  build() {
    if (this.appConfig.proxyCardSize === ProxyCardSize.Large) {
      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween}) {
        Column({space: 3}) {
          Text(`${this.item.name}`).ItemTextStyle()
            .maxLines(1)
          Text(`${this.item.type}`).ItemTypeStyle()
        }.layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Row({space: 5}) {
          Text(delayText(this.delay))
            .fontColor(ProxyData.getColorForLatency(this.delay))
            .fontSize(12)
            .maxLines(1)
            .textAlign(TextAlign.End)
          // group 不要写死, 会和其他tab页的生效，在一个组里唯一
          Radio({ value: this.item.name, group: this.item.g + this.item.name})
            .checked(this.item.name === this.selected)
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
            })
            .hitTestBehavior(HitTestMode.None)
        }
      }.width('100%')
      .padding({left: 14, right: 16})
    } else if (this.appConfig.proxyCardSize === ProxyCardSize.Small) {
      Row() {
        Column() {
          Text(`${this.item.name}`).ItemTextStyle()
            .maxLines(2).padding({bottom: 5})
          Text(`${this.item.type}`).ItemTypeStyle()
            .textOverflow({ overflow: TextOverflow.Ellipsis})
          Text(delayText(this.delay))
            .fontColor(ProxyData.getColorForLatency(this.delay))
            .fontSize(12)
            .maxLines(1)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceBetween)
        Radio({ value: this.item.name, group: this.item.g + this.item.name })
          .checked(this.item.name === this.selected)
          .radioStyle({
            checkedBackgroundColor: this.icon_emphasize,
          })
          .hitTestBehavior(HitTestMode.None)
      }
      .ListRowStyle()
    } else {
      Row() {
        Column({space: 3}) {
          Text(`${this.item.name}`).ItemTextStyle()
            .maxLines(1)
          Row({space: 3}) {
            Text(`${this.item.type}`) //
              .maxLines(1)
              .ItemTypeStyle()
              .fontSize(this.isPXSecScreen ? 10 : 12)
              .constraintSize({maxWidth: this.uiConfig.stringDisplayIndex === 0 ? '55%' : Infinity})
              .textOverflow({ overflow: TextOverflow.Clip})
            Text(`${delayText(this.delay)}`)
              .fontColor(ProxyData.getColorForLatency(this.delay))
              .textOverflow({ overflow:this.isPXSecScreen ? TextOverflow.MARQUEE : TextOverflow.Ellipsis})
              .layoutWeight(1)
              .fontSize(this.isPXSecScreen ? 10 : 12)
              .maxLines(1)
              .textAlign(this.uiConfig.stringDisplayIndex === 0 ? TextAlign.End:TextAlign.Start)
          }.width(this.uiConfig.stringDisplayIndex === 0 ? '70%' : '100%')
          .justifyContent(FlexAlign.Start)
        }.layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Radio({ value: this.item.name, group: this.item.g + this.item.name })
          .checked(this.item.name === this.selected)
          .radioStyle({
            checkedBackgroundColor: this.icon_emphasize,
          })
          .hitTestBehavior(HitTestMode.None)
          .onChange((isChecked) => {
            hilog.debug(0xFF00, "ProxyPageGroupTag", "ProxyNodeItem #onChange %{public}s的选中状态%{public}s", this.item.name, isChecked)
          })
      }
      .ListRowStyle()
    }
  }
}

@Extend(Text)
function ItemTextStyle() {
  .fontColor(($r('sys.color.font_primary')))
  .fontSize(16)
  .fontWeight(FontWeight.Medium)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}
//Item中type（节点类型）公用样式
@Extend(Text)
function ItemTypeStyle() {
  .fontColor($r('sys.color.font_secondary'))
  .fontSize(12)
}
@Extend(Row)
function ListRowStyle() {
  .width('100%')
  .padding({ left: 14, right: 8, top: 5, bottom: 5})
// .alignItems(VerticalAlign.Center)
}

export function delayText(delay: number){
  if (delay == 0) {
    return ""
  } else if(delay < 0){
    return "timeout"
  } else {
    return delay + "ms"
  }
}

