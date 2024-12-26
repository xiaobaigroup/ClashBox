import { ANIMATION_DURATION_300, LIST_ITEM_HEIGHT,
} from '../../common/Constants'
import { BreakpointState, BreakpointSystem } from '../../common/breakpointsystem'
import { hilog } from "@kit.PerformanceAnalysisKit"
import ProxyGroupItem from './ProxyGroupItem'
import { StartOptions } from '@kit.AbilityKit'


@Entry
@Component
struct ProxyArrangement {
  @State font_primary: ResourceColor = $r('sys.color.font_primary') //一级文本色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  @State isContentShow: boolean = true;
  @State selectItem: number = 0;
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')
  private isLandscapePhone: boolean = false
  /* 断点布局相关 */
  @Consume
  private breakPointStateTabContentTitleMargin: BreakpointState<number>
  private componentName: string = 'ProxyPage'

  aboutToAppear(): void {
    hilog.info(0xB000, this.componentName, `#aboutToAppear`)
    BreakpointSystem.getInstance().start()
  }

  @Provide arr: string[] =
    ["分组1", "分组2", "分组3", "分组4", "分组5", "分组6"]
  @Provide listIndex: number = 0;

  build() {
    Column() {
      List({ space: 10, initialIndex: 0 }) {
        ForEach(this.arr, (item: number,) => {
          ListItem() {
            Column() {
              Row() {
                Text(item.toString()).fontSize(16).fontColor($r('sys.color.font_primary'))
                SymbolGlyph(this.isContentShow && this.selectItem === item ? $r('sys.symbol.chevron_down') :
                $r('sys.symbol.chevron_right'))
                  .fontSize(25).fontColor([this.icon_primary])
              }
              .onClick(() => {
                this.listIndex = item;
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
                  this.selectItem = item;
                })
              })
              .clickEffect({ level: ClickEffectLevel.MIDDLE })
              .width('100%')
              .height(LIST_ITEM_HEIGHT)
              .justifyContent(FlexAlign.SpaceBetween)


              //展开后内容显示区域
              if (this.isContentShow && this.selectItem === item) {

          //      Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 16, right: 16 })
                  List() {
                    ProxyGroupItem()
                  }
                  .borderRadius(20)
                  .scrollBar(BarState.Off)
                  .width('100%')
                  .height(400) //展开后界面高度
                  .padding({ top:10, bottom: 10 })
              }
            }
       //     .backgroundColor($r('app.color.container_background'))
            .width('100%')
          }
        }, (item: string) => item.toString())
      }
      .contentEndOffset(110)
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


