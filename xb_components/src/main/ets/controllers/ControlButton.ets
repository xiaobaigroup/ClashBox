import {
  BaseInfo,
  ButtonEventAction,
  ControlButtonData,
  ControlButtonStyle,
  ControlDirectionData,
  SizeReference,
  SizeType,
  ViewGroup,
  VisibilityType,
} from './Controller';
import { getAppStore, getPersistence, MenuState } from './MenuButton';
import { fitLine } from './TouchPadView';
import {  ControlButtonViewModel, intToHex } from './ControlButtonViewModel';
import { TouchPadInput } from './TouchPadInput';
import {
  ControllerCodeDict,
  KeyCodeSelector,
  MouseCodeDict,
  VirtualKeyboard, VirtualMouseKey,
  VirtualStickKey } from '../components/keyboard/VirtualKeyboard';
import { Xb_SettingsGroup } from '../view/Xb_SettingsGroup';
import { EventHub, Xb_CustomDialog, Xb_SettingsItemData } from '../../../../Index';
import { ControllerEventHandler } from './ControllerEventHandler';

export enum PublicEvent{
  ButtonStyleUpdated = 90001,
  DirectionStyleUpdated = 90002,

}
export function dip2px(dpValue: number): number {
  return vp2px(dpValue);
}

export function fixColor(color: number) {
  return intToHex(color);
}
export function SendKey(eventHandler: ControllerEventHandler | undefined, keycode: number, press: boolean){
  if(MouseCodeDict.hasKey(keycode)){
    eventHandler?.onSendMouseKey(keycode, press);
  } else if(ControllerCodeDict.hasKey(keycode)){
    eventHandler?.onSendStickKey(-1, keycode, press);
  }else{
    eventHandler?.onSendKey(-1, keycode, press);
  }
}

@Builder
export function KeyboardSelectorDialog(selector: KeyCodeSelector) {
  List() {
    ListItem() {
      Text("键盘")
    }
    ListItem() {
      VirtualKeyboard({
        selector: selector,
      }).backgroundColor(Color.Gray)
    }
    ListItem() {
      Text("鼠标")
    }
    ListItem() {
      VirtualMouseKey({
        selector: selector,
      }).backgroundColor(Color.Gray)
    }
    ListItem() {
      Text("手柄")
    }
    ListItem() {
      VirtualStickKey({
        selector: selector,
      }).backgroundColor(Color.Gray)
    }
  }.layoutWeight(1)
}


@ComponentV2
struct ControlButtonView{
  @Param @Require style: ControlButtonStyle
  @Param text: ResourceStr = ""
  @Param buttonWidth: number = 0
  @Param buttonHeight: number = 0
  @Param isPressed: boolean = false


  private currentStyle(style: ControlButtonStyle): ControlButtonStyle {
    if (this.isPressed) {
      return {
        cornerRadius: style.cornerRadiusPressed,
        strokeWidth: style.strokeWidthPressed,
        strokeColor: style.strokeColorPressed,
        fillColor: style.fillColorPressed,
        textSize: style.textSizePressed,
        textColor: style.textColorPressed,
      } as ControlButtonStyle;
    } else {
      return {
        cornerRadius: style.cornerRadius,
        strokeWidth: style.strokeWidth,
        strokeColor: style.strokeColor,
        fillColor: style.fillColor,
        textSize: style.textSize,
        textColor: style.textColor,
      } as ControlButtonStyle;
    }
  }

  @LocalBuilder
  private buildDirectionButton() {
    Text(this.text || '')
      .width(this.buttonWidth + "px")
      .height(this.buttonHeight + "px")
      .borderRadius(this.currentStyle(this.style).cornerRadius / 10 + "%")
      .borderWidth(this.currentStyle(this.style).strokeWidth / 10)
      .borderColor(fixColor(this.currentStyle(this.style).strokeColor))
      .backgroundColor(fixColor(this.currentStyle(this.style).fillColor))
      .fontSize(this.currentStyle(this.style).textSize)
      .fontColor(fixColor(this.currentStyle(this.style).textColor))
      .textAlign(TextAlign.Center)
      .fontFamily('monospace, HarmonyOS Sans')
  }
  build() {
    this.buildDirectionButton()
  }
}

