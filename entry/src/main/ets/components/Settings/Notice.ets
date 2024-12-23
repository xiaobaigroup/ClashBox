import { BreakpointState } from "../../common/breakpointsystem"
import { NoticeList, NoticeListItemProp } from "../../common/Constants"
import TopBuilder from "./TopBuilder"

@Component
struct Notice {
  @Link isShowSettings: boolean
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  @State noticeList: NoticeListItemProp[] = NoticeList
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>
  @State Enablednotice: boolean = false

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Notice')})
      Column() {
        // 通知总开关
        Row() {
          SymbolGlyph($r('sys.symbol.message_on_message_fill'))
            .fontSize(24)
            .margin({left: 12})
            .fontColor([this.icon_emphasize])
          Text($r('app.string.notice_main_switch'))
            .fontWeight(FontWeight.Medium)
            .fontSize(16)
          Blank()
          // 后台通知开关
          Toggle({ type: ToggleType.Switch, isOn: this.Enablednotice })
            .selectedColor(this.icon_emphasize)
            .margin({right: 12})
            .onChange((isOn: boolean) => {
              if(isOn) {
                this.Enablednotice = true
              } else {
                this.Enablednotice = false
              }
            })
        }
        .RowStyle()
        if(this.Enablednotice) {
          ForEach(this.noticeList, (item: NoticeListItemProp, index: number) => {
            Row() {
              SymbolGlyph(item.icons)
                .fontSize(24)
                .margin({left: 12})
                .fontColor([this.icon_emphasize])
              Column() {
                Text(item.title)
                  .fontWeight(FontWeight.Medium)
                  .fontSize(16)
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
              if(index === 0) {
                // 后台通知开关
                Toggle({ type: ToggleType.Switch, isOn: item.isOn })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .onChange((isOn: boolean) => {
                    // 逻辑处理

                  })
              } else {
                // 流量&时间提醒
                Text(item.subtitle2)
                  .fontWeight(FontWeight.Normal)
                  .margin({right: 4 })
                  .fontSize(14)
                SymbolGlyph($r('sys.symbol.chevron_right'))
                  .fontSize(28)
                  .margin({right: 12})
                  .fontColor([this.icon_primary])
              }
            }
            .RowStyle()
            .onClick(() => {
              // 流量&时间提醒
              if(index != 0) {
                // 逻辑处理

              }
            })
          })
        }
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
export default Notice

// 列表行共有样式
@Extend(Row)
function RowStyle() {
  .width('100%')
  .height(53)
  .borderRadius(20)
  .margin({bottom: 10})
  .backgroundColor($r('app.color.container_background'))
}