import { RightStyle, SettingsGroup, SettingsItem } from "../settings/SettingsCommonOp"
import { PADDING_VALUE_14, PADDING_VALUE_16 } from "./Constants"
import { Xb_TopTitleBar } from "./Xb_TopTitleBar"
import { Xb_GeneralListItem } from "./Xb_GeneralListItem"

@ComponentV2
export struct Xb_SettingsCommon {

  @Param needRefresh: boolean = false // 邪门写法(

  @Param widthBp: number = 0
  @Param isNavStyle: boolean = true
  @Param pageTitle: ResourceStr = ''
  @Param needBack: boolean = false
  @Param currentRadio: string = ''
  @Param topBackgroundColor: ResourceColor = $r('app.color.xb_window_background')

  @Param @Require pageInfos: NavPathStack
  @Param @Require configList: SettingsGroup[]

  @Local localPageInfos: NavPathStack = new NavPathStack()

  @Event onMenuChange: (item: SettingsItem, index: number) => void
  @Event onRowClick: (item: SettingsItem) => void

  @BuilderParam TopContentBuilder: () => void = this.deafultTopContentBuilder

  build() {
    Stack() {
      Xb_TopTitleBar({
        fontSize: 28,
        heightTotal: 56,
        animationUse: true,
        name: this.pageTitle,
        buttonColor: $r('app.color.button_bg'),
        isBackPress: this.needBack,
        paddingValue: PADDING_VALUE_16,
        onClickIcon: (index) => {
          if (index === 2) {
            this.localPageInfos.pop()
          }
        }
      })
        .backgroundColor(this.topBackgroundColor)
        .position({top: 0})
        .zIndex(2)

      List() {
        ListItemGroup() {
          this.TopContentBuilder()
        }
        ForEach(this.configList, (group: SettingsGroup) => {
          if (group.title) {
            ListItemGroup({ header: this.ItemHeader(group.title, FontWeight.Medium, Color.Gray) })
              .margin({ bottom: 3 })
          }
          ListItemGroup() {
            ForEach(group.items, (item: SettingsItem) => {
              ListItem() {
                Xb_GeneralListItem({
                  itemID: item.id,
                  startFontSize: 16,
                  mainSpace: 8,
                  showStart: item.icon !== undefined,
                  needRowClick: true,
                  tips: item.contentR,
                  startIcon: item.icon,
                  title: item.contentL,
                  theRadio: item.id,
                  currentRadio: this.currentRadio,
                  subtitle1: item.contentSecL,
                  endStyles: item.rightStyle,
                  menuIcon: item.menuIcon,
                  menuSelect: item.menuSelect,
                  menuList: item.menuList,
                  toggleState: item.toggleState,
                  onMenuSelect: (index) => {
                    this.onMenuChange(item, index)
                  },
                  onRowClick: () => {
                    this.onRowClick(item)
                    if (item.onClick) {
                      item.onClick()
                      console.log(`显示${item.id}开关, localToggleState：${item.toggleState}`)
                    } else if (!item.onClick && (item.rightStyle === RightStyle.JUMP || item.rightStyle === RightStyle.TEXTRIGHT)) {
                      this.localPageInfos.pushPathByName(item.id, null, true)
                    }
                  }
                })
              }
              // .onAppear(() => {
              //   console.log(`列表组件加载`)
              // })
              // .onDetach(() => {
              //   console.log(`列表组件卸载`)
              // })
            }, (item: SettingsItem) => item.id)
          }
          .divider({ strokeWidth: 1, color: $r('app.color.divider_light') })
          .backgroundColor($r('app.color.comp_background_list_card'))
          .borderRadius(24)
          .width('100%')
          .padding({
            top: group.items.length > 1 ? 5 : 0,
            bottom: group.items.length > 1 ? 5 : 0,
            left: 7,
            right: 7
          })
          .margin({bottom: 12})
        }, this.needRefresh ? (item: SettingsGroup, index: number) => { return index + '__' + JSON.stringify(item); } : (group: SettingsGroup, index) => `group_${group.title}${index}`)

      }
      .width('100%')
      .height('100%')
      .contentEndOffset(56)
      .contentStartOffset(56)
      .padding({left: PADDING_VALUE_14, right: PADDING_VALUE_14})
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Top)
  }

  @Builder
  ItemHeader(title: ResourceStr, fontWeight: FontWeight, fontColor: ResourceColor, leftMargin: number = 16) {
    Text(title)
      .fontSize(16)
      .width('100%')
      .fontColor(fontColor)
      .fontWeight(fontWeight)
      .textAlign(TextAlign.Start)
      .padding({ top: 8, bottom: 8, left: leftMargin })
  }

  @Builder
  private deafultTopContentBuilder() {}

  aboutToAppear(): void {
    if (this.pageInfos) {
      this.localPageInfos = this.pageInfos
    }
  }

}