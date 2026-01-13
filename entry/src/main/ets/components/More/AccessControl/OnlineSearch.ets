/**
 * @projectName:    clashnext
 * @fileName:      OnlineSearch
 * @author:     SummerKaze
 * @description:  在线搜索
 * @date:    2026/1/13 16:19
 * @version:    1.0
 */

import { AppInfo } from "../../../common/datasources/AccessControlRdb"
import TopBuilder from "../../Settings/TopBuilder"
import { SymbolGlyphModifier } from "@kit.ArkUI"
import { checkoutRowListItem } from "../../Common/Common"
import { CONTENT_END_OFFSET_150 } from "../../../common/entity/Constants"
import { PageMargin } from "../../../common/breakpoint/BreakPoint"
import { Xb_ImageUtils } from "xb_components"

@Builder
export function OnlineSearchBuilder(name: string, param: Object){
  OnlineSearch()
}

@Component
struct OnlineSearch {

  @StorageLink('OnlineSearchPageInfos') addPageInfos: NavPathStack = new NavPathStack()
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @State searchText: string = ''
  @State apps: AppInfo[] = []

  build() {
    NavDestination() {
      TopBuilder({
        showBackButton: true,
        title: $r('app.string.online_search'),
      })
      Column() {
        Search({ value: this.searchText, placeholder: $r('app.string.enter_search')})
          .enterKeyType(EnterKeyType.Search)
          .copyOption(CopyOptions.LocalDevice)
          .searchIcon(new SymbolGlyphModifier($r('sys.symbol.magnifyingglass')).fontColor([this.icon_emphasize]))
          .cancelButton({
            style: CancelButtonStyle.CONSTANT,
            icon: new SymbolGlyphModifier($r('sys.symbol.xmark')).fontColor([this.icon_emphasize])
          })
          .layoutWeight(1)
          .onSubmit((value: string) => {
            // 发送搜索
            this.searchText = value
          })
        List() {
          ForEach(this.apps, (app: AppInfo) => {
            ListItem() {
              checkoutRowListItem({
                icon: app.iconUintArr ? Xb_ImageUtils.uint8ArrayToPixelMap(app.iconUintArr) : $r('app.media.box_cat_round'),
                title: app.name,
                endSymbol: $r('sys.symbol.plus_circle'),
                subtitle: app.package_name,
                enabledClick: true
              })
            }
          })
        }
        .width('100%')
        .alignListItem(ListItemAlign.Center)
        .contentEndOffset(CONTENT_END_OFFSET_150 - 75)
        .padding({left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp)})
      }
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)

  }

}