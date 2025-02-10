import {  BreakpointState } from '../../common/breakpointsystem'
import { curves, mediaquery } from '@kit.ArkUI';
import { ANIMATION_DURATION_300, MarginGenerate } from '../../common/Constants';
import { CardTitle } from './CardTitleBuilder';
import { AppConfig, SwitchModeCard, UIConfig } from '../../entryability/AppState';
import { EventHub, EventKey } from '../../common/EventHub';
import { ClashConfig, ProxyMode } from 'proxy_core';
import { customVibrator } from '../../utils/VibratorUtil';

@Component
struct SwitchMode {
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
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding')  private cardPadding: BreakpointState<MarginGenerate>
  //编辑按钮点击后显示编辑状态判定
  @Consume isShowHomeEdit: boolean
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  // 手机横屏高度条件
  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');

  aboutToAppear() {
  }
  aboutToDisappear() {
  }

  //平移选择动画参数切换
  switchTranslateY(index: number) {
    switch (index) {
      case 0:
        this.uiConfig.translateY='-100%'
        break;
      case 1:
        this.uiConfig.translateY=0
        break
      case 2:
        this.uiConfig.translateY='100%'
        break
    }
  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween }) {
      CardTitle({ title: $r('app.string.Mode') })
      Stack() {
        //平移动画使用的底色组件
        Button()
          .ButtonStyle()
          .shadow({ radius:10,color:$r('app.color.shadow')})
          .height('33.3%')
          .translate({y:this.uiConfig.translateY})
          .clickEffect(this.uiConfig.isAnimation ? { level: ClickEffectLevel.MIDDLE, scale: 0.8 } : null)
          .backgroundColor($r('app.color.container_background'))

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
          ForEach([
            { t: $r('app.string.Rule'), v: ProxyMode.Rule },
            { t: $r('app.string.Overall'), v: ProxyMode.Global },
            { t: $r('app.string.Direct'), v: ProxyMode.Direct }
          ], (n: [Resource, number], i: number) => {
            Button(n["t"], { buttonStyle: ButtonStyleMode.TEXTUAL, stateEffect: false })
              .ButtonStyle()
              .clickEffect(this.uiConfig.isAnimation ? { level: ClickEffectLevel.MIDDLE, scale: 0.8 } : null)
              .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
              .fontColor(this.clashConfig.mode == n["v"] ? this.font_primary : $r('sys.color.font_secondary'))
              .onClick(() => {
                //在home页编辑卡片状态时，无法操作，点击回调写在if判定里
                if (this.isShowHomeEdit === false) {
                  animateTo({
                    duration: this.uiConfig.animationSpeed,
                    iterations: 1,
                    playMode: PlayMode.Normal,
                    curve:Curve.Friction,
                  }, () => {
                    this.clashConfig.mode = n["v"]
                    this.switchTranslateY(i)
                    EventHub.sendEvent(EventKey.SwitchModeCard, n["v"])
                    customVibrator.vibratorTriggerOfHapticClockTimer()
                  })
                }
              })
          })
        }
      }
      .width('100%')
      .height('82%')
      .padding({ top:2,bottom:2,left:3,right:3 })
      .backgroundColor($r('app.color.home_card_background'))
      .borderRadius(20)
    }
    .width('100%')
    .height('100%')
    .padding(this.cardPadding.value)
    .id('SwitchModeId')
  }
}
export default SwitchMode


//按钮公用样式
@Extend(Button)
function ButtonStyle() {
  .width('100%')
  .height(vp2px(32.67))
  .borderRadius(18)
  .fontWeight(FontWeight.Bold)
  .stateEffect(false)
}



