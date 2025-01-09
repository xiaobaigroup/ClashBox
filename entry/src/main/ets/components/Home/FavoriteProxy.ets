import { BreakpointState } from '../../common/breakpointsystem'
import { mediaquery } from '@kit.ArkUI'
import { MarginGenerate } from '../../common/Constants'
import { CardTitle } from './CardTitleBuilder'
import { Item } from '../../common/ProxyData'

@Component
struct FavoriteProxy {
  //节点假数据组后期可改可删
  @Consume items: Item[]
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding')  private cardPadding: BreakpointState<MarginGenerate>
  // 内容文本字体大小
  @Consume('breakPointStateHomeCardSwitchModeFontSize') private fontSize: BreakpointState<number>
  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');
  //radio选中判定
  @State FavoriteProxyRadio :number =0
  //收藏节点判定
  @State FavoriteProxy :number =0

  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //主页卡片内容IP地址小字体大小
  @Consume('HomeCardIPSmFontSize')
  private HomeCardIPSmFontSize: BreakpointState<number>
  /*
编辑模式下右上角删除按钮
 */
  @Consume deleteButtonSize: BreakpointState<number>

  build() {
    Column() {
      CardTitle({ title: $r('app.string.FavoriteProxy') })
      //拥有收藏节点的布局 start
      if (this.FavoriteProxy>=0) {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceEvenly }) {
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
            Text(`${this.items[this.FavoriteProxy].text}`)
              .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
              .fontColor($r('sys.color.font_primary'))
            Radio({ value: 'FavoriteProxyRadio1', group: 'FavoriteProxyRadioGroup' })
              .width(this.isLandscapePhone ? 16 : this.fontSize.value)
              .checked(this.FavoriteProxyRadio === 1)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
              })
          }
          .onClick(() => {
            this.FavoriteProxyRadio = 1
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE })

          Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))

          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
            Text(`${this.items[this.FavoriteProxy+1].text}`)
              .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
              .fontColor($r('sys.color.font_primary'))
            Radio({ value: 'FavoriteProxyRadio2', group: 'FavoriteProxyRadioGroup' })
              .width(this.isLandscapePhone ? 16 : this.fontSize.value)
              .checked(this.FavoriteProxyRadio === 2)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
              })
          }
          .onClick(() => {
            this.FavoriteProxyRadio = 2
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE })

          Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))

          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
            Text(`${this.items[this.FavoriteProxy+2].text}`)
              .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
              .fontColor($r('sys.color.font_primary'))
            Radio({ value: 'FavoriteProxyRadio3', group: 'FavoriteProxyRadioGroup' })
              .width(this.isLandscapePhone ? 16 : this.fontSize.value)
              .checked(this.FavoriteProxyRadio === 3)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
              })
          }
          .onClick(() => {
            this.FavoriteProxyRadio = 3
            this.FavoriteProxy=-1
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
        }
        .width('100%')
        .height('82%')
        .backgroundColor($r('app.color.home_card_background'))
        .borderRadius(10)
        .padding({ left: 8, right: 5 })
      }//拥有收藏节点的布局 end

      //没有收藏节点的布局 start
      else if (this.FavoriteProxy<0)
      {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
          SymbolGlyph($r('sys.symbol.star'))
            .fontSize(this.isLandscapePhone?24 :this.deleteButtonSize.value)
            .fontColor([$r('sys.color.font_secondary')])
            .padding({bottom:5})

          Text($r('app.string.favorite_proxy_tips'))
            .fontSize(this.isLandscapePhone ? 12:this.HomeCardIPSmFontSize.value)
            .fontColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height("78%")
        .onClick(() => {
          this.FavoriteProxy=0
        })//为预览而设置的点击事件，后端接入修改或删除
      }//没有收藏节点的布局 end
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
export default FavoriteProxy