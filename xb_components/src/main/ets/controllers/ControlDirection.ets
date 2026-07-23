import { dip2px, fixColor, KeyboardSelectorDialog, PublicEvent, SendKey } from './ControlButton';
import { ControlDirectionData, SizeType, SizeReference, ControlDirectionStyle, DirectionStyleType,
  FollowOption,
  VisibilityType,
  ControlButtonData,
  BaseInfo,
  ViewGroup,
  StickPosition,
  } from './Controller';
import { getAppStore, getPersistence, MenuState } from './MenuButton';
import { fitLine } from './TouchPadView';
import { ControlButtonViewModel} from './ControlButtonViewModel';
import { ControlDirectionViewModel } from './ControlDirectionViewModel';
import { Xb_CustomDialog } from '../components/Xb_CustomDialog';
import { Xb_SettingsItemData } from '../model/SettingsItem';
import { Xb_SettingsGroup } from '../view/Xb_SettingsGroup';
import { EventHub } from '../utils/EventHub';
import { ControllerEventHandler, StickAxisEvent } from './ControllerEventHandler';

enum Direction {
  DIRECTION_LEFT,
  DIRECTION_RIGHT,
  DIRECTION_UP,
  DIRECTION_DOWN,
  DIRECTION_UP_LEFT,
  DIRECTION_UP_RIGHT,
  DIRECTION_DOWN_LEFT,
  DIRECTION_DOWN_RIGHT,
  DIRECTION_CENTER
}
function radian2Angle(radian: number) :number{
  const tmp = Math.round(radian / Math.PI * 180);
  return tmp >= 0 ? tmp : 360 + tmp;
}

function buildDirectionButtonData(text: string, x: number, y: number, size: number, direction: Direction): DirectionButtonData {
  return  { label:text, x:x, y:y, size: size, direction:direction};
}

class DirectionButtonData {
  label:string = ""
  x: number = 0
  y: number = 0
  size: number = 0
  direction:Direction = Direction.DIRECTION_CENTER
}
function makeDirectionButton(p1: number, p2: number, buttonSize : number, activeDirection: Direction): DirectionButtonData[]{
  const buttons =  [
    buildDirectionButtonData('◆', p1, p1, buttonSize, -1),
    // 方向按钮
    buildDirectionButtonData('▲', p1, 0, buttonSize, Direction.DIRECTION_UP),
    buildDirectionButtonData('▼', p1, p2, buttonSize, Direction.DIRECTION_DOWN),
    buildDirectionButtonData('◀', 0, p1, buttonSize, Direction.DIRECTION_LEFT),
    buildDirectionButtonData('▶ ', p2, p1, buttonSize, Direction.DIRECTION_RIGHT)
  ]
  if (activeDirection === Direction.DIRECTION_UP_LEFT ||
    activeDirection === Direction.DIRECTION_UP ||
    activeDirection === Direction.DIRECTION_LEFT) {
    buttons.push(buildDirectionButtonData('◤', 0, 0, buttonSize, Direction.DIRECTION_UP_LEFT))
  }

  if (activeDirection === Direction.DIRECTION_UP_RIGHT ||
    activeDirection === Direction.DIRECTION_UP ||
    activeDirection === Direction.DIRECTION_RIGHT) {
    buttons.push(buildDirectionButtonData('◥', p2, 0, buttonSize, Direction.DIRECTION_UP_RIGHT))
  }
  if (activeDirection === Direction.DIRECTION_DOWN_LEFT ||
    activeDirection === Direction.DIRECTION_DOWN ||
    activeDirection === Direction.DIRECTION_LEFT) {
    buttons.push(buildDirectionButtonData('◣', 0, p2, buttonSize, Direction.DIRECTION_DOWN_LEFT))
  }
  if (activeDirection === Direction.DIRECTION_DOWN_RIGHT ||
    activeDirection === Direction.DIRECTION_DOWN ||
    activeDirection === Direction.DIRECTION_RIGHT) {
    buttons.push(buildDirectionButtonData('◢', p2, p2, buttonSize, Direction.DIRECTION_DOWN_RIGHT))
  }
  return buttons;
}
@ComponentV2
struct ControlDirectionView{
  @Param @Require style: ControlDirectionStyle
  @Param activeDirection: Direction = Direction.DIRECTION_CENTER
  @Param viewSize: number = 0