@ComponentV2
export struct ControlButton {
  @Param @Require data: ControlButtonData
  @Param @Require viewGroup: ViewGroup
  @Param eventHandler?: ControllerEventHandler = undefined
  @Param inGame: boolean = false
  @Local touchInput: TouchPadInput = getAppStore(TouchPadInput)!
  @Local menu: MenuState = getPersistence(MenuState, () => new MenuState())!
  @Local visibilityType: VisibilityType = this.data.baseInfo.visibilityType

  @Local editController: CustomDialogController = new CustomDialogController({
    builder: Xb_CustomDialog({
      titleText: "编辑按钮",
      center: this.ButtonEditDialog,
      buttons:["复制","删除", "确定"],
      onButtonClick: (b,i) => {
        if (i == 0){
          this.viewModel.copy(this.data, this.viewGroup)
        } else if(i == 1){
          this.viewModel.del(this.data, this.viewGroup)
        } else if (i == 2){
          this.visibilityType = this.data.baseInfo.visibilityType
        }
        this.editController?.close()
      }
    }),
    autoCancel: false,
  })
  @Local styleController: CustomDialogController = new CustomDialogController({
    builder: Xb_CustomDialog({
      titleText: "编辑按钮样式",
      center: () => {
        this.StyleEditDialog()
      },
      onButtonClick: (b,i) => {
        if(i == 1){
          this.viewModel.saveStyle()
        }
        this.styleController?.close()
      }
    }),
    autoCancel: false,
  })
  @Local private viewModel: ControlButtonViewModel = getAppStore(ControlButtonViewModel, ()=>new ControlButtonViewModel())!

  @Local private isPressed: boolean = false;
  @Local private isLongPress: boolean = false;
  @Local private isVisible: boolean = true;
  // 触摸状态
  @Local private downX: number = 0;
  @Local private downY: number = 0;
  @Local private initialX: number = 0;
  @Local private initialY: number = 0;
  @Local private positionX: number = 0;
  @Local private positionY: number = 0;
  @Local private buttonWidth: number = 0;
  @Local private buttonHeight: number = 0;
  @Local private downTime: number = 0;
  // 事件状态
  @Local private pressEvent: boolean = false;
  @Local private longPressEvent: boolean = false;
  @Local private doubleClickEvent: boolean = false;
  @Local private clickEvent: boolean = false;
  @Local private clickCount: number = 0;
  @Local private firstClickTime: number = 0;
  @Local private touchId: number = 0;
  @Local autoClickActive: boolean = false;
  @Local autoClickTimer: number = 0;
  @Local style: ControlButtonStyle = this.viewModel.getButtonStyle(this.data.style)

  @Monitor('menu.screenWidth', 'menu.screenHeight')
  infoPropertyChange(monitor: IMonitor) {
    this.updateSizeAndPosition()
  }
  @Monitor('inGame', 'visibilityType')
  updateVisible(monitor: IMonitor) {
    if(this.data.baseInfo.visibilityType == VisibilityType.ALWAYS){
      this.isVisible = true
    }else if(this.data.baseInfo.visibilityType == VisibilityType.IN_GAME && this.inGame){
      this.isVisible = true
    }else if(this.data.baseInfo.visibilityType == VisibilityType.MENU && !this.inGame){
      this.isVisible = true
    }else{
      this.isVisible = false
    }
  }

  aboutToAppear(): void {
    EventHub.on(PublicEvent.ButtonStyleUpdated,(style: ControlButtonStyle)=>{
      if (this.style.name == style.name)
        this.style = style
    }, false)
    this.updateSizeAndPosition()
  }
  updateSizeAndPosition() {
    this.buttonWidth = this.getButtonWidth(this.data.baseInfo)
    this.buttonHeight = this.getButtonHeight(this.data.baseInfo)
    this.positionX = this.buttonPosition.x as number
    this.positionY = this.buttonPosition.y as number
  }

