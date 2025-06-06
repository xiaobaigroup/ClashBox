import { BORDER_RADIUS_20, CONTENT_END_OFFSET_150, FONT_SIZE_16, LIST_ITEM_HEIGHT} from '../../common/entity/Constants'
import { BreakpointState, BreakpointSystem } from '../../common/breakpoint/breakpointsystem'
import { hilog } from "@kit.PerformanceAnalysisKit"
import ProxyGroupItem from './ProxyGroupItem'
import { Profile, ProxyGroup,ProxyType } from 'proxy_core'
import { ProxyItem, ProxyGroupItemDataSource } from '../../common/datasources/ProxyData'
import ClashViewModel from '../../entryability/ClashViewModel'
import { AppConfig, UIConfig } from '../../entryability/AppState'
import { customAnimationUtil } from '../../common/utils/Animation'

const  componentName: string = 'ProxyPageArrangement'

/**
 * 列表排列
 */
@Component
struct ProxyArrangement {
  @Consume isRolling: boolean
  // page内顶部标题偏移量
  @Consume curYOffset: number
  @State selectItem: number = 0
  // px外屏隐藏top和tab偏移
  @Consume curOffsetRemain: number
  // 当前代理分组
  @Consume currentProxyIndex: number
  // 代理原始数据
  @Consume theProxyGroups: ProxyGroup[]
  @Consume proxyGroups: ProxyGroupItemDataSource
  @State isContentShow: boolean | undefined = false
  @Consume('currentProfile') private currentProfile: Profile
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageLink ('isLandscapePhone') private isLandscapePhone: boolean = false
  @StorageLink('favoriteProxys') favoriteProxys: Map<string, string> = new Map<string, string>([])

  aboutToAppear(): void {
    hilog.info(0xB000, componentName, '#aboutToAppear 组1数组长度： %{public}d', this.theProxyGroups[0].proxies.length )
    BreakpointSystem.getInstance().start()
    hilog.info(0xFF00, "ProxyPageGroupTag", "#ProxyArrangement#aboutToAppear 当前显示分组%{public}d", this.currentProxyIndex)
    if (this.currentProfile){
      let listIndexes = this.theProxyGroups.findIndex((d) => d.name == this.currentProfile?.currentGroupName)
      setTimeout(() => {
        if(listIndexes > -1 && this.currentProxyIndex === 0) {
          this.currentProxyIndex = listIndexes
          this.selectItem = listIndexes
          this.proxyScroller.scrollToItemInGroup(0, this.currentProxyIndex)
        } else {
          this.proxyScroller.scrollToItemInGroup(0, this.currentProxyIndex)
          this.selectItem = this.currentProxyIndex
        }
      }, 200)
    }
    if(this.currentProfile && this.currentProfile?.proxySelected){
      console.log("proxySelected", this.currentProfile?.proxySelected.size)
    }
  }

  changeProxy(g: string, item: ProxyItem){
    if (this.currentProfile) {
      ClashViewModel.changeProxy(this.currentProfile, g, item.name)
    }
  }

  //分组标签
  @Builder
  itemHead(text: string, icon: Resource) {
      Row() {
        Text(text)
          .fontSize(FONT_SIZE_16)
          .fontColor($r('sys.color.font_primary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        SymbolGlyph(icon)
          .fontSize(25).fontColor([$r('sys.color.icon_primary')])
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 10, right: 10 })
      .borderRadius(BORDER_RADIUS_20)
      .backgroundColor($r('app.color.container_background'))
      .height(LIST_ITEM_HEIGHT)
      .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
  }

  proxyScroller: ListScroller = new ListScroller()

  build() {
    List({ initialIndex: 0, scroller: this.proxyScroller}) {
      LazyForEach(this.proxyGroups, (group: ProxyGroup, index: number) => {
        ListItemGroup({
          header: this.itemHead(group.name, !this.isContentShow && this.selectItem === index
            ? $r('sys.symbol.chevron_down') : $r('sys.symbol.chevron_right'))
        }) {
          // 展开后内容显示区域
          if (!this.isContentShow && this.selectItem === index) {
            ProxyGroupItem({
              proxyitems: group.proxies as ProxyItem[],
              ProxyGroupItemSelected: this.appConfig.proxyCardSize,
              disabled: group.type !== ProxyType.Selector,
              selectedProxy: this.currentProfile.getSelectedProxy(group) ?? this.appConfig.currentProxyName ?? '',
              OnProxyChange: (item) => {
                this.changeProxy(group.name, item)
              }
            })
              .width('100%')
              .padding({ top: 10})
              .borderRadius(BORDER_RADIUS_20)
          }
        }.margin({bottom: (!this.isContentShow && this.selectItem === index) ? 0 : 10})
        .clickEffect(this.isContentShow?customAnimationUtil.isClickEffect(this.uiConfig):null)
        .transition(customAnimationUtil.isScaleTranFast(index, this.uiConfig))
        .onClick(() => {
          animateTo({
            duration: this.uiConfig.animationSpeed,
            onFinish: () => {
            }
          }, () => {
            if (!this.isContentShow) {
              this.proxyScroller.scrollToItemInGroup(index, 0, true, ScrollAlign.START)
            }
            this.isContentShow = !this.isContentShow
            this.selectItem = index
          })
        })
        .width('100%')
        .borderRadius(BORDER_RADIUS_20)
     //   .constraintSize({maxHeight: 300})
      }, (item: ProxyGroup) => item.name)
    }
    .contentEndOffset(this.isLandscapePhone?80:CONTENT_END_OFFSET_150)
    .chainAnimation(true)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .onScrollFrameBegin((offset: number) => {
      this.curOffsetRemain  += offset
      if (offset>0) {
        this.isRolling = true
      }else if(offset<0){
        this.isRolling = false
        this.curOffsetRemain = 0
      }
      console.info("offsetRemain:" + offset + '/' +this.curOffsetRemain);
      return { offsetRemain: offset }
    })
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
    .sticky(StickyStyle.Header)
    .height('100%')
    .width('100%')

  }
}

export default ProxyArrangement


