import { BreakpointSystem, BreakpointState } from '../../common/breakpointsystem'
import { mediaquery } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit'
import { ANIMATION_DURATION_300, MarginGenerate } from '../../common/Constants';
import { CardTitle } from './CardTitleBuilder';

@Component
struct SwitchMode {
  private componentName:string = 'SwitchMode'
  //自定义主题，颜色在AppTheme里面修改
  @Consume('icon_emphasize') icon_emphasize: ResourceColor //高亮图标,可在apptheme更换
  @State font_primary: ResourceColor = $r('sys.color.font_primary')

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
  //编辑按钮点击后显示编辑状态判定
  @Consume isShowHomeEdit: boolean

  // 手机横屏高度条件
  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');

  aboutToAppear() {

  }
  aboutToDisappear() {

  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween }) {
      CardTitle({ title: $r('app.string.Mode') })

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
        Text($r('app.string.Rule'))
          .TextStyle()
          .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
          .fontColor(this.currentChecked === 1 ? this.font_primary : $r('sys.color.font_secondary'))
          .backgroundColor(this.currentChecked === 1 ? $r('app.color.container_background'):'#00ffffff')
     //     .shadow(this.currentChecked === 1 ? { radius: 3,color:$r('app.color.shadow')} : { } )
          .onClick(() => {
            //在home页编辑卡片状态时，无法操作，点击回调写在if判定里
            if (!this.isShowHomeEdit) {
              this.currentChecked = 1
            }
          })

        Text($r('app.string.Overall'))
          .TextStyle()
          .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
          .fontColor(this.currentChecked === 2 ? this.font_primary : $r('sys.color.font_secondary'))
          .backgroundColor(this.currentChecked === 2 ? $r('app.color.container_background'):'#00ffffff')
    //      .shadow(this.currentChecked === 2 ? { radius: 3, color:$r('app.color.shadow')} : { } )
          .onClick(() => {
            //在home页编辑卡片状态时，无法操作，点击回调写在if判定里
            if (!this.isShowHomeEdit) {
              this.currentChecked = 2
            }
            })

        Text($r('app.string.Direct'))
          .TextStyle()
          .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
          .fontColor(this.currentChecked === 3 ? this.font_primary : $r('sys.color.font_secondary'))
          .backgroundColor(this.currentChecked === 3 ? $r('app.color.container_background'):'#00ffffff')
    //      .shadow(this.currentChecked === 3 ? { radius: 3, color:$r('app.color.shadow')} : { } )
          .onClick(() => {
            //在home页编辑卡片状态时，无法操作，点击回调写在if判定里
            if (!this.isShowHomeEdit) {
              this.currentChecked = 3
            }
            })
        }
      .width('100%')
      .height('82%')
      .backgroundColor($r('app.color.home_card_background'))
      .borderRadius(20)
      .padding({ top:2,bottom:2,left:3,right:3 })
    }
    .width('100%')
    .height('100%')
    .padding(this.cardPadding.value)
    .id('SwitchModeId')
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
 // .transition(TransitionEffect.translate({y:10}).animation({ duration: 300, curve: Curve.Ease }))
  .clickEffect({ level: ClickEffectLevel.MIDDLE,scale:0.8})
}



