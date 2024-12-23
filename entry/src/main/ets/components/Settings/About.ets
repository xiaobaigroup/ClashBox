import { BreakpointState } from "../../common/breakpointsystem"
import { AboutListItemProp, AboutList, BORDER_RADIUS_20, ContributorsListItemProp,
  ContributorsList,
  CheckUpdateList,
  CheckUpdateListItemProp} from "../../common/Constants"
import TopBuilder from "./TopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { common, Want } from "@kit.AbilityKit"
import { BusinessError } from "@kit.BasicServicesKit"
import { promptAction, SymbolGlyphModifier } from "@kit.ArkUI"

@Component
struct About {
  // 实验功能提示框展示变量
  @Consume isShowExperimentalFunction: boolean
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  // 二级图标色，黑色
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary')
  @State EnableUpdateChenChannels: number = 0
  @State aboutList: AboutListItemProp[] = AboutList
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>

  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  // 列表高度
  @Consume('breakPointStateSettingslistHeight') private SettingslistHeight: BreakpointState<number>

  // 隐式 Want 跳转网站
  async implicitStartAbility(url: string) {
    try {
      let want: Want = {
        // 如果希望仅在特定包中隐式查询，请取消下面的注释行
        // bundleName: "com.example.myapplication",
        "action": "ohos.want.action.viewData",
        // entities可以省略
        "entities": [ "entity.system.browsable" ],
        "uri": url,
      }
      let context = getContext(this) as common.UIAbilityContext;
      await context.startAbility(want)
      console.info(`explicit start ability succeed`)
    } catch (error) {
      console.info(`explicit start ability failed with ${error.code}`)
    }
  }

  // 列表行跳转处理
  handleCheck(name?: string) {
    switch (name) {
      case 'Update':
        // 检查更新
        hilog.info(0xFF00, "AboutestTag", "检查更新")

      break
      case 'Telegram':
        // 跳转Telegram频道
        hilog.info(0xFF00, "AboutestTag", "Telegram")
        this.implicitStartAbility('https://xxx')

      break
      case 'Discord':
        // 跳转Discord社区
        hilog.info(0xFF00, "AboutestTag", "Discord")
        this.implicitStartAbility('https://xxx')

      break
      case 'Email':
        // 电子邮件
        hilog.info(0xFF00, "AboutestTag", "Email")

      break
      case 'Repositories':
        // 跳转仓库
        hilog.info(0xFF00, "AboutestTag", "仓库")
        this.implicitStartAbility('https://gitee.com/DXHXYT/ark-c')

      break
      default :
        this.SettingsPageInfos.pushPathByName(name, false)
    }
  }

  // 列表行开关事件处理
  handleToggle(isOn: boolean, name: string) {
    switch (name) {
      case 'ExperimentalFunction':
        // 实验功能开关
        hilog.info(0xFF00, "AboutestTag", "实验功能")
        if(isOn) {
          this.isShowExperimentalFunction = true
        } else {
          this.isShowExperimentalFunction = false
        }
        break
      case 'Auto':
        // 自动检查更新
        hilog.info(0xFF00, "AboutestTag", "自动检查更新")

    }
  }

  // 更新渠道更改处理
  switchUpdateChenChannels(index: number) {
    hilog.info(0xFF00, "AboutUpdateTag", "index: %{public}d", index)
    switch (index) {
      case 0:
        // Github
        hilog.info(0xFF00, "AboutUpdateTag", "Github")

      break
      case 1:
        // XXX
        hilog.info(0xFF00, "AboutUpdateTag", "XXX")

      break
      case 2:
        // XXXX
        hilog.info(0xFF00, "AboutUpdateTag", "XXXX")

      break

    }
  }

  // 刷新更新渠道列表UI
  refreshUpdateChenChannels(title: ResourceStr) {
    // 修改关于页面更新渠道显示的subtitle
    // 先检查是否存在children
    const childItem = this.aboutList[4]
    if (childItem && childItem.children) {
      childItem.children[1].subtitle = title
      // 使用splice来更新父组件数组
      this.aboutList.splice(4, 1, childItem)
    }
  }

