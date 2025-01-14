import { BreakpointState } from "../../common/breakpointsystem"
import {
  ANIMATION_DURATION_300,
  AppearanceList,
  AppearanceListItemProp,
} from "../../common/Constants"
import TopBuilder from "./TopBuilder"
import { SymbolGlyphModifier, ThemeControl } from "@kit.ArkUI"
import { CustomThemeName, CUSTOM_THEME_MAP } from "../../common/AppTheme"
import { common } from "@kit.AbilityKit"
import { setAutoColorMode, setDarkColorMode, setLightColorMode } from "../../common/ColorModeChangeFunctions"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { menuRowList, toggleRowList } from "../Common"

@Component
struct Appearance {
  // 实验功能提示框展示变量
  @Consume isShowExperimentalFunction: boolean
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  @State appearanceList: AppearanceListItemProp[] = AppearanceList
  /* 主题色 */
  @State font_primary: ResourceColor = $r('sys.color.font_primary')
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  // 深色模式选中
  @StorageProp('enableDarkMode') enableDarkMode: boolean = false;
  // 是否跟随系统
  @StorageProp('isFollowSystemSetting') isFollowSystemSetting: boolean = true;
  // 当前主题颜色模式
  @StorageProp('currentColorMode') currentColorMode: number = 0;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  // 断点系统
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>
  // 手机横屏判断
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  // 滚动列表高度
  @Consume('breakPointStateSettingslistHeight') private SettingslistHeight: BreakpointState<number>
  // 按钮宽度
  @State private proxyStartButtonWidth: Length = $r('app.integer.vp_proxy_not_start_button_width')
  // 按钮高度
  @State private proxyStartButtonHeight: Length = $r('app.integer.vp_proxy_not_start_button_height')
  // 深色模式选中序号
  @State EnableDarkMode: number = 0
  // 深色模式选中文本
  @State EnableDarkModeText: ResourceStr = $r('app.string.follow_system')
  // 主题色选中序号
  @State EnableThemeColor: number = 0
  // 主题色选中文本
  @State EnableThemeColorText: ResourceStr = $r('app.string.star_river_blue')
  // 按钮位置选中序号
  @State EnableButtonPosition: number = 0
  // 按钮位置选中文本
  @State EnableButtonPositionText: ResourceStr = $r('app.string.right')
  // 按钮位置偏移量（默认在右侧的偏移量）
  @State ButtonPositionOffset: number = 0
  // 所有子组件在容器内的对齐方式
  @Consume ('stackAlignContentAlignment') stackAlignContentAlignment: Alignment
  // 背景模糊启用变量
//  @State isBlurr: boolean= false
  @Consume ('isEnableIndexForegroundBlur') private isBlurr: boolean
  /* 是否开启全局动画判定 */
  @Consume ('isAnimation') isAnimation: boolean
  // 主页问候启用变量
  @State isGreeting: boolean= false

  // 切换菜单
  @Builder
  switchMenu(item: AppearanceListItemProp[], index: number) {
    if(index === 0) {
      // 切换深色模式
      Menu() {
        ForEach(item, (menuItem: AppearanceListItemProp, index: number) => {
          MenuItem({
            content: menuItem.title,
            symbolEndIcon: this.EnableDarkMode === index ? new SymbolGlyphModifier($r('sys.symbol.checkmark')).fontColor([this.icon_emphasize]) : undefined
          })
          .selected(this.EnableDarkMode === index)
          .onChange((selected) => {
            this.EnableDarkMode = index
            this.switchColorMode(index)
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
            symbolEndIcon: this.EnableThemeColor === index ? new SymbolGlyphModifier($r('sys.symbol.checkmark')).fontColor([this.icon_emphasize]) : undefined
          })
          .selected(this.EnableThemeColor === index)
          .onChange((selected) => {
            this.EnableThemeColor = index
            this.changeThemeColor(menuItem?.customThemeName ?? 'blueAppTheme')
            // UI刷新
            this.EnableThemeColorText = menuItem.title
          })
        }, (menuItem: AppearanceListItemProp) => JSON.stringify(menuItem))
      }
    } else if (index === 2) {
      Menu() {
        ForEach(item, (menuItem: AppearanceListItemProp, index: number) => {
          MenuItem({
            content: menuItem.title,
            symbolEndIcon: this.EnableButtonPosition === index ? new SymbolGlyphModifier($r('sys.symbol.checkmark')).fontColor([this.icon_emphasize]) : undefined
          })
            .selected(this.EnableButtonPosition === index)
            .onChange((selected) => {
              this.EnableButtonPosition = index
              this.switchButtonPosition(index)
              // UI刷新
              this.EnableButtonPositionText = menuItem.title
            })
        }, (menuItem: AppearanceListItemProp) => JSON.stringify(menuItem))
      }
    }
  }

