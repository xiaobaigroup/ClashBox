import {  BreakpointState } from '../../common/breakpoint/breakpointsystem'
import { CardTitle } from './CardTitleBuilder'
import { ProxyItem, ProxyData  } from '../../common/datasources/ProxyData'
import { AppConfig } from '../../entryability/AppState'
import ClashViewModel from '../../entryability/ClashViewModel'
import { delayText } from '../Proxy/ProxyNodeItem'
import { HomeCardPadding, HomeCardPartSmFontSize, HomeCardProxyFontSize } from '../../common/breakpoint/BreakPoint'
import { font_primary } from '../Common/Common'


@Component
struct CurrentNode {

  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()

  build() {
    Column() {
      CardTitle({title: $r('app.string.CurrentNode')})
      Column() {
        if (this.appConfig.currentProxyItem) {
          Text(`${this.appConfig.currentProxyName}`)
            .fontSize(HomeCardProxyFontSize(this.widthBp, this.heightBp))
            .fontWeight(FontWeight.Bold)
            .fontColor(font_primary)
            .maxLines(2)

          Text('ping ' + `${delayText(ClashViewModel.delayMap.get(this.appConfig.currentProxyItem.name)?.delay ?? 0)}`)
            .fontSize(HomeCardPartSmFontSize(this.widthBp, this.heightBp))
            .fontColor(ProxyData.getColorForLatency(ClashViewModel.delayMap.get(this.appConfig.currentProxyItem.name)?.delay ?? 0))
        } else {
          Text($r('app.string.proxy_name'))
            .fontSize(HomeCardProxyFontSize(this.widthBp, this.heightBp))
            .fontWeight(FontWeight.Bold)
            .fontColor(font_primary)

          Row(){
            Text('ping ')
              .fontSize(HomeCardPartSmFontSize(this.widthBp, this.heightBp))
              .fontColor('#64BB5C')
            Text($r('app.string.Delay'))
              .fontSize(HomeCardPartSmFontSize(this.widthBp, this.heightBp))
              .fontColor('#64BB5C')
          }
        }
      }
      .flexGrow(1)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)
    }
    .padding(HomeCardPadding(this.widthBp, this.heightBp))
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .id('CurrentNodeId')
  }
}
export default CurrentNode