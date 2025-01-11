import { BreakpointState } from '../../common/breakpointsystem'
import { BIND_SHEET_CONTAINER_HEIGHT, MarginGenerate } from '../../common/Constants'
import { CardTitle } from './CardTitleBuilder'

//TODO 还没写完！ 还没写完 ！还没写完！

@Component
struct Shortcuts {
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  // 内容文本字体大小
  @Consume('breakPointStateHomeCardSwitchModeFontSize') private fontSize: BreakpointState<number>
  // 内容文本字体大小
  @Consume('breakPointStateCardCellularDataFontSize') private fontSize1: BreakpointState<number>
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding')  private cardPadding: BreakpointState<MarginGenerate>
  @State isShowShortcutsEdit :boolean = false
  @State isShowShortcuts :boolean = false
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  @Consume('breakPointStateTabContentTitleMargin')
  private breakPointStateTabContentTitleMargin: BreakpointState<number>

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Center }) {
      CardTitle({ title: '快捷方式' })
      Blank(5)
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween }) {
        if (this.isShowShortcuts) {
          Text('自定义网址1')
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .fontColor($r('sys.color.font_primary'))

          Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))

          Text('自定义网址2')
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .fontColor($r('sys.color.font_primary'))

          Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))

          Text('自定义网址4')
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .fontColor($r('sys.color.font_primary'))
        }else {
          Text('点我修改')
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .fontColor($r('sys.color.font_primary'))
            .onClick(() => {
              this.isShowShortcutsEdit = true
          //    this.isEnableIndexForegroundBlur=true
            })

          Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))

          Text('点我修改')
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .fontColor($r('sys.color.font_primary'))

          Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))

          Text('点我修改')
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .fontColor($r('sys.color.font_primary'))
        }
      }
      .width('100%')
      .height('82%')
      .backgroundColor($r('app.color.home_card_background'))
      .borderRadius(10)
      .padding({ top:8,bottom:8 ,left:5})
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
    .bindSheet($$this.isShowShortcutsEdit, this.ShortcutsEdit(), {
      detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.LARGE,],
      preferType: SheetType.CENTER,
      backgroundColor: $r('app.color.background'),
      showClose: true,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      title: { title: '快捷方式小卡片' },
      onWillDismiss: () => {
        this.isShowShortcutsEdit = false
     //   this.isEnableIndexForegroundBlur = false
      }
    })
  }

  //半模态窗口
  @Builder
  ShortcutsEdit() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Center }) {
      Blank(10)

     Text('选项1').TitleTextStyle()
      Blank(10)
      Column({space:16}){
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
          Text('标题').TextStyle()
          Column() {
            Text('请输入').TextStyle1()
            Divider().strokeWidth(1).color(this.icon_emphasize)
          }.width('30%')
        }
        Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
          Text('URL').TextStyle()
          Button('输入网址')
            .width('35%')
            .height(26)
            .fontColor(this.icon_emphasize)
            .fontSize(12)
            .backgroundColor($r('app.color.home_card_background'))
        }
      }.ColumnStyle()
      Blank(10)

      Text('选项2').TitleTextStyle()
      Blank(10)
      Column({space:16}){
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
          Text('标题').TextStyle()
          Column() {
            Text('请输入').TextStyle1()
            Divider().strokeWidth(1).color(this.icon_emphasize)
          }.width('30%')
        }
        Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
          Text('URL').TextStyle()
          Button('输入网址')
            .width('35%')
            .height(26)
            .fontColor(this.icon_emphasize)
            .fontSize(12)
            .backgroundColor($r('app.color.home_card_background'))
        }
      }.ColumnStyle()
      Blank(10)

      Text('选项3').TitleTextStyle()
      Blank(10)
      Column({space:16}){
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
          Text('标题').TextStyle()
          Column() {
            Text('请输入').TextStyle1()
            Divider().strokeWidth(1).color(this.icon_emphasize)
          }.width('30%')
        }
        Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
          Text('URL').TextStyle()
          Button('输入网址')
            .width('35%')
            .height(26)
            .fontColor(this.icon_emphasize)
            .fontSize(12)
            .backgroundColor($r('app.color.home_card_background'))
        }
      }.ColumnStyle()
    }
    .width('100%')
    .padding({
      left: this.breakPointStateTabContentTitleMargin.value,
      right: this.breakPointStateTabContentTitleMargin.value,
    })
  }
}
export default Shortcuts
//半模拟态组件样式
@Extend(Column)
  function ColumnStyle() {
  .width("100%")
  .backgroundColor($r('app.color.container_background'))
  .padding({ left:10, right:10,top:16,bottom:16 })
  .alignItems(HorizontalAlign.Center)
  .borderRadius(24)
  }
//半模拟态内部文本样式
@Extend(Text)
function TextStyle() {
  .width("100%")
  .fontSize(16)
  .fontColor($r('sys.color.font_primary'))
}
//半模拟态小标题文本样式
@Extend(Text)
function TitleTextStyle() {
  .width("100%")
  .fontSize(16)
  .fontColor($r('sys.color.font_secondary'))
  .padding({left:3})
}

//半模拟态内部请输入文本样式
@Extend(Text)
function TextStyle1() {
  .width("100%")
  .fontSize(14)
  .textAlign(TextAlign.Center)
  .fontColor($r('sys.color.font_secondary'))
}