  @Param rockerX: number = 0
  @Param rockerY: number =  0
  @Local rockerRawX: number = 0
  @Local rockerRawY: number = 0

  @Local rockerSize: number = 0



  @Local menu: MenuState = getPersistence(MenuState, ()=>new MenuState())!

  @Local buttons: DirectionButtonData[] = []
  private get buttonSize(){
    if (this.style.styleType === DirectionStyleType.BUTTON) {
      return (this.viewSize * (1000 - (2 * (this.style.buttonStyle.interval ?? 0) ))) / 3000;
    }
    return 0;
  }
  @Monitor("style", "viewSize", "activeDirection")
  updateButtons(){
    this.buttons = makeDirectionButton(this.buttonSize + (this.viewSize * (this.style.buttonStyle?.interval ?? 0)) / 1000, this.viewSize - this.buttonSize, this.buttonSize, this.activeDirection)
  }
  @Monitor("style","viewSize")
  updateRockerSize() {
    this.rockerSize = (this.viewSize * this.style.rockerStyle.rockerSize) / 1000;
    this.rockerRawX = (this.viewSize / 2) - (this.rockerSize / 2)
    this.rockerRawY = (this.viewSize / 2) - (this.rockerSize / 2)
  }
  @Monitor( "rockerX", "rockerY")
  updateRockerXY() {
    this.rockerRawX = this.rockerX
    this.rockerRawY = this.rockerY
  }


  aboutToAppear(): void {
    this.buttons = makeDirectionButton(this.buttonSize + (this.viewSize * (this.style.buttonStyle.interval ?? 0)) / 1000, this.viewSize - this.buttonSize, this.buttonSize, this.activeDirection)
    this.updateRockerSize()
  }

  @LocalBuilder
  private buildDirectionButton(text: string, x: number, y: number, size: number, direction: Direction) {
    Text(text)
      .width(size + "px")
      .height(size + "px")
      .position({ x: `${x}px`, y: `${y}px` })
      .borderRadius(this.activeDirection == direction ? this.buttonStyle(this.style).cornerRadiusPressed / 10 : this.buttonStyle(this.style).cornerRadius / 10)
      .borderWidth(this.activeDirection == direction ? this.buttonStyle(this.style).strokeWidthPressed / 10 : this.buttonStyle(this.style).strokeWidth / 10)
      .borderColor(fixColor(this.activeDirection == direction ? this.buttonStyle(this.style).strokeColorPressed : this.buttonStyle(this.style).strokeColor))
      .backgroundColor(fixColor(this.activeDirection == direction ? this.buttonStyle(this.style).fillColorPressed : this.buttonStyle(this.style).fillColor))
      .fontSize(this.activeDirection == direction ? this.buttonStyle(this.style).textSizePressed : this.buttonStyle(this.style).textSize)
      .fontColor(fixColor(this.activeDirection == direction ? this.buttonStyle(this.style).textColorPressed : this.buttonStyle(this.style).textColor))
      .textAlign(TextAlign.Center)
      .fontFamily('monospace, HarmonyOS Sans')
  }
  @Builder
  private buildRockerMode() {
    Stack({ alignContent: Alignment.Center }) {
      // 摇杆背景
      Rect()
        .width(this.viewSize + "px")
        .height(this.viewSize + "px")
        .fill(fixColor(this.rockerStyle(this.style).bgFillColor))
        .strokeWidth(0)
        .borderColor(this.rockerStyle(this.style).bgStrokeColor)
        .borderRadius(this.rockerStyle(this.style).bgCornerRadius / 10 + "%")
        .borderWidth(this.rockerStyle(this.style).bgStrokeWidth / 10)
      // 摇杆
      Text()
        .width(this.rockerSize + "px")
        .height(this.rockerSize + "px")
        .position({ x: `${this.rockerRawX}px`, y: `${this.rockerRawY}px` })
        .backgroundColor(fixColor(this.rockerStyle(this.style).rockerFillColor))
        .borderWidth(this.rockerStyle(this.style).rockerStrokeWidth / 10)
        .borderColor(this.rockerStyle(this.style).rockerStrokeColor)
        .borderRadius(this.rockerStyle(this.style).rockerCornerRadius / 10 + "%")
    }
    .width(this.viewSize + "px")
    .height(this.viewSize + "px")
  }

