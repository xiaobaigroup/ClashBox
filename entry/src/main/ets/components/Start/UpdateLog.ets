import { Xb_GetResourceString } from "xb_components"
import { PageMargin } from "../../common/breakpoint/BreakPoint"
import { TCItemProp } from "../../common/entity/Constants"
import { customAnimationUtil } from "../../common/utils/Animation"
import { AppState, UIConfig } from "../../entryability/AppState"
import TopBuilder from "../Settings/TopBuilder"

@Component
export struct UpdateLog {

  @State showBackButton: boolean = false
  @State updateLog: TCItemProp[] = UpdateLogData
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0

  build() {
    NavDestination() {
      TopBuilder({
        title: $r('app.string.update_log'),
        showBackButton: this.showBackButton
      })
      List({space: 10}) {
        // Logo&名称
        ListItem() {
          Column({space: 15}) {
            // logo
            Stack() {
              Image($r('app.media.background_white_large'))
                .borderRadius(25)
                .height(106)
                .zIndex(1)
              Image($r("app.media.foreground_box_cat_large"))
                .height(106)
                .zIndex(2)
            }
            // 名称
            Image($r("app.media.clash_box_blue"))
              .width(192)
            Text() {
              Span($r('app.string.current_version'))
              Span('：')
              Span(AppState.versionName)
            }
              .fontSize(15)
              .fontWeight(FontWeight.Normal)
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .width('100%')
          .borderRadius(20)
          .height(220)
        }
        // 更新日志
        ForEach(this.updateLog, (item: TCItemProp) => {
          ListItem() {
            Column() {
              // 项目
              Text(item.title)
                .fontSize(17)
                .fontWeight(FontWeight.Medium)
              // 内容
              Text(item.content)
                .fontSize(15)
                .margin({top: 2})
                .fontWeight(FontWeight.Normal)
            }
            .width('100%')
            .borderRadius(20)
            .backgroundColor($r('app.color.container_background'))
            .alignItems(HorizontalAlign.Start)
            .padding({top: 12, left: 10, right: 10})
            .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          }
        })
      }
      .width('100%')
      .alignListItem(ListItemAlign.Center)
      .contentEndOffset(86)
      .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.SettingsPageInfos.pop()
      return true
    })
  }

}

const UpdateLogData: TCItemProp[] = [
  // 名称：版本号+时间
  {
    title: '1.6.0 2025.09.01',
    content: '1.xxx \n2.xxx \n'
  },
  {
    title: '1.5.5 2025.09.01',
    content: '1.xxx \n2.xxx \n'
  },
  {
    title: '1.5.3 2025.09.01',
    content: '1.xxx \n2.xxx \n'
  },
  {
    title: '1.5.2 2025.09.01',
    content: '1.xxx \n2.xxx \n'
  },
  {
    title: '1.5.1 2025.09.01',
    content: '1.xxx \n2.xxx \n'
  },
  {
    title: '1.0.5 2025.09.01',
    content: '1.xxx \n2.xxx \n'
  },
]