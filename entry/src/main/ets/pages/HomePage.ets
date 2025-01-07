//主页 栅格布局、媒体查询
import { BreakpointSystem, BreakpointState } from '../common/breakpointsystem'
import { PromptAction, ThemeControl, window } from '@kit.ArkUI'
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
  TAB_CONTENT_TITLE_HEIGHT
} from '../common/Constants'
import Settings from '../components/Settings/Settings'
import { CUSTOM_THEME_MAP } from '../common/AppTheme'
import CurrentNode from '../components/Home/CurrentNode'
import FavoriteProxy from '../components/Home/FavoriteProxy'
import FavoriteConfiguration from '../components/Home/FavoriteConfiguration'


interface MarginGenerate {
  top: number,
  left: number,
  right: number,
  bottom?: number,
}

interface HomeCardData {
  name: string
}

@Entry
@Component
struct Home {
  // 页面名称 主页
  private componentName: string = 'HomePage'
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean
  private promptAction:PromptAction = this.getUIContext()?.getPromptAction()
  // 设置模态页控制变量
  @State isShowSettings: boolean = false
  // 设置按钮导航
  @Provide('NavSettingsPathStack') SettingsPageInfos: NavPathStack = new NavPathStack()
  // 设置 -> 备份与恢复 -> 是否启用云备份配置
  @Provide isShowCloudconfig: boolean = false
  // 设置页语言选中暂存变量
  @Provide currentLanguage: ResourceStr = $r('app.string.Language_Subtitle')
  // 设置 -> 通知 -> 流量提醒启用状态变量
  @Provide EnableCellularDataReminder: boolean = false
  // 设置页实验功能提示框显示变量
  @Provide isShowExperimentalFunction: boolean = true
  // 设置 -> 后台运行 -> 流量提醒启用状态变量
  @Provide Enablebackgrounder: boolean = false
  // 所有子组件在容器内的对齐方式 TODO 【用户首选项】在设置里可以更改 Alignment.BottomStart 和 Alignment.BottomEnd Enlin@2024-12-04
  @State
  stackAlignContentAlignment: Alignment = Alignment.BottomEnd
  //系统颜色调用
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  //二级图标色，灰色
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary')
  //一级文本色，黑色
  @State font_primary: ResourceColor = $r('sys.color.font_primary')
  @State currentBp: string = ''
  // 默认问候语
  @State greetings: Resource = $r('app.string.GoodMorning')
  @State ContainerHeight: string = ''
  @State TopHeight: string = ''
  @State compStr: BreakpointState<string> = BreakpointState.of({
    xs: "xs", sm: "sm", md: "md", lg: "lg", xl: "xl"
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
    xs: '6vp', sm: '6vp', md: '12vp', lg: '15vp', xl: '15vp'
  });
  @State containerRightMargin: BreakpointState<string> = BreakpointState.of({
    xs: '0vp', sm: '0vp', md: '0vp', lg: '15vp', xl: '15vp'
  });
  @State containerHeight: BreakpointState<string> = BreakpointState.of({
    xs: '156vp', sm: '160vp', md: '232.7vp', lg: '240vp', xl: '240vp'
  });
  @State GridRowHeight: BreakpointState<string> = BreakpointState.of({
    xs: '715vp', sm: '715vp', md: '1050vp', lg: '550vp', xl: '550vp'
  });

