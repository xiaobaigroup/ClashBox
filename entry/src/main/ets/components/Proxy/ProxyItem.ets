import { EventHub, EventKey } from '../../common/EventHub'
import { ProxyItem as ProxyItem, ProxyData } from '../../common/ProxyData'
import { ProxyCardSize, UIConfig } from '../../entryability/AppState'
import ClashViewModel from '../../entryability/ClashViewModel'
import { customVibrator } from '../../utils/VibratorUtil'


@Extend(Text)
function ItemTextStyle() {
  .fontColor(($r('sys.color.font_primary')))
  .fontSize(18)
  .fontWeight(FontWeight.Medium)
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .width('80%')
}
//Item中type（节点类型）公用样式
@Extend(Text)
function ItemTypeStyle() {
  .fontColor($r('sys.color.font_secondary'))
  .fontSize(14)
}
@Extend(Row)
function ListRowStyle() {
  .width('100%')
  .padding({ left: 14, right:8})
  .alignItems(VerticalAlign.Center)
}

@Component
export struct ProxyNode {
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @Prop itemSize: ProxyCardSize
  @Prop item: ProxyItem
  @Prop disabled: boolean
  @Prop selected: string

  selectProxy?: (item: ProxyItem) => void
  aboutToAppear(): void {
    EventHub.on(EventKey.TestDelayAll, async (name: string)=>{
      if(name == this.item.name){
        await ClashViewModel.testDelay(name).then(d => {
          this.item.latency = d
        })
      } else if (!name) {
        await ClashViewModel.testDelay(this.item.name).then(d => {
          this.item.latency = d
        })
      }

    }, false) // 批量监听
  }
  build() {
    if (this.itemSize === ProxyCardSize.Large){
      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween}) {
        Column() {
          Text(`${this.item.name}`).ItemTextStyle()
          Text(`${this.item.type}`).ItemTypeStyle()
        }.alignItems(HorizontalAlign.Start)
        Row({space:10}){
          Text(`${this.item.latency ?? "-"}` + 'ms')
            .fontColor(ProxyData.getColorForLatency(this.item.latency))
            .fontSize(16)
            .maxLines(1)
            .textAlign(TextAlign.End)
          // group 不要写死, 会和其他tab页的生效，在一个组里唯一
          // 使用.enabled(!this.disabled) 来禁用radio不让选
          //Radio({ value: 'ProxyRadio' + index, group: 'ProxyGroup' }).enabled(!this.disabled)
          Radio({ value: this.item.name, group: this.item.g + this.item.name}).enabled(!this.disabled)
            .checked(this.item.name === this.selected)
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
            })
            .onClick(() => {
              this.selectProxy?.(this.item)
            })
        }
      }.width('100%')
      .padding({left:14,right:16})
    }else if (this.itemSize === ProxyCardSize.Mini){
      Row() {
        Column() {
          Text(`${this.item.name}`).ItemTextStyle()
          Row() {
            Text(`${this.item.type}`).ItemTypeStyle().maxLines(1).width('25%').textOverflow({ overflow: TextOverflow.Clip})
            Text(`${this.item.latency}` + 'ms')
              .fontColor(ProxyData.getColorForLatency(this.item.latency))
              .fontSize(14)
              .maxLines(1)
                // .width(this.isLandscapePhone ?'429px':'250px')
              .width('55%')
          }.justifyContent(FlexAlign.Start)
        }
        .alignItems(HorizontalAlign.Start)

        Blank()
        Radio({ value: this.item.name, group: this.item.g + this.item.name }).enabled(!this.disabled)
          .checked(this.item.name === this.selected)
          .radioStyle({
            checkedBackgroundColor: this.icon_emphasize,
          })
          .onClick(() => {
            this.selectProxy?.(this.item)
          })
      }
      .ListRowStyle()
    }else{
      Row() {
        Column() {
          Text(`${this.item.name}`).ItemTextStyle()//.width(this.isLandscapePhone ?'592px':'433px')
          Text(`${this.item.type}`).ItemTypeStyle()
          Blank(10)
          Text(`${this.item.latency}` + 'ms')
            //  Text(`${item.id }`)
            .fontColor(ProxyData.getColorForLatency(this.item.latency))
            .fontSize(16)
            .maxLines(1)
            .width('80%')
          // .width(this.isLandscapePhone ?'592px':'250px')
        }.alignItems(HorizontalAlign.Start)
        Blank()
        Radio({ value: this.item.name, group: this.item.g + this.item.name }).enabled(!this.disabled)
          .checked(this.item.name === this.selected)
          .radioStyle({
            checkedBackgroundColor: this.icon_emphasize,
          })
            // 不要用chang
          .onClick(() => {
            this.selectProxy?.(this.item)
          })
      }
      .ListRowStyle()
    }
  }

}