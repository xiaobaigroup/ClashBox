import { BreakpointState, BreakpointSystem } from '../common/breakpointsystem'
import {
  ANIMATION_DURATION_300,
  TAB_CONTENT_TITLE_HEIGHT,
  BIND_SHEET_CONTAINER_HEIGHT,
} from '../common/Constants'
import { hilog } from '@kit.PerformanceAnalysisKit'
import ProxyGroupItem from '../components/Proxy/ProxyGroupItem'
import ProxyArrangement from '../components/Proxy/ProxyArrangement'
import { intl } from '@kit.LocalizationKit'
import { Item } from '../common/ProxyData'

//中文排序
let ProxyCollator = new intl.Collator("zh-CN");

@Entry
@Component
struct ProxyPage {
  //系统颜色调用
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean
  @State font_primary: ResourceColor = $r('sys.color.font_primary') //一级文本色，黑色
  @State font_secondary: ResourceColor = $r('sys.color.font_secondary') //二级文本色，深灰色
  @State container_background: ResourceColor = ($r('app.color.container_background')); //卡片颜色
  /* 配置列表List相关 */
  @State font_on_primary: ResourceColor = $r('sys.color.font_on_primary') //一级文本反色，白色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary') //二级图标色，深灰色

  /* Stack层叠布局 */
  // 所有子组件在容器内的对齐方式 TODO 【用户首选项】在设置里可以更改 Alignment.BottomStart 和 Alignment.BottomEnd Enlin@2024-12-04
  @State
  stackAlignContentAlignment: Alignment = Alignment.BottomEnd
  //编辑按钮点击
  @State isShowEdit: boolean = false
  //分组tabs相关
  @State currentIndex: number = 0;

  //假数据延迟颜色设置
  @State color: ResourceColor = $r('sys.color.font_secondary')
  // 定义ProxyArrangementSelected的值便于切换分组方式
  @State ProxyArrangementSelected: string = 'ProxyArrangementSelected1';
  @State ProxyArrangementChecked: boolean = true;
  // 定义ProxyGroupItemSelected的值便于切换布局方式
  @Provide ProxyGroupItemSelected: string = 'ProxyGroupItemSelectedWide'
  @State ProxyGroupItemChecked: boolean = true;
  ProxyGroupItemChecked1: boolean = false;
  @State currentRadioValue1: number = 0 // 分组方式切换
  @State currentRadioValue2: number = 0 // 排列方式切换
  @State currentRadioValue3: number = 0 // 卡片尺寸切换
  @State FristPage: boolean = true // 为观看预览页的判定，更改后续可以删掉
  /*节点相关数据以及排序 */
  //节点假数据组后期可改可删
  @Consume items: Item[]

  // 延迟排序
  LatencySortItems() {
    this.items.sort((a, b) => a.latency - b.latency);
  }

  //按名称排序
  NameSortItems() {
    this.items.sort((a, b) => {
      return ProxyCollator.compare(a.text, b.text);
    })
  }

  //默认排序
  DefaultSortItems() {
    this.items.sort((a, b) => a.id - b.id);
  }

  /* 断点布局相关 相关作用看定义时候的注释 */
  @Consume('breakPointStateListLanes')
  private breakPointStateListLanes: BreakpointState<number>
  @Consume('breakPointStateListGutter')
  private breakPointStateListGutter: BreakpointState<number>

  @Consume('breakPointStateTabContentTitleMargin')
  private breakPointStateTabContentTitleMargin: BreakpointState<number>
  private tabsController: TabsController = new TabsController()
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone')
  private isLandscapePhone: boolean = false
  // 按钮宽度
  private proxyStartButtonWidth: Length = $r('app.integer.vp_proxy_not_start_button_width')
  // 按钮高度
  private proxyStartButtonHeight: Length = $r('app.integer.vp_proxy_not_start_button_height')
  // 按钮Margin
  private proxyStartButtonMargin: Length = $r('app.integer.vp_proxy_start_button_margin')
  // 按钮前Symbol动效
  private ReplaceSymbolEffect: SymbolEffect = EffectScope.WHOLE
  //定义组件名
  private componentName: string = 'ProxyPage'



  //栅格点位配置
  aboutToAppear(): void {
    hilog.info(0xB000, this.componentName, `#aboutToAppear`)
    BreakpointSystem.getInstance().start()
  }

