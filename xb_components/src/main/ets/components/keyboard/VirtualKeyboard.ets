/* 虚拟全键盘 */
import {
  vKBorderRadius,
  vKColumnsGapSize, vKeyHeightSize,
  vKeyHeightSize1,
  vKeyHeightSize2,
  vKFontSize, vKPaddingSize, vKRowsGapSize,
  vKRowsSize } from "./BreakPoint";
import { vKIconSize } from "./BreakPoint";
import { KeyCode } from "@kit.InputKit";
import { screenInfo } from "./ScreenInfo";
import { HashMap } from "@kit.ArkTS";

/* 虚拟全键盘 */
export interface VirtualKeyItem{
  icon?: Resource
  image?: Resource
  value?: ResourceStr
  keyCode?: KeyCode | MouseButtonCode
  aspectRatio?: number
  height: Length
}

export interface VKGroup{
  groupIndex: number
  vkList: Array<VirtualKeyItem>
}

const AspectRatio_158 = 1.58
const AspectRatio_17 = 1.77
const AspectRatio_13 = 1.3
const AspectRatio_23 = 2.3
const AspectRatio_27 = 2.7
const Height_24 = vKeyHeightSize(screenInfo.WidthBp)
const Height_28 = vKeyHeightSize1(screenInfo.WidthBp)
const Height_32 = vKeyHeightSize2(screenInfo.WidthBp)

