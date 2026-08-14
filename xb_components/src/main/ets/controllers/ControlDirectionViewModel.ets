import { PublicEvent } from "./ControlButton"
import { ControlButtonViewModel, copyNew, hexToInt, intToHex, makeButtonStyleSettings } from "./ControlButtonViewModel"
import { ControlDirectionData, ControlDirectionStyle,
  DirectionStyleType,
  FollowOption, makeDefaultDirectionStyle ,
  SizeReference,
  SizeType,
  StickPosition,
  ViewGroup,
  VisibilityType} from "./Controller"
import { ControllerViewModel } from "./ControllerViewModel"
import { getAppStore } from "./MenuButton"
import { util } from "@kit.ArkTS"
import { Xb_ActionType, Xb_RadioGroupData, Xb_SettingsItemData } from "../model/SettingsItem"
import { KeyCodeSelector } from "../components/keyboard/VirtualKeyboard"
import { EventHub } from "../utils/EventHub"


@ObservedV2
export class ControlDirectionViewModel{
  controllerViewModel: ControllerViewModel = getAppStore(ControllerViewModel)!
  controlButtonViewModel: ControlButtonViewModel = getAppStore(ControlButtonViewModel)!
  @Trace editSettings: Xb_SettingsItemData[] = []
  @Trace styleListSettings: Xb_SettingsItemData[] = []
  @Trace styleEditSettings: Xb_SettingsItemData[] = []
  @Trace currentStyleGroup: Xb_RadioGroupData = new Xb_RadioGroupData("", "directionStyle");
  @Trace styleEdited?: ControlDirectionStyle
  @Trace keySelector: KeyCodeSelector = new KeyCodeSelector()

  onUpdate: () => void = () => {}
  onStyleEdit: () => void = () => {}
  copy(data:ControlDirectionData, group: ViewGroup){
    let newButton = copyNew<ControlDirectionData>(data)
    let uuid = util.generateRandomUUID(true);
    newButton.id = uuid
    group.viewData.directionList.push(newButton)
    this.controllerViewModel.updateViewGroups()
  }
  del(data: ControlDirectionData, group: ViewGroup){
    group.viewData.directionList = group.viewData.directionList.filter(b => b.id != data.id)
    this.controllerViewModel.updateViewGroups()
  }

  getDirectionStyle(name:string){
    return this.controllerViewModel.getDirectionStyle(name)
  }
  updateStyleListItems(data: ControlDirectionData){
    this.currentStyleGroup.value = data.style
    this.styleListSettings = this.controllerViewModel.makeDirectionStyleList(this.currentStyleGroup)
  }
  deleteStyle(){
    if(this.styleListSettings.length > 1){
      this.controllerViewModel.deleteDirectionStyle(this.currentStyleGroup.value)
      this.currentStyleGroup.value = this.styleListSettings[0].value as string
      this.styleListSettings = this.controllerViewModel.makeDirectionStyleList(this.currentStyleGroup)
    }
  }
  saveStyle(){
    if(this.styleEdited){
      this.controllerViewModel.saveDirectionStyle(this.styleEdited)
      this.styleListSettings = this.controllerViewModel.makeDirectionStyleList(this.currentStyleGroup)
    }
  }
  makeStyleEditItems(styleName: string){
    const style = this.controllerViewModel.getDirectionStyle(styleName)
    this.styleEdited = JSON.parse(JSON.stringify(style)) as ControlDirectionStyle
    this.styleEditSettings = this.makeDirectionStyleSettings(this.styleEdited)
  }