  private buttonStyle(style: ControlDirectionStyle){
    return style.buttonStyle
  }
  private rockerStyle(style: ControlDirectionStyle){
    return style.rockerStyle
  }
  build() {
    if (this.style.styleType == DirectionStyleType.BUTTON) {
      Stack({ alignContent: Alignment.TopStart }) {
        // 中心按钮
        ForEach(this.buttons, (b:DirectionButtonData)=>{
          this.buildDirectionButton(b.label,b.x,b.y, b.size, b.direction)
        })
      }.width(this.viewSize + "px")
      .height(this.viewSize + "px")
    } else {
      this.buildRockerMode()
    }
  }
}



@ComponentV2
export struct ControlDirection {
  @Param @Require data: ControlDirectionData;
  @Param @Require viewGroup: ViewGroup
  @Param inGame: boolean = false
  @Local viewModel: ControlDirectionViewModel = getAppStore(ControlDirectionViewModel,()=>new ControlDirectionViewModel())!
  @Local buttonViewModel: ControlButtonViewModel = getAppStore(ControlButtonViewModel,()=>new ControlButtonViewModel())!
  @Local menu: MenuState = getPersistence(MenuState, ()=>new MenuState())!
  @Param eventHandler?: ControllerEventHandler = undefined

  @Local dialogController: CustomDialogController = new CustomDialogController({
    builder: Xb_CustomDialog({
      titleText: "编辑方向盘",
      buttons:["复制","删除", "确定"],
      center: this.EditDialog,
      onButtonClick: (b,i)=>{
        if (i == 0) {
          this.viewModel.copy(this.data, this.viewGroup)
        } else if(i == 1){
          this.viewModel.del(this.data, this.viewGroup)
        } else if (i == 2){
          this.visibilityType = this.data.baseInfo.visibilityType
        }
        this.dialogController?.close()
      }
    }),
    autoCancel:false,
  })
  @Local styleController: CustomDialogController = new CustomDialogController({
    builder: Xb_CustomDialog({
      titleText: "编辑方向盘样式",
      center: this.StyleEditDialog,
      onButtonClick: (b,i)=>{
        if(i == 1){
          this.viewModel.saveStyle()
        }
        this.styleController?.close()
      }
    }),
    autoCancel:false,
  })
  @Local visibilityType: VisibilityType = this.data.baseInfo.visibilityType
  @Local isVisible: boolean = true;


  @Local private downX: number = 0;
  @Local private downY: number = 0;
  @Local private initialX: number = 0;
  @Local private initialY: number = 0;
  @Local private positionX: number = 0;
  @Local private positionY: number = 0;
  @Local downTime: number = 0;

  @Local activeDirection: number = Direction.DIRECTION_CENTER;
  @Local clickCount: number = 0;
  @Local firstClickTime: number = 0;
  @Local doubleClickEvent: boolean = false;
  @Local startClick: boolean = false;
  @Local startRecord: boolean = false;

  @Local rockerX: number = 0;
  @Local rockerY: number = 0;
  @Local rockerSize: number = 0;

  @Local viewSize: number = 0;
  @Local buttonSize: number = 0;
  @Local screenWidth: number = 0
  @Local screenHeight: number =  0

  @Local touchId: number = 0

  @Local style: ControlDirectionStyle = this.viewModel.getDirectionStyle(this.data.style)