export const virtualKeyboardList: VKGroup[] = [
  {
    groupIndex: 0,
    vkList: [
      {value: 'ESC', keyCode: KeyCode.KEYCODE_ESCAPE, aspectRatio: AspectRatio_23, height: Height_24},
      {value: 'F1', keyCode: KeyCode.KEYCODE_F1, aspectRatio: AspectRatio_23, height: Height_24},
      {value: 'F2', keyCode: KeyCode.KEYCODE_F2, aspectRatio: AspectRatio_23, height: Height_24},
      {value: 'F3', keyCode: KeyCode.KEYCODE_F3, aspectRatio: AspectRatio_23, height: Height_24},
      {value: 'F4', keyCode: KeyCode.KEYCODE_F4, aspectRatio: AspectRatio_23, height: Height_24},
      {value: 'F5', keyCode: KeyCode.KEYCODE_F5, aspectRatio: AspectRatio_23, height: Height_24},
      {value: 'F6', keyCode: KeyCode.KEYCODE_F6, aspectRatio: AspectRatio_23, height: Height_24},
      {value: 'F7', keyCode: KeyCode.KEYCODE_F7, aspectRatio: AspectRatio_23, height: Height_24},
      {value: 'F8', keyCode: KeyCode.KEYCODE_F8, aspectRatio: AspectRatio_23, height: Height_24},
      {value: 'F9', keyCode: KeyCode.KEYCODE_F9, aspectRatio: AspectRatio_23, height: Height_24},
      {value: 'F10', keyCode: KeyCode.KEYCODE_F10, aspectRatio: AspectRatio_23, height: Height_24},
      {value: 'F11', keyCode: KeyCode.KEYCODE_F11, aspectRatio: AspectRatio_23, height: Height_24},
      {value: 'F12', keyCode: KeyCode.KEYCODE_F12, aspectRatio: AspectRatio_23, height: Height_24},
      {icon: $r("sys.symbol.line_below_chevron_down"), keyCode: -111, aspectRatio: AspectRatio_23, height: Height_24},
    ]
  },
  {
    groupIndex: 1,
    vkList: [
      {value: '` ~', keyCode: KeyCode.KEYCODE_GRAVE, aspectRatio: AspectRatio_17, height: Height_28},
      {value: '1 !', keyCode: KeyCode.KEYCODE_1, aspectRatio: AspectRatio_17, height: Height_28},
      {value: '2 @', keyCode: KeyCode.KEYCODE_2, aspectRatio: AspectRatio_17, height: Height_28},
      {value: '3 #', keyCode: KeyCode.KEYCODE_3, aspectRatio: AspectRatio_17, height: Height_28},
      {value: '4 $', keyCode: KeyCode.KEYCODE_4, aspectRatio: AspectRatio_17, height: Height_28},
      {value: '5 %', keyCode: KeyCode.KEYCODE_5, aspectRatio: AspectRatio_17, height: Height_28},
      {value: '6 ^', keyCode: KeyCode.KEYCODE_6, aspectRatio: AspectRatio_17, height: Height_28},
      {value: '7 &', keyCode: KeyCode.KEYCODE_7, aspectRatio: AspectRatio_17, height: Height_28},
      {value: '8 *', keyCode: KeyCode.KEYCODE_8, aspectRatio: AspectRatio_17, height: Height_28},
      {value: '9 (', keyCode: KeyCode.KEYCODE_9, aspectRatio: AspectRatio_17, height: Height_28},
      {value: '0 )', keyCode: KeyCode.KEYCODE_0, aspectRatio: AspectRatio_17, height: Height_28},
      {value: '- _', keyCode: KeyCode.KEYCODE_MINUS, aspectRatio: AspectRatio_17, height: Height_28},
      {value: '= +', keyCode: KeyCode.KEYCODE_EQUALS, aspectRatio: AspectRatio_17, height: Height_28},
      {value: 'Del', keyCode: KeyCode.KEYCODE_FORWARD_DEL, aspectRatio: AspectRatio_17, height: Height_28},
      {value: 'SrcLK', keyCode: KeyCode.KEYCODE_SCROLL_LOCK, aspectRatio: AspectRatio_17, height: Height_28},
    ]
  },
  {
    groupIndex: 2,
    vkList: [
      {icon: $r("sys.symbol.reverse_order"), value: 'Tab', keyCode: KeyCode.KEYCODE_TAB, aspectRatio: 2, height: Height_32},
      {value: 'Q', keyCode: KeyCode.KEYCODE_Q, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'W', keyCode: KeyCode.KEYCODE_W, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'E', keyCode: KeyCode.KEYCODE_E, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'R', keyCode: KeyCode.KEYCODE_R, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'T', keyCode: KeyCode.KEYCODE_T, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'Y', keyCode: KeyCode.KEYCODE_Y, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'U', keyCode: KeyCode.KEYCODE_U, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'I', keyCode: KeyCode.KEYCODE_I, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'O', keyCode: KeyCode.KEYCODE_O, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'P', keyCode: KeyCode.KEYCODE_P, aspectRatio: AspectRatio_13, height: Height_32},
      {value: '[ {', keyCode: KeyCode.KEYCODE_LEFT_BRACKET, aspectRatio: AspectRatio_13, height: Height_32},
      {value: '] }', keyCode: KeyCode.KEYCODE_RIGHT_BRACKET, aspectRatio: AspectRatio_13, height: Height_32},
      {value: `\|`, keyCode: KeyCode.KEYCODE_BACKSLASH, aspectRatio: AspectRatio_13, height: Height_32},
      {icon: $r("sys.symbol.arrow_left"), value: 'Back', keyCode: KeyCode.KEYCODE_DEL, aspectRatio: AspectRatio_23,  height: Height_32},
      {value: 'Pause', keyCode: KeyCode.KEYCODE_BREAK, aspectRatio: AspectRatio_13, height: Height_32},
    ]
  },
  {
    groupIndex: 3,
    vkList: [
      {value: 'Caps', keyCode: KeyCode.KEYCODE_CAPS_LOCK, aspectRatio: 2.9, height: Height_32},
      {value: 'A', keyCode: KeyCode.KEYCODE_A, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'S', keyCode: KeyCode.KEYCODE_S, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'D', keyCode: KeyCode.KEYCODE_D, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'F', keyCode: KeyCode.KEYCODE_F, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'G', keyCode: KeyCode.KEYCODE_G, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'H', keyCode: KeyCode.KEYCODE_H, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'J', keyCode: KeyCode.KEYCODE_J, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'K', keyCode: KeyCode.KEYCODE_K, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'L', keyCode: KeyCode.KEYCODE_L, aspectRatio: AspectRatio_13, height: Height_32},
      {value: '; :', keyCode: KeyCode.KEYCODE_SEMICOLON, aspectRatio: AspectRatio_13, height: Height_32},
      {value: `' "`, keyCode: KeyCode.KEYCODE_APOSTROPHE, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'Enter', keyCode: KeyCode.KEYCODE_ENTER, aspectRatio: AspectRatio_27,  height: Height_32},
      {value: 'Ins', keyCode: KeyCode.KEYCODE_INSERT, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'Print', keyCode: KeyCode.KEYCODE_PRINT, aspectRatio: AspectRatio_13, height: Height_32},
    ]
  },
  {
    groupIndex: 4,
    vkList: [
      {icon: $r("sys.symbol.arrowshape_up"), value: 'Shift', keyCode: KeyCode.KEYCODE_SHIFT_LEFT, aspectRatio: 3.5, height: Height_32},
      {value: 'Z', keyCode: KeyCode.KEYCODE_Z, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'X', keyCode: KeyCode.KEYCODE_X, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'C', keyCode: KeyCode.KEYCODE_C, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'V', keyCode: KeyCode.KEYCODE_V, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'B', keyCode: KeyCode.KEYCODE_B, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'N', keyCode: KeyCode.KEYCODE_N, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'M', keyCode: KeyCode.KEYCODE_M, aspectRatio: AspectRatio_13, height: Height_32},
      {value: ', <', keyCode: KeyCode.KEYCODE_COMMA, aspectRatio: AspectRatio_13, height: Height_32},
      {value: '. >', keyCode: KeyCode.KEYCODE_PERIOD, aspectRatio: AspectRatio_13, height: Height_32},
      {value: '/ ?', keyCode: KeyCode.KEYCODE_SLASH, aspectRatio: AspectRatio_13, height: Height_32},
      {icon: $r("sys.symbol.arrowshape_up"), value: 'Shift', keyCode: KeyCode.KEYCODE_SHIFT_RIGHT, aspectRatio: AspectRatio_23,  height: Height_32},
      {value: 'PgUp', keyCode: KeyCode.KEYCODE_PAGE_UP, aspectRatio: AspectRatio_13, height: Height_32},
      {icon: $r("sys.symbol.chevron_up"), keyCode: KeyCode.KEYCODE_DPAD_UP, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'PgDw', keyCode: KeyCode.KEYCODE_PAGE_DOWN, aspectRatio: AspectRatio_13, height: Height_32},
    ]
  },
  {
    groupIndex: 5,
    vkList: [
      {value: 'Ctrl', keyCode: KeyCode.KEYCODE_CTRL_LEFT, aspectRatio: AspectRatio_13,  height: Height_32},
      {icon: $r("sys.symbol.square_fill_grid_2x2"), keyCode: KeyCode.KEYCODE_META_LEFT, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'Alt', keyCode: KeyCode.KEYCODE_ALT_LEFT, aspectRatio: AspectRatio_13, height: Height_32},
      {value: '——', keyCode: KeyCode.KEYCODE_SPACE, aspectRatio: 10.3,  height: Height_32},
      {value: 'Alt', keyCode: KeyCode.KEYCODE_ALT_RIGHT, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'Fn', keyCode: KeyCode.KEYCODE_FN, aspectRatio: AspectRatio_13, height: Height_32},
      {icon: $r("sys.symbol.doc_plaintext"), keyCode: KeyCode.KEYCODE_MENU, aspectRatio: AspectRatio_13, height: Height_32},
      {value: 'Ctrl', keyCode: KeyCode.KEYCODE_CTRL_RIGHT, aspectRatio: AspectRatio_13, height: Height_32},
      {icon: $r("sys.symbol.chevron_left"), keyCode: KeyCode.KEYCODE_DPAD_LEFT, aspectRatio: AspectRatio_13, height: Height_32},
      {icon: $r("sys.symbol.chevron_down"), keyCode: KeyCode.KEYCODE_DPAD_DOWN, aspectRatio: AspectRatio_13, height: Height_32},
      {icon: $r("sys.symbol.chevron_right"), keyCode: KeyCode.KEYCODE_DPAD_RIGHT, aspectRatio: AspectRatio_13, height: Height_32},
    ]
  }
]

