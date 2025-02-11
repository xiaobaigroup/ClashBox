import { curves, LengthMetrics } from "@kit.ArkUI"
import { BreakpointState } from "../../common/breakpointsystem"
import { AppConfig, UIConfig } from "../../entryability/AppState"
import HomePage from "../../pages/HomePage"
import { customAnimationUtil } from "../../utils/Animation"
import { image } from "@kit.ImageKit"
import { ConfigurationConstant } from "@kit.AbilityKit"


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
  // 折叠屏展开状态判定
  @StorageProp('isFoldStatus') private isFoldStatus: boolean = false

  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  // 当前主页布局
  @Consume theCurrentHomeCard: boolean[]
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  build() {
    Flex({ wrap: FlexWrap.Wrap,justifyContent:FlexAlign.SpaceBetween, space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) } }) { // 子组件多行布局
      //网络速率小卡片
      if (this.theCurrentHomeCard[0] === false) {
        Image($r('app.media.Speed'))
          .width('100%')
          .aspectRatio(2.07)
          .height(this.HomeCardEditHeight.value)
          .ImageItemStyle()
          .transition(customAnimationUtil.isScaleTran(0,this.uiConfig))
         // .transition(this.uiConfig.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: this.uiConfig.animationSpeed }):null)
          .onAttach(() => {
          })//挂载回调
          .onDetach(() => {
          })//卸载回调
          .onClick(() => {
            animateTo({ duration: this.uiConfig.animationSpeed, curve: curves.springMotion() }, () => {
              this.theCurrentHomeCard.splice(0, 1, true)
            })
          })
      }

      //节点信息小卡片
      if (this.theCurrentHomeCard[7] === false) {
        Image($r('app.media.ProxyINFO'))
          .width('100%')
          .height(this.HomeCardEditHeight.value)
          .aspectRatio(2.07)
          .ImageItemStyle()
          .transition(customAnimationUtil.isScaleTran(1,this.uiConfig))
         // .transition(this.uiConfig.isAnimation ? TransitionEffect.scale({ x: 0, y: 0 }).animation({ duration: this.uiConfig.animationSpeed }) : null)
          .onClick(() => {
            animateTo({ duration: this.uiConfig.animationSpeed, curve: curves.springMotion() }, () => {
              this.theCurrentHomeCard.splice(7, 1, true)
            })
          })
      }

      //分流模式小卡片
      if (this.theCurrentHomeCard[1] === false) {
        Image($r('app.media.SwitchMode'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(customAnimationUtil.isScaleTran(2,this.uiConfig))
          .onClick(() => {
            animateTo({ duration: this.uiConfig.animationSpeed, curve: curves.springMotion() }, () => {
              this.theCurrentHomeCard.splice(1, 1, true)
            })
          })
      }

      //流量统计小卡片
      if (this.theCurrentHomeCard[2] === false) {
        Image($r('app.media.CellularData'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(customAnimationUtil.isScaleTran(3,this.uiConfig))
          .onClick(() => {
            animateTo({ duration: this.uiConfig.animationSpeed, curve: curves.springMotion() }, () => {
              this.theCurrentHomeCard.splice(2, 1, true)
            })
          })
      }

      //当前节点小卡片
      if (this.theCurrentHomeCard[3] === false) {
        Image($r('app.media.CurrentNode'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(customAnimationUtil.isScaleTran(4,this.uiConfig))
         // .transition(this.uiConfig.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: this.uiConfig.animationSpeed }):null)
          .onClick(() => {
            animateTo({ duration: this.uiConfig.animationSpeed, curve: curves.springMotion() }, () => {
              this.theCurrentHomeCard.splice(3, 1, true)
            })
          })
      }

      //IP地址小卡片
      if (this.theCurrentHomeCard[4] === false) {
        Image($r('app.media.PublicNetwork'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(customAnimationUtil.isScaleTran(5,this.uiConfig))
        //  .transition(this.uiConfig.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: this.uiConfig.animationSpeed }):null)
            //       .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: this.uiConfig.animationSpeed, curve: curves.springMotion() }, () => {
              this.theCurrentHomeCard.splice(4, 1, true)
            })
          })
      }

      //收藏节点小卡片
      if (this.theCurrentHomeCard[5] === false) {
        Image($r('app.media.FavoriteProxy'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(customAnimationUtil.isScaleTran(6,this.uiConfig))
        //  .transition(this.uiConfig.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: this.uiConfig.animationSpeed }):null)
            //      .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: this.uiConfig.animationSpeed, curve: curves.springMotion() }, () => {
              this.theCurrentHomeCard.splice(5, 1, true)
            })
          })
      }

      //收藏配置小卡片
      if (this.theCurrentHomeCard[6] === false) {
        Image($r('app.media.FavoriteConfiguration'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(customAnimationUtil.isScaleTran(7,this.uiConfig))
        //  .transition(this.uiConfig.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: this.uiConfig.animationSpeed }):null)
            //      .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: this.uiConfig.animationSpeed, curve: curves.springMotion() }, () => {
              this.theCurrentHomeCard.splice(6, 1, true)
            })
          })
      }

      //当前配置小卡片
      if (this.theCurrentHomeCard[8] === false) {
        Image($r('app.media.CurrentConfiguration'))
          .width('48.5%')
          .height(this.HomeCardEditHeight.value)
          .aspectRatio(1)
          .ImageItemStyle()
          .transition(customAnimationUtil.isScaleTran(8,this.uiConfig))
      //    .transition(this.uiConfig.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: this.uiConfig.animationSpeed }):null)
            //      .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: this.uiConfig.animationSpeed, curve: curves.springMotion() }, () => {
              this.theCurrentHomeCard.splice(8, 1, true)
            })
          })
      }

      //快捷方式小卡片
      if (this.theCurrentHomeCard[9] === this.isFoldStatus ? true : false) {
        Image($r('app.media.Shortcuts'))
          .width('48.5%')
          .height(this.HomeCardEditHeight.value)
          .aspectRatio(1)
          .ImageItemStyle()
          .transition(customAnimationUtil.isScaleTran(9,this.uiConfig))
       //   .transition(this.uiConfig.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: this.uiConfig.animationSpeed }):null)
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
    })
  }
  @Consume('breakPointStateTabContentTitleMargin')
  private breakPointStateTabContentTitleMargin: BreakpointState<number>
}

@Extend(Image)
function ImageItemStyle() {
  .borderRadius(20)
  .backgroundColor($r('app.color.container_background'))
}

