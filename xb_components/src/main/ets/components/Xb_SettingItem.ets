
import { LengthMetrics, SymbolGlyphModifier } from "@kit.ArkUI"
import { BORDER_RADIUS_20, PADDING_VALUE_12 } from "./Constants"
import { Xb_ColorUtils, Xb_CustomDialog, Xb_Global } from "../../../../Index"
import { ThemeType } from "../entity/Common"
import {Xb_RadioGroupData, Xb_SettingsItemData, Xb_MenuSelectItem, Xb_ActionType } from "../model/SettingsItem"
import { ColorPickerType, GridColorPicker, SpectrumColorPicker, CustomColorPickerDialog } from '@linke/ui-color-picker';

function hexToFloat(hex: string): number {
  // 移除可能的 # 前缀和空格，并转为大写
  const cleanHex = hex.replace('#', '').trim().toUpperCase();

  // 验证输入是否为有效的两位十六进制
  if (!/^[0-9A-F]{2}$/.test(cleanHex)) {
    throw new Error('Invalid hex format. Must be two hexadecimal characters (00-FF)');
  }

  // 将十六进制转换为十进制 (0-255)
  const decimal = parseInt(cleanHex, 16);

  // 转换为0-1之间的浮点数
  return decimal / 255;
}

function floatToHex(value: number): string {
  // 边界检查
  if (value < 0 || value > 1) {
    throw new Error('Value must be between 0 and 1');
  }

  // 转换为0-255之间的整数
  const decimal = Math.round(value * 255);

  // 转换为两位十六进制，不足两位补0
  return decimal.toString(16).padStart(2, '0').toUpperCase();
}

@Component
struct ColorPickerV1{
  @Prop defaultColor: string = ""
  @State @Watch("onColorSelect") selectedColor: string = '#8626A6';
  @State @Watch("onColorSelect") selectedOpacity: number = 1;
  @State colorPickerType: ColorPickerType = "Grid"
  onColorChange: (color:string)=> void = ()=>{}
  onClose:()=>void = ()=>{}
  aboutToAppear(): void {
    this.selectedColor = "#" + this.defaultColor.substring(3)
    this.selectedOpacity =  hexToFloat(this.defaultColor.substring(1, 3))
  }
  onColorSelect(){
    this.onColorChange(`#${floatToHex(this.selectedOpacity)}${this.selectedColor.substring(1)}` )
  }
  build() {
    Scroll(){
      CustomColorPickerDialog({
        selectedColor: this.selectedColor,
        selectedOpacity: this.selectedOpacity,
        colorPickerType: this.colorPickerType,
        onCloseClick: () => {
          this.onClose()
        }
      })
    }
  }
}


@ComponentV2
export struct Xb_SettingsItem {

  @Require @Param item: Xb_SettingsItemData
  @Param themeType: ThemeType = ThemeType.Black

  @BuilderParam icon: CustomBuilder
  @BuilderParam dialogContent?: (data: Xb_SettingsItemData) => void

  @Local value: ResourceStr| boolean | number = ""
  @Local showMenu: boolean = false
  @Local group: Xb_RadioGroupData | undefined = this.item.radioGroup
  @Local dialogController: CustomDialogController | undefined

  @LocalBuilder
  ColorPickerDialog(){

    ColorPickerV1({defaultColor: this.item.value as string,onClose:()=>{
      this.dialogController?.close()
    }, onColorChange:(color)=>{
        this.value = color;
        if(this.item.onChange){
          this.item.onChange(color)
        }
      }
    })
  }