export enum  MouseButtonCode{
  Left =  9001,
  Right =  9003,
  Middle =  9002,
  Forward =  9004,
  Back =  9005,
}

export const virtualMouseList: VirtualKeyItem[] = [
  {value: 'Left', keyCode: MouseButtonCode.Left, aspectRatio: AspectRatio_158, height: Height_24},
  {value: 'Right', keyCode: MouseButtonCode.Right, aspectRatio: AspectRatio_158, height: Height_24},
  {value: 'Middle', keyCode: MouseButtonCode.Middle, aspectRatio: AspectRatio_158, height: Height_24},
  {value: 'Forward', keyCode: MouseButtonCode.Forward, aspectRatio: AspectRatio_158, height: Height_24},
  {value: 'Back', keyCode: MouseButtonCode.Back, aspectRatio: AspectRatio_158, height: Height_24},
]
export const virtualControllerList: VirtualKeyItem[] = [
  {value: 'A', keyCode: KeyCode.KEYCODE_BUTTON_A, aspectRatio: AspectRatio_158, height: Height_24},
  {value: 'B', keyCode: KeyCode.KEYCODE_BUTTON_B, aspectRatio: AspectRatio_158, height: Height_24},
  {value: 'X', keyCode: KeyCode.KEYCODE_BUTTON_X, aspectRatio: AspectRatio_158, height: Height_24},
  {value: 'Y', keyCode: KeyCode.KEYCODE_BUTTON_Y, aspectRatio: AspectRatio_158, height: Height_24},
  {value: 'L1', keyCode: KeyCode.KEYCODE_BUTTON_L1, aspectRatio: AspectRatio_158, height: Height_24},
  {value: 'L2', keyCode: KeyCode.KEYCODE_BUTTON_L2, aspectRatio: AspectRatio_158, height: Height_24},
  {value: 'R1', keyCode: KeyCode.KEYCODE_BUTTON_R1, aspectRatio: AspectRatio_158, height: Height_24},
  {value: 'R2', keyCode: KeyCode.KEYCODE_BUTTON_R2, aspectRatio: AspectRatio_158, height: Height_24},
  {value: 'SELECT', keyCode: KeyCode.KEYCODE_BUTTON_SELECT, aspectRatio: AspectRatio_158, height: Height_24},
  {value: 'Start', keyCode: KeyCode.KEYCODE_BUTTON_START, aspectRatio: AspectRatio_158, height: Height_24},
  {value: 'MODE', keyCode: KeyCode.KEYCODE_BUTTON_MODE, aspectRatio: AspectRatio_158, height: Height_24},
  {value: 'THUMBL', keyCode: KeyCode.KEYCODE_BUTTON_THUMBL, aspectRatio: AspectRatio_158, height: Height_24},
  {value: 'THUMBR', keyCode: KeyCode.KEYCODE_BUTTON_THUMBR, aspectRatio: AspectRatio_158, height: Height_24},
]
export const ControllerCodeDict = virtualControllerList.reduce((p: HashMap<number,number>,n)=>{
  if(!p.hasKey(n.keyCode)){
    p.set(n.keyCode, n.keyCode)
  }
  return p
}, new HashMap<number,number>())

