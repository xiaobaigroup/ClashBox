import {  BreakpointState } from '../../common/breakpoint/breakpointsystem'
import { mediaquery } from '@kit.ArkUI';
import { CardTitle } from './CardTitleBuilder';
import { AppConfig, UIConfig } from '../../entryability/AppState';
import { EventHub, EventKey } from '../../common/EventHub';
import { ClashConfig, ProxyMode } from 'proxy_core';
import { customVibrator } from '../../common/utils/VibratorUtil';
import { customAnimationUtil } from '../../common/utils/Animation';
import { HomeCardFontSize, HomeCardPadding, HomeCardSwitchModeBorderRadius } from '../../common/breakpoint/BreakPoint';
import { font_primary } from '../Common/Common';

@Component
struct SwitchMode {

  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  //编辑按钮点击后显示编辑状态判定
  @Consume isShowHomeEdit: boolean
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()

  // 手机横屏高度条件
  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');

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
              .fontColor(this.clashConfig.mode == n["v"] ? font_primary : $r('sys.color.font_secondary'))
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
      .padding({ top: 2,bottom: 2,left: 3,right: 3 })
      .backgroundColor($r('app.color.home_card_background'))
      .borderRadius(HomeCardSwitchModeBorderRadius(this.widthBp, this.heightBp))
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



