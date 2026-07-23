import { Xb_AnimationStyle } from "../utils/Animation"
import { customVibrator } from "../utils/Vibrator"
import { Xb_CircleButton } from "./Xb_Button"
import { colorChange } from "./Common"
import { MenuItem } from "../settings/SettingsCommonOp"
import { Xb_Menu } from "./Xb_Menu"
import { BORDER_RADIUS_20 } from "./Constants"

// 通用组件#顶部标题组件
@ComponentV2
export struct Xb_TopTitleBar {

  @Param buttonMenuList: MenuItem[] = []
  @Param buttonIndexHasMenu: number = -1
  @Param name: string | Resource = ''
  @Param fontColor: ResourceColor = ''

  @Param windowMode: boolean = false
  @Param isShowMenu: boolean = false
  @Param animationUse: boolean = true
  @Param isBackPress?: boolean = false
  @Param icon1?: Resource = undefined
  @Param icon2?: Resource = undefined
  @Param rightButtonList: Array<Resource | undefined> = [this.icon1, this.icon2]
  @Param endIconColor: ResourceColor = Color.White
  @Param buttonColor?: ResourceColor = colorChange.color1
  /** @description 标题栏总高度 此处勿改，初始值为undefined时，会自动根据标题栏的组件高度赋值，如需统一高度，则在导入处赋值56 */
  @Param heightTotal?: Length = undefined
  @Param paddingValue: number = 0
  @Param iconSize: number = 24
  @Param fontSize: number = 0
  @Param alignRow: VerticalAlign = VerticalAlign.Center

  @Event menu2OnDisappear: () => void = () => {}
  /** @description 图标点击回调 按钮从左到右序号依次为2、0、1 */
  @Event onClickIcon: (i: number) => void = (i: number) => {}
  @Event onSelectMenu: (i: number) => void = (i: number) => {}

  build() {
    Row() {
      Row({ space: 10 }) {
        if (this.isBackPress) {
          Xb_CircleButton({
            iconSize: this.iconSize,
            iconColor: $r('sys.color.font_primary'),
            icon: $r("sys.symbol.chevron_left"),
            iconBackgroundColor: undefined,
            theBackgroundColor: this.buttonColor,
            onCheck: () => {
              this.onClickIcon(2)
              customVibrator.vibratorTriggerOfHapticClockTimer()
            },
          })
            .transition(this.animationUse ? Xb_AnimationStyle.isMove(0) : null)
        }
        Text(this.name)
          .titleText(this.fontSize)
          .fontColor(this.fontColor)
          .margin(this.windowMode ? { top:  8, left: 16 } : undefined)
          .transition(this.animationUse ? Xb_AnimationStyle.isMove(1) : null)
      }

      Row({ space: 10 }) {
        ForEach(this.rightButtonList, (item: Resource, index) => {
          Row() {
            Xb_CircleButton({
              iconSize: this.windowMode ? 17 : 24,
              icon: item,
              iconColor: this.endIconColor,
              iconBackgroundColor: undefined,
              iconWeight: this.windowMode ? FontWeight.Bold : undefined,
              theBackgroundColor: this.windowMode ? Color.Transparent : this.buttonColor,
              onCheck: () => {
                this.onClickIcon(index)
                customVibrator.vibratorTriggerOfHapticClockTimer()
              }
            })
          }
          .transition(this.animationUse ? Xb_AnimationStyle.isMove(index == 0 ? 2 : 3) : null)
          .bindContextMenu(index === this.buttonIndexHasMenu ? this.isShowMenu!! : null,
            index === this.buttonIndexHasMenu ? Xb_Menu(this.buttonMenuList, (i: number) => {
              this.onSelectMenu(i) }, false) : null,
            {
              placement: Placement.BottomRight,
              preview: MenuPreviewMode.NONE,
              previewBorderRadius: BORDER_RADIUS_20,
              onDisappear: () => {
                this.menu2OnDisappear()
              }
            } as ContextMenuOptions )
        })
        // 窗口控制按钮避让区
        if (this.windowMode) {
          Row().width(109)
        }
      }
      .justifyContent(FlexAlign.End)
      .alignItems(this.windowMode ? VerticalAlign.Top : VerticalAlign.Center)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(this.alignRow)
    .width('100%')
    .height(this.heightTotal)
    .backgroundColor(Color.Transparent)
    .padding({ left: this.paddingValue, right: this.paddingValue })
  }
}


@Extend(Text)
function titleText(s: number){
  .fontWeight(FontWeight.Bold)
  .maxLines(1)
  .fontSize(s)
}
