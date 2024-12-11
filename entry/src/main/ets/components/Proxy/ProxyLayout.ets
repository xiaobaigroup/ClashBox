import { NodeParam, TreeController, TreeView } from "@kit.ArkUI"
import {
  TAB_CONTENT_TITLE_FONT_SIZE,
  TAB_CONTENT_TITLE_FONT_WEIGHT,
  BPS_LIST_LANES_1_1_2_3_4,
  BPS_LIST_GUTTER_1_1_2_3_3,
  BPS_TAB_CONTENT_TITLE_MARGIN_12_13_28_36,
  ANIMATION_DURATION_300,
  TAB_CONTENT_TITLE_HEIGHT,
  TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE,
  LIST_ITEM_HEIGHT,
} from '../../common/Constants'
import { BreakpointState, BreakpointSystem } from '../../common/breakpointsystem'
import { hilog } from "@kit.PerformanceAnalysisKit"
import ProxyGroupItem from './ProxyGroupItem'


@Entry
@Component
struct ProxyLayout {
  @State font_primary: ResourceColor = $r('sys.color.font_primary') //一级文本色，黑色
  @State comp_divider: ResourceColor = $r('sys.color.comp_divider') //分割线颜色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  @State arr: string[] =
    ["分组1", "分组2", "分组3", "分组4", "分组5", "分组6"]
  @State isContentShow: boolean = true;
  @State selectItem: number = 0;
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')
  private isLandscapePhone: boolean = false
  /* 断点布局相关 */
  @State
  private breakPointStateListLanes: BreakpointState<number> = BPS_LIST_LANES_1_1_2_3_4
  @State
  private breakPointStateListGutter: BreakpointState<number> = BPS_LIST_GUTTER_1_1_2_3_3
  @State
  private breakPointStateTabContentTitleMargin: BreakpointState<number> = BPS_TAB_CONTENT_TITLE_MARGIN_12_13_28_36
  private componentName: string = 'ProxyPage'

  aboutToAppear(): void {
    hilog.info(0xB000, this.componentName, `#aboutToAppear`)
    BreakpointSystem.getInstance().attach(this.breakPointStateListLanes)
    BreakpointSystem.getInstance().attach(this.breakPointStateListGutter)
    BreakpointSystem.getInstance().attach(this.breakPointStateTabContentTitleMargin)
    BreakpointSystem.getInstance().start()
  }

  build() {
    Column() {
      List({ space: 10, initialIndex: 0 }) {
        ForEach(this.arr, (item: number,) => {
          ListItem() {
            Column() {
              Row() {
                Text(item.toString()).fontSize(18).fontColor($r('sys.color.font_primary'))
                SymbolGlyph(this.isContentShow && this.selectItem === item ? $r('sys.symbol.chevron_down') :
                $r('sys.symbol.chevron_right'))
                  .fontSize(18).fontColor([this.icon_primary])
              }
              .padding({ left: 10, right: 10 })
              .onClick(() => {
                animateTo({
                  duration: 300,
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

                Divider().strokeWidth(1).color(this.comp_divider).padding({ left: 16, right: 16 })

                  List({ space: 10, initialIndex: 0 }) {
                    ProxyGroupItem().margin({ bottom: 10 })
                  }
                  .width('100%')
                  .height(undefined) //展开后界面高度
                  //   .padding({  bottom: 10 })
                  .divider({ strokeWidth: 1 })
              }
            }
            .borderRadius(20)
            .backgroundColor($r('app.color.container_background'))
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

export default ProxyLayout