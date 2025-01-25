//主页 栅格布局、媒体查询
import { BreakpointState } from '../common/breakpointsystem'
import { PromptAction, window } from '@kit.ArkUI'
import SwitchMode from '../components/Home/SwitchMode'
import CellularData from '../components/Home/CellularData'
import PublicNetwork from '../components/Home/PublicNetwork'
import Speed from '../components/Home/Speed'
import { getGreeting } from '../utils/GreetingUtil'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Timer } from '../common/HHmmssTimer'
import {
  PROXY_STARTED_DURATION_INIT_VALUE,
  ANIMATION_DURATION_300,
  TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE,
  BIND_SHEET_CONTAINER_HEIGHT,
  TAB_CONTENT_TITLE_HEIGHT,
  gutterHomeGridcol,
  MarginGenerate,
  showHomeCard,
} from '../common/Constants'
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


@Entry
@Component
struct Home {
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 设置模态页控制变量
  @State isShowSettings: boolean = false
  // 设置页面栈
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 所有子组件在容器内的对齐方式
  @Consume ('stackAlignContentAlignment') stackAlignContentAlignment: Alignment
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  //二级图标色，灰色
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary')
  //一级文本色，黑色
  @State font_primary: ResourceColor = $r('sys.color.font_primary')
  //系统颜色调用
  @State currentBp: string = ''
  // 默认问候语
  @State greetings: Resource = $r('app.string.GoodMorning')
  @State ContainerHeight: string = ''
  @State TopHeight: string = ''
  /* 主页卡片高度*/
  @Consume('HomeCardEditHeight') private HomeCardEditHeight: BreakpointState<number>
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  windowClass = AppStorage.get<window.Window>('windowClass') as window.Window;
  //编辑按钮点击后显示编辑状态判定
  @Provide isShowHomeEdit: boolean = false
  /**
   * 是否保存布局弹窗
   */
  SaveDialogController: CustomDialogController | null = new CustomDialogController({
    builder: SaveCustomDialog({
      cancel: () => {
        this.onCancel()
      },
      confirm: () => {
        this.onAccept()
      }
    }),
    cancel: this.existApp,
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: false,
    cornerRadius: 32,
  })

  /*
  编辑模式下右上角删除按钮
   */
  @Consume deleteButtonSize: BreakpointState<number>
  //删除按钮是否出现判定
  @State isShowDeleteButton: boolean = false
  //卡片编辑半模拟态判定
  @State isShowCardEdit: boolean = false
  // 折叠屏展开状态判定
  @StorageProp('isFoldStatus') private isFoldStatus: boolean = false

  // 页面名称 主页
  private componentName: string = 'HomePage'
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  /* 是否开启全局动画判定 */
  @Consume ('isAnimation') isAnimation: boolean
  /* Stack层叠布局 */
  /* 代理启动按钮 */
  private promptAction: PromptAction = this.getUIContext()?.getPromptAction()
  // 代理启动按钮状态
  @Provide private proxyEnabled: boolean = false
  // 代理启动持续的时间
  @State private proxyStartingDuration: string = PROXY_STARTED_DURATION_INIT_VALUE
  // 按钮宽度
  @State private proxyStartButtonWidth: Length = $r('app.integer.vp_proxy_not_start_button_width')
  // 按钮高度
  @State private proxyStartButtonHeight: Length = $r('app.integer.vp_proxy_not_start_button_height')
  // 按钮前Symbol动效
  private ReplaceSymbolEffect: SymbolEffect = EffectScope.WHOLE // 按钮前Symbol动效
  // 定时器Controller
  private proxyStartedTimer: Timer = new Timer()
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  // 主页卡片内边距
  @Consume('breakPointStateHomeCardPadding') private cardPadding: BreakpointState<MarginGenerate>
  // 主页卡片内边距
  @Consume('gutterHomeGridcol_12_15') private gutterHomeGridcol: BreakpointState<gutterHomeGridcol>
  //主页整个卡片区域边距
  @Consume('HomeCardAreaPadding') private HomeCardAreaPadding: BreakpointState<MarginGenerate>
  @Consume('breakPointStateTabContentTitleMargin') private breakPointStateTabContentTitleMargin: BreakpointState<number>
  /**主页卡片标题按钮间距*/
  @Consume('HomeCardTitleButtonPadding') private HomeCardTitleButtonPadding: BreakpointState<number>
  // 当前主页布局
  @Provide theCurrentHomeCard: boolean[] = showHomeCard
  // 上一次主页布局
  @State theLastHomeCard: boolean[] = showHomeCard


