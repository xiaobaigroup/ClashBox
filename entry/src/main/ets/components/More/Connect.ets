import { BreakpointState } from "../../common/breakpointsystem"
import { BIND_SHEET_TITLE_CONTAINER_HEIGHT, BORDER_RADIUS_20, CONTENT_END_OFFSET_150,
  TAB_CONTENT_TITLE_HEIGHT } from "../../common/Constants"
import { AppConfig, UIConfig } from "../../entryability/AppState"
import { convertTime, timestampToDateTime } from "../../utils/TimeConvertUtil"
import { Nothing } from "../Common"
import { MoreTop } from "./MoreTopBuilder"
import { curves, LengthMetrics } from "@kit.ArkUI"
import ClashViewModel from "../../entryability/ClashViewModel"
import { ConnectionInfo, Metadata } from "proxy_core"
import { customAnimationUtil } from "../../utils/Animation"
import { ConnectItemDataSource } from "../../common/ConnectData"


export function  getRequestText(metadata: Metadata ) {
  let text = `${metadata.network}://`;
  const ips = [
    metadata.host,
    metadata.destinationIP,
  ].filter((ip: string) => ip && ip !== "");
  text += ips.join("/");
  text += `:${metadata.destinationPort}`;
  return text;
}
export function getSourceText( connection: ConnectionInfo) {
  const  metadata = connection.metadata;
  if (metadata.process != "") {
    return connection.start;
  }
  return `${connection.start}`;
}
export function  getTheSourceText( connection: ConnectionInfo) {
  const  metadata = connection.metadata;
  if (metadata.process != "") {
    return connection.start;
  }
  return `${metadata.process}`;
}

@Component
struct Connect {
  // page内顶部标题偏移量
  @Consume curYOffset: number
  // 是否进入二级界面
  @Consume isSecondary: boolean
  @State intervalId: number = 0
  @Consume('NavPathStack') pageInfos: NavPathStack
  // 数据
  @State private connectListData: ConnectItemDataSource = new ConnectItemDataSource()
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')


  async aboutToAppear(): Promise<void> {
    this.connectListData.empty()
    if (this.appConfig.enableConnect) {
      this.getConnections()
      this.intervalId = setInterval(() => {
        this.getConnections()
      }, 9000)
    } else {
      console.log("getConnections 未启用" )
    }
  }

  aboutToDisappear(): void {
    clearInterval(this.intervalId)
    this.connectListData.empty()
  }

  async getConnections() {
    let result = await ClashViewModel.getConnections()
    console.log("#getConnections result ", JSON.stringify(result))
    // 合并后去重
    const merged = [...result, ...this.connectListData.getTotslData()]
    const uniqueMap = new Map<string, ConnectionInfo>()
    merged.forEach(item => {
      uniqueMap.set(`${item.id}${item.start}`, item)
    })

    // 转换为数组并按时间排序
    const ConnectListData = Array.from(uniqueMap.values()).sort((a, b) => {
      return new Date(b.start).getTime() - new Date(a.start).getTime()
    })
    this.connectListData.pushData(ConnectListData)
    // console.log("#getConnections result 长度", result.length)
    // console.log("#getConnections connectListData 原长度", this.connectListData.length)
    // console.log("#getConnections 合并后去重前长度", merged.length)
    // console.log("#getConnections 去重后长度", uniqueMap.size)
  }

  @Builder
  connectOther() {
    if (this.appConfig.enableConnect) {
      // 清理按钮
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        SymbolGlyph($r('sys.symbol.clean_fill'))
          .fontSize(24)
          .fontColor([this.icon_primary])
      }.onClick(()=>{
        this.connectListData.clear()
        ClashViewModel.clearConnections()
      })
      .width(40)
      .height(40)
      .margin({ left: 10 })
      .backgroundColor($r('app.color.settings_container_background'))
      .transition(customAnimationUtil.isSlide(0, this.uiConfig))
    }
    // 启用按钮
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph(!this.appConfig.enableConnect ? $r('sys.symbol.checkmark_circle') : $r('sys.symbol.checkmark_circle_fill'))
        .fontSize(24)
        .fontColor([this.icon_primary])
    }.onClick(() => {
      animateTo({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear }, () => {
        this.appConfig.enableConnect = !this.appConfig.enableConnect
        if (!this.appConfig.enableConnect) {
          clearInterval(this.intervalId)
          this.connectListData.clear()
        } else {
          this.getConnections()
          this.intervalId = setInterval(() => {
            this.getConnections()
          }, 9000)
        }
      })
    })
    .width(40)
    .height(40)
    .margin({ left: 10 })
    .backgroundColor($r('app.color.settings_container_background'))
    .transition(customAnimationUtil.isSlide(0, this.uiConfig))
  }

  async getPackageIcon(connection: ConnectionInfo)  {
    return connection.metadata.process;
  }


  build() {
    NavDestination() {
      Stack() {
          MoreTop({
            title: $r('app.string.Connect'),
            otherButton: (): void => { this.connectOther() }
          })

        Column() {
          Blank().height(TAB_CONTENT_TITLE_HEIGHT+6)
          // 页面
          if (!this.appConfig.enableConnect) {
            Nothing({
              name: $r('app.string.Connect'),
              isNotEnabled: true
            })
          } else if (this.connectListData.totalCount() === 0) {
            Nothing({ name: $r('app.string.Connect') })
          } else {
            Scroll() {
              List({ space: 10 }) {
                LazyForEach(this.connectListData, (item: ConnectionInfo, index: number) => {
                  ListItem() {
                    Row() {
                      // 文本显示区
                      Column() {
                        Text(getRequestText(item.metadata))
                          .fontWeight(FontWeight.Bold)
                          .margin({ bottom: 2 })
                          .fontSize(17)
                        Flex({
                          alignContent: FlexAlign.Start,
                          direction: FlexDirection.Row,
                          wrap: FlexWrap.Wrap,
                          space: { main: LengthMetrics.vp(2), cross: LengthMetrics.vp(2) }
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
                      Button({ type: ButtonType.Circle, stateEffect: true }) {
                        SymbolGlyph($r('sys.symbol.nosign'))
                          .fontSize(24)
                          .fontColor([this.icon_primary])
                      }
                      .width(40)
                      .height(40)
                      .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                      .backgroundColor($r('app.color.settings_container_background'))
                      .onClick(() => {
                        this.connectListData.notifyDataDelete(index)
                        ClashViewModel.closeConnection(item.id)
                      })
                    }
                    .width('100%')
                    .padding(12)
                    .justifyContent(FlexAlign.Center)
                    .width('100%')
                    .backgroundColor($r('app.color.container_background'))
                    .borderRadius(BORDER_RADIUS_20)
                  }.width('100%')
                  .transition(customAnimationUtil.isScaleTranFast(index, this.uiConfig))
                })
              }.width('100%')
              .height('100%')
              .cachedCount(5, true)
              .padding({ right: this.morePageMargin.value, left: this.morePageMargin.value })
              .contentEndOffset(CONTENT_END_OFFSET_150)
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
      .width('100%')
      .height('100%')

    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.pageInfos.clear();
      this.isSecondary = false
      return true;
    })
  }
}
export default Connect

@Extend(Text)
function smallText() {
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .fontWeight(FontWeight.Normal)
  .fontSize(15)
  .maxLines(1)
}