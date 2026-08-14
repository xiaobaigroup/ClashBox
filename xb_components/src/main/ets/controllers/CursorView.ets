import { getAppStore, getPersistence, MenuState } from "./MenuButton"
import { TouchPadInput } from "./TouchPadInput"

@ComponentV2
export struct CursorView{
  @Local touchInput: TouchPadInput = getAppStore(TouchPadInput, ()=> new TouchPadInput())!
  @Local menuState?: MenuState = getPersistence(MenuState)
  build() {
    Image($r("app.media.cursor")).size({width:this.menuState?.cursorSize, height:this.menuState?.cursorSize}).position({x: this.touchInput.cursorX + "px",y: this.touchInput.cursorY + "px" })
  }
}