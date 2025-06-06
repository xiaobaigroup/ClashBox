//主页 栅格布局、媒体查询
import { BreakpointState } from '../common/breakpoint/breakpointsystem'
import { curves, PromptAction } from '@kit.ArkUI'
import SwitchMode from '../components/Home/SwitchMode'
import CellularData from '../components/Home/CellularData'
import PublicNetwork from '../components/Home/PublicNetwork'
import Speed from '../components/Home/Speed'
import { getGreeting } from '../common/utils/GreetingUtil'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Timer } from '../common/utils/HHmmssTimer'
import {
  BIND_SHEET_CONTAINER_HEIGHT,
  TAB_CONTENT_TITLE_HEIGHT,
  showHomeCard,
  showHomeCardPC,
} from '../common/entity/Constants'
import Settings from '../components/Settings/Settings'
import CurrentNode from '../components/Home/CurrentNode'
import FavoriteProxy from '../components/Home/FavoriteProxy'
import FavoriteConfiguration from '../components/Home/FavoriteConfiguration'
import { CardEdit } from '../components/Home/CardEdit'
import ProxyINFO from '../components/Home/ProxyINFO'
import CurrentConfiguration from '../components/Home/CurrentConfiguration'
import ClashViewModel from '../entryability/ClashViewModel'
import Shortcuts from '../components/Home/Shortcuts'
import { AppConfig, UIConfig } from '../entryability/AppState'
import { ConfigData, HomeCardInfo } from '../common/entity/PageArgumentEntity'
import { customVibrator } from '../common/utils/VibratorUtil'
import { customAnimationUtil } from '../common/utils/Animation'
import { Profile, ProxyGroup, ProxyMode } from 'proxy_core'
import { ProxyGroupItemDataSource, ProxyItemDataSource } from '../common/datasources/ProxyData'
import { EventHub, EventKey } from '../common/EventHub'
import { PopTips, PopupBuilder } from '../components/Start/Popup'
import { getResourceString } from '../common/utils/ResourceStringUtil'
import { TopBar } from '../components/Common/TopBar'
import {
  HomeCardDeleteButtonSize,
  HomeCardGutter,
  HomeCardSpan346lg, HomeCardSpan346md, HomeCardSpan36sm,
  HomeGridRowPadding } from '../common/breakpoint/BreakPoint'


@Entry
@Component
struct Home {
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 是否开启 `Index` 页面的前景模糊
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  // 编辑按钮点击后显示编辑状态判定
  @Consume @Watch('ShowHomeEditChange') isShowHomeEdit: boolean
  // 前台判断变量
  @Consume @Watch('onForeward') isForeward: boolean
  @Consume isSmallSquareScreen: boolean
  // 删除按钮是否出现判定
  @Consume isShowDeleteButton: boolean
  // 平板横屏
  @Consume istabletLandscape: boolean
  // 设置模态页控制变量
  @Consume @Watch('ShowHomeEditChange') isShowSettings: boolean
  // 是否为PX外屏
  @Consume isPXSecScreen: boolean
  // 代理启动按钮状态
  @Consume proxyEnabled: boolean
  @Consume isRolling: boolean

  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageLink ('isLandscapePhone') @Watch('isLandscapePhoneScrollTo') isLandscapePhone: boolean = false
  // 折叠屏展开状态判定
  @StorageLink ('isFoldStatus') isFoldStatus: boolean = false
  // 窗口模式区分，true为窗口式，false为普通式
  @StorageProp('WindowMode') windowMode: boolean = false
  // 2in1判定
  @StorageLink ('2in1') is2in1: boolean = false
  // 主页半模态页
  @State showHomeSheet: boolean = false

  // 所有子组件在容器内的对齐方式
  @Consume ('stackAlignContentAlignment') stackAlignContentAlignment: Alignment
  // 设置页面栈
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack

  private promptAction: PromptAction = this.getUIContext()?.getPromptAction()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 滚动控制
  private scrollerForScroll: Scroller = new Scroller()

  // 代理页分组数据（懒加载）
  @Consume proxyGroups: ProxyGroupItemDataSource
  // 节点数据
  @Consume proxyLazyItems: ProxyItemDataSource
  // 配置页数据表
  @Consume configList: Array<ConfigData>
  // 当前主页布局
  @Consume theCurrentHomeCard: boolean[]
  // 节点数据组
  @Consume theProxyGroups: ProxyGroup[]
  // 上一次主页布局
  @Consume theLastHomeCard: boolean[]

  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 按钮宽度
  // @State  proxyStartButtonWidth: Length = $r('app.integer.vp_proxy_not_start_button_width')
  // 按钮高度
  @State  proxyStartButtonHeight: Length = $r('app.integer.vp_proxy_not_start_button_height')
  // 页面名称 主页
  private componentName: string = 'HomePage'
  // 代理启动持续的时间
  @Consume proxyStartingDuration: string

  @Consume curOffsetRemain: number
  // 恢复时刻
  @Consume theRestoreTime: number
  // 暂停时刻
  @Consume thePauseTime: number
  @Consume rotateAngle : number
  // page内顶部标题偏移量
  @Consume curYOffset: number
  // px外屏隐藏top和tab偏移
  @Consume heightTop: number

