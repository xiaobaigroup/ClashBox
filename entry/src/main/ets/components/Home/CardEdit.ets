import { curves, LengthMetrics } from "@kit.ArkUI"
import { BreakpointState } from "../../common/breakpointsystem"
import { HomeCardItem, HomeCardList } from "../../common/Constants"
import { AppConfig, UIConfig } from "../../entryability/AppState"
import { customAnimationUtil } from "../../utils/Animation"



@Component
export struct CardEdit {
  /*
  grid网格组件相关数据,包含scroller控制器,regularSize参数指代组件布局大小为1:1,irregularIndexes参数指代0序号的组件占据整排
   */
  scroller: Scroller = new Scroller()
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  /* 主页卡片高度*/
  @Consume('HomeCardEditHeight') private HomeCardEditHeight: BreakpointState<number>
  @Consume('breakPointStateTabContentTitleMargin')
  private breakPointStateTabContentTitleMargin: BreakpointState<number>
  // 折叠屏展开状态判定
  @StorageProp('isFoldStatus') private isFoldStatus: boolean = false

  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  // 当前主页布局
  @Consume theCurrentHomeCard: boolean[]
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  @Builder CardImage(s:Resource,a:number,i:number,w:ResourceStr,isShow:boolean){
    if (this.theCurrentHomeCard[i] === false) {
      Image(s)
        .width(w)
        .aspectRatio(a)
        .height(this.HomeCardEditHeight.value)
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
      ForEach(HomeCardList,(item:HomeCardItem,i:number)=> {
        this.CardImage(item.image,item.aspectRatio,i,item.width,item.isShow)
      })

      //快捷方式小卡片
      if (this.theCurrentHomeCard[9] === this.isFoldStatus ? true : false) {
        Image($r('app.media.Shortcuts'))
          .width('48.5%')
          .height(this.HomeCardEditHeight.value)
          .aspectRatio(1)
          .ImageItemStyle()
          .transition(customAnimationUtil.isScaleTran(9,this.uiConfig))
          .onClick(() => {
            animateTo({ duration: this.uiConfig.animationSpeed, curve: curves.springMotion() }, () => {
              this.theCurrentHomeCard.splice(9, 1, this.isFoldStatus ? false : true)
            })
          })
      }
    }
    .width('100%')
    .padding({
      left: this.breakPointStateTabContentTitleMargin.value,
      right: this.breakPointStateTabContentTitleMargin.value,
    bottom:30})
  }
}

@Extend(Image)
function ImageItemStyle() {
  .borderRadius(20)
  .backgroundColor($r('app.color.container_background'))
}

