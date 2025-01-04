import { BreakpointSystem, BreakpointState } from '../../common/breakpointsystem'
import { mediaquery } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit'
import { MarginGenerate } from '../../common/Constants';
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
    Column() {
      CardTitle({title: $r('app.string.Mode')})
      Column() {
        Row() {
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
            .margin(this.fontMargin.value)
            .fontColor(this.currentChecked === 1 ? this.font_primary : $r('sys.color.font_secondary'))
        }
        .width('98%')
        .borderRadius(18)
        .backgroundColor(this.currentChecked === 1 ? $r('app.color.container_background') : '')
        .justifyContent(FlexAlign.Center)
        .margin({top: this.RowMargin.value})
        .onClick(() => {
          this.currentChecked = 1
        })
        Row() {
          Text($r('app.string.Overall'))
            .fontWeight(FontWeight.Bold)
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .margin(this.fontMargin.value)
            .fontColor(this.currentChecked === 2 ? this.font_primary : $r('sys.color.font_secondary'))
        }
        .width('98%')
        .borderRadius(18)
        .backgroundColor(this.currentChecked === 2 ? $r('app.color.container_background') : '')
        .justifyContent(FlexAlign.Center)
        .margin({top: this.RowMargin.value})
        .onClick(() => {
          this.currentChecked = 2
        })
        Row() {
          Text($r('app.string.Direct'))
            .fontWeight(FontWeight.Bold)
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .margin(this.fontMargin.value)
            .fontColor(this.currentChecked === 3 ? this.font_primary : $r('sys.color.font_secondary'))
        }
        .width('98%')
        .borderRadius(18)
        .backgroundColor(this.currentChecked === 3 ? $r('app.color.container_background') : '')
        .justifyContent(FlexAlign.Center)
        .margin({top: this.RowMargin.value})
      }
      .width('100%')
      .layoutWeight(1)
      .borderRadius(20)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.currentChecked = 3
      })

    }
    .padding(this.cardPadding.value)
    .width('100%')
    // .height('100%')
    .alignItems(HorizontalAlign.Center)

  }
}
export default SwitchMode