  makeDirectionStyleSettings(directionStyle: ControlDirectionStyle, onChange:(value: ResourceStr| boolean | number)=> void = ()=>{ this.styleEdited = copyNew(directionStyle) }): Xb_SettingsItemData[]{
    const items: Xb_SettingsItemData[] = [
      {label:"名称", value: directionStyle.name, actionType: Xb_ActionType.Input, onChange:(v)=>{ directionStyle.name = v as string; onChange(v)}},

      {label:"控制类型", value: directionStyle.styleType, actionType: Xb_ActionType.MENU, menuSelectList:[{label: "摇杆", value: DirectionStyleType.ROCKER },{ label:"方向键", value: DirectionStyleType.BUTTON}],
        onChange:(v)=>{
          directionStyle.styleType = v as DirectionStyleType;
          this.styleEditSettings = this.makeDirectionStyleSettings(directionStyle)
          onChange(v)
        }},
    ]
    if (directionStyle.styleType == DirectionStyleType.ROCKER) {
      let style = directionStyle.rockerStyle
      items.push(
        {label:"摇杆大小", value: style.rockerSize / 10, actionType: Xb_ActionType.SLIDER, slider: { step:0.5 ,util:"vp"},
          onChange:(v)=>{
            style.rockerSize = v as number * 10;
            onChange(v)
          }},
        {label:"背景边框宽度", value: style.bgStrokeWidth / 10, actionType: Xb_ActionType.SLIDER, slider: { min:0, max:10, step:0.5 ,util:"vp"}, onChange:(v)=>{
          style.bgStrokeWidth = v as number * 10;
          onChange(v)
        }},
        {label:"背景圆角半径", value: style.bgCornerRadius / 10, actionType: Xb_ActionType.SLIDER, slider: { min:0, max:50, step:0.5 ,util:"%"}, onChange:(v)=>{
          style.bgCornerRadius = v as number * 10;
          onChange(v)
        }},
        {label:"摇杆边框宽度", value: style.rockerStrokeWidth / 10, actionType: Xb_ActionType.SLIDER,slider: { min:0, max:10, step:0.5 ,util:"vp"}, onChange:(v)=>{
          style.rockerStrokeWidth = v as number * 10;
          onChange(v)
        }},
        {label:"摇杆圆角半径", value: style.rockerCornerRadius / 10, actionType: Xb_ActionType.SLIDER,slider:  { min:0, max:50, step:0.5 ,util:"%"}, onChange:(v)=>{
          style.rockerCornerRadius = v as number * 10;
          onChange(v)
        }},
        {label:"摇杆边框颜色", value: intToHex(style.rockerStrokeColor), actionType: Xb_ActionType.COLOR, onChange:(v)=>{ style.rockerStrokeColor = hexToInt(v as string);  onChange(v) }},
        {label:"摇杆填充颜色", value: intToHex(style.rockerFillColor), actionType: Xb_ActionType.COLOR, onChange:(v)=>{ style.rockerFillColor = hexToInt(v as string);  onChange(v) }},
        {label:"背景边框颜色", value: intToHex(style.bgStrokeColor), actionType: Xb_ActionType.COLOR, onChange:(v)=>{ style.bgStrokeColor = hexToInt(v as string);  onChange(v) }},
        {label:"背景填充颜色", value: intToHex(style.bgFillColor), actionType: Xb_ActionType.COLOR, onChange:(v)=>{ style.bgFillColor = hexToInt(v as string);  onChange(v) }}
      )
    } else {
      let style = directionStyle.buttonStyle
      items.push(
        {label:"按键间隔", value: style.interval, actionType: Xb_ActionType.SLIDER,
          onChange: (v)=> { style.interval = v as number; this.styleEdited = copyNew(directionStyle)}
        },
        {id: "buttonStyleList", label:"按键样式", value: style.name, actionType: Xb_ActionType.DIALOG, dialog: {
          width: "65%",
          onWillAppear:()=>{
            this.controlButtonViewModel.updateStyleListItems(style.name)
          }},
          onChange:(v)=>{
            if (v as boolean == true){
              style.name = this.controlButtonViewModel.currentStyleGroup.value
              let buttonStyle = this.controllerViewModel.getButtonStyle(style.name)
              directionStyle.buttonStyle.textSize = buttonStyle.textSize
              directionStyle.buttonStyle.strokeWidth = buttonStyle.strokeWidth
              directionStyle.buttonStyle.cornerRadius = buttonStyle.cornerRadius
              directionStyle.buttonStyle.textColor = buttonStyle.textColor
              directionStyle.buttonStyle.strokeColor = buttonStyle.strokeColor
              directionStyle.buttonStyle.fillColor = buttonStyle.fillColor
              directionStyle.buttonStyle.textSizePressed = buttonStyle.textSizePressed
              directionStyle.buttonStyle.strokeWidthPressed = buttonStyle.strokeWidthPressed
              directionStyle.buttonStyle.cornerRadiusPressed = buttonStyle.cornerRadiusPressed
              directionStyle.buttonStyle.fillColorPressed = buttonStyle.fillColorPressed
              directionStyle.buttonStyle.textColorPressed = buttonStyle.textColorPressed
              directionStyle.buttonStyle.strokeColorPressed = buttonStyle.strokeColorPressed
              onChange(v)
              this.styleEditSettings = this.makeDirectionStyleSettings(directionStyle)
            }
          }
        },
        ...makeButtonStyleSettings(style, onChange)
      )
    }
    return items;
  }