export const MouseCodeDict = virtualMouseList.reduce((p: HashMap<number,number>,n)=>{
  if(!p.hasKey(n.keyCode)){
    p.set(n.keyCode, n.keyCode)
  }
  return p
}, new HashMap<number,number>())
@ObservedV2
export class KeyCodeSelector{
  @Trace codes: number[] = []

  isSelect(key:number){
    return this.codes.indexOf(key) > -1
  }
  select(key: number){
    if(!this.isSelect(key)){
      this.codes.push(key)
    }else{
      this.codes = this.codes.filter(k=>k != key)
    }
  }
}

@ComponentV2
export struct VirtualKey{
  @Param @Require data: VirtualKeyItem
  @Param selector?: KeyCodeSelector = undefined
  @Param @Require onVKeyEvent: (e: KeyEvent) => void
  @Param bgColor: ResourceColor = $r("app.color.background")
  @Local isPress: boolean = false

  build() {
    Row({ space: 4 }) {
      if (this.data.icon != undefined) {
        SymbolGlyph(this.data.icon).fontColor([Color.White]).fontSize(vKIconSize(screenInfo.WidthBp))
      } else if (this.data.image != undefined) {
        Image(this.data.image)
          .size({ width: vKIconSize(screenInfo.WidthBp), height: vKIconSize(screenInfo.WidthBp) })
      }
      if (this.data.value != undefined) {
        Text(this.data.value).fontColor(Color.White).fontSize(vKFontSize(screenInfo.WidthBp))
      }
    }
    .aspectRatio(this.data.aspectRatio)
    .height(this.data.height)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .borderRadius(vKBorderRadius(screenInfo.WidthBp))
    .onTouch((e)=>{
      e.stopPropagation()
      let type = KeyType.Down;
      if (e.type == TouchType.Down){
        this.selector?.select(this.data.keyCode as number)
        type = KeyType.Down
        this.isPress = true
      }
      if(e.type == TouchType.Up || e.type == TouchType.Cancel){
        type = KeyType.Up
        this.isPress = false
      }
      // TODO 伪造keyEvent, 处理键盘事件
      const metaKey = 0
      //  * Indicates the status of the key when the key is pressed.
      //      * The value 1 indicates the pressed state, and the value 0 indicates the unpressed state.

      this.onVKeyEvent({ keyCode: this.data.keyCode, type: type, keyText: this.data.value, metaKey: metaKey } as KeyEvent)
    })
    .onKeyEvent((event: KeyEvent)=>{
      if (event) {
        if (event.keyCode == this.data.keyCode && event.type === KeyType.Down) {
          this.isPress = true
        }else if(event.keyCode == this.data.keyCode && event.type === KeyType.Up){
          this.isPress = false
        }
      }
    })
    .backgroundColor((this.isPress || this.selector?.isSelect(this.data.keyCode)) ? $r('sys.color.icon_emphasize') : this.bgColor)
  }
}
@ComponentV2
export struct VirtualStickKey{
  @Param OnEvent: (e: KeyEvent) => void = ()=>{}
  @Param selector?: KeyCodeSelector = undefined
  build() {
    Row({space: "2vp"}){
      Repeat<VirtualKeyItem>(virtualControllerList)
        .each((ri: RepeatItem<VirtualKeyItem>) => {
          VirtualKey({data:ri.item, selector: this.selector, onVKeyEvent: this.OnEvent})
        })
    }.padding(8)
  }
}


