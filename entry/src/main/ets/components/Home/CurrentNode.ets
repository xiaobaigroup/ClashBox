import { BreakpointSystem, BreakpointState } from '../../common/breakpointsystem'
import { mediaquery } from '@kit.ArkUI'
import { MarginGenerate } from '../../common/Constants'
import { CardTitle } from './CardTitleBuilder'

@Component
struct CurrentNode {
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
  @State currentNode: string = '暂无节点'
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @State compStr: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg", xl: "xl" })
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
    BreakpointSystem.getInstance().attach(this.RowPadding)
    BreakpointSystem.getInstance().attach(this.fontMargin)
    BreakpointSystem.getInstance().start()
  }
  aboutToDisappear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontMargin)
    BreakpointSystem.getInstance().attach(this.RowPadding)
    BreakpointSystem.getInstance().stop()
  }


  build() {
    Column() {
      CardTitle({title: $r('app.string.CurrentNode')})
      Row() {
        Text(this.currentNode)
          .fontSize(23)
          .fontColor('grey')
          .fontColor(this.font_primary)
      }
      .flexGrow(1)
      .width('100%')
      .justifyContent(FlexAlign.Center)
      /*Row() {
        Text($r('app.string.Switch'))
          .fontSize(this.fontSize.value)
          .fontWeight(FontWeight.Bold)
        Text() {SymbolSpan($r('sys.symbol.chevron_right'))}
        .fontSize(this.fontSize.value)
        .margin({left:5})
      }
      .width('100%')
      .justifyContent(FlexAlign.End)*/
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
export default CurrentNode