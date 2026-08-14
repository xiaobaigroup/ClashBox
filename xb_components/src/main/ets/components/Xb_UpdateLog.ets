import { PageMargin } from "../utils/breakpoint/BreakPoint"
import { Xb_AnimationStyle } from "../utils/Animation"
import { colorChange } from "./Common"
import { Xb_TopTitleBar } from "./Xb_TopTitleBar"


@ComponentV2
export struct Xb_UpdateLog {
  // 标题相关
  @Param needTopTitle: boolean = true  // V1传参V2失败时可自定义标题
  @Param isBackPress: boolean = false
  @Param isShowClose: boolean = true
  @Param marginTitleTop: Length = 0
  @Param marginTitle: Length = 0
  @Param iconSize: number = 24

  @Param alignRow: VerticalAlign = VerticalAlign.Center
  @Param backPressColor: ResourceColor = colorChange.color1

  @Param listItemGroupBgColor?: ResourceColor = undefined
  @Param pageInfos: NavPathStack = new NavPathStack()
  @Param appNameImage?: Resource = undefined
  @Param logoImageBg?: Resource = undefined
  @Param logoImage?: Resource = undefined

  @Param versionName: ResourceStr = ''
  @Param appName: ResourceStr = ''

  @Param scrollBarState: BarState = BarState.Auto
  @Param showBackButton: boolean = false
  @Param isShowAnimation: boolean = true
  @Param isNameText: boolean = false
  @Param updateLog: TCItemProp[] = []
  @Param animationSpeed: number = 300

  // 宽度断点
  @Param widthBp: WidthBreakpoint = 1
  // 高度断点
  @Param heightBp: HeightBreakpoint = 0

  @Local showGroup: boolean = true
  @Local currentGroup: ResourceStr = ''


  @Event closeUse: () => void = () => {}

  build() {
    NavDestination() {
      if (this.needTopTitle) {
        Xb_TopTitleBar({
          name: $r('app.string.update_log'),
          icon2: this.isShowClose ? $r("sys.symbol.xmark") : undefined,
          fontSize: 20,
          paddingValue: 16,
          heightTotal: 56,
          iconSize: this.iconSize,
          alignRow: this.alignRow,
          isBackPress: this.isBackPress,
          buttonColor: this.backPressColor,
          animationUse: false,
          onClickIcon: (i) => {
            if (i === 1) {
              this.closeUse()
              this.pageInfos.clear()
            } else if (i === 2) {
              this.pageInfos.pop()
            }
          }
        }).margin({top: this.marginTitleTop, bottom: this.marginTitle})
      }

      List({space: 10}) {
        // Logo & 名称
        ListItem() {
          Column({space: 15}) {
            // logo
            Stack() {
              Image(this.logoImage)
                .borderRadius(25)
                .height(106)
                .zIndex(1)
              Image(this.logoImageBg)
                .height(106)
                .zIndex(2)
            }
            // 名称
            if (!this.isNameText){
              Image(this.appNameImage)
                .width(192)
            }else {
              Text(this.appName)
                .fontSize(30).fontWeight(FontWeight.Bold)
            }

            Text() {
              Span($r('app.string.current_version'))
              Span('：')
              Span(this.versionName)
            }
            .fontSize(15)
            .fontWeight(FontWeight.Normal)
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .width('100%')
          .borderRadius(20)
          .height(220)
        }
        // 更新日志
        ForEach(this.updateLog, (item: TCItemProp, i: number) => {
          ListItemGroup({
            header: this.itemHead(item.title, ((this.showGroup && this.currentGroup === item.title) ? $r('sys.symbol.chevron_down') : $r('sys.symbol.chevron_right')))
          })
          {
            if (this.showGroup && this.currentGroup === item.title) {
              ListItem() {
                // 内容
                Text(item.content)
                  .fontSize(15)
                  .margin({top: 2})
                  .fontWeight(FontWeight.Normal)
                  .textAlign(TextAlign.Start)
              }
              .align(Alignment.Start)
              .width('100%')
              .padding({ left: 10, right: 10 })
              .transition(Xb_AnimationStyle.isScaleTransY(i))
            }
          }
          .padding(10)
          .width('100%')
          .borderRadius(20)
          .backgroundColor(this.listItemGroupBgColor)
          .clickEffect(this.isShowAnimation ? Xb_AnimationStyle.isClick() : null)
          .onClick(() => {
            this.getUIContext().animateTo({
              duration: this.animationSpeed,
            },() => {
              this.currentGroup = item.title
              this.showGroup = !this.showGroup
            })
          })
        })
      }
      .width('100%')
      .scrollBar(this.scrollBarState)
      .alignListItem(ListItemAlign.Center)
      .contentEndOffset(86)
      .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .hideBackButton(true)
    .hideToolBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      if (this.needTopTitle) {
        this.pageInfos.pop()
      }
      return true
    })
  }

  @Builder
  itemHead(text: ResourceStr, icon: Resource) {
    Row() {
      Text(text)
        .maxLines(1)
        .fontSize(17)
        .fontColor($r('sys.color.font_primary'))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      SymbolGlyph(icon)
        .fontSize(25).fontColor([$r('sys.color.icon_primary')])
    }
    .height(36)
    .width('100%')
    .borderRadius(20)
    .padding({ left: 10, right: 10 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  aboutToAppear(): void {
    this.currentGroup = this.updateLog[0].title
  }

}

/**
 * 标题&内容
 */
export interface TCItemProp {
  title: ResourceStr
  content: ResourceStr
}

