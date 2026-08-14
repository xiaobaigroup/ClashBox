export enum VisibilityType {
  ALWAYS = "ALWAYS",
  IN_GAME = "IN_GAME",
  MENU = "MENU"
}

export enum SizeReference {
  SCREEN_WIDTH = "SCREEN_WIDTH",
  SCREEN_HEIGHT = "SCREEN_HEIGHT"
}

export enum SizeType {
  PERCENTAGE = "PERCENTAGE",
  ABSOLUTE = "ABSOLUTE"
}
export interface PercentageSize {
  reference: SizeReference;
  size: number;
}
export interface BaseInfo {
  visibilityType: VisibilityType;
  xPosition: number;
  yPosition: number;
  sizeType: SizeType;
  absoluteWidth: number;
  absoluteHeight: number;
  percentageWidth: PercentageSize;
  percentageHeight: PercentageSize;
}
export interface ButtonEventAction {
  autoKeep: boolean;
  autoClick: boolean;
  openMenu: boolean;
  switchTouchMode: boolean;
  switchMouseMode: boolean;
  input: boolean;
  quickInput: boolean;
  outputText: string;
  outputKeycodes: number[];
  bindViewGroup: string[];
}
export interface ButtonEventData {
  pointerFollow: boolean;
  Movable: boolean;
  pressEvent: ButtonEventAction;
  longPressEvent: ButtonEventAction;
  clickEvent: ButtonEventAction;
  doubleClickEvent: ButtonEventAction;
}
export enum GroupVisibility{
  VISIBLE = "VISIBLE",
  INVISIBLE = "INVISIBLE",
}

export interface ViewGroup {
  id: string;
  name: string;
  visibility: GroupVisibility; // 可以是枚举类型，根据实际值定义
  viewData: ViewData;
}
export interface ViewData {
  buttonList: ControlButtonData[];
  directionList: ControlDirectionData[]; // 根据实际数据结构调整
}
export interface ControlButtonData {
  id: string;
  text: string;
  style: string;
  baseInfo: BaseInfo;
  event: ButtonEventData;
}
export interface ControlDirectionData {
  id: string;
  style: string;
  baseInfo: BaseInfo;
  event: DirectionEventData;
}
export interface Controller{
  id?: string
  name?: string
  version?: string
  versionCode?: number
  description?: string
  controllerVersion?: number
  buttonStyles: ControlButtonStyle[]
  directionStyles: ControlDirectionStyle[]
  viewGroups: ViewGroup[]
}

export interface ControlButtonStyle {
  name: string;
  textColor: number;
  textSize: number;
  strokeColor: number;
  strokeWidth: number;
  cornerRadius: number;
  fillColor: number;
  textColorPressed: number;
  textSizePressed: number;
  strokeColorPressed: number;
  strokeWidthPressed: number;
  cornerRadiusPressed: number;
  fillColorPressed: number;
  interval?:number
}
export function makeDefaultButtonStyle(): ControlButtonStyle{
  return {
    name: "",
    textColor: 0,
    textSize: 0,
    strokeColor:0,
    strokeWidth:0,
    cornerRadius: 0,
    fillColor: 0,
    textColorPressed: 0,
    textSizePressed:0,
    strokeColorPressed:0,
    strokeWidthPressed: 0,
    cornerRadiusPressed:0,
    fillColorPressed:0,
  }
}
export function makeDefaultDirectionStyle(): ControlDirectionStyle{
  return {
    name: "",
    styleType: DirectionStyleType.BUTTON,
    buttonStyle: makeDefaultButtonStyle(),
    rockerStyle: {
      rockerSize: 0,
      bgCornerRadius: 0,
      bgStrokeWidth: 0,
      bgStrokeColor: 0,
      bgFillColor: 0,
      rockerCornerRadius: 0,
      rockerStrokeWidth: 0,
      rockerStrokeColor: 0,
      rockerFillColor: 0
    }
  } as ControlDirectionStyle
}


export enum DirectionStyleType{
  BUTTON = "BUTTON",
  ROCKER = "ROCKER"
}
export interface ControlDirectionStyle {
  name: string;
  styleType: DirectionStyleType;
  buttonStyle: ControlButtonStyle;
  rockerStyle: RockerStyle;
}
export enum StickPosition {
  Left = "LEFT",
  Right = "RIGHT"
}

export interface DirectionEventData {
  upKeycode: number;
  downKeycode: number;
  leftKeycode: number;
  rightKeycode: number;
  followOption: FollowOption;
  stickPosition: StickPosition;
  sneak: boolean;
  sneakKeycode: number;
}

interface RockerStyle {
  rockerSize: number;
  bgCornerRadius: number;
  bgStrokeWidth: number;
  bgStrokeColor: number;
  bgFillColor: number;
  rockerCornerRadius: number;
  rockerStrokeWidth: number;
  rockerStrokeColor: number;
  rockerFillColor: number;
}
export enum FollowOption {
  FIXED = "FIXED",
  CENTER_FOLLOW  = "CENTER_FOLLOW",
  FOLLOW = "FOLLOW"
}