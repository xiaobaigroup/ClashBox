import { BreakpointState } from "../../../common/breakpoint/breakpointsystem"
import { BORDER_RADIUS_20, ListOverwriteData, moreData, TAB_CONTENT_TITLE_HEIGHT } from "../../../common/entity/Constants"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { skipRowList, theRowCustomDialog } from "../../Common/Common"
import { MoreTop } from "../MoreTopBuilder"
import { AppState, UIConfig } from "../../../entryability/AppState"
import { ClashConfig } from "proxy_core"
import { curves } from "@kit.ArkUI"
import { customAnimationUtil } from "../../../common/utils/Animation"
import OverwriteTop from "./OverwriteTopBuilder"
import { NeedClearMoreStack, PageMargin } from "../../../common/breakpoint/BreakPoint"

@Component
struct Overwrite {
  // 是否进入二级界面
  @Consume isSecondary: boolean
  @Consume('NavPathStack') pageInfos: NavPathStack
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @State overwriteList: moreData[] = ListOverwriteData()
  // 重置覆写提示弹窗标题
  @State theResetDialogTitle: ResourceStr = $r('app.string.override_reset_prompt')
  /**
   * 是否开启 `Index` 页面的前景模糊
   */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  //page内顶部标题偏移量
  @Consume curYOffset: number

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
    AppState.ResetClashConfig()
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
      Stack() {
            MoreTop({
              title: $r('app.string.Overwrite'),
            })

        Column() {
          Blank().height(TAB_CONTENT_TITLE_HEIGHT + 6)
          Scroll() {
            List({ space: 10 }) {
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
                .transition(customAnimationUtil.isScaleTran(index, this.uiConfig))
              })
              // 重启应用提示
              ListItem() {
                Text($r('app.string.overwrite_restart_tips'))
                  .fontColor($r('sys.color.font_secondary'))
                  .fontWeight(FontWeight.Normal)
                  .fontSize(14)
              }.transition(customAnimationUtil.isScaleTran(4, this.uiConfig))
            }
            .width('100%')
            .height('100%')
            .borderRadius(BORDER_RADIUS_20)
            .alignListItem(ListItemAlign.Center)
            .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
            .chainAnimation(true)
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            })
          }
          .edgeEffect(this.uiConfig.isAnimation?EdgeEffect.Spring:null)//,{alwaysEnabled:true})
          .onDidScroll((xOffset: number, yOffset: number): void => {
            // 累计计算当前父组件滚动在Y轴方向的偏移量
            if (this.uiConfig.isAnimation){
              this.curYOffset += yOffset
            }
            console.info("yOffset" + this.curYOffset);
          })
        }
      }
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      if(this.pageInfos.size() === 1) {
        if (NeedClearMoreStack(this.widthBp, this.heightBp)) {
          this.pageInfos.clear()
        }
        this.isSecondary = false
      } else {
        this.pageInfos.pop(true)
      }
      return true
    })
  }
}
export default Overwrite