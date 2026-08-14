import { ControlButtonData, VisibilityType, SizeType, SizeReference, ControlButtonStyle,
  makeDefaultButtonStyle,
  ViewGroup,
  ButtonEventAction,
  GroupVisibility,} from "./Controller"
import { JSON, util } from "@kit.ArkTS"
import { PublicEvent } from "./ControlButton"
import { ControllerViewModel } from "./ControllerViewModel"
import { getAppStore } from "./MenuButton"
import { KeyCodeSelector } from '../components/keyboard/VirtualKeyboard';
import { Xb_ActionType, Xb_RadioGroupData, Xb_SettingsItemData } from "../model/SettingsItem"
import { EventHub } from "../utils/EventHub"

@ObservedV2
export class ControlButtonViewModel {
  controllerViewModel: ControllerViewModel = getAppStore(ControllerViewModel)!
  @Trace editSettings: Xb_SettingsItemData[] = []
  @Trace styleListSettings: Xb_SettingsItemData[] = []
  @Trace styleEditSettings: Xb_SettingsItemData[] = []
  @Trace eventTab = "按压"
  @Trace currentStyleGroup: Xb_RadioGroupData = new Xb_RadioGroupData("", "buttonStyle");
  @Trace styleEdited?: ControlButtonStyle
  @Trace keySelector: KeyCodeSelector = new KeyCodeSelector()

  @Trace viewGroupSettings: Xb_SettingsItemData[] = []

  onUpdate: () => void = () => {}
  onStyleEdit: () => void = () => {}
  copy(data:ControlButtonData, group: ViewGroup){
    let newButton = copyNew<ControlButtonData>(data)
    let uuid = util.generateRandomUUID(true);
    newButton.id = uuid
    group.viewData.buttonList.push(newButton)
    this.controllerViewModel.updateViewGroups()
  }
  del(data: ControlButtonData, group: ViewGroup){
    group.viewData.buttonList = group.viewData.buttonList.filter(b => b.id != data.id)
    this.controllerViewModel.updateViewGroups()
  }

  getButtonStyle(name: string){
    return this.controllerViewModel.getButtonStyle(name);
  }
  updateStyleListItems(styleName: string){
    this.currentStyleGroup.value = styleName
    this.styleListSettings = this.controllerViewModel.makeButtonStyleList(this.currentStyleGroup)
  }
  deleteStyle(){
    if(this.styleListSettings.length > 1){
      this.controllerViewModel.deleteButtonStyle(this.currentStyleGroup.value)
      this.currentStyleGroup.value = this.styleListSettings[0].value as string
      this.styleListSettings =  this.controllerViewModel.makeButtonStyleList(this.currentStyleGroup)
    }
  }
  saveStyle(){
    if(this.styleEdited){
      this.controllerViewModel.saveButtonStyle(this.styleEdited)
      this.styleListSettings = this.controllerViewModel.makeButtonStyleList(this.currentStyleGroup)
    }
  }
  makeStyleEditItems(styleName: string| undefined){
    let newStyleEdited: ControlButtonStyle;
    if(styleName == undefined){
      newStyleEdited = makeDefaultButtonStyle()
    }else{
      const style = this.controllerViewModel.getButtonStyle(styleName)
      newStyleEdited = JSON.parse(JSON.stringify(style)) as ControlButtonStyle
    }
    this.styleEdited = newStyleEdited;
    this.styleEditSettings = this.makeButtonStyleSettings(newStyleEdited, ()=>{
      this.styleEdited = copyNew(newStyleEdited)
    })
  }

  makeButtonStyleSettings(style: ControlButtonStyle, onChange:(value: ResourceStr| boolean | number)=> void = ()=>{  }): Xb_SettingsItemData[]{
    return [
      {label:"名称", value: style.name, actionType: Xb_ActionType.Input, onChange:(v)=>{ style.name = v as string;  }},
      ...makeButtonStyleSettings(style, onChange)
    ]
  }

  updateButtonItems(data: ControlButtonData){
    this.editSettings = this.makeButtonItems(data)
    this.updateStyleListItems(data.style)
  }
  updateViewGroupSettings(data: ButtonEventAction){
    this.viewGroupSettings = this.controllerViewModel.viewGroups.map((g)=>{
      return {
        label: g.name, value: data.bindViewGroup.indexOf(g.id) > -1, actionType: Xb_ActionType.CHECK
      } as Xb_SettingsItemData
    })
  }
  switchViewGroupVisibility(data: ButtonEventAction){
    this.controllerViewModel.viewGroups.forEach((d)=>{
      if(data.bindViewGroup.indexOf(d.id) > -1){
       if(d.visibility == GroupVisibility.VISIBLE){
         d.visibility = GroupVisibility.INVISIBLE
       }else{
         d.visibility = GroupVisibility.VISIBLE
       }
      }
    })
    this.controllerViewModel.updateViewGroups()
  }


