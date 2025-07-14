import { AboutListItemProp, BORDER_RADIUS_20,
  CheckUpdateListItemProp,
  CONTENT_END_OFFSET_150,
  moreData,
  ListMoreData,
  getAboutList,
  getCheckUpdateList,
  TCItemProp,
  FAQList,
  ThirdServicesList,
  UseGuidanceList,
  LinkList,
  CollaboratorsList,
  CollaboratorsListItemProp,
} from "../../common/entity/Constants"
import TopBuilder from "./TopBuilder"
import { Xb_Studio } from "xb_components"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { common, Want } from "@kit.AbilityKit"
import { LengthMetrics, promptAction, SymbolGlyphModifier } from "@kit.ArkUI"
import { AppConfig, ClashCore, isEnd, UIConfig } from "../../entryability/AppState"
import { customAnimationUtil } from "../../common/utils/Animation"
import { removeItemsByIndex } from "../../common/utils/RemoveItemsUtils"
import { customVibrator } from "../../common/utils/VibratorUtil"
import { customSound } from "../../common/utils/SoundPoolUtil"
import { getResourceString } from "../../common/utils/ResourceStringUtil"
import { extractUpdateInfo, getUpdateInfo, UpdateInfo } from "../../common/utils/CheckUpdateUtil"
import { PageMargin } from "../../common/breakpoint/BreakPoint"
import { icon_primary } from '../Common/Common'
import { Xb_GoToWeb, Xb_HandleMailto } from "xb_components/src/main/ets/utils/JumpTo"
import { Xb_Copy } from "xb_components/src/main/ets/utils/ClipBoardUtil"

@Component
struct About {
  // 实验功能提示框展示变量
  @Consume isShowExperimentalFunction: boolean
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @State EnableUpdateChenChannels: number = 0
  @State aboutList: AboutListItemProp[] = []
  // 更多页列表数组
  @Consume moreList: moreData[]
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink ('isLandscapePhone') isLandscapePhone: boolean = false
  // 点击次数
  @State clickCount: number = 0
  // 实验功能开关列表行数据
  @Consume ExperimentData: AboutListItemProp
  @Consume theAppVersionInfo: UpdateInfo

