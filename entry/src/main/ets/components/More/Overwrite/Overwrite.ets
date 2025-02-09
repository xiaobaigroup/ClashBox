import { BreakpointState } from "../../../common/breakpointsystem"
import { ListOverwriteData, moreData } from "../../../common/Constants"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { skipRowList, theRowCustomDialog } from "../../Common"
import { MoreTop } from "../MoreTopBuilder"
import { UIConfig } from "../../../entryability/AppState"
import { ClashConfig } from "proxy_core"
import { curves } from "@kit.ArkUI"

@Component
struct Overwrite {
  // 是否进入二级界面
  @Consume isSecondary: boolean
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @State overwriteList: moreData[] = ListOverwriteData()
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Consume('breakPointStatemorePagelistBottom') listBottom: BreakpointState<number>
  // 重置覆写提示弹窗标题
  @State theResetDialogTitle: ResourceStr = $r('app.string.override_reset_prompt')
  /**
   * 是否开启 `Index` 页面的前景模糊
   */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean

  /**
   * 重置覆写提示弹窗控制器
   */
  resetDialogController: CustomDialogController = new CustomDialogController({
    builder: theRowCustomDialog({
      theDialogTitle: this.theResetDialogTitle,
      cancel: ()=> { this.onresetCancel() },
      confirm: ()=> { this.onresetAccept() },
      leftButton: this.resetBuilder
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        // 点击遮蔽层不响应，防误触
      } else {
        // 通过dismiss主动关闭对话框
        dismissDialogAction.dismiss()
        // 关闭背景模糊
        this.isEnableIndexForegroundBlur = false
      }
    }
  })
  /**
   * 重置覆写提示弹窗左按钮
   */
  @Builder
  resetBuilder() {
    Button($r('app.string.reset'))
      .backgroundColor($r('app.color.container_background'))
      .width('100%')
      .height(39)
      .fontColor(Color.Red)
  }
  onresetCancel() {
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
  }
  onresetAccept() {
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
    // 重置覆写操作
    const newConfig = new ClashConfig()
    AppStorage.set("clashConfig", newConfig)

  }

  @Builder
  overwriteSearch() {
  }
  @Builder
  overwriteOther() {
  }

  handleCheck(index: number) {
    if(index === 3) {
      // 重置覆写弹窗
      this.isEnableIndexForegroundBlur = true
      this.resetDialogController.open()
    } else {
      // 跳转
      let itemData = this.overwriteList[index]
      this.pageInfos.pushPathByName(itemData.name, false)
      hilog.isLoggable(0xFF00, "OverwritetestTag", hilog.LogLevel.INFO);
      hilog.info(0xFF00, "OverwritetestTag", itemData.name)
    }
  }

  build() {
    NavDestination() {
      Row() {
        MoreTop({
          title: $r('app.string.Overwrite'),
          searchButton: this.overwriteSearch,
          otherButton: this.overwriteOther
        })
      }
      .width('100%')
      .transition(this.uiConfig.isAnimation ? TransitionEffect.OPACITY
        .animation({ duration: this.uiConfig.animationSpeed,curve:curves.springMotion(), delay: 0 })
        .combine(TransitionEffect.SLIDE) : null)

      List({space: 10}) {
        ForEach(this.overwriteList, (item: moreData, index: number) => {
          ListItem() {
            skipRowList({
              icons: item.icons,
              title: item.title,
              subtitle: item.subtitle,
              isPrimaryIcons: true
            })
          }.onClick(() => {
            this.handleCheck(index)
          })
          .transition(this.uiConfig.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: index*10+10 })
            .combine(TransitionEffect.scale({x: 0, y: 0})):null)
        })

      }
      .width('100%')
      .height(500)
      .margin({ top: 10 })
      .borderRadius(18)
      .alignListItem(ListItemAlign.Center)

    }
    .hideTitleBar(true)
    .padding({ left: this.morePageMargin.value, right: this.morePageMargin.value })
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      if(this.pageInfos.size() === 1) {
        this.pageInfos.clear()
        this.isSecondary = false
      } else {
        this.pageInfos.pop(true)
      }
      return true
    })
  }
}
export default Overwrite