  @Monitor('viewSize', 'style')
  updateButtonSize(monitor: IMonitor) {
    if (this.style.styleType === DirectionStyleType.BUTTON) {
      this.buttonSize = (this.viewSize * (1000 - (2 * (this.style.buttonStyle.interval ?? 0) ))) / 3000;
    } else {
      this.updateSizeAndPosition()
    }
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

  @Monitor('menu.screenWidth', 'menu.screenHeight')
  infoPropertyChange(monitor: IMonitor) {
    this.initSizeAndPosition()
  }
  initSizeAndPosition(){
    this.screenWidth = this.menu.screenWidth
    this.screenHeight = this.menu.screenHeight
    this.updateSizeAndPosition()
  }
  updateSizeAndPosition(){
    this.viewSize = this.getSize(this.data.baseInfo)
    this.rockerSize = (this.viewSize * this.style.rockerStyle.rockerSize) / 1000;
    this.rockerX = (this.viewSize / 2) - (this.rockerSize / 2)
    this.rockerY = (this.viewSize / 2) - (this.rockerSize / 2)
    this.positionX = this.viewPosition.x as number
    this.positionY = this.viewPosition.y as number
  }
  aboutToAppear(): void {
    EventHub.on(PublicEvent.DirectionStyleUpdated, (style: ControlDirectionStyle)=>{
        this.style = style
    })
    this.initSizeAndPosition()
  }

  toEdit(){
    this.viewModel.onUpdate = ()=>{
      this.updateSizeAndPosition()
    }
    this.viewModel.onStyleEdit = ()=>{
      this.styleController.open()
    }
    this.viewModel.updateDirectionItems(this.data)
    this.dialogController.open();
  }



  private readonly ANGLE_0: number = 0;
  private readonly ANGLE_360: number = 360;
  private readonly ANGLE_8D_OF_0P: number = 22.5;
  private readonly ANGLE_8D_OF_1P: number = 67.5;
  private readonly ANGLE_8D_OF_2P: number = 112.5;
  private readonly ANGLE_8D_OF_3P: number = 157.5;
  private readonly ANGLE_8D_OF_4P: number = 202.5;
  private readonly ANGLE_8D_OF_5P: number = 247.5;
  private readonly ANGLE_8D_OF_6P: number = 292.5;
  private readonly ANGLE_8D_OF_7P: number = 337.5;

  private get viewPosition(): Position {
    const baseInfo = this.data.baseInfo;
    return this.getViewPosition(baseInfo);
  }
  private getViewPosition(baseInfo: BaseInfo): Position {
    const size = this.getSize(baseInfo);
    const xValue = (this.screenWidth - size) * (baseInfo.xPosition / 1000);
    const yValue = (this.screenHeight - size) * (baseInfo.yPosition / 1000);
    return { x: xValue, y: yValue };
  }
  private getSize(baseInfo: BaseInfo): number {
    if (baseInfo.sizeType === SizeType.ABSOLUTE) {
      return dip2px(baseInfo.absoluteWidth);
    } else {
      const reference = baseInfo.percentageWidth.reference == SizeReference.SCREEN_WIDTH
        ? this.screenWidth
        : this.screenHeight;
      return reference * (baseInfo.percentageWidth.size / 1000);
    }
  }

  build() {
    this.buildMainView()
  }

  @LocalBuilder
  dialogContent(data: Xb_SettingsItemData) {
    if (data.id == "keyboard") {
      KeyboardSelectorDialog(this.viewModel.keySelector);
    }
    if (data.id == "styleList") {
      Xb_SettingsGroup({items: this.viewModel.styleListSettings}).layoutWeight(1)
    }
    if(data.id == "buttonStyleList"){
      Xb_SettingsGroup({items: this.buttonViewModel.styleListSettings}).layoutWeight(1)
    }
  }
  @LocalBuilder
  private StyleEditDialog() {
    ControlDirectionView({style: this.viewModel.styleEdited, viewSize: dip2px(50),})
    Xb_SettingsGroup({ items: this.viewModel.styleEditSettings, dialogContent: this.dialogContent}).layoutWeight(1)
  }
  @LocalBuilder
  private EditDialog(){
    Xb_SettingsGroup({items:this.viewModel.editSettings, dialogContent: this.dialogContent}).layoutWeight(1)
  }
  @Builder
  private buildBoundary() {
    Row()
      .width(this.viewSize + "px")
      .height(this.viewSize + "px")
      .borderWidth(2)
      .borderColor($r("app.color.divider"))
      .borderStyle(BorderStyle.Solid)
  }
  // 构建主视图
  @Builder
  private buildMainView() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 边界显示
      if (this.menu.showViewBoundaries) {
        this.buildBoundary()
      }
      ControlDirectionView({
        style: this.style,
        activeDirection: this.activeDirection,
        viewSize: this.viewSize,
        rockerX: this.rockerX,
        rockerY: this.rockerY
      })
    }
    .width(this.viewSize + "px")
    .height(this.viewSize + "px")
    .position({ x: this.positionX + "px", y: this.positionY + "px" })
    .onTouch((event: TouchEvent) => {
      this.handleTouch(event);
    })
    .visibility(this.isVisible ? Visibility.Visible : Visibility.None)
  }

  handleTouch(event: TouchEvent){
    if (this.menu.editMode) {
      this.handleEditModeTouch(event);
    } else {
      this.handleGameModeTouch(event);
    }
  }
  private handleEditModeTouch(event: TouchEvent): void {
    if(event.type == TouchType.Down){
      if(this.touchId < 0){
        this.touchId = event.touches[0].id
      }
    }
    let touch = this.findTouch(event, this.touchId)
    if(!touch)
      return
    let x = vp2px(touch.x);
    let y = vp2px(touch.y);
    switch (event.type) {
      case TouchType.Down:
        this.downX = x;
        this.downY = y;
        this.initialX = this.positionX;
        this.initialY = this.positionY;
        this.downTime = new Date().getTime();
        break;
      case TouchType.Move:
        const widthDelta = this.screenWidth - this.getSize(this.data.baseInfo)
        const heightDelta = this.screenHeight - this.getSize(this.data.baseInfo)
        const targetX = Math.max(0, Math.min(widthDelta, this.initialX + x - this.downX));
        const targetY = Math.max(0, Math.min(heightDelta, this.initialY + y - this.downY));
        this.positionX = targetX
        this.positionY = targetY
        this.data.baseInfo.xPosition = this.positionX / Math.max(1, widthDelta)  * 1000
        this.data.baseInfo.yPosition = this.positionY / Math.max(1, heightDelta)  * 1000
        this.autoFitPosition()
        break;
      case TouchType.Up:
      case TouchType.Cancel:
        fitLine.removeLine(0);
        fitLine.removeLine(1);
        this.touchId = -1;
        if (Math.abs(x - this.downX) <= 10
          && Math.abs(y - this.downY) <= 10
          && new Date().getTime() - this.downTime <= 400) {
          this.toEdit()
        }
        break;
    }
  }

  private handleGameModeTouch(event: TouchEvent): void {
    const style = this.style;
    if (style.styleType === DirectionStyleType.BUTTON) {
      this.handleButtonModeTouch(event);
    } else {
      this.handleRockerModeTouch(event);
    }
  }
  private autoFitPosition(){
    if(!this.menu.autoFit){
      return
    }
    const dist = vp2px(Math.max(this.menu.autoFitDist,  2));
    const xyPref = [false, false];
    const prefXY = [0, 0];
    const selfXY = [0, 0];
    const xyDist = [dist, dist];
    let left = this.positionX;
    let right = this.positionX + this.viewSize;
    let up = this.positionY;
    let down = this.positionY + this.viewSize;
    const posArr = [left, right, up, down];
    const dataList: (ControlButtonData | ControlDirectionData) [] = [...this.viewGroup.viewData.buttonList, ...this.viewGroup.viewData.directionList]
    for(let button of dataList){
      if (button.id == this.data.id) {
        continue;
      }
      const position = this.getViewPosition(button.baseInfo)
      const buttonPosArr = [
        position.x as number,
        position.x as number + this.getSize(button.baseInfo),
        position.y as number,
        position.y as number + this.getSize(button.baseInfo)
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
  // 处理摇杆事件
  private handleRockerEvent(x: number, y: number): void {
    const maxDistance = this.viewSize / 2 - this.rockerSize / 2;
    const centerX = this.viewSize / 2;
    const centerY = this.viewSize / 2;

    const position = this.getRockerPositionPoint(centerX, centerY, x, y, maxDistance);
    this.rockerX = (position.x as number) - this.rockerSize / 2;
    this.rockerY = (position.y as number) - this.rockerSize / 2;
    this.eventHandler?.onStickAxisEvent(this.buildStickAxisEvent(this.rockerX / maxDistance, this.rockerY/ maxDistance))
  }
  private buildStickAxisEvent(x: number, y: number):StickAxisEvent{
    if(this.data.event.stickPosition == StickPosition.Right){
      return {deviceId:-1, rightStickX: x, rightStickY: y}
    }else {
      return {deviceId:-1, leftStickX: x, leftStickY: y}
    }
  }
  // 获取摇杆位置点
  private getRockerPositionPoint(centerX: number, centerY: number, touchX: number, touchY: number, maxDistance: number): Position {
    const lenX = touchX - centerX;
    const lenY = touchY - centerY;
    const lenXY = Math.sqrt(lenX * lenX + lenY * lenY);
    const radian = Math.acos(lenX / lenXY) * (touchY < centerY ? -1 : 1);
    const angle = radian2Angle(radian);

    if (lenXY <= maxDistance) {
      this.handleAngleEvent(angle);
      return { x: touchX, y: touchY };
    } else {
      const showPointX = centerX + maxDistance * Math.cos(radian);
      const showPointY = centerY + maxDistance * Math.sin(radian);
      this.handleAngleEvent(angle);
      return { x: showPointX, y: showPointY };
    }
  }

  // 摇杆模式触摸处理
  private handleRockerModeTouch(event: TouchEvent): void {
    if(event.type == TouchType.Down){
      if(this.touchId < 0){
        this.touchId = event.changedTouches[event.changedTouches.length -1].id
      }
    }
    let touch = this.findTouch(event, this.touchId)
    if(!touch)
      return;
    let x = vp2px(touch.x);
    let y = vp2px(touch.y);

    switch (event.type) {
      case TouchType.Down:
        const eventData = this.data.event;
        const followOption = eventData.followOption;
        if (followOption === FollowOption.FOLLOW ||
          (followOption === FollowOption.CENTER_FOLLOW &&
            x >= this.viewSize / 2 - this.rockerSize / 2 &&
            x <= this.viewSize / 2 + this.rockerSize / 2 &&
            y >= this.viewSize / 2 - this.rockerSize / 2 &&
            y <= this.viewSize / 2 + this.rockerSize / 2)) {
          this.downTime = Date.now();
          this.startClick = true;

          const deltaX = x - this.viewSize / 2;
          const deltaY = y - this.viewSize / 2;
          const targetX = (this.positionX + deltaX);
          const targetY = (this.positionY + deltaY);
          this.positionX = targetX;
          this.positionY = targetY
        } else {
          this.startClick = false;
          this.handleRockerEvent(x, y);
        }
        break;

      case TouchType.Move:
        if (!this.startRecord) {
          this.downX = x;
          this.downY = y;
          this.startRecord = true;
        } else if (!this.startClick ||
          Math.abs(x - this.downX) > 10 ||
          Math.abs(y - this.downY) > 10) {
          this.handleRockerEvent(x, y);
        }
        break;

      case TouchType.Up:
      case TouchType.Cancel:
        this.touchId = -1;
        this.startRecord = false;
        if (this.startClick &&
          Date.now() - this.downTime <= 100 &&
          Math.abs(event.touches[0].x - this.downX) <= 10 &&
          Math.abs(event.touches[0].y - this.downY) <= 10) {
          this.startClick = false;
          this.handleClickEvent();
        }
        this.cancelAllEvent();
        break;
    }
  }

  private findTouch(event: TouchEvent, touchId:number): TouchObject | undefined{
    return event.touches.find(d => d.id == touchId)
  }
  // 按钮模式触摸处理
  private handleButtonModeTouch(event: TouchEvent): void {

    if(event.type == TouchType.Down){
      this.touchId = event.changedTouches[event.changedTouches.length - 1].id
    }
    let touch = this.findTouch(event, this.touchId)
    if(!touch)
      return
    let x = vp2px(touch.x);
    let y = vp2px(touch.y);
    switch (event.type) {
      case TouchType.Down:
        this.downX = x;
        this.downY =y;
        this.downTime = Date.now();
        const buttonSize = this.buttonSize
        const p1 = buttonSize + ((this.viewSize * this.style.buttonStyle.interval!) / 1000);
        this.handleButtonEvent(x, y);
        this.startClick = x >= p1 && x <= p1 + buttonSize && y >= p1 && y <= p1 + buttonSize;
        break;

      case TouchType.Move:
        this.handleButtonEvent(x, y);
        break;

      case TouchType.Up:
      case TouchType.Cancel:
        this.touchId = 0;
        if (this.startClick &&
          Date.now() - this.downTime <= 100 &&
          Math.abs(x - this.downX) <= 10 &&
          Math.abs(y - this.downY) <= 10) {
         this.handleClickEvent();
        }
        this.cancelAllEvent();

        break;
    }
  }
  private handleButtonEvent(x: number, y: number): void {
    const size = this.getSize(this.data.baseInfo)
    const interval = this.style.buttonStyle.interval ?? 0
    const buttonSize = (size * (1000 - (2 * interval))) / 3000;
    const p1 = buttonSize + ((size * interval) / 1000);
    const p2 = size - buttonSize;

    if (x <= buttonSize && y <= buttonSize) {
      // 左上
      this.handleMoveEvent(true, false, true, false);
    } else if (x >= p1 && x <= p1 + buttonSize && y <= buttonSize) {
      // 上
      this.handleMoveEvent(true, false, false, false);
    } else if (x >= p2 && y <= buttonSize) {
      // 右上
      this.handleMoveEvent(true, false, false, true);
    } else if (x <= buttonSize && y >= p1 && y <= p1 + buttonSize) {
      // 左
      this.handleMoveEvent(false, false, true, false);
    } else if (x >= p1 && x <= p1 + buttonSize && y >= p1 && y <= p1 + buttonSize) {
      // 中
      this.handleMoveEvent(false, false, false, false);
    } else if (x >= p2 && y >= p1 && y <= p1 + buttonSize) {
      // 右
      this.handleMoveEvent(false, false, false, true);
    } else if (x <= buttonSize && y >= p2) {
      // 左下
      this.handleMoveEvent(false, true, true, false);
    } else if (x >= p1 && x <= p1 + buttonSize && y >= p2) {
      // 下
      this.handleMoveEvent(false, true, false, false);
    } else if (x >= p2 && y >= p2) {
      // 右下
      this.handleMoveEvent(false, true, false, true);
    }
  }

  // 处理角度事件
  private handleAngleEvent(angle: number): void {

    if ((this.ANGLE_0 <= angle && this.ANGLE_8D_OF_0P > angle || this.ANGLE_8D_OF_7P <= angle && this.ANGLE_360 > angle) &&
      this.activeDirection !== Direction.DIRECTION_RIGHT) {
      // 右
      this.activeDirection = Direction.DIRECTION_RIGHT;
      this.handleMoveEvent(false, false, false, true);
    } else if (this.ANGLE_8D_OF_0P <= angle && this.ANGLE_8D_OF_1P > angle &&
      this.activeDirection !== Direction.DIRECTION_DOWN_RIGHT) {
      // 右下
      this.activeDirection = Direction.DIRECTION_DOWN_RIGHT;
      this.handleMoveEvent(false, true, false, true);
    } else if (this.ANGLE_8D_OF_1P <= angle && this.ANGLE_8D_OF_2P > angle &&
      this.activeDirection !== Direction.DIRECTION_DOWN) {
      // 下
      this.activeDirection = Direction.DIRECTION_DOWN;
      this.handleMoveEvent(false, true, false, false);
    } else if (this.ANGLE_8D_OF_2P <= angle && this.ANGLE_8D_OF_3P > angle &&
      this.activeDirection !== Direction.DIRECTION_DOWN_LEFT) {
      // 左下
      this.activeDirection = Direction.DIRECTION_DOWN_LEFT;
      this.handleMoveEvent(false, true, true, false);
    } else if (this.ANGLE_8D_OF_3P <= angle && this.ANGLE_8D_OF_4P > angle &&
      this.activeDirection !== Direction.DIRECTION_LEFT) {
      // 左
      this.activeDirection = Direction.DIRECTION_LEFT;
      this.handleMoveEvent(false, false, true, false);
    } else if (this.ANGLE_8D_OF_4P <= angle && this.ANGLE_8D_OF_5P > angle &&
      this.activeDirection !== Direction.DIRECTION_UP_LEFT) {
      // 左上
      this.activeDirection = Direction.DIRECTION_UP_LEFT;
      this.handleMoveEvent(true, false, true, false);
    } else if (this.ANGLE_8D_OF_5P <= angle && this.ANGLE_8D_OF_6P > angle &&
      this.activeDirection !== Direction.DIRECTION_UP) {
      // 上
      this.activeDirection = Direction.DIRECTION_UP;
      this.handleMoveEvent(true, false, false, false);
    } else if (this.ANGLE_8D_OF_6P <= angle && this.ANGLE_8D_OF_7P > angle &&
      this.activeDirection !== Direction.DIRECTION_UP_RIGHT) {
      // 右上
      this.activeDirection = Direction.DIRECTION_UP_RIGHT;
      this.handleMoveEvent(true, false, false, true);
    }
  }


  // 处理移动事件
  private handleMoveEvent(up: boolean, down: boolean, left: boolean, right: boolean): void {
    if (this.style.styleType == DirectionStyleType.BUTTON) {
      if(!up && !down && !left && !right){
        this.activeDirection = Direction.DIRECTION_CENTER
      }
      if(up && !down && !left && !right){
        this.activeDirection = Direction.DIRECTION_UP
      }
      if(!up && down && !left && !right){
        this.activeDirection = Direction.DIRECTION_DOWN
      }
      if(!up && !down && left && !right){
        this.activeDirection = Direction.DIRECTION_LEFT
      }
      if(!up && !down && !left && right){
        this.activeDirection = Direction.DIRECTION_RIGHT
      }
      if(up && !down && left && !right){
        this.activeDirection = Direction.DIRECTION_UP_LEFT
      }
      if(up && !down && !left && right){
        this.activeDirection = Direction.DIRECTION_UP_RIGHT
      }
      if(!up && down && left && !right){
        this.activeDirection = Direction.DIRECTION_DOWN_LEFT
      }
      if(!up && down && !left && right){
        this.activeDirection =Direction.DIRECTION_DOWN_RIGHT
      }
    }
    const eventData = this.data.event;
    SendKey(this.eventHandler,eventData.upKeycode, up)
    SendKey(this.eventHandler,eventData.downKeycode, down)
    SendKey(this.eventHandler,eventData.leftKeycode, left)
    SendKey(this.eventHandler,eventData.rightKeycode, right)
  }
  private cancelAllEvent(): void {

    // 发送键盘释放事件
    const eventData = this.data.event;

    SendKey(this.eventHandler,eventData.upKeycode, false)
    SendKey(this.eventHandler,eventData.downKeycode, false)
    SendKey(this.eventHandler,eventData.leftKeycode, false)
    SendKey(this.eventHandler,eventData.rightKeycode, false)

    if (this.doubleClickEvent) {
      SendKey(this.eventHandler,eventData.sneakKeycode, false)
      this.doubleClickEvent = false;
    }

    // 重置状态
    this.activeDirection = Direction.DIRECTION_CENTER;
    this.clickCount = 0;
    this.startClick = false;
    this.startRecord = false;

    // 重置摇杆位置
    if (this.style.styleType === DirectionStyleType.ROCKER) {
      this.rockerX = this.viewSize / 2 - this.rockerSize / 2;
      this.rockerY = this.viewSize / 2 - this.rockerSize / 2;
      this.positionX = ((this.menu.screenWidth - this.viewSize) * (this.data.baseInfo.xPosition / 1000));
      this.positionY = ((this.menu.screenHeight - this.viewSize) * (this.data.baseInfo.yPosition / 1000));
    }
  }

  // 处理点击事件
  private handleClickEvent(): void {
    this.startClick = false;
    this.clickCount++;
    if (this.clickCount === 1) {
      this.firstClickTime = Date.now();
    } else if (this.clickCount === 2) {
      if (Date.now() - this.firstClickTime < 400) {
        this.handleDoubleClickEvent();
        this.clickCount = 0;
      } else {
        this.clickCount = 1;
        this.firstClickTime = Date.now();
      }
    }
  }
  private handleDoubleClickEvent(): void {
    if (this.data.event.sneak) {
      this.doubleClickEvent = true;
      SendKey(this.eventHandler, this.data.event.sneakKeycode, true)
    }
  }

}