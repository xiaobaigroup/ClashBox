import { BreakpointState } from "../../common/breakpointsystem"
import { BORDER_RADIUS_20 } from "../../common/Constants"
import TopBuilder from "./TopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { AppConfig, ClashCore } from '../../entryability/AppState'
import ClashViewModel from '../../entryability/ClashViewModel'
import { promptAction } from "@kit.ArkUI"
import { ExperimentalFunction } from "../Common"
import { removeItemsByIndex } from "../../utils/RemoveItemsUtils"

interface KernelListItem {
  icons: Resource
  title: ResourceStr
  subtitle: ResourceStr
  isExperimental: boolean
  ClashCore: number
}

@Component
struct Kernel {
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 页面内边距
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>
  // 实验功能展示变量
  @Consume isShowExperimentalFunction: boolean
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @State private kernel: KernelListItem[] = [
    {icons: $rawfile('FlClash.svg'), title: 'FlClash', subtitle: $r('app.string.new_kernel'), isExperimental: false, ClashCore: ClashCore.FlClash},
    {icons: $rawfile('ClashMeta.svg'), title: $r('app.string.default_kernel'), subtitle: $r('app.string.old_kernel'), isExperimental: false, ClashCore: ClashCore.ClashMeta},
    {icons: $rawfile('ClashRS.svg'), title: 'ClashRS', subtitle: $r('app.string.new_kernel'), isExperimental: true, ClashCore: ClashCore.ClashRs}
  ]

  handleClick(index: number) {
    switch (index) {
      case 1:
        // ClashMeta
        this.appConfig.clashCore = ClashCore.ClashMeta
        ClashViewModel.ChangeCore(ClashCore.ClashMeta)
        hilog.info(0xFF00, "SettingsKerneltestTag", "当前内核：%{public}d", this.appConfig.clashCore)
        break
      case 0:
        // FlClash
        this.appConfig.clashCore = ClashCore.FlClash
        ClashViewModel.ChangeCore(ClashCore.FlClash)
        hilog.info(0xFF00, "SettingsKerneltestTag", "当前内核：%{public}d", this.appConfig.clashCore)
        break
      case 2:
        // ClashRS
        this.appConfig.clashCore = ClashCore.ClashRs
        ClashViewModel.ChangeCore(ClashCore.ClashRs)
        hilog.info(0xFF00, "SettingsKerneltestTag", "当前内核：%{public}d", this.appConfig.clashCore)
        break
    }
  }

  aboutToAppear(): void {
    if(!this.isShowExperimentalFunction) {
      // 话说好像我只用删除一个用splice好像也行
      this.kernel = removeItemsByIndex(this.kernel, [2])
    }
  }



  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.kernel')})
      Column({space: 10}) {
        Column() {
          ForEach(this.kernel, (item: KernelListItem, index: number) => {
            Row() {
              Image(item.icons)
                .width(48)
                .height(48)
              Column() {
                Row() {
                  Text(item.title)
                    .fontWeight(FontWeight.Bold)
                    .fontSize(16)
                  // 实验功能提示框
                  if(item.isExperimental) {
                    ExperimentalFunction()
                  }
                }
                Text(item.subtitle)
                  .fontWeight(FontWeight.Normal)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .maxLines(1)
                  .margin({ top: 2 })
                  .fontSize(14)
              }.margin({ left: 12 })
              .alignItems(HorizontalAlign.Start)
              Blank()
              Radio({ value: 'kernel' + index, group: 'kernelGroup' })
                .checked(item.ClashCore === this.appConfig.clashCore)
                .radioStyle({
                  checkedBackgroundColor: this.icon_emphasize,
                })
                .hitTestBehavior(HitTestMode.None)
            }
            .height(53)
            .width('100%')
            .onClick(() => {
              this.handleClick(index)
              promptAction.showToast({message: $r('app.string.switch_clashcore_tips'), duration: 2000 })
            })
            if ((this.isShowExperimentalFunction && (index === 0 || index === 1) || (index === 0 && this.isShowExperimentalFunction === false) )) {
              // 分割线
              Row().height(0.5).backgroundColor('#0D000000').width('93%').margin({top: 12, bottom: 12})
            }

          })

        }.padding(12)
        .backgroundColor($r('app.color.container_background'))
        .borderRadius(BORDER_RADIUS_20)
        .clickEffect({ level: ClickEffectLevel.MIDDLE })

        if(!this.isShowExperimentalFunction) {
          // 启用提示
          Text($r('app.string.open_core_prompt'))
            .fontWeight(FontWeight.Normal)
            .fontSize(15)
        } else {
          // 切换内核提示
          Text($r('app.string.switch_core_prompt'))
            .fontWeight(FontWeight.Normal)
            .fontSize(15)
        }

      }.alignItems(HorizontalAlign.Start)
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