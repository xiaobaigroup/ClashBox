import { BreakpointState } from "../../common/breakpointsystem"
import TopBuilder from "./TopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { ExperimentalFunction, theRowCustomDialog, toggleRowList } from "../Common"
import { UIConfig } from "../../entryability/AppState"


@Component
struct Backgrounder {
  // UI控制变量
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 模拟播放控制变量
  @State isPlay: boolean = false
  // 模拟录音控制变量
  @State isRecord: boolean = false
  // 实验功能展示变量
  @Consume isShowExperimentalFunction: boolean
  // 模拟下载关闭提示弹窗标题
  @State theColsedDialogTitle: ResourceStr = $r('app.string.simulate_download_closed_tips')
  // 模拟下载关闭提示弹窗内容文本
  @State closedContentText: ResourceStr = $r('app.string.simulate_download_closed_content_text')
  // 模拟录音启用提示弹窗标题
  @State theOpenDialogTitle: ResourceStr = $r('app.string.simulate_record_open_tips')
  // 模拟录音启用提示弹窗内容文本
  @State openContentText: ResourceStr = $r('app.string.simulate_record_open_content_text')
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>

  /**
   * 关闭模拟下载提示弹窗控制器
   */
  closeDialogController: CustomDialogController = new CustomDialogController({
    builder: theRowCustomDialog({
      theDialogTitle: this.theColsedDialogTitle,
      contentText: this.closedContentText,
      cancel: ()=> { this.oncloseCancel() },
      confirm: ()=> { this.oncloseAccept() },
      leftButton: this.closedBuilder
    }),
  })
  /**
   * 模拟下载关闭提示弹窗左按钮
   */
  @Builder
  closedBuilder() {
    Button($r('app.string.close'))
      .backgroundColor($r('app.color.container_background'))
      .width('100%')
      .height(39)
      .fontColor(Color.Red)
  }
  // 模拟下载关闭提示弹窗-取消
  oncloseCancel() {
    // 将模拟下载设置为 true
    this.uiConfig.backgroundDownModel = true
  }
  // 模拟下载关闭提示弹窗-关闭
  oncloseAccept() {
    // 将模拟下载设置为 false
    this.uiConfig.backgroundDownModel = false
    hilog.info(0xFF00, "BackgrounderSwitchtestTag", "模拟下载设置为: %{public}s", this.uiConfig.backgroundDownModel)
    // 关闭模拟下载逻辑处理
    hilog.info(0xFF00, "BackgroundertestTag", "模拟下载正在关闭")
    this.onCloseDown()
  }

  /**
   * 启用模拟模拟录音提示弹窗控制器
   */
  openDialogController: CustomDialogController = new CustomDialogController({
    builder: theRowCustomDialog({
      theDialogTitle: this.theOpenDialogTitle,
      contentText: this.openContentText,
      cancel: ()=> { this.onopenCancel() },
      confirm: ()=> { this.onopenAccept() }
    }),
  })
  // 模拟录音启用提示弹窗-取消
  onopenCancel() {
    // 将模拟录音设置为 false
    this.isRecord = false
    hilog.info(0xFF00, "BackgrounderSwitchtestTag", "模拟录音设置为: %{public}s", this.isRecord)
  }
  // 模拟录音启用提示弹窗-启用
  onopenAccept() {
    // 将模拟录音设置为 true
    this.isRecord = true
    // 关闭其它两个模拟
    if(this.uiConfig.backgroundDownModel) {
      // 关闭模拟下载
      this.oncloseAccept()
    } else if (this.isPlay) {
      // 关闭模拟播放
      this.isPlay = false
    }
    // 启用模拟录音逻辑处理
    hilog.info(0xFF00, "BackgroundertestTag", "模拟录音正在开启")
    this.onOpenRecord()
  }

