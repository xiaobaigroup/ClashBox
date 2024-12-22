import { BreakpointState } from "../../common/breakpointsystem"
import { AppearanceList, AppearanceListItemProp } from "../../common/Constants"
import TopBuilder from "./TopBuilder"
import { ThemeControl } from "@kit.ArkUI"
import { CUSTOM_THEME_MAP } from "../../common/AppTheme"

@Component
struct Appearance {
  @Link isShowSettings: boolean
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  @State appearanceList: AppearanceListItemProp[] = AppearanceList
  /* 主题色 */
  @State font_primary: ResourceColor = $r('sys.color.font_primary')
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>
  // 按钮宽度
  @State
  private proxyStartButtonWidth: Length = $r('app.integer.vp_proxy_not_start_button_width')
  // 按钮高度
  @State
  private proxyStartButtonHeight: Length = $r('app.integer.vp_proxy_not_start_button_height')
  // 主题模式选中序号
  @State EnableDarkMode: number = 0
  // 主题色选中序号
  @State EnableThemeColor: number = 0
  // 按钮位置选中序号
  @State EnableButtonPosition: number = 0

  // 切换菜单
  @Builder
  switchMenu(item: AppearanceListItemProp[], index: number) {
    if(index === 0) {
      // 切换深色模式
      Menu() {
        ForEach(item, (menuItem: AppearanceListItemProp, index: number) => {
          MenuItem({ content: menuItem.title })
            .selectIcon(true)
          .selected(this.EnableDarkMode === index)
          .onChange((selected) => {
            // 修改关于页面更新渠道显示的subtitle
            // if (this.aboutList && this.aboutList.length > 4 && this.aboutList[4].children) {
            //   // 检查this.aboutList[4].children[1]是否存在
            //   const childItem = this.aboutList[4].children[1];
            //   if (childItem) {
            //     // 如果存在，更新它的subtitle属性
            //     childItem.subtitle = menuItem.title;
            //   }
            //   // 使用splice来修改subtitle
            //   this.aboutList[4].children.splice(1, 1, childItem);
            // }
            // this.switchUpdateChenChannels(index)
            this.EnableDarkMode = index

          })
        }, (menuItem: AppearanceListItemProp) => JSON.stringify(menuItem))
      }
    } else if(index === 1) {
      // 切换主题色
      Menu() {
        ForEach(item, (menuItem: AppearanceListItemProp, index: number) => {
          MenuItem({ content: menuItem.title })
            .selectIcon(true)
          .selected(this.EnableThemeColor === index)
          .onChange((selected) => {
            // 修改关于页面更新渠道显示的subtitle
            // if (this.aboutList && this.aboutList.length > 4 && this.aboutList[4].children) {
            //   // 检查this.aboutList[4].children[1]是否存在
            //   const childItem = this.aboutList[4].children[1];
            //   if (childItem) {
            //     // 如果存在，更新它的subtitle属性
            //     childItem.subtitle = menuItem.title;
            //   }
            //   // 使用splice来修改subtitle
            //   this.aboutList[4].children.splice(1, 1, childItem);
            // }
            // this.switchUpdateChenChannels(index)
            this.EnableThemeColor = index
            this.switchThemeColor(index)
          })
        }, (menuItem: AppearanceListItemProp) => JSON.stringify(menuItem))
      }
    } else if(index === 3) {
      // 切换按钮位置
      Menu() {
        ForEach(item, (menuItem: AppearanceListItemProp, index: number) => {
          MenuItem({ content: menuItem.title })
            .selectIcon(true)
          .selected(this.EnableButtonPosition === index)
          .onChange((selected) => {
            // 修改关于页面更新渠道显示的subtitle
            // if (this.aboutList && this.aboutList.length > 4 && this.aboutList[4].children) {
            //   // 检查this.aboutList[4].children[1]是否存在
            //   const childItem = this.aboutList[4].children[1];
            //   if (childItem) {
            //     // 如果存在，更新它的subtitle属性
            //     childItem.subtitle = menuItem.title;
            //   }
            //   // 使用splice来修改subtitle
            //   this.aboutList[4].children.splice(1, 1, childItem);
            // }
            // this.switchUpdateChenChannels(index)
            this.EnableButtonPosition = index

          })
        }, (menuItem: AppearanceListItemProp) => JSON.stringify(menuItem))
      }
    }
  }

