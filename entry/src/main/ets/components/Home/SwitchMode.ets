import { BreakpointSystem, BreakpointState } from '../../common/breakpointsystem'
import { mediaquery } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit'
import { ANIMATION_DURATION_300, MarginGenerate } from '../../common/Constants';
import { CardTitle } from './CardTitleBuilder';

@Component
struct SwitchMode {
  private componentName:string = 'SwitchMode'
  //自定义主题，颜色在AppTheme里面修改
  @State font_primary: ResourceColor = $r('sys.color.font_primary')
  @Consume('icon_emphasize') icon_emphasize: ResourceColor //高亮图标,可在apptheme更换

  onWillApplyTheme(theme: Theme) {
    this.icon_emphasize = theme.colors.iconEmphasize;
  }

  // 代理模式选中状态
  @State currentChecked: number = 0
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @State compStr: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg", xl: "xl" })
  // 内容文本字体大小
  @Consume('breakPointStateHomeCardSwitchModeFontSize') private fontSize: BreakpointState<number>
  // Row上下边距
  @Consume('breakPointStateHomeCardSwitchModeRowMargin')  private RowMargin: BreakpointState<number>
  // 文本上下边距
  @Consume('breakPointStateHomeCardSwitchModeTextMargin') private fontMargin: BreakpointState<MarginGenerate>
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding')  private cardPadding: BreakpointState<MarginGenerate>

  // 手机横屏高度条件
  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');

  aboutToAppear() {

  }
  aboutToDisappear() {

  }


  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween }) {
      CardTitle({ title: $r('app.string.Mode') })
      Blank(5)
      Flex({ direction: FlexDirection.Column,alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
        Text($r('app.string.Rule'))
          .TextStyle()
          .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
          .fontColor(this.currentChecked === 1 ? this.font_primary : $r('sys.color.font_secondary'))
          .backgroundColor(this.currentChecked === 1 ? $r('app.color.container_background') : '#00ffffff')
     //     .shadow(this.currentChecked === 1 ? { radius: 3,color:$r('app.color.shadow')} : { } )
          .onClick(() => {this.currentChecked = 1})
        Text($r('app.string.Overall'))
          .TextStyle()
          .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
          .fontColor(this.currentChecked === 2 ? this.font_primary : $r('sys.color.font_secondary'))
          .backgroundColor(this.currentChecked === 2 ? $r('app.color.container_background') : '#00ffffff')
    //      .shadow(this.currentChecked === 2 ? { radius: 3, color:$r('app.color.shadow')} : { } )
          .onClick(() => {this.currentChecked = 2})
        Text($r('app.string.Direct'))
          .TextStyle()
          .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
          .fontColor(this.currentChecked === 3 ? this.font_primary : $r('sys.color.font_secondary'))
          .backgroundColor(this.currentChecked === 3 ? $r('app.color.container_background') : '#00ffffff')
    //      .shadow(this.currentChecked === 3 ? { radius: 3, color:$r('app.color.shadow')} : { } )
          .onClick(() => {this.currentChecked = 3})
      }
      .width('100%')
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .borderRadius(20)
      .padding({ top:2,bottom:2,left:3,right:3 })
    }
    .width('100%')
    .height('100%')
    .padding(this.cardPadding.value)

    /*     Column({ space: 2 }) {
           Button() {
             // Radio({ value: 'rule', group: 'connectModeRadioGroup', indicatorType: RadioIndicatorType.DOT })
             //   .checked($$this.radioRuleChecked)
             //   .onChange((value: boolean) => {
             //     hilog.info(0xA001, this.componentName, `#Radio()#rule#state: ${this.radioRuleChecked}`)
             //   })
             //   .radioStyle({
             //     checkedBackgroundColor: this.icon_emphasize,
             //   })
             Text($r('app.string.Rule'))
               .fontWeight(FontWeight.Bold)
               .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
       //        .margin(this.fontMargin.value)
               .fontColor(this.currentChecked === 1 ? this.font_primary : $r('sys.color.font_secondary'))
           }
           .width('98%')
           .borderRadius(18)
       //    .shadow({ radius: 3, color:$r('app.color.shadow')  })
           .backgroundColor(this.currentChecked === 1 ? $r('app.color.container_background') : '')
        //   .justifyContent(FlexAlign.Center)
     //      .margin({top: this.RowMargin.value,right:this.RowMargin.value,left:this.RowMargin.value})
           .onClick(() => {
             this.currentChecked = 1
           })*/
  }
}
export default SwitchMode


//按钮公用样式
@Extend(Text)
function TextStyle() {
  .width('100%')
  .height(vp2px(32.67))
  .borderRadius(18)
  .fontWeight(FontWeight.Bold)
  .textAlign(TextAlign.Center)
  .transition(TransitionEffect.OPACITY)
  .clickEffect({ level: ClickEffectLevel.MIDDLE,scale:0.8})
}