  aboutToAppear(): void {
    this.value = this.item.value ?? "";
    if(this.item.actionType == Xb_ActionType.DIALOG){
        this.dialogController = new CustomDialogController({
          builder: Xb_CustomDialog({
            titleText: this.item.label,
            buttons: this.item.dialog?.buttons,
            center: ()=>{
              if(this.dialogContent){
                this.dialogContent(this.item)
              }
            },

            onButtonClick: (b, i)=>{
              if(this.item.dialog?.onClick != null){
                this.item.dialog!.onClick(b,i, this.dialogController)
              }else{
                if(this.item.onChange && !this.item.dialog?.buttons){
                  this.item.onChange(i == 1)
                }
                this.dialogController?.close()
              }
            }
          }),
          onWillAppear:()=>{
            if(this.item.dialog?.onWillAppear != null){
              this.item.dialog?.onWillAppear()
            }
          },
          width: this.item?.dialog?.width,
          autoCancel:false,
        })
    }
    if(this.item.actionType == Xb_ActionType.COLOR){
      this.dialogController = new CustomDialogController({
        builder: this.ColorPickerDialog,
        alignment: DialogAlignment.Bottom,
        onWillAppear:()=>{
          if(this.item.dialog?.onWillAppear != null){
            this.item.dialog?.onWillAppear()
          }
        },
        width: this.item?.dialog?.width,
        autoCancel: false,
      })
    }
  }

  build() {
    Row({space: 50}){
      Row({space: 12}) {
        if(this.icon) {
          this.icon()
        } else if (this.item.icon) {
          SymbolGlyph(this.item.icon)
            .fontColor([(this.item?.enable ?? true) ? this.item?.iconColor || Xb_Global.icon_emphasize :
              Xb_ColorUtils.getUnableColor(this.item?.iconColor || Xb_Global.icon_emphasize)])
            .fontSize(24)
        } else if(this.item.image) {
          Image(this.item.image)
            .width(21)
            .height(21)
        }
        Column(){
          Text(this.item.label)
            .fontColor((this.item?.enable ?? true) ? $r('app.color.font_color') : Xb_ColorUtils.getUnableColor($r('app.color.font_color')))
            .fontSize(16)
          Text(this.item.content)
            .fontColor((this.item?.enable ?? true) ? $r("app.color.text_input_placeholder") : Xb_ColorUtils.getUnableColor($r("app.color.text_input_placeholder")))
            .fontSize(12)
        }
        .enabled(this.item?.enable ?? true)
        .alignItems(HorizontalAlign.Start)
      }.layoutWeight(1)
      if (this.item.actionType == Xb_ActionType.RADIO) {
        RightAction({
          value: this.group?.value,
          item: this.item
        })
      } else {
        RightAction({
          value: this.value,
          item: this.item,
          themeType: this.themeType,
          onSliderChange: (v) => {
            this.value = v
            this.item.value = v;
            if (this.item?.onChange) {
              this.item?.onChange(v as number)
            }
          }
        })
      }
    }
    .enabled(this.item?.enable ?? true)
    .padding({left:10, right:10})
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
    .bindMenu(
      this.showMenu,
      this.item.actionType == Xb_ActionType.MENU ? MenuSelectWitch(this.item, (menu) => {
        this.value = menu.value
      }): undefined,
      {
        placement: Placement.BottomRight,
        backgroundBlurStyle: BlurStyle.NONE,
        onDisappear: () => {
          this.showMenu = false
        }
      })
    .width("100%")
    .onClick(() => {
      if (this.item.actionType == Xb_ActionType.MENU) {
        this.showMenu = true
        return
      }
      if (this.item.actionType == Xb_ActionType.TOGGLE) {
        this.item.value = !this.item.value
        this.value = this.item.value
      }
      if (this.item.actionType == Xb_ActionType.RADIO) {
        this.group!.value = this.item.value as string
      }
      if(this.item.actionType == Xb_ActionType.CHECK) {
        this.item.value = !this.item.value
        this.value = !this.value as boolean
      }
      if(this.item.actionType == Xb_ActionType.DIALOG || this.item.actionType == Xb_ActionType.COLOR) {
        this.dialogController?.open()
      } else {
        if (this.item?.onChange) {
          this.item.onChange(this.value)
        }
      }
    })
  }
}

export function makeSettingItems<T>(data: T, callBack:(t: T)=> Xb_SettingsItemData[]){
  return callBack(data);
}

// 设置#右侧通用组件
@ComponentV2
export struct RightAction {

  @Require @Param value: ResourceStr | boolean | number
  @Require @Param item: Xb_SettingsItemData
  @Param themeType: ThemeType = ThemeType.Black

  @Event onSliderChange: (p: number) => void

