import { Xb_Global } from "../entity/XbGlobal"
import { RightStyle, MenuItem } from "../settings/SettingsCommonOp"
import { font_primary, font_secondary } from "./Constants"
import { SymbolGlyphModifier } from "@kit.ArkUI"
import { Xb_AnimationStyle } from "../utils/Animation"
import { customVibrator } from "../utils/Vibrator"
import { Xb_GetResourceString } from "../utils/ResourceStringUtil"

// 通用列表组件
@ComponentV2
export struct Xb_GeneralListItem {

  @Param itemID: string = ''
  @Param tips: ResourceStr = ''
  @Param title: ResourceStr = ''
  @Param checkBoxName: string = ''
  @Param buttonText?: ResourceStr = ''

  @Param startFontSize: number = 18
  @Param endText?: string = undefined
  @Param menuIcon?: Resource = undefined
  @Param theRadio?: string = undefined
  @Param selectMenuHeight: Length = 52
  @Param menuMediaIcon?: Resource = undefined
  @Param currentRadio?: string = undefined
  @Param endFIcon?: Resource = undefined
  @Param startImage?: string = undefined
  @Param startIcon?: Resource = undefined
  @Param subtitle1?: ResourceStr = undefined
  @Param subtitle2?: ResourceStr = undefined

  @Param showStart: boolean = false
  @Param needUpdate: boolean = false
  @Param toggleState: boolean = false
  @Param needSelecter: boolean = false
  @Param needRowClick: boolean = false
  @Param needRowPadding: boolean = true
  @Param enabledEndIcon: boolean = true
  @Param isLatestVersion: boolean = false
  @Param showBackgroundColor: boolean = false

  @Param mainSpace: number = 5
  @Param menuList?: MenuItem[] = undefined
  @Param menuSelect: number | string = 0
  @Param endStyles: string = RightStyle.SYMBOL
  @Param titleColor: ResourceColor = font_primary
  @Param startIconColor: ResourceColor = Xb_Global.icon_emphasize
  @Param endIconColor: ResourceColor = font_primary
  @Param endFIconColor: ResourceColor = font_primary
  @Param endIcon?: Resource = $r('sys.symbol.chevron_right')
  @Param selectMenuIconColor: ResourceColor = $r('sys.color.font_secondary')

  @Event onNormalButtonClick: () => void
  @Event onSbuttonClick: () => void
  @Event onMenuSelect: (index: number) => void
  @Event onRowClick: (id: string) => void

  /** @description 图标缩放比例 */
  @Local iconScale: number = 0;
  /** @description 图标旋转角度 */
  @Local iconRotation: number = 0;
  // 显示菜单
  @Local isShowMenu: boolean = false
  // 列表行是否可点击
  @Local enableRowClick: boolean = true
  // 本地开关状态变化
  @Local localToggleState: boolean = false
  @Local selectMenuName?: ResourceStr = ''
  @Local localMenuSelect: number | string = 0

