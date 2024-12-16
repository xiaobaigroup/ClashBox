import TopBuilder from "./TopBuilder"
import { i18n } from "@kit.LocalizationKit"
import { LanguageData, LanguageListItem } from "../../common/Constants"
import { BreakpointState } from "../../common/breakpointsystem"
import { promptAction } from "@kit.ArkUI"

@Component
struct Language {
  @Link isShowSettings: boolean
  @State SystemLanguageSubtitle: ResourceStr = $r('app.string.SimplifiedChinese')
  @State private currentRadioCheck: number = -1
  @State SettingsLanguageList: LanguageData[] = LanguageListItem()
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary') //一级图标色，黑色
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Language'), /*isShowSettings: this.isShowSettings*/})
      List() {
        // 跟随系统语言
        ListItem() {
          Row() {
            Column() {
              Text($r('app.string.SystemLanguage'))
                .fontWeight(FontWeight.Medium)
                .fontSize(16)
              Text(this.SystemLanguageSubtitle)
                .fontWeight(FontWeight.Normal)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
                .margin({ top: 2 })
                .fontSize(14)
            }
            .margin({ left: 12 })
            .alignItems(HorizontalAlign.Start)
            Blank()
            Radio({ value: 'language' , group: 'languageGroup' })
              .checked(this.currentRadioCheck === -1)
              .margin({right: 12 })
          }
          .width('94%')
          .height(53)
          .borderRadius(20)
          .backgroundColor($r('app.color.container_background'))
        }
        .margin({bottom: 10})
        .onClick(() => {
          // 点击整行对应单选框选中
           this.currentRadioCheck = -1
          // 恢复默认
          i18n.System.setAppPreferredLanguage("default")
          promptAction.showToast({message: '重启应用生效', duration: 2000 })
        })
        ForEach(this.SettingsLanguageList, (item: LanguageData, index: number) => {
          // 语言列表
          ListItem() {
            Row() {
              Column() {
                Text(item.title)
                  .fontWeight(FontWeight.Medium)
                  .fontSize(16)
                Text(item.subtitle)
                  .fontWeight(FontWeight.Normal)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                  .margin({ top: 2 })
                  .fontSize(14)
              }
              .margin({ left: 12 })
              .alignItems(HorizontalAlign.Start)
              Blank()
              Radio({ value: 'language' + index, group: 'languageGroup' })
                .checked(index === this.currentRadioCheck)
                .margin({right: 12 })
            }
            .width('94%')
            .height(53)
            .borderRadius(20)
            .backgroundColor($r('app.color.container_background'))
          }
          .margin({bottom: 10})
          .onClick(() => {
            // 点击整行对应单选框选中
            this.currentRadioCheck = index
            // 修改语言
            i18n.System.setAppPreferredLanguage(item.areaID)
          })
        })
      }
      .width('100%')
      .alignListItem(ListItemAlign.Center)
      .height(this.isLandscapePhone ? 275 : 800)
      .margin({ left: this.morePageMargin.value, right: this.morePageMargin.value })

    }
    .hideTitleBar(true)
    .backgroundBlurStyle(BlurStyle.BACKGROUND_REGULAR)
    .onBackPressed(() => {
      this.SettingsPageInfos.clear();
      return true;
    })
  }
}
export default Language