  aboutToAppear(): void {
    this.greetings = getGreeting()
    // 初始化主页卡片布局
    if (this.uiConfig.isShowHomeCard)
      this.theCurrentHomeCard = JSON.parse(this.uiConfig.isShowHomeCard)
    hilog.info(0xFF00, "HometestTag", "布局初始化为： %{public}s", JSON.stringify(this.theCurrentHomeCard))
  }


  aboutToDisappear() {
    // 将dialogController置空
    this.SaveDialogController = null
  }

  // 在自定义组件即将析构销毁时将dialogController置空
  onCancel() {
    this.restoreLayout()
    this.isEnableIndexForegroundBlur=false
    hilog.info(0xA000, this.componentName, '#onCancel: Callback when the first button is clicked')
  }

  onAccept() {
    this.saveHomeLayout()
    this.isEnableIndexForegroundBlur=false
    hilog.info(0xA000, this.componentName, '#onAccept: Callback when the second button is clicked')
  }

  existApp() {
    this.isEnableIndexForegroundBlur=false
    hilog.info(0xA000, this.componentName, '#existApp: Click the callback in the blank area')
  }

  /**
   * 还原主页卡片布局
   */
  restoreLayout() {
    // 还原布局
    this.theCurrentHomeCard = this.theLastHomeCard
    this.uiConfig.isShowHomeCard = JSON.stringify(this.theLastHomeCard)
    hilog.info(0xFF00, "HometestTag", "布局还原为： %{public}s", JSON.stringify(this.theCurrentHomeCard))
    this.promptAction.showToast({ message: `${getContext().resourceManager.getStringSync($r('app.string.layout_restored'))}🫡` })
    this.isShowHomeEdit = false
    animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
      this.isShowDeleteButton = false
    })
  }

  /**
   * 保存主页卡片布局
   */
  saveHomeLayout() {
    // 保存布局
    this.uiConfig.isShowHomeCard = JSON.stringify(this.theCurrentHomeCard)
    hilog.info(0xFF00, "HometestTag", "保存的布局： %{public}s", this.uiConfig.isShowHomeCard)
    this.promptAction.showToast({ message: `${getContext().resourceManager.getStringSync($r('app.string.layout_saved'))}💾` })
    this.isShowHomeEdit = false
    if (this.isAnimation) {
      animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
        this.isShowDeleteButton = false
      })
    } else { this.isShowDeleteButton = false }
  }

  // 通过@Builder构建设置模态展示界面
  @Builder
  SettingsSheet() {
    Column() {
      Settings()
    }
    .width('100%')
    .height('100%')
  }

  //卡片编辑半模拟态
  @Builder
  CardEdit() {
    CardEdit()
  }

  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  build() {
    Column() {
      if (!this.isLandscapePhone) {
        Row({space: this.HomeCardTitleButtonPadding.value}) {
          if (!this.isShowHomeEdit) {
            //编辑布局按钮判定：非编辑状态
            if (this.uiConfig.isGreeting === true) {
              Text(this.greetings)
                .fontSize(this.uiConfig.userLanguage != 'en-Latn' ? 32 : 27)
                .layoutWeight(1)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.font_primary)
                .transition(this.isAnimation ? TransitionEffect.OPACITY
                  .animation({ duration: ANIMATION_DURATION_300, delay: 0 })
                  .combine(TransitionEffect.SLIDE):null)
            }
            Blank()
            //编辑按钮
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph($r('sys.symbol.square_and_pencil'))
                .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)// .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)//分层颜色
                .fontColor([this.icon_primary])
            }
            .transition(this.isAnimation ?TransitionEffect.OPACITY.animation({ duration: ANIMATION_DURATION_300, delay: 0 })
              .combine(TransitionEffect.SLIDE):null)
            .onClick(() => {
              this.isShowHomeEdit = true
              // 编辑布局前储存之前的布局变量
              hilog.info(0xFF00, "HometestTag", "上一次布局1： %{public}s", JSON.stringify(this.theLastHomeCard))
              this.theLastHomeCard = JSON.parse(this.uiConfig.isShowHomeCard)
              hilog.info(0xFF00, "HometestTag", "上一次布局2： %{public}s", JSON.stringify(this.theLastHomeCard))
              if (this.isAnimation) {
                animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
                  this.isShowDeleteButton = true
                })
              }else {this.isShowDeleteButton = true}
            })
            .width(40)
            .height(40)
            .backgroundColor($r('app.color.settings_container_background'))

            //设置按钮
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph($r('sys.symbol.gearshape'))
                .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
                .fontColor([this.icon_primary]) //设置图标无法分层设为单色
            }
            .width(40)
            .height(40)
            .backgroundColor($r('app.color.settings_container_background'))
            .transition(this.isAnimation ?TransitionEffect.OPACITY.animation({ duration: ANIMATION_DURATION_300, delay: 0 })
              .combine(TransitionEffect.SLIDE):null)
            .onClick(() => {
              this.isShowSettings = true
              this.isEnableIndexForegroundBlur = true
            })
          } else {
            //编辑布局按钮判定：是编辑状态
            Text($r('app.string.home_edit'))
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.font_primary)
              .transition(this.isAnimation ?TransitionEffect.OPACITY.animation({ duration: ANIMATION_DURATION_300, delay: 0 })
                .combine(TransitionEffect.SLIDE):null)
            Blank()
            //添加按钮
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph($r('sys.symbol.plus'))
                .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)// .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)//分层颜色
                .fontColor([Color.White])
            }
            .width(40)
            .height(40)
            .backgroundColor(this.icon_emphasize)
            .transition(this.isAnimation ?TransitionEffect.OPACITY.animation({ duration: ANIMATION_DURATION_300, delay: 0 })
              .combine(TransitionEffect.SLIDE):null)
            .onClick(() => {
              this.isShowCardEdit = true
              this.isEnableIndexForegroundBlur = true
            })

            //保存按钮
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph($r('sys.symbol.save'))
                .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
                .fontColor([Color.White])
            }
            .width(40)
            .height(40)
            .backgroundColor(this.icon_emphasize)
            .transition(this.isAnimation ?TransitionEffect.OPACITY.animation({ duration: ANIMATION_DURATION_300, delay: 0 })
              .combine(TransitionEffect.SLIDE):null)
            .onClick(() => {
              this.saveHomeLayout()
            })

            //取消按钮
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph($r('sys.symbol.xmark'))
                .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
                .fontColor([Color.White])
            }
            .width(40)
            .height(40)
            .backgroundColor(this.icon_emphasize)
            .transition(this.isAnimation ?TransitionEffect.OPACITY.animation({ duration: ANIMATION_DURATION_300, delay: 0 })
              .combine(TransitionEffect.SLIDE):null)
            .onClick(() => {
              if (this.SaveDialogController != null) {
                this.SaveDialogController.open()
                this.isEnableIndexForegroundBlur = true
              }
            })
          }
        }
        .width('100%')
        .height(TAB_CONTENT_TITLE_HEIGHT)
        .geometryTransition("Button")
        .padding({
          left: this.breakPointStateTabContentTitleMargin.value,
          right: this.breakPointStateTabContentTitleMargin.value,
        })
        // transition保证组件离场不被立即析构，可设置其他转场效果
        .transition(this.isAnimation ? TransitionEffect.OPACITY:null)
      }

      Stack({ alignContent: this.stackAlignContentAlignment }) {
        // 主页卡片层
        List() {
          ListItem() {
            GridRow({ gutter: this.isLandscapePhone ? { x: 12, y: 15 } : this.gutterHomeGridcol.value }) {
              //网络速度小卡片
              if (this.theCurrentHomeCard[0]) {
                GridCol({
                  span: { xs: this.isLandscapePhone ? 6 : 12, md: this.isLandscapePhone ? 6 :this.isFoldStatus ? 8 : 12, lg: 6 },
                  order: 1
                }) {
                  Stack({ alignContent: Alignment.TopEnd }) {
                    Speed()
                    if (this.isShowDeleteButton) {
                      DeleteButton1()
                        .position({ x: '95%', y: -4 })
                        .onClick(() => {
                          animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
                            // 将序号0变为false
                            this.theCurrentHomeCard.splice(0, 1, false)
                          })
                          hilog.info(0xFF00, "HometestTag", "网络速率卡片： %{public}s", this.uiConfig.isShowHomeCard[0])
                        })
                    }
                  }
                }
                .aspectRatio(2.07)
                .borderRadius(20)
                .backgroundColor($r('app.color.container_background'))
                .clickEffect({ level: ClickEffectLevel.MIDDLE })
                .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
                .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                //消失触发回调
                .onDetach(() => {
                })
                //显示时触发回调
                .onAttach(() => {
                })
              }

              //分流模式小卡片
              if (this.theCurrentHomeCard[1]) {
                GridCol({
                  span: { xs: this.isLandscapePhone ? 3 : 6, md: this.isLandscapePhone ? 3 : this.isFoldStatus ? 4 : 6, lg: 3 },
                  order: 2
                }) {
                  Stack({ alignContent: Alignment.TopEnd }) {
                    SwitchMode()
                    if (this.isShowDeleteButton) {
                      DeleteButton2()
                        .position({ x: '90%', y: -4 })
                        .onClick(() => {
                          animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
                            // 将序号1变为false
                            this.theCurrentHomeCard.splice(1, 1, false)
                          })
                          hilog.info(0xFF00, "HometestTag", "分流模式卡片： %{public}s", this.uiConfig.isShowHomeCard[1])
                        })
                    }
                  }
                }
                .GridColStyle()
                .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
              }

              //流量统计小卡片
              if (this.theCurrentHomeCard[2]) {
                GridCol({
                  span: { xs: this.isLandscapePhone ? 3 : 6, md: this.isLandscapePhone ? 3 : this.isFoldStatus ? 4 : 6, lg: 3 },
                  order: 3
                }) {
                  Stack({ alignContent: Alignment.TopEnd }) {
                    CellularData()
                    if (this.isShowDeleteButton) {
                      DeleteButton2()
                        .position({ x: '90%', y: -4 })
                        .onClick(() => {
                          animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
                            // 将序号2变为false
                            this.theCurrentHomeCard.splice(2, 1, false)
                          })
                        })
                    }
                  }
                }
                //   .margin({ left: this.containerMargin.value })
                .GridColStyle()
                .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
              }

              //当前节点小卡片
              if (this.theCurrentHomeCard[3]) {
                GridCol({
                  span: { xs: this.isLandscapePhone ? 3 : 6, md: this.isLandscapePhone ? 3 : this.isFoldStatus ? 4 : 6, lg: 3 },
                  order: 4
                }) {
                  Stack({ alignContent: Alignment.TopEnd }) {
                    CurrentNode()
                    if (this.isShowDeleteButton) {
                      DeleteButton2()
                        .position({ x: '90%', y: -4 })
                        .onClick(() => {
                          animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
                            // 将序号3变为false
                            this.theCurrentHomeCard.splice(3, 1, false)
                          })
                        })
                    }
                  }
                }
                .GridColStyle()
                .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
              }

              //IP地址小卡片
              if (this.theCurrentHomeCard[4]) {
                GridCol({
                  span: { xs: this.isLandscapePhone ? 3 : 6, md: this.isLandscapePhone ? 3 : this.isFoldStatus ? 4 : 6, lg: 3 },
                  order: 5
                }) {
                  Stack({ alignContent: Alignment.TopEnd }) {
                    PublicNetwork()
                    if (this.isShowDeleteButton) {
                      DeleteButton2()
                        .position({ x: '90%', y: -4 })
                        .onClick(() => {
                          animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
                            // 将序号4变为false
                            this.theCurrentHomeCard.splice(4, 1, false)
                          })
                        })
                    }
                  }
                }
                .GridColStyle()
                .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
              }

              //收藏节点小卡片
              if (this.theCurrentHomeCard[5]) {
                GridCol({
                  span: { xs: this.isLandscapePhone ? 3 : 6, md: this.isLandscapePhone ? 3 : this.isFoldStatus ? 4 : 6, lg: 3 },
                  order: 6
                }) {
                  Stack({ alignContent: Alignment.TopEnd }) {
                    FavoriteProxy()
                    if (this.isShowDeleteButton) {
                      DeleteButton2()
                        .position({ x: '90%', y: -4 })
                        .onClick(() => {
                          animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
                            // 将序号5变为false
                            this.theCurrentHomeCard.splice(5, 1, false)
                          })
                        })
                    }
                  }
                }
                .GridColStyle()
                .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
              }

              //收藏配置小卡片
              if (this.theCurrentHomeCard[6]) {
                GridCol({
                  span: { xs: this.isLandscapePhone ? 3 : 6, md: this.isLandscapePhone ? 3 : this.isFoldStatus ? 4 : 6, lg: 3 },
                  order: 7
                }) {
                  Stack({ alignContent: Alignment.TopEnd }) {
                    FavoriteConfiguration()
                    if (this.isShowDeleteButton) {
                      DeleteButton2()
                        .position({ x: '90%', y: -4 })
                        .onClick(() => {
                          animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
                            // 将序号6变为false
                            this.theCurrentHomeCard.splice(6, 1, false)
                          })
                        })
                    }
                  }
                }
                .GridColStyle()
                .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
              }

              //节点信息小卡片
              if (this.theCurrentHomeCard[7]) {
                GridCol({
                  span: { xs: this.isLandscapePhone ? 6 : 12, md: this.isLandscapePhone ? 6 : this.isFoldStatus ? 8 :12, lg: 6 },
                  order: 1
                }) {
                  Stack({ alignContent: Alignment.TopEnd }) {
                    ProxyINFO()
                    if (this.isShowDeleteButton) {
                      DeleteButton1()
                        .position({ x: '95%', y: -4 })
                        .onClick(() => {
                          animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
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
                .clickEffect({ level: ClickEffectLevel.MIDDLE })
                .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
                .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
              }

              //当前配置小卡片
              if (this.theCurrentHomeCard[8]) {
                GridCol({
                  span: { xs: this.isLandscapePhone ? 3 : 6, md: this.isLandscapePhone ? 3 : this.isFoldStatus ? 4 : 6, lg: 3 },
                  order: 4
                }) {
                  Stack({ alignContent: Alignment.TopEnd }) {
                    CurrentConfiguration()
                    if (this.isShowDeleteButton) {
                      DeleteButton2()
                        .position({ x: '90%', y: -4 })
                        .onClick(() => {
                          animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear}, () => {
                            // 将序号8变为false
                            this.theCurrentHomeCard.splice(8, 1, false)
                          })
                        })
                    }
                  }
                }
                .GridColStyle()
                .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
              }

              //快捷方式小卡片
              if (this.theCurrentHomeCard[9] === this.isFoldStatus ? false : true) {
                GridCol({
                  span: { xs: this.isLandscapePhone ? 3 : 6, md: this.isLandscapePhone ? 3 : this.isFoldStatus ? 4 : 6, lg: 3 },
                  order: 8
                }) {
                  Stack({ alignContent: Alignment.TopEnd }) {
                    Shortcuts()
                    if (this.isShowDeleteButton) {
                      DeleteButton2()
                        .position({ x: '90%', y: -4 })
                        .onClick(() => {
                          animateTo({ duration: ANIMATION_DURATION_300, curve: Curve.Linear }, () => {
                            // 将序号9变为false
                            this.theCurrentHomeCard.splice(9, 1, this.isFoldStatus ? true : false)
                          })
                        })
                    }
                  }
                }
                .GridColStyle()
                .height(this.isLandscapePhone ? '160vp' : this.HomeCardEditHeight.value)
                .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
              }
            } //GridRow的尾括号
            .width('100%')
            .padding(this.isLandscapePhone ? { top: 4, left: 25, right: 25 } :this.isFoldStatus ? { top: 4, left: 50, right: 50 } : this.HomeCardAreaPadding.value)
            .margin({ top: this.isLandscapePhone ? 7 : 0 })
          }
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .contentEndOffset(70)
        .edgeEffect(EdgeEffect.Spring)
        .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Ease })
        .bindSheet($$this.isShowCardEdit, this.CardEdit(), {
          detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.LARGE,],
          preferType: SheetType.CENTER,
          backgroundColor: $r('app.color.background'),
          showClose: true,
          dragBar: false,
          scrollSizeMode: ScrollSizeMode.CONTINUOUS,
          title: { title: $r('app.string.add_home_card') },
          onWillDismiss: () => {
            this.isShowCardEdit = false
            this.isEnableIndexForegroundBlur = false
          }
        })


        // 代理启动按钮层
        Column() {
          Row() {
            Stack({ alignContent: Alignment.Center }) {
              SymbolGlyph(this.proxyEnabled ? $r('sys.symbol.pause') : $r('sys.symbol.play_fill'))
                .fontSize(24)
                .fontColor([Color.White])
                .symbolEffect(this.ReplaceSymbolEffect)
                .align(Alignment.Center)
            }
            .width(this.proxyStartButtonHeight)
            .height(this.proxyStartButtonHeight)

            // .border({ width:2, radius: '50%', style: BorderStyle.Dashed, color: Color.White })
            // 计时器文本
            Text(this.proxyStartingDuration)
              .fontSize(20)// 使用透明度控制是否显示计时器，是因为用 `visibility` 来控制的话，不显示的时间长了之后，再次显示时候会延迟一秒，体验不好
              .fontColor(this.proxyEnabled ? Color.White : Color.Transparent)
              .fontWeight(FontWeight.Bold)
          }.width('100%')
        }
        .borderRadius(100)
        .backgroundColor(this.icon_emphasize)
        .shadow({
          radius: 10,
          color: this.icon_emphasize,
          offsetY: 4,
          type: ShadowType.BLUR
        })
        .margin($r('app.integer.vp_proxy_start_button_margin'))
        .width(this.proxyStartButtonWidth)
        .height(this.proxyStartButtonHeight)
        .clip(true)
        .onClick(async (event: ClickEvent) => {
          // TODO 调用启动代理方法 等待结果响应之后 再切换按钮状态开始计时
          this.proxyEnabled = !this.proxyEnabled
          hilog.info(0xA002, this.componentName, `代理启动按钮状态：${this.proxyEnabled}`)
          // 开始计时器
          if (this.proxyEnabled) {
            this.proxyStartedTimer.start((formatTime) => {
              this.proxyStartingDuration = formatTime
            })
            await ClashViewModel.StartVpn()
          } else {
            this.proxyStartedTimer.reset()
            // 如果`reset()`就取消注释这句，如果是`pause()`就注释这句
            this.proxyStartingDuration = PROXY_STARTED_DURATION_INIT_VALUE
            await ClashViewModel.StopVpn()
          }

          this.proxyStartButtonWidth = this.proxyEnabled ? $r('app.integer.vp_proxy_started_button_width') :
          $r('app.integer.vp_proxy_not_start_button_width')
        })
        .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Ease })
        .clickEffect({ level: ClickEffectLevel.LIGHT })

      }
      .backgroundColor($r('app.color.background'))
      //    .padding(this.isLandscapePhone ? '0vp' : { bottom: '45vp' })
      .height(this.isLandscapePhone ? '100%' : `calc(100% - ${TAB_CONTENT_TITLE_HEIGHT}vp)`)
      .width("100%")
      .bindSheet($$this.isShowSettings, this.SettingsSheet(), {
        detents: [BIND_SHEET_CONTAINER_HEIGHT, 300],
        preferType: SheetType.CENTER,
        scrollSizeMode: ScrollSizeMode.CONTINUOUS,
        backgroundColor: $r('app.color.background'),
        dragBar: false,
        keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
        onWillDismiss: () => {
          this.isShowSettings = false
          this.isEnableIndexForegroundBlur = false
          this.SettingsPageInfos.clear()
        }
      })
    }.width('100%').height('100%')
  }
}


