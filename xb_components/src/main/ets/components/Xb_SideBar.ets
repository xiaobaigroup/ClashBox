import { Xb_SettingsGroupData, Xb_SettingsItemData } from "../model/SettingsItem"
import { BORDER_RADIUS_24, CONTENT_END_OFFSET, PADDING_VALUE_12, PADDING_VALUE_16 } from "./Constants"
import { Xb_SettingsItem } from "./Xb_SettingItem"
import { Xb_TopTitleBar } from "./Xb_TopTitleBar"
import { ThemeType } from "../entity/Common"
import { Xb_AnimationStyle } from "../utils/Animation"

/**
 * 侧边栏组件
 */
@ComponentV2
export struct Xb_SideBar{
  @Param isShowSideBar: boolean = false
  @Param titleText: ResourceStr = ''
  @Param isBackPress: boolean = false
  // 侧边栏list相关
  @Param gList?: Array<Xb_SettingsGroupData> = []
  @Param listItemBgColor: ResourceColor = $r('app.color.comp_background_list_card')
  // 侧边栏显示位置
  @Param sideBarPosition: SideBarPosition = SideBarPosition.Start

  // 自定义侧边栏内容
  @BuilderParam customList?: CustomBuilder
  // 列表里的自定义内容
  @BuilderParam customItem?: CustomBuilder

  @Event titleButtonVoid: (i: number) => void //i为2 ，返回按钮回调；i为0 右侧第一个按钮回调； i为1右侧第二个按钮回调

  build() {
    SideBarContainer(SideBarContainerType.Overlay){
      Column(){
        //  标题
        Xb_TopTitleBar({
          name: this.titleText,
          fontSize: 20,
          fontColor: $r('sys.color.font'),
          icon2: $r('sys.symbol.xmark'),
          heightTotal: 56,
          isBackPress: this.isBackPress,
          animationUse: false,
          onClickIcon: (i) => {
            Xb_AnimationStyle.animToAPI18(()=>{
              this.titleButtonVoid(i)
            }, 300, 'default')
          }
        }).width('100%').padding({top: 8})

        if (this.customList){
          // 自定义内容
          this.customList()
        }else{
          List({ space: 8 }) {
            // 列表里的自定义内容
            if (this.customItem) {
              ListItemGroup() {
                this.customItem()
              }.listItemGroup().backgroundColor(this.listItemBgColor)
            }

            if (this.gList) {
              this.SettingListItem()
            }
          }.scrollBar(BarState.Off).width('100%').height('100%').edgeEffect(EdgeEffect.Spring)
          .contentEndOffset(CONTENT_END_OFFSET)
        }
      }.padding({left: PADDING_VALUE_16+5, right: PADDING_VALUE_16+5})
      .borderRadius({ topLeft: this.sideBarPosition == SideBarPosition.Start ? 0 : 24,
        topRight: this.sideBarPosition == SideBarPosition.Start ? 24 : 0,
        bottomLeft: this.sideBarPosition == SideBarPosition.Start ? 0 : 24,
        bottomRight: this.sideBarPosition == SideBarPosition.Start ? 24 : 0 })
      .width('100%').height('100%').backgroundColor($r('sys.color.background_fourth'))
    }.height('100%').width(320)
    .showSideBar(this.isShowSideBar)
    .showControlButton(false)
    .sideBarWidth(320)
    .sideBarPosition(this.sideBarPosition)
    .transition(this.sideBarPosition == SideBarPosition.Start ? Xb_AnimationStyle.isMoveSettings(0) : Xb_AnimationStyle.isMoveSettings2(0))
  }

  aboutToAppear(): void {
    Xb_AnimationStyle.setContext(this.getUIContext())
  }

  //list标题组件
  @Builder
  ListTitle(t: ResourceStr){
    Xb_TopTitleBar({
      name: t,
      animationUse: false,
      fontColor: $r("sys.color.font_on_tertiary"),
      fontSize: 16,
      icon1: undefined,
      icon2: undefined,
      paddingValue: 0,
      isBackPress: false,
    })
  }

  // 使用Xb_SettingsGroupData时的gList
  @Builder
  SettingListItem(){
    ForEach(this.gList, (gItem: Xb_SettingsGroupData, gIndex: number) => {
      if (gItem.group) {
        ListItemGroup({ header: this.ListTitle(gItem.group.id) })
      }

      ListItemGroup() {
        ForEach(gItem.items, (lItem: Xb_SettingsItemData, index: number) => {
          Xb_SettingsItem({
            item: lItem,
            themeType: ThemeType.Auto,
          }).padding({top: PADDING_VALUE_12, bottom: PADDING_VALUE_12})
        })
      }.listItemGroup().backgroundColor(this.listItemBgColor)
    })
  }
}

//分组list样式
@Extend(ListItemGroup)
function listItemGroup(){
  .borderRadius(BORDER_RADIUS_24)
  .padding({left: 2, right: 2})
  .backgroundColor($r("app.color.settings_list_background"))
  .divider({ color: $r("app.color.divider_light"),
    strokeWidth: 1,})
}