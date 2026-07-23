import { customVibrator } from "../utils/Vibrator"
import { Xb_AnimationStyle } from "../utils/Animation"

// 统一数据接口
export interface SwitchButtonItem {
  text: ResourceStr;       // 主文本
  subText?: ResourceStr;   // 副文本（可选）
  symbol?: Resource;      // 图标（可选）
}

@ComponentV2
export struct Xb_SwitchButton {

  // 事件回调：用于通知父组件tab值变化
  @Event onClickUse: (index: number) => void

  @Param items: SwitchButtonItem[] = []
  // 状态控制参数：
  @Param @Require switchOne: number

  // 本地状态
  @Local currentButton: number = 0

  @Param WidthBp: number = 0
  @Param heightAll: Length = 40
  @Param borderRadiusAll: Length = 100
  @Param selectedColor: ResourceColor = $r("sys.color.font")

  private sliderOffset: string = ''

  build() {
    Row() {
      Stack() {
        // 滑块背景
        Button({ type: ButtonType.Normal })
          .id('singleButton')
          .translate({ x: this.sliderOffset })
          .animation(Xb_AnimationStyle.animNormalUtils(0))
          .width(`${100 / this.items.length}%`)
          .buttonSwitchStyles(2, this.WidthBp < 2 ? 14 : 16, $r('app.color.switch_button'), FontWeight.Medium)
          .offset({ right: this.currentButton === this.items.length - 1 ? 4 : 0 })
          .height(Number(this.heightAll) - 4)
          .borderRadius(Number(this.borderRadiusAll) - 2)

        // 按钮渲染区
        Row() {
          ForEach(this.items, (item: SwitchButtonItem, index: number) => {
            Column({ space: item.subText ? 4 : 0 }) {
              // 主内容行（图标 + 主文本）
              Row({ space: 4 }) {
                if (item.symbol) {
                  SymbolGlyph(item.symbol)
                    .fontSize(18)
                    .fontColor([this.currentButton === index ? this.selectedColor : $r("sys.color.icon_tertiary")])
                }
                Text(item.text)
                  .fontSize(this.WidthBp < 2 ? 14 : 16)
                  .fontWeight(this.currentButton === index ? FontWeight.Bold : FontWeight.Medium)
                  .fontColor(this.currentButton === index ? this.selectedColor : $r("sys.color.icon_tertiary"))
              }
              .alignItems(VerticalAlign.Center)
              .justifyContent(FlexAlign.Center)
              // 副文本
              if (item.subText) {
                Text(item.subText)
                  .fontSize(this.WidthBp < 2 ? 12 : 14)
                  .fontWeight(this.currentButton === index ? FontWeight.Bold : FontWeight.Medium)
                  .fontColor(this.currentButton === index ? this.selectedColor :$r('sys.color.multi_color_10'))
                  .opacity(this.currentButton === index ? 1 : 0.6)
              }

            }
            .width(`${100 / this.items.length}%`)
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .clickEffect(Xb_AnimationStyle.isClick())
            .onClick(() => {
              // 统一的点击处理逻辑
              this.handleClick(index)
            })
          }, (item: SwitchButtonItem) => item.text.toString())
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
      }
      .alignContent(Alignment.Start)
    }
    .width('100%')
    .height(this.heightAll)
    .borderRadius(this.borderRadiusAll)
    .clip(true)
    .backgroundColor($r("app.color.settings_switch_button_floor"))
  }

  // 监听父组件传入的 switchOne 变化 (受控模式)
  @Monitor('switchOne')
  onSwitchOneChange() {
    // 只有当 switchOne 被父组件赋值时，才同步覆盖本地状态
    if (this.switchOne !== undefined) {
      this.currentButton = this.switchOne
    }
    this.updateSliderOffset()
  }

  // 组件初始化
  aboutToAppear(): void {
    // 初始化时，如果有传入值则同步，否则默认为 0
    if (this.switchOne !== undefined) {
      this.currentButton = this.switchOne
    }
    this.updateSliderOffset()
  }

  // 统一处理点击事件
  handleClick(index: number) {
    // 触发振动
    customVibrator.vibratorTriggerOfHapticClockTimer()
    // 触发回调
    this.onClickUse(index)
    // 状态更新逻辑分支
    if (this.switchOne === undefined) {
      // --- 自治模式 ---
      // 组件本身更新状态并驱动动画
      this.currentButton = index
      this.updateSliderOffset()
    }
    // --- 受控模式 ---
    // 如果 switchOne 有值，此处无动作
    // 等待父组件接收到 onClickUse 事件后，修改 switchOne 的值，
    // 然后触发 @Monitor('switchOne') -> onSwitchOneChange -> 更新 currentButton -> 更新 offset
  }

  // 抽离滑块偏移量计算
  private updateSliderOffset() {
    this.sliderOffset = `${ 100 * this.currentButton }%`
  }

}

@Extend(Button)
function buttonSwitchStyles(m: number, fontSize: Length, bkColor: ResourceColor, fontWeight: FontWeight) {
  .margin(m)
  .fontSize(fontSize)
  .fontWeight(fontWeight)
  .backgroundColor(bkColor)
  .clickEffect(Xb_AnimationStyle.isClick())
}