/**
 * 保存样式和内容弹窗控制器
 */
@CustomDialog
struct SaveCustomDialog {
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  controller?: CustomDialogController
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean

  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  build() {
    Column() {
      Text($r('app.string.Home_Save_Layout'))
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

export default Home

// 小卡片共有属性
@Extend(GridCol)
function GridColStyle() {
  .aspectRatio(1)
  .borderRadius(20)
  .backgroundColor($r('app.color.container_background'))
  .clickEffect({ level: ClickEffectLevel.MIDDLE })
}

//网络测速大卡片里的删除按钮
@Component
struct DeleteButton1 {
  /*
编辑模式下右上角删除按钮
 */
  @Consume deleteButtonSize: BreakpointState<number>
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  // 折叠屏展开状态判定
  @StorageProp('isFoldStatus') private isFoldStatus: boolean = false
  /* 是否开启全局动画判定 */
  @Consume ('isAnimation') isAnimation: boolean

  build() {
    Button() {
      SymbolGlyph($r('sys.symbol.xmark'))
        .fontSize(16)
        .fontColor(['#fff'])
    }
    .borderRadius(20)
    .width(this.isLandscapePhone ? 24 :this.isFoldStatus?24: this.deleteButtonSize.value)
    .height(this.isLandscapePhone ? 24 :this.isFoldStatus?24: this.deleteButtonSize.value)
    .backgroundColor('#ffe84026')
    .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
  }
}

//普通模卡片里的删除按钮
@Component
struct DeleteButton2 {
  /*
编辑模式下右上角删除按钮
 */
  @Consume deleteButtonSize: BreakpointState<number>
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  // 折叠屏展开状态判定
  @StorageProp('isFoldStatus') private isFoldStatus: boolean = false
  /* 是否开启全局动画判定 */
  @Consume ('isAnimation') isAnimation: boolean

  build() {
    Button() {
      SymbolGlyph($r('sys.symbol.xmark'))
        .fontSize(16)
        .fontColor(['#fff'])
    }
    .borderRadius(20)
    .width(this.isLandscapePhone ? 24 :this.isFoldStatus?24: this.deleteButtonSize.value)
    .height(this.isLandscapePhone ? 24 :this.isFoldStatus?24: this.deleteButtonSize.value)
    .backgroundColor('#ffe84026')
    .transition(this.isAnimation ? TransitionEffect.scale({x: 0, y: 0}).animation({ duration: ANIMATION_DURATION_300 }):null)
  }
}

