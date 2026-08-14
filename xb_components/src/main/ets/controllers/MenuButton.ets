import { AppStorageV2, PersistenceV2 } from "@kit.ArkUI";
import { TypeConstructorWithArgs } from "@ohos.arkui.StateManagement"
import { EventHub } from "../../../../Index";
import { Xb_ActionType, Xb_RadioGroupData, Xb_SettingsItemData } from "../model/SettingsItem";
import { Xb_EventKey } from "../utils/EventHub";
import { Xb_SettingsGroup } from "../view/Xb_SettingsGroup";
import { ControllerViewModel } from "./ControllerViewModel";


@ComponentV2
export struct MenuButton{
  @Local menuState: MenuState = getPersistence(MenuState)!
  @Local viewmodel: ControllerViewModel = getAppStore(ControllerViewModel)!
  @Local private downX: number = 0;
  @Local private downY: number = 0;
  @Local private initialX: number = 200;
  @Local private initialY: number = 200;
  @Local postionX: number = 200;
  @Local postionY: number = 200;
  @Local private downTime: number = 20;
  aboutToAppear(): void {
    this.updateSettings()
  }

  aboutToDisappear(): void {
    this.menuState
  }
  handleTouch(event: TouchEvent){
    let x = vp2px(event.changedTouches[0].x);
    let y = vp2px(event.changedTouches[0].y);
    switch (event.type) {
      case TouchType.Down:
        this.downX = x;
        this.downY = y;
        this.initialX = this.postionX;
        this.initialY = this.postionY;
        this.downTime = new Date().getTime();
        break;
      case TouchType.Move:
        const targetX = Math.max(0, Math.min(this.menuState!.screenWidth - vp2px(this.menuState?.menuSize), this.initialX + x - this.downX));
        const targetY = Math.max(0, Math.min(this.menuState!.screenWidth - vp2px(this.menuState?.menuSize), this.initialY + y - this.downY));
        this.postionX = targetX
        this.postionY = targetY
        break;
      case TouchType.Up:
      case TouchType.Cancel:
        if (Math.abs(x - this.downX) <= 10
          && Math.abs(y - this.downY) <= 10
          && new Date().getTime() - this.downTime <= 400) {
            this.handleClick()
        }
        break;
    }
  }
  handleClick(){
    this.menuState.switchMenuSettings()
  }
  build() {
    Stack() {
      Image($rawfile("xbStudio.jpg")).hitTestBehavior(HitTestMode.None).size({
        width: this.menuState?.menuSize || 20,
        height: this.menuState?.menuSize || 20
      }).borderRadius("50%").clip(true)
    }.bindSheet(this.menuState!.showMenuSettings, this.SheetBuilder, { onDisappear:()=>{
      this.menuState!.showMenuSettings = false
    }}).onTouch((e)=>this.handleTouch(e))
    .position({x: this.postionX + "px",y: this.postionY + "px" })
  }
  @Local radioGroup: Xb_RadioGroupData = new Xb_RadioGroupData("111", "group")

  @Local menuSettings: Xb_SettingsItemData[] = []

  @Builder
  SheetBuilder() {
    Column() {
      Xb_SettingsGroup({items:this.menuSettings})
      Row().height(1)
    }.width('100%').height('100%')
  }

