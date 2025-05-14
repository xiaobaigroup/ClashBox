import TopBuilder from "./TopBuilder"
import { i18n } from "@kit.LocalizationKit"
import { LanguageData, LanguageListItem } from "../../common/Constants"
import { BreakpointState } from "../../common/breakpointsystem"
import { promptAction } from "@kit.ArkUI"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { ChangeLanguage } from "../../utils/ChangeLanguageUtil"
import { AppConfig, UIConfig } from "../../entryability/AppState"
import { customAnimationUtil } from "../../utils/Animation"

@Component
struct Language {
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @Consume currentLanguage: ResourceStr
  @State SystemLanguageSubtitle: ResourceStr = $r('app.string.SimplifiedChinese')
  @State private currentRadioCheck: number = -1
  @State SettingsLanguageList: LanguageData[] = LanguageListItem()
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @StorageLink ('isLandscapePhone') private isLandscapePhone: boolean = false
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  aboutToAppear(): void {
    // 初始化选择的Radio
    for (let i = 0; i < this.SettingsLanguageList.length; i++) {
      if (this.SettingsLanguageList[i].areaID === this.uiConfig.userLanguage) {
        this.currentRadioCheck = i
        break
      }
    }
  }

  FollowSystemHotChanage() {
    switch (i18n.System.getSystemLanguage()) {
      case 'zh-Hans-CN':
        // 简体中文
        ChangeLanguage('zh-Hans')
        this.currentLanguage = $r('app.string.Language_Subtitle')
      break
      default :
        // TODO 存在隐患，没有确定其它语言文本时函数返回值
        ChangeLanguage(i18n.System.getSystemLanguage())
    }
  }

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Language')})
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
            Radio({ value: 'language-1' , group: 'languageGroup' })
              .checked(this.currentRadioCheck === -1)
              .margin({right: 12 })
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
              })
              .hitTestBehavior(HitTestMode.None)
          }
          .width('94%')
          .height(53)
          .borderRadius(20)
          .backgroundColor($r('app.color.container_background'))
        }
        .margin({bottom: 10})
           .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
        .onClick(() => {
          // 点击整行对应单选框选中
           this.currentRadioCheck = -1
          // 恢复默认
          ChangeLanguage("default")
          this.uiConfig.userLanguage = "default"
          // promptAction.showToast({message: $r('app.string.restart_app_tips'), duration: 2000 })
          this.FollowSystemHotChanage()
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
                .radioStyle({
                  checkedBackgroundColor: this.icon_emphasize,
                })
                .hitTestBehavior(HitTestMode.None)
            }
            .width('94%')
            .height(53)
            .borderRadius(20)
            .backgroundColor($r('app.color.container_background'))
          }
          .margin({bottom: 10})
             .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .onClick(() => {
            // 点击整行对应单选框选中
            this.currentRadioCheck = index
            hilog.info(0xFF00, "SettingsLanguagetestTag", "当前选中：%{public}d", this.currentRadioCheck)
            // 改变语言
            ChangeLanguage(item.areaID)
            this.uiConfig.userLanguage = item.areaID
            if(index === 0) {
              this.currentLanguage = $r('app.string.Language_Subtitle')
            } else {
              this.currentLanguage = item.title
            }
          })
        })
      }
      .width('100%')
      .alignListItem(ListItemAlign.Center)
      .height(this.isLandscapePhone ? 275 : 800)
      .margin({ left: this.morePageMargin.value, right: this.morePageMargin.value })

    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.SettingsPageInfos.clear();
      return true;
    })
  }
}
export default Language