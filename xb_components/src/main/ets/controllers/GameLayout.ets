import { ControlButton } from './ControlButton'
import { ControlDirection } from './ControlDirection'
import { ControlButtonData, ControlDirectionData, Controller, ViewGroup, GroupVisibility,
  VisibilityType } from './Controller'
import { ControllerViewModel } from './ControllerViewModel'
import { CursorView } from './CursorView'
import { InputView } from './InputView'
import { getAppStore, getPersistence, MenuButton, MenuState } from './MenuButton'
import { TouchPadView } from './TouchPadView'
import { KeyCode } from '@kit.InputKit'
import { TouchPadInput } from './TouchPadInput'
import { Xb_ToastUtil } from '../utils/ToastUtils'
import { ControllerEventHandler } from './ControllerEventHandler'


@ComponentV2
export struct GameLayout{
  @Param eventHandler?: ControllerEventHandler = undefined
  @Param controllerPath?: string = undefined
  @Param onNormKeyCode: (key:number) => number = (key)=>key
  @Param inGame: boolean = false
  @Local touchInput: TouchPadInput = getAppStore(TouchPadInput, ()=>new TouchPadInput())!
  @Local menuState?: MenuState = getPersistence(MenuState, ()=>new MenuState())
  @Local controllerViewModel: ControllerViewModel = getAppStore(ControllerViewModel,()=> new ControllerViewModel())!
  @BuilderParam gameView: CustomBuilder
  async aboutToAppear(): Promise<void> {
    Xb_ToastUtil.initContext(this.getUIContext())
    await this.controllerViewModel.loadControllerList(this.getUIContext().getHostContext()!, this.controllerPath, this.onNormKeyCode)
  }
  build() {
    Stack(){
      if (this.gameView) {
        this.gameView()
      }
      InputView()
      if(this.menuState?.cursorEnabled){
        CursorView()
      }
      TouchPadView({eventHandler: this.eventHandler}).hitTestBehavior(HitTestMode.Transparent)
      if(!this.menuState?.hideAllViews){
        ForEach(this.controllerViewModel.viewGroups.filter(d => d.visibility == GroupVisibility.VISIBLE), (v:ViewGroup)=>{
          ForEach(v.viewData.buttonList, (b: ControlButtonData)=>{
            ControlButton({data:b, viewGroup: v, eventHandler: this.eventHandler, inGame: this.inGame})
          })
          ForEach(v.viewData.directionList, (b: ControlDirectionData)=>{
            ControlDirection({data:b, viewGroup: v, eventHandler: this.eventHandler, inGame: this.inGame})
          })
        })
      }
      if(!this.menuState?.hideMenuButton){
        MenuButton()
      }
    }
    .onKeyEvent((e)=>{
      if(e.keyCode == KeyCode.KEYCODE_VOLUME_UP || e.keyCode == KeyCode.KEYCODE_VOLUME_DOWN){
        this.menuState!.hideMenuButton = false
      }
      this.eventHandler?.onKeyEvent(e)
    })
    .onMouse(e => {
      let x = (e.rawDeltaX || 0) * (this.menuState?.mouseSensitivity || 1);
      let y = (e.rawDeltaY || 0) * (this.menuState?.mouseSensitivity || 1);

      this.touchInput.movePointer(x,y, this.menuState!.cursorEnabled, this.eventHandler, this.menuState!.screenWidth, this.menuState!.screenHeight)
      this.eventHandler?.onMouseEvent(e, x, y, this.menuState?.screenWidth ?? 0, this.menuState?.screenHeight ?? 0)
      e.stopPropagation()
    })
    .padding(this.menuState?.screenPadding || 0)
    .width("100%").height("100%")
  }
}