  @Consume ("currentProfile") currentProfile: Profile | null
  // 定时器Controller
  @Consume proxyStartedTimer: Timer


  // 按钮前Symbol动效
  // ReplaceSymbolEffect: SymbolEffect = EffectScope.WHOLE

  build() {
    Stack() {
      if (!this.isLandscapePhone) {
        Row() {
          if (!this.isShowHomeEdit) {
            // 编辑布局按钮判定：非编辑状态
            // 顶栏
            TopBar({
              title: this.uiConfig.isGreeting ? getResourceString(getGreeting(), this) : 'ClashBox',
              icons: [$r('sys.symbol.square_and_pencil'), $r('sys.symbol.gearshape')],
              iconSize: this.windowMode ? 16 : 24,
              // 编辑按钮
              onFClick: () => {
                this.isShowHomeEdit = true
                // 编辑布局前储存之前的布局变量
                hilog.info(0xFF00, "HometestTag", "上一次布局1： %{public}s", JSON.stringify(this.theLastHomeCard))
                this.theLastHomeCard = JSON.parse(this.uiConfig.isShowHomeCard)
                hilog.info(0xFF00, "HometestTag", "上一次布局2： %{public}s", JSON.stringify(this.theLastHomeCard))
                if (this.uiConfig.isAnimation) {
                  animateTo({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear }, () => {
                    this.isShowDeleteButton = true
                  })
                } else {
                  this.isShowDeleteButton = true
                }
              },
              // 设置按钮
              onSClick: () => {
                this.isShowSettings = true
                this.showHomeSheet = true
                this.isEnableIndexForegroundBlur = true
              }
            })
          } else {
            // 编辑布局按钮判定：是编辑状态
            TopBar({
              title: `${getResourceString($r('app.string.home_edit'), this)}`,
              titleFontSize: this.windowMode ? 20 : 24,
              icons: [$r('sys.symbol.plus'), $r('sys.symbol.save'), $r('sys.symbol.xmark')],
              // 添加按钮
              onFClick: () => {
                this.isShowSettings = false
                this.showHomeSheet = true
                this.isEnableIndexForegroundBlur = true
              },
              onSClick: () => {
                this.saveHomeLayout()
              },
              onTClick: () => {
                if (this.SaveDialogController != null) {
                  this.SaveDialogController.open()
                  this.isEnableIndexForegroundBlur = true
                }
              }
            })
          }

        }
        .zIndex(1)
        .position({x: 0,y:this.isRolling && this.isSmallSquareScreen?this.heightTop:0})
        .width('100%')
        .geometryTransition("Button")
      }

      Stack({ alignContent: this.stackAlignContentAlignment }) {
        // 主页卡片层
        Column() {
          Blank()
            .height(this.isLandscapePhone || (this.isRolling && this.isSmallSquareScreen) ? this.heightTop : this.istabletLandscape ? 72 : TAB_CONTENT_TITLE_HEIGHT)
          Scroll() {
            Column() {
              GridRow({
                gutter: HomeCardGutter(this.widthBp, this.heightBp),
              })
              {
                ForEach(this.homeCardList(), (item: HomeCardInfo, index: number) => {
                  HomeCard({
                    item: item,
                    index: index
                  })
                }, (item: HomeCardInfo, index: number) => `${item.order}${index}`)
              }
              Blank().height(100)
            }
          }
          .layoutWeight(1)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .padding(HomeGridRowPadding(this.widthBp, this.heightBp))
          // .enableScrollInteraction(!this.windowMode)
          .margin({ top: this.isLandscapePhone ? 7 : 0 })
          .edgeEffect(this.uiConfig.isAnimation ? EdgeEffect.Spring : null)
          .onScrollFrameBegin((offset: number) => {
            if (!this.windowMode) {
              this.curOffsetRemain  += offset
              if (offset > 0) {
                this.isRolling = true
              } else if(offset < 0) {
                this.isRolling = false
                this.curOffsetRemain = 0
              }
              console.info("offsetRemain:" + offset + '/' +this.curOffsetRemain);
              return { offsetRemain: offset }
            } else {
              return { offsetRemain: 0 }
            }
          })
          .onDidScroll((xOffset: number, yOffset: number, scrollState: ScrollState): void => {
            if (!this.windowMode) {
              // 累计计算当前父组件滚动在Y轴方向的偏移量
              if (this.uiConfig.isAnimation){
                this.curYOffset += yOffset
              }
              console.info("yOffset:" + yOffset)
            }
          })
        }
        // 代理启动按钮层
        if (!this.isShowHomeEdit) {
          Column() {
            Row() {
              Stack({ alignContent: Alignment.Center }) {
                SymbolGlyph(this.proxyEnabled ? $r('sys.symbol.pause') : $r('sys.symbol.play_fill'))
                  .fontSize(24)
                  .fontColor([Color.White])
                  .align(Alignment.Center)
                  .effectStrategy(customAnimationUtil.isIconEffect(this.uiConfig))
              }
              .width(this.proxyStartButtonHeight)
              .height(this.proxyStartButtonHeight)
              // 计时器文本
              Text(this.proxyStartingDuration)
                .fontSize(20)// 使用透明度控制是否显示计时器，是因为用 `visibility` 来控制的话，不显示的时间长了之后，再次显示时候会延迟一秒，体验不好
                .fontColor(this.proxyEnabled ? Color.White : Color.Transparent)
                .fontWeight(FontWeight.Bold)
            }.width('100%')
          }
          .borderRadius(100)
          .transition(customAnimationUtil.isSlideSwitch(this.uiConfig))
          .backgroundColor(this.icon_emphasize)
          .shadow({
            radius: 10,
            color: this.icon_emphasize,
            offsetY: 4,
            type: ShadowType.BLUR
          })
          .margin({
            bottom: this.isLandscapePhone || this.istabletLandscape || !this.uiConfig.isBlurr || (this.isRolling && this.isSmallSquareScreen) ? $r('app.integer.vp_proxy_start_button_left_right_margin') : $r('app.integer.vp_proxy_start_button_bottom_margin'),
            right:$r('app.integer.vp_proxy_start_button_left_right_margin'),
            left:$r('app.integer.vp_proxy_start_button_left_right_margin')
          })
          .width(this.proxyEnabled ? $r('app.integer.vp_proxy_started_button_width') : $r('app.integer.vp_proxy_not_start_button_width'))
          .height(this.proxyStartButtonHeight)
          .clip(true)
          .onClick(async (event: ClickEvent) => {
            if(this.configList.length === 0 || this.theProxyGroups.length === 0) {
              if (this.uiConfig.isVibrate) {
                customVibrator.vibratorTriggerOfHapticClockTimer()
              }
              // 配置页没有数据，或者代理节点未加载
              this.promptAction.showToast({ message: `${getContext().resourceManager.getStringSync($r('app.string.start_prompt'))}` })
              // vpn小钥匙可能卡死，关闭vpn小钥匙
              await ClashViewModel.StopVpn()
            } else {
              hilog.info(0xA002, this.componentName, `主页按钮点击事件 代理启动按钮状态：${this.proxyEnabled}`)
              this.proxyEnabled = !this.proxyEnabled
              if (this.proxyEnabled) {
                await ClashViewModel.StartVpn()
              } else {
                await ClashViewModel.StopVpn()
              }
              if (this.uiConfig.isVibrate) {
                customVibrator.vibratorTriggerOfHapticClockTimer()
              }
            }
          })
          .animation(this.uiConfig.isAnimation?{ duration: this.uiConfig.animationSpeed,curve:curves.springMotion() }:null)
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .bindPopup(!!this.uiConfig.ShowStartPop, {
            builder: PopupBuilder(this, PopTips[0], () => {
              this.uiConfig.ShowStartPop = false
            }),
            onWillDismiss: false,
            autoCancel: false
          })
        }
      }
      .backgroundColor($r('app.color.background'))
      .height('100%' )
      .width("100%")
      .bindSheet($$this.showHomeSheet, this.HomeSheet(), {
        detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.LARGE],
        preferType: SheetType.CENTER,
        scrollSizeMode: ScrollSizeMode.CONTINUOUS,
        backgroundColor: $r('app.color.background'),
        dragBar: false,
        title: this.isShowSettings ? undefined : { title: $r('app.string.add_home_card') },
        keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
        onWillDismiss: () => {
          this.isShowSettings = false
          this.showHomeSheet = false
          this.isEnableIndexForegroundBlur = false
          this.SettingsPageInfos.clear()
        }
      })
    }.width('100%').height('100%')
  }


  @Builder
  HomeSheet() {
    if (this.isShowSettings) {
      // 设置模态界面
      Column() {
        Settings()
      }
      .width('100%')
      .height('100%')
    } else {
      // 卡片编辑半模态
      CardEdit()
    }
  }

  /**是否保存布局弹窗*/
  SaveDialogController: CustomDialogController | null = new CustomDialogController({
    builder: SaveCustomDialog({
      cancel: () => {
        this.onCancel()
        animateTo({ duration: 0,iterations:0 }, () => {
          this.rotateAngle = 0
        })
      },
      confirm: () => {
        this.onAccept()
        animateTo({ duration: 0,iterations:0 }, () => {
          this.rotateAngle = 0
        })
      }
    }),
    cancel: this.existApp,
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: false,
    cornerRadius: 32,
  })

  aboutToAppear(): void {
    // 初始化主页卡片布局
    if (this.uiConfig.isShowHomeCard)
      this.theCurrentHomeCard = JSON.parse(this.uiConfig.isShowHomeCard)
    hilog.info(0xFF00, "HometestTag", "布局初始化为： %{public}s", JSON.stringify(this.theCurrentHomeCard))
    EventHub.on(EventKey.SwitchModeCard, async (mode: ProxyMode) => {
      // 清空数据
      this.proxyGroups.empty()
      this.proxyLazyItems.empty()
      if (this.currentProfile) {
        await ClashViewModel.loadConfig(true)
        // 写入数据
        this.theProxyGroups = await ClashViewModel.getProxyGroups(mode)
        this.proxyGroups.pushData(this.theProxyGroups)
      }
    })

    // 只有当PC首次启动时重置主页布局
    if (this.is2in1 && this.uiConfig.isShowHomeCard === JSON.stringify(showHomeCard)) {
      this.theCurrentHomeCard = showHomeCardPC
      // 更新PC布局持久化, 避免二次启动重复调用覆盖
      this.uiConfig.isShowHomeCard = JSON.stringify(showHomeCardPC)
    }

  }

  aboutToDisappear() {
    // 将dialogController置空
    this.SaveDialogController = null
    EventHub.off(EventKey.SwitchModeCard)
  }

  homeCardList(): HomeCardInfo[] {
    return [
      { // 网络速度小卡片
        aspectRatio: 2.07,
        order: 1
      },
      { // 分流模式小卡片
        aspectRatio: 1,
        order: 2
      },
      { // 流量统计小卡片
        aspectRatio: 1,
        order: 3
      },
      { // 当前节点小卡片
        aspectRatio: 1,
        order: 4
      },
      { // IP地址小卡片
        aspectRatio: 1,
        order: 5
      },
      { // 收藏节点小卡片
        aspectRatio: 1,
        order: 6
      },
      { // 收藏配置小卡片
        aspectRatio: 1,
        order: 7
      },
      { // 节点信息小卡片
        order: 8/*HomeCardProxyInfoOrder(this.widthBp, this.heightBp)*/,
        aspectRatio: 2.07,
      },
      { // 当前配置小卡片
        aspectRatio: 1,
        order: 9
      },
      { // 快捷方式小卡片
        aspectRatio: 1,
        order: 10
      }
    ]
  }

  // 在自定义组件即将析构销毁时将dialogController置空
  onCancel() {
    this.restoreLayout()
    this.isEnableIndexForegroundBlur = false
    hilog.info(0xA000, this.componentName, '#onCancel: Callback when the first button is clicked')
  }

  onAccept() {
    this.saveHomeLayout()
    this.isEnableIndexForegroundBlur = false
    hilog.info(0xA000, this.componentName, '#onAccept: Callback when the second button is clicked')
  }

  existApp() {
    this.isEnableIndexForegroundBlur = false
    hilog.info(0xA000, this.componentName, '#existApp: Click the callback in the blank area')
  }

  /**横屏HOME页滚动到中间*/
  isLandscapePhoneScrollTo() {
    if (this.isLandscapePhone) {
      this.scrollerForScroll.scrollTo({xOffset: 0,yOffset: '50%',animation: true})
    }
  }

  // 卡片摇摆动画
  startAnim() {
    this.rotateAngle = 0
    animateTo({
      duration: this.uiConfig.animationSpeed,
      curve: Curve.Linear,
      iterations:-1,
      playMode:PlayMode.Alternate
    }, () => {
      this.rotateAngle = 1
    })
  }

  stopAnim() {
    animateTo({
      delay: 0,
      duration: 0,
      iterations: 0,
      curve: Curve.Linear,
    }, () => {
      this.rotateAngle = 0
    })
  }

  /**保存主页卡片布局*/
  saveHomeLayout() {
    // 保存布局
    this.uiConfig.isShowHomeCard = JSON.stringify(this.theCurrentHomeCard)
    hilog.info(0xFF00, "HometestTag", "保存的布局： %{public}s", this.uiConfig.isShowHomeCard)
    this.promptAction.showToast({ message: `${getContext().resourceManager.getStringSync($r('app.string.layout_saved'))}💾` })
    this.isShowHomeEdit = false
    if (this.uiConfig.isAnimation) {
      animateTo({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear }, () => {
        this.isShowDeleteButton = false
      })
    } else { this.isShowDeleteButton = false }
  }

  /**还原主页卡片布局*/
  restoreLayout() {
    // 还原布局
    this.theCurrentHomeCard = this.theLastHomeCard
    this.uiConfig.isShowHomeCard = JSON.stringify(this.theLastHomeCard)
    hilog.info(0xFF00, "HometestTag", "布局还原为： %{public}s", JSON.stringify(this.theCurrentHomeCard))
    this.promptAction.showToast({ message: `${getContext().resourceManager.getStringSync($r('app.string.layout_restored'))}🫡` })
    this.isShowHomeEdit = false
    animateTo({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear }, () => {
      this.isShowDeleteButton = false
    })
  }

  /**卡片编辑页面显示监听*/
  ShowHomeEditChange() {
    hilog.info(0xFF00, "HometestTag", "进入卡片编辑页面显示监听  %{public}s")
    // 展示编辑页时才触发
    if (!this.isShowSettings) {
      // 当编辑页面由 true -> false 时触发抖动动画刷新
      if(this.isShowHomeEdit && !this.isShowSettings) {
        hilog.info(0xFF00, "HometestTag", "进入卡片编辑页面显示监听，true -> false  %{public}s")
        this.stopAnim()
        this.startAnim()
      } else {
        this.stopAnim()
      }
    }
  }

  onForeward() {
    if (this.proxyEnabled) {
      if(!this.isForeward) {
        // 页面不处于前台时暂停计时
        this.proxyStartedTimer.pause()
        hilog.info(0xFF00, "TimertestTag", "计时器暂停此时的时间：%{private}s", this.proxyStartingDuration)
      } else {
        // 二次启动计时
        let gapTime = this.theRestoreTime - this.thePauseTime
        hilog.info(0xFF00, "TimertestTag", "需要增加的时间： %{private}d", gapTime)
        this.proxyStartedTimer.resumeWithExtraTime(gapTime)
      }
    }
  }

}

