/**
 * 更多页顶部导航栏
 * @param title 标题文本
 * @param searchButton 搜索按钮
 * @param otherButton 其它功能按钮
 */
@Component
export struct MoreTop {
  // 是否进入二级界面
  @Consume isSecondary: boolean
  // 更多页路由表
  @Consume('NavPathStack') pageInfos: NavPathStack
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  // 标题
  @State title?: Resource = undefined
  // 元素名称标识
  @State name: string = ''
  // 副标题
  @State subtitle: ResourceStr = ''
  // 搜索按钮
  @BuilderParam searchButton: () => void = this.searchDefaultButton
  // 其它按钮
  @BuilderParam otherButton: () => void = this.otherDefaultButton

  @Builder searchDefaultButton() {
    // 默认搜索按钮
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph($r('sys.symbol.magnifyingglass'))
        .fontSize(24)
        .fontColor([this.icon_primary])
    }
    .backgroundColor($r('app.color.settings_container_background'))
    .width(40)
    .height(40)
  }
  @Builder otherDefaultButton() {
    // 默认功能按钮为更多
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
        .fontSize(24)
        .fontColor([this.icon_primary])
    }
    .width(40)
    .height(40)
    .margin({ left: 10 })
    .backgroundColor($r('app.color.settings_container_background'))
  }

  build() {
    Row() {
      // 返回图标
      Button({ type: ButtonType.Circle, stateEffect: true }) {
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(28)
          .fontColor([this.icon_primary])
      }
      .width(40)
      .height(40)
      .backgroundColor($r('app.color.settings_container_background'))
      .onClick(() => {
        this.pageInfos.pop(true)
        if (this.pageInfos.size() <= 1) {
          this.isSecondary = false
        }
      })
      Column() {
        Text(this.title)
          .fontSize(30)
          .geometryTransition(this.name)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Start)
          .margin({left: 8})
        if(this.subtitle) {
          Text(this.subtitle)
            .fontWeight(FontWeight.Normal)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({top: 2, left: 8})
            .fontSize(14)
            .maxLines(1)
        }
      }.layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Blank()
      this.searchButton()
      this.otherButton()
    }
    .zIndex(1)
    .layoutWeight(1)
    .height(56)
    .alignItems(VerticalAlign.Center)
  }
}