  //分组tabs内容
  @Builder
  TabBuilder(title: ResourceStr, targetIndex: number) {
    Column() {
      Column() {
        Text(title)
          .fontSize(14)
          .fontColor(this.currentIndex === targetIndex ? this.font_on_primary : this.font_secondary)
      }
      .borderRadius(21)
      .height(this.currentIndex === targetIndex ? 36 : 32)
      .width(this.currentIndex === targetIndex ? 96 : 87)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.currentIndex === targetIndex ? this.icon_emphasize : this.container_background)
      .animation(
        {
          duration: ANIMATION_DURATION_300,
          tempo:0.3,
          curve: Curve.Ease,
          iterations: 1,
          playMode: PlayMode.Normal
        })
    }
    .height(55)
    .margin({ right: 8, bottom: 10 })
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(this.currentIndex);
    })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  //半模态编辑菜单Start
  ProxyBindSheetEdit() {
    Column() {
      EditTitle({ title: $r('app.string.Packet_mode') })
      Column() {
        Row() {
          Text($r('app.string.Tabs'))
            .EditText()
          Radio({
            value: 'ProxyArrangementSelected1', group: 'ProxyArrangementSelectedRadioGroup',
            indicatorType: RadioIndicatorType.TICK,
          })
            .checked(this.currentRadioValue1 === 0)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                animateTo({ duration: 500 }, () => {
                  this.currentRadioValue1 = 0
                })
                this.ProxyArrangementSelected = 'ProxyArrangementSelected1'
              }
            })
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        .EditRow()
        // 点击后改变ProxyArrangementSelected状态为 标签
        .onClick(() => {
          animateTo({ duration: 500 }, () => {
            this.currentRadioValue1 = 0
          })
          this.ProxyArrangementSelected = 'ProxyArrangementSelected1'
        })

        Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })

        Row() {
          Text($r('app.string.List'))
            .EditText()
          Radio({
            value: 'ProxyArrangementSelected2', group: 'ProxyArrangementSelectedRadioGroup',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(this.currentRadioValue1 === 1)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                animateTo({ duration: 500 }, () => {
                  this.currentRadioValue1 = 1
                })
                this.ProxyArrangementSelected = 'ProxyArrangementSelected2'
              }
            })
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        .EditRow()
        // 点击后改变ProxyArrangementSelected状态为 列表
        .onClick(() => {
          animateTo({ duration: 500 }, () => {
            this.currentRadioValue1 = 1
          })
          this.ProxyArrangementSelected = 'ProxyArrangementSelected2'
        })
      }
      .height(94)
      .EditColumn()

      EditTitle({ title: $r('app.string.Arrangement') })
      Column() {
        Row() {
          Text($r('app.string.Default'))
            .EditText()
          Radio({
            value: 'SortRadio1', group: 'SortRadioGroup',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(this.currentRadioValue2 === 0)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.DefaultSortItems()
                animateTo({ duration: 500 }, () => {
                  this.currentRadioValue2 = 0
                })
              }
            })
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        .EditRow()
        .onClick(() => {
          this.DefaultSortItems()
          animateTo({ duration: 500 }, () => {
            this.currentRadioValue2 = 0
          })
        })

        Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })

        Row() {
          Text($r('app.string.Delay'))
            .EditText()
          Radio({
            value: 'SortRadio2', group: 'SortRadioGroup',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(this.currentRadioValue2 === 1)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.LatencySortItems()
                animateTo({ duration: 500 }, () => {
                  this.currentRadioValue2 = 1
                })
              }
            })
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        .EditRow()
        .onClick(() => {
          this.LatencySortItems() //按延迟排序
          animateTo({ duration: 500 }, () => {
            this.currentRadioValue2 = 1
          })
        })

        Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })

        Row() {
          Text($r('app.string.Name'))
            .EditText()
          Radio({
            value: 'SortRadio3', group: 'SortRadioGroup',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(this.currentRadioValue2 === 2)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.NameSortItems()
                animateTo({ duration: 500 }, () => {
                  this.currentRadioValue2 = 2
                })
              }
            })
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        .EditRow()
        .onClick(() => {
          this.NameSortItems()
          animateTo({ duration: 500 }, () => {
            this.currentRadioValue2 = 2
          })
        })
      }
      .height(142)
      .EditColumn()

      EditTitle({ title: $r('app.string.Card_Size') })
      Column() {
        Row() {
          Text($r('app.string.Thin'))
            .EditText()
          Radio({
            value: 'ProxyGroupItemSelectedRadio1', group: 'ProxyGroupItemSelectedRadioGroup',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(this.currentRadioValue3 === 0)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                animateTo({ duration: 500 }, () => {
                  this.currentRadioValue3 = 0
                })
                this.ProxyGroupItemSelected = 'ProxyGroupItemSelectedWide'
              }
            })
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        .EditRow()
        // 点击后改变ProxyGroupItemSelected状态为 多列
        .onClick(() => {
          animateTo({ duration: 500 }, () => {
            this.currentRadioValue3 = 0
          })
          this.ProxyGroupItemSelected = 'ProxyGroupItemSelectedWide'
        })

        Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })

        Row() {
          Text($r('app.string.Wide'))
            .EditText()
          Radio({
            value: 'ProxyGroupItemSelectedRadio2', group: 'ProxyGroupItemSelectedRadioGroup',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(this.currentRadioValue3 === 1)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                animateTo({ duration: 500 }, () => {
                  this.currentRadioValue3 = 1
                })
                this.ProxyGroupItemSelected = 'ProxyGroupItemSelectedThin'
              }
            })
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        // 点击后改变ProxyGroupItemSelected状态为 单列
        .onClick(() => {
          animateTo({ duration: 500 }, () => {
            this.currentRadioValue3 = 1
          })
          this.ProxyGroupItemSelected = 'ProxyGroupItemSelectedThin'
        })
        .EditRow()

        Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })

        Row() {
          Text($r('app.string.Mini'))
            .EditText()
          Radio({
            value: 'Radio8', group: 'radioGroup3',
            indicatorType: RadioIndicatorType.TICK
          })
            .checked(this.currentRadioValue3 === 2)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                animateTo({ duration: 500 }, () => {
                  this.currentRadioValue3 = 2
                })
                this.ProxyGroupItemSelected = 'ProxyGroupItemSelectedMini'
              }
            })
            .radioStyle({
              checkedBackgroundColor: this.icon_emphasize,
              //   uncheckedBorderColor: this.icon_secondary
            })
        }
        .EditRow()
        // 点击后改变ProxyGroupItemSelected状态为 迷你
        .onClick(() => {
          animateTo({ duration: 500 }, () => {
            this.currentRadioValue3 = 2
          })
          this.ProxyGroupItemSelected = 'ProxyGroupItemSelectedMini'
        })
      }
      .height(142)
      .EditColumn()

    }
    .padding({
      left: this.breakPointStateTabContentTitleMargin.value,
      right: this.breakPointStateTabContentTitleMargin.value,
    })
    .width('100%')
  }//半模态编辑菜单end

  build() {
    Column() {
      // 标题栏
      if (!this.isLandscapePhone) {
        Row() {
          Text($r('app.string.Proxy'))
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)

          Blank()
          //编辑图标
          Button({ type: ButtonType.Circle, stateEffect: true }) {
            SymbolGlyph($r('sys.symbol.square_and_pencil'))
              .fontSize(24)//      .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)//分层颜色
              .fontColor([this.icon_primary])
          }
          .width(40)
          .height(40)
          .backgroundColor($r('app.color.settings_container_background'))
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
          .onClick(() => {
            this.isShowEdit = true
            this.isEnableIndexForegroundBlur=true
            hilog.info(0xB001, this.componentName, `#button#onClick()#编辑代理`)
          })
        }
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .height(TAB_CONTENT_TITLE_HEIGHT)
        .padding({
          left: this.breakPointStateTabContentTitleMargin.value,
          right: this.breakPointStateTabContentTitleMargin.value,
        })
      }

      if (this.FristPage) { //为观看预览页的判定if/else，判定和更改后续可以删掉判定
        Column({ space: 5 }) {
          SymbolGlyph($r('sys.symbol.doc')).fontSize(32).fontColor([this.icon_secondary])
          Text($r('app.string.None_Proxy')).fontSize(20).fontColor(this.font_secondary).textAlign(TextAlign.Center)
        }
        .width('100%')
        .height('90%')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center) //.padding({top:TAB_CONTENT_TITLE_HEIGHT})
        // transition保证组件离场不被立即析构，可设置其他转场效果
        .transition(TransitionEffect.OPACITY)
        .onClick(() => {
          animateTo({ duration:ANIMATION_DURATION_300 }, () => {
            this.FristPage = false
          })
        })
      } else if (!this.FristPage) { //为观看的判定if/else后续可以删掉判定
        // 代理页分组TAB+list主体
        Stack({ alignContent: this.stackAlignContentAlignment }) {
          //根据ProxyArrangementSelected的状态决定是否显示
          if (this.ProxyArrangementSelected === 'ProxyArrangementSelected1') {
            Column() { //分组标签页 start
              Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
                TabContent() {
                ProxyGroupItem() //list相关在components/ProxyGroupItem.ets文件里
                  .padding({right: this.breakPointStateTabContentTitleMargin.value,})
                  .width('100%')
                  .height('100%')
                  //      .lanes(this.breakPointStateListLanes.value, this.breakPointStateListGutter.value)
                }

                .tabBar(this.TabBuilder('分组1', 0))

                TabContent() {
                  ProxyGroupItem() //list相关在components/ProxyGroupItem.ets文件里
                    .padding({right: this.breakPointStateTabContentTitleMargin.value,})
                    .width('100%')
                    .height('100%')
                }
                .tabBar(this.TabBuilder('分组2', 1))

                TabContent() {
                }
                .tabBar(this.TabBuilder('分组3', 2))

                TabContent() {
                }
                .tabBar(this.TabBuilder('分组4', 3))

                TabContent() {
                }
                .tabBar(this.TabBuilder('分组5', 4))

                TabContent() {
                }
                .tabBar(this.TabBuilder('分组6', 5))

                TabContent() {
                }
                .tabBar(this.TabBuilder('分组7', 6))

                TabContent() {
                }
                .tabBar(this.TabBuilder('分组8', 7))
              }
              .animationDuration(200)
              .barMode(BarMode.Scrollable)
              .barHeight(55)
              .fadingEdge(false)
              .onChange((index: number) => {
                this.currentIndex = index;
              })

            }
            .padding({
              left: this.breakPointStateTabContentTitleMargin.value,
            })
            .width('100%')
            .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Ease })
            .foregroundBlurStyle(
              this.isEnableIndexForegroundBlur ? BlurStyle.Thin : BlurStyle.NONE,
              { colorMode: ThemeColorMode.SYSTEM, adaptiveColor: AdaptiveColor.DEFAULT, scale: 0.3 }
            )
            //分组tabs end
          }

          // 列表排列
          else if (this.ProxyArrangementSelected === 'ProxyArrangementSelected2') {
            ProxyArrangement()// transition保证组件离场不被立即析构，可设置其他转场效果
              .transition(TransitionEffect.OPACITY)
          }
          //列表排列end

          // 悬浮代理测速按钮 START
          Column() {
            Stack({ alignContent: Alignment.Center }) {
              SymbolGlyph($r('sys.symbol.bolt_filled_on_circle'))
                .fontSize(24)
                .fontColor([Color.White])
                .symbolEffect(this.ReplaceSymbolEffect)
                .align(Alignment.Center)
            }
            .width('100%')
            .height('100%')
          }
          .shadow({
            radius: 10,
            color: this.icon_emphasize,
            offsetY: 4,
            type: ShadowType.BLUR
          })
          .borderRadius(100)
          .backgroundColor(this.icon_emphasize)
          .margin(this.proxyStartButtonMargin)
          .width(this.proxyStartButtonWidth)
          .height(this.proxyStartButtonHeight)
          .clip(true)
          .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Ease })
          .clickEffect({ level: ClickEffectLevel.LIGHT })
          .bindSheet($$this.isShowEdit, this.ProxyBindSheetEdit(), {
            detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.FIT_CONTENT,],
            backgroundColor: $r('app.color.background'),
            //  blurStyle: BlurStyle.BACKGROUND_REGULAR,
            showClose: true,
            dragBar: false,
            scrollSizeMode: ScrollSizeMode.CONTINUOUS,
            title: { title: $r('app.string.Edit') },
            preferType: SheetType.CENTER,
            //         maskColor: $r('app.color.dialog_maskcolor'),
            onWillDismiss: () => {
              this.isShowEdit = false
              this.isEnableIndexForegroundBlur=false
            }
          })
          // 悬浮代理测速按钮 END
        }
        .backgroundColor($r('app.color.background'))
       // .padding(this.isLandscapePhone ? '0vp' : { bottom: '45vp' })
        .width('100%')
        .height(this.isLandscapePhone ? '100%' : `calc(100% - ${TAB_CONTENT_TITLE_HEIGHT}vp)`)

        // 主体 END
      }
    }
    .width('100%')
    .height('100%')
  }
}