  @Monitor("viewmodel.controllerList")
  updateSettings(){
    this.menuSettings = makePersistenceSettings(MenuState, ()=> new MenuState(), (state)=>{
      return [
        {label:"布局设置", actionType: Xb_ActionType.GROUP},
        {label:"编辑模式", value: state.editMode, actionType: Xb_ActionType.TOGGLE, onChange:(v)=>{
          state.editMode = v as boolean
        }},
        {label:"当前布局", value: this.viewmodel.current?.id, actionType: Xb_ActionType.MENU, menuSelectList: this.viewmodel.controllerMenuList(), onChange:(v)=>{
          this.viewmodel.switchController(v as string)
        }},
        {label:"保存当前布局", value: this.viewmodel.current?.id, actionType: Xb_ActionType.BUTTON, onChange:(v)=>{
          this.viewmodel.saveController(this.viewmodel.current)
        }},
        {label:"导入新布局", value: this.viewmodel.current?.id, actionType: Xb_ActionType.BUTTON, onChange:(v)=>{
          this.viewmodel.importNewController()
        }},
        {label:"下载布局", value: this.viewmodel.current?.id, actionType: Xb_ActionType.BUTTON, onChange:(v)=>{
          this.viewmodel.downloadController(this.viewmodel.current)
        }},
        {label:"基础设置", actionType: Xb_ActionType.GROUP},
        {label:"显示控件边缘", value: state.showViewBoundaries, actionType: Xb_ActionType.TOGGLE, onChange:(v)=>{
          state.showViewBoundaries = v as boolean
        }},
        {label:"隐藏所有控件", value: state.hideAllViews, actionType: Xb_ActionType.TOGGLE, onChange:(v)=>{
          state.hideAllViews = v as boolean
        }},
        {label:"屏幕内边距", value: state.screenPadding, actionType: Xb_ActionType.SLIDER,slider:{ min:0, max:20, step: 2, util:"vp"}, onChange:(v)=>{
          state.screenPadding = (v as number)
        }},
        {label:"自动吸附", value: state.autoFit, actionType: Xb_ActionType.TOGGLE, onChange:(v)=>{
          state.autoFit = v as boolean
        }},
        {label:"吸附阈值", value: state.autoFitDist, actionType: Xb_ActionType.SLIDER,slider:{ min:2, max:10, step: 1, util:"vp"}, onChange:(v)=>{
          state.autoFitDist = v as number
        }},
        {label:"鼠标设置", actionType: Xb_ActionType.GROUP},
        {label:"锁定鼠标", content: "(需要升级系统到(API22))", value: state.lockMouse, actionType: Xb_ActionType.TOGGLE, onChange:(v)=>{
          state.lockMouse = v as boolean
        }},
        {label:"启动虚拟光标", value: state.cursorEnabled, actionType: Xb_ActionType.TOGGLE, onChange:(v)=>{
          state.cursorEnabled = v as boolean
        }},
        {label:"光标灵敏度", value: state.mouseSensitivity * 100, actionType: Xb_ActionType.SLIDER,slider:{ min:100, max:1000, step: 10, util:"%"}, onChange:(v)=>{
          state.mouseSensitivity = (v as number / 100)
        }},
        {label:"光标大小", value: state.cursorSize, actionType: Xb_ActionType.SLIDER,slider:{ min:10, max:30, step: 2, util:"vp"}, onChange:(v)=>{
          state.cursorSize = (v as number)
        }},
        {label:"菜单设置", actionType: Xb_ActionType.GROUP},
        {label:"大小", value: state.menuSize, actionType: Xb_ActionType.SLIDER,slider:{ min:20, max:50, step: 2, util:"vp"}, onChange:(v)=>{
          state.menuSize = (v as number)
        }},
        {label:"隐藏菜单", value: state.hideMenuButton, actionType: Xb_ActionType.TOGGLE, onChange:(v)=>{
          state.hideMenuButton = v as boolean
        }},
        {label:"其他设置", actionType: Xb_ActionType.GROUP},
        {label:"显示日志", value: state.showLogs, actionType: Xb_ActionType.TOGGLE, onChange:(v)=>{
          state.showLogs = v as boolean
        }},
        {label:"导出日志", value: "", actionType: Xb_ActionType.BUTTON, onChange:(v)=>{
          EventHub.sendEvent(Xb_EventKey.exportLogs)
        }},
      ]
    })
  }

}

export enum  CursorMoveType{
  Click,
  Move
}
@ObservedV2
export class MenuState{

  @Trace editMode: boolean = false
  @Trace cursorMode: boolean = false
  @Trace showViewBoundaries: boolean = false
  @Trace hideAllViews: boolean = false
  @Trace hideMenuButton: boolean = false
  @Trace lockMenu: boolean = false
  @Trace showMenuSettings: boolean = false
  @Trace lockMouse: boolean = false
  @Trace cursorSize: number = 10
  @Trace menuSize: number = 20
  @Trace mouseSensitivity: number = 1
  @Trace screenPadding: number = 0
  @Trace showLogs: boolean = false
  @Trace showKeyboard: boolean = false
  @Trace inputText: string = ""
  @Trace gestureMode: boolean = false
  @Trace mouseMode: boolean = false
  @Trace autoFit: boolean = true
  @Trace autoFitDist: number = 2

  @Trace screenWidth: number = 0
  @Trace screenHeight: number = 0

  @Trace cursorEnabled: boolean = true
  @Trace cursorMoveType: CursorMoveType = CursorMoveType.Click
  @Trace isDisableLeftTouch: boolean = false

  switchMenuSettings(){
    this.showMenuSettings = !this.showMenuSettings
  }
  switchGestureMode(){
    this.gestureMode = !this.gestureMode
  }
  switchMouseMode(){
    this.mouseMode = this.mouseMode
  }
  toggleKeyboard(){
    this.showKeyboard = !this.showKeyboard
  }
  openQuickInput(){

  }
}
// 持久化状态
export function makePersistenceSettings<T extends object>(type: TypeConstructorWithArgs<T>, defaultFactory:() =>T, onSettings: (t: T)=> Xb_SettingsItemData[]): Xb_SettingsItemData[] {
  const state = PersistenceV2.connect(type, type.name, defaultFactory)
  if(state){
    return onSettings(state)
  }
  return []
}
// 获取持久化的状态
export function getPersistence<T extends object>(type: TypeConstructorWithArgs<T>,  defaultFactory:(() =>T) | undefined = undefined): T | undefined {
  try {
    return PersistenceV2.connect(type, type.name, defaultFactory)
  }catch (e) {
    return undefined
  }
}
export function getAppStore<T extends object>(type: TypeConstructorWithArgs<T>,  defaultFactory:(() =>T) | undefined = undefined): T | undefined {
  try {
    return AppStorageV2.connect(type, type.name, defaultFactory)
  }catch (e) {
    return undefined
  }
}