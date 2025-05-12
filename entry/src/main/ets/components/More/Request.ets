import { BreakpointState } from "../../common/breakpointsystem"
import { BORDER_RADIUS_20, CONTENT_END_OFFSET_150, TAB_CONTENT_TITLE_HEIGHT } from "../../common/Constants"
import { MoreTop } from "./MoreTopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { convertTime, timestampToDateTime } from "../../utils/TimeConvertUtil"
import { Nothing } from "../Common"
import { AppConfig, UIConfig } from "../../entryability/AppState"
import { curves } from "@kit.ArkUI"
import { customAnimationUtil } from "../../utils/Animation"
import ClashViewModel from "../../entryability/ClashViewModel"
import { ConnectionInfo } from "proxy_core"
import { getRequestText, getSourceText, getTheSourceText } from "./Connect"
import { ConnectItemDataSource } from "../../common/ConnectData"


@Component
struct RequestPage {
  @Consume isSecondary: boolean
  @State intervalId: number = 0
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  // page内顶部标题偏移量
  @Consume curYOffset: number
  // 列表数据
  @State private requestListData: ConnectItemDataSource = new ConnectItemDataSource()
  @Consume needSearch: boolean
  @Consume @Watch('RequestList') isSearching: boolean
  @Consume @Watch('searchRequest') searchText: string

  async aboutToAppear(): Promise<void> {
    this.requestListData.empty()
    if (this.appConfig.enableRequest) {
      this.getRequest()
      this.intervalId = setInterval(() => {
        this.getRequest()
      }, 9000)
    }
  }

  aboutToDisappear(): void {
    clearInterval(this.intervalId)
    this.requestListData.empty()
  }

  RequestList() {
    if (this.isSearching) {
      // 暂停计时任务
      clearInterval(this.intervalId)
    } else {
      // 如果不在搜索，还原请求列表并恢复计时任务
      this.requestListData.restoreData()
      this.intervalId = setInterval(() => {
        this.getRequest()
      }, 9000)
    }
  }

  // 请求搜索
  searchRequest(keyword: string) {
    hilog.info(0xFF00, 'Request', `#smartsearchRequest 搜索文本：${this.searchText}`)
    keyword = this.searchText
    if (keyword !== '') {
      hilog.info(0xFF00, 'Request', `#smartsearchRequest 开始搜索，搜索文本：${this.searchText}`)
      // 搜索
      this.requestListData.searchData(keyword)
    } else {
      hilog.info(0xFF00, 'Request', `#smartsearchRequest 空搜索文本：${this.searchText}`)
      // 空文本还原请求列表并恢复计时任务
      this.requestListData.restoreData()
      this.intervalId = setInterval(() => {
        this.getRequest()
      }, 9000)
    }
  }

  async getRequest() {
    // TODO  ClashViewModel.clearRequestList()
    let requestLatestListData = await ClashViewModel.getRequestList()

    // 合并后去重
    const merged = [...requestLatestListData, ...this.requestListData.getTotslData()]
    const uniqueMap = new Map<string, ConnectionInfo>()
    merged.forEach(item => {
      uniqueMap.set(`${item.id}${item.start}`, item)
    })

    // 转换为数组并按时间排序
    const RequestListData = Array.from(uniqueMap.values()).reverse()
    this.requestListData.pushData(RequestListData)
  }

  @Builder
  requestOther() {
    // 启用按钮
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph(!this.appConfig.enableRequest ? $r('sys.symbol.checkmark_circle') : $r('sys.symbol.checkmark_circle_fill'))
        .fontSize(24)
        .fontColor([this.icon_primary])
    }.onClick(() => {
      animateTo({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear }, () => {
        this.appConfig.enableRequest = !this.appConfig.enableRequest
        // this.needSearch = this.appConfig.enableRequest
        if (!this.appConfig.enableRequest) {
          clearInterval(this.intervalId)
          this.requestListData.clear()
        } else {
          this.getRequest()
          this.intervalId = setInterval(() => {
            this.getRequest()
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
          Blank().height(TAB_CONTENT_TITLE_HEIGHT + 6)
          // 页面
         if (!this.appConfig.enableRequest) {
            Nothing({
              name: $r('app.string.Request'),
              isNotEnabled: true
            })
          } else  if (this.requestListData.totalCount() === 0) {
           Nothing({ name: $r('app.string.Request') })
         } else {
            Scroll() {
              List({ space: 10 }) {
                LazyForEach(this.requestListData, (item: ConnectionInfo, index: number) => {
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
                  .transition(customAnimationUtil.isScaleTranFast(index, this.uiConfig))
                })
              }.width('100%')
              .height('100%')
              .cachedCount(5, true)
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
    .onShown(() => {
      // 初始化搜索按钮
      // this.needSearch = this.appConfig.enableRequest
      this.needSearch = false
    })
    .onWillHide(() => {
      this.needSearch = false
      this.isSearching = false
    })
    .onBackPressed(() => {
      if(this.isSearching) {
        this.isSearching = false
        this.searchText = ''
        return true
      }
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
