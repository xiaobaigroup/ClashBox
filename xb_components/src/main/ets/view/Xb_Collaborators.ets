import { Xb_TopTitleBar } from "../components/Xb_TopTitleBar";
import { Xb_IconLogo } from "../components/Xb_IconLogo";
import { BORDER_RADIUS_24, PADDING_VALUE_12, PADDING_VALUE_16 } from "../components/Constants";
import { SettingsItem, SettingsGroup, RightStyle } from "../settings/SettingsCommonOp";
import { customVibrator } from "../utils/Vibrator";
import { KeyCode } from "@kit.InputKit";
import { Xb_AnimationStyle } from "../utils/Animation";
import { Xb_GoToWeb } from "../utils/JumpTo";
import { XbCollaboratorsNavInfo } from "../entity/Common";
import { colorChange } from "../components/Common";
import { IntroduceItem } from "./Xb_IntroduceItem";


// 系统路由-协作者页
@Builder
export function XbCollaboratorsBuilder(name: string) {
  Xb_Collaborators()
}

/**
 * 协作者页
 */
@ComponentV2
export struct Xb_Collaborators {

  @Local navNeedClose: boolean = true
  @Local navTopIconSize: number = 24
  @Local navAppName: ResourceStr = ''
  @Local navAppNameEng: ResourceStr = ''
  @Local navProjectList?: SettingsItem[] = undefined
  @Local navDeveloperList?: SettingsItem[] = undefined
  @Local thePageInfo: NavPathStack = new NavPathStack()
  @Local navAppLogo: Resource = $rawfile('xbStudio.jpg')
  @Local navPageBackgroundColor: ResourceColor = $r('app.color.start_window_background')
  @Local navTopButtonColor?: ResourceColor = colorChange.color1
  @Local navItemBackgroundCorlor?: ResourceColor = $r("app.color.bind_sheet_list_background")

  @Param showTopTitle: boolean = true
  @Param route?: NavPathStack = undefined

  @Param needClose: boolean = true
  @Param topIconSize: number = 24
  @Param appName?: ResourceStr = undefined
  @Param appNameEng?: ResourceStr = undefined
  @Param projectList?: SettingsItem[] = undefined
  @Param developerList?: SettingsItem[] = undefined
  @Param appLogo?: Resource = $rawfile('xbStudio.jpg')
  @Param ItemBackgroundCorlor?: ResourceColor = undefined
  @Param topButtonColor?: ResourceColor = colorChange.color1
  @Param pageBackgroundColor: ResourceColor = $r('app.color.start_window_background')

  @Event onClose: () => void

  build() {
    NavDestination() {
      List({ space:10 }) {
        // 应用展示区
        ListItem() {
          Xb_IconLogo({
            icon: this.navAppLogo,
            text1: this.navAppName,
            text2: this.navAppNameEng,
            text3: ''
          })
        }.padding({top: 32, bottom: 12})
        // 协作者列表
        ForEach(this.getCollaboratorsList(this.navDeveloperList, this.navProjectList), (group: SettingsGroup) => {
          ListItemGroup({ header: this.Title(group.title) })
            .padding({top: 16})
          ListItemGroup(){
            ForEach(group.items, (ri: SettingsItem)=>{
              ListItem() { IntroduceItem({ item: ri }) }
              .clickEffect(Xb_AnimationStyle.isClick())
              .onClick(() => {
                if ( ri.onClick) ri.onClick()
              })
            }, (item: SettingsItem) => item.id)
          }
          .listItemGroup(this.navItemBackgroundCorlor)
        })

      }
      .width('100%')
      .contentEndOffset(82)
      .scrollBar(BarState.Off)
      .padding({ left: PADDING_VALUE_16, right: PADDING_VALUE_16 })
      .nestedScroll({
        scrollForward: NestedScrollMode.SELF_ONLY,
        scrollBackward: NestedScrollMode.SELF_ONLY
      })
    }
    .id('Collaborators')
    .onBackPressed(() => {
        this.thePageInfo.pop();
        return true
    })
    .onKeyEvent((e: KeyEvent)=>{
      if (e) {
        if (e.keyCode == KeyCode.KEYCODE_ESCAPE && e.type === KeyType.Down) {
          this.thePageInfo.pop();
        }
      }
    })
    .width('100%')
    .height('100%')
    .title($r("app.string.xb_collaborators"))
    .padding({ top: !this.route ? 8 : 0 })
    .backgroundColor(this.navPageBackgroundColor)
    .hideTitleBar(!this.showTopTitle)
    .onReady((ctx) => {
      // 作为组件使用时的初始化
      this.asComponentInit()
      if (this.route) {
        this.thePageInfo = this.route
        return
      }
      // 系统路由使用时的初始化
      const stack = ctx.pathStack
      if (stack) {
        this.thePageInfo = stack
        try {
          const ctxParam: XbCollaboratorsNavInfo = ctx.pathInfo.param as XbCollaboratorsNavInfo
          console.log('XbCollaborators#onReady 协作者页接收的ctxParam：', ctxParam)
          this.asRouteInit(ctxParam)
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
      fontColor: $r("sys.color.font_on_tertiary"),
      fontSize: 16,
      paddingValue: 14.5,
      isBackPress: false
    })
  }

  getCollaboratorsList(developers?: SettingsItem[], projects?: SettingsItem[]): SettingsGroup[] {
    return [
      {
        title: $r('app.string.xb_developer'),
        items: [
          { id: 'xbstudio', icon: $rawfile('xbStudio.jpg'), contentR: 'GitHub', rightStyle: RightStyle.BUTTON,
            contentL: $r('app.string.xb_studio'), onClick: () => { Xb_GoToWeb('https://github.com/xiaobaigroup') } },
          ...(developers ? developers : [])
        ]
      },
      ...(projects ? [{
        title: $r('app.string.xb_reference_excellent_project'),
        items: [
          ...(projects ? projects : [])
        ]
      } as SettingsGroup ] : []),
    ]
  }

  asComponentInit() {
    this.navNeedClose = this.needClose
    this.navTopIconSize = this.topIconSize
    this.navTopButtonColor = this.topButtonColor
    this.navPageBackgroundColor = this.pageBackgroundColor
    if (this.appName) {
      this.navAppName = this.appName
    }
    if (this.appNameEng) {
      this.navAppNameEng = this.appNameEng
    }
    if (this.projectList) {
      this.navProjectList = this.projectList
    }
    if (this.developerList) {
      this.navDeveloperList = this.developerList
    }
    if (this.appLogo) {
      this.navAppLogo = this.appLogo
    }
    if (this.ItemBackgroundCorlor) {
      this.navItemBackgroundCorlor = this.ItemBackgroundCorlor
    }
  }

  asRouteInit(params: XbCollaboratorsNavInfo) {
    this.navAppLogo = params.appLogo
    this.navAppName = params.appName
    this.navAppNameEng = params.appNameEng
    this.navNeedClose = params.needClose
    this.navTopIconSize = params.iconSize
    this.navTopButtonColor = params.topButtonColor
    this.navItemBackgroundCorlor = params.itemBackgroundCorlor
    this.navPageBackgroundColor = params.pageBackgroundColor
    this.navDeveloperList = params.developer
    this.navProjectList = params.project
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