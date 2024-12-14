
import { BreakpointState } from "../../../common/breakpointsystem"
import { ListOverwriteDNSData,  moreData } from "../../../common/Constants"
import { hilog } from "@kit.PerformanceAnalysisKit"
import OverwriteTop from "./OverwriteTopBuilder"

// 编辑FakeIP范围弹窗
@CustomDialog
struct FakeIPCustomDialog {
  @Link SaveInputValue: string
  @Link currentInputValue: string
  cancel?: () => void
  confirm?: () => void
  controller: CustomDialogController

  build() {
    Column() {
      Text($r('app.string.Edit_FakeIP_Range'))
        .fontWeight(FontWeight.Medium)
        .fontSize(20)
        .margin({ top: 15, bottom: 15 })
      TextInput({placeholder: '例如：198.18.0.1/16', text: this.currentInputValue })
        .onChange((value: string) => {
          this.currentInputValue = value
        })
        .margin({bottom: 8 })
      Button($r('app.string.Save'))
        .width('100%')
        .height(39)
        .onClick(() => {
          this.SaveInputValue = this.currentInputValue
          this.controller.close()
          if (this.confirm) {
            this.confirm()
          }
        })
        .backgroundColor($r('app.color.speed_down_icon'))
        .fontColor(Color.White)
      Button($r('app.string.Cancel'))
        .height(39)
        .width('100%')
        .fontColor($r('app.color.speed_down_icon'))
        .backgroundColor($r('app.color.Dialog_BackgroundColor'))
        .onClick(() => {
          this.controller.close()
          if (this.cancel) {
            this.cancel()
          }
        })
    }
    .padding({left: 16, right: 16})
    .backgroundColor($r('app.color.Dialog_BackgroundColor'))
    .width('100%')
    .height(195)
  }
}

@Component
struct DNS {
  @Consume('NavPathStack') pageInfos: NavPathStack
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @State overwriteDNSList: moreData[] = ListOverwriteDNSData()
  @Consume('breakPointStatemorePagelistBottom') listBottom: BreakpointState<number>
  @State SaveInputValue: string = ''
  @State currentInputValue: string = ''
  // 弹窗控制器
  dialogController: CustomDialogController = new CustomDialogController({
    builder: FakeIPCustomDialog({
      currentInputValue: $currentInputValue,
      SaveInputValue: $SaveInputValue,
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onAccept() },
    }),
  })

  onCancel() {

  }
  onAccept() {
    // 更新UI数组中对应元素
    let FakeIPRangeData = this.overwriteDNSList[9]
    FakeIPRangeData.subtitle = this.SaveInputValue
    this.overwriteDNSList.splice(9,1,FakeIPRangeData)
    // 处理FakeIP范围变更

  }

  // 列表行点击事件处理
  handleCheck(index: number) {
    if(index === 9) {
      this.dialogController.open()
    } else {
      // 跳转
      let itemData = this.overwriteDNSList[index]
      this.pageInfos.pushPathByName(itemData.name, false)
    }
  }

  // DNS页面开关处理
  handleToggle(index: number) {
    switch (index) {
      case 0:
        // 覆写DNS
        hilog.info(0xFF00, "DNStestTag", "覆写DNS")

        break
      case 2:
        // 状态
        hilog.info(0xFF00, "DNStestTag", "状态")

        break
      case 3:
        // 使用Hosts
        hilog.info(0xFF00, "DNStestTag", "使用Hosts")

        break
      case 4:
        // 使用系统Hosts
        hilog.info(0xFF00, "DNStestTag", "使用系统Hosts")

        break
      case 5:
        // Ipv6
        hilog.info(0xFF00, "DNStestTag", "Ipv6")

        break
      case 6:
        // 遵守规则
        hilog.info(0xFF00, "DNStestTag", "遵守规则")

        break
      case 7:
        // 优先使用H3
        hilog.info(0xFF00, "DNStestTag", "优先使用H3")

        break
      case 17:
        // GeoIP
        hilog.info(0xFF00, "DNStestTag", "GeoIP")

        break
    }

  }

  build() {
    NavDestination() {
      // 导航栏
      OverwriteTop({
        title: $r('app.string.DNS'),
        subtitle: ''
      })

      List() {
        ForEach(this.overwriteDNSList, (item: moreData, index: number) => {
          if (item.sign === 0 ) {
            // 展开型
            ListItem() {
              Row() {
                Row() {
                  Text(item.title)
                    .fontWeight(FontWeight.Medium)
                    .fontSize(16)
                    .padding({ left: 12 })
                  Blank()
                  Text(item.subtitle)
                    .fontWeight(FontWeight.Normal)
                    .margin({top: 2 })
                    .fontSize(14)
                  SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
                    .fontSize(14)
                    .fontColor([$r('app.color.settings_container_background')])
                    .margin({left: 7, right: 20})
                }
                .width('94%')
                .height(53)
                .borderRadius(20)
                .backgroundColor($r('app.color.container_background'))
                Row()
                  .height(10)
              }
              .onClick(() => {
                this.handleCheck(index)
              })
            }
            .margin({bottom: this.listBottom.value })
          } else
            if (item.sign === 1 ) {
              // 跳转型
              ListItem() {
                Row() {
                  Row() {
                    Column() {
                      Text(item.title)
                        .fontWeight(FontWeight.Medium)
                        .fontSize(16)
                      if(index != 9 && index != 18 ) {
                        Text(item.subtitle)
                          .fontWeight(FontWeight.Normal)
                          .textOverflow({ overflow: TextOverflow.MARQUEE })
                          .maxLines(1)
                          .width('85%')
                          .margin({ top: 2 })
                          .fontSize(14)
                      }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .margin({ left: 12 })
                    Blank()
                    if(index === 9 || index === 18) {
                      Text(item.subtitle)
                        .fontWeight(FontWeight.Normal)
                        .margin({right: 4 })
                        .fontSize(14)
                    }
                    SymbolGlyph($r('sys.symbol.chevron_right'))
                      .fontSize(28)
                      .margin({right: 12})
                  }
                  .width('94%')
                  .height(53)
                  .borderRadius(20)
                  .backgroundColor($r('app.color.container_background'))
                  Row()
                    .height(10)
                }
                .onClick(() => {
                  this.handleCheck(index)
                })
              }
              .margin({bottom: this.listBottom.value })
            } else
            if (item.sign === 2 ) {
              // 开关型
              ListItem() {
                Row() {
                  Row() {
                    Text(item.title)
                      .fontWeight(FontWeight.Medium)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('86%')
                      .maxLines(1)
                      .fontSize(16)
                      .padding({ left: 12 })
                    Blank()
                    Toggle({ type: ToggleType.Switch, isOn: item.isCheck })
                      .margin({right: 12})
                      .onChange((isOn: boolean) => {
                        if(isOn) {
                          this.handleToggle(index)
                        }
                      })
                  }
                  .width('94%')
                  .height(53)
                  .borderRadius(20)
                  .backgroundColor($r('app.color.container_background'))
                  Row()
                    .height(10)
                }
                .onClick(() => {
                  this.handleCheck(index)
                })
              }
              .margin({bottom: this.listBottom.value })
            } else
            if (item.sign === 3) {
              // 标题栏
              ListItem() {
               Row() {
                 Row() {
                   Text(item.title)
                     .fontWeight(FontWeight.Normal)
                     .fontSize(16)
                   //.padding({ left: 12 })
                   Blank()
                 }
                 .width('94%')
                 .height(29)
                 Row()
                   .height(10)
               }
             }
            }

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
      this.pageInfos.clear();
      return true;
    })
  }
}
export default DNS