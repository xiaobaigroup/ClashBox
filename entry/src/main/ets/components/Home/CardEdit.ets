import { BreakpointState } from "../../common/breakpointsystem"
import CellularData from "./CellularData"
import CurrentNode from "./CurrentNode"
import FavoriteConfiguration from "./FavoriteConfiguration"
import FavoriteProxy from "./FavoriteProxy"
import PublicNetwork from "./PublicNetwork"
import SwitchMode from "./SwitchMode"
import { image } from "@kit.ImageKit"
import { LengthMetrics } from "@kit.ArkUI"

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
  @Consume pixmap: image.PixelMap | undefined
  //卡片卸载添加判定及卡片id
  @Consume('isShowSpeed') isShowSpeed: boolean
  @Consume('isShowSwitchMode') isShowSwitchMode: boolean
  @Consume('isShowCellularData') isShowCellularData: boolean
  @Consume('isShowCurrentNode') isShowCurrentNode: boolean
  @Consume('isShowPublicNetwork') isShowPublicNetwork: boolean
  @Consume('isShowFavoriteProxy') isShowFavoriteProxy: boolean
  @Consume('isShowFavoriteConfiguration') isShowFavoriteConfiguration: boolean

  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  //主页卡片内容编辑添加半模拟态里卡片高度
  @Consume('HomeCardEditHeight') private HomeCardEditHeight: BreakpointState<number>


  build() {
    Flex({ wrap: FlexWrap.Wrap,justifyContent:FlexAlign.SpaceBetween, space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) } }) { // 子组件多行布局
      if (!this.isShowSpeed) {
        Image(this.pixmap)
          .ImageItemStyle()
          .height(this.isLandscapePhone ? 200: this.HomeCardEditHeight.value)
          .onAttach(() => {
          })//挂载回调
          .onDetach(() => {
          })//卸载回调
          .onClick(() => {
            this.isShowSpeed = true
          })
      }

      if (!this.isShowSwitchMode) {
          SwitchMode()
            .width('48.5%')
            .borderRadius(20)
            .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
            .backgroundColor($r('app.color.container_background'))
        .onClick(() => {
          this.isShowSwitchMode=true
        })
      }

      if (!this.isShowCellularData) {
        CellularData()
          .width('48.5%')
          .borderRadius(20)
          .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .backgroundColor($r('app.color.container_background'))
          .onClick(() => {
            this.isShowCellularData=true
          })
      }

      if (!this.isShowCurrentNode) {
        CurrentNode()
          .width('48.5%')
          .borderRadius(20)
          .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .backgroundColor($r('app.color.container_background'))
          .onClick(() => {
            this.isShowCurrentNode=true
          })
      }

      if (!this.isShowPublicNetwork) {
        PublicNetwork()
          .width('48.5%')
          .borderRadius(20)
          .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .backgroundColor($r('app.color.container_background'))
          .onClick(() => {
            this.isShowPublicNetwork=true
          })
      }

      if (!this.isShowFavoriteProxy) {
        FavoriteProxy()
          .width('48.5%')
          .borderRadius(20)
          .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .backgroundColor($r('app.color.container_background'))
          .onClick(() => {
            this.isShowFavoriteProxy=true
          })
      }

      if (!this.isShowFavoriteConfiguration) {
        FavoriteConfiguration()
          .width('48.5%')
          .borderRadius(20)
          .height(this.isLandscapePhone ? 160 :this.HomeCardEditHeight.value)
          .backgroundColor($r('app.color.container_background'))
          .onClick(() => {
            this.isShowFavoriteConfiguration=true
          })
      }
    }
    .width('100%')
    .padding({  left: 14, right: 14 })
  }
}

@Extend(Image)
function ImageItemStyle() {
  .width('100%')
  .borderRadius(20)
  .backgroundColor($r('app.color.container_background'))
}

