import { BreakpointSystem, BreakpointState } from '../../common/breakpointsystem'
import { mediaquery } from '@kit.ArkUI';
import { ThemeControl } from '@ohos.arkui.theme'
import { gAppTheme } from '../../common/AppTheme'
import { hilog } from '@kit.PerformanceAnalysisKit'

// 在页面build前执行ThemeControl，就可以改变主题颜色
//ThemeControl.setDefaultTheme(gAppTheme)

interface MarginGenerate {
  left: number, right: number, top: number,
  bottom?:number
}

@Component
struct SwitchMode {
  private componentName:string = 'SwitchMode'
  //自定义主题，颜色在AppTheme里面修改
  @State font_secondary: ResourceColor = $r('sys.color.font_secondary')
  @State icon_emphasize: ResourceColor = $r('sys.color.icon_emphasize')//高亮图标，蓝色
/*
  @State backgroundPrimary: ResourceColor = $r('sys.color.background_primary')
  @State fontPrimary: ResourceColor = $r('sys.color.font_primary')
  @State iconOnPrimary: ResourceColor = $r('sys.color.icon_on_primary')
  @State iconFourth: ResourceColor = $r('sys.color.icon_fourth')

  onWillApplyTheme(theme: Theme) {
    this.backgroundPrimary = theme.colors.backgroundPrimary;
    this.fontPrimary = theme.colors.fontPrimary;
    this.iconOnPrimary = theme.colors.iconOnPrimary;
    this.iconFourth = theme.colors.iconFourth;
  }
*/
  // 代理模式Radio状态
  @State radioRuleChecked: boolean = false;
  @State radioOverallChecked: boolean = false;
  @State radioDirectChecked: boolean = false;

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
          Radio({ value: 'rule', group: 'connectModeRadioGroup', indicatorType: RadioIndicatorType.DOT })
            .checked($$this.radioRuleChecked)
            .onChange((value: boolean) => {
              hilog.info(0xA001, this.componentName, `#Radio()#rule#state: ${this.radioRuleChecked}`)
            })
          Text($r('app.string.Rule'))
            .fontWeight(FontWeight.Bold)
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .margin(this.isLandscapePhone ? { left: 15 }: this.fontMargin.value)
            .fontColor(this.font_secondary)
        }
        Row() {
          Radio({ value: 'overall', group: 'connectModeRadioGroup', indicatorType: RadioIndicatorType.DOT })
            .checked($$this.radioOverallChecked)
            .onChange((value: boolean) => {
              hilog.info(0xA001, this.componentName, `#Radio()#overall#state: ${this.radioRuleChecked}`)
            })
          Text($r('app.string.Overall'))
            .fontWeight(FontWeight.Bold)
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .margin(this.isLandscapePhone ? { left: 15 }: this.fontMargin.value)
            .fontColor(this.font_secondary)
        }
        .margin({top: this.RowPadding.value})
        Row() {
          Radio({ value:'direct', group: 'connectModeRadioGroup', indicatorType: RadioIndicatorType.DOT })
            .checked($$this.radioDirectChecked)
            .onChange((value: boolean) => {
              hilog.info(0xA001, this.componentName, `#Radio()#direct#state: ${this.radioRuleChecked}`)
            })
          Text($r('app.string.Direct'))
            .fontWeight(FontWeight.Bold)
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .margin(this.isLandscapePhone ? { left: 15 }: this.fontMargin.value)
            .fontColor(this.font_secondary)
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






