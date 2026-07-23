import { getPersistence, MenuState } from "./MenuButton"

@ComponentV2
export struct InputView{
  @Local menuState?: MenuState = getPersistence(MenuState)
  build() {
    if(this.menuState?.showKeyboard){
      TextArea({text: this.menuState.inputText}).hitTestBehavior(HitTestMode.None).key("inputView")
        .defaultFocus(true).onAppear(()=>{
          try {
            this.getUIContext().getFocusController().requestFocus("inputView")
          }catch (e) {
          }

      })
        .enterKeyType(EnterKeyType.Done)
        .onKeyEventDispatch(e=>{
          return true;
        })
        .onKeyPreIme((e)=>{
          return true;
        })
        .onChange((e, previewText, o)=>{
          if(this.menuState!.inputText == e)
            return
          console.log("testTag onChange", e, JSON.stringify(previewText),JSON.stringify(o))
          const lengthBefore = this.menuState!.inputText.length
          const lengthAfter = e.length
          for (let i = 0; i < lengthBefore; ++i) {
           // nativeInput.sendBackspace();
          }
          const start =0;
          for (let i = start, count = 0; count < lengthAfter; ++i) {
           // nativeInput.sendChar(e.charAt(i));
            ++count;
          }
          this.menuState!.inputText = e
        }).onSubmit((enterKeyType: EnterKeyType, e?: SubmitEvent)=>{
        this.menuState!.showKeyboard = false
        console.log("testTag onSubmit", enterKeyType,JSON.stringify(e))
      }).onBlur(()=>{
        this.menuState!.showKeyboard = false
      })
    }

  }
}