  // 更新渠道菜单
  @Builder
  UpdateMenu(item: AboutListItemProp[], index: number) {
    Menu() {
      ForEach(item, (menuItem: AboutListItemProp, index: number) => {
        MenuItem({ content: menuItem.title })
          .selectIcon(true)
          .selected(this.EnableUpdateChenChannels === index)
          .onChange((selected) => {
            this.switchUpdateChenChannels(index)
            this.EnableUpdateChenChannels = index
            // UI刷新
            this.refreshUpdateChenChannels(menuItem.title)
          })
      }, (menuItem: AboutListItemProp) => JSON.stringify(menuItem))
    }
  }

  build() {
    NavDestination() {
      // 标题
      TopBuilder({title: $r('app.string.About')})
      // List主体
      List() {
        // Logo&名称
        ListItem() {
          Column() {
            Stack() {
              Image($r('app.media.foreground'))
                .height(160)
                .zIndex(2)
              Stack() {
                Image($r('app.media.About_name_1'))
                  .width(192)
                  .fillColor($r('app.color.symbol_logo_name_color'))
                Image($r('app.media.About_name_2'))
                  .height(26)
                  .offset({x: 51, y: -1})
              }
              .offset({y: 86})
            }
          }
          .justifyContent(FlexAlign.Start)
          .alignItems(HorizontalAlign.Center)
          .width('100%')
          .backgroundColor($r('app.color.container_background'))
          .borderRadius(BORDER_RADIUS_20)
          .height(220)
        }.margin({bottom: 10 })

        ForEach(this.aboutList, (item: AboutListItemProp, index: number) => {
          ListItem() {
            Column() {
              ForEach(item.children, (itemChild: AboutListItemProp) => {
                if (itemChild.children) {
                  // 存在子项
                  Column() {
                    Row() {
                      Text(itemChild.title)
                        .height(53)
                        .fontWeight(FontWeight.Medium)
                        .padding({ left: 12 })
                        .fontSize(16)
                      Blank()
                      Row() {
                        Text(itemChild.subtitle)
                          .fontWeight(FontWeight.Normal)
                          .fontSize(14)
                          .margin({right: 5})
                        SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
                          .fontSize(14)
                          .fontColor([this.icon_primary])
                          .margin({left: 7})
                      }.margin({right: 20})
                       .bindMenu(this.UpdateMenu(itemChild.children, index))
                    }.width('100%')
                    // 分割线
                    Row().height(0.5).backgroundColor('#0D000000').width('93%')
                  }
                  .onClick(() => {
                    // 这里什么都没有
                  })
                } else { // 无子项
                  Column() {
                    Row() {
                      Column() {
                        Text(itemChild.title)
                          .fontWeight(FontWeight.Medium)
                          .fontSize(16)
                        if(itemChild.subtitle && itemChild.sign === 1) {
                          Text(itemChild.subtitle)
                            .fontWeight(FontWeight.Normal)
                            .fontSize(14)
                            .margin({top: 2})
                        }
                      }
                      .height(53)
                      .justifyContent(FlexAlign.Center)
                      .alignItems(HorizontalAlign.Start)
                      .margin({ left: 12 })
                      Blank()
                      if(itemChild.sign === 1) {
                        // 开关型
                        Toggle({ type: ToggleType.Switch, isOn: itemChild.isOn })
                          .selectedColor(this.icon_emphasize)
                          .margin({right: 12})
                          .onChange((isOn: boolean) => {
                            // 进入开关事件处理
                            this.handleToggle(isOn, itemChild.name)
                          })
                      } else if(itemChild.sign === 2) {
                        // 跳转型
                        SymbolGlyph($r('sys.symbol.chevron_right'))
                          .fontSize(28)
                          .margin({right: 12})
                          .fontColor([this.icon_primary])
                      } else if(itemChild.sign === 0) {
                        // 普通型
                        Text(itemChild.subtitle)
                          .fontWeight(FontWeight.Normal)
                          .fontSize(14)
                          .margin({right: 12})
                      }
                    }.width('100%')
                    // 分割线
                    Row().height(0.5).backgroundColor('#0D000000').width('93%')
                  }
                  .onClick(() => {
                    if(itemChild.sign === 0) {
                      // 似乎可以留个彩蛋
                    } else if(itemChild.sign === 2) {
                      // 进入列表行跳转处理
                      this.handleCheck(itemChild.name)
                    }
                  })
                }
              })
            }
            .backgroundColor($r('app.color.container_background'))
            .borderRadius(BORDER_RADIUS_20)
            .margin({bottom: 10 })
          }

        })
      }
      .width('100%')
      .alignListItem(ListItemAlign.Center)
      .height(this.isLandscapePhone ? 300 : this.SettingslistHeight.value)
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
export default About



/**
 *  贡献者名单页面
 */
@Component
export struct AboutContributors {
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  @State ContributorsList: ContributorsListItemProp[] = ContributorsList
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  // 列表高度
  @Consume('breakPointStateSettingslistHeight') private SettingslistHeight: BreakpointState<number>
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>

  // 隐式 Want 跳转网站
  async implicitStartAbility(url: string) {
    try {
      let want: Want = {
        // 如果希望仅在特定包中隐式查询，请取消下面的注释行
        // bundleName: "com.example.myapplication",
        "action": "ohos.want.action.viewData",
        // entities可以省略
        "entities": [ "entity.system.browsable" ],
        "uri": url,
      }
      let context = getContext(this) as common.UIAbilityContext;
      await context.startAbility(want)
      console.info(`explicit start ability succeed`)
    } catch (error) {
      console.info(`explicit start ability failed with ${error.code}`)
    }
  }

  // 拉起邮件类应用（mailto方式）
  async handleMailto(address: string) {
    let ctx = getContext(this) as common.UIAbilityContext;
    ctx.startAbility({
      action: 'ohos.want.action.sendToData',
      uri: address
    })
  }

  handleClick(index: number) {
    switch (index) {
      case 0:
        // 小白
        this.implicitStartAbility('https://github.com/likuai2010')
      break
      case 1:
        // 船长
        this.handleMailto('mailto:feedback@example.com?subject=App Feedback&body=Please describe your feedback here...')
      break
      case 2:
        // 柯蓝KL
        this.handleMailto('mailto:feedback@example.com?subject=App Feedback&body=Please describe your feedback here...')
      break
      case 3:
        // 恩临大帝
        this.handleMailto('mailto:feedback@example.com?subject=App Feedback&body=Please describe your feedback here...')
      break
      case 4:
        // crazypig321
        this.implicitStartAbility('https://github.com/crazypig321')
      break
      case 5:
        // 小雅
        this.implicitStartAbility('https://github.com/XHXYT')
      break
    }
  }

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.About'), subtitle: $r('app.string.Contributors')})
      List() {
        ForEach(this.ContributorsList, (item: ContributorsListItemProp, index: number) => {
          ListItem() {
            Column() {
              Row() {
                // 头像
                Image(item.image)
                  .width(48)
                  .height(48)
                Column() {
                  // 名字
                  Text(item.title)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                  Text(item.subtitle)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .maxLines(1)
                    .fontSize(16)
                    .fontWeight(FontWeight.Normal)
                    .margin({top: 2})
                }
                .alignItems(HorizontalAlign.Start)
                .margin({left: 16})
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)

              if(item.contact) {
                Row() {
                  Button(item.contact, { type: ButtonType.Capsule, stateEffect: true })
                    .backgroundColor($r('app.color.button_container_background'))
                    .fontColor(this.icon_emphasize)
                    .width(90)
                    .height(26)
                    .onClick(() => {
                      this.handleClick(index)
                    })
                  if(item.contact2) {
                    Button(item.contact2, { type: ButtonType.Capsule, stateEffect: true })
                      .backgroundColor($r('app.color.button_container_background'))
                      .fontColor(this.icon_emphasize)
                      .margin({left: 6})
                      .width(90)
                      .height(26)
                      .onClick(() => {
                        // 柯蓝KL Telegram
                        this.implicitStartAbility('https://xxxx')
                      })
                  }
                }
                .margin({top: 12})
                .width('100%')
                .justifyContent(FlexAlign.Start)
              }
            }
          }
          .backgroundColor($r('app.color.container_background'))
          .borderRadius(BORDER_RADIUS_20)
          .margin({bottom: 10 })
          .width('100%')
          .padding({left: 12, top: 12, bottom: 12})
        })
      }
      .width('100%')
      .alignListItem(ListItemAlign.Center)
      .height(this.isLandscapePhone ? 300 : this.SettingslistHeight.value)
      .padding({ left: this.breakPointStatemorePageMargin.value, right: this.breakPointStatemorePageMargin.value })
    }
    .width('100%')
    .backgroundColor($r('app.color.background'))
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.SettingsPageInfos.pop(true)
      return true
    })
  }
}

