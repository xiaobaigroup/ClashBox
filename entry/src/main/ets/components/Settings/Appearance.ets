import { BreakpointState } from "../../common/breakpoint/breakpointsystem"
import {
  ANIMATION_DURATION_100,
  ANIMATION_DURATION_300,
  ANIMATION_DURATION_500,
  AppearanceList,
  AppearanceListItemProp,
  CONTENT_END_OFFSET_150,
} from "../../common/entity/Constants"
import TopBuilder from "./TopBuilder"
import { curves, SymbolGlyphModifier } from "@kit.ArkUI"
import { common } from "@kit.AbilityKit"
import { font_primary, menuRowList, toggleRowList } from "../Common/Common"
import { UIConfig } from "../../entryability/AppState"
import { customAnimationUtil } from "../../common/utils/Animation"
import { PageMargin } from "../../common/breakpoint/BreakPoint"
import { Xb_ColorModeManager, Xb_UIConfig } from "xb_components"
import { Xb_ChangeThemeColor } from "xb_components/src/main/ets/utils/ChangeThemeColorUtil"

const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

@Component
struct Appearance {

  // 按钮宽度
  @State proxyStartButtonWidth: Length = $r('app.integer.vp_proxy_not_start_button_width')
  // 按钮高度
  @State proxyStartButtonHeight: Length = $r('app.integer.vp_proxy_not_start_button_height')
  // 深色模式选中文本
  @State EnableDarkModeText: ResourceStr = $r('app.string.follow_system')
  // 主题色选中文本
  @State EnableThemeColorText: ResourceStr = $r('app.string.xb_star_river_blue')
  // 动画速度选中文本
  @State EnableAnimationSpeedText: ResourceStr = $r('app.string.normal')
  // 字符串显示权重选中文本
  @State EnableStringDisplayText: ResourceStr = $r('app.string.appearance')
  // 关闭窗口选中文本
  @State EnableCloseWindowText: ResourceStr = $r('app.string.appearance')
  // 按钮位置选中文本
  @State EnableButtonPositionText: ResourceStr = $r('app.string.right')
  // 列表
  @State appearanceList: AppearanceListItemProp[] = AppearanceList

  // 按钮位置偏移量（默认在右侧的偏移量）
  @Consume ButtonPositionOffset: number
  // 实验功能提示框展示变量
  @Consume isShowExperimentalFunction: boolean
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 所有子组件在容器内的对齐方式
  @Consume ('stackAlignContentAlignment') stackAlignContentAlignment: Alignment

  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 窗口模式
  @StorageProp('WindowMode') windowMode: boolean = false
  // 手机横屏判断
  @StorageLink ('isLandscapePhone') isLandscapePhone: boolean = false
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0


