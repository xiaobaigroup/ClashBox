import { image } from "@kit.ImageKit"
import { LengthMetrics } from "@kit.ArkUI"
import { ANIMATION_DURATION_300 } from "../../common/Constants"
import ProxyINFO from "./ProxyINFO"
import { BreakpointState } from "../../common/breakpointsystem"
import CurrentConfiguration from "./CurrentConfiguration"
import Shortcuts from "./Shortcuts"

//TODO 1.后续需要把各文件组件换为截图，以减少性能消耗。2.挂载和卸载无动画效果，后面需要加入
@Component
export struct CardEdit {
  /*
  grid网格组件相关数据,包含scroller控制器,regularSize参数指代组件布局大小为1:1,irregularIndexes参数指代0序号的组件占据整排
   */
  scroller: Scroller = new Scroller()
  /*
  主页卡片组件截图
 */
  @Consume ('pixmapSpeed')pixmapSpeed: image.PixelMap | undefined
  @Consume ('pixmapSwitchMode')pixmapSwitchMode: image.PixelMap | undefined
  @Consume ('pixmapCellularData')pixmapCellularData: image.PixelMap | undefined
  @Consume ('pixmapCurrentNode')pixmapCurrentNode: image.PixelMap | undefined
  @Consume ('pixmapPublicNetwork')pixmapPublicNetwork: image.PixelMap | undefined
  @Consume ('pixmapFavoriteProxy')pixmapFavoriteProxy: image.PixelMap | undefined
  @Consume ('pixmapFavoriteConfiguration')pixmapFavoriteConfiguration: image.PixelMap | undefined
  @Consume ('pixmapCurrentConfiguration')pixmapCurrentConfiguration: image.PixelMap | undefined
  @Consume ('pixmapProxyINFO')pixmapProxyINFO: image.PixelMap | undefined
  @Consume ('pixmapShortcuts')pixmapShortcuts: image.PixelMap | undefined

  //卡片卸载添加判定及卡片id
  @Consume('isShowSpeed') isShowSpeed: boolean
  @Consume('isShowSwitchMode') isShowSwitchMode: boolean
  @Consume('isShowCellularData') isShowCellularData: boolean
  @Consume('isShowCurrentNode') isShowCurrentNode: boolean
  @Consume('isShowPublicNetwork') isShowPublicNetwork: boolean
  @Consume('isShowFavoriteProxy') isShowFavoriteProxy: boolean
  @Consume('isShowFavoriteConfiguration') isShowFavoriteConfiguration: boolean
  @Consume('isShowProxyINFO') isShowProxyINFO: boolean
  @Consume('isShowCurrentConfiguration') isShowCurrentConfiguration: boolean
  @Consume('isShowShortcuts') isShowShortcuts: boolean
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  /* 是否开启全局动画判定 */
  @Consume ('isAnimation') isAnimation: boolean
  /* 主页卡片高度*/
  @Consume('HomeCardEditHeight') private HomeCardEditHeight: BreakpointState<number>

  build() {
    Flex({ wrap: FlexWrap.Wrap,justifyContent:FlexAlign.SpaceBetween, space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) } }) { // 子组件多行布局
      //网络速率小卡片
      if (!this.isShowSpeed) {
        Image(this.pixmapSpeed)
          .width('100%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
     //     .height(this.isLandscapePhone ? 200: this.HomeCardEditHeight.value)
          .onAttach(() => {
          })//挂载回调
          .onDetach(() => {
          })//卸载回调
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowSpeed = true
            })
          })
      }

      //节点信息小卡片
      if (!this.isShowProxyINFO && this.pixmapProxyINFO == undefined ) {
        ProxyINFO()
          .width('100%')
          .height(this.HomeCardEditHeight.value)
          .borderRadius(20)
          .aspectRatio(2.07)
          .backgroundColor($r('app.color.container_background'))
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowProxyINFO = true
            })
          })
      }else if(!this.isShowProxyINFO) {
        Image(this.pixmapProxyINFO)
          .width('100%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowProxyINFO = true
            })
          })
      }

      //分流模式小卡片
      if (!this.isShowSwitchMode) {
        Image(this.pixmapSwitchMode)
            .width('48.5%')
            .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
    //        .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
        .onClick(() => {
          animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
          this.isShowSwitchMode=true
          })
        })
      }

      //流量统计小卡片
      if (!this.isShowCellularData) {
        Image(this.pixmapCellularData)
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
    //      .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowCellularData=true
            })
          })
      }

      //当前节点小卡片
      if (!this.isShowCurrentNode) {
        Image(this.pixmapCurrentNode)
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowCurrentNode=true
            })
          })
      }

      //IP地址小卡片
      if (!this.isShowPublicNetwork) {
        Image(this.pixmapPublicNetwork)
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
   //       .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowPublicNetwork=true
            })
          })
      }

      //收藏节点小卡片
      if (!this.isShowFavoriteProxy) {
       Image(this.pixmapFavoriteProxy)
          .width('48.5%')
          .ImageItemStyle()
         .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
    //      .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
            this.isShowFavoriteProxy=true
            })
          })
      }

      //收藏配置小卡片
      if (!this.isShowFavoriteConfiguration) {
        Image(this.pixmapFavoriteConfiguration)
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
    //      .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
            this.isShowFavoriteConfiguration=true
            })
          })
      }

      //当前配置小卡片
      if (!this.isShowCurrentConfiguration && this.pixmapCurrentConfiguration == undefined) {
        CurrentConfiguration()
          .width('48.5%')
          .height(this.HomeCardEditHeight.value)
          .aspectRatio(1)
          .borderRadius(20)
          .backgroundColor($r('app.color.container_background'))
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
            //      .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowCurrentConfiguration=true
            })
          })
      } else if(!this.isShowCurrentConfiguration) {
        Image(this.pixmapCurrentConfiguration)
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowCurrentConfiguration = true
            })
          })
      }


      //快捷方式小卡片
      if (!this.isShowShortcuts) {
        Shortcuts()
          .width('48.5%')
          .height(this.HomeCardEditHeight.value)
          .aspectRatio(1)
          .borderRadius(20)
          .backgroundColor($r('app.color.container_background'))
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
            //      .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowShortcuts=true
            })
          })
      } else if(!this.isShowShortcuts) {
        Image(this.pixmapShortcuts)
          .width('48.5%')
          .ImageItemStyle()
          .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
          .onClick(() => {
            animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
              this.isShowShortcuts = true
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

