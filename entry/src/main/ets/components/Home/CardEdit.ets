import { curves, LengthMetrics } from "@kit.ArkUI"
import { BreakpointState } from "../../common/breakpoint/breakpointsystem"
import { HomeCardItem, HomeCardList, HomeCards } from "../../common/entity/Constants"
import { AppConfig, UIConfig } from "../../entryability/AppState"
import { customAnimationUtil } from "../../common/utils/Animation"
import { TabContentTitleMargin } from "../../common/breakpoint/BreakPoint"
import { Xb_ToastUtil } from "xb_components"
import { HomeCardInfo } from "../../common/entity/PageArgumentEntity"
import { Xb_AnimationStyle } from "xb_components"


@Component
export struct CardEdit {

  // 当前主页布局
  @Consume theCurrentHomeCard: string[]
  @Consume homeCardList: HomeCardInfo[]
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1

  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  @Builder CardImage(s: Resource, a: number, i: number,w: ResourceStr, key: string){
    Image(s)
      .width(w)
      .aspectRatio(a)
      .height(160)
      .ImageItemStyle()
      .transition(customAnimationUtil.isScaleTran(i, this.uiConfig))
      .onClick(() => {
        Xb_AnimationStyle.animToAPI18(() => {
          const index = HomeCards.findIndex(value => key == value.key)
          const data = HomeCards[index]
          this.homeCardList.push(data)
          this.theCurrentHomeCard.push(key)
        }, this.uiConfig.animationSpeed, 'app', 0, curves.springMotion())
      })
  }

  build() {
    Flex({
      wrap: FlexWrap.Wrap,
      justifyContent: FlexAlign.SpaceBetween,
      space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) } }) // 子组件多行布局
    {
      ForEach(HomeCardList.filter(value => !this.theCurrentHomeCard.includes(value.key)), (item: HomeCardItem, i: number)=> {
        this.CardImage(item.image, item.aspectRatio, i, item.width, item.key)
      })
    }
    .width('100%')
    .padding({
      left: TabContentTitleMargin(this.widthBp, this.heightBp),
      right: TabContentTitleMargin(this.widthBp, this.heightBp),
      bottom: 30 })
  }

}

@Extend(Image)
function ImageItemStyle() {
  .borderRadius(20)
  .backgroundColor($r('app.color.container_background'))
}

