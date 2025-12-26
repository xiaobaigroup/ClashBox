import { BreakpointState } from '../../common/breakpoint/breakpointsystem'
import { mediaquery, PromptAction } from '@kit.ArkUI'
import { CardTitle } from './CardTitleBuilder'
import { AppConfig, isEnd, UIConfig } from '../../entryability/AppState'
import { customVibrator } from '../../common/utils/VibratorUtil'
import { customAnimationUtil } from '../../common/utils/Animation'
import ClashViewModel from '../../entryability/ClashViewModel'
import { EventHub, EventKey } from '../../common/EventHub'
import { getResourceString } from '../../common/utils/ResourceStringUtil'
import { HomeCardDeleteButtonSize, HomeCardFontSize, HomeCardPadding,
  HomeCardPartSmallFontSize } from '../../common/breakpoint/BreakPoint'
import { Xb_ToastUtil } from 'xb_components'


@Component
struct FavoriteConfiguration {

  @StorageLink('favoriteProfiles') favoriteProfiles: Map<string, string> = new Map<string, string>([])
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 编辑按钮点击后显示编辑状态判定
  @Consume isShowHomeEdit: boolean

  build() {
    Column() {
      CardTitle({ title: $r('app.string.FavoriteConfiguration') })
      // 收藏配置 start
      if (this.favoriteProfiles.size > 0) {
        List() {
          ForEach(Array.from(this.favoriteProfiles.entries()), (f:[string, string], i: number) => {
            ListItem() {
              Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceEvenly }) {
                Text(f[1])
                  .fontSize(HomeCardFontSize(this.widthBp, this.heightBp))
                  .fontColor($r('sys.color.font_primary'))
                  .maxLines(1)
                  .width('80%')
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Radio({ value: 'FavoriteConfigurationRadio1', group: 'FavoriteConfigurationRadioGroup' })
                  .width(HomeCardFontSize(this.widthBp, this.heightBp))
                  .checked(f[0] === this.appConfig.currentProfileId)
                  .radioStyle({
                    checkedBackgroundColor: this.icon_emphasize,
                  })
                  .hitTestBehavior(HitTestMode.None)
              }
            }
            .height(this.favoriteProfiles.size - 1 == 1 ? '50%' : '32%')
            .onClick(async () => {
              if (!this.isShowHomeEdit) {
                this.appConfig.currentProfileId = f[0]
                EventHub.sendEvent(EventKey.LoadClashConfig)
                await ClashViewModel.loadConfig(false, 'FavoriteConfiguration-点击收藏行');
                Xb_ToastUtil.showToast({message: getResourceString($r('app.string.load_success'), this)})
                if (this.uiConfig.isVibrate) {
                  customVibrator.vibratorTriggerOfHapticClockTimer()
                }
              }
            })
            .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
            .transition({ type: TransitionType.Delete, opacity: 0 }).swipeAction({
              end: {
                builder: () => {
                  this.itemEnd(f[0]);
                },
                actionAreaDistance: 56,
              },
              edgeEffect: SwipeEdgeEffect.Spring
            })
            if(!isEnd(this.favoriteProfiles.size, i))
              Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))
          })
        }
        .width('100%')
        .height('82%')
        .backgroundColor($r('app.color.home_card_background'))
        .borderRadius(10)
        .padding({ left: 8, right: 5 })
      } // 收藏配置 end
      // 无收藏配置时的布局 start
      else {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
          SymbolGlyph($r('sys.symbol.star'))
            .fontSize(HomeCardDeleteButtonSize(this.widthBp, this.heightBp))
            .fontColor([$r('sys.color.font_secondary')])
            .padding({bottom:5})
          Text($r('app.string.favorite_configuration_tips'))
            .fontSize(HomeCardPartSmallFontSize(this.widthBp, this.heightBp))
            .fontColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height("78%")
      } // 无收藏配置时的布局 end
    }
    .padding(HomeCardPadding(this.widthBp, this.heightBp))
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .id('FavoriteConfigurationId')
  }

  @Builder
  itemEnd(id: string) {
    Button({ type: ButtonType.Circle }) {
      SymbolGlyph($r('sys.symbol.trash_fill'))
        .fontColor([Color.Red])
        .fontSize(HomeCardFontSize(this.widthBp, this.heightBp))
    }
    .padding(5)
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      this.favoriteProfiles.delete(id)
    })
  }

}

export default FavoriteConfiguration