export default Home

@Component
struct HomeCard {

  @Prop index: number
  @Prop item: HomeCardInfo
  @Consume rotateAngle : number
  // 删除按钮是否出现判定
  @Consume isShowDeleteButton: boolean
  // 当前主页布局
  @Consume theCurrentHomeCard: boolean[]
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0

  build() {
    if (this.theCurrentHomeCard[this.index]) {
      GridCol({
        span: {
          sm: HomeCardSpan36sm(this.widthBp, this.heightBp) * (this.index == 0 || this.index == 7 ? 2 : 1),
          md: HomeCardSpan346md(this.widthBp, this.heightBp) * (this.index == 0 || this.index == 7 ? 2 : 1),
          lg: HomeCardSpan346lg(this.widthBp, this.heightBp) * (this.index == 0 || this.index == 7 ? 2 : 1)
        },
        // order: this.item.order
      })
      {
        Stack({ alignContent: Alignment.TopEnd }) {
          // Column() {
          //   Text(`实际sm: ${HomeCardSpan36sm(this.widthBp, this.heightBp)} 实际md: ${HomeCardSpan346md(this.widthBp, this.heightBp)} 实际lg: ${HomeCardSpan346lg(this.widthBp, this.heightBp)}`)
          // }
          this.HomeCardContent(this.index)
          if (this.isShowDeleteButton) {
            DeleteButton()
              .position({ x: '95%', y: -4 })
              .onClick(() => {
                animateTo({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear }, () => {
                  this.theCurrentHomeCard.splice(this.index, 1, false)
                })
                hilog.info(0xFF00, "HometestTag", "网络速率卡片: %{public}s", this.uiConfig.isShowHomeCard[this.index])
              })
          }
        }
      }.height(160)
      .borderRadius(20)
      .aspectRatio(this.item.aspectRatio)
      .backgroundColor($r('app.color.container_background'))/*.borderWidth(2).borderColor(Color.Red)*/
      .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
      .transition(customAnimationUtil.isScaleTran(1, this.uiConfig))
      // 消失触发回调
      .onDetach(() => {})
      // 显示时触发回调
      .onAttach(() => {})
      // 编辑模式下跳动动画
      .rotate({ angle: this.uiConfig.isAnimation ? this.rotateAngle : null })
    }
  }

