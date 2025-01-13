import { BreakpointState } from "../../../common/breakpointsystem"
import { ListOverwriteData, moreData } from "../../../common/Constants"
import moreListItem from "../MoreListItem"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { theRowCustomDialog } from "../../Common"
import { MoreTop } from "../MoreTopBuilder"

@Component
struct Overwrite {
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
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
      .padding({right: this.morePageMargin.value, left: this.morePageMargin.value})

      List() {
        ForEach(this.overwriteList, (item: moreData, index: number) => {
          ListItem() {
            moreListItem({
              index: index,
              itemObj: item,
              onCheck: (index: number) => {
                this.handleCheck(index)
              }
            })
          }
          .margin({bottom: this.listBottom.value })
        })

      }
      .width('100%')
      .height(500)
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
export default Overwrite