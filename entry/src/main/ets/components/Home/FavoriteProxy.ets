import { BreakpointState } from '../../common/breakpointsystem'
import { mediaquery, promptAction } from '@kit.ArkUI'
import { MarginGenerate } from '../../common/Constants'
import { CardTitle } from './CardTitleBuilder'
import { ProxyGroupItemDataSource, ProxyItem } from '../../common/ProxyData'
import { AppConfig, AppState, isEnd, UIConfig } from '../../entryability/AppState'
import { Profile, ProxyGroup } from 'proxy_core'
import { customVibrator } from '../../utils/VibratorUtil'
import { customAnimationUtil } from '../../utils/Animation'
import ClashViewModel from '../../entryability/ClashViewModel'
import { EventHub, EventKey } from '../../common/EventHub'


@Component
struct FavoriteProxy {
  //节点假数据组后期可改可删
  @Consume items: ProxyItem[]
  @Prop selectedProxy: string
  @Prop disabled: boolean
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding')  private cardPadding: BreakpointState<MarginGenerate>
  // 内容文本字体大小
  @Consume('breakPointStateHomeCardSwitchModeFontSize') private fontSize: BreakpointState<number>
  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');
  //radio选中判定
  @State FavoriteProxyRadio :number =0
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //主页卡片内容IP地址小字体大小
  @Consume('HomeCardIPSmFontSize')
  private HomeCardIPSmFontSize: BreakpointState<number>
  /*编辑模式下右上角删除按钮*/
  @Consume deleteButtonSize: BreakpointState<number>
  // 当前代理节点长按选择的值
  @Consume private FavoriteProxy: number
  // 当前代理节点长按选择的值
  @Consume private ProxyItemLongPressValue: number
  //编辑按钮点击后显示编辑状态判定
  @Consume isShowHomeEdit: boolean
  @Consume theProxyGroups: ProxyGroup[]
  // 代理数据(懒加载)
  @Consume proxyGroups: ProxyGroupItemDataSource
  @StorageLink('favoriteProxys') favoriteProxys: Map<string, string> = new Map<string, string>([])
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink("proxyGroups") ProxyGroups: ProxyGroup[] = []
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @Consume('currentProfile') currentProfile: Profile | null

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
                      .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
                      .fontColor($r('sys.color.font_primary'))
                      .maxLines(1)
                      .width('80%')
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Radio({ value: 'FavoriteProxyRadio', group: 'FavoriteProxyGroup' })
                      .width(this.isLandscapePhone ? 16 : this.fontSize.value)
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
      }//拥有收藏节点的布局 end

      //没有收藏节点的布局 start
      else
      {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
          SymbolGlyph($r('sys.symbol.star'))
            .fontSize(this.isLandscapePhone?24 :this.deleteButtonSize.value)
            .fontColor([$r('sys.color.font_secondary')])
            .padding({bottom:5})

          Text($r('app.string.favorite_proxy_tips'))
            .fontSize(this.isLandscapePhone ? 12:this.HomeCardIPSmFontSize.value)
            .fontColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height("78%")
      }//没有收藏节点的布局 end
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .id('FavoriteProxyId')
  }
}
export default FavoriteProxy


