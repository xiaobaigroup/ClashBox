import { ProxyData } from "../common/ProxyListData"


@Component
struct ProxyListItem {
  @State font_primary: ResourceColor = $r('sys.color.font_primary') //一级文本色，黑色
  @State icon_emphasize: ResourceColor = $r('sys.color.icon_emphasize') //高亮图标，蓝色
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary') //二级图标色，灰色
  @State font_secondary: ResourceColor = $r('sys.color.font_secondary') //二级文本色，灰色
  @State color: ResourceColor = $r('sys.color.font_secondary')
  @Prop itemObj: ProxyData
  @Prop index: number
  onCheck = (index: number) => {
  }

  aboutToAppear(): void {
    // 假设我们有一个数值 value 和一个 Text 组件
    let value: number = this.itemObj.latency/* 获取你的数值 */;
    let color: Color;
    // 根据数值设定颜色
    if (value >= 0 && value <= 500) {
      this.color = '#64BB5C';
    } else if (value >= 501 && value <= 1000) {
      this.color = '#f7ce00';
    } else if (value >= 1001 ) {
      this.color = '#e84026';
    } else {
      this.color = ($r('sys.color.font_secondary')); // 默认颜色
    }
  }


  build() {
    Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, }) {
      Row() {
        Row() {
          Column() {
            Text(this.itemObj.name)
              .fontSize(20)
              .width('100%')
              .fontColor(this.font_primary)
            //   .textAlign(TextAlign.Start)
            Text(this.itemObj.passage)
              .fontSize(14)
              .width('100%')
              .fontColor(this.font_secondary)
          }

          Text(this.itemObj.latency.toString() + 'ms')
            .fontSize(18)//    .width('90%')
            .fontColor(this.color)
            .textAlign(2)
            .width('45%')
        }
        .padding({ right: 95 })
        .width('100%')

     //   .justifyContent(FlexAlign.End)

        Radio({
          value: 'Radio', group: 'radioGroup',
          indicatorType: RadioIndicatorType.TICK
        })
          .checked(false)
          .radioStyle({
            checkedBackgroundColor: this.icon_emphasize,
            //   uncheckedBorderColor: this.icon_secondary
          })

          .height(20)
          .width(20)
          .onChange((isChecked: boolean) => {
            console.info('Radio2 change is' + isChecked)
            this.onCheck(this.index)
          })
      }
      // .padding({  right: 12})
      .height(58)
      .width('92%')

      //     .alignItems(VerticalAlign.Center)
      //    .justifyContent(FlexAlign.SpaceBetween)
      //   .backgroundColor($r('app.color.background'))
    }
  }
}


export default ProxyListItem