  toEdit() {
    this.viewModel.onUpdate = ()=>{
      this.updateSizeAndPosition()
    }
    this.viewModel.onStyleEdit = ()=>{
      this.styleController.open()
    }
    this.viewModel.updateButtonItems(this.data)
    this.editController.open();
  }

  build() {
    this.buildButtonContent()
  }

  @LocalBuilder
  dialogContent(data: Xb_SettingsItemData) {
    if (data.id == "keyboard") {
      KeyboardSelectorDialog(this.viewModel.keySelector);
    }
    if (data.id == "styleList") {
      Xb_SettingsGroup({items:this.viewModel.styleListSettings}).layoutWeight(1)
    }
    if (data.id == "viewGroup") {
      Xb_SettingsGroup({items:this.viewModel.viewGroupSettings}).layoutWeight(1)
    }
  }

  @LocalBuilder
  private ButtonEditDialog() {
    Xb_SettingsGroup({ items: this.viewModel.editSettings, dialogContent: this.dialogContent, }).layoutWeight(1)
  }

  @LocalBuilder
  private StyleEditDialog() {
    ControlButtonView({text:this.data.text, style: this.viewModel.styleEdited, buttonWidth: dip2px(50), buttonHeight:dip2px(50)})
    Xb_SettingsGroup({ items: this.viewModel.styleEditSettings, dialogContent: this.dialogContent }).layoutWeight(1)
  }

  @Builder
  private buildButtonContent() {
    Stack() {
      // 边界显示
      if (this.menu.showViewBoundaries) {
        this.buildBoundary()
      }
      ControlButtonView({text:this.data.text, style: this.style, buttonWidth:this.buttonWidth, buttonHeight: this.buttonHeight, isPressed: this.isPressed})
    }.onTouch( e=> this.handleTouch(e))
    .position({ x: this.positionX + "px", y: this.positionY + "px" })
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }
  @Builder
  buildBoundary() {
    Row()
      .width(this.buttonWidth + "px")
      .height(this.buttonHeight + "px")
      .borderWidth(2)
      .borderColor($r("app.color.divider"))
      .borderStyle(BorderStyle.Solid)
  }



  handleTouch(event: TouchEvent) {
    if (this.menu.editMode) {
      this.handleEditModeTouch(event);
    } else {
      this.handleGameModeTouch(event);
    }
  }

  handler = 0;
  private findTouch(event: TouchEvent, touchId: number): TouchObject {
    return event.changedTouches.find(d => d.id == touchId) ?? event.changedTouches[0]
  }

  private handleEditModeTouch(event: TouchEvent): void {
    let x = vp2px(event.changedTouches[0].x);
    let y = vp2px(event.changedTouches[0].y);
    switch (event.type) {
      case TouchType.Down:
        this.downX = x;
        this.downY = y;
        this.initialX = this.positionX;
        this.initialY = this.positionY;
        this.downTime = new Date().getTime();
        break;
      case TouchType.Move:
        const widthDelta = this.menu.screenWidth - this.buttonWidth
        const heightDelta = this.menu.screenHeight - this.buttonHeight
        const targetX = Math.max(0, Math.min(widthDelta, this.initialX + x - this.downX));
        const targetY = Math.max(0, Math.min(heightDelta, this.initialY + y - this.downY));
        this.positionX = targetX
        this.positionY = targetY
        this.data.baseInfo.xPosition = this.positionX / Math.max(1, widthDelta) * 1000
        this.data.baseInfo.yPosition = this.positionY / Math.max(1,heightDelta) * 1000
        this.autoFitPosition()
        break;
      case TouchType.Up:
      case TouchType.Cancel:
        fitLine.removeLine(0);
        fitLine.removeLine(1);
        if (Math.abs(x - this.downX) <= 10
          && Math.abs(y - this.downY) <= 10
          && new Date().getTime() - this.downTime <= 400) {
          this.toEdit()
        }
        break;
    }
  }

