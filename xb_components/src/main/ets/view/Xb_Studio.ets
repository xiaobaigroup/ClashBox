import { Xb_TopTitleBar } from "../components/Xb_TopTitleBar";
import { Xb_IconLogo } from "../components/Xb_IconLogo";
import { contributorList } from "../settings/ContributorListOp";
import { BORDER_RADIUS_24, CONTENT_END_OFFSET, PADDING_VALUE_12, PADDING_VALUE_16 } from "../components/Constants";
import { SettingsItem } from "../settings/SettingsCommonOp";
import { KeyCode } from "@kit.InputKit";
import { Xb_AnimationStyle } from "../utils/Animation";
import { Xb_GetResourceString } from "../utils/ResourceStringUtil";
import { XbStudioNavInfo } from "../entity/Common";
import { IntroduceItem } from "./Xb_IntroduceItem";

// 系统路由-小白工坊
@Builder
export function XbStudioBuilder(name: string) {
  Xb_Studio()
}


/**
 * 小白工坊介绍页
 */
@ComponentV2
export struct Xb_Studio {

  @Local navIconSize: number = 24
  @Local topRect?: Length = undefined
  @Local navPageBackgroundColor: ResourceColor = $r('app.color.start_window_background')
  @Local navItemBackgroundCorlor?: ResourceColor = $r("app.color.bind_sheet_list_background")

  @Param showTopTitle: boolean = true
  @Param route?: NavPathStack = undefined
  @Param topRectHeight?: Length = undefined
  @Param ItemBackgroundColor?: ResourceColor = undefined
  @Param PageBackgroundColor?: ResourceColor = $r('app.color.start_window_background')

  private thePageInfo: NavPathStack = new NavPathStack()

  build() {
    NavDestination() {
      List({ space:10 }) {
        ListItem() {
          Xb_IconLogo({
            icon: $rawfile('xbStudio.jpg'),
            text1: '小白工坊',
            text2: 'Xiaobai Studio',
            text3: $r("app.string.xb_introduce")
          })
        }.padding({top: 32, bottom: 22})

        ListItemGroup({ header: this.Title($r("app.string.xb_member")) })
          .padding({top: 16})
        ListItemGroup(){
          ForEach(contributorList.contributorList1,(ri: SettingsItem)=>{
              ListItem() {
                IntroduceItem({ item: ri })
              }
            }, (item: SettingsItem) => Xb_GetResourceString(item.contentL, this))
        }
        .listItemGroup(this.navItemBackgroundCorlor)

        ListItemGroup({ header: this.Title($r("app.string.xb_app")) })
          .padding({top: 16})
        ListItemGroup(){
          ForEach(contributorList.contributorList2,(ri: SettingsItem)=>{
              ListItem() {
                IntroduceItem({ item: ri })
              }
            }, (item: SettingsItem) => Xb_GetResourceString(item.contentL, this))
        }
        .listItemGroup(this.navItemBackgroundCorlor)

        ListItemGroup({ header: this.Title($r("app.string.xb_sponsor_contact")) })
          .padding({top: 16})
        ListItemGroup(){
          ForEach(contributorList.contributorList3,(ri: SettingsItem)=>{
            ListItem() {
              IntroduceItem({ item: ri })
            }
            .clickEffect(Xb_AnimationStyle.isClick())
            .onClick(()=>{
              if ( ri.onClick) ri.onClick()
            })
          }, (item: SettingsItem) => Xb_GetResourceString(item.contentL, this))
        }
        .listItemGroup(this.navItemBackgroundCorlor)
      }
      .width('100%')
      .contentEndOffset(CONTENT_END_OFFSET)
      .padding({ left: PADDING_VALUE_16, right: PADDING_VALUE_16 })
      .scrollBar(BarState.Off)
      .nestedScroll({
        scrollForward: NestedScrollMode.SELF_ONLY,
        scrollBackward: NestedScrollMode.SELF_ONLY
      })
    }
    .id('xb_studio')
    .onKeyEvent((e: KeyEvent) => {
      if (e){
        if (e.keyCode == KeyCode.KEYCODE_ESCAPE && e.type === KeyType.Down) {
          this.thePageInfo.pop();
        }
      }
    })
    .width('100%')
    .height('100%')
    .title($r("app.string.xb_about_xb_studio"))
    .padding({ top: this.topRect || (!this.route ? 8 : 0) })
    .backgroundColor(this.navPageBackgroundColor)
    .onReady((ctx) => {
      if (this.PageBackgroundColor) {
        this.navPageBackgroundColor = this.PageBackgroundColor
      }
      if (this.ItemBackgroundColor) {
        this.navItemBackgroundCorlor = this.ItemBackgroundColor
      }
      if (this.route) {
        this.thePageInfo = this.route
        return
      }
      if (this.topRectHeight) {
        this.topRect = this.topRectHeight
      }
      const stack = ctx.pathStack
      if (stack) {
        this.thePageInfo = stack
        try {
          const ctxParam: XbStudioNavInfo = ctx.pathInfo.param as XbStudioNavInfo
          console.log('XbStudio#onReady 小白工坊页接收的ctxParam：', ctxParam)
          this.navItemBackgroundCorlor = ctxParam.itemBackgroundColor
          this.navPageBackgroundColor = ctxParam.pageBackgroundColor
          this.topRect = ctxParam.topRectHeight
        } catch (e) {
          console.log(`XbStudio#onReady Navigate onReady catch exception: ${JSON.stringify(e)}`)
        }
      }
    })
  }

  // 标题组件
  @Builder
  Title(t: ResourceStr){
    Xb_TopTitleBar({
      name: t,
      animationUse: false,
      fontColor: $r("sys.color.font_tertiary"),
      fontSize: 16,
      paddingValue: 14.5,
      isBackPress: false
    })
  }
}

// 分组list样式
@Extend(ListItemGroup)
function listItemGroup(ItemBackgroundCorlor?: ResourceColor) {
  .borderRadius(BORDER_RADIUS_24)
  .padding({left: PADDING_VALUE_12, right: PADDING_VALUE_12})
  .backgroundColor(ItemBackgroundCorlor ?? $r("app.color.bind_sheet_list_background"))
  .divider({ color: $r("app.color.divider_light"),
    strokeWidth: 1,})
   // startMargin: PADDING_VALUE_12,
  //  endMargin: PADDING_VALUE_12})
}