  updateDirectionItems(data: ControlDirectionData){
    this.editSettings = this.makeDirectionItems(data)
  }
  makeDirectionItems(data: ControlDirectionData): Xb_SettingsItemData[]{
    let base : Xb_SettingsItemData[] = [
      {  label: "基本信息", actionType: Xb_ActionType.GROUP },
      {
        label:"可见性", value:data.baseInfo.visibilityType, actionType: Xb_ActionType.MENU, menuSelectList:[{value: VisibilityType.ALWAYS, label:"永远显示" }, {value: VisibilityType.IN_GAME, label:"游戏内" },{ value: VisibilityType.MENU, label:"游戏外" }],
        onChange:(v)=>{
          data.baseInfo.visibilityType = v as VisibilityType
        }
      },
      {
        label:"X", value: data.baseInfo.xPosition / 10, actionType: Xb_ActionType.SLIDER, slider: {min: 0.0, max:100, step: 0.1, util:"%"},
        onChange:(v)=> {
          data.baseInfo.xPosition = Math.round(v as number * 10)
          this.onUpdate()
        }
      },
      {
        label:"Y", value: data.baseInfo.yPosition / 10, actionType: Xb_ActionType.SLIDER, slider: {min:  0.0, max:100, step: 0.1, util:"%"},
        onChange:(v)=> {
          data.baseInfo.yPosition = Math.round(v as number * 10)
          this.onUpdate()
        }
      },
      {label:"尺寸类型", value: data.baseInfo.sizeType, actionType: Xb_ActionType.MENU, menuSelectList:[{value:SizeType.PERCENTAGE, label:"百分比"}, {value: SizeType.ABSOLUTE, label:"绝对尺寸"}], onChange:(v)=>{
        data.baseInfo.sizeType = v as SizeType
        this.updateDirectionItems(data)
      }},
    ]
    if (data.baseInfo.sizeType == SizeType.PERCENTAGE){
      base.push(
        {label:"宽参考对象", value: data.baseInfo.percentageWidth.reference, actionType: Xb_ActionType.MENU, menuSelectList:[{value:SizeReference.SCREEN_WIDTH, label:"屏幕宽度"}, {value: SizeReference.SCREEN_HEIGHT, label:"屏幕高度"}],
          onChange:(v)=> {
            data.baseInfo.percentageWidth.reference = v as SizeReference
            this.onUpdate()
          }
        },
        {label:"尺寸", value: data.baseInfo.percentageWidth.size  / 10, actionType: Xb_ActionType.SLIDER, slider: {min:10,max:100, step:1,util:"%"},
          onChange:(v)=> {
            data.baseInfo.percentageWidth.size = v as number * 10
            this.onUpdate()
          }
        },
      )
    } else {
      base.push(
        {label:"尺寸", value: data.baseInfo.absoluteWidth, actionType: Xb_ActionType.SLIDER, slider: {min:20, max:200, step:1,util:"vp"},
          onChange: (v) => {
            data.baseInfo.absoluteWidth = v as number
            this.onUpdate()
          }
        }
      )
    }
    base.push(
      {
        id: "styleList",
        label: "控件样式",
        value: data.style,
        actionType: Xb_ActionType.DIALOG,
        dialog: {
          width: "65%",
          onWillAppear:()=>{
            this.updateStyleListItems(data)
          },
          buttons: ["添加", "编辑", "删除", "确认"], onClick: (b,i,d) => {
            if (i == 0){
              this.onStyleEdit()
              this.styleEdited = makeDefaultDirectionStyle()
              this.styleEditSettings = this.makeDirectionStyleSettings(this.styleEdited)
            } else if(i == 1){
              this.makeStyleEditItems(this.currentStyleGroup.value)
              this.onStyleEdit()
            } else if(i == 2) {
              this.deleteStyle()
            } else if (i == 3) {
              data.style = this.currentStyleGroup.value
              this.updateDirectionItems(data)
              EventHub.sendEvent(PublicEvent.DirectionStyleUpdated, this.controllerViewModel.getDirectionStyle(data.style));
              d?.close()
            }
          }
        },
        onChange: (v) => data.style = v as string
      },
    )
    base.push( {  label: "事件信息", actionType: Xb_ActionType.GROUP },)
    base.push(
      {
        id:"keyboard", label:"上", value: data.event.upKeycode, actionType: Xb_ActionType.DIALOG,
        dialog:{
          width: "80%",
          onWillAppear:()=>{
            this.keySelector.codes = [data.event.upKeycode]
          }
        },
        onChange: (v)=> {
          if(v){
            data.event.upKeycode = this.keySelector.codes[this.keySelector.codes.length - 1]
          }
        }
      },
      {id:"keyboard",label:"下", value: data.event.downKeycode, actionType: Xb_ActionType.DIALOG,
        dialog:{
          width: "80%",
          onWillAppear: () => {
            this.keySelector.codes = [data.event.downKeycode]
          }
        },
        onChange: (v) =>{
          if(v){
            data.event.downKeycode = this.keySelector.codes[this.keySelector.codes.length - 1]
          }
        }
      },
      {id:"keyboard",label:"左", value: data.event.leftKeycode, actionType: Xb_ActionType.DIALOG,
        dialog:{
          width: "80%",
          onWillAppear: () => {
            this.keySelector.codes = [data.event.leftKeycode]
          }
        },
        onChange: (v) =>{
          if(v){
            data.event.leftKeycode = this.keySelector.codes[this.keySelector.codes.length - 1]
          }
        }
      },
      {id:"keyboard",label:"右", value: data.event.rightKeycode, actionType: Xb_ActionType.DIALOG,
        dialog:{
          width: "80%",
          onWillAppear: () => {
            this.keySelector.codes = [data.event.rightKeycode]
          }
        },
        onChange: (v) =>{
          if(v){
            data.event.rightKeycode = this.keySelector.codes[this.keySelector.codes.length - 1]
          }
        }
      },
      {
        label:"摇杆位置", value: data.event.stickPosition, actionType: Xb_ActionType.MENU, menuSelectList:[{label:"左", value: StickPosition.Left},{label:"右", value: StickPosition.Right }], onChange:(v) => data.event.stickPosition = v as StickPosition
      },
      {
        label:"开启双击", value: data.event.sneak, actionType: Xb_ActionType.TOGGLE, onChange:(v) => data.event.sneak = v as boolean
      },
      {id:"keyboard",label:"双击键值", value: data.event.sneakKeycode, actionType: Xb_ActionType.DIALOG,
        dialog:{
          width: "80%",
          onWillAppear: () => {
            this.keySelector.codes = [data.event.sneakKeycode]
          }
        },
        onChange: (v) =>{
          if(v){
            data.event.sneakKeycode = this.keySelector.codes[this.keySelector.codes.length - 1]
          }
        }
      },
      {label:"跟随设置", content: "作用摇杆模式", value: data.event.followOption, actionType: Xb_ActionType.MENU, menuSelectList: [{value:FollowOption.FIXED, label:"固定"},{value:FollowOption.FOLLOW, label:"完全跟随"},{value:FollowOption.CENTER_FOLLOW, label:"中心部位跟随"}],
        onChange:(v)=> data.event.followOption = v as FollowOption
      },
    )
    return base;
  }

}
