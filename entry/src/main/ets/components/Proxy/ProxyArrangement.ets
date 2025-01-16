import { ANIMATION_DURATION_300, LIST_ITEM_HEIGHT,
} from '../../common/Constants'
import { BreakpointState, BreakpointSystem } from '../../common/breakpointsystem'
import { hilog } from "@kit.PerformanceAnalysisKit"
import ProxyGroupItem from './ProxyGroupItem'
import { Profile, ProxyGroup,ProxyType } from 'proxy_core'
import { Item } from '../../common/ProxyData'
import ClashViewModel from '../../entryability/ClashViewModel'
import { AppConfig } from '../../entryability/AppState'


@Entry
@Component
struct ProxyArrangement {
  @State isContentShow: boolean = true;
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

  changeProxy(g: string, item: Item){
    if(this.currentProfile){
      ClashViewModel.changeProxy(this.currentProfile, g, item.text)
    }
  }



  build() {
    Column() {
      List({ space: 10, initialIndex: 0 }) {
        ForEach(this.proxyGroups, (g:ProxyGroup, i: number) => {
          ListItem() {
            Column() {
              Row() {
                Text(g.name).fontSize(16).fontColor($r('sys.color.font_primary')).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                SymbolGlyph(this.isContentShow && this.selectItem === i ? $r('sys.symbol.chevron_down') :
                $r('sys.symbol.chevron_right'))
                  .fontSize(25).fontColor([$r('sys.color.icon_primary')])
              }
              .onClick(() => {
                this.selectItem = i;
              })
              .borderRadius(20)
              .backgroundColor($r('app.color.container_background'))
              .padding({ left: 10, right: 10 })
              .onClick(() => {
                animateTo({
                  duration: ANIMATION_DURATION_300,
                  onFinish: () => {
                    console.info('animation end');
                  }
                }, () => {
                  this.isContentShow = !this.isContentShow;
                  this.selectItem = i;
                })
              })
              .clickEffect({ level: ClickEffectLevel.MIDDLE })
              .width('100%')
              .height(LIST_ITEM_HEIGHT)
              .justifyContent(FlexAlign.SpaceBetween)


              //展开后内容显示区域
              if (this.isContentShow && this.selectItem === i) {

                ProxyGroupItem({
                  items: g.proxies as Item[],
                  ProxyGroupItemSelected: this.appConfig.proxyCardSize,
                  disabled: g.type !== ProxyType.Selector,
                  selectedProxy: this.currentProfile?.getSelectedProxy(g),
                  OnProxyChange: (item) => {
                    this.changeProxy(g.name, item)
                  }
                })
                  .borderRadius(20)
                  .width('100%')
                  .height(500) //展开后界面高度
                  .padding({ top:10, bottom: 10 })
              }
            }
       //     .backgroundColor($r('app.color.container_background'))
            .width('100%')
          }
        })
      }
      .scrollBar(BarState.Off)
      .height('100%')
      .width('100%')
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