  /**
   * 启用模拟下载
   */
  onOpenDown() {
    this.uiConfig.backgroundDownModel = true
  }
  /**
   * 关闭模拟下载
   */
  onCloseDown() {
    this.uiConfig.backgroundDownModel = false
  }
  /**
   * 启用模拟播放
   */
  onOpenPlay() {

  }
  /**
   * 关闭模拟播放
   */
  onClosePlay() {

  }
  /**
   * 启用模拟录音
   */
  onOpenRecord() {

  }
  /**
   * 关闭模拟录音
   */
  onCloseRecord() {

  }

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Backgrounder')})
      Column({space: 10}) {
        // 模拟下载
        Row() {
          toggleRowList({
            icons: $r('sys.symbol.arrow_down_circle'),
            title: $r('app.string.simulate_download'),
            subtitle: $r('app.string.simulate_download_subtitle')
          }) {
            Toggle({ type: ToggleType.Switch, isOn: $$this.uiConfig.backgroundDownModel })
              .selectedColor(this.icon_emphasize)
              .margin({right: 12})
              .hitTestBehavior(HitTestMode.None)
          }
        }.onClick(() => {
          if(this.uiConfig.backgroundDownModel) {
            // 打开模拟下载关闭提示弹窗
            if(!this.isPlay && !this.isRecord) {
              this.closeDialogController.open()
            }
          } else {
            // 关闭其它两个模拟并开启模拟下载
            this.isPlay = false
            this.isRecord = false
            this.uiConfig.backgroundDownModel = true
          }
        })
        if(this.isShowExperimentalFunction) {
          // 模拟播放
          Row() {
            toggleRowList({
              icons: $r('sys.symbol.media_center'),
              title: $r('app.string.simulate_player'),
              subtitle: $r('app.string.simulate_player_subtitle'),
              isExperimentalFunction: true
            }) {
              Toggle({ type: ToggleType.Switch, isOn: $$this.isPlay })
                .selectedColor(this.icon_emphasize)
                .margin({right: 12})
                .hitTestBehavior(HitTestMode.None)
            }
          }.onClick(() => {
            if(this.isPlay) {
              // 关闭模拟播放
              this.isPlay = false
            } else {
              // 关闭其它两个模拟并开启模拟播放
              this.uiConfig.backgroundDownModel = false
              this.isRecord = false
              // 开启
              this.isPlay = true
            }
          })
          // 模拟录音
          Row() {
            toggleRowList({
              icons: $r('sys.symbol.mic_circle'),
              title: $r('app.string.simulate_record'),
              subtitle: $r('app.string.simulate_record_subtitle'),
              isExperimentalFunction: true
            }) {
              Toggle({ type: ToggleType.Switch, isOn: $$this.isRecord })
                .selectedColor(this.icon_emphasize)
                .margin({right: 12})
                .hitTestBehavior(HitTestMode.None)
            }
          }.onClick(() => {
            if(this.isRecord) {
              // 模拟录音关闭
              this.isRecord = false
            } else {
              // 打开模拟录音启用提示弹窗
              this.openDialogController.open()
            }
          })
          // 提示
          Text($r('app.string.backgrounder_tips'))
            .fontWeight(FontWeight.Normal)
            .fontSize(15)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: this.breakPointStatemorePageMargin.value, right: this.breakPointStatemorePageMargin.value })
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.SettingsPageInfos.clear();
      return true;
    })
  }

  aboutToDisappear(): void {
    // 改变后台运行全局变量的状态
    if(this.uiConfig.backgroundDownModel || this.isPlay || this.isRecord) {
      this.uiConfig.Enablebackgrounder = true
    } else {
      this.uiConfig.Enablebackgrounder = false
    }
  }

}
export default Backgrounder

/**
 * 开关列表行通用组件
 */
@Component
struct RowList {
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @State icons: Resource = $r('sys.symbol.arrow_down_circle')
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @State title: ResourceStr = ''
  @State subtitle: ResourceStr = ''
  @State subtitle2: ResourceStr = ''
  @BuilderParam switchToggle: () => void = this.defaultBuilder
  // 默认开关
  @Builder
  defaultBuilder() {
    Toggle({ type: ToggleType.Switch, isOn: false })
      .selectedColor(this.icon_emphasize)
      .margin({right: 12})
  }

  build() {
    Row() {
      SymbolGlyph(this.icons)
        .fontSize(24)
        .margin({left: 12})
        .fontColor([this.icon_emphasize])
      Column() {
        Row() {
          Text(this.title)
            .fontWeight(FontWeight.Medium)
            .fontSize(16)
          // 实验功能提示框
          if(this.subtitle2) {
            ExperimentalFunction()
          }

        }
        Text(this.subtitle)
          .fontWeight(FontWeight.Normal)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .margin({top: 2})
          .fontSize(14)
          .width('65%')
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      Blank()
      this.switchToggle()
    }
    .width('100%')
    .height(53)
    .borderRadius(20)
    .margin({bottom: 10})
    .backgroundColor($r('app.color.container_background'))
      .clickEffect(this.uiConfig.isAnimation ? { level: ClickEffectLevel.MIDDLE, scale: 0.8} : null)
  }
}