  menuLabel() {
    return this.item.menuSelectList?.find(m=> m.value == this.value)?.label ?? this.value
  }

  build() {
    Row(){
      if (this.item.actionType == Xb_ActionType.MENU) {
        // 菜单
        Row({space : 8}){
          Text(this.menuLabel() as ResourceStr).menuText()
            .fontColor((this.item?.enable ?? true) ? $r('app.color.font_color') : Xb_ColorUtils.getUnableColor($r('app.color.font_color')))
          SymbolGlyph($r("sys.symbol.arrowtriangle_down_fill")).menuSymbolGlyph(14, this.themeType, this.item?.enable ?? true)
        }
      } else if (this.item.actionType == Xb_ActionType.TOGGLE) {
        // 开关
        Toggle({type: ToggleType.Switch, isOn: this.value as boolean})
          .selectedColor(this.item?.actionColor || Xb_Global.icon_emphasize )
          .enabled(this.item?.enable ?? true)
          .hitTestBehavior(HitTestMode.None)
      } else if (this.item.actionType == Xb_ActionType.JUMP) {
        // 跳转箭头
        SymbolGlyph($r("sys.symbol.chevron_right")).menuSymbolGlyph(24, this.themeType)
          .hitTestBehavior(HitTestMode.None)
      } else if (this.item.actionType == Xb_ActionType.TEXT) {
        // 跳转箭头（带文本）
        Row({space : 8}) {
          Text(this.item.value as ResourceStr)
            .fontSize(15)
            .fontColor($r("app.color.text_input_placeholder"))
          SymbolGlyph($r("sys.symbol.chevron_right")).menuSymbolGlyph(24, this.themeType)
            .hitTestBehavior(HitTestMode.None)
        }
      } else if (this.item.actionType == Xb_ActionType.RADIO) {
        // 单选框
        Radio({value: this.item.value as string, group: this.item.radioGroup?.group})
          .size({width: 24, height: 24})
          .radioStyle({ checkedBackgroundColor: this.item?.actionColor || Xb_Global.icon_emphasize })
          .hitTestBehavior(HitTestMode.None)
          .checked(this.item.value == this.value)
      } else if (this.item.actionType == Xb_ActionType.CHECK) {
        Checkbox().size({width: 24, height: 24}).select(this.value as boolean).hitTestBehavior(HitTestMode.None)
      }
      else if (this.item.actionType == Xb_ActionType.DIALOG) {
        // 对话框弹窗箭头
        Row({space: 4}) {
          Text(this.value as ResourceStr).menuText()
          SymbolGlyph($r("sys.symbol.chevron_right")).menuSymbolGlyph(24, this.themeType)
        }
      }
      else if (this.item.actionType == Xb_ActionType.COLOR) {
        // 颜色选择弹窗箭头
        Row({space: 4}) {
          Rect().width(30).height(20).fill(this.value as string)
          Text(this.value as ResourceStr).menuText()
          SymbolGlyph($r("sys.symbol.chevron_right")).menuSymbolGlyph(24, this.themeType)
        }
      }
      else if (this.item.actionType == Xb_ActionType.SLIDER) {
        // 滑动条
        Row() {
          Text(`${((this.value || 0) as number).toFixed(1)} ${this.item.slider?.util || ""}`)
            .menuText()
            .margin({ right: this.item.slider?.ctrl ? 5 : 0})
          if (this.item.slider?.ctrl) {
            SymbolGlyph($r("sys.symbol.minus_circle_fill"))
              .menuSymbolGlyph(21, this.themeType)
              .onClick(() => {
                const minus = this.item.slider?.step || 1
                const old = this.value as number
                this.onSliderChange(old - minus)
              })
          }
          Slider({
            value: this.value!! as number,
            min: this.item.slider?.min || 0,
            max: this.item.slider?.max || 100,
            style: SliderStyle.InSet,
            step: this.item.slider?.step || 5
          }).showSteps(true)
            .stepColor($r("app.color.divider_light"))
            .blockColor(Color.White)
            .trackColor($r("app.color.settings_list_background"))
            .selectedColor($r("app.color.emphasize"))
            .trackThickness(20)
            .blockBorderColor($r("app.color.emphasize"))
            .minResponsiveDistance(1)
            .onChange((v: number) => {
              if (this.onSliderChange != null) {
                this.onSliderChange(v)
              }
            }).layoutWeight(1)
          if (this.item.slider?.ctrl) {
            SymbolGlyph($r("sys.symbol.plus_circle_fill"))
              .menuSymbolGlyph(21, this.themeType)
              .onClick(() => {
                const plus = this.item.slider?.step || 1
                const old = this.value as number
                this.onSliderChange(old + plus)
              })
          }
        }
      } else if (this.item.actionType == Xb_ActionType.Input){
        Row({space : 0}){
          TextInput({text: this.value as ResourceStr}).fontSize(14).onChange((v)=>{
            if(this.item.onChange != null){
              this.item.onChange(v)
            }
          })
        }.padding(2)
      }
    }.height(35).layoutWeight(this.item.actionType == Xb_ActionType.SLIDER || this.item.actionType == Xb_ActionType.Input ? 2: undefined).justifyContent(FlexAlign.End)
  }
}

