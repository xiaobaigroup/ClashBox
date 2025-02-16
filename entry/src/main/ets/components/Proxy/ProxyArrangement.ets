import { BORDER_RADIUS_20, CONTENT_END_OFFSET_150, FONT_SIZE_16, LIST_ITEM_HEIGHT} from '../../common/Constants'
import { BreakpointState, BreakpointSystem } from '../../common/breakpointsystem'
import { hilog } from "@kit.PerformanceAnalysisKit"
import ProxyGroupItem from './ProxyGroupItem'
import { Profile, ProxyGroup,ProxyType } from 'proxy_core'
import { ProxyItem, ProxyGroupItemDataSource, ProxyItemDataSource } from '../../common/ProxyData'
import ClashViewModel from '../../entryability/ClashViewModel'
import { AppConfig, UIConfig } from '../../entryability/AppState'
import { customAnimationUtil } from '../../utils/Animation'

/**
 * 列表排列
 */
@Component
struct ProxyArrangement {
  //page内顶部标题偏移量
  @Consume curYOffset: number
  @State selectItem: number = 0
  @State currentIndex: number =0
  // 代理原始数据
  @Consume theProxyGroups: ProxyGroup[]
  @Consume proxyGroups: ProxyGroupItemDataSource
  private componentName: string = 'ProxyPage'
  @State isContentShow: boolean |undefined = false
  @Consume('currentProfile') private currentProfile: Profile
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  /* 断点布局相关 */
  @Consume private breakPointStateTabContentTitleMargin: BreakpointState<number>
  @StorageLink('favoriteProxys') favoriteProxys: Map<string, string> = new Map<string, string>([])

  aboutToAppear(): void {
    hilog.info(0xB000, this.componentName, `#aboutToAppear`)
    BreakpointSystem.getInstance().start()

    if (this.currentProfile){
      let listIndexes = this.theProxyGroups.findIndex((d)=>d.name == this.currentProfile?.currentGroupName)
      setTimeout(() => {
        if(listIndexes > -1){
          this.currentIndex = listIndexes
        }
      }, 200)
    }
    if(this.currentProfile && this.currentProfile?.proxySelected){
      console.log("proxySelected",this.currentProfile?.proxySelected.size)
      for(let d of this.currentProfile.proxySelected?.entries()){
        console.log("proxySelected",d[0],d[1])
      }
    }
  }

  changeProxy(g: string, item: ProxyItem){
    if(this.currentProfile){
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
    List({ space: 10, initialIndex: 0, scroller: this.proxyScroller}) {
      LazyForEach(this.proxyGroups, (group: ProxyGroup, index: number) => {
        ListItemGroup({
          header: this.itemHead(group.name, !this.isContentShow && this.selectItem === index
            ? $r('sys.symbol.chevron_down') : $r('sys.symbol.chevron_right'))
        }){
          // 展开后内容显示区域
          if (!this.isContentShow && this.selectItem === index) {
            ProxyGroupItem({
              proxyitems: group.proxies as ProxyItem[],
              ProxyGroupItemSelected: this.appConfig.proxyCardSize,
              disabled: group.type !== ProxyType.Selector,
              selectedProxy: this.currentProfile.getSelectedProxy(group),
              OnProxyChange: (item) => {
                this.changeProxy(group.name, item)
              }
            })
              .borderRadius(BORDER_RADIUS_20)
              .width('100%')
              .padding({ top:10, bottom: 10 })
          }
        }
        .padding({
          left: this.breakPointStateTabContentTitleMargin.value,
          right: this.breakPointStateTabContentTitleMargin.value,
        })
        .clickEffect(this.isContentShow?customAnimationUtil.isClickEffect(this.uiConfig):null)
        .transition(customAnimationUtil.isScaleTran(index, this.uiConfig))
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
      }, (item: ProxyGroup) => item.name)
    }
    .cachedCount(5)
    .chainAnimation(true)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .contentEndOffset(CONTENT_END_OFFSET_150)
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


