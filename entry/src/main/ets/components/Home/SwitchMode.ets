import {  BreakpointState } from '../../common/breakpoint/breakpointsystem'
import { mediaquery } from '@kit.ArkUI';
import { CardTitle } from './CardTitleBuilder';
import { AppConfig, UIConfig } from '../../entryability/AppState';
import { EventHub, EventKey } from '../../common/EventHub';
import { ClashConfig, ProxyMode } from 'proxy_core';
import { customVibrator } from '../../common/utils/VibratorUtil';
import { customAnimationUtil } from '../../common/utils/Animation';
import { HomeCardFontSize, HomeCardPadding } from '../../common/breakpoint/BreakPoint';

@Component
struct SwitchMode {
  //自定义主题，颜色在AppTheme里面修改
  @Consume('icon_emphasize') icon_emphasize: ResourceColor //高亮图标,可在apptheme更换
  @State font_primary: ResourceColor = $r('sys.color.font_primary')
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageLink ('isLandscapePhone')  private isLandscapePhone: boolean = false
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @State compStr: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg", xl: "xl" })
  // 代理模式选中状态
  @State currentChecked: number = 0
  //编辑按钮点击后显示编辑状态判定
  @Consume isShowHomeEdit: boolean
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  // 手机横屏高度条件
  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');
  // px外屏
  @Consume isPXSecScreen: boolean
  aboutToAppear() {
  }
  aboutToDisappear() {
  }

  onWillApplyTheme(theme: Theme) {
    this.icon_emphasize = theme.colors.iconEmphasize
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
        Button({type: ButtonType.Normal})
          .ButtonStyle()
          .shadow({ radius:10,color:$r('app.color.shadow')})
          .borderRadius(18)
          .height('33.3%')
          .translate({y:this.uiConfig.translateY})
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .backgroundColor($r('app.color.container_background'))

      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceAround }) {
          ForEach([
            { t: $r('app.string.Rule'), v: ProxyMode.Rule },
            { t: $r('app.string.Overall'), v: ProxyMode.Global },
            { t: $r('app.string.Direct'), v: ProxyMode.Direct }
          ], (n: [Resource, number], i: number) => {
            Button(n["t"], { buttonStyle: ButtonStyleMode.TEXTUAL, stateEffect: false })
              .ButtonStyle()
              .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
              .fontSize(HomeCardFontSize(this.widthBp, this.heightBp))
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
                    if (this.uiConfig.isVibrate) {
                      customVibrator.vibratorTriggerOfHapticClockTimer()
                    }
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
      .borderRadius(this.isPXSecScreen || this.isLandscapePhone ? 16 : 20)
    }
    .width('100%')
    .height('100%')
    .padding(HomeCardPadding(this.widthBp, this.heightBp))
    .id('SwitchModeId')
  }
}
export default SwitchMode


//按钮公用样式
@Extend(Button)
function ButtonStyle() {
  .width('100%')
  .height(vp2px(32.67))
  .fontWeight(FontWeight.Bold)
  .stateEffect(false)
}



