import { PADDING_VALUE_12 } from "../components/Constants"
import { Xb_SettingsItem } from "../components/Xb_SettingItem"
import { ThemeType } from "../entity/Common"
import { makeSettingsGroupData, Xb_SettingsGroupData, Xb_SettingsItemData } from "../model/SettingsItem"

@ComponentV2
export struct Xb_SettingsGroup {

  @Require @Param items: Xb_SettingsItemData[]
  @Param space: number | string = "5vp"
  @Param themeType: ThemeType = ThemeType.Auto

  @Local groups: Xb_SettingsGroupData[] = []

  @BuilderParam dialogContent?: (data: Xb_SettingsItemData) => void

  aboutToAppear(): void {
    this.groups = makeSettingsGroupData(this.items)
  }

  @Monitor("items")
  updateGroup(){
    this.groups = makeSettingsGroupData(this.items)
  }
  @LocalBuilder
  title(g: Xb_SettingsGroupData){
    Text(g.group?.label ?? "").fontSize(16).fontColor( $r("app.color.text_input_placeholder")).padding({top:14, bottom:14})
  }

  build() {
    List({ space: "10vp" }){
      ForEach(this.groups,(g: Xb_SettingsGroupData, i: number)=>{
        ListItemGroup({ header: this.title(g), space: this.space}){
          ForEach(g.items,(ri: Xb_SettingsItemData, i: number)=>{
            ListItem() {
              Xb_SettingsItem({
                item: ri,
                themeType: this.themeType,
                dialogContent: (d) => {
                  if (this.dialogContent)
                    this.dialogContent(d)
                }
              })
            }
          },(item: Xb_SettingsItemData) => JSON.stringify(item))
        }.listItemGroup()
      },(item: Xb_SettingsGroupData) => JSON.stringify(item))
    }
    .nestedScroll({
      scrollForward: NestedScrollMode.SELF_ONLY,
      scrollBackward: NestedScrollMode.SELF_ONLY
    })
  }
}

// 分组list样式
@Extend(ListItemGroup)
function listItemGroup(){
  .borderRadius(24)
  .padding({left: PADDING_VALUE_12, right: PADDING_VALUE_12, bottom: 5})
  // .backgroundColor($r("app.color.settings_switch_button_floor"))
  .divider({ color: $r("app.color.divider_light"),
    strokeWidth: 1,})
}