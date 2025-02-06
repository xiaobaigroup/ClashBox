import { LengthMetrics } from "@kit.ArkUI"
import { ANIMATION_DURATION_300 } from "../../common/Constants"
import { BreakpointState } from "../../common/breakpointsystem"
import { AppConfig } from "../../entryability/AppState"



@Component
export struct CardEdit {

  /*
  grid网格组件相关数据,包含scroller控制器,regularSize参数指代组件布局大小为1:1,irregularIndexes参数指代0序号的组件占据整排
   */
  scroller: Scroller = new Scroller()

  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  /* 是否开启全局动画判定 */
  @Consume ('isAnimation') isAnimation: boolean
  /* 主页卡片高度*/
  @Consume('HomeCardEditHeight') private HomeCardEditHeight: BreakpointState<number>
  // 折叠屏展开状态判定
  @StorageProp('isFoldStatus') private isFoldStatus: boolean = false

  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  // 当前主页布局
  @Consume theCurrentHomeCard: boolean[]


  build() {
    Flex({ wrap: FlexWrap.Wrap,justifyContent:FlexAlign.SpaceBetween, space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) } }) { // 子组件多行布局
      //网络速率小卡片
      if (this.theCurrentHomeCard[0] === false) {
        Image($rawfile('Speed.png'))
          .width('100%')
          .aspectRatio(2.07)
          .height(this.HomeCardEditHeight.value)
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
          .onAttach(() => {
          })//挂载回调
          .onDetach(() => {
          })//卸载回调
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.theCurrentHomeCard.splice(0, 1, true)
            })
          })
      }

      //节点信息小卡片
      if (this.theCurrentHomeCard[7] === false) {
        Image($rawfile('ProxyINFO.png'))
          .width('100%')
          .height(this.HomeCardEditHeight.value)
          .aspectRatio(2.07)
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({ x: 0, y: 0 }).animation({ duration: ANIMATION_DURATION_300 }) : null)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.theCurrentHomeCard.splice(7, 1, true)
            })
          })
      }

      //分流模式小卡片
      if (this.theCurrentHomeCard[1] === false) {
        Image($rawfile('SwitchMode.png'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
            //        .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.theCurrentHomeCard.splice(1, 1, true)
            })
          })
      }

      //流量统计小卡片
      if (this.theCurrentHomeCard[2] === false) {
        Image($rawfile('CellularData.png'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
            //      .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.theCurrentHomeCard.splice(2, 1, true)
            })
          })
      }

      //当前节点小卡片
      if (this.theCurrentHomeCard[3] === false) {
        Image($rawfile('CurrentNode.png'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.theCurrentHomeCard.splice(3, 1, true)
            })
          })
      }

      //IP地址小卡片
      if (this.theCurrentHomeCard[4] === false) {
        Image($rawfile('PublicNetwork.png'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
            //       .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.theCurrentHomeCard.splice(4, 1, true)
            })
          })
      }

      //收藏节点小卡片
      if (this.theCurrentHomeCard[5] === false) {
        Image($rawfile('FavoriteProxy.png'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
            //      .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.theCurrentHomeCard.splice(5, 1, true)
            })
          })
      }

      //收藏配置小卡片
      if (this.theCurrentHomeCard[6] === false) {
        Image($rawfile('FavoriteConfiguration.png'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
            //      .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.theCurrentHomeCard.splice(6, 1, true)
            })
          })
      }

      //当前配置小卡片
      if (this.theCurrentHomeCard[8] === false) {
        Image($rawfile('CurrentConfiguration.png'))
          .width('48.5%')
          .height(this.HomeCardEditHeight.value)
          .aspectRatio(1)
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
            //      .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.theCurrentHomeCard.splice(8, 1, true)
            })
          })
      }

      //快捷方式小卡片
      if (this.theCurrentHomeCard[9] === this.isFoldStatus ? true : false) {
        Image($rawfile('Shortcuts.png'))
          .width('48.5%')
          .height(this.HomeCardEditHeight.value)
          .aspectRatio(1)
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
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

