import { BreakpointState } from "../../common/breakpointsystem"
import { ANIMATION_DURATION_300, BORDER_RADIUS_20 } from "../../common/Constants"
import TopBuilder from "./TopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"

@Component
struct Kernel {
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 开启测试内核
  @State isBetaKernel: boolean = false
  // 内核指代
  @State currenKernel: number = 0
  // 页面内边距
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.kernel')})
      Column() {
        // 测试版内核启用开关
        Row() {
          Column() {
            Text($r('app.string.beta_kernel'))
              .fontWeight(FontWeight.Medium)
              .fontSize(16)
            Text($r('app.string.beta_kernel_subtitle'))
              .fontWeight(FontWeight.Normal)
              .fontSize(14)
              .margin({top: 2})
          }
          .height(53)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 12 })
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: $$this.isBetaKernel })
            .selectedColor(this.icon_emphasize)
            .margin({right: 12})
            .onChange((isOn: boolean) => {
              // 开关测试版内核 显式动画 TODO 【用户首选项】保存测试版内核启用状态 Ya@2025-01-10
              this.getUIContext()?.animateTo({
                duration: ANIMATION_DURATION_300,
                curve: Curve.Ease
              }, () => {
                this.isBetaKernel = isOn
              })
            })
        }
        .width('100%')
        .backgroundColor($r('app.color.container_background'))
        .borderRadius(BORDER_RADIUS_20)
        .margin({bottom: 10 })
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .onClick(() => {
          // 展开测试版内核列表行 显式动画
          this.getUIContext()?.animateTo({
            duration: ANIMATION_DURATION_300
          }, () => {
            this.isBetaKernel = !this.isBetaKernel
          })
        })
        // 内核
        if(this.isBetaKernel) {
          Column() {
            // ClashMeta
            Row() {
              Text($r('app.string.default_kernel'))
              Blank()
              Radio({ value: 'kernel1', group: 'kernelGroup' })
                .checked(1 === this.currenKernel)
                .radioStyle({
                  checkedBackgroundColor: this.icon_emphasize,
                })
                .hitTestBehavior(HitTestMode.None)
            }
            .height(53)
            .width('100%')
            .padding({left: 12, right: 12})
            .onClick(() => {
              this.currenKernel = 1
              hilog.info(0xFF00, "SettingsKerneltestTag", "当前内核1：%{public}d", this.currenKernel)
            })
            // FlClash
            Row() {
              Text('FlClash')
              Blank()
              Radio({ value: 'kernel2', group: 'kernelGroup' })
                .checked(2 === this.currenKernel)
                .radioStyle({
                  checkedBackgroundColor: this.icon_emphasize,
                })
                .hitTestBehavior(HitTestMode.None)
            }
            .height(53)
            .width('100%')
            .padding({left: 12, right: 12})
            .onClick(() => {
              this.currenKernel = 2
              hilog.info(0xFF00, "SettingsKerneltestTag", "当前内核2：%{public}d", this.currenKernel)
            })
          }
          .backgroundColor($r('app.color.container_background'))
          .borderRadius(BORDER_RADIUS_20)
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
        }
      }
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
export default Kernel