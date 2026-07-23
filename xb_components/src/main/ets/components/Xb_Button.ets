import { Xb_AnimationStyle } from "../utils/Animation"
import { Xb_Global } from "../entity/XbGlobal"


/**通用圆形按钮*/
@ComponentV2
struct Xb_CircleButton {

  @Param iconSize: number = 21
 // @Param MenuList: MenuItem[] = []
  @Param needClick: boolean = true
 // @Param isShowMenu: boolean = false
  @Param enabledClick: boolean = true
  @Param iconWeight: number = FontWeight.Regular
  @Param theBackgroundColor: ResourceColor = $r('sys.color.button_background_color_transparent')
  @Param iconColor: ResourceColor = ''

  @Param iconBackgroundColor?: ResourceColor = undefined
  @Param @Require icon?: Resource

  // 点击事件
  @Event onCheck: () => void = () => {}
 // @Event menuOnDisappear: () => void = () => {}
  @Event onLongPressCheck: () => void = () => {}

  build() {
    if (this.icon) {
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        SymbolGlyph(this.icon)
          .padding(this.iconBackgroundColor ? 5 : undefined)
          .backgroundColor(this.iconBackgroundColor)
          .fontColor([this.iconColor])
          .fontWeight(this.iconWeight)
          .fontSize(this.iconSize)
          .borderRadius(100)
      }
      .width(40)
      .height(40)
      .enabled(this.enabledClick)
      .hitTestBehavior(this.needClick ? HitTestMode.Default : HitTestMode.None)
      .clickEffect(Xb_AnimationStyle.isClick())
      .backgroundColor(this.theBackgroundColor)
      .onClick(() => {
        this.onCheck()
      })
      .gesture(
        LongPressGesture({ repeat: false, duration: 1000 })
          .onAction((event: GestureEvent) => {
            if (event && event.repeat) {
              this.onLongPressCheck()
            }
          }))
    /*  .bindContextMenu(this.isShowMenu!!,
        Xb_Menu(this.MenuList, (i: number) => { }, false),
        {
          placement: Placement.BottomRight,
          preview: MenuPreviewMode.NONE,
          previewBorderRadius: BORDER_RADIUS_20,
          onDisappear: () => {
            this.menuOnDisappear()
          }
        } as ContextMenuOptions )*/
    }
  }
}

/**通用胶囊按钮*/
@ComponentV2
struct Xb_CapsuleButton {

  @Param icon?: Resource = undefined
  @Param image?: Resource = undefined

  @Param text: ResourceStr = ''
  @Param iconColor: ResourceColor = Color.White
  @Param fontSize: string | number | Resource = 12
  @Param theBackgroundColor: ResourceColor | undefined = undefined
  @Param paddingValue: number = 6
  @Param buttonWidth: Length = 'auto'
  @Param buttonHeight: Length = 30
  @Param rotateIcon: number = 0

  // 点击事件
  @Event onCheck: () => void = () => {}

  build() {
    Button({ type: ButtonType.Capsule, stateEffect: true }) {
      Row({space: 3}) {
        if (this.icon) {
          SymbolGlyph(this.icon)
            .fontSize(this.fontSize)
            .fontColor([this.iconColor])
            .rotate({angle: this.rotateIcon})
        }
        if (this.image) {
          Image(this.image)
            .width(this.fontSize)
            .height(this.fontSize)
        }
        Text(this.text)
          .fontSize(this.fontSize)
          .fontColor(this.iconColor)
      }.padding({left: this.paddingValue, right: this.paddingValue})
    }
    .height(this.buttonHeight)
    .width(this.buttonWidth)
    .backgroundColor(this.theBackgroundColor ? this.theBackgroundColor : Xb_Global.icon_emphasize)
    .onClick(() => {
      this.onCheck()
    })
  }

}

export { Xb_CircleButton, Xb_CapsuleButton }