  // 切换颜色模式
  switchColorMode(index: number) {
    switch (index) {
      case 0:
        // 跟随系统
        this.isFollowSystemSetting = true
        this.enableDarkMode = false
        setAutoColorMode(this.context)
        break;
      case 1:
        // 始终浅色
        this.isFollowSystemSetting = false
        setLightColorMode(this.context)
        break
      case 2:
        // 始终深色
        this.isFollowSystemSetting = false
        this.enableDarkMode = true
        setDarkColorMode(this.context)
        break
    }
  }

  /**
   * 更改主题配置
   * @param customThemeName 自定义主题的名字
   */
  changeThemeColor(customThemeName: CustomThemeName) {
    ThemeControl.setDefaultTheme(CUSTOM_THEME_MAP.get(customThemeName))
  }

  // 切换按钮位置
  switchButtonPosition(index:number) {
    switch (index) {
      case 0:
        // 右侧
        this.ButtonPositionOffset = 16
        this.stackAlignContentAlignment = Alignment.BottomEnd
        // 需接入全局按钮位置控制

      break
      case 1:
        // 中间
        this.ButtonPositionOffset = 0
        this.stackAlignContentAlignment = Alignment.Bottom
        // 需接入全局按钮位置控制

      break
      case 2:
        // 左侧
        this.ButtonPositionOffset = -16
        this.stackAlignContentAlignment = Alignment.BottomStart
        // 需接入全局按钮位置控制

      break
    }
  }

  aboutToAppear(): void {
    hilog.info(0xFF00, "AppearanceTag", "实验功能显示: %{public}s", this.isShowExperimentalFunction)
  }

  aboutToDisappear(): void {
    AppStorage.setOrCreate('enableDarkMode', this.enableDarkMode)
    AppStorage.setOrCreate('isFollowSystemSetting', this.isFollowSystemSetting)
  }

  @Builder
  ThemeColorTipsText() {
    Text(this.EnableThemeColorText)
      .fontWeight(FontWeight.Normal)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .margin({top: 2 })
      .fontSize(14)
  }
  @Builder
  ThemeColorMenuEntrance() {
    // 确保children存在
    if(this.appearanceList && this.appearanceList[1].children) {
      this.switchMenu(this.appearanceList[1].children, 1)
    }
  }
  @Builder
  DarkModeTipsText() {
    Text(this.EnableDarkModeText)
      .fontWeight(FontWeight.Normal)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .margin({top: 2 })
      .fontSize(14)
  }
  @Builder
  DarkModeMenuEntrance() {
    // 确保children存在
    if(this.appearanceList && this.appearanceList[0].children) {
      this.switchMenu(this.appearanceList[0].children, 0)
    }
  }
  @Builder
  ButtonPositionTipsText() {
    Text(this.EnableButtonPositionText)
      .fontWeight(FontWeight.Normal)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .margin({top: 2 })
      .fontSize(14)
  }
  @Builder
  ButtonPositionMenuEntrance() {
    // 确保children存在
    if(this.appearanceList && this.appearanceList[2].children) {
      this.switchMenu(this.appearanceList[2].children, 2)
    }
  }

