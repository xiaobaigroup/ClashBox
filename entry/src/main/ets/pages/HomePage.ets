//主页 栅格布局、媒体查询
import { BreakpointSystem, BreakpointState } from '../common/breakpointsystem'
import { ThemeControl, window } from '@kit.ArkUI'
import SwitchMode from '../components/Home/SwitchMode'
import CellularData from '../components/Home/CellularData'
import CurrrentNode from '../components/Home/CurrentNode'
import PublicNetwork from '../components/Home/PublicNetwork'
import Start from '../components/Home/Speed'
import { getGreeting } from '../utils/getGreeting'
import SwitchQuickly from '../components/Home/SwitchQuickly'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Timer } from '../common/HHmmssTimer'
import {
  PROXY_STARTED_DURATION_INIT_VALUE,
  ANIMATION_DURATION_300,
  TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE,
  BIND_SHEET_CONTAINER_HEIGHT
} from '../common/Constants'
import Settings from '../components/Settings/Settings'
import { CUSTOM_THEME_MAP } from '../common/AppTheme'
import { AlertDialog } from '@kit.ArkUI'


interface MarginGenerate {
  top: number,
  left: number,
  right: number,
  bottom?: number,
}

@Entry
@Component
struct Home {
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  // 设置按钮导航
  @Provide('NavSettingsPathStack') SettingsPageInfos: NavPathStack = new NavPathStack()
  // 所有子组件在容器内的对齐方式 TODO 【用户首选项】在设置里可以更改 Alignment.BottomStart 和 Alignment.BottomEnd Enlin@2024-12-04
  @State
  stackAlignContentAlignment: Alignment = Alignment.BottomEnd
  /* Stack层叠布局 */
  //系统颜色调用
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  /* 代理启动按钮 */
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary') //二级图标色，灰色
  @State font_primary: ResourceColor = $r('sys.color.font_primary') //一级文本色，黑色
  @State currentBp: string = ''
  @State greetings: Resource = $r('app.string.GoodMorning')
  @State ContainerHeight: string = ''
  @State TopHeight: string = ''
  @State isShowSettings: boolean = false
  @State compStr: BreakpointState<string> = BreakpointState.of({
    xs: "xs",
    sm: "sm",
    md: "md",
    lg: "lg",
    xl: "xl"
  })
  @State containerMargin1: BreakpointState<MarginGenerate> = BreakpointState.of({
    xs: ({ top: 15 } as MarginGenerate),
    sm: ({ top: 15 } as MarginGenerate),
    md: ({ top: 28 } as MarginGenerate),
    lg: ({ top: 0, left: 15 } as MarginGenerate),
    xl: ({ top: 0, left: 15 } as MarginGenerate)
  });
  @State containerMargin2: BreakpointState<MarginGenerate> = BreakpointState.of({
    xs: ({ top: 30 } as MarginGenerate),
    sm: ({ top: 30 } as MarginGenerate),
    md: ({ top: 56 } as MarginGenerate),
    lg: ({ top: 25, right: 15 } as MarginGenerate),
    xl: ({ top: 25, right: 15 } as MarginGenerate)
  });
  //设置图标颜色，修改resources/base(dark)/element/color.json中settings_icon配置浅色和深色模式分别颜色
  //@State fontColorValue:ResourceColor = ($r('app.color.settings_icon'));
  @State containerMargin3: BreakpointState<MarginGenerate> = BreakpointState.of({
    xs: ({ top: 45 } as MarginGenerate),
    sm: ({ top: 45 } as MarginGenerate),
    md: ({ top: 84 } as MarginGenerate),
    lg: ({ top: 25, left: 15 } as MarginGenerate),
    xl: ({ top: 25, left: 15 } as MarginGenerate)
  });
  @State containerMargin: BreakpointState<string> = BreakpointState.of({
    xs: '6vp',
    sm: '6vp',
    md: '12vp',
    lg: '15vp',
    xl: '15vp'
  });
  @State containerRightMargin: BreakpointState<string> = BreakpointState.of({
    xs: '0vp',
    sm: '0vp',
    md: '0vp',
    lg: '15vp',
    xl: '15vp'
  });
  @State containerHeight: BreakpointState<string> = BreakpointState.of({
    xs: '156vp',
    sm: '160vp',
    md: '232.7vp',
    lg: '240vp',
    xl: '240vp'
  });
  @State GridRowHeight: BreakpointState<string> = BreakpointState.of({
    xs: '715vp',
    sm: '715vp',
    md: '1050vp',
    lg: '550vp',
    xl: '550vp'
  });
  windowClass = AppStorage.get<window.Window>('windowClass') as window.Window;
  //编辑按钮点击后显示编辑状态判定
  @State isShowHomeEdit: boolean = false
  //是否保存弹窗
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
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      console.info("reason=" + JSON.stringify(dismissDialogAction.reason))
      console.log("dialog onWillDismiss")
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
      }
    },
    alignment: DialogAlignment.Center,
    //  offset: { dx: 0, dy: -20 },
    customStyle: false,
    cornerRadius: 32,
    //   height: 117,
    //   borderStyle: BorderStyle.Dashed,//使用borderStyle属性，需要和borderWidth属性一起使用
    //   borderColor: Color.Blue,//使用borderColor属性，需要和borderWidth属性一起使用
    //    backgroundColor: Color.White,
    //   shadow: ({ radius: 20, color: Color.Grey, offsetX: 50, offsetY: 0}),
  })
  private componentName: string = 'HomePage'
  // 代理启动按钮状态
  @State
  private proxyEnabled: boolean = false
  // 代理启动持续的时间
  @State
  private proxyStartingDuration: string = PROXY_STARTED_DURATION_INIT_VALUE
  // 按钮宽度
  @State
  private proxyStartButtonWidth: Length = $r('app.integer.vp_proxy_not_start_button_width')
  // 按钮高度
  @State
  private proxyStartButtonHeight: Length = $r('app.integer.vp_proxy_not_start_button_height')
  // 按钮前Symbol动效
  private ReplaceSymbolEffect: SymbolEffect = EffectScope.WHOLE // 按钮前Symbol动效
  // 定时器Controller
  private proxyStartedTimer: Timer = new Timer()
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  @State private gridMargin: number = 0

  aboutToAppear() {
    this.greetings = getGreeting()
    console.log('问候语:' + this.greetings)

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.containerMargin)
    BreakpointSystem.getInstance().attach(this.containerRightMargin)
    BreakpointSystem.getInstance().attach(this.containerMargin1)
    BreakpointSystem.getInstance().attach(this.containerMargin2)
    BreakpointSystem.getInstance().attach(this.containerMargin3)
    BreakpointSystem.getInstance().attach(this.containerHeight)
    BreakpointSystem.getInstance().attach(this.GridRowHeight)
    BreakpointSystem.getInstance().start()
  }

  aboutToDisappear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.containerMargin)
    BreakpointSystem.getInstance().attach(this.containerRightMargin)
    BreakpointSystem.getInstance().attach(this.containerMargin1)
    BreakpointSystem.getInstance().attach(this.containerMargin2)
    BreakpointSystem.getInstance().attach(this.containerMargin3)
    BreakpointSystem.getInstance().attach(this.containerHeight)
    BreakpointSystem.getInstance().attach(this.GridRowHeight)
    BreakpointSystem.getInstance().stop()
    this.SaveDialogController = null // 将dialogController置空
  }

  // 在自定义组件即将析构销毁时将dialogController置空
  onCancel() {
    console.info('Callback when the first button is clicked')
  }

  onAccept() {
    console.info('Callback when the second button is clicked')
  }

  existApp() {
    console.info('Click the callback in the blank area')
  }

  // 通过@Builder构建设置模态展示界面
  @Builder
  SettingsSheet() {

    Column() {
      Settings({ isShowSettings: this.isShowSettings })
    }
    .width('100%')
    .height('100%')

    //.backgroundColor(Color.White)
  }

  build() {
    Column() {
      if (!this.isShowHomeEdit) {
        if (!this.isLandscapePhone) {
          Row() {
            Text(this.greetings)
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .margin({ left: this.gridMargin })
              .fontColor(this.font_primary)
            Blank()
            //编辑图标
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph($r('sys.symbol.square_and_pencil'))
                .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)// .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)//分层颜色
                .fontColor([this.icon_primary])
            }
            .onClick(() => {
              this.isShowHomeEdit = true
            })
            .margin({ right: this.gridMargin })
            .width(40)
            .height(40)
            .backgroundColor($r('app.color.settings_container_background'))

            //设置图标
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph($r('sys.symbol.gearshape'))
                .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
                .fontColor([this.icon_primary]) //设置图标无法分层设为单色
            }
            .margin({ right: this.gridMargin })
            .width(40)
            .height(40)
            .backgroundColor($r('app.color.settings_container_background'))
            .onClick(() => {
              this.isShowSettings = true
              this.isEnableIndexForegroundBlur = true
            })
            .bindSheet($$this.isShowSettings, this.SettingsSheet(), {
              detents: [BIND_SHEET_CONTAINER_HEIGHT, 300],
              preferType: SheetType.CENTER,
              backgroundColor: $r('app.color.container_background'),
              dragBar: false,
              blurStyle: BlurStyle.BACKGROUND_REGULAR,
              onWillDismiss: () => {
                this.isShowSettings = false
                this.isEnableIndexForegroundBlur = false
                this.SettingsPageInfos.clear()
              }
            })
          }
          .width('100%')
          .margin({ bottom: 15 })
        }
      } else if (this.isShowHomeEdit) {
        Row() {
          Text(this.greetings)
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .margin({ left: this.gridMargin })
            .fontColor(this.font_primary)
          Blank()
          //添加图标
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)// .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)//分层颜色
              .fontColor([Color.White])

          }
          .margin({ right: this.gridMargin })
          .width(40)
          .height(40)
          .backgroundColor(this.icon_emphasize)

          //保存图标
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            SymbolGlyph($r('sys.symbol.save'))
              .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
              .fontColor([Color.White])
          }
          .margin({ right: this.gridMargin })
          .width(40)
          .height(40)
          .backgroundColor(this.icon_emphasize)
          .onClick(() => {
            if (this.SaveDialogController != null) {
              this.SaveDialogController.open()
            }
          })

          //删除图标
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            SymbolGlyph($r('sys.symbol.xmark'))
              .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
              .fontColor([Color.White])
          }
          .margin({ right: this.gridMargin })
          .width(40)
          .height(40)
          .backgroundColor(this.icon_emphasize)
          .onClick(() => {
            this.isShowHomeEdit = false
          })
        }
        .width('100%')
        .margin({ bottom: 15 })
      }


      Stack({ alignContent: this.stackAlignContentAlignment }) {
        // 主页卡片层
        Scroll() {
          GridRow({
            columns: 12,
            breakpoints: {
              value: ["320vp", "600vp", "840vp", "1000vp"],
              reference: BreakpointsReference.WindowSize
            },
          }) {
            GridCol({
              span: {
                xs: 12,
                sm: 12,
                md: this.isLandscapePhone ? 6 : 10,
                lg: 6,
                xl: 6
              },
              offset: {
                xs: 0,
                sm: 0,
                md: this.isLandscapePhone ? 0 : 1,
                lg: 0,
                xl: 0
              }
            }) {
              Start()
            }
            .borderRadius(20)
            .backgroundColor($r('app.color.container_background'))
            .height(this.isLandscapePhone ? '160vp' : this.containerHeight.value)
            .margin({ right: this.isLandscapePhone ? this.containerMargin.value : this.containerRightMargin.value })
            .clickEffect({ level: ClickEffectLevel.MIDDLE })

            GridCol({
              span: {
                xs: 12,
                sm: 12,
                md: this.isLandscapePhone ? 6 : 10,
                lg: 6,
                xl: 6
              },
              offset: {
                xs: 0,
                sm: 0,
                md: this.isLandscapePhone ? 0 : 2,
                lg: 0,
                xl: 0
              }
            }) {
              GridRow() {
                GridCol({
                  span: {
                    xs: 6,
                    sm: 6,
                    md: 6,
                    lg: 6,
                    xl: 6
                  }
                }) {
                  SwitchMode()
                }
                .height('100%')
                .borderRadius(20)
                .margin({ right: this.containerMargin.value })
                .backgroundColor($r('app.color.container_background'))
                .clickEffect({ level: ClickEffectLevel.MIDDLE })

                GridCol({
                  span: {
                    xs: 6,
                    sm: 6,
                    md: 6,
                    lg: 6,
                    xl: 6
                  },
                }) {
                  CellularData()
                }
                .height('100%')
                .borderRadius(20)
                .margin({ left: this.containerMargin.value })
                .backgroundColor($r('app.color.container_background'))
                .clickEffect({ level: ClickEffectLevel.MIDDLE })
              }
            }
            .height(this.isLandscapePhone ? '160vp' : this.containerHeight.value)
            .margin(this.isLandscapePhone ? { left: 12 } : this.containerMargin1.value)

            GridCol({
              span: {
                xs: 12,
                sm: 12,
                md: this.isLandscapePhone ? 6 : 10,
                lg: 6,
                xl: 6
              },
              offset: {
                xs: 0,
                sm: 0,
                md: this.isLandscapePhone ? 0 : 2,
                lg: 0,
                xl: 0
              }
            }) {
              GridRow() {
                GridCol({
                  span: {
                    xs: 6,
                    sm: 6,
                    md: 6,
                    lg: 6,
                    xl: 6
                  }
                }) {
                  CurrrentNode()
                }
                .height('100%')
                .borderRadius(20)
                .margin({ right: this.containerMargin.value })
                .backgroundColor($r('app.color.container_background'))
                .clickEffect({ level: ClickEffectLevel.MIDDLE })

                GridCol({
                  span: {
                    xs: 6,
                    sm: 6,
                    md: 6,
                    lg: 6,
                    xl: 6
                  },
                }) {
                  PublicNetwork()
                }
                .height('100%')
                .borderRadius(20)
                .margin({ left: this.containerMargin.value })
                .backgroundColor($r('app.color.container_background'))
                .clickEffect({ level: ClickEffectLevel.MIDDLE })
              }
            }
            .height(this.isLandscapePhone ? '160vp' : this.containerHeight.value)
            .margin(this.isLandscapePhone ? { top: 20, right: 12 } : this.containerMargin2.value)

            GridCol({
              span: {
                xs: 12,
                sm: 12,
                md: this.isLandscapePhone ? 6 : 10,
                lg: 6,
                xl: 6
              },
              offset: {
                xs: 0,
                sm: 0,
                md: this.isLandscapePhone ? 0 : 2,
                lg: 0,
                xl: 0
              }
            }) {
              GridRow() {
                GridCol({
                  span: {
                    xs: 6,
                    sm: 6,
                    md: 6,
                    lg: 6,
                    xl: 6
                  }
                }) {
                  SwitchQuickly()
                }
                .height('100%')
                .borderRadius(20)
                .margin({ right: this.containerMargin.value })
                .backgroundColor($r('app.color.container_background'))
                .clickEffect({ level: ClickEffectLevel.MIDDLE })

                GridCol({
                  span: {
                    xs: 6,
                    sm: 6,
                    md: 6,
                    lg: 6,
                    xl: 6
                  },
                }) {
                  //TrafficStatistics()
                }
                .height('100%')
                .borderRadius(20)
                .margin({ left: this.containerMargin.value })
                .backgroundColor($r('app.color.container_background'))
                .clickEffect({ level: ClickEffectLevel.MIDDLE })
              }
            }
            .height(this.isLandscapePhone ? '160vp' : this.containerHeight.value)
            .margin(this.isLandscapePhone ? { top: 20, left: 12 } : this.containerMargin3.value)

          }
          .height(this.isLandscapePhone ? '360vp' : this.GridRowHeight.value)
          .width('100%')
          .onBreakpointChange((breakpoint) => {
            this.currentBp = breakpoint
            switch (this.currentBp) {
              case 'xs':
                this.gridMargin = 12
                break
              case 'sm':
                this.gridMargin = 14
                break
              case 'md':
                this.gridMargin = 28
                break
              case 'lg':
              case 'xl':
                this.gridMargin = 36
                break
            }
            // console.log('断点为：' + this.currentBp + '容器高：' + this.ContainerHeight + '顶部高：' + this.TopHeight)
          })
        }
        .width('100%')
        .height('100%')
        .padding({ left: this.gridMargin, right: this.gridMargin })
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
        .margin(this.isLandscapePhone ? { top: 19 } : '0vp')
        .edgeEffect(EdgeEffect.Spring)
        .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Ease })

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
        .onClick((event: ClickEvent) => {
          // TODO 调用启动代理方法 等待结果响应之后 再切换按钮状态开始计时
          this.proxyEnabled = !this.proxyEnabled
          hilog.info(0xA002, this.componentName, `代理启动按钮状态：${this.proxyEnabled}`)
          // 开始计时器
          if (this.proxyEnabled) {
            // TODO 删除下面两行 为了测试更换固定主题色用的
            this.proxyStartedTimer.start((formatTime) => {
              this.proxyStartingDuration = formatTime
            })
            ThemeControl.setDefaultTheme(CUSTOM_THEME_MAP.get('redAppTheme'))
            hilog.info(0xA002, this.componentName, `#Button#onClick#ThemeControl.setDefaultTheme(redAppTheme)`)
          } else {
            // TODO 删除下面两行 为了测试更换固定主题色用的
            ThemeControl.setDefaultTheme(CUSTOM_THEME_MAP.get('orangeAppTheme'))
            hilog.info(0xA002, this.componentName, `#Button#onClick#ThemeControl.setDefaultTheme(orangeAppTheme)`)
            this.proxyStartedTimer.reset()
            // 如果`reset()`就取消注释这句，如果是`pause()`就注释这句
            this.proxyStartingDuration = PROXY_STARTED_DURATION_INIT_VALUE
          }

          this.proxyStartButtonWidth = this.proxyEnabled ? $r('app.integer.vp_proxy_started_button_width') :
          $r('app.integer.vp_proxy_not_start_button_width')
        })
        .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Ease })
        .clickEffect({ level: ClickEffectLevel.LIGHT })
      }
      .backgroundColor($r('app.color.background'))
      .padding(this.isLandscapePhone ? '0vp' : { bottom: '45vp' })
      .width("100%")
    }
  }
}

//保存弹窗样式和内容
@CustomDialog
struct SaveCustomDialog {
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  controller?: CustomDialogController
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
