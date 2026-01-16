import { BIND_SHEET_DRAG_BAR_HEIGHT, BIND_SHEET_TITLE_CONTAINER_HEIGHT } from '../../common/entity/Constants'
import { UIConfig } from '../../entryability/AppState'
import { customAnimationUtil } from '../../common/utils/Animation'
import { icon_primary } from '../Common/Common'

@Preview
@Component
struct TopBuilder {

  @State title: ResourceStr = '设置'
  @State subtitle: ResourceStr = ''
  @State showBackButton: boolean = true
  // 窗口模式区分，true为窗口式，false为普通式
  @StorageProp('WindowMode') windowMode: boolean = false
  /** 由调用方传入，支持不同路由栈的复用 */
  @Link pathStack: NavPathStack
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  /** 可选的额外 Builder，用于在标题右侧绘制自定义内容 */
  @BuilderParam extraBuilder?: () => void

  build() {
    Row() {
      if (this.showBackButton) {
        // 返回图标
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(28)
            .fontColor([icon_primary])
        }
        .width(40).height(40)
        .margin({left: 16, top: BIND_SHEET_DRAG_BAR_HEIGHT })
        .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
        .backgroundColor(this.windowMode ? Color.Transparent : $r('app.color.back'))
        .onClick(() => {
          this.pathStack.pop(true)
        })
      }
      Column() {
        Row() {
          Text(this.title)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
          // 渲染额外的 Builder（如状态指示器）
          if (this.extraBuilder) {
            this.extraBuilder()
          }
        }
        .alignItems(VerticalAlign.Center)
        .margin(this.showBackButton ? {left: 8, top: 21 } : {left: 16, top: 21 })

        if (this.subtitle) {
          Text(this.subtitle)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .fontSize(12)
            .fontWeight(FontWeight.Normal)
            .margin(this.showBackButton ? {left: 8, top: 2 } : {left: 16, top: 2})
        }
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
      .height(BIND_SHEET_TITLE_CONTAINER_HEIGHT)
      Blank()
    }
    .margin({bottom: 8})
    .alignItems(VerticalAlign.Top)
    .width('100%')
    .height(BIND_SHEET_TITLE_CONTAINER_HEIGHT)
  }
}

export default  TopBuilder