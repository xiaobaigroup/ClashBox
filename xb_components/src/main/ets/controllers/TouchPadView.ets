import { pointer } from "@kit.InputKit";
import { getAppStore, getPersistence, MenuState } from "./MenuButton";
import { TouchPadInput } from "./TouchPadInput";
import { lockCursor, unlockCursor } from "libxb_components.so";
import { Xb_GlobalContext } from "../entity/GlobalContext";
import { ControllerEventHandler, StickAxisEvent } from "./ControllerEventHandler";

@ObservedV2
class FitLine{
  @Trace showLineHorizontal:boolean = false
  @Trace showLineVertical:boolean = false
  @Trace prefX: number = 0
  @Trace prefY: number = 0
  @Trace selfX: number = 0
  @Trace selfY: number = 0

  showLine(orientation: number, pref: number, self: number){
    if (orientation == 0) {
      this.showLineHorizontal = true;
      this.prefX = pref;
      this.selfX = self;
    } else {
      this.showLineVertical = true;
      this.prefY = pref;
      this.selfY = self;
    }
  }
  removeLine(orientation: number) {
    if (orientation == 0)
      this.showLineHorizontal = false;
    else
      this.showLineVertical = false;
  }
}
export const fitLine = new FitLine()

@ComponentV2
export struct TouchPadView{
  @Param eventHandler?: ControllerEventHandler = undefined
  @Local menuState: MenuState = getPersistence(MenuState,()=> new MenuState())!
  @Local touchInput: TouchPadInput = getAppStore(TouchPadInput,()=> new TouchPadInput())!

  @Monitor("menuState.lockMouse")
  onLockMouse(monitor: IMonitor){
    this.lockMouse()
  }
  lockMouse(){
    if(this.menuState?.lockMouse){
      pointer.setPointerVisibleSync(false)
      lockCursor(Xb_GlobalContext.windowId, false)
    }else{
      pointer.setPointerVisibleSync(true)
      unlockCursor(Xb_GlobalContext.windowId)
    }
  }
  aboutToAppear(): void {
    this.lockMouse()
  }
  aboutToDisappear(): void {
    this.lockMouse()
  }
  onPageHide(): void {
    this.lockMouse()
  }
  onPageShow(): void {
    this.lockMouse()
  }
  build() {
    Stack(){
      if(fitLine.showLineVertical){
        Line().height(1).width("100%").position({y: fitLine.prefY + "px"}).backgroundColor(Color.Green)
        Line().height(1).width("100%").position({y: fitLine.selfY + "px"}).backgroundColor(Color.Green)
      }
      if(fitLine.showLineHorizontal){
        Line().height("100%").width(1).position({x: fitLine.prefX + "px"}).backgroundColor(Color.Green)
        Line().height("100%").width(1).position({x: fitLine.selfX + "px"}).backgroundColor(Color.Green)
      }

      Button().defaultFocus(true).opacity(0)
    }
    .width("100%").height("100%")
    .onTouch((e)=>{
      if(e.source == SourceType.TouchScreen){
        this.touchInput.onTouchEvent(e, this.menuState, this.eventHandler, this.menuState.screenWidth, this.menuState.screenHeight)
        this.eventHandler?.onTouchEvent(e, this.menuState.screenWidth, this.menuState.screenHeight)
      }
    })
    .onAxisEvent(e=>{
      this.eventHandler?.onAxisEvent(e)
    })
    .onFocusAxisEvent((e)=>{
      this.eventHandler?.onStickAxisEvent(buildStickAxisEvent(e))
    })
    .onAreaChange((e, n)=>{
      let w = vp2px(n.width as number)  || 800;
      let h = vp2px(n.height  as number) || 800;
      this.menuState!.screenWidth = w
      this.menuState!.screenHeight = h
    })
  }
}

function buildStickAxisEvent(event: FocusAxisEvent): StickAxisEvent{
  //左摇杆
  const leftStickX = event.axisMap.get(AxisModel.ABS_X);
  const leftStickY = event.axisMap.get(AxisModel.ABS_Y);

  //右摇杆
  const rightStickX = event.axisMap.get(AxisModel.ABS_Z);
  const rightStickY = event.axisMap.get(AxisModel.ABS_RZ);


  //扳机键
  let rightTrigger = event.axisMap.get(AxisModel.ABS_GAS);
  let leftTrigger = event.axisMap.get(AxisModel.ABS_BRAKE);
  return {deviceId: event.deviceId ?? 0, leftStickX, leftStickY, rightStickX, rightStickY, rightTrigger, leftTrigger} as StickAxisEvent;
}