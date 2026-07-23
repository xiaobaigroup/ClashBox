import { Xb_GameMenuState } from "../../../../Index";
import { MouseButtonCode } from "../components/keyboard/VirtualKeyboard";
import { ControllerEventHandler } from "./ControllerEventHandler";
import { CursorMoveType } from "./MenuButton";

@ObservedV2
export class TouchPadInput {
  enableGyroscope: boolean = false
  pointerX: number = 0;
  pointerY: number = 0;
  // 虚拟鼠标
  @Trace cursorX: number = 0;
  @Trace cursorY: number = 0;

  initialX: number = 0;
  initialY: number = 0;
  downX: number = 0;
  downY: number = 0;
  downTime: number = 0;
  runnable: number = 0;
  cancelMouseLeft: boolean = false
  cancelMouseRight: boolean = false
  onTouchEvent(e: TouchEvent, menu: Xb_GameMenuState, handler: ControllerEventHandler| undefined, width:number, height: number){
    const x = vp2px(e.changedTouches[0].x);
    const y = vp2px(e.changedTouches[0].y);
    if(menu.cursorEnabled){

      if (menu.cursorMoveType == CursorMoveType.Click) {
        handler?.onSendCursorPostion(x, y, 0, 0, menu.cursorEnabled, width, height)
        this.cursorX = x;
        this.cursorY = y;
        switch (e.type) {
          case TouchType.Down: {
            setTimeout(()=>{
              handler?.onSendMouseKey(MouseButtonCode.Left, true);
            })
            break;
          }
          case TouchType.Cancel:
          case TouchType.Up: {
            setTimeout(()=>{
              handler?.onSendMouseKey(MouseButtonCode.Left, false);
            })
            break;
          }
        }
      }else{
        switch (e.type) {
          case TouchType.Down: {
            this.downX = x
            this.downY = y;
            this.downTime = new Date().getTime()
            this.initialX = this.cursorX
            this.initialY = this.cursorY
            break;
          }
          case TouchType.Move:{
            let deltaX = x - this.downX
            let deltaY = y - this.downY
            let targetX = this.initialX + deltaX;
            let targetY = this.initialY + deltaY;
            this.cursorX = targetX;
            this.cursorX = targetY;
          }
          case TouchType.Cancel:
          case TouchType.Up: {
            if (new Date().getTime() - this.downTime <= 100
              && Math.abs(x - this.downX) <= 10
              && Math.abs(y - this.downY) <= 10) {
              handler?.onSendMouseKey(MouseButtonCode.Left, true);
              handler?.onSendMouseKey(MouseButtonCode.Left, false);
            }
            break;
          }
        }
      }
    } else {
      if (menu.isDisableLeftTouch && x <= width / 2) {
        return;
      }
      switch (e.type){
        case TouchType.Down: {
          this.downX = x
          this.downY = y;
          this.downTime = new Date().getTime()
          this.initialX = this.pointerX
          this.initialY = this.pointerY
          this.runnable = setTimeout(()=>{
            this.cancelMouseLeft = true;
            this.cancelMouseRight = false;
            handler?.onSendMouseKey(MouseButtonCode.Left, true);
            // if (getGestureMode() == GestureMode.BUILD) {
            //   handler?.onSendMouseKey(MouseButtonCode.Left, true);
            //   cancelMouseLeft = true;
            //   cancelMouseRight = false;
            // } else {
            //   gameMenu.getInput().sendKeyEvent(FCLInput.MOUSE_RIGHT, true);
            //   cancelMouseRight = true;
            //   cancelMouseLeft = false;
            // }
          },400)
        }
          break;
        case TouchType.Move:{
          let deltaX = x - this.downX
          let deltaY = y - this.downY
          let targetX = this.initialX + deltaX ;
          let targetY = this.initialY + deltaY;
          if ((Math.abs(deltaX) > 1 || Math.abs(deltaY) > 1) && new Date().getTime() - this.downTime < 400) {
            clearTimeout(this.runnable)
          }
          this.pointerX = targetX;
          this.pointerY = targetY;
          handler?.onSendCursorPostion(targetX, targetY, deltaX, deltaY, menu.cursorEnabled, width, height)
        }
          break;
        case TouchType.Cancel:
        case TouchType.Up:
          {
            clearTimeout(this.runnable)
            if (this.cancelMouseLeft) {
              handler?.onSendMouseKey(MouseButtonCode.Left, false);
            }
            if (this.cancelMouseRight) {
              handler?.onSendMouseKey(MouseButtonCode.Right, false);
            }
            this.cancelMouseLeft = false;
            this.cancelMouseRight = false;
            if (new Date().getTime() - this.downTime <= 100
              && Math.abs(x - this.downX) <= 10
              && Math.abs(y - this.downY) <= 10) {
              handler?.onSendMouseKey(MouseButtonCode.Left, true);
              handler?.onSendMouseKey(MouseButtonCode.Left, false);
            }
          }
          break;
      }
    }
  }


  setPointer(x: number, y: number, cursorEnabled: boolean, handler: ControllerEventHandler | undefined, width:number, height: number){
    if (cursorEnabled) {
      this.cursorX = x;
      this.cursorY = y;
    }
    this.pointerX = x;
    this.pointerY = y;
    handler?.onSendCursorPostion(x, y, 0, 0, cursorEnabled, width, height)
  }
  movePointer(x: number, y: number, cursorEnabled: boolean, handler: ControllerEventHandler | undefined, width:number, height: number){
    if (cursorEnabled) {
      this.cursorX += x;
      this.cursorY += y;
      handler?.onSendCursorPostion(this.cursorX, this.cursorY, x, y, cursorEnabled, width, height)
    }else{
      this.pointerX += x;
      this.pointerY += y;
      handler?.onSendCursorPostion(this.pointerX, this.pointerY, x, y, cursorEnabled, width, height)
    }

  }
}