import { curves, LengthMetrics } from "@kit.ArkUI"
import { BreakpointState } from "../../common/breakpoint/breakpointsystem"
import { HomeCardItem, HomeCardList } from "../../common/entity/Constants"
import { AppConfig, UIConfig } from "../../entryability/AppState"
import { customAnimationUtil } from "../../common/utils/Animation"
import { TabContentTitleMargin } from "../../common/breakpoint/BreakPoint"


@Component
export struct CardEdit {
  /**
   * grid网格组件相关数据,包含scroller控制器,regularSize参数指代组件布局大小为1:1,irregularIndexes参数指代0序号的组件占据整排
   */
  scroller: Scroller = new Scroller()
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageLink ('isLandscapePhone') isLandscapePhone: boolean = false
  // 折叠屏展开状态判定
  @StorageLink ('isFoldStatus') isFoldStatus: boolean = false

  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  // 当前主页布局
  @Consume theCurrentHomeCard: boolean[]
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // PC判定
  @StorageLink ('2in1') is2in1: boolean = false

  @Builder CardImage(s:Resource,a:number,i:number,w:ResourceStr,isShow:boolean){
    if (this.theCurrentHomeCard[i] === false) {
      Image(s)
        .width(w)
        .aspectRatio(a)
        .height(160)
        .ImageItemStyle()
        .transition(customAnimationUtil.isScaleTran(i, this.uiConfig))
        .onClick(() => {
          animateTo({ duration: this.uiConfig.animationSpeed, curve: curves.springMotion() }, () => {
            this.theCurrentHomeCard.splice(i, 1, isShow)
          })
        })
    }
  }


  build() {
    Flex({ wrap: FlexWrap.Wrap,justifyContent:FlexAlign.SpaceBetween, space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) } }) { // 子组件多行布局
      ForEach(HomeCardList,(item: HomeCardItem, i: number)=> {
        this.CardImage(item.image, item.aspectRatio, i, item.width,item.isShow)
      })

      // 快捷方式小卡片
      if (this.isFoldStatus && !this.is2in1 ? this.theCurrentHomeCard[9] : !this.theCurrentHomeCard[9]) {
        Image($r('app.media.Shortcuts'))
          .width('48.5%')
          .height(160)
          .aspectRatio(1)
          .ImageItemStyle()
          .transition(customAnimationUtil.isScaleTran(9, this.uiConfig))
          .onClick(() => {
            animateTo({ duration: this.uiConfig.animationSpeed, curve: curves.springMotion() }, () => {
              this.theCurrentHomeCard.splice(9, 1, this.isFoldStatus && !this.is2in1 ? false : true)
            })
          })
      }

      Row(){
        this.CardImage($r('app.media.ProxyINFO'), 2.07, 8, '100%', true)
      }
      .onClick(() => {
        animateTo({ duration: this.uiConfig.animationSpeed, curve: curves.springMotion() }, () => {
          this.theCurrentHomeCard.splice(8, 1, true)
        })
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

