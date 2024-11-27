import { BreakpointSystem, BreakpointState } from '../common/breakpointsystem'
import { mediaquery } from '@kit.ArkUI';

interface MarginGenerate {
  left: number, right: number, top: number,
  bottom?:number
}

@Component
struct SwitchMode {
  @State isToggle1: boolean = false;
  @State isToggle2: boolean = false;
  @State isToggle3: boolean = false;
  @State isLandscapePhone: boolean = false
  @State compStr: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg", xl: "xl" })
  @State fontSize: BreakpointState<number> = BreakpointState.of({
    sm: 16, md: 27, lg: 26, xl: 27
  });
  @State titleFontSize: BreakpointState<number> = BreakpointState.of({
    sm: 18, md: 29, lg: 26, xl: 27
  });
  @State RowPadding: BreakpointState<number> = BreakpointState.of({
    sm: 10, md: 9, lg: 10, xl: 20
  });
  @State fontMargin: BreakpointState<MarginGenerate> = BreakpointState.of({
    sm: ({ left: 15 } as MarginGenerate),
    md: ({ left: 25 } as MarginGenerate),
    lg: ({ left: 8 } as MarginGenerate),
    xl: ({ left: 15 } as MarginGenerate)
  });
  @State cardPadding: BreakpointState<MarginGenerate> = BreakpointState.of({
    sm: ({top: 12, bottom: 12, left: 12, right: 12} as MarginGenerate),
    md: ({top: 12, bottom: 12, left: 12, right: 12} as MarginGenerate),
    lg: ({top: 14, bottom: 14, left: 14, right: 14} as MarginGenerate),
    xl: ({top: 14, bottom: 14, left: 14, right: 14} as MarginGenerate)
  });

  onPhoneLandscape(mediaQueryResult:mediaquery.MediaQueryResult) {
    if (mediaQueryResult.matches as boolean ) {
      this.isLandscapePhone = true
      console.log('手机横屏' + this.isLandscapePhone)
    } else {
      this.isLandscapePhone = false
      console.log('手机竖屏' + this.isLandscapePhone)
    }
  }

  // 手机横屏高度条件
  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');

  aboutToAppear() {
    this.phonelistener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.onPhoneLandscape(mediaQueryResult)
    });

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.titleFontSize)
    BreakpointSystem.getInstance().attach(this.RowPadding)
    BreakpointSystem.getInstance().attach(this.fontMargin)
    BreakpointSystem.getInstance().attach(this.cardPadding)
    BreakpointSystem.getInstance().start()
  }
  aboutToDisappear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.titleFontSize)
    BreakpointSystem.getInstance().attach(this.fontMargin)
    BreakpointSystem.getInstance().attach(this.RowPadding)
    BreakpointSystem.getInstance().attach(this.cardPadding)
    BreakpointSystem.getInstance().stop()
    this.phonelistener.off('change');
  }

  build() {
    Column() {
      Text($r('app.string.Mode'))
        .fontSize(this.isLandscapePhone ? 18 : this.titleFontSize.value)
        .fontWeight(FontWeight.Bold)
        //.margin({left:this.RowPadding.value, bottom:7})
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
            .fontWeight(FontWeight.Bold)
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .margin(this.isLandscapePhone ? { left: 15 }: this.fontMargin.value)
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
            .fontWeight(FontWeight.Bold)
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .margin(this.isLandscapePhone ? { left: 15 }: this.fontMargin.value)
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
            .fontWeight(FontWeight.Bold)
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .margin(this.isLandscapePhone ? { left: 15 }: this.fontMargin.value)
        }
        .margin({top: this.RowPadding.value})
      }
      //.padding(this.RowPadding.value)
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
    //.justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
  }
}
export default SwitchMode