export default ProxyPage


// 半模态编辑页Column公共样式（含非通用公共属性采用Extend继承的方式抽取）
@Extend(Column)
function EditColumn() {
  .padding({ left: 12, right: 12 })
  .width('100%')
  .margin({ bottom: 10 })
  .borderRadius(20)
  .backgroundColor($r('app.color.container_background'))
  .justifyContent(FlexAlign.SpaceEvenly) // 非通用公共属性
}

// 半模态编辑页Row公共样式（含非通用公共属性采用Extend继承的方式抽取）
@Extend(Row)
function EditRow() {
  .width('100%')
  .justifyContent(FlexAlign.SpaceBetween) // 非通用公共属性
  .clickEffect({ level: ClickEffectLevel.MIDDLE }) // 非通用公共属性
}

// 半模态编辑页Text共同属性（Text独有属性采用Extend继承的方式抽取）
@Extend(Text)
function EditText() {
  .font({ size: 16 })
  .fontColor($r('sys.color.font_primary')) // 一级文本色，黑色
}

// 半模态编辑页标题
@Component
struct EditTitle {
  @State title: ResourceStr = $r('app.string.Packet_mode')

  build() {
    Text(this.title)
      .width('100%')
      .fontSize(16)
      .fontColor($r('sys.color.font_secondary'))
      .textAlign(0)
      .margin({ bottom: 10 })
  }
}