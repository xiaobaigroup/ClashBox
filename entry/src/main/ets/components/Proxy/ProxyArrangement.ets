import { BORDER_RADIUS_20, CONTENT_END_OFFSET_110, FONT_SIZE_16, LIST_ITEM_HEIGHT} from '../../common/Constants'
import { BreakpointState, BreakpointSystem } from '../../common/breakpointsystem'
import { hilog } from "@kit.PerformanceAnalysisKit"
import ProxyGroupItem from './ProxyGroupItem'
import { Profile, ProxyGroup,ProxyType } from 'proxy_core'
import { ProxyItem } from '../../common/ProxyData'
import ClashViewModel from '../../entryability/ClashViewModel'
import { AppConfig, UIConfig } from '../../entryability/AppState'
import { customAnimationUtil } from '../../utils/Animation'



@Entry
@Component
struct ProxyArrangement {
  @State isContentShow: boolean |undefined = false;
  @State selectItem: number = 0;
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')
  private isLandscapePhone: boolean = false
  /* 断点布局相关 */
  @Consume
  private breakPointStateTabContentTitleMargin: BreakpointState<number>
  private componentName: string = 'ProxyPage'
  @Consume('currentProfile')
  private currentProfile: Profile | null
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('favoriteProxys') favoriteProxys: Map<string, string> = new Map<string, string>([])
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  aboutToAppear(): void {
    hilog.info(0xB000, this.componentName, `#aboutToAppear`)
    BreakpointSystem.getInstance().start()

    if (this.currentProfile){
      let listIndexes = this.proxyGroups.findIndex((d)=>d.name == this.currentProfile?.currentGroupName)
      setTimeout(() => {
        if(listIndexes > -1){
      //    this.listController.changeIndex(listIndexes)
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

 @State currentIndex: number =0
  @Consume
  proxyGroups: ProxyGroup[]

  changeProxy(g: string, item: ProxyItem){
    if(this.currentProfile){
      ClashViewModel.changeProxy(this.currentProfile, g, item.name)
    }
  }

  //分组标签
  @Builder
  itemHead(text: string,icon:Resource) {
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
    Column() {
      List({ space: 10, initialIndex: 0,scroller:this.proxyScroller}) {
        ForEach(this.proxyGroups, (g:ProxyGroup, i: number) => {
          ListItemGroup({ header: this.itemHead(g.name,
            !this.isContentShow && this.selectItem === i ? $r('sys.symbol.chevron_down')
              : $r('sys.symbol.chevron_right'))} ){

              //展开后内容显示区域
              if (!this.isContentShow && this.selectItem === i) {
                ProxyGroupItem({
                  items: g.proxies as ProxyItem[],
                  ProxyGroupItemSelected: this.appConfig.proxyCardSize,
                  disabled: g.type !== ProxyType.Selector,
                  selectedProxy: this.currentProfile?.getSelectedProxy(g),
                  OnProxyChange: (item) => {
                    this.changeProxy(g.name, item)
                  }
                })
                  .borderRadius(BORDER_RADIUS_20)
                  .width('100%')
               //   .height(500) //展开后界面高度
                  .padding({ top:10, bottom: 10 })
              }
          }
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .transition(customAnimationUtil.isScaleTran(i,this.uiConfig))
          .onClick(() => {
            animateTo({
              duration: this.uiConfig.animationSpeed,
              onFinish: () => {
              }
            }, () => {
              if (!this.isContentShow) {
                this.proxyScroller.scrollToItemInGroup(i,0,true,ScrollAlign.START)
              }
              this.isContentShow=!this.isContentShow
              this.selectItem = i;
            })
          })
          .width('100%')
          .borderRadius(BORDER_RADIUS_20)
        })
      }
      .chainAnimation(true)
      .borderRadius(BORDER_RADIUS_20)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .contentEndOffset(CONTENT_END_OFFSET_110)
      //.height('100%')
    //  .width('100%')
      .sticky(StickyStyle.Header)
    }
    .height('100%')
    .width('100%')
    .padding({
      left: this.breakPointStateTabContentTitleMargin.value,
      right: this.breakPointStateTabContentTitleMargin.value,
    })
    .backgroundColor($r('app.color.background'))
    }
}

export default ProxyArrangement


