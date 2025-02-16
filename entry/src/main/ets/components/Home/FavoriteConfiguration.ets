import { BreakpointState } from '../../common/breakpointsystem'
import { mediaquery, PromptAction } from '@kit.ArkUI'
import { MarginGenerate } from '../../common/Constants'
import { CardTitle } from './CardTitleBuilder'
import { AppConfig, isEnd, UIConfig } from '../../entryability/AppState'
import { customVibrator } from '../../utils/VibratorUtil'
import { customAnimationUtil } from '../../utils/Animation'
import ClashViewModel from '../../entryability/ClashViewModel'
import { EventHub, EventKey } from '../../common/EventHub'
import { getResourceString } from '../../utils/ResourceStringUtil'


@Component
struct FavoriteConfiguration {
  //后端接入后此处应改为收藏的配置项
  @State FavoriteConfiguration: string [] = ['收藏配置1','收藏配置2','收藏配置3']
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding')  private cardPadding: BreakpointState<MarginGenerate>
  // 内容文本字体大小
  @Consume('breakPointStateHomeCardSwitchModeFontSize') private fontSize: BreakpointState<number>
  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');
  //radio选中判定
  @State FavoriteConfigurationRadio :number =0
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //有无收藏代理节点判定
  @State isCheckFavoriteConfiguration:number=-1
  //主页卡片内容IP地址小字体大小
  @Consume('HomeCardIPSmFontSize')
  private HomeCardIPSmFontSize: BreakpointState<number>
  /*
编辑模式下右上角删除按钮
 */
  @Consume deleteButtonSize: BreakpointState<number>
  @StorageLink('favoriteProfiles') favoriteProfiles: Map<string, string> = new Map<string, string>([])
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  //编辑按钮点击后显示编辑状态判定
  @Consume isShowHomeEdit: boolean
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  private promptAction:PromptAction = this.getUIContext()?.getPromptAction()

  build() {
    Column() {
      CardTitle({ title: $r('app.string.FavoriteConfiguration') })
      //拥有收藏配置的布局 start
      if (this.favoriteProfiles.size > 0) {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceEvenly }) {
          ForEach(Array.from(this.favoriteProfiles.entries()), (f:[string, string], i: number)=>{
            Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
              Text(f[1])
                .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
                .fontColor($r('sys.color.font_primary'))
                .maxLines(1)
                .width('80%')
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Radio({ value: 'FavoriteConfigurationRadio1', group: 'FavoriteConfigurationRadioGroup' })
                .width(this.isLandscapePhone ? 16 : this.fontSize.value)
                .checked(f[0] === this.appConfig.currentProfileId)
                .radioStyle({
                  checkedBackgroundColor: this.icon_emphasize,
                })
                .hitTestBehavior(HitTestMode.None)
                .onChange(async (isChecked: boolean) => {
                  //在home页编辑状态时，无法操作
                  if (this.isShowHomeEdit === false && isChecked) {
                    await ClashViewModel.loadConfig(false); // 假设loadConfig返回一个Promise
                    this.appConfig.currentProfileId = f[0]
                    this.promptAction.showToast({message: getResourceString($r('app.string.load_success'), this)})
                    if (this.uiConfig.isVibrate) {
                      customVibrator.vibratorTriggerOfHapticClockTimer()
                    }
                  }
                })
            }
            .onClick(async () => {
              if (this.isShowHomeEdit===false) {
                this.appConfig.currentProfileId = f[0]
                EventHub.sendEvent(EventKey.LoadClashConfig)
                await ClashViewModel.loadConfig(false); // 假设loadConfig返回一个Promise
                this.promptAction.showToast({message: getResourceString($r('app.string.load_success'), this)})
                if (this.uiConfig.isVibrate) {
                  customVibrator.vibratorTriggerOfHapticClockTimer()
                }
              }
            })
            .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
            if(!isEnd(this.favoriteProfiles.size, i))
              Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))
          })
        }
        .width('100%')
        .height('82%')
        .backgroundColor($r('app.color.home_card_background'))
        .borderRadius(10)
        .padding({ left: 8, right: 5 })
      }//拥有收藏配置的布局 end
      //没有收藏配置时的布局 start
      else
      {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
          SymbolGlyph($r('sys.symbol.star'))
            .fontSize(this.isLandscapePhone?24 :this.deleteButtonSize.value)
            .fontColor([$r('sys.color.font_secondary')])
            .padding({bottom:5})

          Text($r('app.string.favorite_configuration_tips'))
            .fontSize(this.isLandscapePhone ? 12:this.HomeCardIPSmFontSize.value)
            .fontColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height("78%")
        .onClick(() => {
          //在home页编辑状态时，无法操作
          if (this.isShowHomeEdit===false) {
          }
        })//为预览而设置的点击事件，后端接入修改或删除
      }//没有收藏配置时的布局 end
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .id('FavoriteConfigurationId')
  }
}
export default FavoriteConfiguration