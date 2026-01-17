import {
  BIND_SHEET_DRAG_BAR_HEIGHT,
  BIND_SHEET_MAIN_FONT_WEIGHT,
  BIND_SHEET_MAIN_FONTSIZE,
  BIND_SHEET_SUB_FONTSIZE,
  BIND_SHEET_TITLE_CONTAINER_HEIGHT,
  LIST_SPACE
} from '../../../common/entity/Constants'
import { UIConfig } from '../../../entryability/AppState'
import { BindSheetTitleCustomBuilder, skipRowList } from '../../Common/Common'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { NavigationListPadding } from '../../../common/breakpoint/BreakPoint'

@Component
export struct AddAppListComponent {
  // 显示/隐藏添加应用弹窗
  @Link isShowSheet: boolean
  // 添加应用事件
  @Require addAppEvent: () => void = () => {
  }
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @StorageLink('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  @StorageLink('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @StorageLink('OnlineSearchPageInfos') addPageInfos: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.addPageInfos) {
      List({ space: LIST_SPACE }) {
        ListItem() {
          skipRowList({
            icons: undefined,
            title: $r('app.string.online_search'),
          })
            .onClick(() => {
              this.addPageInfos.pushDestination({
                name: 'online_app_search'
              })
                .then(() => {
                  hilog.info(0x0001, "AccessControl", 'pushDestination success')
                })
                .catch((err: ESObject) => {
                  hilog.error(0x0001, "AccessControl", 'pushDestination fail: ' + err)
                })
            })
        }

        ListItem() {
          skipRowList({
            icons: undefined,
            title: $r('app.string.add_app'),
          })
            .onClick(() => {
              this.isShowSheet = false
              this.addAppEvent()
            })
        }
        ListItem() {
          Text() {
            Span($r('app.string.tips'))
            Span(': \n')
            Span($r('app.string.online_search_tips_1'))
          }
        }.padding({ left: 5, right: 5})
      }
      .padding({
        left: NavigationListPadding(this.widthBp, this.heightBp),
        right: NavigationListPadding(this.widthBp, this.heightBp)
      })
    }
    .mode(NavigationMode.Stack)
    .hideToolBar(true)
    .width('100%')
    .height('100%')
    .title(
      {
        builder: BindSheetTitleCustomBuilder({
          pageInfos: this.addPageInfos,
          isSubPage: false,
          mainTitle: $r('app.string.add_app'),
          needSetHeight: true,
          mainTitleFontWeight: BIND_SHEET_MAIN_FONT_WEIGHT,
          mainTitleFontSize: BIND_SHEET_MAIN_FONTSIZE,
          subTitleFontSize: BIND_SHEET_SUB_FONTSIZE,
          padding: {
            left: NavigationListPadding(this.widthBp, this.heightBp),
            right: NavigationListPadding(this.widthBp, this.heightBp)
          },
          menus: []
        }),
        height: BIND_SHEET_TITLE_CONTAINER_HEIGHT + BIND_SHEET_DRAG_BAR_HEIGHT
      })
    .mode(NavigationMode.Stack)
    .hideBackButton(true)
    .navBarWidthRange([255, '100%'])
    .animation({ duration: this.uiConfig.animationSpeed, curve: Curve.Ease })
  }
}