/**
 *  检查更新页
 */
@Component
export struct CheckUpdate {

  @State updateList: CheckUpdateListItemProp[] = CheckUpdateList
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')

  // 隐式 Want 跳转网站
  async implicitStartAbility(url: string) {
    try {
      let want: Want = {
        // 如果希望仅在特定包中隐式查询，请取消下面的注释行
        // bundleName: "com.example.myapplication",
        "action": "ohos.want.action.viewData",
        // entities可以省略
        "entities": [ "entity.system.browsable" ],
        "uri": url,
      }
      let context = getContext(this) as common.UIAbilityContext;
      await context.startAbility(want)
      console.info(`explicit start ability succeed`)
    } catch (error) {
      console.info(`explicit start ability failed with ${error.code}`)
    }
  }

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Check_Updates')})
      Column() {
        ForEach(this.updateList, (item: CheckUpdateListItemProp, index: number) => {
          Column() {
            ForEach(item.children, (itemChild: CheckUpdateListItemProp) => {
              Column() {
                Row() {
                  // 图标
                  if(itemChild.icons) {
                    SymbolGlyph(itemChild.icons)
                      .fontSize(24)
                      .margin({left: 12, right: 12})
                      .fontColor([this.icon_emphasize])
                  }
                  // 标题
                  Column() {
                    Text(itemChild.title)
                      .fontWeight(FontWeight.Medium)
                      .fontSize(16)
                    if(itemChild.subtitle && item.title != 'Version') {
                      Text(itemChild.subtitle)
                        .fontWeight(FontWeight.Normal)
                        .fontSize(14)
                        .margin({top: 2})
                    }
                  }
                  .height(53)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 12 })
                  Blank()
                  if(item.title === 'Version') {
                    Text(itemChild.subtitle)
                      .fontWeight(FontWeight.Normal)
                      .fontSize(14)
                      .margin({ right: 12})
                  } else {
                    SymbolGlyph($r('sys.symbol.chevron_right'))
                      .fontSize(24)
                      .margin({ right: 12})
                      .fontColor([this.icon_primary])
                  }
                }
                .width('100%')
                .justifyContent(FlexAlign.Start)
                // 分割线
                Row().height(0.5).backgroundColor('#0D000000').width('93%')
              }.width('100%')
              .onClick(() => {
                if(index === 1) {
                  // 前往下载网页
                  hilog.info(0xFF00, "checkUpdateTest", "前往下载网页")
                  // 网站的URL后期需要更换为动态变化
                  // this.implicitStartAbility('https://xxxx')
                  // 预览版暂不提供此功能
                  promptAction.showToast({
                    message: '开发中，敬请期待',
                    duration: 2000
                  })
                } else if(index === 2) {
                  // 忽略本次更新
                  hilog.info(0xFF00, "checkUpdateTest", "忽略本次更新")

                }
              })
            })
          }
          .width('100%')
          .backgroundColor($r('app.color.container_background'))
          .borderRadius(BORDER_RADIUS_20)
          .margin({bottom: 10 })
        })
        // 提示
        Text($r('app.string.check_update_tips'))
          .fontWeight(FontWeight.Normal)
          .fontSize(15)
      }
      .width('100%')
      .padding({ left: this.breakPointStatemorePageMargin.value, right: this.breakPointStatemorePageMargin.value })
    }
    .width('100%')
    .backgroundColor($r('app.color.background'))
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.SettingsPageInfos.pop(true)
      return true
    })
  }
}