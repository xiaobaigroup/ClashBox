
import { BreakpointState } from "../../../common/breakpointsystem"
import { ListOverwriteDNSData,  moreData } from "../../../common/Constants"
import { hilog } from "@kit.PerformanceAnalysisKit"
import OverwriteTop from "./OverwriteTopBuilder"

@Component
struct DNS {
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('morePageMargin') morePageMargin: BreakpointState<number>
  @State overwriteDNSList: moreData[] = ListOverwriteDNSData()
  @Consume('listBottom') listBottom: BreakpointState<number>

  handleCheck(index: number) {
    // 跳转
    let itemData = this.overwriteDNSList[index]
    this.pageInfos.pushPathByName(itemData.name, false)
  }
  // 开关处理
  handleToggle(index: number) {
    switch (index) {
      case 6:
        // IPv6状态切换
        hilog.info(0xFF00, "BasictestTag", "IPv6")

        break
      case 7:
        // 统一延迟实现
        hilog.info(0xFF00, "BasictestTag", "统一延迟")

        break
      case 8:
        // TCP并发切换
        hilog.info(0xFF00, "BasictestTag", "TCP并发")

        break
      case 9:
        // 外部控制实现
        hilog.info(0xFF00, "BasictestTag", "外部控制")

        break
    }

  }

  build() {
    NavDestination() {
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
                    Text(item.title)
                      .fontWeight(FontWeight.Medium)
                      .fontSize(16)
                      .padding({ left: 12 })
                    Blank()
                    Text(item.subtitle)
                      .fontWeight(FontWeight.Normal)
                      .margin({right: 4 })
                      .fontSize(14)
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
      .height(650)
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