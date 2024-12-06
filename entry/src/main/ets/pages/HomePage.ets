//主页 栅格布局、媒体查询
import { BreakpointSystem, BreakpointState } from '../common/breakpointsystem'
import { mediaquery, window } from '@kit.ArkUI'
import SwitchMode from '../components/Home/SwitchMode'
import CellularData from '../components/Home/CellularData'
import CurrrentNode from '../components/Home/CurrentNode'
import PublicNetwork from '../components/Home/PublicNetwork'
import Start from '../components/Home/Speed'
import { getGreeting } from '../utils/getGreeting'
import SwitchQuickly from '../components/Home/SwitchQuickly'
import { ThemeControl } from '@ohos.arkui.theme'
import { gAppTheme } from '../common/AppTheme'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Timer } from '../common/HHmmssTimer'
import { PROXY_STARTED_DURATION_INIT_VALUE, ANIMATION_DURATION_300 } from '../common/Constants'
// 在页面build前执行ThemeControl，就可以改变主题颜色
//ThemeControl.setDefaultTheme(gAppTheme)


interface MarginGenerate {
  top: number,
  left: number,
  right: number,
  bottom?: number,
}

@Entry
@Component
struct Home {

  private componentName: string = 'HomePage'

  /* Stack层叠布局 */
  // 所有子组件在容器内的对齐方式 TODO 【用户首选项】在设置里可以更改 Alignment.BottomStart 和 Alignment.BottomEnd Enlin@2024-12-04
  @State
  stackAlignContentAlignment: Alignment = Alignment.BottomEnd

  /* 代理启动按钮 */
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
  private ReplaceSymbolEffect: SymbolEffect = EffectScope.WHOLE
  // 定时器Controller
  private proxyStartedTimer: Timer = new Timer()

  //系统颜色调用
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary') //二级图标色，灰色
  @State icon_emphasize: ResourceColor = $r('sys.color.icon_emphasize') //高亮图标，蓝色
  //设置图标颜色，修改resources/base(dark)/element/color.json中settings_icon配置浅色和深色模式分别颜色
  //@State fontColorValue:ResourceColor = ($r('app.color.settings_icon'));

  //@Prop isLandscape: boolean
  @State currentBp: string = ''
  @State greetings: string = '早上好'
  @State ContainerHeight: string = ''
  @State TopHeight: string = ''
  @State isLandscapePhone: boolean = false
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
  // 手机横屏高度条件
  phonelistener: mediaquery.MediaQueryListener =
    this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');
  @State private gridMargin: number = 0

  onPhoneLandscape(mediaQueryResult: mediaquery.MediaQueryResult) {
    if (mediaQueryResult.matches as boolean) {
      this.isLandscapePhone = true
      console.log('手机横屏' + this.isLandscapePhone)
      //用于修改通知栏，预览器无法使用，请注释掉再开
      //this.windowClass.setSpecificSystemBarEnabled('navigationIndicator', false)
    } else {
      this.isLandscapePhone = false
      console.log('手机竖屏' + this.isLandscapePhone)
      //this.windowClass.setSpecificSystemBarEnabled('navigationIndicator', true)
    }
  }

  aboutToAppear() {
    this.greetings = getGreeting()
    console.log('问候语:' + this.greetings)

    this.phonelistener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.onPhoneLandscape(mediaQueryResult)
    });

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
    this.phonelistener.off('change');
  }

  build() {
    Column() {
      if (!this.isLandscapePhone) {
        Row() {
          Text(this.greetings)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .margin({ left: this.gridMargin })
          Blank()
          //编辑图标
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            SymbolGlyph($r('sys.symbol.square_and_pencil'))
              .fontSize(30)//         .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)//分层颜色
              .fontColor([this.icon_secondary])
          }
          .margin({ right: this.gridMargin })
          .width(40)
          .height(40)
          .backgroundColor($r('app.color.settings_container_background'))

          //设置图标
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            SymbolGlyph($r('sys.symbol.gearshape'))
              .fontSize(30)
              .fontColor([this.icon_secondary]) //设置图标无法分层设为单色
          }
          .margin({ right: this.gridMargin })
          .width(40)
          .height(40)
          .backgroundColor($r('app.color.settings_container_background'))
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
        .animation({duration: ANIMATION_DURATION_300, curve:Curve.Ease})

        // 代理启动按钮层
        Button(){
          Row(){
            Stack( { alignContent: Alignment.Center } ){
              SymbolGlyph( this.proxyEnabled ? $r('sys.symbol.pause') : $r('sys.symbol.play_fill') )
                .fontSize(24)
                .fontColor([Color.White])
                .symbolEffect(this.ReplaceSymbolEffect)
                .align(Alignment.Center)
            }
            .width(this.proxyStartButtonHeight)
            .height(this.proxyStartButtonHeight)
            // .border({ width:2, radius: '50%', style: BorderStyle.Dashed, color: Color.White })
            // 计时器文本
            Text( this.proxyStartingDuration )
              .fontSize(20)
              // 使用透明度控制是否显示计时器，是因为用 `visibility` 来控制的话，不显示的时间长了之后，再次显示时候会延迟一秒，体验不好
              .fontColor(this.proxyEnabled ? Color.White : Color.Transparent)
              .fontWeight(FontWeight.Bold)
          }.width('100%')
        }
        // .backgroundColor($r('app.color.speed_down_icon'))
        .shadow({radius: 10, color: $r('app.color.speed_down_icon'), offsetY: 4, type: ShadowType.BLUR})
        .margin($r('app.integer.vp_proxy_start_button_margin'))
        .width(this.proxyStartButtonWidth)
        .height(this.proxyStartButtonHeight)
        .clip(true)
        .onClick( (event: ClickEvent) => {
          // TODO 调用启动代理方法 等待结果响应之后 再切换按钮状态开始计时
          this.proxyEnabled = !this.proxyEnabled
          hilog.info(0xA002, this.componentName, `代理启动按钮状态：${this.proxyEnabled}`)
          // 开始计时器
          if (this.proxyEnabled) {
            this.proxyStartedTimer.start( (formatTime) => { this.proxyStartingDuration = formatTime } )
          } else {
            this.proxyStartedTimer.reset()
            // 如果`reset()`就取消注释这句，如果是`pause()`就注释这句
            this.proxyStartingDuration = PROXY_STARTED_DURATION_INIT_VALUE
          }

          this.proxyStartButtonWidth = this.proxyEnabled ? $r('app.integer.vp_proxy_started_button_width') : $r('app.integer.vp_proxy_not_start_button_width')
        })
        .animation({duration: ANIMATION_DURATION_300, curve: Curve.Ease})
        .clickEffect({level: ClickEffectLevel.MIDDLE})
      }
      .backgroundColor($r('app.color.background'))
      .padding(this.isLandscapePhone ? '0vp' : { bottom: '45vp' })
      .width("100%")
    }
  }
}
export default Home