  onClickCount() {
    //振动触发
    if (this.uiConfig.isVibrate) {
      customVibrator.vibratorTriggerOfHapticClockTimer()
    }
    hilog.info(0xFF00, "AboutClickTag", "点击次数: %{public}d", this.clickCount)
    if(this.uiConfig.enabledADvanced) {
      promptAction.showToast({message: '已处于高级模式' /*$r('app.string.click_prompt')*/, duration: 2000 })
    } else {
      if (this.clickCount >= 5) {
        this.uiConfig.enabledADvanced = true
        this.uiConfig.isShowExperimentalFunction = true
        // 刷新关于页面数据
        this.aboutList.splice(1, 0, this.ExperimentData)
        // 刷新更多页面数据
        this.moreList = ListMoreData()
        promptAction.showToast({message: '高级模式已开启' /*$r('app.string.click_prompt')*/, duration: 2000 })
        //音效触发
        customSound.playAudioForSoundPool()
      } else if (this.clickCount === 3) {
        promptAction.showToast({message: '什么东西闪过去了' /*$r('app.string.click_prompt')*/, duration: 1000 })
      }
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
        Xb_GoToWeb('https://t.me/+ihe73JZWYb40NTY1')

      break
      case 'Discord':
        // 跳转Discord社区
        hilog.info(0xFF00, "AboutestTag", "Discord")
        Xb_GoToWeb('https://discord.gg/mZarq2EQmm')

      break
      case 'Email':
        // 电子邮件
        hilog.info(0xFF00, "AboutestTag", "Email")
        Xb_HandleMailto('mailto:xfz347@gmail.com?subject=反馈&body=你的反馈内容...')
      break
      case 'Repositories':
        // 跳转仓库
        // hilog.info(0xFF00, "AboutestTag", "仓库")
        Xb_GoToWeb('https://github.com/xiaobaigroup/ClashBox')
        // promptAction.showToast({message: $r('app.string.not_open'), duration: 2000 })
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
        // 持久化实验功能开关状态
        this.uiConfig.isShowExperimentalFunction = isOn
        hilog.info(0xFF00, "AboutestTag", "实验功能")
        if(isOn) {
          this.isShowExperimentalFunction = true
          // 显示分流策略
          this.moreList = ListMoreData()
        } else {
          this.isShowExperimentalFunction = false
          // 屏蔽分流策略
          // this.moreList = removeItemsByIndex(this.moreList, [5])
        }
        break
      case 'Auto':
      // 自动检查更新
      hilog.info(0xFF00, "AboutestTag", "自动检查更新")
      this.uiConfig.autoCheckUpdate = isOn
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

  // 刷新更新渠道列表UI TODO 【用户首选项】保存选择的更新渠道 Ya@2024-12-20
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

  // 刷新实验功能启用开关状态
  refreshShowExperimentalFunction(isOn: boolean) {
    const showItem = this.aboutList[1]
    if (showItem && showItem.children) {
      showItem.children[0].isOn = isOn
      // 使用splice来更新父组件数组
      this.aboutList.splice(1, 1, showItem)
    }
  }
  // 刷新内核版本信息显示
  refreshShowKernelVersion(kernel?: ClashCore) {
    hilog.info(0xFF00, "SettingsKerneltestTag", "当前显示内核：%{public}d", this.appConfig.clashCore)
    const showItem = this.aboutList[0]
    if (showItem && showItem.children) {
      switch (kernel) {
        case 0:
          showItem.children[1].subtitle = `mihomo ${showItem.children[1].subtitle}`
          break
        case 1:
          showItem.children[1].subtitle = `前台模式 ${showItem.children[1].subtitle}`
          break
        case 2:
          showItem.children[1].subtitle = `ClashRS ${showItem.children[1].subtitle}`
          break
      }
      // 使用splice来更新父组件数组
      this.aboutList.splice(0, 1, showItem)
    }
  }

  // 刷新自动检查更新启用开关状态
  refreshShowAutoUpdate(isOn: boolean) {
    const showItem = this.aboutList[4]
    if (showItem && showItem.children) {
      showItem.children[2].isOn = isOn
      // 使用splice来更新父组件数组
      this.aboutList.splice(4, 1, showItem)
    }
  }

  // 更新渠道菜单
  @Builder
  UpdateMenu(item: AboutListItemProp[], index: number) {
    Menu() {
      ForEach(item, (menuItem: AboutListItemProp, index: number) => {
        MenuItem({
          content: menuItem.title,
          symbolEndIcon: this.EnableUpdateChenChannels === index ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
        })
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

  aboutToAppear(): void {
    this.aboutList = getAboutList()
    // 音效
    customSound.initSoundPool(3, 'di.mp3')
    // 页面加载时初始化实验功能启用状态
    this.refreshShowExperimentalFunction(this.uiConfig.isShowExperimentalFunction)
    // 加载时初始化内核版本显示
    this.refreshShowKernelVersion(this.appConfig.clashCore)
    // 加载时初始化自动检查更新开关状态
    this.refreshShowAutoUpdate(this.uiConfig.autoCheckUpdate)
    hilog.info(0xFF00, "AboutClickTag", "高级功能: %{public}s", this.uiConfig.enabledADvanced)
    if (this.uiConfig.enabledADvanced === false && this.aboutList.length === 6) {
      this.aboutList = removeItemsByIndex(this.aboutList, [1])
    }
  }

  aboutToDisappear(): void {
    this.isShowExperimentalFunction = this.uiConfig.isShowExperimentalFunction
    customSound.destroySoundPool()
  }

  build() {
    NavDestination() {
      // 标题
      TopBuilder({title: $r('app.string.About')})
      // List主体
      List() {
        // Logo&名称
        ListItem() {
          Column({space: 15}) {
            // logo
            Stack() {
              Image($r('app.media.background_white'))
                .borderRadius(25)
                .height(106)
                .zIndex(1)
              Image($r("app.media.fore_box_cat"))
                .height(106)
                .zIndex(2)
            }
            // 名称
            Image($r("app.media.clash_box_blue"))
              .width(192)
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .width('100%')
         // .backgroundColor($r('app.color.container_background'))
          .borderRadius(BORDER_RADIUS_20)
          .height(220)
        }
        .margin({bottom: 10 })
           .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))

        ForEach(this.aboutList, (item: AboutListItemProp, index: number) => {
          ListItem() {
            Column() {
              ForEach(item.children, (itemChild: AboutListItemProp, i: number) => {
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
                          .fontColor([icon_primary])
                          .margin({left: 7})
                      }.margin({right: 20})
                       .bindMenu(this.UpdateMenu(itemChild.children, index))
                    }.width('100%')
                    // 分割线
                    if(!isEnd(item.children!.length,i))
                      Row().height(0.5).backgroundColor($r('app.color.divider')).width('93%')

                  }
                     .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
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
                          .fontColor([icon_primary])
                      } else if(itemChild.sign === 0) {
                        // 普通型
                        Text(itemChild.subtitle)
                          .fontWeight(FontWeight.Normal)
                          .fontSize(14)
                          .margin({right: 12})
                          .hitTestBehavior(HitTestMode.None)
                      }
                    }.width('100%')
                    // 分割线
                   if(!isEnd(item.children!.length,i))
                     Row().height(0.5).backgroundColor($r('app.color.divider')).width('93%')

                  }
                  .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                  .onClick(() => {
                   if(itemChild.sign === 1) {
                     // 点击提示 防误触
                     promptAction.showToast({message: $r('app.string.click_prompt'), duration: 2000 })
                      if (itemChild.name === 'ExperimentalFunction') {

                      // } else {
                      //   // 改变自动检查更新开关状态 显式动画
                      //   this.getUIContext()?.animateTo({
                      //     duration: this.uiConfig.animationSpeed,
                      //     curve: Curve.Ease
                      //   }, () => {
                      //     const childItem = this.aboutList[4]
                      //     if (childItem && childItem.children) {
                      //       childItem.children[2].isOn = !childItem.children[2].isOn
                      //       // 使用splice来更新父组件数组
                      //       this.aboutList.splice(4, 1, childItem)
                      //     }
                      //   })
                      }

                    } else if (itemChild.sign === 2) {
                      // 进入列表行跳转处理
                      this.handleCheck(itemChild.name)
                    } else if (itemChild.sign === 0) {
                     if (itemChild.name === 'ApplicationVersion') {
                       hilog.info(0xFF00, "AboutClickTag", "前: %{public}d", this.clickCount)
                       // TODO 高级模式
                       // this.clickCount++
                       // this.onClickCount()
                       hilog.info(0xFF00, "AboutClickTag", "后: %{public}d", this.clickCount)
                     }
                   }
                  })
                }
              }, (itemChild: AboutListItemProp) => itemChild.name )
            }
            .backgroundColor($r('app.color.container_background'))
            .borderRadius(BORDER_RADIUS_20)
            .margin({bottom: 10 })
          }

        })
      }
      .width('100%')
      .alignListItem(ListItemAlign.Center)
      .contentEndOffset(CONTENT_END_OFFSET_150 - 85)
      .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
    }
    .width('100%')
    .backgroundColor($r('app.color.background'))
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.SettingsPageInfos.clear()
      return true
    })
  }
}
export default About

