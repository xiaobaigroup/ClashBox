import { LengthMetrics, window } from "@kit.ArkUI";
import { FunctionInfo } from "../../common/entity/PageArgumentEntity";
import { customAnimationUtil } from "../../common/utils/Animation";
import { UIConfig } from "../../entryability/AppState";
import { ButtonBuilder, context, font_primary, icon_primary } from "./Common";
import { BusinessError } from "@kit.BasicServicesKit";
import { calculateFontSizeLinear } from "../../common/utils/CalculateFontSizeUtil";

let theWindowClass: window.Window

@Component
export struct TopBar {

  @Prop title: string
  @Prop iconSize: number
  @Prop icons: Resource[]
  @Prop titleFontSize: number

  @StorageProp('WindowMode') windowMode: boolean = false
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  onFClick: () => void = () => {}
  onSClick: () => void = () => {}
  onTClick: () => void = () => {}

  build() {
    Flex({
      direction: FlexDirection.Row,
      space: {main: LengthMetrics.vp(5)},
      justifyContent: FlexAlign.SpaceBetween
    })
    {
      Text(this.title)
        .fontColor(font_primary)
        .fontWeight(FontWeight.Bold)
        .margin({ top: this.windowMode ? 8 : 0})
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .transition(customAnimationUtil.isSlide(200, this.uiConfig))
        .fontSize(this.titleFontSize ?? calculateFontSizeLinear(this.title))
      // Text(`窗口模式 windowMode：${this.windowMode}`)
      Row({space: this.windowMode ? 0 : 10}) {
        // 按钮1
        if (this.icons.length >= 1) {
          ButtonBuilder({
            icon: this.icons[0],
            iconSize: this.iconSize,
            iconWeight: this.windowMode ? FontWeight.Bold : undefined,
            onCheck: () => { this.onFClick() }
          }).transition(customAnimationUtil.isSlide(100, this.uiConfig))
        }
        // 按钮2
        if (this.icons.length >= 2) {
          ButtonBuilder({
            icon: this.icons[1],
            iconSize: this.iconSize,
            iconWeight: this.windowMode ? FontWeight.Bold : undefined,
            onCheck: () => { this.onSClick() }
          }).transition(customAnimationUtil.isSlide(0, this.uiConfig))
        }
        // 按钮3
        if (this.icons.length >= 3) {
          ButtonBuilder({
            icon: this.icons[2],
            iconSize: this.iconSize,
            iconWeight: this.windowMode ? FontWeight.Bold : undefined,
            onCheck: () => { this.onTClick() }
          }).transition(customAnimationUtil.isSlide(0, this.uiConfig))
        }
        // 窗口控制按钮
        if (this.windowMode) {
          Row().width(109)
        }
      }
      .alignItems(this.windowMode ? VerticalAlign.Top : VerticalAlign.Center)
      // .justifyContent(FlexAlign.SpaceAround)
    }
    .margin({ right: 12, left: 12})
  }

}

@Component
export struct WindowTopBar {

  @State WindowMaximize: boolean = false
  @State windowClass: window.Window = theWindowClass
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  build() {
    Row() {
      ForEach(this.getWindowDecorButtonModel(), (item: FunctionInfo, index: number) => {
        ButtonBuilder({
          icon: item.icon,
          iconColor: icon_primary,
          enableTransition: false,
          iconSize: index == 0 && !this.WindowMaximize ? 15 : 18,
          iconWeight: index != 0 || this.WindowMaximize ? FontWeight.Bold : FontWeight.Regular,
          onCheck: item.onClick
        })
      })
    }
    .alignItems(VerticalAlign.Center)
  }

  aboutToAppear(): void {
    window.getLastWindow(getContext(this), (err, WindowClass) => {
      // 初始化WindowClass
      this.windowClass = WindowClass
    })
  }

  // 窗口控制器
  getWindowDecorButtonModel(): FunctionInfo[] {
    return [
      {
        icon: this.WindowMaximize ? $r('sys.symbol.arrow_down_right_and_arrow_up_left') : $r('sys.symbol.arrowshape_up_left_and_arrowshape_down_right'),
        onClick: async () => {
          console.log(`#WindowDecorButtonModel 点击最大&最小化按钮`)
          if (this.windowClass) {
            if (this.WindowMaximize) {
              console.log(`#WindowDecorButtonModel 即将最小化`)
              let promise = this.windowClass.recover()
              promise.then(() => {
                this.WindowMaximize = false
                console.info(`#WindowDecorButtonModel Succeeded in recover the window. ${this.WindowMaximize}`)
              }).catch((err: BusinessError) => {
                console.error(`#WindowDecorButtonModel 最小化失败：${err.code}, message: ${err.message}`)
              })
            } else {
              console.log(`#WindowDecorButtonModel 即将最大化`)
              try {
                this.windowClass.maximize()
                this.WindowMaximize = true
                console.info(`#WindowDecorButtonModel Succeeded in maximizing the window. ${this.WindowMaximize}`)
              } catch (err) {
                console.error(`#WindowDecorButtonModel 最大化失败：${err.code}, message: ${err.message}`)
              }
            }
          } else {
            console.error(`#WindowDecorButtonModel WindowClass不存在`)
          }
        }
      },
      {
        icon: $r('sys.symbol.minus'),
        onClick: async () => {
          this.windowClass.minimize()
        }
      },
      {
        icon: $r('sys.symbol.xmark'),
        onClick: () => {
          this.uiConfig.exitWindowMode === 1 ? getContext().getApplicationContext().killAllProcesses() : this.windowClass.minimize()
        }
      }
    ]
  }

}