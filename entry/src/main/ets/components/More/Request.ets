import { BreakpointState } from "../../common/breakpointsystem"
import { BORDER_RADIUS_20, CONTENT_END_OFFSET_150, TAB_CONTENT_TITLE_HEIGHT } from "../../common/Constants"
import { MoreTop } from "./MoreTopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { convertTime, timestampToDateTime } from "../../utils/TimeConvertUtil"
import { Nothing } from "../Common"
import { UIConfig } from "../../entryability/AppState"
import { curves } from "@kit.ArkUI"
import { customAnimationUtil } from "../../utils/Animation"
import ClashViewModel from "../../entryability/ClashViewModel"
import { ConnectionInfo } from "proxy_core"
import { getRequestText, getSourceText, getTheSourceText } from "./Connect"

// 资源数据（假设）
interface RequestData {
  // 配置名
  requestConfigName: string
  // 代理名
  requestProxyName: string
  // 请求时间(展示的时间)
  requestTime: number
  // 请求链接
  requestUrl: string
  // 请求标识（0：直连；1：代理）
  requestSign: number
}

@Component
struct RequestPage {
  @Consume isSecondary: boolean
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  //page内顶部标题偏移量
  @Consume curYOffset: number
  // 临时数据
  @State
  private requestListData: ConnectionInfo[] = [
  ]
  async aboutToAppear(): Promise<void> {
      // TODO  ClashViewModel.clearRequestList()
      this.requestListData = await ClashViewModel.getRequestList()
  }
  @Builder
  requestOther() {
  }

  build() {
    NavDestination() {
      Stack() {
        // 标题栏
          MoreTop({
            title: $r('app.string.Request'),
            otherButton: (): void => {
              this.requestOther()
            }
          })

        Column() {
          Blank().height(TAB_CONTENT_TITLE_HEIGHT+6)
          // 页面
          if (this.requestListData.length === 0) {
            Nothing({ name: $r('app.string.Request') })
          } else {
            Scroll() {
              List({ space: 10 }) {
                ForEach(this.requestListData, (item: ConnectionInfo, index: number) => {
                  ListItem() {
                    Row() {
                      Column() {
                        Text(getRequestText(item.metadata))
                          .fontWeight(FontWeight.Bold)
                          .margin({ bottom: 2 })
                          .fontSize(17)
                        Flex({
                          alignContent: FlexAlign.Start,
                          direction: FlexDirection.Row,
                          wrap: FlexWrap.Wrap,
                        }) {
                          ForEach(item.chains, (c: string) => {
                            Text(c)
                              .smallText()
                          })
                          Text(getTheSourceText(item).toString())
                            .smallText()
                          Text('·')
                            .smallText()
                          Text(timestampToDateTime(getSourceText(item)))
                            .smallText()
                        }
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)

                      Blank()
                    }
                    .width('100%')
                    .padding(12)
                    .justifyContent(FlexAlign.Center)
                    .width('100%')
                    .backgroundColor($r('app.color.container_background'))
                    .borderRadius(BORDER_RADIUS_20)
                  }.width('100%')
                  .transition(customAnimationUtil.isScaleTran(index, this.uiConfig))
                })
              }.width('100%')
              .height('100%')
              .contentEndOffset(CONTENT_END_OFFSET_150)
              .padding({ right: this.morePageMargin.value, left: this.morePageMargin.value })
              .chainAnimation(true)
              .nestedScroll({
                scrollForward: NestedScrollMode.PARENT_FIRST,
                scrollBackward: NestedScrollMode.SELF_FIRST
              })
            }
            .edgeEffect(this.uiConfig.isAnimation?EdgeEffect.Spring:null)//,{alwaysEnabled:true})
            .onDidScroll((xOffset: number, yOffset: number): void => {
              // 累计计算当前父组件滚动在Y轴方向的偏移量
              if (this.uiConfig.isAnimation){
                this.curYOffset += yOffset
              }
              console.info("yOffset" + this.curYOffset);
            })
          }
        }
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.pageInfos.clear()
      this.isSecondary = false
      return true;
    })
  }
}

export default RequestPage

@Extend(Text)
function smallText() {
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .fontWeight(FontWeight.Normal)
  .fontSize(15)
  .maxLines(1)
}
