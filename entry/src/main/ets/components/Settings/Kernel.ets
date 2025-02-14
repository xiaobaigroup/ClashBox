import { BreakpointState } from "../../common/breakpointsystem"
import { BORDER_RADIUS_20, ListMoreData, moreData } from "../../common/Constants"
import TopBuilder from "./TopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { AppConfig, ClashCore, isEnd, UIConfig } from '../../entryability/AppState'
import ClashViewModel from '../../entryability/ClashViewModel'
import { promptAction } from "@kit.ArkUI"
import { ExperimentalFunction } from "../Common"
import { removeItemsByIndex } from "../../utils/RemoveItemsUtils"
import { customAnimationUtil } from "../../utils/Animation"

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
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 实验功能展示变量
  @Consume isShowExperimentalFunction: boolean
  // 更多页列表数组
  @Consume moreList: moreData[]
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
        // 屏蔽请求与连接
        this.moreList = removeItemsByIndex(this.moreList, [2,3])
        break
      case 0:
        // FlClash
        this.appConfig.clashCore = ClashCore.FlClash
        ClashViewModel.ChangeCore(ClashCore.FlClash)
        hilog.info(0xFF00, "SettingsKerneltestTag", "当前内核：%{public}d", this.appConfig.clashCore)
        // 恢复更多页列表
        this.moreList = ListMoreData()
        if (!this.uiConfig.isShowExperimentalFunction) {
          // 屏蔽分流策略
          this.moreList = removeItemsByIndex(this.moreList, [5])
        }
        break
      case 2:
        promptAction.showToast({message: $r('app.string.developing'), duration: 2000 })
        // ClashRS
        // this.appConfig.clashCore = ClashCore.ClashRs
        // ClashViewModel.ChangeCore(ClashCore.ClashRs)
        // hilog.info(0xFF00, "SettingsKerneltestTag", "当前内核：%{public}d", this.appConfig.clashCore)
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
      Column({space:10}) {
Column({space:8}){
          ForEach(this.kernel, (item: KernelListItem, index: number) => {
            Row() {
              Image(item.icons)
                .width(48)
                .height(48)
                .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                .transition(customAnimationUtil.isScaleTranIcon(10,this.uiConfig))
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
               .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
              Blank()
              Radio({ value: 'kernel' + index, group: 'kernelGroup' })
                .checked(item.ClashCore === this.appConfig.clashCore)
                .radioStyle({
                  checkedBackgroundColor: this.icon_emphasize,
                })
                .hitTestBehavior(HitTestMode.None)
            }.opacity(index !== 2 ? 1 : 0.5)
            .height(72)
            .width('100%')
            .padding({top:12,bottom:12})
            .onClick(() => {
              this.handleClick(index)
              if(index !== 2) {
                promptAction.showToast({message: $r('app.string.switch_clashcore_tips'), duration: 2000 })
              }
            })
            if ((this.isShowExperimentalFunction && (index === 0 || index === 1) || (index === 0 && this.isShowExperimentalFunction === false) )) {
             if(!isEnd(this.kernel!.length,index))
                Row().height(0.5).backgroundColor($r('app.color.divider')).width('93%')
            }
          })
        }.padding(12)
        .backgroundColor($r('app.color.container_background'))
        .borderRadius(BORDER_RADIUS_20)
         .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))

        ///Blank(10)
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
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.SettingsPageInfos.clear();
      return true;
    })
  }
}
export default Kernel