/**
 * 小白工坊
 */
@Component
export struct AboutXBStudio {
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.About'), subtitle: $r('app.string.xb_studio')})
      // 小白工坊
      Xb_Studio({
        route: undefined /*UIUtils.enableV2Compatibility(this.SettingsPageInfos)*/,
        showTopTitle: false,
        PageBackgroundColor: $r('app.color.background'),
      })
    }
    .backgroundColor($r('app.color.background'))
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.SettingsPageInfos.pop(true)
      return true
    })
  }

}

/**
 *  协作者名单页面
 */
@Component
export struct AboutCollaborators {
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @State CollaboratorsList: CollaboratorsListItemProp[] = CollaboratorsList
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.About'), subtitle: $r('app.string.collaborators')})
      List() {
        ForEach(this.CollaboratorsList, (item: CollaboratorsListItemProp, index: number) => {
          ListItem() {
            Column() {
              Row() {
                // 头像
                Image(item.image)
                  .width(48)
                  .height(48)
                  .borderRadius(100)
                  .interpolation(ImageInterpolation.High)
                  .transition(customAnimationUtil.isScaleTranIcon(10,this.uiConfig))
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
                    .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                    .backgroundColor($r('app.color.button_container_background'))
                    .fontColor(this.icon_emphasize)
                    .width(90)
                    .height(26)
                    .onClick(() => {
                      if (item.sign == 0) {
                        Xb_GoToWeb(item.link)
                      } else if (item.sign == 1) {
                        Xb_HandleMailto(item.link)
                      } else if (item.sign == 2) {
                        Xb_Copy(item.link)
                        promptAction.showToast({ message: `${getResourceString($r('app.string.qq_copy'), this)}：${item.link}`})
                      }
                    })
                  if(item.contact2) {
                    Button(item.contact2, { type: ButtonType.Capsule, stateEffect: true })
                           .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                      .backgroundColor($r('app.color.button_container_background'))
                      .fontColor(this.icon_emphasize)
                      .margin({left: 6})
                      .width(90)
                      .height(26)
                      .onClick(() => {
                        // 柯蓝KL Telegram
                        Xb_GoToWeb('https://xxxx')
                      })
                  }
                }
                .margin({top: 12})
                .width('100%')
                .justifyContent(FlexAlign.Start)
              }
            }
          }
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .backgroundColor($r('app.color.container_background'))
          .borderRadius(BORDER_RADIUS_20)
          .margin({bottom: 10 })
          .width('100%')
          .padding({left: 12, top: 12, bottom: 12})
        })
      }
      .width('100%')
      .alignListItem(ListItemAlign.Center)
      .contentEndOffset(CONTENT_END_OFFSET_150 - 85)
      .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
    }.width('100%')
    .backgroundColor($r('app.color.background'))
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.SettingsPageInfos.pop(true)
      return true
    })
  }
}