  private makeButtonItems(data: ControlButtonData): Xb_SettingsItemData[] {
    let base: Xb_SettingsItemData[] = [
      {  label: "基本信息", actionType: Xb_ActionType.GROUP },
      {
        label: "显示文本",
        value: data.text,
        actionType: Xb_ActionType.Input,
        onChange: (v) => {
          data.text = v as string
        }
      },
      {
        label: "可见性",
        value: data.baseInfo.visibilityType,
        actionType: Xb_ActionType.MENU,
        menuSelectList: [{ value: VisibilityType.ALWAYS, label: "永远显示" },
          { value: VisibilityType.IN_GAME, label: "游戏内" }, { value: VisibilityType.MENU, label: "游戏外" }],
        onChange: (v) => {
          data.baseInfo.visibilityType = v as VisibilityType
        }
      },
      {
        label: "X",
        value: data.baseInfo.xPosition / 10,
        actionType: Xb_ActionType.SLIDER,
        slider: {
          min: 0,
          max: 100,
          step: 0.1,
          util: "%",
          ctrl: true
        }
      ,
        onChange: (v) => {
          data.baseInfo.xPosition = v as number * 10
          this.onUpdate()
        }
      },
      {
        label: "Y",
        value: data.baseInfo.yPosition / 10,
        actionType: Xb_ActionType.SLIDER,
        slider: {
          min: 0,
          max: 100,
          step: 0.1,
          util: "%",
          ctrl: true
        }
      ,
        onChange: (v) => {
          data.baseInfo.yPosition = Math.round(v as number * 10)
          this.onUpdate()
        }
      },
      {
        label: "尺寸类型",
        value: data.baseInfo.sizeType,
        actionType: Xb_ActionType.MENU,
        menuSelectList: [{ value: SizeType.PERCENTAGE, label: "百分比" }, { value: SizeType.ABSOLUTE, label: "绝对尺寸" }],
        onChange: (v) => {
          data.baseInfo.sizeType = v as SizeType
          this.updateButtonItems(data)
        }
      },
    ]
    if (data.baseInfo.sizeType == SizeType.PERCENTAGE) {
      base.push(
        {
          label: "宽参考对象",
          value: data.baseInfo.percentageWidth.reference,
          actionType: Xb_ActionType.MENU,
          menuSelectList: [{ value: SizeReference.SCREEN_WIDTH, label: "屏幕宽度" },{ value: SizeReference.SCREEN_HEIGHT, label: "屏幕高度" }],
          onChange: (v) => {
            data.baseInfo.percentageWidth.reference = v as SizeReference
            this.onUpdate()
          }
        },
        {
          label: "宽",
          value: data.baseInfo.percentageWidth.size / 10,
          actionType: Xb_ActionType.SLIDER,
          slider: {
            min: 1,
            max: 100,
            step: 1,
            util: "%",
            ctrl: true
          },
          onChange: (v) => {
            data.baseInfo.percentageWidth.size = v as number * 10
            this.onUpdate()
          }
        },
        {
          label: "高参考对象",
          value: data.baseInfo.percentageHeight.reference,
          actionType: Xb_ActionType.MENU,
          menuSelectList: [{ value: SizeReference.SCREEN_WIDTH, label: "屏幕宽度" },  { value: SizeReference.SCREEN_HEIGHT, label: "屏幕高度" }],
          onChange: (v) => {
            data.baseInfo.percentageHeight.reference = v as SizeReference
            this.onUpdate()
          }
        },
        {
          label: "高",
          value: data.baseInfo.percentageHeight.size / 10,
          actionType: Xb_ActionType.SLIDER,
          slider: {
            min: 1,
            max: 100,
            step: 1,
            util: "%",
            ctrl: true
          },
          onChange: (v) => {
            data.baseInfo.percentageHeight.size = v as number * 10
            this.onUpdate()
          }
        }
      )
    } else {
      base.push(
        {
          label: "宽",
          value: data.baseInfo.absoluteWidth,
          actionType: Xb_ActionType.SLIDER,
          slider: {
            min: 10,
            max: 200,
            step: 1,
            util: "vp",
            ctrl: true
          },
          onChange: (v) => {
            data.baseInfo.absoluteWidth = v as number
            this.onUpdate()
          }
        },
        {
          label: "高",
          value: data.baseInfo.absoluteHeight,
          actionType: Xb_ActionType.SLIDER,
          slider: {
            min: 10,
            max: 200,
            step: 1,
            util: "vp",
            ctrl: true
          },
          onChange: (v) => {
            data.baseInfo.absoluteHeight = v as number
            this.onUpdate()
          }
        }
      )
    }
    base.push(
      {
        id: "styleList",
        label: "按钮样式",
        value: data.style,
        actionType: Xb_ActionType.DIALOG,
        dialog: {
          width: "65%",
          buttons: ["添加", "编辑", "删除", "确认"], onClick: (b,i,d) => {
            if (i == 0){
              this.makeStyleEditItems(undefined)
              this.onStyleEdit()
            } else if(i == 1){
              this.makeStyleEditItems(this.currentStyleGroup.value)
              this.onStyleEdit()
            } else if(i == 2) {
              this.deleteStyle()
            } else if (i == 3) {
              data.style = this.currentStyleGroup.value
              this.updateButtonItems(data)
              EventHub.sendEvent(PublicEvent.ButtonStyleUpdated, this.controllerViewModel.getButtonStyle(data.style));
              d?.close()
            }
          }
        },
        onChange: (v) => data.style = v as string
      },
    )
    base.push(
      {
        label: "光标跟随",
        value: data.event.pointerFollow,
        actionType: Xb_ActionType.TOGGLE,
        onChange: (v) => data.event.pointerFollow = v as boolean
      },
      {
        label: "可移动",
        value: data.event.Movable,
        actionType: Xb_ActionType.TOGGLE,
        onChange: (v) => data.event.Movable = v as boolean
      }
    )

    base.push({
      label: "按钮事件",
      actionType: Xb_ActionType.GROUP,
    })
    base.push({
      label: "事件类型",
      value: this.eventTab,
      actionType: Xb_ActionType.MENU,
      menuSelectList: [{ value: "点击" }, { value: "长按" }, { value: "双击" }, { value: "按压" }],
      onChange: (v) => {
        this.eventTab = v as string
        this.updateButtonItems(data)
      }
    })
    let e = data.event.longPressEvent;
    switch (this.eventTab) {
      case "点击":
        e = data.event.clickEvent;
        break;
      case "长按":
        e = data.event.longPressEvent;
        break;
      case "双击":
        e = data.event.doubleClickEvent;
        break;
      case "按压":
        e = data.event.pressEvent;
        break;
    }
    this.keySelector.codes = e.outputKeycodes
    base.push(
      {
        label: "自动保持",
        value: e.autoKeep,
        actionType: Xb_ActionType.TOGGLE ,
        onChange: (v) => e.autoKeep = v as boolean
      },
      {
        label: "自动点击",
        value: e.autoClick,
        actionType: Xb_ActionType.TOGGLE,
        onChange: (v) => e.autoClick = v as boolean
      },
      {
        label: "打开菜单",
        value: e.openMenu,
        actionType: Xb_ActionType.TOGGLE,
        onChange: (v) => e.openMenu = v as boolean
      },
      {
        label: "切换触摸控制手势",
        value: e.switchTouchMode,
        actionType: Xb_ActionType.TOGGLE,
        onChange: (v) => e.switchTouchMode = v as boolean
      },
      {
        label: "切换鼠标控制模式",
        value: e.switchMouseMode,
        actionType: Xb_ActionType.TOGGLE,
        onChange: (v) => e.switchMouseMode = v as boolean
      },
      {
        label: "软件键盘输入",
        value: e.input,
        actionType: Xb_ActionType.TOGGLE,
        onChange: (v) => e.input = v as boolean
      },
      {
        label: "打开快捷输入",
        value: e.quickInput,
        actionType: Xb_ActionType.TOGGLE,
        onChange: (v) => e.quickInput = v as boolean
      },
      {
        label: "发送文本",
        value: e.outputText,
        actionType: Xb_ActionType.Input,
        onChange: (v) => e.outputText = v as string
      },
      {
        id: "keyboard",
        label: "输出键值",
        value: "",
        actionType: Xb_ActionType.DIALOG,
        dialog: {
          width: "80%",
          onWillAppear:()=>{
            this.keySelector.codes = [...e.outputKeycodes]
          }
        },
        onChange: (v) =>{
          if(v as boolean == true){
            e.outputKeycodes = [...this.keySelector.codes]
          }
        }
      },
      {
        id: "viewGroup",
        label: "控制视图组",
        value: "",
        actionType: Xb_ActionType.DIALOG,
        dialog: {
          width: "50%",
          onWillAppear:()=>{
            this.updateViewGroupSettings(e)
          }
        },
        onChange: (v) =>{
          if(v as boolean == true){
            e.bindViewGroup = this.viewGroupSettings.filter(d=>d.value).map(d=> d.id as string)
          }
        }
      }
    )
    return base;
  }

}


