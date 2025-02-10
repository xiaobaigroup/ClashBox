import { BreakpointState } from "../../common/breakpointsystem"
import { BIND_SHEET_TITLE_CONTAINER_HEIGHT, BORDER_RADIUS_20, CONTENT_END_OFFSET_110 } from "../../common/Constants"
import { UIConfig } from "../../entryability/AppState"
import { convertTime } from "../../utils/TimeConvertUtil"
import { Nothing } from "../Common"
import { MoreTop } from "./MoreTopBuilder"
import { curves, LengthMetrics } from "@kit.ArkUI"
import ClashViewModel from "../../entryability/ClashViewModel"
import { ConnectionInfo, Metadata } from "proxy_core"
import { customAnimationUtil } from "../../utils/Animation"

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
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')

  // 数据
  @State
  private connectListData: Array<ConnectionInfo> = [
  ]
  async aboutToAppear(): Promise<void> {
    let result = await ClashViewModel.getConnections()
    this.connectListData = result
    console.log("getConnections", JSON.stringify(result) )
  }
  @Builder
  connectOther() {
    // 清理按钮
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph($r('sys.symbol.clean_fill'))
        .fontSize(24)
        .fontColor([this.icon_primary])
    }.onClick(()=>{
      this.connectListData = []
      ClashViewModel.clearConnections()
    })
    .width(40)
    .height(40)
    .margin({ left: 10 })
    .backgroundColor($r('app.color.settings_container_background'))
  }
  async getPackageIcon(connection: ConnectionInfo)  {
    return connection.metadata.process;
  }
  getRequestText(metadata: Metadata ) {
    let text = `${metadata.network}://`;
      const ips = [
        metadata.host,
        metadata.destinationIP,
      ].filter((ip: string) => ip && ip !== "");
      text += ips.join("/");
      text += `:${metadata.destinationPort}`;
      return text;
  }
  getSourceText( connection: ConnectionInfo) {
      const  metadata = connection.metadata;
      if (metadata.process != "") {
        return connection.start;
      }
    return `${metadata.process} · ${connection.start}`;
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
        .transition(customAnimationUtil.isSlide(200,this.uiConfig))
        .padding({right: this.morePageMargin.value, left: this.morePageMargin.value})
        // 页面
        if(this.connectListData.length === 0) {
          Nothing({ name: $r('app.string.Request') })
        } else {
          List({ space: 10 }) {
            ForEach(this.connectListData, (item: ConnectionInfo, index: number) => {
              ListItem() {
                Row() {
                  // 文本显示区
                  Column() {
                    Text(this.getRequestText(item.metadata))
                      .fontWeight(FontWeight.Bold)
                      .margin({ bottom: 2 })
                      .fontSize(17)
                    Flex({
                      alignContent: FlexAlign.Start,
                      direction: FlexDirection.Row,
                      wrap: FlexWrap.Wrap,
                      space: {main: LengthMetrics.vp(2), cross: LengthMetrics.vp(2)}
                    }) {
                      ForEach(item.chains, (c: string)=>{
                        Text(c)
                        .smallText()
                      })
                      Text(convertTime(this.getSourceText(item)))
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
                  }.width(40)
                  .height(40)
                  .clickEffect(this.uiConfig.isAnimation ? { level: ClickEffectLevel.MIDDLE, scale: 0.8} : null)
                  .backgroundColor($r('app.color.settings_container_background')).onClick(()=>{
                      this.connectListData.splice(index,1)
                      ClashViewModel.closeConnection(item.id)
                  })
                }.width('100%')
                .padding(12)
                .justifyContent(FlexAlign.Center)
                .width('100%')
                .backgroundColor($r('app.color.container_background'))
                .borderRadius(BORDER_RADIUS_20)
              }.width('100%')
              .transition(customAnimationUtil.isScaleTran(index,this.uiConfig))
            })
          }.width('100%')
          .height('100%')
          .padding({right: this.morePageMargin.value, left: this.morePageMargin.value})
          .contentEndOffset(CONTENT_END_OFFSET_110)
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)

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