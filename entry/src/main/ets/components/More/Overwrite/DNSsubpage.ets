import { BreakpointState } from "../../../common/breakpointsystem"
import { theCustomDialog } from "./Network"
import OverwriteTop from "./OverwriteTopBuilder"

// DNS -> FakeIP过滤
@Component
export struct FakeIPfilter {

  @State SaveInputValue: string = ''
  @State currentInputValue: string = ''
  @State theplaceholder: string = '请输入内容'
  @State theDialogTitle: ResourceStr = $r('app.string.Add_FakeIPfilter')
  @State FakeIPfilterList: FakeIPfilterData[] = createFakeIPfilterData()
  @Consume('NavPathStack') pageInfos: NavPathStack
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @Consume('breakPointStatemorePagelistBottom') listBottom: BreakpointState<number>

  // FakeIP过滤弹窗控制器
  dialogController: CustomDialogController = new CustomDialogController({
    builder: theCustomDialog({
      theplaceholder: this.theplaceholder,
      currentInputValue: $currentInputValue,
      SaveInputValue: $SaveInputValue,
      theDialogTitle: this.theDialogTitle,
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onAccept() },
    }),
  })

  onCancel() {

  }
  onAccept() {
    // 更新UI数组中对应元素
    const newItem: FakeIPfilterData = new FakeIPfilterData(this.SaveInputValue, false)
    this.FakeIPfilterList = [...this.FakeIPfilterList, newItem]

  }

  // 列表行删除
  handleDelete(index: number) {
    this.FakeIPfilterList.splice(index, 1)
  }

  build() {
    NavDestination() {
      // 导航栏
      OverwriteTop({
        title: $r('app.string.Network'),
        subtitle: $r('app.string.Routing_Address')
      })

      List() {
        ForEach(this.FakeIPfilterList, (item: FakeIPfilterData, index: number) => {
          // 数据列表行
          ListItem() {
            Row() {
              Row() {
                Text(item.name)
                  .fontWeight(FontWeight.Medium)
                  .fontSize(16)
                  .margin({left: 12})
                Blank()
                SymbolGlyph($r('sys.symbol.trash_fill'))
                  .fontSize(28)
                  .margin({right: 12})
                  .onClick(() => {
                    this.handleDelete(index)
                  })
              }
              .width('94%')
              .height(53)
              .borderRadius(20)
              .backgroundColor($r('app.color.container_background'))
              Row()
                .height(10)
            }

          }
          .margin({bottom: this.listBottom.value })
        })

        // 添加栏
        ListItem() {
          Row() {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(28)
              .margin({left: 12, right: 16})
            Text($r('app.string.Add'))
              .fontWeight(FontWeight.Medium)
              .fontSize(16)
          }
          .width('94%')
          .height(53)
          .borderRadius(20)
          .backgroundColor($r('app.color.container_background'))
        }
        .onClick(() => {
          this.dialogController.open()
        })

      }
      .width('100%')
      .height(this.isLandscapePhone ? 275 : 650)
      .margin({ top: 10, left: this.morePageMargin.value, right: this.morePageMargin.value })
      .borderRadius(18)
      .alignListItem(ListItemAlign.Center)


    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.pageInfos.pop(true);
      return true;
    })
  }
}

// FakeIP过滤列表数据类
class FakeIPfilterData {
  name: string
  isCheck: boolean

  constructor(name: string, isCheck:boolean) {
    this.name = name
    this.isCheck = isCheck
  }
}

// 数据
const createFakeIPfilterData = (): FakeIPfilterData[] => {
  let result: FakeIPfilterData[] = new Array()
  result = [
    new FakeIPfilterData('lens.l.google.com', false),
    new FakeIPfilterData('+stun.*.*.*', false),
    new FakeIPfilterData('*.*.xboxlive.com', false),
    new FakeIPfilterData('值', false),

  ]
  return result
}
