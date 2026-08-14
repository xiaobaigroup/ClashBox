

export interface Xb_SettingsItemData {
  id?: string
  icon?: Resource
  image?: Resource
  iconColor?: ResourceColor
  actionColor?: ResourceColor
  label?: ResourceStr
  content?: ResourceStr
  value? : ResourceStr| boolean | number
  actionType: Xb_ActionType
  onChange?: (value: ResourceStr| boolean | number) => void
  radioGroup?: Xb_RadioGroupData
  dialog?: Xb_DialogParam
  slider?: Xb_SliderParam
  enable?: boolean
  menuSelectList?: Array<Xb_MenuSelectItem>
  menuDisabled?: (item: Xb_MenuSelectItem, index: number)=> boolean
}

@ObservedV2
export class Xb_RadioGroupData {
  @Trace value: string = ""
  @Trace group: string = ""
  constructor(value: string, group: string) {
    this.value = value
    this.group = group
  }
}

export interface Xb_DialogParam {
  width?: Dimension
  buttons?: ResourceStr[]
  onWillAppear?: () => void
  onClick?: (button: ResourceStr, index: number, dialog: CustomDialogController | undefined) => void
}

export interface Xb_SliderParam {
  min?: number
  max?: number
  step?: number
  util?: string
  ctrl?: boolean
}

export interface Xb_MenuSelectItem {
  label?: ResourceStr
  value: ResourceStr
  symbolIcon?: SymbolGlyphModifier
}


export enum Xb_ActionType {
  MENU = 'Menu',
  TOGGLE = 'Toggle',
  DIALOG = 'Dialog',
  COLOR = 'Color',
  JUMP = 'Jump',
  TEXT = 'Text',
  Input = 'Input',
  BUTTON = 'Button',
  RADIO = 'Radio',
  CHECK = 'Check',
  SLIDER = 'Slider',
  GROUP = 'Group',
  NONE = 'None'
}

export interface Xb_SettingsGroupData{
    group?: Xb_SettingsItemData,
    items: Xb_SettingsItemData[]
}

export function makeSettingsGroupData(data: Xb_SettingsItemData[]): Xb_SettingsGroupData[]{
  return data.reduce((result: Xb_SettingsGroupData[], item: Xb_SettingsItemData ) => {
    if (item.actionType === Xb_ActionType.GROUP) {
      result.push({ group: item, items: [] });
    } else if (result.length > 0) {
      result[result.length - 1].items.push(item);
    } else {
      // 第一个元素不是Group的情况
      result.push({ group: undefined, items: [item] });
    }
    return result;
  }, []);
}