  private autoFitPosition() {
    if (!this.menu.autoFit) {
      return
    }
    const dist = vp2px(Math.max(this.menu.autoFitDist, 2));
    const xyPref = [false, false];
    const prefXY = [0, 0];
    const selfXY = [0, 0];
    const xyDist = [dist, dist];
    let left = this.positionX;
    let right = this.positionX + this.buttonWidth;
    let up = this.positionY;
    let down = this.positionY + this.buttonHeight;
    const posArr = [left, right, up, down];
    const dataList: (ControlButtonData | ControlDirectionData) [] =
      [...this.viewGroup.viewData.buttonList, ...this.viewGroup.viewData.directionList]
    for (let button of dataList) {
      if (button.id == this.data.id) {
        continue;
      }
      const position = this.getButtonPosition(button.baseInfo)
      const buttonPosArr = [
        position.x as number,
        position.x as number + this.getButtonWidth(button.baseInfo),
        position.y as number,
        position.y as number + this.getButtonHeight(button.baseInfo)
      ];
      let flag = -1;
      for (let j = 0; j < posArr.length; j++) {
        flag *= -1;
        let xyIndex = j / 2 % 2;
        if (Math.abs(posArr[j] - buttonPosArr[j]) < xyDist[xyIndex]) {
          xyPref[xyIndex] = true;
          prefXY[xyIndex] = buttonPosArr[j];
          xyDist[xyIndex] = posArr[j] - buttonPosArr[j];
          selfXY[xyIndex] = posArr[j] - xyDist[xyIndex];
        }
        let buttonDist = posArr[j] - buttonPosArr[j + flag];
        if (flag * buttonDist >= 0 && flag * buttonDist < xyDist[xyIndex]) {
          xyPref[xyIndex] = true;
          prefXY[xyIndex] = buttonPosArr[j + flag];
          xyDist[xyIndex] = buttonDist - flag * dist;
          selfXY[xyIndex] = posArr[j] - xyDist[xyIndex];
        }
      }
    }
    if (xyPref[0]) {
      this.positionX = left - xyDist[0]
      fitLine.showLine(0, prefXY[0], selfXY[0]);
    } else {
      fitLine.removeLine(0);
    }
    if (xyPref[1]) {
      this.positionY = up - xyDist[1]
      fitLine.showLine(1, prefXY[1], selfXY[1]);
    } else {
      fitLine.removeLine(1);
    }
  }

  private handleGameModeTouch(event: TouchEvent): void {
    if (event.type == TouchType.Down) {
      this.touchId = event.changedTouches[0].id
    }
    let touch = this.findTouch(event, this.touchId)
    let x = vp2px(touch.x);
    let y = vp2px(touch.y);
    switch (event.type) {
      case TouchType.Down:
        this.isPressed = true;
        this.downX = x;
        this.downY = y;
        this.initialX = this.menu.cursorEnabled
          ? this.touchInput.cursorX
          : this.touchInput.pointerX;
        this.initialY = this.menu.cursorEnabled
          ? this.touchInput.cursorY
          : this.touchInput.pointerY;
        this.positionX = this.buttonPosition.x as number;
        this.positionY = this.buttonPosition.y as number;
        this.downTime = Date.now();
        // 处理按下事件
        this.handlePressEvent(!this.pressEvent);
        this.handler = setTimeout(() => {
          this.handleLongPressEvent(!this.longPressEvent);
        }, 400);
        break;
      case TouchType.Move:
        this.handleMoveEvent(x, y)
        if ((Math.abs(x - this.downX) > 2 || Math.abs(y - this.downY) > 2) && Date.now() - this.downTime < 400) {
          clearTimeout(this.handler)
        }
        break;
      case TouchType.Up:
      case TouchType.Cancel:
        this.handleTouchEnd(x, y);
        this.touchId = 0;
        break;
    }
  }

