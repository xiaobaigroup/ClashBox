import { BreakpointSystem, BreakpointState } from '../../common/breakpointsystem'
import { mediaquery } from '@kit.ArkUI'
import { MarginGenerate } from '../../common/Constants'
import { CardTitle } from './CardTitleBuilder'

@Component
struct PublicNetwork {
  //自定义主题，颜色在AppTheme里面修改
  @State font_primary: ResourceColor = $r('sys.color.font_primary')
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

  @State address: string = '中国大陆'
  @State IP: string = '255.255.255.255'
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @State compStr: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg", xl: "xl" })
  @State fontSize: BreakpointState<number> = BreakpointState.of({
    sm: 16, md: 27, lg: 26, xl: 27
  });
  @State IPfontSize: BreakpointState<number> = BreakpointState.of({
    sm: 20, md: 30, lg: 26, xl: 27
  });
  @State RowPadding: BreakpointState<number> = BreakpointState.of({
    sm: 10, md: 10, lg: 10, xl: 20
  });
  @State fontMargin: BreakpointState<MarginGenerate> = BreakpointState.of({
    sm: ({ left: 20 } as MarginGenerate),
    md: ({ left: 55 } as MarginGenerate),
    lg: ({ left: 50 } as MarginGenerate),
    xl: ({ left: 50 } as MarginGenerate)
  });
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding')  private cardPadding: BreakpointState<MarginGenerate>

  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');

  aboutToAppear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.IPfontSize)
    BreakpointSystem.getInstance().attach(this.RowPadding)
    BreakpointSystem.getInstance().attach(this.fontMargin)
    BreakpointSystem.getInstance().start()
  }
  aboutToDisappear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.IPfontSize)
    BreakpointSystem.getInstance().attach(this.fontMargin)
    BreakpointSystem.getInstance().attach(this.RowPadding)
    BreakpointSystem.getInstance().stop()

  }


  build() {
    Column() {
      CardTitle({title: $r('app.string.PublicNetwork')})
      Column() {
        Row() {
          Text(this.address)
            .fontSize(this.isLandscapePhone ? 12 : this.fontSize.value)
            .fontColor(this.font_primary)
        }
        .justifyContent(FlexAlign.Start)
        Text(this.IP)
          .fontSize(this.isLandscapePhone ? 20 : this.IPfontSize.value)
          .textAlign(TextAlign.Start)
          .margin(this.RowPadding.value)
          .fontColor(this.font_primary)

      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .flexGrow(1)
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
    //.justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
  }
}
export default PublicNetwork