import { BreakpointState } from "../../common/breakpointsystem"
import { BORDER_RADIUS_20 } from "../../common/Constants"
import { MoreTop } from "./MoreTopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { convertTime } from "../../utils/TimeConvertUtil"
import { Nothing } from "../Common"
import { UIConfig } from "../../entryability/AppState"

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

  // 临时数据
  @State
  private requestListData: Array<RequestData> = [
    {
      requestConfigName: '',
      requestProxyName: '',
      requestTime: 1736990325781,
      requestUrl: 'tcp://upadte.huawei.com:443',
      requestSign: 0
    },
    {
      requestConfigName: '配置1',
      requestProxyName: '中国香港①',
      requestTime: 1736996575781,
      requestUrl: 'tcp://google.com:443',
      requestSign: 1
    },
    {
      requestConfigName: '配置名',
      requestProxyName: '代理名',
      requestTime: 1736990425781,
      requestUrl: '链接',
      requestSign: 1
    },
  ]
  @Builder
  requestOther() {
  }

  build() {
    NavDestination() {
      // 标题栏
      Row() {
        MoreTop({
          title: $r('app.string.Request'),
          otherButton: (): void => { this.requestOther() }
        })
      }.width('100%')
      .transition(this.uiConfig.isAnimation ? TransitionEffect.OPACITY
        .animation({ duration: this.uiConfig.animationSpeed, delay: 0 })
        .combine(TransitionEffect.SLIDE) : null)
      // 页面
      if(this.requestListData.length === 0) {
        Nothing({ name: $r('app.string.Request') })
      } else {
        List({ space: 10 }) {
          ForEach(this.requestListData, (item: RequestData, index: number) => {
            ListItem() {
              Row() {
                // 文本显示区
                Column() {
                  Text(item.requestUrl)
                    .fontWeight(FontWeight.Bold)
                    .margin({ bottom: 2 })
                    .fontSize(17)
                  Row({ space: 2 }) {
                    Text(item.requestSign === 0 ? $r('app.string.Direct') : item.requestConfigName)
                      .smallText()
                    Text('·')
                      .smallText()
                    if(item.requestSign === 1) {
                      Text(item.requestProxyName)
                        .smallText()
                      Text('·')
                        .smallText()
                    }
                    Text(convertTime(item.requestTime))
                      .smallText()
                  }.justifyContent(FlexAlign.Start)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                Blank()
              }.width('100%')
              .padding(12)
              .justifyContent(FlexAlign.Center)
              .width('100%')
              .backgroundColor($r('app.color.container_background'))
              .borderRadius(BORDER_RADIUS_20)
            }.width('100%')
            .transition(this.uiConfig.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: index*10+10 })
              .combine(TransitionEffect.scale({x: 0, y: 0})):null)
          })
        }.width('100%')
        .height('100%')

      }

    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .padding({right: this.morePageMargin.value, left: this.morePageMargin.value})
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
