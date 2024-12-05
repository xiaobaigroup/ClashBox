
import { ProxyData } from "../common/ProxyListData"

@Component
struct ProcyListItem {
  @Prop itemObj: ProxyData
  @Prop index: number
  onCheck = (index: number) => {}

  build() {
    Row() {
      Text(this.itemObj.name)
        .fontColor(Color.Black)
        //.fontColor(this.itemObj.isCheck ? Color.Blue : Color.Gray)
      Blank()
      Checkbox({ name: 'checkbox', group: 'checkboxGroup' })
        .select(this.itemObj.isCheck)
        .selectedColor(0x39a2db)
        .shape(CheckBoxShape.ROUNDED_SQUARE)
        .onChange((value: boolean) => {
          console.info('Checkbox change is' + value)
          this.onCheck(this.index)
        })
    }
    .width(200)
    .height(48)
    .padding(5)
  }
}

export default ProcyListItem