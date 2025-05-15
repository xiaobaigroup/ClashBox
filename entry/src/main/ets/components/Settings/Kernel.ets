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
import { getResourceString } from "../../utils/ResourceStringUtil"
import { common } from "@kit.AbilityKit"

interface KernelListItem {
  icons: Resource
  title: string
  subtitle: ResourceStr
  isExperimental: boolean
  ClashCore: number
}

const context = getContext(this) as common.UIAbilityContext

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
    {icons: $rawfile('mihomo.png'), title: 'mihomo', subtitle: $r('app.string.new_kernel'), isExperimental: false, ClashCore: ClashCore.mihomo},
    {icons: $rawfile('mihomo.png'), title: "前台模式(mihomo)", subtitle: $r('app.string.switch_core_foreground_prompt'), isExperimental: false, ClashCore: ClashCore.ClashMeta},
    //{icons: $rawfile('ClashRS.svg'), title: 'ClashRS', subtitle: $r('app.string.new_kernel'), isExperimental: true, ClashCore: ClashCore.ClashRs}
  ]

  handleClick(index: number) {
    switch (index) {
      case 0:
        // mihomo
        this.appConfig.clashCore = ClashCore.mihomo
        ClashViewModel.ChangeCore(ClashCore.mihomo)
        hilog.info(0xFF00, "SettingsKerneltestTag", "当前内核：%{public}d", this.appConfig.clashCore)
        promptAction.showToast({message: $r('app.string.restart_tips'), duration: 2000 })
        setTimeout(() => {
          getContext(this)?.getApplicationContext().killAllProcesses()
        }, 2000)
        // 恢复更多页列表
        this.moreList = ListMoreData()
        // if (!this.uiConfig.isShowExperimentalFunction) {
        //   // 屏蔽分流策略
        //   this.moreList = removeItemsByIndex(this.moreList, [5])
        // }
        break
      case 1:
        // 前台模式
        this.appConfig.clashCore = ClashCore.ClashMeta
        ClashViewModel.ChangeCore(ClashCore.ClashMeta)
        this.uiConfig.backgroundPiPModel = true
        promptAction.showToast({message: $r('app.string.restart_tips'), duration: 2000 })
        setTimeout(() => {
          getContext(this)?.getApplicationContext().killAllProcesses()
        }, 2000)

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
      //this.kernel = removeItemsByIndex(this.kernel, [1])
    }
  }



  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.kernel')})
      Column({space:10}) {
        Column({space:8}){
          ForEach(this.kernel, (item: KernelListItem, index: number) => {
            Flex({
              direction: FlexDirection.Row,
              justifyContent: FlexAlign.Center,
              alignItems: ItemAlign.Center
            }) {
              Image(item.icons)
                .width(48)
                .height(48)
                .borderRadius(15)
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
                  .maxLines(2)
                  .margin({ top: 2 })
                  .fontSize(14)
              }
              .margin({ left: 12 })
              .constraintSize({maxWidth: '80%'})
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Center)
              .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
              Blank()
              Checkbox({ name: 'kernel' + index, group: item.title })
                .selectedColor(this.icon_emphasize)
                .select(item.ClashCore === this.appConfig.clashCore)
                .hitTestBehavior(HitTestMode.None)
            }.opacity(index !== 2 ? 1 : 0.5)
            .constraintSize({minHeight: 48, maxHeight: 72})
            .width('100%')
            .onClick(() => {
              this.handleClick(index)
            })
            if ((this.isShowExperimentalFunction && (index === 0 || index === 1) || (index === 0 && this.isShowExperimentalFunction === false) )) {
              if(!isEnd(this.kernel!.length,index))
                Row().height(0.5).backgroundColor($r('app.color.divider')).width('93%')
            }
          })
        }.padding(12)
        .width('100%')
        .backgroundColor($r('app.color.container_background'))
        .borderRadius(BORDER_RADIUS_20)
        .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))

        // if(!this.isShowExperimentalFunction) {
        //   // 启用提示
        //   Text($r('app.string.open_core_prompt'))
        //     .fontWeight(FontWeight.Normal)
        //     .fontSize(15)
        // } else {
        //
        // }
        // 切换内核提示
        Text($r('app.string.switch_core_prompt'))
          .fontWeight(FontWeight.Normal)
          .fontSize(15)

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