// 设置#右侧菜单组件文本样式
@Extend(Text)
function menuText() {
  .fontSize(14).fontColor($r('app.color.font_color'))
}

// 设置#右侧菜单组件图标样式
@Extend(SymbolGlyph)
function menuSymbolGlyph(size: number, themeType: ThemeType = ThemeType.Black, enable: boolean = true) {
  .fontSize(size)
  .fontColor([enable ? themeType == ThemeType.Black ? $r("app.color.divider") : themeType == ThemeType.Light ? $r("app.color.divider_light") : $r("sys.color.menu_text_normal_color") :
  Xb_ColorUtils.getUnableColor(themeType == ThemeType.Black ? $r("app.color.divider") : themeType == ThemeType.Light ? $r("app.color.divider_light") : $r("sys.color.menu_text_normal_color"))])
}

// 设置#菜单通用组件
@Builder
export function MenuSelectWitch(item: Xb_SettingsItemData, onSelect:(item: Xb_MenuSelectItem)=>void) {
  Menu() {
    MenuItem({ content: item.label }).contentFont({ weight: FontWeight.Bold }) // 标题项
    Repeat<Xb_MenuSelectItem>(item.menuSelectList)
      .each((ri: RepeatItem<Xb_MenuSelectItem>) => {
        MenuItem({
          content: ri.item.label ?? ri.item.value,
          symbolStartIcon: ri.item.symbolIcon ? defaultIcon(ri) : undefined,
          symbolEndIcon: item.value == ri.item.value ? new SymbolGlyphModifier($r("sys.symbol.checkmark")).fontColor([menuColor(item, ri)]) : undefined,
        })
          .contentFont({ size:16 })
          .contentFontColor(menuColor(item, ri))
          .onClick(() => {
            if(item.menuDisabled && item.menuDisabled(ri.item, ri.index)){

            } else {
              onSelect(ri.item)
              if(item.onChange){
                item.onChange(ri.item.value)
              }
              item.value = ri.item.value
            }

          })
      }).key((item: Xb_MenuSelectItem) => item.value.toString())
  }
  .menuItemDivider({ color: $r("app.color.divider_light"),
    strokeWidth: LengthMetrics.vp(1),
    startMargin: LengthMetrics.vp(PADDING_VALUE_12),
    endMargin: LengthMetrics.vp(PADDING_VALUE_12)})
  .backgroundColor( $r("app.color.start_window_background") )
  .borderRadius(BORDER_RADIUS_20)
}

function defaultIcon(menu: RepeatItem<Xb_MenuSelectItem>){
  if(menu.item.symbolIcon == null)
    return new SymbolGlyphModifier($r("sys.symbol.checkmark"))
  return menu.item.symbolIcon
}

function menuColor(item: Xb_SettingsItemData, menu: RepeatItem<Xb_MenuSelectItem>): ResourceColor{
  if(item.menuDisabled == null){
    return $r("app.color.font_color");
  }
  return item.menuDisabled(menu.item, menu.index) ? $r("app.color.xb_font_on_tertiary") : $r("app.color.font_color");
}

