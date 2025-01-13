import { BreakpointState } from '../../common/breakpointsystem'
import { mediaquery } from '@kit.ArkUI'
import { MarginGenerate } from '../../common/Constants'
import { CardTitle } from './CardTitleBuilder'
import { Item, ProxyData } from '../../common/ProxyData'



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
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //主页卡片内容IP地址小字体大小
  @Consume('HomeCardIPSmFontSize')
  private HomeCardIPSmFontSize: BreakpointState<number>
  /*
编辑模式下右上角删除按钮
 */
  @Consume deleteButtonSize: BreakpointState<number>
  // 当前代理节点长按选择的值
  @Consume private FavoriteProxy: number
  // 当前代理节点单选选择的值
  @Consume private ProxyRadioCheckedValue: number
  // 当前代理节点长按选择的值
  @Consume private ProxyItemLongPressValue: number
  //编辑按钮点击后显示编辑状态判定
  @Consume isShowHomeEdit: boolean


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
            Radio({ value: 'FavoriteProxyRadio1', group: 'FavoriteProxyGroup' })
              .width(this.isLandscapePhone ? 16 : this.fontSize.value)
              .checked(this.FavoriteProxyRadio === 1)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
              })
              .onChange(() => {
                //在home页编辑状态时，无法操作
                if (!this.isShowHomeEdit) {
                this.FavoriteProxyRadio === 1
                this.ProxyRadioCheckedValue = this.FavoriteProxy
                  }
              })
          }
          .onClick(() => {
            //在home页编辑状态时，无法操作
            if (!this.isShowHomeEdit) {
              this.FavoriteProxyRadio = 1
              this.ProxyRadioCheckedValue = this.FavoriteProxy
            }
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE })

          Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))

          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
            //TODO 此处items[this.FavoriteProxy]中的this.FavoriteProxy为收藏点击一次取值的数值，后面需要更改（我不会需要大佬sos）
            Text(`${this.items[this.FavoriteProxy].text}`)
              .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
              .fontColor($r('sys.color.font_primary'))
            Radio({ value: 'FavoriteProxyRadio2', group: 'FavoriteProxyGroup' })
              .width(this.isLandscapePhone ? 16 : this.fontSize.value)
              .checked(this.FavoriteProxyRadio === 2)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
              })
              .onChange(() => {
                //在home页编辑状态时，无法操作
                if (!this.isShowHomeEdit) {
                  this.FavoriteProxyRadio === 2
                  //TODO 此处this.FavoriteProxy为收藏点击一次取值的数值，后面需要更改（我不会需要大佬sos）
                  this.ProxyRadioCheckedValue = this.FavoriteProxy
                }
              })
          }
          .onClick(() => {
            //在home页编辑状态时，无法操作
            if (!this.isShowHomeEdit) {
              this.FavoriteProxyRadio = 2
              this.ProxyRadioCheckedValue = this.FavoriteProxy
            }
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE })

          Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))

          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
            //TODO 此处items[this.FavoriteProxy]中的this.FavoriteProxy为收藏点击一次取值的数值，后面需要更改（我不会需要大佬sos）
            Text(`${this.items[this.FavoriteProxy].text}`)
              .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
              .fontColor($r('sys.color.font_primary'))
            Radio({ value: 'FavoriteProxyRadio3', group: 'FavoriteProxyGroup' })
              .width(this.isLandscapePhone ? 16 : this.fontSize.value)
              .checked(this.FavoriteProxyRadio === 3)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
              })
              .onChange(() => {
                //在home页编辑状态时，无法操作
                if (!this.isShowHomeEdit) {
                  this.FavoriteProxyRadio === 3
                  //TODO 此处this.FavoriteProxy为收藏点击一次取值的数值，后面需要更改（我不会需要大佬sos）
                  this.ProxyRadioCheckedValue = this.FavoriteProxy
                }
              })
          }
          .onClick(() => {
            //在home页编辑状态时，无法操作
            if (!this.isShowHomeEdit) {
            this.FavoriteProxyRadio = 3
            this.ProxyRadioCheckedValue = this.FavoriteProxy
              }
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
      }//没有收藏节点的布局 end
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .id('FavoriteProxyId')
  }
}
export default FavoriteProxy


