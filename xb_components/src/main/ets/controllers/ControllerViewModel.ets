import { Context } from '@kit.AbilityKit';
import { ControlButtonStyle, ControlDirectionStyle, Controller, DirectionStyleType, ViewGroup } from './Controller';
import { JSON, util } from '@kit.ArkTS';
import { fileIo } from '@kit.CoreFileKit';
import { Xb_MenuSelectItem, Xb_RadioGroupData, Xb_ActionType, Xb_SettingsItemData } from '../model/SettingsItem';
import { Xb_ToastUtil } from '../utils/ToastUtils';
import { cacheDownload } from '@kit.BasicServicesKit';
import { Xb_GlobalContext } from '../entity/GlobalContext';
import { copyNew } from './ControlButtonViewModel';
import utils from '@arkts.utils';
import { Xb_FileUtils } from '../../../../Index';


function fixController(c:Controller, onKey:(key:number)=> number){
  c.viewGroups.forEach(d=>{
    d.viewData.directionList.forEach(d=>{
      d.event.sneakKeycode = onKey(d.event.sneakKeycode)
      d.event.upKeycode = onKey(d.event.upKeycode)
      d.event.downKeycode = onKey(d.event.downKeycode)
      d.event.leftKeycode = onKey(d.event.leftKeycode)
      d.event.rightKeycode = onKey(d.event.rightKeycode)
    })
    d.viewData.buttonList.forEach(d=>{
      d.event.pressEvent.outputKeycodes = d.event.pressEvent.outputKeycodes.map(onKey)
      d.event.clickEvent.outputKeycodes = d.event.clickEvent.outputKeycodes.map(onKey)
      d.event.doubleClickEvent.outputKeycodes = d.event.doubleClickEvent.outputKeycodes.map(onKey)
      d.event.longPressEvent.outputKeycodes = d.event.longPressEvent.outputKeycodes.map(onKey)
    })
  })
  return c;
}

@ObservedV2
export class ControllerViewModel {
  @Trace current?:Controller
  @Trace controllerList : Controller[] = []
  @Trace viewGroups: ViewGroup[] = []
  @Trace filePath: string = ""
  constructor() {
  }
  public updateViewGroups(){
    if(this.current){
      this.viewGroups = [...this.current!.viewGroups]
    }
  }
  async loadControllerList(context: Context, filePath: string | undefined,  onNormKeyCode:(key: number) => number){
    filePath = filePath == undefined ? context.filesDir + "/controllers/" : filePath;
    this.filePath = filePath
    try {
      if (!await fileIo.access(filePath, fileIo.AccessModeType.EXIST)) {
        await fileIo.mkdir(filePath)
      }
      let configList = await fileIo.listFile(filePath)
      if(configList.length == 0){
        await fileIo.copyDir(context.resourceDir + "/controllers/", context.filesDir +"/controllers/" , 1)
      }
    } catch (error) {
      Xb_ToastUtil.showToast({message:"路径不对" + error})
    }
    const configList = await fileIo.listFile(filePath)
    let controllerList: Controller[] = []
    for(let file of configList){
      const config = fileIo.readTextSync(filePath + file)
      let controller = JSON.parse(config) as Controller;
      controllerList.push(fixController(controller, onNormKeyCode))
    }
    this.controllerList = controllerList;
    if(!this.current){
      this.switchController(controllerList[0]?.id)
    }
  }

  switchController(id: string | undefined){
    let c =  this.controllerList.find(f => f.id == id)
    if(c){
      this.current = c
    }
    this.updateViewGroups()
  }
  
  async importNewController(){
    const filePath = await Xb_FileUtils.openFile(Xb_GlobalContext.getContext())
    if(filePath && filePath?.endsWith(".json")){
      const config = await fileIo.readText(filePath)
      let controller = JSON.parse(config) as Controller;
      controller.id = util.generateRandomUUID().substring(0, 8)
      this.controllerList.push(controller)
      this.controllerList = [...this.controllerList]
      await this.saveController(controller)
      this.switchController(controller.id)
    }else if(filePath){
        Xb_ToastUtil.showToast({message:"文件格式不对"})
    }
  }
  addNewController(){
    this.current
  }
  delController(id: string){
    fileIo.unlinkSync(this.filePath + id+ ".json")
  }
  async saveController(c: Controller | undefined, fileDir: string | undefined = undefined, message: ResourceStr = "已保存"){
    try {
      const saveDir = fileDir ?? this.filePath
      const savePath = saveDir + c?.id + ".json"
      if (!await fileIo.access(saveDir, fileIo.AccessModeType.EXIST)) {
        await fileIo.mkdir(saveDir)
      }
      const file = await fileIo.open(savePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.TRUNC)
      await fileIo.write(file.fd, JSON.stringify(c));
      await fileIo.fsync(file.fd)
      await fileIo.close(file.fd)
      Xb_ToastUtil.showToast({message: message})
    }catch (e) {
      Xb_ToastUtil.showToast({message:"保存失败" + e.message})
    }
  }
  async downloadController(c: Controller | undefined){
    if(Xb_GlobalContext.downloadDir == ""){
      await Xb_GlobalContext.initDownloadDir()
    }
    const savePath = Xb_GlobalContext.downloadDir + "/controllers/"
    this.saveController(c, savePath, "已保存到下载目录")
  }
  controllerMenuList(): Xb_MenuSelectItem[]{
   const list = this.controllerList.map(c=> {
      return {label: c.name, value: c.id ?? "" } as Xb_MenuSelectItem
    })
    return list
  }

  getButtonStyle(name:string): ControlButtonStyle{
    return this.current?.buttonStyles.find(d => d.name == name) ?? {} as ControlButtonStyle
  }
  getDirectionStyle(name:string): ControlDirectionStyle{
    return this.current?.directionStyles.find(d=>d.name == name) ?? {} as ControlDirectionStyle
  }

  makeButtonStyleList(group: Xb_RadioGroupData): Xb_SettingsItemData[]{
    return this.current?.buttonStyles.map((d)=>{
      return { label:d.name, value: d.name, actionType: Xb_ActionType.RADIO, radioGroup: group} as Xb_SettingsItemData
    }) ?? []
  }
  makeDirectionStyleList(group: Xb_RadioGroupData, ): Xb_SettingsItemData[]{
    return this.current?.directionStyles.map((d)=>{
      return { label:d.name, value: d.name, actionType: Xb_ActionType.RADIO, radioGroup: group } as Xb_SettingsItemData
    }) ?? []
  }
  saveDirectionStyle(style: ControlDirectionStyle)
  {
    if(!this.current || style.name == "")
      return;
    let index = this.current?.directionStyles.findIndex(d => d.name == style.name)
    if (index < 0) {
      this.current.directionStyles.push(style)
    } else {
      this.current.directionStyles[index] = style;
    }
  }
  saveButtonStyle(style: ControlButtonStyle)
  {
    if(!this.current || style.name == "")
        return;
    let index = this.current?.buttonStyles.findIndex(d => d.name == style.name)
    if (index < 0) {
      this.current.buttonStyles.push(style)
    } else {
      this.current.buttonStyles[index] = style;
    }
  }
  deleteDirectionStyle(styleName: string)
  {
    if (!this.current || styleName == "")
      return;
    this.current.directionStyles = this.current?.directionStyles.filter(d => d.name != styleName)
  }
  deleteButtonStyle(styleName: string)
  {
    if (!this.current || styleName == "")
      return;
    this.current.buttonStyles = this.current?.buttonStyles.filter(d => d.name != styleName)
  }
}