  private handleMoveEvent(x: number, y: number) {
    // 指针跟随
    if (this.data.event.pointerFollow) {
      const deltaX = (x - this.downX) * this.menu.mouseSensitivity;
      const deltaY = (y - this.downY) * this.menu.mouseSensitivity;

      if (this.menu.cursorEnabled) {
        const targetX = Math.max(0, Math.min(this.menu.screenWidth, this.initialX + deltaX));
        const targetY = Math.max(0, Math.min(this.menu.screenWidth, this.initialY + deltaY));
        this.touchInput.setPointer(targetX, targetY, this.menu.cursorEnabled, this.eventHandler, this.menu.screenWidth, this.menu.screenHeight);
      } else {
        if (this.touchInput.enableGyroscope) {
          this.touchInput.pointerX = this.initialX + deltaX;
          this.touchInput.pointerY = this.initialY + deltaY;
        } else {
          this.touchInput.setPointer(this.initialX + deltaX, this.initialY + deltaY, this.menu.cursorEnabled, this.eventHandler, this.menu.screenWidth, this.menu.screenHeight);
        }
      }
    }

    // 可移动
    if (this.data.event.Movable) {
      const deltaX = x - this.downX;
      const deltaY = y - this.downY;

      let targetX = this.positionX + deltaX;
      let targetY = this.positionY + deltaY;

      targetX = Math.max(0, Math.min(this.menu.screenWidth - this.getButtonHeight(this.data.baseInfo), targetX));
      targetY = Math.max(0, Math.min(this.menu.screenWidth - this.getButtonHeight(this.data.baseInfo), targetY));
      this.positionX = targetX
      this.positionY = targetY
    }
  }

  private handleTouchEnd(x: number, y: number): void {
    if (!this.data.event.pressEvent.autoKeep && !(this.data.event.longPressEvent.autoKeep && this.longPressEvent)) {
      this.isPressed = false
    }
    // if (Objects.equals(menu.getInput().getPointerId(), getData().getId())) {
    //   menu.getInput().setPointerId(null);
    // }
    clearTimeout(this.handler)
    this.handleUpAfterPressEvent();
    if (this.isLongPress) {
      this.handleUpAfterLongPressEvent();
    }
    // 判断点击事件
    if (Date.now() - this.downTime <= 100 &&
      Math.abs(x - this.downX) <= 10 &&
      Math.abs(y - this.downY) <= 10) {
      this.handleClickEvent(!this.clickEvent);
      this.clickCount++;
      if (this.clickCount == 1) {
        this.firstClickTime = Date.now();
      }
      if (this.clickCount == 2) {
        if (Date.now() - this.firstClickTime < 400) {
          this.handleDoubleEvent(!this.doubleClickEvent);
          this.clickCount = 0;
        } else {
          this.clickCount = 1;
          this.firstClickTime = Date.now();
        }
      }
    }

  }
  private handleDoubleEvent(enable: boolean) {
    this.doubleClickEvent = enable;
    this.handleTickEvent(enable, this.data.event.doubleClickEvent, 3);
  }

  private handlePressEvent(enable: boolean): void {
    this.pressEvent = enable;
    this.handleTickEvent(enable, this.data.event.pressEvent, 0);
  }

  private handleLongPressEvent(enable: boolean): void {
    this.isLongPress = true;
    this.longPressEvent = enable;
    this.handleTickEvent(enable, this.data.event.longPressEvent, 1);
  }

  private handleUpAfterLongPressEvent(): void {
    this.isLongPress = false;
    this.handleUpEvent(this.data.event.longPressEvent);
  }

  private handleUpAfterPressEvent(): void {
    this.handleUpEvent(this.data.event.pressEvent);
  }

  private handleUpEvent(event: ButtonEventAction): void {
    if (!event.autoKeep) {
      if (event.autoClick) {
        this.handleAutoClick(event, false);
      } else {
        this.handleKeyEvent(event, false);
      }
    }
  }

  // 处理键盘事件
  private handleKeyEvent(event: ButtonEventAction, press: boolean): void {
    if (event.outputKeycodes.length === 0) {
      return;
    }
    for (const keycode of event.outputKeycodes) {
      SendKey(this.eventHandler, keycode, press)
    }
  }

  private handleClickEvent(enable: boolean): void {
    this.clickEvent = enable;
    this.handleTickEvent(enable, this.data.event.clickEvent, 2);
  }



