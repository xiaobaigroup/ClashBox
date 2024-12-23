import { BreakpointState } from "../../common/breakpointsystem"
import { BackgroundList, BackgroundListItemProp } from "../../common/Constants"
import TopBuilder from "./TopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"

@Component
struct Backgrounder {
  // 实验功能提示框展示变量
  @Consume isShowExperimentalFunction: boolean
  @State backgrounderList: BackgroundListItemProp[] = BackgroundList
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>

  // 列表行开关事件处理
  handleToggle(isOn: boolean, index: number) {
    switch (index) {
      case 0:
        // 模拟下载
        hilog.info(0xFF00, "BackgroundertestTag", "模拟下载")
        if(isOn) {
          // 开启

        } else {
          // 关闭

        }
        break
      case 1:
        // 模拟播放
        hilog.info(0xFF00, "BackgroundertestTag", "模拟播放")
        if(isOn) {
          // 开启

        } else {
          // 关闭

        }
      break
      case 2:
        // 模拟录音
        hilog.info(0xFF00, "BackgroundertestTag", "模拟录音")
        if(isOn) {
          // 开启

        } else {
          // 关闭

        }
      break
    }
  }

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Backgrounder')})
      Column() {
        ForEach(this.backgrounderList, (item: BackgroundListItemProp, index: number) => {
          Row() {
            SymbolGlyph(item.icons)
              .fontSize(24)
              .margin({left: 12})
              .fontColor([this.icon_emphasize])
            Column() {
              Row() {
                Text(item.title)
                  .fontWeight(FontWeight.Medium)
                  .fontSize(16)
                if(this.isShowExperimentalFunction) {
                  // 实验功能提示框
                  if(item.subtitle2) {
                    Column() {
                      Text(item.subtitle2)
                        .fontColor(Color.White)
                        .fontSize(10)
                    }
                    .alignItems(HorizontalAlign.Center)
                    .justifyContent(FlexAlign.Center)
                    .width(50)
                    .height(18)
                    .borderRadius(4)
                    .margin({left: 2})
                    .backgroundColor(this.icon_emphasize)
                  }
                }
              }
              Text(item.subtitle)
                .fontWeight(FontWeight.Normal)
                .textOverflow({ overflow: TextOverflow.MARQUEE })
                .maxLines(1)
                .margin({top: 2})
                .fontSize(14)
                .width('65%')
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: false })
              .selectedColor(this.icon_emphasize)
              .margin({right: 12})
              .onChange((isOn: boolean) => {
                this.handleToggle(isOn, index)
              })
          }
          .width('100%')
          .height(53)
          .borderRadius(20)
          .margin({bottom: 10})
          .backgroundColor($r('app.color.container_background'))
        })
        // 提示
        Text($r('app.string.backgrounder_tips'))
          .fontWeight(FontWeight.Normal)
          .fontSize(15)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: this.breakPointStatemorePageMargin.value, right: this.breakPointStatemorePageMargin.value })
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.SettingsPageInfos.clear();
      return true;
    })
  }
}
export default Backgrounder