  @Builder
  HomeCardContent(index: number) {
    if (index == 0) {
      Speed()
    } else if (index == 1) {
      SwitchMode()
    } else if (index == 2) {
      CellularData()
    } else if (index == 3) {
      CurrentNode()
    } else if (index == 4) {
      PublicNetwork()
    } else if (index == 5) {
      FavoriteProxy()
    } else if (index == 6) {
      FavoriteConfiguration()
    } else if (index == 7) {
      ProxyINFO()
    } else if (index == 8) {
      CurrentConfiguration()
    } else if (index == 9) {
      Shortcuts()
    }
  }

}

/**
 * 保存样式和内容弹窗控制器
 */
@CustomDialog
struct SaveCustomDialog {
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  controller?: CustomDialogController
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean

  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  build() {
    Column() {
      Text($r('app.string.home_save_layout'))
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))

      Row() {
        Button($r('app.string.Give_Up'))
          .fontSize(16)
          .width(144)
          .fontColor(Color.Red)
          .backgroundColor('#00ffffff')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
            }
            this.cancel()
            this.isEnableIndexForegroundBlur = false
          })
        Blank(8)
        Button($r('app.string.Save'))
          .fontSize(16)
          .width(144)
          .backgroundColor(this.icon_emphasize)
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
            }
            this.confirm()
            this.isEnableIndexForegroundBlur = false
          })
      }.padding({ top: 23 })
    }
    .width('100%')
    .height(undefined)
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('app.color.container_background'))
    .padding({ top: 16, bottom: 16 })
  }



}