  build() {
    NavDestination() {
      // 顶部导航区
      TopBuilder({title: $r('app.string.Appearance')})
      // 功能区
      List({ space: 10 }) {
        // 预览区
        ListItem() {
          Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
            Stack({ alignContent: this.stackAlignContentAlignment }) {
              // 单选框预览区
              Column() {
                Row() {
                  Text($r('app.string.color_preview'))
                    .width(80)
                    .fontWeight(FontWeight.Bold)
                    .fontSize(16)
                    .margin({ right: 9 })
                    .fontColor(this.font_primary)
                  Radio({ value: 'preview', group: 'appearanceRadioGroup', })
                    .checked(true)
                    .radioStyle({
                      checkedBackgroundColor: this.icon_emphasize,
                    })
                }

                Row() {
                  Text($r('app.string.configuration_1'))
                    .fontWeight(FontWeight.Bold)
                    .width(80)
                    .fontSize(16)
                    .margin({ right: 9 })
                    .fontColor(this.font_primary)
                  Radio({ value: 'config', group: 'appearanceRadioGroup', })
                    .checked(false)
                    .radioStyle({
                      checkedBackgroundColor: this.icon_emphasize,
                    })
                }
                .margin({ top: 10 })

                Row() {
                  Text($r('app.string.proxy_1'))
                    .fontWeight(FontWeight.Bold)
                    .width(80)
                    .fontSize(16)
                    .margin({ right: 9 })
                    .fontColor(this.font_primary)
                  Radio({ value: 'proxy', group: 'appearanceRadioGroup', })
                    .checked(false)
                    .radioStyle({
                      checkedBackgroundColor: this.icon_emphasize,
                    })
                }
                .margin({ top: 10 })
              }
              .width(188)
              .height(130)
              .borderRadius(20)
              .backdropBlur(2)
              .alignItems(HorizontalAlign.Start)
              .backgroundColor($r('app.color.container_background'))
              .padding({ left: 16, top: 15 })
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
          }
          .width('100%')
          .height(220)
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
        }
        // 列表区 Start
        ListItem() {
          Column() {
            // 主题色
            menuRowList({
              icons: $r('sys.symbol.paintpalette_fill'),
              title: $r('app.string.theme_color'),
              // 确保this指向父组件
              tips: (): void => { this.ThemeColorTipsText() },
              menu: (): void => { this.ThemeColorMenuEntrance() }
            })
            // 分割线
            Row().height(0.5).backgroundColor('#0D000000').width('93%')
            // 深色模式
            menuRowList({
              icons: $r('sys.symbol.circle_righthalf_inset_filled'),
              title: $r('app.string.dark_mode'),
              // 确保this指向父组件
              tips: (): void => { this.DarkModeTipsText() },
              menu: (): void => { this.DarkModeMenuEntrance() }
            })
            // 分割线
            Row().height(0.5).backgroundColor('#0D000000').width('93%')
            // 背景模糊
            Row() {
              toggleRowList({
                icons: $r('sys.symbol.rectangle_on_rectangle_fill'),
                title: $r('app.string.blurred_background'),
                subtitle: $r('app.string.blurred_background_subtitle'),
              }) {
                // 背景模糊开关
                Toggle({ type: ToggleType.Switch, isOn: $$this.isBlurr })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .onChange((isOn: boolean) => {
                    // 打开背景模糊 显式动画
                    this.getUIContext()?.animateTo({
                      duration: ANIMATION_DURATION_300,
                      curve: Curve.Ease
                    }, () => {
                      this.isBlurr = isOn
                    })
                  })
              }
            }.onClick(()=> {
              // 打开背景模糊 显式动画
              this.getUIContext()?.animateTo({
                duration: ANIMATION_DURATION_300
              }, () => {
                this.isBlurr = !this.isBlurr
              })
            })
            if(this.isShowExperimentalFunction) {
              // 分割线
              Row().height(0.5).backgroundColor('#0D000000').width('93%')
              // 动画效果
              Row() {
                toggleRowList({
                  icons: $r('sys.symbol.livephoto'),
                  title: $r('app.string.animation_effects'),
                  subtitle: $r('app.string.animation_effects_subtitle'),
                  isExperimentalFunction: true
                }) {
                  // 动画效果开关
                  Toggle({ type: ToggleType.Switch, isOn: $$this.isAnimation })
                    .selectedColor(this.icon_emphasize)
                    .margin({right: 12})
                    .onChange((isOn: boolean) => {
                      // 打开动画效果 显式动画
                      this.getUIContext()?.animateTo({
                        duration: ANIMATION_DURATION_300,
                        curve: Curve.Ease
                      }, () => {
                        this.isAnimation = isOn
                      })
                    })
                }
              }.onClick(()=> {
                // 打开动画效果 显式动画
                this.getUIContext()?.animateTo({
                  duration: ANIMATION_DURATION_300
                }, () => {
                  this.isAnimation = !this.isAnimation
                })
              })
            }
          }
          .width('100%')
          .borderRadius(20)
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
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
                Toggle({ type: ToggleType.Switch, isOn: $$this.isGreeting })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .onChange((isOn: boolean) => {
                    // 打开主页问候 显式动画
                    this.getUIContext()?.animateTo({
                      duration: ANIMATION_DURATION_300,
                      curve: Curve.Ease
                    }, () => {
                      this.isGreeting = isOn
                    })
                  })
              }
            }.onClick(()=> {
              // 打开主页问候 显式动画
              this.getUIContext()?.animateTo({
                duration: ANIMATION_DURATION_300
              }, () => {
                this.isGreeting = !this.isGreeting
              })
            })
            // 分割线
            Row().height(0.5).backgroundColor('#0D000000').width('93%')
            // 悬浮按钮位置
            menuRowList({
              icons: $r('sys.symbol.local_fill'),
              title: $r('app.string.suspension_button_position'),
              // 确保this指向父组件
              tips: (): void => { this.ButtonPositionTipsText() },
              menu: (): void => { this.ButtonPositionMenuEntrance() }
            })
          }
          .width('100%')
          .borderRadius(20)
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
          .backgroundColor($r('app.color.container_background'))
        }
        // 列表区 End
      }
      .width('100%')
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .height(this.isLandscapePhone ? 300 : this.SettingslistHeight.value)
      .padding({ left: this.breakPointStatemorePageMargin.value, right: this.breakPointStatemorePageMargin.value, bottom: this.breakPointStatemorePageMargin.value })

    }
    .width('100%')
    .backgroundColor($r('app.color.background'))
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.SettingsPageInfos.clear();
      return true;
    })

  }
}
export default Appearance
