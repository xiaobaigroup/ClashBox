import { EventHub, EventKey } from '../../common/EventHub'
import { ProxyItem as ProxyItem, ProxyData } from '../../common/ProxyData'
import { AppConfig, ProxyCardSize, UIConfig } from '../../entryability/AppState'
import ClashViewModel, { DelayInfo } from '../../entryability/ClashViewModel'
import { customVibrator } from '../../utils/VibratorUtil'


@Extend(Text)
function ItemTextStyle() {
  .fontColor(($r('sys.color.font_primary')))
  .fontSize(16)
  .fontWeight(FontWeight.Medium)
  .maxLines(1)
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

@Component
export struct ProxyNode {
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @Prop itemSize: ProxyCardSize
  @Prop item: ProxyItem
  @Prop disabled: boolean
  @State delay: number = 0
  @Prop selected: string
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()

  selectProxy?: (item: ProxyItem) => void
  onLatencyChange?:(l: number)=>void

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
    if (this.itemSize === ProxyCardSize.Large) {
      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween}) {
        Column({space: 3}) {
          Text(`${this.item.name}`).ItemTextStyle()
          Text(`${this.item.type}`).ItemTypeStyle()
        }.layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Row({space: 5}) {
          Text(delayText(this.delay))
            .fontColor(ProxyData.getColorForLatency(this.delay))
            .fontSize(12)
            .maxLines(1)
            .textAlign(TextAlign.End)
          // group唯一
          Checkbox({ name: this.item.name, group: this.item.g})
            .shape(CheckBoxShape.CIRCLE)
            .select(this.item.name === this.selected)
            .selectedColor(this.icon_emphasize)
            .hitTestBehavior(HitTestMode.None)
        }
      }.width('100%')
      .padding({left: 14, right: 16})
    } else if (this.itemSize === ProxyCardSize.Mini){
      Row() {
        Column({space: 3}) {
          Text(`${this.item.name}`).ItemTextStyle()
          Row({space: 3}) {
            Text(`${this.item.type}`)
              .maxLines(1)
              .ItemTypeStyle()
              .constraintSize({maxWidth: this.uiConfig.stringDisplayIndex === 0 ? '55%' : Infinity})
              .textOverflow({ overflow: TextOverflow.Clip})
            Text(delayText(this.delay))
              .fontColor(ProxyData.getColorForLatency(this.delay))
              .textOverflow({ overflow: TextOverflow.Ellipsis})
              .layoutWeight(1)
              .fontSize(12)
              .maxLines(1)
              .textAlign(this.uiConfig.stringDisplayIndex === 0 ? TextAlign.End:TextAlign.Start)
          }.width(this.uiConfig.stringDisplayIndex === 0 ? '70%' : '100%')
          .justifyContent(FlexAlign.Start)
        }.layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Checkbox({ name: this.item.name, group: this.item.g/* + this.item.name*/})
          .shape(CheckBoxShape.CIRCLE)
          .select(this.item.name === this.selected)
          .selectedColor(this.icon_emphasize)
          .hitTestBehavior(HitTestMode.None)
      }
      .ListRowStyle()
    } else {
      Row() {
        Column() {
          Text(`${this.item.name}`).ItemTextStyle().maxLines(2).padding({bottom:5})
          Column() {
            Text(`${this.item.type}`).ItemTypeStyle()
              .textOverflow({ overflow: TextOverflow.Ellipsis})
            Text(delayText(this.delay))
              .fontColor(ProxyData.getColorForLatency(this.delay))
              .fontSize(12)
              .maxLines(1)
          }.alignItems(HorizontalAlign.Start)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceBetween)
        Checkbox({ name: this.item.name, group: this.item.g})
          .shape(CheckBoxShape.CIRCLE)
          .select(this.item.name === this.selected)
          .selectedColor(this.icon_emphasize)
          .hitTestBehavior(HitTestMode.None)
      }
      .ListRowStyle()
    }
  }

}