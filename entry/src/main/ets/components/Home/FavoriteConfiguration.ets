import { BreakpointState } from '../../common/breakpointsystem'
import { mediaquery } from '@kit.ArkUI'
import { MarginGenerate } from '../../common/Constants'
import { CardTitle } from './CardTitleBuilder'


@Component
struct FavoriteConfiguration {
  //后端接入后此处应改为收藏的配置项
  @State FavoriteConfiguration: string [] = ['收藏配置1','收藏配置2','收藏配置3']
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding')  private cardPadding: BreakpointState<MarginGenerate>
  // 内容文本字体大小
  @Consume('breakPointStateHomeCardSwitchModeFontSize') private fontSize: BreakpointState<number>
  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');
  //radio选中判定
  @State FavoriteConfigurationRadio :number =0
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //有无收藏代理节点判定
  @State isCheckFavoriteConfiguration:boolean=true
  //主页卡片内容IP地址小字体大小
  @Consume('HomeCardIPSmFontSize')
  private HomeCardIPSmFontSize: BreakpointState<number>
  /*
编辑模式下右上角删除按钮
 */
  @Consume deleteButtonSize: BreakpointState<number>

  build() {
    Column() {
      CardTitle({ title: $r('app.string.FavoriteConfiguration') })
      //拥有收藏配置的布局 start
      if (this.isCheckFavoriteConfiguration) {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceEvenly }) {
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
            Text(this.FavoriteConfiguration[0])
              .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
              .fontColor($r('sys.color.font_primary'))
            Radio({ value: 'FavoriteConfigurationRadio1', group: 'FavoriteConfigurationRadioGroup' })
              .width(this.isLandscapePhone ? 16 : this.fontSize.value)
              .checked(this.FavoriteConfigurationRadio === 1)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
              })
          }
          .onClick(() => {
            this.FavoriteConfigurationRadio = 1
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE })

          Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))

          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
            Text(this.FavoriteConfiguration[1])
              .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
              .fontColor($r('sys.color.font_primary'))
            Radio({ value: 'FavoriteConfigurationRadio2', group: 'FavoriteConfigurationRadioGroup' })
              .width(this.isLandscapePhone ? 16 : this.fontSize.value)
              .checked(this.FavoriteConfigurationRadio === 2)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
              })
          }
          .onClick(() => {
            this.FavoriteConfigurationRadio = 2
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE })

          Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))

          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
            Text(this.FavoriteConfiguration[2])
              .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
              .fontColor($r('sys.color.font_primary'))
            Radio({ value: 'FavoriteConfigurationRadio3', group: 'FavoriteConfigurationRadioGroup' })
              .width(this.isLandscapePhone ? 16 : this.fontSize.value)
              .checked(this.FavoriteConfigurationRadio === 3)
              .radioStyle({
                checkedBackgroundColor: this.icon_emphasize,
              })
          }
          .onClick(() => {
            this.FavoriteConfigurationRadio = 3
            this.isCheckFavoriteConfiguration=false//为预览而设置的点击事件，后端接入修改或删除
          })
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
        }
        .width('100%')
        .height('82%')
        .backgroundColor($r('sys.color.comp_background_tertiary'))
        .borderRadius(10)
        .padding({ left: 8, right: 5 })
      }//拥有收藏配置的布局 end

     //没有收藏配置时的布局 start
      else if (!this.isCheckFavoriteConfiguration)
      {
        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
          SymbolGlyph($r('sys.symbol.star'))
            .fontSize(this.isLandscapePhone?24 :this.deleteButtonSize.value)
            .fontColor([$r('sys.color.font_secondary')])
            .padding({bottom:5})

          Text($r('app.string.FavoriteConfigurationTips'))
            .fontSize(this.isLandscapePhone ? 12:this.HomeCardIPSmFontSize.value)
            .fontColor($r('sys.color.font_secondary'))
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height("78%")
        .onClick(() => {
          this.isCheckFavoriteConfiguration=true
        })//为预览而设置的点击事件，后端接入修改或删除
      }//没有收藏配置时的布局 end
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
export default FavoriteConfiguration