  windowClass = AppStorage.get<window.Window>('windowClass') as window.Window;
  /* Stack层叠布局 */
  /* 代理启动按钮 */
  //编辑按钮点击后显示编辑状态判定
  @State isShowHomeEdit: boolean = false
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
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  @State private gridMargin: number = 0

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
    //  offset: { dx: 0, dy: -20 },
    customStyle: false,
    cornerRadius: 32,
    //   height: 117,
    //   borderStyle: BorderStyle.Dashed,//使用borderStyle属性，需要和borderWidth属性一起使用
    //   borderColor: Color.Blue,//使用borderColor属性，需要和borderWidth属性一起使用
    //    backgroundColor: Color.White,
    //   shadow: ({ radius: 20, color: Color.Grey, offsetX: 50, offsetY: 0}),
  })

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
    this.restoreLayout()
    hilog.info(0xA000, this.componentName, '#onCancel: Callback when the first button is clicked')
  }

  onAccept() {
    this.saveHomeLayout()
    hilog.info(0xA000, this.componentName, '#onAccept: Callback when the second button is clicked')
  }

  existApp() {
    hilog.info(0xA000, this.componentName, '#existApp: Click the callback in the blank area')
  }

  /**
   * 还原主页卡片布局
   */
  restoreLayout(){
    // TODO 国际化
    this.promptAction.showToast({ message: `布局已还原🫡` })
    this.isShowHomeEdit = false
    this.isShowDeleteButton = false
  }

  /**
   * 保存主页卡片布局
   */
  saveHomeLayout(){
    // TODO 国际化
    this.promptAction.showToast({ message: `布局已保存💾` })
    this.isShowHomeEdit = false
    this.isShowDeleteButton = false
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

  /*
  编辑模式下右上角删除按钮
   */
  @Consume deleteButtonSize: BreakpointState<number>
  //删除按钮是否出现判定
  @State isShowDeleteButton :boolean = false
  //网络测速大模块里的
  @Builder
  DeleteButton1(){
    Button(){
      SymbolGlyph($r('sys.symbol.xmark'))
        .fontSize(16)
        .fontColor(['#fff'])
    }
    .borderRadius(20)
    .width(this.isLandscapePhone?24 :this.deleteButtonSize.value)
    .height(this.isLandscapePhone?24 :this.deleteButtonSize.value)
    .backgroundColor('#ffe84026')
    .position({ x: '95%',y:-4 })
  }
  //普通模块里的
  @Builder
  DeleteButton2(){
    Button(){
      SymbolGlyph($r('sys.symbol.xmark'))
        .fontSize(16)
        .fontColor(['#fff'])
    }
    .borderRadius(20)
    .width(this.isLandscapePhone?24 :this.deleteButtonSize.value)
    .height(this.isLandscapePhone?24 :this.deleteButtonSize.value)
    .backgroundColor('#ffe84026')
    .position({ x: '90%',y:-4 })
  }


  build() {
    Column() {
      if (!this.isLandscapePhone) {
        Row() {
          if (!this.isShowHomeEdit) {
            //编辑布局按钮判定：非编辑状态
            Text(this.greetings)
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .margin({ left: this.gridMargin })
              .fontColor(this.font_primary)
              .transition(TransitionEffect.OPACITY.animation({duration: ANIMATION_DURATION_300, delay:0}).combine(TransitionEffect.SLIDE))
            Blank()

            //编辑按钮
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph($r('sys.symbol.square_and_pencil'))
                .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)// .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)//分层颜色
                .fontColor([this.icon_primary])
            }
            .transition(TransitionEffect.OPACITY.animation({duration: ANIMATION_DURATION_300, delay:50}).combine(TransitionEffect.SLIDE))
            .onClick(() => {
              this.isShowHomeEdit = true
              this.isShowDeleteButton = true
            })
            .margin({ right: this.gridMargin })
            .width(40)
            .height(40)
            .backgroundColor($r('app.color.settings_container_background'))

            //设置按钮
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph($r('sys.symbol.gearshape'))
                .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
                .fontColor([this.icon_primary]) //设置图标无法分层设为单色
            }
            .margin({ right: this.gridMargin })
            .width(40)
            .height(40)
            .backgroundColor($r('app.color.settings_container_background'))
            .transition(TransitionEffect.OPACITY.animation({duration: ANIMATION_DURATION_300, delay:0}).combine(TransitionEffect.SLIDE))
            .onClick(() => {
              this.isShowSettings = true
              this.isEnableIndexForegroundBlur = true
            })
          } else {
            //编辑布局按钮判定：是编辑状态
            Text($r('app.string.home_edit'))
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .margin({ left: this.gridMargin })
              .fontColor(this.font_primary)
              .transition(TransitionEffect.OPACITY.animation({duration: ANIMATION_DURATION_300, delay:100}).combine(TransitionEffect.SLIDE))
            Blank()
            //添加按钮
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph($r('sys.symbol.plus'))
                .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)// .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)//分层颜色
                .fontColor([Color.White])

            }
            .margin({ right: this.gridMargin })
            .width(40)
            .height(40)
            .backgroundColor(this.icon_emphasize)
            .transition(TransitionEffect.OPACITY.animation({duration: ANIMATION_DURATION_300, delay:100}).combine(TransitionEffect.SLIDE))

            //保存按钮
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph($r('sys.symbol.save'))
                .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
                .fontColor([Color.White])
            }
            .margin({ right: this.gridMargin })
            .width(40)
            .height(40)
            .backgroundColor(this.icon_emphasize)
            .transition(TransitionEffect.OPACITY.animation({duration: ANIMATION_DURATION_300, delay:50}).combine(TransitionEffect.SLIDE))
            .onClick(() => {
              this.saveHomeLayout()
            })

            //取消按钮
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              SymbolGlyph($r('sys.symbol.xmark'))
                .fontSize(TAB_CONTENT_TITLE_SYMBOL_FONT_SIZE)
                .fontColor([Color.White])
            }
            .margin({ right: this.gridMargin })
            .width(40)
            .height(40)
            .backgroundColor(this.icon_emphasize)
            .transition(TransitionEffect.OPACITY.animation({duration: ANIMATION_DURATION_300, delay:0}).combine(TransitionEffect.SLIDE))
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
        //  .margin({ bottom: 15 })
        .geometryTransition("Button")
        // transition保证组件离场不被立即析构，可设置其他转场效果
        .transition(TransitionEffect.OPACITY)
      }

      Stack({ alignContent: this.stackAlignContentAlignment }) {
        // 主页卡片层
        Scroll() {
          GridRow({
            columns: 12,
            breakpoints: {
              value: ["320vp", "600vp", "840vp", "1000vp"],
              reference: BreakpointsReference.WindowSize
            }, })
          {   // 速率图
            GridCol({
              span: { xs: 12, sm: 12, md: this.isLandscapePhone ? 6 : 10, lg: 6, xl: 6 },
              offset: { xs: 0, sm: 0, md: this.isLandscapePhone ? 0 : 1, lg: 0, xl: 0 }
            }) {
              Speed()
              if(this.isShowDeleteButton) {
                this.DeleteButton1()
              }
            }
            .borderRadius(20)
            .clickEffect({ level: ClickEffectLevel.MIDDLE })
            .backgroundColor($r('app.color.container_background'))
            .height(this.isLandscapePhone ? '160vp' : this.containerHeight.value)
            .margin({ right: this.isLandscapePhone ? this.containerMargin.value : this.containerRightMargin.value })


            GridCol({
              span: { xs: 12, sm: 12, md: this.isLandscapePhone ? 6 : 10, lg: 6, xl: 6 },
              offset: { xs: 0, sm: 0, md: this.isLandscapePhone ? 0 : 2, lg: 0, xl: 0 }
            }) {
              GridRow() {

                GridCol({
                  span: { xs: 6, sm: 6, md: 6, lg: 6, xl: 6 }
                }) {
                  SwitchMode()
                  if(this.isShowDeleteButton) {
                    this.DeleteButton2()
                  }
                }
                .margin({ right: this.containerMargin.value })
                .GridColStyle()

                GridCol({
                  span: { xs: 6, sm: 6, md: 6, lg: 6, xl: 6 },
                }) {
                  CellularData()
                  if(this.isShowDeleteButton) {
                    this.DeleteButton2()
                  }
                }
                .margin({ left: this.containerMargin.value })
                .GridColStyle()
              }
            }
            .height(this.isLandscapePhone ? '160vp' : this.containerHeight.value)
            .margin(this.isLandscapePhone ? { left: 12 } : this.containerMargin1.value)

            GridCol({
              span: { xs: 12, sm: 12, md: this.isLandscapePhone ? 6 : 10, lg: 6, xl: 6 },
              offset: { xs: 0, sm: 0, md: this.isLandscapePhone ? 0 : 2, lg: 0, xl: 0 }
            }) {
              GridRow() {
                GridCol({
                  span: { xs: 6, sm: 6, md: 6, lg: 6, xl: 6 }
                }) {
                  CurrentNode()
                  if(this.isShowDeleteButton) {
                    this.DeleteButton2()
                  }
                }
                .margin({ right: this.containerMargin.value })
                .GridColStyle()

                GridCol({
                  span: { xs: 6, sm: 6, md: 6, lg: 6, xl: 6 },
                }) {
                  PublicNetwork()
                  if(this.isShowDeleteButton) {
                    this.DeleteButton2()
                  }
                }
                .margin({ left: this.containerMargin.value })
                .GridColStyle()
              }
            }
            .height(this.isLandscapePhone ? '160vp' : this.containerHeight.value)
            .margin(this.isLandscapePhone ? { top: 20, right: 12 } : this.containerMargin2.value)

            GridCol({
              span: { xs: 12, sm: 12, md: this.isLandscapePhone ? 6 : 10, lg: 6, xl: 6 },
              offset: { xs: 0, sm: 0, md: this.isLandscapePhone ? 0 : 2, lg: 0, xl: 0 }
            }) {
              GridRow() {
                GridCol({
                  span: { xs: 6, sm: 6, md: 6, lg: 6, xl: 6 }
                }) {
                  FavoriteProxy()
                  if(this.isShowDeleteButton) {
                    this.DeleteButton2()
                  }
                }
                .margin({ right: this.containerMargin.value })
                .GridColStyle()

                GridCol({
                  span: { xs: 6, sm: 6, md: 6, lg: 6, xl: 6 },
                }) {
                  FavoriteConfiguration()
                  if(this.isShowDeleteButton) {
                    this.DeleteButton2()
                  }
                }
                .margin({ left: this.containerMargin.value })
                .GridColStyle()
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

          })
        }
        .width('100%')
        .height('100%')
        .padding({ left:this.isLandscapePhone ?this.gridMargin  :this.gridMargin , right: this.gridMargin , top:this.isLandscapePhone ? 19  : '4vp'})
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
        //   .margin(this.isLandscapePhone ? { top: 19 } : '0vp')
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
            this.proxyStartedTimer.start((formatTime) => {
              this.proxyStartingDuration = formatTime
            })
          } else {
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
      //  .padding(this.isLandscapePhone ? '0vp' : { bottom: '45vp' })
      .height(this.isLandscapePhone ? '100%' : `calc(100% - ${TAB_CONTENT_TITLE_HEIGHT}vp)`)
      .width("100%")
      .bindSheet($$this.isShowSettings, this.SettingsSheet(), {
        detents: [BIND_SHEET_CONTAINER_HEIGHT, 300],
        preferType: SheetType.CENTER,
        backgroundColor: $r('app.color.background'),
        dragBar: false,
        // blurStyle: BlurStyle.BACKGROUND_REGULAR,
        onWillDismiss: () => {
          this.isShowSettings = false
          this.isEnableIndexForegroundBlur = false
          this.SettingsPageInfos.clear()
        }
      })
    }
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
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean
  controller?: CustomDialogController
  cancel: () => void = () => {}
  confirm: () => void = () => {}

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
  .height('100%')
  .borderRadius(20)
  .backgroundColor($r('app.color.container_background'))
  .clickEffect({ level: ClickEffectLevel.MIDDLE })
}