// 小卡片共有属性
@Extend(GridCol)
function GridColStyle() {
  .aspectRatio(1)
  .borderRadius(20)
  .backgroundColor($r('app.color.container_background'))
}

// 网络测速大卡片里的删除按钮
@Component
struct DeleteButton {
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageLink ('isLandscapePhone') private isLandscapePhone: boolean = false
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 折叠屏展开状态判定
  @StorageLink ('isFoldStatus') private isFoldStatus: boolean = false
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  build() {
    Button() {
      SymbolGlyph($r('sys.symbol.xmark'))
        .fontSize(16)
        .fontColor(['#fff'])
    }
    .borderRadius(20)
    .width(HomeCardDeleteButtonSize(this.widthBp, this.heightBp))
    .height(HomeCardDeleteButtonSize(this.widthBp, this.heightBp))
    .backgroundColor('#ffe84026')
    .transition(this.uiConfig.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: this.uiConfig.animationSpeed,curve:curves.springMotion() }):null)
  }
}


/*// 网络速度小卡片
               if (this.theCurrentHomeCard[0]) {
                 GridCol({
                   span: {
                     xs: this.isLandscapePhone ? 6 : 12,
                     sm: this.isLandscapePhone ? 6 : 12,
                     md: this.isLandscapePhone ? 6 : this.isFoldStatus ? 8 : 12,
                     lg: this.isFoldStatus ? 8 : this.isLandscapePhone || this.istabletLandscape ? 6 : 12
                   },
                   order: 1
                 })
                 {
                   Stack({ alignContent: Alignment.TopEnd }) {
                     Speed()
                     if (this.isShowDeleteButton) {
                       DeleteButton1()
                         .position({ x: '95%', y: -4 })
                         .onClick(() => {
                           animateTo({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear }, () => {
                             // 将序号0变为false
                             this.theCurrentHomeCard.splice(0, 1, false)
                           })
                           hilog.info(0xFF00, "HometestTag", "网络速率卡片： %{public}s",
                             this.uiConfig.isShowHomeCard[0])
                         })
                     }
                   }
                 }
                 .aspectRatio(2.07)
                 .borderRadius(20)
                 .backgroundColor($r('app.color.container_background'))
                 .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                 .transition(customAnimationUtil.isScaleTran(1, this.uiConfig))
                 .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                 // 消失触发回调
                 .onDetach(() => {})
                 // 显示时触发回调
                 .onAttach(() => {})
                 // 编辑模式下跳动动画
                 .rotate({ angle: this.uiConfig.isAnimation ? this.rotateAngle : null })
               }

               // 分流模式小卡片
               if (this.theCurrentHomeCard[1]) {
                 GridCol({
                   span: {
                     xs: this.isLandscapePhone ? 3 : 6,
                     sm: this.isLandscapePhone ? 3 : 6,
                     md: this.isLandscapePhone ? 3 : this.isFoldStatus ? 4 : 6,
                     lg: this.isFoldStatus ? 4 : this.isLandscapePhone || this.istabletLandscape ? 3 : 6
                   },
                   order: 2
                 }) {
                   Stack({ alignContent: Alignment.TopEnd }) {
                     SwitchMode()
                     if (this.isShowDeleteButton) {
                       DeleteButton2()
                         .position({ x: '90%', y: -4 })
                         .onClick(() => {
                           animateTo({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear }, () => {
                             // 将序号1变为false
                             this.theCurrentHomeCard.splice(1, 1, false)
                           })
                           hilog.info(0xFF00, "HometestTag", "分流模式卡片： %{public}s",
                             this.uiConfig.isShowHomeCard[1])
                         })
                     }
                   }
                 }
                 .GridColStyle()
                 .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                 .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                 .transition(customAnimationUtil.isScaleTran(2, this.uiConfig))
                 //.transition(this.uiConfig.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: this.uiConfig.animationSpeed,delay:20 }):null)
                 //编辑模式下跳动动画
                 .rotate({ angle: this.uiConfig.isAnimation ? this.rotateAngle : null })
                 // 消失触发回调
                 .onDetach(() => {
                 })
               }

               //流量统计小卡片
               if (this.theCurrentHomeCard[2]) {
                 GridCol({
                   span: {
                     xs: this.isLandscapePhone ? 3 : 6,
                     sm: this.isLandscapePhone ? 3 : 6,
                     md: this.isLandscapePhone ? 3 : this.isFoldStatus ? 4 : 6,
                     lg: this.isFoldStatus ? 4 : this.isLandscapePhone || this.istabletLandscape ? 3 : 6
                   },
                   order: 3
                 }) {
                   Stack({ alignContent: Alignment.TopEnd }) {
                     CellularData()
                     if (this.isShowDeleteButton) {
                       DeleteButton2()
                         .position({ x: '90%', y: -4 })
                         .onClick(() => {
                           animateTo({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear }, () => {
                             // 将序号2变为false
                             this.theCurrentHomeCard.splice(2, 1, false)
                           })
                         })
                     }
                   }
                 }
                 //   .margin({ left: this.containerMargin.value })
                 .GridColStyle()
                 .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                 .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                 .transition(customAnimationUtil.isScaleTran(3, this.uiConfig))
                 // .transition(this.uiConfig.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: this.uiConfig.animationSpeed,delay:30 }):null)
                 //编辑模式下跳动动画
                 .rotate({ angle: this.uiConfig.isAnimation ? this.rotateAngle : null })
                 // 消失触发回调
                 .onDetach(() => {
                 })
               }

               //当前节点小卡片
               if (this.theCurrentHomeCard[3]) {
                 GridCol({
                   span: {
                     xs: this.isLandscapePhone ? 3 : 6,
                     sm: this.isLandscapePhone ? 3 : 6,
                     md: this.isLandscapePhone ? 3 : this.isFoldStatus ? 4 : 6,
                     lg: this.isFoldStatus ? 4 : this.isLandscapePhone || this.istabletLandscape ? 3 : 6
                   },
                   order: 4
                 }) {
                   Stack({ alignContent: Alignment.TopEnd }) {
                     CurrentNode()
                     if (this.isShowDeleteButton) {
                       DeleteButton2()
                         .position({ x: '90%', y: -4 })
                         .onClick(() => {
                           animateTo({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear }, () => {
                             // 将序号3变为false
                             this.theCurrentHomeCard.splice(3, 1, false)
                           })
                         })
                     }
                   }
                 }
                 .GridColStyle()
                 .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                 .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                 .transition(customAnimationUtil.isScaleTran(4, this.uiConfig))
                 //.transition(this.uiConfig.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: this.uiConfig.animationSpeed,delay:40 }):null)
                 //编辑模式下跳动动画
                 .rotate({ angle: this.uiConfig.isAnimation ? this.rotateAngle : null })
                 // 消失触发回调
                 .onDetach(() => {

                 })
               }

               //IP地址小卡片
               if (this.theCurrentHomeCard[4]) {
                 GridCol({
                   span: {
                     xs: this.isLandscapePhone ? 3 : 6,
                     sm: this.isLandscapePhone ? 3 : 6,
                     md: this.isLandscapePhone ? 3 : this.isFoldStatus ? 4 : 6,
                     lg: this.isFoldStatus ? 4 : this.isLandscapePhone || this.istabletLandscape ? 3 : 6
                   },
                   order: 5
                 }) {
                   Stack({ alignContent: Alignment.TopEnd }) {
                     PublicNetwork()
                     if (this.isShowDeleteButton) {
                       DeleteButton2()
                         .position({ x: '90%', y: -4 })
                         .onClick(() => {
                           animateTo({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear }, () => {
                             // 将序号4变为false
                             this.theCurrentHomeCard.splice(4, 1, false)
                           })
                         })
                     }
                   }
                 }
                 .GridColStyle()
                 .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                 .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                 .transition(customAnimationUtil.isScaleTran(5, this.uiConfig))
                 // .transition(this.uiConfig.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: this.uiConfig.animationSpeed,delay:60 }):null)
                 //编辑模式下跳动动画
                 .rotate({ angle: this.uiConfig.isAnimation ? this.rotateAngle : null })
                 // 消失触发回调
                 .onDetach(() => {
                 })
               }

               //收藏节点小卡片
               if (this.theCurrentHomeCard[5]) {
                 GridCol({
                   span: {
                     xs: this.isLandscapePhone ? 3 : 6,
                     sm: this.isLandscapePhone ? 3 : 6,
                     md: this.isLandscapePhone ? 3 : this.isFoldStatus ? 4 : 6,
                     lg: this.isFoldStatus ? 4 : this.isLandscapePhone || this.istabletLandscape ? 3 : 6
                   },
                   order: 6
                 }) {
                   Stack({ alignContent: Alignment.TopEnd }) {
                     FavoriteProxy()
                     if (this.isShowDeleteButton) {
                       DeleteButton2()
                         .position({ x: '90%', y: -4 })
                         .onClick(() => {
                           animateTo({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear }, () => {
                             // 将序号5变为false
                             this.theCurrentHomeCard.splice(5, 1, false)
                           })
                         })
                     }
                   }
                 }
                 .GridColStyle()
                 .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                 .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                 .transition(customAnimationUtil.isScaleTran(6, this.uiConfig))
                 //.transition(this.uiConfig.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: this.uiConfig.animationSpeed,delay:70 }):null)
                 //编辑模式下跳动动画
                 .rotate({ angle: this.uiConfig.isAnimation ? this.rotateAngle : null })
                 // 消失触发回调
                 .onDetach(() => {
                 })
               }

               //收藏配置小卡片
               if (this.theCurrentHomeCard[6]) {
                 GridCol({
                   span: {
                     xs: this.isLandscapePhone ? 3 : 6,
                     sm: this.isLandscapePhone ? 3 : 6,
                     md: this.isLandscapePhone ? 3 : this.isFoldStatus ? 4 : 6,
                     lg: this.isFoldStatus ? 4 : this.isLandscapePhone || this.istabletLandscape ? 3 : 6
                   },
                   order: 7
                 }) {
                   Stack({ alignContent: Alignment.TopEnd }) {
                     FavoriteConfiguration()
                     if (this.isShowDeleteButton) {
                       DeleteButton2()
                         .position({ x: '90%', y: -4 })
                         .onClick(() => {
                           animateTo({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear }, () => {
                             // 将序号6变为false
                             this.theCurrentHomeCard.splice(6, 1, false)
                           })
                         })
                     }
                   }
                 }
                 .GridColStyle()
                 .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                 .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                 .transition(customAnimationUtil.isScaleTran(7, this.uiConfig))
                 // .transition(this.uiConfig.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: this.uiConfig.animationSpeed,delay:80 }):null)
                 //编辑模式下跳动动画
                 .rotate({ angle: this.uiConfig.isAnimation ? this.rotateAngle : null })
                 // 消失触发回调
                 .onDetach(() => {
                 })
               }

               // 节点信息小卡片
               if (this.theCurrentHomeCard[7]) {
                 GridCol({
                   span: {
                     xs: this.isLandscapePhone ? 6 : 12,
                     sm: this.isLandscapePhone ? 6 : 12,
                     md: this.isLandscapePhone ? 6 : this.isFoldStatus ? 8 : 12,
                     lg: this.isFoldStatus ? 8 : this.isLandscapePhone || this.istabletLandscape ? 6 : 12
                   },
                   order: this.isFoldStatus ? 3 : 1
                 }) {
                   Stack({ alignContent: Alignment.TopEnd }) {
                     ProxyINFO()
                     if (this.isShowDeleteButton) {
                       DeleteButton1()
                         .position({ x: '95%', y: -4 })
                         .onClick(() => {
                           animateTo({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear }, () => {
                             // 将序号7变为false
                             this.theCurrentHomeCard.splice(7, 1, false)
                           })
                         })
                     }
                   }
                 }
                 .aspectRatio(2.07)
                 .borderRadius(20)
                 .backgroundColor($r('app.color.container_background'))
                 .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                 .transition(customAnimationUtil.isScaleTran(8, this.uiConfig))
                 .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                 //编辑模式下跳动动画
                 .rotate({ angle: this.uiConfig.isAnimation ? this.rotateAngle : null })
                 // 消失触发回调
                 .onDetach(() => {
                 })
               }

               //当前配置小卡片
               if (this.theCurrentHomeCard[8]) {
                 GridCol({
                   span: {
                     xs: this.isLandscapePhone ? 3 : 6,
                     sm: this.isLandscapePhone ? 3 : 6,
                     md: this.isLandscapePhone ? 3 : this.isFoldStatus ? 4 : 6,
                     lg: this.isFoldStatus ? 4 : this.isLandscapePhone || this.istabletLandscape ? 3 : 6
                   },
                   order: 4
                 }) {
                   Stack({ alignContent: Alignment.TopEnd }) {
                     CurrentConfiguration()
                     if (this.isShowDeleteButton) {
                       DeleteButton2()
                         .position({ x: '90%', y: -4 })
                         .onClick(() => {
                           animateTo({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear }, () => {
                             // 将序号8变为false
                             this.theCurrentHomeCard.splice(8, 1, false)
                           })
                         })
                     }
                   }
                 }
                 .GridColStyle()
                 .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                 .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                 // .transition(this.uiConfig.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: this.uiConfig.animationSpeed ,delay:50}):null)
                 .transition(customAnimationUtil.isScaleTran(9, this.uiConfig))
                 //编辑模式下跳动动画
                 .rotate({ angle: this.uiConfig.isAnimation ? this.rotateAngle : null })
                 // 消失触发回调
                 .onDetach(() => {
                 })
               }

               //快捷方式小卡片
               if (this.isFoldStatus && !this.is2in1 ? !this.theCurrentHomeCard[9] : this.theCurrentHomeCard[9]) {
                 GridCol({
                   span: {
                     xs: this.isLandscapePhone ? 3 : 6,
                     sm: this.isLandscapePhone ? 3 : 6,
                     md: this.isLandscapePhone ? 3 : this.isFoldStatus ? 4 : 6,
                     lg: this.isFoldStatus ? 4 : this.isLandscapePhone || this.istabletLandscape ? 3 : 6
                   },
                   order: 8
                 }) {
                   Stack({ alignContent: Alignment.TopEnd }) {
                     Shortcuts()
                     if (this.isShowDeleteButton) {
                       DeleteButton2()
                         .position({ x: '90%', y: -4 })
                         .onClick(() => {
                           animateTo({ duration: this.uiConfig.animationSpeed, curve: Curve.Linear }, () => {
                               // 将序号9变为false
                               this.theCurrentHomeCard.splice(9, 1,this.isFoldStatus && !this.is2in1 ? true : false)
                             console.info('快捷卡片判定',this.theCurrentHomeCard[9])
                           })
                         })
                         .onAppear(()=>{
                           console.info('快捷卡片判定',this.theCurrentHomeCard[9])
                         })
                     }
                   }
                 }
                 .GridColStyle()
                 .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                 .height(this.isLandscapePhone ? '100vp' : this.HomeCardEditHeight.value)
                 .transition(customAnimationUtil.isScaleTran(10, this.uiConfig))
                 // .transition(this.uiConfig.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: this.uiConfig.animationSpeed ,delay:90}):null)
                 //编辑模式下跳动动画
                 .rotate({ angle: this.uiConfig.isAnimation ? this.rotateAngle : null })
                 // 消失触发回调
                 .onDetach(() => {
                 })
               }*/