  private handleAutoClick(event: ButtonEventAction, enable: boolean): void {
    this.autoClickActive = enable;

    if (enable) {
      this.autoClickTimer = setInterval(() => {
        this.handleKeyEvent(event, true);
        this.handleKeyEvent(event, false);
      }, 20);
    } else if (this.autoClickTimer !== 0) {
      clearInterval(this.autoClickTimer);
      this.autoClickTimer = 0;
    }
  }

  private handleTickEvent(enable: boolean, event: ButtonEventAction, eventType: number): void {
    if (event.autoKeep) {
      if (event.autoClick) {
        this.handleAutoClick(event, enable);
      } else {
        this.handleKeyEvent(event, enable);
      }
      this.isPressed = enable;
    } else {
      switch (eventType) {
        case 0: // 按下
        case 1: // 长按
          if (event.autoClick) {
            this.handleAutoClick(event, true);
          } else {
            this.handleKeyEvent(event, true);
          }
          break;
        case 2: // 单击
        case 3: // 双击
          this.handleKeyEvent(event, true);
          this.handleKeyEvent(event, false);
          break;
      }
    }

    // 处理其他事件类型
    if (event.openMenu) {
      this.menu.switchMenuSettings()
    }

    if (event.switchTouchMode) {
      this.menu.switchGestureMode();
    }

    if (event.switchMouseMode) {
      this.menu.switchMouseMode();
    }

    if (event.input) {
      this.menu.toggleKeyboard();
    }

    if (event.quickInput) {
      this.menu.openQuickInput();
    }

    const outputText = event.outputText;
    if (outputText && outputText.length > 0) {
      this.handleTextOutput(outputText);
    }
    this.viewModel.switchViewGroupVisibility(event)
  }

  // 处理文本输出
  private handleTextOutput(text: string): void {
    // if (this.menu.getCursorMode() === CURSOR_ENABLED) {
    //   for (let i = 0; i < text.length; i++) {
    //     this.menu.getInput().sendChar(text.charAt(i));
    //   }
    // } else {
    //   this.menu.getInput().sendKeyEvent(20, true); // T键
    //   this.menu.getInput().sendKeyEvent(20, false);
    //
    //   setTimeout(() => {
    //     for (let i = 0; i < text.length; i++) {
    //       this.menu.getInput().sendChar(text.charAt(i));
    //     }
    //     this.menu.getInput().sendKeyEvent(28, true); // 回车键
    //     this.menu.getInput().sendKeyEvent(28, false);
    //   }, 150);
    // }
  }



  private get buttonPosition(): Position {
    const baseInfo = this.data.baseInfo;
    const width = this.buttonWidth;
    const height = this.buttonHeight;
    const xValue = (this.menu.screenWidth - width) * (baseInfo.xPosition / 1000);
    const yValue = (this.menu.screenHeight - height) * (baseInfo.yPosition / 1000);
    return { x: xValue, y: yValue };
  }

  private getButtonPosition(baseInfo: BaseInfo): Position {
    const width = this.getButtonWidth(baseInfo);
    const height = this.getButtonHeight(baseInfo);
    const xValue = (this.menu.screenWidth - width) * (baseInfo.xPosition / 1000);
    const yValue = (this.menu.screenHeight - height) * (baseInfo.yPosition / 1000);
    return { x: xValue, y: yValue };
  }

  private getButtonWidth(data: BaseInfo): number {
    const baseInfo = data;
    if (baseInfo.sizeType === SizeType.ABSOLUTE) {
      return vp2px(baseInfo.absoluteWidth);
    } else {
      const reference = baseInfo.percentageWidth.reference == SizeReference.SCREEN_WIDTH
        ? this.menu.screenWidth
        : this.menu.screenHeight;
      return reference * (baseInfo.percentageWidth.size / 1000);
    }
  }

  private getButtonHeight(data: BaseInfo): number {
    const baseInfo = data;
    if (baseInfo.sizeType === SizeType.ABSOLUTE) {
      return vp2px(baseInfo.absoluteHeight);
    } else {
      const reference = baseInfo.percentageHeight.reference == SizeReference.SCREEN_WIDTH
        ? this.menu.screenWidth
        : this.menu.screenHeight;
      return reference * (baseInfo.percentageHeight.size / 1000);
    }
  }
}