/**
 *  三方库与服务
 */
@Component
export struct ThirdServices {
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @State thirdServicesList: TCItemProp[] = ThirdServicesList
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()


  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.About'), subtitle: $r('app.string.third_party_services')})
      List({space: 10}) {
        ForEach(this.thirdServicesList, (item: TCItemProp, index: number) => {
          ListItem() {
            Column() {
              // 项目
              Text(`${getResourceString($r('app.string.Name'), this)}: ${item.title}`)
                .fontSize(17)
                .fontWeight(FontWeight.Medium)
              // 内容
              Text(`${getResourceString($r('app.string.project'), this)}: ${item.content}`)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .maxLines(1)
                .fontSize(17)
                .fontWeight(FontWeight.Normal)
                .margin({top: 2})
            }.width('100%')
            .margin({left: 12})
            .alignItems(HorizontalAlign.Start)
          }
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .backgroundColor($r('app.color.container_background'))
          .borderRadius(BORDER_RADIUS_20)
          .width('100%')
          .padding({left: 12, top: 12, bottom: 12})
          .onClick(() => {
            Xb_GoToWeb(getResourceString(item.content, this))
          })
        }, (item: TCItemProp) => getResourceString(item.title, this))
      }
      .width('100%')
      .alignListItem(ListItemAlign.Center)
      .contentEndOffset(CONTENT_END_OFFSET_150 - 85)
      .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
    }.width('100%')
    .backgroundColor($r('app.color.background'))
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.SettingsPageInfos.pop(true)
      return true
    })
  }
}

/**
 *  使用引导
 */
@Component
export struct UseGuidance {
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @State useGuidanceList: TCItemProp[] = UseGuidanceList
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()


  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.About'), subtitle: $r('app.string.UseGuidance')})
      List({space: 10}) {
        ForEach(this.useGuidanceList, (item: TCItemProp, index: number) => {
          ListItem() {
            Column() {
              // 项目
              Row() {
                Text('·')
                  .fontSize(32)
                  .fontWeight(FontWeight.Bolder)
                Text() {
                  Span(item.title)
                    .fontSize(17)
                    .fontWeight(FontWeight.Medium)
                }
              }.alignItems(VerticalAlign.Center)
              // 内容
              Image(item.content)
                .height(169)
                .width('100%')
                .borderRadius(BORDER_RADIUS_20)
            }.width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .backgroundColor($r('app.color.container_background'))
          .borderRadius(BORDER_RADIUS_20)
          .width('100%')
          .padding(12)
        }, (item: TCItemProp) => getResourceString(item.title, this))
      }
      .width('100%')
      .alignListItem(ListItemAlign.Center)
      .contentEndOffset(CONTENT_END_OFFSET_150 - 65)
      .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
    }.width('100%')
    .backgroundColor($r('app.color.background'))
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.SettingsPageInfos.pop(true)
      return true
    })
  }
}