  build() {
    Row({ space: this.mainSpace }) {
      // 前图案
      if (this.showStart) {
        if (this.startIcon) {
          SymbolGlyph(this.startIcon)
            .fontSize(24)
            .fontColor([Xb_Global.icon_emphasize])
            .effectStrategy(SymbolEffectStrategy.HIERARCHICAL)
            .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
            .scale({ x: this.iconScale, y: this.iconScale }) // 应用缩放
            .rotate({ angle: this.iconRotation }) // 应用旋转角度
            .animation({
              duration: 600,
              curve: Curve.EaseOut,
              delay: 0,
              iterations: 1,
              playMode: PlayMode.Normal
            })
            .onAppear(() => {
              this.iconScale = 1;
              this.iconRotation = 360; // 旋转一周
            })
        } else if (this.theRadio) {
          Radio({ value: this.theRadio, group: 'RadioGroup'})
            .hitTestBehavior(HitTestMode.None)
            .checked(this.theRadio == this.currentRadio)
            .radioStyle({
              checkedBackgroundColor: Xb_Global.icon_emphasize
            })
        } else if (this.startImage) {
          Image($rawfile(this.startImage))
            .borderRadius(18)
            .height(50)
            .width(50)
        } else {
          Checkbox({ name: this.checkBoxName, group: 'CheckboxGroup' })
            .hitTestBehavior(HitTestMode.None)
            .selectedColor(Xb_Global.icon_emphasize)
            .shape(CheckBoxShape.CIRCLE)
        }
      }
      // 内容文本区
      Column() {
        // 标题
        Row({space: 3}) {
          Text(this.title)
            .maxLines(2)
            .fontSize(this.startFontSize)
            .fontColor(this.titleColor)
            .fontWeight(FontWeight.Medium)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        // 副标题
        if (this.subtitle1) {
          Text(this.subtitle1)
            //.maxLines(this.endStyles !== RightStyle.TEXT ? 1 : undefined)
            .fontColor(font_secondary)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        if (this.subtitle2) {
          Text(this.subtitle2)
            .maxLines(1)
            .fontColor(font_secondary)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }.layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Blank()
      // 后部区
      if (this.endStyles == RightStyle.MENU) {
        // 选择菜单
        Row() {
          Text(this.selectMenuName)
            .fontColor($r('sys.color.font_secondary'))
          SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
            .fontSize(14)
            .margin({left: 7})
            .fontColor([this.selectMenuIconColor])
        }
        .bindContextMenu(this.isShowMenu, this.menu,
          {
            preview: undefined,
            onDisappear: () => {
              this.isShowMenu = false
              this.enableRowClick = true
              console.log(`进入菜单消失回调，此时isShowMenu：${this.isShowMenu} enableRowClick: ${this.enableRowClick}`)
            }
          })
        .height(this.selectMenuHeight)
      } else if (this.endStyles == RightStyle.RADIO) {
        // 单选框
        Radio({ value: this.theRadio, group: 'RadioGroup'})
          .hitTestBehavior(HitTestMode.None)
          .checked(this.theRadio == this.currentRadio)
          .radioStyle({
            checkedBackgroundColor: Xb_Global.icon_emphasize
          })
      } else if (this.endStyles == RightStyle.TOGGLE) {
        // 开关
        Toggle({ type: ToggleType.Switch, isOn: this.localToggleState })
          .selectedColor(Xb_Global.icon_emphasize)
          .hitTestBehavior(HitTestMode.None)
          .height(20)
      } else if (this.endStyles == RightStyle.BUTTON) {
        // 按钮
        Button(this.buttonText, {type: ButtonType.Capsule})
          .fontSize(12)
          .fontColor(Xb_Global.icon_emphasize)
          .backgroundColor($r("app.color.settings_list_background"))
          .height(26)
          .onClick(()=>{
            this.onNormalButtonClick()
            customVibrator.vibratorTriggerOfHapticClockTimer()
          })
          .clickEffect(Xb_AnimationStyle.isClick())
      } else if (this.endStyles == RightStyle.RIGHTTEXT) {
        // 提示二级文本
        Text(this.tips)
          .fontColor(font_secondary)
          .hitTestBehavior(HitTestMode.None)
      } else if (this.endStyles === RightStyle.TEXTRIGHT || this.endStyles === RightStyle.JUMP)  {
        if (this.endStyles == RightStyle.TEXTRIGHT) {
          // 功能显示二级文本
          Text(this.tips)
            .fontColor(font_secondary)
            .hitTestBehavior(HitTestMode.None)
        }
        SymbolGlyph(this.endIcon)
          .fontSize(24)
          .enabled(this.enabledEndIcon)
          .fontColor([this.endIconColor])
          .opacity(this.enabledEndIcon ? 1 : 0.5)
          .hitTestBehavior(this.needRowClick ? HitTestMode.None : HitTestMode.Default)
          .onClick(() => {
            this.onSbuttonClick()
          })
      }

    }
    .width('100%')
    .borderRadius(24)
    .constraintSize({minHeight: 56})
    .alignItems(VerticalAlign.Center)
    .padding(this.needRowPadding ? { top: 5, bottom: 5, left: 12, right: 12} : 0)
    .backgroundColor(this.showBackgroundColor ? this.getColor() : undefined)
    .onClick(() => {
      if (this.enableRowClick) {
        console.log(`点击整行，endStyles：${this.endStyles}`)
        if (this.endStyles === RightStyle.MENU) {
          // 菜单时效果
          this.isShowMenu = true
          this.enableRowClick = false
          console.log(`显示${this.itemID}菜单, isShowMenu：${this.isShowMenu} enableRowClick: ${this.enableRowClick}`)
        } else if (this.endStyles === RightStyle.TOGGLE) {
          // 开关时效果
          this.onRowClick(this.itemID)
          this.localToggleState = !this.localToggleState
          console.log(`显示${this.itemID}开关, localToggleState：${this.localToggleState} enableRowClick: ${this.enableRowClick}`)
        } else {
          this.onRowClick(this.itemID)
        }
      } else {
        console.log(`菜单显示中，列表行不可点击 endStyles：${this.endStyles} enableRowClick: ${this.enableRowClick}`)
        return
      }
    })
  }

  @Builder
  menu() {
    Menu() {
      ForEach(this.menuList, (menuItem: MenuItem, index: number) => {
        MenuItem({
          content: menuItem.itemName,
          symbolStartIcon: menuItem.startMediaIcon ? undefined : new SymbolGlyphModifier(this.menuIcon).fontColor(menuItem.startIconColor),
          startIcon: this.menuMediaIcon ?? menuItem.startMediaIcon,
          symbolEndIcon: this.localMenuSelect === menuItem.itemValue || this.localMenuSelect === index ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
        })
          .onChange((selected) => {
            this.selectMenuName = menuItem.itemName
            this.localMenuSelect = menuItem.itemValue ?? index
            if (this.menuList) {
              const onMenuClick = this.menuList.map(item => item.onSelect)[index]
              if (onMenuClick) {
                onMenuClick()
              }
            }
            this.onMenuSelect(index)
            this.isShowMenu = false
            this.enableRowClick = true
          })
      }, (menuItem: MenuItem) => JSON.stringify(menuItem))
    }
  }

  aboutToAppear(): void {
    // 初始化本地变量状态
    this.localMenuSelect = this.menuSelect
    this.localToggleState = this.toggleState
    this.getSelectMenuName()
  }

  private getSelectMenuName() {
    console.log(`#getSelectMenuName this.menuSelect：${this.menuSelect}`)
    if (!this.menuList) {
      this.selectMenuName = ''
      return
    } else {
      if (typeof this.menuSelect === 'number') {
        this.selectMenuName = this.menuList[this.menuSelect]?.itemName || '';
      } else {
        const found = this.menuList.find(item => item.itemValue === this.menuSelect);
        this.selectMenuName = found?.itemName || '';
      }
    }
    console.log(`#getSelectMenuName this.SelectMenuName：${Xb_GetResourceString(this.selectMenuName, this.getUIContext)}`)
  }

  getColor() {
    const context = this.getUIContext().getHostContext()!
    if (typeof Xb_Global.icon_emphasize == 'string' || typeof Xb_Global.icon_emphasize == 'number') return Xb_Global.icon_emphasize
    const colorValue = context.resourceManager.getColorSync(Xb_Global.icon_emphasize.id)
    return 0x33 << 24 | (colorValue & 0x00FFFFFF)
  }

  getMenuIconColor(colors: ResourceColor[]): [ResourceColor, number][] {
    let newCorlors: [ResourceColor, number][] = []
    colors.forEach((item, index) => {
      newCorlors.push([item, index])
    })
		return newCorlors
	}

}