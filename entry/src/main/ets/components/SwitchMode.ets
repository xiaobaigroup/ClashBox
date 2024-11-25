import { BreakpointSystem, BreakpointState } from '../common/breakpointsystem'

interface MarginGenerate {
  left: number,
  bottom?:number
}

@Component
struct SwitchMode {
  @State isToggle1: boolean = false;
  @State isToggle2: boolean = false;
  @State isToggle3: boolean = false;
  @State compStr: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg", xl: "xl" })
  @State fontSize: BreakpointState<number> = BreakpointState.of({
    sm: 21, md: 21, lg: 26, xl: 27
  });
  @State RowPadding: BreakpointState<number> = BreakpointState.of({
    sm: 10, md: 9, lg: 10, xl: 20
  });
  @State fontMargin: BreakpointState<MarginGenerate> = BreakpointState.of({
    sm: ({ left: 20 } as MarginGenerate),
    md: ({ left: 25 } as MarginGenerate),
    lg: ({ left: 8 } as MarginGenerate),
    xl: ({ left: 15 } as MarginGenerate)
  });

  aboutToAppear() {
    /*this.phonelistener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.onPhoneLandscape(mediaQueryResult)
    });*/

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.RowPadding)
    BreakpointSystem.getInstance().attach(this.fontMargin)
    BreakpointSystem.getInstance().start()
  }
  aboutToDisappear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.fontMargin)
    BreakpointSystem.getInstance().attach(this.RowPadding)
    BreakpointSystem.getInstance().stop()
    //this.phonelistener.off('change');
  }

  build() {
    Column() {
      Text($r('app.string.Mode'))
        .fontSize(this.fontSize.value)
        .fontWeight(FontWeight.Bold)
        .margin({left:this.RowPadding.value, bottom:7})
      Column() {
        Row() {
          Checkbox({ name: 'checkbox', group: 'checkboxGroup' })
            .select($$this.isToggle1)
            .selectedColor(0x39a2db)
            .shape(CheckBoxShape.CIRCLE)
            .onChange((value: boolean) => {
              //this.isToggle1 = true
              console.info('Checkbox1 change is' + value)
              if(this.isToggle2 || this.isToggle3) {
                this.isToggle2 = false
                this.isToggle3 = false
              }
            })
          Text($r('app.string.Rule'))
            .fontSize(this.fontSize.value)
            .margin(this.fontMargin.value)
        }
        Row() {
          Checkbox({ name: 'checkbox', group: 'checkboxGroup' })
            .select($$this.isToggle2)
            .selectedColor(0x39a2db)
            .shape(CheckBoxShape.CIRCLE)
            .onChange((value: boolean) => {
              //this.isToggle2 = true
              console.info('Checkbox2 change is' + value)
              if(this.isToggle1 || this.isToggle3) {
                this.isToggle1 = false
                this.isToggle3 = false
              }
            })
          Text($r('app.string.Overall'))
            .fontSize(this.fontSize.value)
            .margin(this.fontMargin.value)
        }
        .margin({top: this.RowPadding.value})
        Row() {
          Checkbox({ name: 'checkbox', group: 'checkboxGroup' })
            .select($$this.isToggle3)
            .selectedColor(0x39a2db)
            .shape(CheckBoxShape.CIRCLE)
            .onChange((value: boolean) => {
              //this.isToggle3 = true
              console.info('Checkbox3 change is' + value)
              if(this.isToggle1 || this.isToggle2) {
                this.isToggle1 = false
                this.isToggle2 = false
              }
            })
          Text($r('app.string.Direct'))
            .fontSize(this.fontSize.value)
            .margin(this.fontMargin.value)
        }
        .margin({top: this.RowPadding.value})
      }
      //.padding(this.RowPadding.value)
    }
    .padding(5)
    .width('100%')
    .height('100%')
    //.justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
  }
}
export default SwitchMode






