import { LengthMetrics } from "@kit.ArkUI"
import { ANIMATION_DURATION_300 } from "../../common/Constants"
import { BreakpointState } from "../../common/breakpointsystem"
import { IsShowHomeCard, isShowHomeCardConfig } from "../../common/HomeCardEditData"


//TODO 1.后续需要把各文件组件换为截图，以减少性能消耗。2.挂载和卸载无动画效果，后面需要加入
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
  @StorageLink("isShowHomeCardConfig")isShowHomeCardConfig:IsShowHomeCard= new isShowHomeCardConfig()


  build() {
    Flex({ wrap: FlexWrap.Wrap,justifyContent:FlexAlign.SpaceBetween, space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) } }) { // 子组件多行布局
      //网络速率小卡片
      if (this.isShowHomeCardConfig.isShowSpeed === false) {
        Image($rawfile('Speed.png'))
          .width('100%')
          .aspectRatio(2.07)
          .height(this.HomeCardEditHeight.value)
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
            //     .height(this.isLandscapePhone ? 200: this.HomeCardEditHeight.value)
          .onAttach(() => {
          })//挂载回调
          .onDetach(() => {
          })//卸载回调
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowHomeCardConfig.isShowSpeed = true
            })
          })
      }

      //节点信息小卡片
      if (this.isShowHomeCardConfig.isShowProxyINFO === false) {
        Image($rawfile('ProxyINFO.png'))
          .width('100%')
          .height(this.HomeCardEditHeight.value)
          .aspectRatio(2.07)
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({ x: 0, y: 0 }).animation({ duration: ANIMATION_DURATION_300 }) : null)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowHomeCardConfig.isShowProxyINFO = true
            })
          })
      }

      //分流模式小卡片
      if (this.isShowHomeCardConfig.isShowSwitchMode === false) {
        Image($rawfile('SwitchMode.png'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
            //        .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowHomeCardConfig.isShowSwitchMode = true
            })
          })
      }

      //流量统计小卡片
      if (this.isShowHomeCardConfig.isShowCellularData === false) {
        Image($rawfile('CellularData.png'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
            //      .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowHomeCardConfig.isShowCellularData=true
            })
          })
      }

      //当前节点小卡片
      if (this.isShowHomeCardConfig.isShowCurrentNode === false) {
        Image($rawfile('CurrentNode.png'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowHomeCardConfig.isShowCurrentNode=true
            })
          })
      }

      //IP地址小卡片
      if (this.isShowHomeCardConfig.isShowPublicNetwork === false) {
        Image($rawfile('PublicNetwork.png'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
            //       .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowHomeCardConfig.isShowPublicNetwork=true
            })
          })
      }

      //收藏节点小卡片
      if (this.isShowHomeCardConfig.isShowFavoriteProxy === false) {
        Image($rawfile('FavoriteProxy.png'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
            //      .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowHomeCardConfig.isShowFavoriteProxy=true
            })
          })
      }

      //收藏配置小卡片
      if (this.isShowHomeCardConfig.isShowFavoriteConfiguration === false) {
        Image($rawfile('FavoriteConfiguration.png'))
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
            //      .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowHomeCardConfig.isShowFavoriteConfiguration=true
            })
          })
      }

      //当前配置小卡片
      if (this.isShowHomeCardConfig.isShowCurrentConfiguration === false) {
        Image($rawfile('CurrentConfiguration.png'))
          .width('48.5%')
          .height(this.HomeCardEditHeight.value)
          .aspectRatio(1)
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
            //      .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowHomeCardConfig.isShowCurrentConfiguration=true
            })
          })
      }


      //快捷方式小卡片
      if ( this.isShowHomeCardConfig.isShowShortcuts===this.isFoldStatus? true:false) {
        Image($rawfile('Shortcuts.png'))
          .width('48.5%')
          .height(this.HomeCardEditHeight.value)
          .aspectRatio(1)
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
            //      .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowHomeCardConfig.isShowShortcuts=this.isFoldStatus? false:true
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