  build() {
    NavDestination() {
      // 顶部导航区
      TopBuilder({title: $r('app.string.Appearance')})
      // 功能区
      List({ space: 10 }) {
        // 预览区
        ListItem() {
          Stack({ alignContent: this.stackAlignContentAlignment }) {
            // 单选框预览区
            Column({space: 10}) {
              Row({space: 9}) {
                Text($r('app.string.color_preview'))
                  .width(80)
                  .fontWeight(FontWeight.Bold)
                  .fontSize(16)
                  .fontColor(font_primary)
                Radio({ value: 'preview', group: 'appearanceRadioGroup', })
                  .checked(true)
                  .radioStyle({
                    checkedBackgroundColor: this.icon_emphasize,
                  })
              }
              Row({space: 9}) {
                Text($r('app.string.configuration_1'))
                  .fontWeight(FontWeight.Bold)
                  .width(80)
                  .fontSize(16)
                  .fontColor(font_primary)
                Radio({ value: 'config', group: 'appearanceRadioGroup', })
                  .checked(false)
                  .radioStyle({
                    checkedBackgroundColor: this.icon_emphasize,
                  })
              }
              Row({space: 9}) {
                Text($r('app.string.proxy_1'))
                  .fontWeight(FontWeight.Bold)
                  .width(80)
                  .fontSize(16)
                  .fontColor(font_primary)
                Radio({ value: 'proxy', group: 'appearanceRadioGroup', })
                  .checked(false)
                  .radioStyle({
                    checkedBackgroundColor: this.icon_emphasize,
                  })
              }
            }
            .width(188)
            .borderRadius(20)
            .backdropBlur(2)
            .alignItems(HorizontalAlign.Start)
            .backgroundColor($r('app.color.container_background'))
            .padding({ left: 16, top: 15, bottom: 15 })
            .shadow({
              color: '#1a000000',
              radius: 60,
              type: ShadowType.COLOR
            })

            // 按钮预览区
            Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
              SymbolGlyph($r('sys.symbol.play_fill'))
                .fontSize(24)
                .fontColor([Color.White])
            }
            .offset({x:this.ButtonPositionOffset ,y: 13})
            .borderRadius(100)
            .backgroundColor(this.icon_emphasize)
            .shadow({
              radius: 10,
              color: this.icon_emphasize,
              offsetY: 4,
              type: ShadowType.BLUR
            })
            .width(this.proxyStartButtonHeight)
            .height(this.proxyStartButtonHeight)
          }
        }.width('100%').margin({top: 20, bottom: 15})
        .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
        // 列表区 Start
        ListItem() {
          Column() {
            // 主题色
            menuRowList({
              icons: $r('sys.symbol.paintpalette_fill'),
              title: $r('app.string.theme_color'),
              // 确保this指向父组件
              tips: (): void => { this.TipsText(0) },
              menu: (): void => { this.MenuEntrance(0) }
            })
            // 分割线
            Row().height(0.5).backgroundColor($r('app.color.divider')).width('93%')
            // 深色模式
            menuRowList({
              icons: $r('sys.symbol.circle_righthalf_inset_filled'),
              title: $r('app.string.dark_mode'),
              // 确保this指向父组件
              tips: (): void => { this.TipsText(1) },
              menu: (): void => { this.MenuEntrance(1) }
            })
            // 分割线
            Row().height(0.5).backgroundColor($r('app.color.divider')).width('93%')
            // 背景模糊
            Row() {
              toggleRowList({
                icons: $r('sys.symbol.rectangle_on_rectangle_fill'),
                title: $r('app.string.blurred_background'),
                subtitle: $r('app.string.blurred_background_subtitle'),
              }) {
                // 背景模糊开关
                Toggle({ type: ToggleType.Switch, isOn: this.uiConfig.isBlurr })
                  .selectedColor(this.icon_emphasize)
                  .hitTestBehavior(HitTestMode.None)
                  .margin({right: 12})
              }
            }.onClick(()=> {
              // 打开背景模糊 显式动画
              this.getUIContext()?.animateTo({
                duration: this.uiConfig.animationSpeed
              }, () => {
                this.uiConfig.isBlurr = !this.uiConfig.isBlurr
              })
            })
            // 分割线
            Row().height(0.5).backgroundColor($r('app.color.divider')).width('93%')
            // 动画速度
            menuRowList({
              icons: $r('sys.symbol.livephoto'),
              title: $r('app.string.animation_speed'),
              subtitle: $r('app.string.animation_speed_subtitle'),
              isExperimentalFunction: false,
              // 确保this指向父组件
              tips: (): void => { this.TipsText(3) },
              menu: (): void => { this.MenuEntrance(3) }
            })
          }
          .width('100%')
          .borderRadius(20)
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .backgroundColor($r('app.color.container_background'))
        }
        ListItem() {
          Column() {
            // 主页问候
            Row() {
              toggleRowList({
                icons: $r('sys.symbol.message'),
                title: $r('app.string.homepage_greetings'),
                subtitle: $r('app.string.homepage_greetings_subtitle'),
              }) {
                // 主页问候开关
                Toggle({ type: ToggleType.Switch, isOn: $$this.uiConfig.isGreeting })
                  .selectedColor(this.icon_emphasize)
                  .hitTestBehavior(HitTestMode.None)
                  .margin({right: 12})
              }
            }.onClick(()=> {
              // 打开主页问候 显式动画
              this.getUIContext()?.animateTo({
                duration: ANIMATION_DURATION_300
              }, () => {
                this.uiConfig.isGreeting = !this.uiConfig.isGreeting
              })
            })
            // 分割线
            Row().height(0.5).backgroundColor($r('app.color.divider')).width('93%')
            // 悬浮按钮位置
            menuRowList({
              icons: $r('sys.symbol.local_fill'),
              title: $r('app.string.suspension_button_position'),
              // 确保this指向父组件
              tips: (): void => { this.TipsText(2) },
              menu: (): void => { this.MenuEntrance(2) }
            })
            // 分割线
            Row().height(0.5).backgroundColor($r('app.color.divider')).width('93%')
            // 字符串显示权重
            menuRowList({
              icons: $r('sys.symbol.list_square_bill'),
              title: $r('app.string.string_display_preferences'),
              // 确保this指向父组件
              tips: (): void => { this.TipsText(4) },
              menu: (): void => { this.MenuEntrance(4) }
            })
            if (this.windowMode) {
              // 分割线
              Row().height(0.5).backgroundColor($r('app.color.divider')).width('93%')
              // 关闭窗口
              menuRowList({
                icons: $r('sys.symbol.wrench_and_screwdriver'),
                title: $r('app.string.exit_window'),
                // 确保this指向父组件
                tips: (): void => { this.TipsText(5) },
                menu: (): void => { this.MenuEntrance(5) }
              })
            }
          }
          .width('100%')
          .borderRadius(20)
          .backgroundColor($r('app.color.container_background'))
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
        }
        // 列表区 End
      }
      .width('100%')
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)
      .contentEndOffset(CONTENT_END_OFFSET_150 - 85)
      .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp), bottom: PageMargin(this.widthBp, this.heightBp) })

    }
    .width('100%')
    .backgroundColor($r('app.color.background'))
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.SettingsPageInfos.clear();
      return true;
    })

  }

  // 切换菜单
  @Builder
  switchMenu(item: AppearanceListItemProp[], index: number) {
    if(index === 0) {
      // 切换深色模式
      Menu() {
        ForEach(item, (menuItem: AppearanceListItemProp, index: number) => {
          MenuItem({
            content: menuItem.title,
            symbolEndIcon: this.uiConfig.darkMode === menuItem.colorMode ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
          })
          .onChange((selected) => {
            // 持久化深色模式
            this.uiConfig.darkMode = menuItem.colorMode!
            Xb_ColorModeManager.setColorModeByString(context, this.uiConfig.darkMode)
            // UI刷新
            this.EnableDarkModeText = menuItem.title
          })
        }, (menuItem: AppearanceListItemProp) => JSON.stringify(menuItem))
      }
    } else if(index === 1) {
      // 切换主题色
      Menu() {
        ForEach(item, (menuItem: AppearanceListItemProp, index: number) => {
          MenuItem({
            content: menuItem.title,
            symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.paintpalette_fill')).fontColor(menuItem.startSymbolFontColor),
            symbolEndIcon: this.uiConfig.themeColorIndex === index ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
          })
          .selected(this.uiConfig.themeColorIndex === index)
          .onChange((selected) => {
            this.uiConfig.themeColorIndex = index
            // 持久化主题色
            this.uiConfig.themeColor = menuItem?.customThemeName ?? 'yellowAppTheme'
            Xb_UIConfig.themeColor = menuItem?.customThemeName ?? 'yellowAppTheme'
            Xb_ChangeThemeColor(this.uiConfig.themeColor)
            // UI刷新
            this.EnableThemeColorText = menuItem.title
          })
        }, (menuItem: AppearanceListItemProp) => JSON.stringify(menuItem))
      }
    } else if (index === 2) {
      // 切换按钮位置
      Menu() {
        ForEach(item, (menuItem: AppearanceListItemProp, index: number) => {
          MenuItem({
            content: menuItem.title,
            symbolEndIcon: this.uiConfig.buttonPositionIndex === index ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
          })
            .selected(this.uiConfig.buttonPositionIndex === index)
            .onChange((selected) => {
              animateTo(this.uiConfig.isAnimation?{ duration: this.uiConfig.animationSpeed, curve: curves.springMotion() }:null, () => {
                // 持久化按钮位置
                this.uiConfig.buttonPositionIndex = index
                this.switchButtonPosition(index)
              })
              // UI刷新
              this.EnableButtonPositionText = menuItem.title
            })
        }, (menuItem: AppearanceListItemProp) => JSON.stringify(menuItem))
      }
    } else if (index === 3) {
      // 切换动画速度
      Menu() {
        ForEach(item, (menuItem: AppearanceListItemProp, index: number) => {
          MenuItem({
            content: menuItem.title,
            symbolEndIcon: this.uiConfig.animationSpeedIndex === index ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
          })
            .selected(this.uiConfig.animationSpeedIndex === index)
            .onChange((selected) => {
              // 持久化动画速度
              this.uiConfig.animationSpeedIndex = index
              this.switchAnimationSpeed(index)
              // UI刷新
              this.EnableAnimationSpeedText = menuItem.title
            })
        }, (menuItem: AppearanceListItemProp) => JSON.stringify(menuItem))
      }
    } else if (index === 4) {
      // 切换字符显示权重
      Menu() {
        ForEach(item, (menuItem: AppearanceListItemProp, index: number) => {
          MenuItem({
            content: menuItem.title,
            symbolEndIcon: this.uiConfig.stringDisplayIndex === index ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
          })
            .selected(this.uiConfig.stringDisplayIndex === index)
            .onChange((selected) => {
              // 持久化字符显示权重
              this.uiConfig.stringDisplayIndex = index
              // UI刷新
              this.EnableStringDisplayText = menuItem.title
            })
        }, (menuItem: AppearanceListItemProp) => JSON.stringify(menuItem))
      }
    } else if (index === 5) {
      // 关闭窗口
      Menu() {
        ForEach(item, (menuItem: AppearanceListItemProp, index: number) => {
          MenuItem({
            content: menuItem.title,
            symbolEndIcon: this.uiConfig.stringDisplayIndex === index ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
          })
            .selected(this.uiConfig.stringDisplayIndex === index)
            .onChange((selected) => {
              // 持久化关闭窗口模式
              this.uiConfig.exitWindowMode = index
              // UI刷新
              this.EnableCloseWindowText = menuItem.title
            })
        }, (menuItem: AppearanceListItemProp) => JSON.stringify(menuItem))
      }
    }
  }

  @Builder
  TipsText(index: number) {
    if (index === 0) {
      // 主题色
      Text(this.EnableThemeColorText)
        .tipsText()
    } else if (index === 1) {
      // 深色模式
      Text(this.EnableDarkModeText)
        .tipsText()
    } else if (index === 2) {
      // 按钮位置
      Text(this.EnableButtonPositionText)
        .tipsText()
    } else if (index === 3) {
      // 动画速度
      Text(this.EnableAnimationSpeedText)
        .tipsText()
    } else if (index === 4) {
      // 字符显示权重
      Text(this.EnableStringDisplayText)
        .tipsText()
    } else if (index === 5) {
      // 关闭窗口
      Text(this.EnableCloseWindowText)
        .tipsText()
    }
  }

  @Builder
  MenuEntrance(index: number) {
    if (index === 0) {
      // 主题色
      // 确保children存在
      if(this.appearanceList && this.appearanceList[1].children) {
        this.switchMenu(this.appearanceList[1].children, 1)
      }
    } else if (index === 1) {
      // 深色模式
      // 确保children存在
      if(this.appearanceList && this.appearanceList[0].children) {
        this.switchMenu(this.appearanceList[0].children, 0)
      }
    } else if (index === 2) {
      // 按钮位置
      // 确保children存在
      if(this.appearanceList && this.appearanceList[2].children) {
        this.switchMenu(this.appearanceList[2].children, 2)
      }
    } else if (index === 3) {
      // 动画速度
      // 确保children存在
      if(this.appearanceList && this.appearanceList[3].children) {
        this.switchMenu(this.appearanceList[3].children, 3)
      }
    } else if (index === 4) {
      // 字符显示权重
      // 确保children存在
      if(this.appearanceList && this.appearanceList[4].children) {
        this.switchMenu(this.appearanceList[4].children, 4)
      }
    } else if (index === 5) {
      // 关闭窗口
      // 确保children存在
      if(this.appearanceList && this.appearanceList[5].children) {
        this.switchMenu(this.appearanceList[5].children, 5)
      }
    }
  }

  // 切换按钮位置
  switchButtonPosition(index:number) {
    switch (index) {
      case 0:
        // 右侧
        this.ButtonPositionOffset = 16
        this.stackAlignContentAlignment = Alignment.BottomEnd
        break
      case 1:
        // 中间
        this.ButtonPositionOffset = 0
        this.stackAlignContentAlignment = Alignment.Bottom
        break
      case 2:
        // 左侧
        this.ButtonPositionOffset = -16
        this.stackAlignContentAlignment = Alignment.BottomStart
        break
    }
  }

  // 切换动画速度
  switchAnimationSpeed(index: number) {
    switch (index) {
      case 0:
        // 快速
        this.uiConfig.isAnimation = true
        this.uiConfig.animationSpeed = ANIMATION_DURATION_100
        break
      case 1:
        // 正常
        this.uiConfig.isAnimation = true
        this.uiConfig.animationSpeed = ANIMATION_DURATION_300
        break
      case 2:
        // 慢速
        this.uiConfig.isAnimation = true
        this.uiConfig.animationSpeed = ANIMATION_DURATION_500
        break
      case 3:
        // 关闭
        this.uiConfig.isAnimation = false
        this.uiConfig.animationSpeed = 0
        break
    }
  }

  aboutToAppear(): void {
    // 初始化主题色显示文本
    if (this.appearanceList && this.appearanceList[1].children) {
      this.EnableThemeColorText = this.appearanceList[1].children[this.uiConfig.themeColorIndex].title
    }
    // 初始化深色模式显示文本
    if (this.appearanceList && this.appearanceList[0].children) {
      this.EnableDarkModeText = this.appearanceList[0].children.find(child => child.colorMode === this.uiConfig.darkMode)?.title!
    }
    // 初始化按钮位置显示文本
    if (this.appearanceList && this.appearanceList[2].children) {
      this.EnableButtonPositionText = this.appearanceList[2].children[this.uiConfig.buttonPositionIndex].title
    }
    // 初始化动画速度显示文本
    if (this.appearanceList && this.appearanceList[3].children) {
      this.EnableAnimationSpeedText = this.appearanceList[3].children[this.uiConfig.animationSpeedIndex].title
    }
    // 初始化字符显示权重显示文本
    if (this.appearanceList && this.appearanceList[4].children) {
      this.EnableStringDisplayText = this.appearanceList[4].children[this.uiConfig.stringDisplayIndex].title
    }
    // 窗口模式时才处理
    if (this.windowMode) {
      // 初始化关闭窗口显示文本
      if (this.appearanceList && this.appearanceList[5].children) {
        this.EnableCloseWindowText = this.appearanceList[5].children[this.uiConfig.exitWindowMode].title
      }
    }
  }

  aboutToDisappear(): void {

  }

}

export default Appearance

@Extend(Text)
function tipsText() {
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .fontColor($r('sys.color.font_secondary'))
  .fontWeight(FontWeight.Normal)
  .margin({top: 2 })
  .fontSize(14)
  .maxLines(1)
}