@ComponentV2
export struct VirtualMouseKey{
  @Param OnEvent: (e: KeyEvent) => void = ()=>{}
  @Param selector?: KeyCodeSelector = undefined
  build() {
   Row({space: "2vp"}){
     Repeat<VirtualKeyItem>(virtualMouseList)
       .each((ri: RepeatItem<VirtualKeyItem>) => {
         VirtualKey({data:ri.item, selector: this.selector, onVKeyEvent: this.OnEvent})
       })
    }.padding(8)
  }
}


@ComponentV2
export struct VirtualKeyboard{
  @Param OnEvent: (e: KeyEvent) => void = () => {}
  @Param selector?: KeyCodeSelector = undefined
  @Param vkBgColor: ResourceColor = $r("app.color.background")

  build() {
    Column({space: vKColumnsGapSize(screenInfo.WidthBp)}) {
      ForEach(virtualKeyboardList, (g: VKGroup, gIndex: number) => {
        if (gIndex == g.groupIndex) {
          Flex({direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignContent: FlexAlign.Start, space: vKRowsSize(screenInfo.WidthBp)}) {
            ForEach(g.vkList, (l: VirtualKeyItem, i: number) => {
              VirtualKey({ data: l, selector: this.selector, onVKeyEvent: this.OnEvent, bgColor: this.vkBgColor })
            })
          }.width('100%')
        }
      })
    }
    .width('100%')
    .padding(vKPaddingSize(screenInfo.WidthBp))
  }
}