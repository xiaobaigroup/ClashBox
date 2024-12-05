/*
 * More列表页
 * 2024.12.04
 *
 */
import { BreakpointState, BreakpointSystem } from '../common/breakpointsystem'
import Constants from '../common/Constants';
import { ListItemProp } from '../common/ListItemProp';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct MorePage {
  //系统颜色调用
  /*  @State icon_emphasize: ResourceColor = $r('sys.color.icon_emphasize')//高亮图标，蓝色
    @State icon_tertiary: ResourceColor = $r('sys.color.icon_tertiary')//三级图标色，浅灰色

     预留自定义主题，颜色在AppTheme里面修改
     onWillApplyTheme(theme: Theme) {
        this.backgroundPrimary = theme.colors.backgroundPrimary;
        this.fontPrimary = theme.colors.fontPrimary;
        this.iconOnPrimary = theme.colors.iconOnPrimary;
        this.iconFourth = theme.colors.iconFourth;
     }
 */
  @State moreList: ListItemProp[] = Constants.MoreList;
  @State compStr: BreakpointState<string> = BreakpointState.of({
    xs: "xs", sm: "sm", md: "md", lg: "lg", xl: "xl"
  })
  @State listMargin: BreakpointState<number> = BreakpointState.of({
    xs: 12, sm: 14, md: 28, lg: 36, xl: 36
  });

  aboutToAppear(): void {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.listMargin)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear(): void {
    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.listMargin)
    BreakpointSystem.getInstance().stop()
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.More'))
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .margin({ left: this.listMargin.value })
      }
      .width('100%')
      .margin({ bottom: 15 })

      Scroll() {
        Column() {
          ForEach(this.moreList, (item: ListItemProp) => {
            Column() {
              ForEach(item.children, (itemChild: ListItemProp) => {

                Column() {
                  Row() {
                    SymbolGlyph(itemChild.icons)
                      .fontSize(24)
                      .margin({left: 12})
                    Text(itemChild.title)
                      .height(48)
                      .fontWeight(FontWeight.Medium)
                      .padding({ left: 12 })
                      .fontSize(16)
                    Blank()
                    Row()
                      .width(10)
                      .height(10)
                      .margin({ right: 20 })
                      .border({
                        width: {
                          top: 2,
                          right: 2
                        },
                        color: '#000000'
                      })
                      .rotate({ angle: 45 })
                  }
                  .width('100%')
                  .height(53)
                  .borderRadius(20)
                  .backgroundColor('white')
                  Row()
                    .height(10)

                }
                .onClick(() => {
                  hilog.isLoggable(0xFF00, "MoretestTag", hilog.LogLevel.INFO);
                  hilog.info(0xFF00, "MoretestTag", itemChild.name)


                })

              })
            }
            .margin({
              top: 10,
              bottom: 18
            })
            .borderRadius(18)

            //.backgroundColor('gray')
          })
        }
        .padding({
          left: 16,
          right: 16
        })
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)

    }
    .width('100%')
    .height('100%')
    .padding({ bottom: '45vp' })
    .backgroundColor('#F1F3F5')
  }
}

export default MorePage