export function makeButtonStyleSettings(style: ControlButtonStyle, onChange:(value: ResourceStr| boolean | number)=> void = ()=>{  }): Xb_SettingsItemData[]{
  return [
    {label:"正常状态", actionType: Xb_ActionType.GROUP },
    {label:"文本大小", value: style.textSize, actionType: Xb_ActionType.SLIDER, slider: { min:0, max:20, step:0.5, util:"vp"}, onChange:(v)=>{ style.textSize = v as number; onChange(v) }},
    {label:"边框宽度", value: style.strokeWidth / 10, actionType: Xb_ActionType.SLIDER, slider: { min:0, max: 10, step:0.5, util:"vp"}, onChange:(v)=>{ style.strokeWidth = v as number * 10; onChange(v) }},
    {label:"圆角半径", value: style.cornerRadius / 10, actionType: Xb_ActionType.SLIDER, slider: { min:0, max:50, step:0.5, util:"%"}, onChange:(v)=>{ style.cornerRadius = v as number * 10; onChange(v) }},
    {label:"文本颜色", value: intToHex(style.textColor), actionType: Xb_ActionType.COLOR, onChange:(v)=>{ style.textColor = hexToInt(v as string); onChange(v) }},
    {label:"边框颜色", value: intToHex(style.strokeColor), actionType: Xb_ActionType.COLOR, onChange:(v)=>{ style.strokeColor = hexToInt(v as string); onChange(v) }},
    {label:"填充颜色", value: intToHex(style.fillColor), actionType: Xb_ActionType.COLOR, onChange:(v)=>{ style.fillColor = hexToInt(v as string);; onChange(v) }},
    {label:"按压状态", actionType: Xb_ActionType.GROUP },
    {label:"文本大小", value: style.textSizePressed /10, actionType: Xb_ActionType.SLIDER,slider: { min:0, max: 20, step:0.5, util:"vp"}, onChange:(v)=>{ style.textSizePressed = v as number * 10; onChange(v) }},
    {label:"边框宽度", value: style.strokeWidthPressed/10, actionType: Xb_ActionType.SLIDER, slider: { min:0, max: 10, step:0.5, util:"vp"}, onChange:(v)=>{ style.strokeWidthPressed = v as number * 10; onChange(v) }},
    {label:"圆角半径", value: style.cornerRadiusPressed /10, actionType: Xb_ActionType.SLIDER, slider: { min:0, max:50, step:0.5, util:"%"}, onChange:(v)=>{ style.cornerRadiusPressed = v as number * 10; onChange(v) }},
    {label:"文本颜色", value: intToHex(style.textColorPressed), actionType: Xb_ActionType.COLOR, onChange:(v)=>{ style.textColorPressed = hexToInt(v as string); onChange(v) }},
    {label:"边框颜色", value: intToHex(style.strokeColorPressed), actionType: Xb_ActionType.COLOR, onChange:(v)=>{ style.strokeColorPressed = hexToInt(v as string); onChange(v) }},
    {label:"填充颜色", value: intToHex(style.fillColorPressed), actionType: Xb_ActionType.COLOR, onChange:(v)=>{ style.fillColorPressed = hexToInt(v as string); onChange(v) }}
  ]
}


export function intToHex(color: number): string {
  return '#' + (color >>> 0).toString(16).padStart(8, '0').toUpperCase();
}
export function hexToInt(hex: string): number {
  // 移除 # 号
  hex = hex.replace(/^#/, '');

  // 确保是6位十六进制
  if (hex.length === 3) {
    hex = hex.split('').map(c => c + c).join('');
  }
  // 转换为整数
  return parseInt(hex, 16);
}
export function copyNew<T>(data: object): T {
  return JSON.parse(JSON.stringify(data)) as T
}