  switchThemeColor(index: number) {
    switch (index) {
      case 0:
        // 星河蓝
        ThemeControl.setDefaultTheme(CUSTOM_THEME_MAP.get('blueAppTheme'))
      break;
      case 1:
        // 猫咪蓝
      break
      case 2:
        // 便单黄
        ThemeControl.setDefaultTheme(CUSTOM_THEME_MAP.get('orangeAppTheme'))
      break
      case 3:
        // 华为红
        ThemeControl.setDefaultTheme(CUSTOM_THEME_MAP.get('redAppTheme'))
      break
      case 4:
        // 优雅紫
      break
      case 5:
        // 哔哩粉
      break
      case 6:
        // 小草绿
      break
    }
  }

  build() {
    NavDestination() {
      // 顶部导航区
      TopBuilder({title: $r('app.string.Appearance')})
      // 功能区
      Column() {
        // 颜色预览区
        Stack() {
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
              Radio({ value: 'config', group: 'appearanceRadioGroup',})
                .checked(false)
                .radioStyle({
                  checkedBackgroundColor: this.icon_emphasize,
                })
            }
            .margin({top: 10})
            Row() {
              Text($r('app.string.proxy_1'))
                .fontWeight(FontWeight.Bold)
                .width(80)
                .fontSize(16)
                .margin({ right: 9 })
                .fontColor(this.font_primary)
              Radio({ value:'proxy', group: 'appearanceRadioGroup',})
                .checked(false)
                .radioStyle({
                  checkedBackgroundColor: this.icon_emphasize,
                })
            }
            .margin({top: 10})
          }
          .width(188)
          .height(130)
          .borderRadius(20)
          .backdropBlur(2)
          .alignItems(HorizontalAlign.Start)
          .backgroundColor($r('app.color.container_background'))
          .padding({left: 16, top: 15})
          // 按钮预览区
          Column() {
            Row() {
              Stack({ alignContent: Alignment.Center }) {
                SymbolGlyph($r('sys.symbol.play_fill'))
                  .fontSize(24)
                  .fontColor([Color.White])
                  .align(Alignment.Center)
              }
              .width(this.proxyStartButtonHeight)
              .height(this.proxyStartButtonHeight)
            }.width(this.proxyStartButtonHeight)
          }
          .offset({x: 92, y: 52})
          .borderRadius(100)
          .backgroundColor(this.icon_emphasize)
          .shadow({
            radius: 10,
            color: this.icon_emphasize,
            offsetY: 4,
            type: ShadowType.BLUR
          })
        }
        .width('100%')
        .height(220)
        // 列表区
        ForEach(this.appearanceList, (item: AppearanceListItemProp, index: number) => {
          Row() {
            Row() {
              SymbolGlyph(item.icon)
                .fontSize(24)
                .margin({left: 12})
                .fontColor([this.icon_emphasize])
              Column() {
                Text(item.title)
                  .fontWeight(FontWeight.Medium)
                  .fontSize(16)
                if(!item.children) {
                  Text(item.subtitle)
                    .fontWeight(FontWeight.Normal)
                    .textOverflow({ overflow: TextOverflow.MARQUEE })
                    .maxLines(1)
                    .margin({ top: 2 })
                    .fontSize(14)
                    .width('70%')
                }
              }
              .margin({ left: 12 })
              .alignItems(HorizontalAlign.Start)
              Blank()
              if(item.children) {
                Row() {
                  Text(item.subtitle)
                    .fontWeight(FontWeight.Normal)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .maxLines(1)
                    .margin({top: 2 })
                    .fontSize(14)
                  SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
                    .fontSize(14)
                    .margin({left: 7, right: 20})
                    .fontColor([this.icon_primary])
                }.bindMenu(this.switchMenu(item.children, index))
              } else {
                Toggle({ type: ToggleType.Switch, isOn: false })
                  .selectedColor(this.icon_emphasize)
                  .margin({right: 12})
                  .onChange((isOn: boolean) => {
                    if(isOn) {
                      //this.handleToggle(index)
                    }
                  })
              }
            }
            .margin({bottom: 10})
            .width('100%')
            .height(53)
            .borderRadius(20)
            .backgroundColor($r('app.color.container_background'))
          }
        })
      }
      .padding({ left: this.breakPointStatemorePageMargin.value, right: this.breakPointStatemorePageMargin.value })
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