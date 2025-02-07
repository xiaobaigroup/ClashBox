import { BreakpointState } from "../../common/breakpointsystem"
import { BIND_SHEET_TITLE_CONTAINER_HEIGHT, BORDER_RADIUS_20 } from "../../common/Constants"
import { convertTime } from "../../utils/TimeConvertUtil"
import { Nothing } from "../Common"
import { MoreTop } from "./MoreTopBuilder"

// 资源数据（假设）
interface ConnectData {
  // 配置名
  connectConfigName: string
  // 代理名
  connectProxyName: string
  // 请求时间(展示的时间)
  connectTime: number
  // 请求链接
  connectUrl: string
  // 请求标识（0：直连；1：代理）
  connectSign: number
}

@Component
struct Connect {
  // 是否进入二级界面
  @Consume isSecondary: boolean
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')

  // 临时数据
  @State
  private connectListData: Array<ConnectData> = [
    {
      connectConfigName: '',
      connectProxyName: '',
      connectTime: 1736590325781,
      connectUrl: 'tcp://upadte.huawei.com:443',
      connectSign: 0
    },
    {
      connectConfigName: '配置1',
      connectProxyName: '中国香港①',
      connectTime: 1736996575781,
      connectUrl: 'tcp://google.com:443',
      connectSign: 1
    },
    {
      connectConfigName: '配置名',
      connectProxyName: '代理名',
      connectTime: 1749990425781,
      connectUrl: '链接',
      connectSign: 1
    },
  ]
  @Builder
  connectOther() {
    // 清理按钮
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph($r('sys.symbol.clean_fill'))
        .fontSize(24)
        .fontColor([this.icon_primary])
    }
    .width(40)
    .height(40)
    .margin({ left: 10 })
    .backgroundColor($r('app.color.settings_container_background'))
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          MoreTop({
            title: $r('app.string.Connect'),
            otherButton: (): void => { this.connectOther() }
          })
        }.width('100%')
        // 页面
        if(this.connectListData.length === 0) {
          Nothing({ name: $r('app.string.Request') })
        } else {
          List({ space: 10 }) {
            ForEach(this.connectListData, (item: ConnectData, index: number) => {
              ListItem() {
                Row() {
                  // 文本显示区
                  Column() {
                    Text(item.connectUrl)
                      .fontWeight(FontWeight.Bold)
                      .margin({ bottom: 2 })
                      .fontSize(17)
                    Row({ space: 2 }) {
                      Text(item.connectSign === 0 ? $r('app.string.Direct') : item.connectConfigName)
                        .smallText()
                      Text('·')
                        .smallText()
                      if(item.connectSign === 1) {
                        Text(item.connectProxyName)
                          .smallText()
                        Text('·')
                          .smallText()
                      }
                      Text(convertTime(item.connectTime))
                        .smallText()
                    }.justifyContent(FlexAlign.Start)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  Blank()
                  Button({ type: ButtonType.Circle, stateEffect: true }) {
                    SymbolGlyph($r('sys.symbol.nosign'))
                      .fontSize(24)
                      .fontColor([this.icon_primary])
                  }.width(40)
                  .height(40)
                  .clickEffect({ level: ClickEffectLevel.LIGHT })
                  .backgroundColor($r('app.color.settings_container_background'))
                }.width('100%')
                .padding(12)
                .justifyContent(FlexAlign.Center)
                .width('100%')
                .backgroundColor($r('app.color.container_background'))
                .borderRadius(BORDER_RADIUS_20)
              }.width('100%')
            })
          }.width('100%')
          .height('100%')

        }

      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .padding({right: this.morePageMargin.value, left: this.morePageMargin.value})
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