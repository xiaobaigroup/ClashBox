
export interface StickAxisEvent{
   deviceId: number
   leftTrigger?: number;
   rightTrigger?: number;
   rightStickX?: number;
   rightStickY?: number;
   leftStickX?: number;
   leftStickY?: number;
}

export interface ControllerEventHandler{
  // 键盘事件
  onKeyEvent(e: KeyEvent): void
  // 鼠标事件
  onMouseEvent(e: MouseEvent, x:number, y:number, width: number, height: number ):void
  onAxisEvent(e:AxisEvent):void
  // 触摸事件
  onTouchEvent(e: TouchEvent, width: number, height: number): void
  // 控制器轴事件
  onStickAxisEvent(e: StickAxisEvent): void

  // 发送鼠标按键
  onSendMouseKey(keycode: number, isPress: boolean):void
  // 发送手柄按键
  onSendStickKey(deviceId: number, keycode: number, isPress: boolean): void
  // 虚拟按键事件
  onSendKey(deviceId: number, keycode: number, isPress: boolean):void

  onSendKeysEvent(keycodes: number[]):void

  // 虚拟光标
  onSendCursorPostion(x: number, y: number, deltaX: number, deltaY: number, cursorEnabled: boolean, width: number, height:number): void

}