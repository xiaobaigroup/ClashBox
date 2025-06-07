import { BreakpointState } from '../../common/breakpoint/breakpointsystem'
import { mediaquery} from '@kit.ArkUI'
import { CardTitle } from './CardTitleBuilder'
import { ProxyGroupItemDataSource, ProxyItem } from '../../common/datasources/ProxyData'
import { AppConfig, AppState, UIConfig } from '../../entryability/AppState'
import { Profile, ProxyGroup } from 'proxy_core'
import { customVibrator } from '../../common/utils/VibratorUtil'
import { customAnimationUtil } from '../../common/utils/Animation'
import ClashViewModel from '../../entryability/ClashViewModel'
import { HomeCardDeleteButtonSize, HomeCardFontSize, HomeCardPadding,
  HomeCardPartSmallFontSize } from '../../common/breakpoint/BreakPoint'


@Component
struct FavoriteProxy {

  @StorageLink('favoriteProxys') favoriteProxys: Map<string, string> = new Map<string, string>([])
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @StorageLink("proxyGroups") ProxyGroups: ProxyGroup[] = []
  @Consume('currentProfile') currentProfile: Profile | null
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @Consume theProxyGroups: ProxyGroup[]
  // 编辑按钮点击后显示编辑状态判定
  @Consume isShowHomeEdit: boolean

  build() {
    Column() {
      CardTitle({ title: $r('app.string.FavoriteProxy') })
      //拥有收藏节点的布局 start
      if (AppState.fetchFavoriteProxys(this.favoriteProxys, this.theProxyGroups).length > 0 ) {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceEvenly }) {
          List({}) {
            ForEach(AppState.fetchFavoriteProxys(this.favoriteProxys, this.theProxyGroups),
              (p: [string, string], i: number) => {
                ListItem() {
                  Flex({
                    direction: FlexDirection.Row,
                    alignItems: ItemAlign.Center,
                    justifyContent: FlexAlign.SpaceBetween
                  }) {
                    Text(`${p[1]}`)
                      .fontSize(HomeCardFontSize(this.widthBp, this.heightBp))
                      .fontColor($r('sys.color.font_primary'))
                      .maxLines(1)
                      .width('80%')
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Radio({ value: 'FavoriteProxyRadio', group: 'FavoriteProxyGroup' })
                      .width(HomeCardFontSize(this.widthBp, this.heightBp))
                      .checked(this.appConfig.currentProxyName === p[1])
                      .radioStyle({
                        checkedBackgroundColor: this.icon_emphasize,
                      })
                      .hitTestBehavior(HitTestMode.None)
                  }
                  .onClick(() => {
                    // 在home页编辑状态时，无法操作
                    if (this.isShowHomeEdit === false) {
                      this.appConfig.currentProxyName = p[1]
                      this.appConfig.currentProxyItem = AppState.fetchProxyItem(this.theProxyGroups, p[0], p[1])
                      // 对应切换代理页节点
                      this.changeProxy(p[0], this.appConfig.currentProxyItem)
                      if (this.uiConfig.isVibrate) {
                        customVibrator.vibratorTriggerOfHapticClockTimer()
                      }
                    }
                  })
                  .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                }.height(AppState.fetchFavoriteProxys(this.favoriteProxys, this.theProxyGroups).length - 1 == 1 ? '50%' : '32%')
              })
          }.divider({ strokeWidth: 1, color: $r('app.color.FavoriteProxyDivider') })
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.None)
        }
        .width('100%')
        .height('82%')
        .backgroundColor($r('app.color.home_card_background'))
        .borderRadius(10)
        .padding({ left: 8, right: 5 })
      }// 拥有收藏节点的布局 end

      // 没有收藏节点的布局 start
      else {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
          SymbolGlyph($r('sys.symbol.star'))
            .fontSize(HomeCardDeleteButtonSize(this.widthBp, this.heightBp))
            .fontColor([$r('sys.color.font_secondary')])
            .padding({bottom:5})

          Text($r('app.string.favorite_proxy_tips'))
            .fontSize(HomeCardPartSmallFontSize(this.widthBp, this.heightBp))
            .fontColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height("78%")
      }//没有收藏节点的布局 end
    }
    .padding(HomeCardPadding(this.widthBp, this.heightBp))
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .id('FavoriteProxyId')
  }

  changeProxy(g: string, item: ProxyItem){
    if (this.currentProfile) {
      ClashViewModel.changeProxy(this.currentProfile, g, item.name)
    }
  }

  aboutToAppear(): void {
    this.theProxyGroups = this.ProxyGroups
  }

  aboutToDisappear() {
    this.ProxyGroups = this.theProxyGroups
  }

}
export default FavoriteProxy