import { BreakpointSystem, BreakpointState } from '../../common/breakpointsystem'
import { mediaquery } from '@kit.ArkUI'
import { ThemeControl } from '@ohos.arkui.theme'
import { gAppTheme } from '../../common/AppTheme'

// 在页面build前执行ThemeControl，就可以改变主题颜色
//ThemeControl.setDefaultTheme(gAppTheme)


interface MarginGenerate {
  left: number,top: number, right: number,
  bottom?:number
}

@Component
struct TrafficStatistics {
  /* //自定义主题，颜色在AppTheme里面修改
   @State font_secondary: ResourceColor = $r('sys.color.font_secondary')

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
  @State font_primary: ResourceColor = $r('sys.color.font_primary')
  @State TotalDownloads: number = 0
  @State TotalUpload: number = 0
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @State compStr: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg", xl: "xl" })
  @State fontSize: BreakpointState<number> = BreakpointState.of({
    sm: 14, md: 23, lg: 26, xl: 21
  });
  @State titleFontSize: BreakpointState<number> = BreakpointState.of({
    sm: 18, md: 29, lg: 26, xl: 27
  });
  @State chevronSize: BreakpointState<number> = BreakpointState.of({
    sm: 16, md: 22, lg: 26, xl: 27
  });
  @State RowMargin: BreakpointState<number> = BreakpointState.of({
    sm: 20, md: 10, lg: 10, xl: 20
  });
  @State barHeight: BreakpointState<number> = BreakpointState.of({
    sm: 6, md: 5, lg: 5, xl: 5
  });
  @State barMargin: BreakpointState<MarginGenerate> = BreakpointState.of({
    xs: ({ top: 10, bottom: 7 } as MarginGenerate),
    sm: ({ top: 10, bottom: 7 } as MarginGenerate),
    md: ({ top: 15, bottom: 9 } as MarginGenerate),
    lg: ({ top: 15, bottom: 9 } as MarginGenerate),
    xl: ({ top: 15, bottom: 9 } as MarginGenerate)
  });
  @State cardPadding: BreakpointState<MarginGenerate> = BreakpointState.of({
    sm: ({top: 12, bottom: 12, left: 10, right: 10} as MarginGenerate),
    md: ({top: 12, bottom: 12, left: 10, right: 10} as MarginGenerate),
    lg: ({top: 14, bottom: 14, left: 12, right: 12} as MarginGenerate),
    xl: ({top: 14, bottom: 14, left: 12, right: 12} as MarginGenerate)
  });



  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');

  aboutToAppear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.titleFontSize)
    BreakpointSystem.getInstance().attach(this.chevronSize)
    BreakpointSystem.getInstance().attach(this.RowMargin)
    BreakpointSystem.getInstance().attach(this.barHeight)
    BreakpointSystem.getInstance().attach(this.barMargin)
    BreakpointSystem.getInstance().attach(this.cardPadding)
    BreakpointSystem.getInstance().start()
  }
  aboutToDisappear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.titleFontSize)
    BreakpointSystem.getInstance().attach(this.chevronSize)
    BreakpointSystem.getInstance().attach(this.barHeight)
    BreakpointSystem.getInstance().attach(this.RowMargin)
    BreakpointSystem.getInstance().attach(this.barMargin)
    BreakpointSystem.getInstance().attach(this.cardPadding)
    BreakpointSystem.getInstance().stop()
  }


  build() {
    Column() {
      Text($r('app.string.CellularData'))
        .fontSize(this.isLandscapePhone ? 18 : this.titleFontSize.value)
          //.margin({left:this.RowPadding.value})
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
      Column() {
        Row() {
          Column() {
            Text() {SymbolSpan($r('sys.symbol.chevron_down'))}
            .fontSize(this.chevronSize.value)
            .fontColor($r('app.color.speed_down_icon'))
            Text(this.TotalDownloads.toString() + ' GB')
              //.margin(this.fontMargin.value)
              .fontSize(this.isLandscapePhone ? 14 : this.fontSize.value)
              .fontColor($r('app.color.speed_down_icon'))
          }
          .margin({top:this.RowMargin.value, right: this.RowMargin.value})
          .justifyContent(FlexAlign.Center)
          Column() {
            Text() {SymbolSpan($r('sys.symbol.chevron_up'))}
            .fontSize(this.chevronSize.value)
            .fontColor($r('app.color.speed_up_icon'))
            Text(this.TotalUpload.toString() + ' GB')
              //.margin(this.fontMargin.value)
              .fontSize(this.isLandscapePhone ? 14 : this.fontSize.value)
              .fontColor($r('app.color.speed_up_icon'))
          }
          .margin({top:this.RowMargin.value})
          .justifyContent(FlexAlign.Center)
          //.margin({top: this.RowPadding.value})
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        Column() {

        }
        .width('90%')
        .backgroundColor('#B2B2B2')
        .height(this.barHeight.value)
        .borderRadius(this.barHeight.value)
        .margin(this.barMargin.value)
        Text($r('app.string.CellularData_Statistics_explanation'))
          .fontSize(this.isLandscapePhone ? 14 : this.fontSize.value)
          .fontColor(this.font_primary)

      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      //.justifyContent(FlexAlign.Center)

    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
    //.justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
  }
}
export default TrafficStatistics