/**
 *  常见问题
 */
@Component
export struct FAQ {
  @State FAQlist: TCItemProp[] = FAQList
  @State linkList: TCItemProp[] = LinkList
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.About'), subtitle: $r('app.string.FAQ')})
      List({space: 10}) {
        ListItem() {
          Row({space: 10}) {
            SymbolGlyph($r('sys.symbol.info_circle'))
              .fontSize(24)
              //.margin({left: 7})
              .fontColor([icon_primary])
            Flex({
              alignContent: FlexAlign.Start,
              direction: FlexDirection.Row,
              wrap: FlexWrap.Wrap,
            }) {
              Text() {
                Span($r('app.string.statement'))
                Span($r('app.string.third_party_services'))
                  .fontColor(this.icon_emphasize)
                  .onClick(() => {
                    this.SettingsPageInfos.pushPathByName('Three', false)
                  })
                Span($r('app.string.statement_1'))
              }.textAlign(TextAlign.JUSTIFY)
            }.width('88%')
          }.width('100%')
          .justifyContent(FlexAlign.Start)
        }.width('100%')
        .margin({top: 5})

        ListItem() {
          Flex({
            alignContent: FlexAlign.Start,
            direction: FlexDirection.Row,
            wrap: FlexWrap.Wrap,
          }) {
            Text($r('app.string.qa_tips'))
              .textAlign(TextAlign.JUSTIFY)
              .margin({top: 5, bottom: 5})
          }//.margin({left: 11})
        }

        ListItem() {
          Column(){
            Text('F&Q')
              .fontSize(16)
          }.width('100%')
          //.margin({left: 11})
          .alignItems(HorizontalAlign.Start)
        }.width('100%')
        // F&Q
        ForEach(this.FAQlist, (item: TCItemProp) => {
          ListItem() {
            Flex({
              direction: FlexDirection.Column,
              space: { main: LengthMetrics.vp(3)}
            }) {
              Flex({
                direction: FlexDirection.Row,
                space: { main: LengthMetrics.vp(3)},
                alignItems: ItemAlign.Center
              }) {
                Text('·')
                  .fontSize(32)
                  .fontWeight(FontWeight.Bolder)
                  .textIndent(2)
                Text(item.title)
                  .fontSize(17)
                  .fontWeight(FontWeight.Medium)
                 // .copyOption(CopyOptions.LocalDevice)
              }.width('96%')//.margin({left: 8})
              Text(item.content)
                .fontSize(15)
               // .margin({left: 11})
                .fontWeight(FontWeight.Regular)
                .copyOption(CopyOptions.LocalDevice)
                .textAlign(TextAlign.JUSTIFY)
            }.width('100%')
          }
        }, (item: TCItemProp) => getResourceString(item.title, this))
        // 附录
        ListItem() {
         Column({space: 3}) {
           Text($r('app.string.attach'))
             .fontSize(15)
             .fontWeight(FontWeight.Regular)
           // 转换链接
           ForEach(this.linkList, (item: TCItemProp, index: number) => {
             Row() {
               Text(`${getResourceString($r('app.string.link'), this)}${index + 1}：`)
                 .fontSize(15)
                 .fontWeight(FontWeight.Regular)
               Text(item.title)
                 .fontSize(15)
                 .fontColor(this.icon_emphasize)
                 .fontWeight(FontWeight.Regular)
                 .copyOption(CopyOptions.LocalDevice)
                 .decoration({
                   type: TextDecorationType.Underline,
                   color: this.icon_emphasize
                 })
                 .onClick(() => {
                   Xb_GoToWeb(item.content as string)
                 })
             }.width('100%')
           }, (item: TCItemProp) => getResourceString(item.title, this))

         }//.margin({left: 11})
          .alignItems(HorizontalAlign.Start)
        }.width('100%')

      }.width('100%')
      .contentEndOffset(85)
      .alignListItem(ListItemAlign.Center)
      .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
    }.width('100%')
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

  @State updateList: CheckUpdateListItemProp[] = []
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @Consume theAppVersionInfo: UpdateInfo

  async aboutToAppear(): Promise<void> {
    if (!this.uiConfig.autoCheckUpdate) {
      await this.checkUpdate()
    }
    this.updateList = getCheckUpdateList(this.theAppVersionInfo)
  }

  async checkUpdate() {
    // 检查版本更新
    try {
      const updateInfo = await getUpdateInfo()
      hilog.info(0xFF00, "UpdatetestTag", "Update Info: %{public}s", JSON.stringify(updateInfo))
      const theLatest = extractUpdateInfo(updateInfo)
      if (theLatest !== null) {
        promptAction.showToast({message: $r('app.string.query_success'), duration: 2000 })
        // 查询完成
        this.theAppVersionInfo = theLatest
      } else {
        hilog.info(0xFF00, "UpdatetestTag", "提取更新信息失败")
      }
    } catch (err) {
      // 处理错误情况
      const infoError = `Error:${JSON.stringify(err)}`
      hilog.info(0xFF00, "UpdatetestTag", "Info: %{public}s", infoError)
    }
  }

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Check_Updates')})
      Column({space: 10}) {
        ForEach(this.updateList, (item: CheckUpdateListItemProp, index: number) => {
          Column() {
            ForEach(item.children, (itemChild: CheckUpdateListItemProp, i: number) => {
              Column() {
                Row({space: 12}) {
                  // 图标
                  if(itemChild.icons) {
                    SymbolGlyph(itemChild.icons)
                      .fontSize(24)
                      .fontColor([this.icon_emphasize])
                  }
                  // 标题
                  Column({space: 2}) {
                    Text(itemChild.title)
                      .fontWeight(FontWeight.Medium)
                      .fontSize(16)
                    if(itemChild.subtitle && item.title != 'Version') {
                      Text(itemChild.subtitle)
                        .fontWeight(FontWeight.Normal)
                        .fontSize(14)
                    }
                  }.layoutWeight(1)
                  .constraintSize({minHeight: 49})
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Start)
                  Blank()
                  if(item.title === 'Version') {
                    Text(itemChild.subtitle)
                      .fontWeight(FontWeight.Normal)
                      .fontSize(14)
                  } else {
                    SymbolGlyph($r('sys.symbol.chevron_right'))
                      .fontSize(24)
                      .fontColor([icon_primary])
                  }
                }.width('100%')
                .padding({left: 12, right: 12, top: 5, bottom: 5})
                .justifyContent(FlexAlign.Start)
                //分割线
                if(!isEnd(item.children!.length,i))
                  Row().height(0.5).backgroundColor($r('app.color.divider')).width('93%')
              }
              .width('100%')
                   .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
              .onClick(() => {
                if(index === 1) {
                  // 前往下载网页
                  hilog.info(0xFF00, "checkUpdateTest", "前往下载网页")
                  Xb_GoToWeb('https://github.com/xiaobaigroup/ClashBox/releases')
                } else if(index === 3) {
                  // 忽略本次更新
                  promptAction.showToast({
                    message: $r('app.string.developing'),
                    duration: 2000
                  })
                } else if(index === 2) {
                  // 前往下载
                  if (this.theAppVersionInfo.browser_download_url === '') {
                    promptAction.showToast({
                      message: $r('app.string.no_link'),
                      duration: 2000
                    })
                  } else {
                    Xb_GoToWeb(this.theAppVersionInfo.browser_download_url)
                  }

                }
              })
            })
          }
          .width('100%')
          .backgroundColor($r('app.color.container_background'))
          .borderRadius(BORDER_RADIUS_20)
        })
        // 提示
        Text() {
          Span($r('app.string.check_update_tips'))
          Span(`Telegram${getResourceString($r('app.string.check_update_tips_2'), this)}`)
            .fontColor(this.icon_emphasize)
            .onClick(() => {
              Xb_GoToWeb('https://t.me/+ihe73JZWYb40NTY1')
            })
          Span($r('app.string.check_update_tips_1'))
        }
          .fontWeight(FontWeight.Normal)
          .fontSize(15)
      }
      .width('100%')
      .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
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


