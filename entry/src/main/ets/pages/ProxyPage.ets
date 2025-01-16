import { BreakpointState, BreakpointSystem } from '../common/breakpointsystem'
import {
  ANIMATION_DURATION_300,
  TAB_CONTENT_TITLE_HEIGHT,
  BIND_SHEET_CONTAINER_HEIGHT,
} from '../common/Constants'
import { hilog } from '@kit.PerformanceAnalysisKit'
import ProxyGroupItem from '../components/Proxy/ProxyGroupItem'
import ProxyArrangement from '../components/Proxy/ProxyArrangement'
import { Item } from '../common/ProxyData'
import ClashViewModel from '../entryability/ClashViewModel'
import { Profile, ProxyGroup, ProxySort, ProxyType } from 'proxy_core'
import { EventHub, EventKey } from '../common/EventHub'
import { AppConfig, isEnd, ProxyCardSize, ProxyGroupType } from '../entryability/AppState'



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
  // 所有子组件在容器内的对齐方式
  @Consume ('stackAlignContentAlignment') stackAlignContentAlignment: Alignment
  /* 是否开启全局动画判定 */
  @Consume ('isAnimation') isAnimation: boolean
  @State font_primary: ResourceColor = $r('sys.color.font_primary') //一级文本色，黑色
  @State font_secondary: ResourceColor = $r('sys.color.font_secondary') //二级文本色，深灰色
  @State container_background: ResourceColor = ($r('app.color.container_background')); //卡片颜色
  /* 配置列表List相关 */
  @State font_on_primary: ResourceColor = $r('sys.color.font_on_primary') //一级文本反色，白色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  @State icon_secondary: ResourceColor = $r('sys.color.icon_secondary') //二级图标色，深灰色

  /* Stack层叠布局 */
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
  @State FristPage: boolean = true
  /*节点相关数据以及排序 */
  //节点假数据组后期可改可删
  @Consume items: Item[]

  @Consume
  proxyGroups: ProxyGroup[]

  hasGroups(){
    this.FristPage = this.proxyGroups.length == 0;
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

  @Consume('currentProfile')
  private currentProfile: Profile | null
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('favoriteProxys') favoriteProxys: Map<string, string> = new Map<string, string>([])
  //栅格点位配置
  aboutToAppear(): void {
    hilog.info(0xB000, this.componentName, `#aboutToAppear`)
    BreakpointSystem.getInstance().start()
    if (this.currentProfile){
      let tabIndexes = this.proxyGroups.findIndex((d)=>d.name == this.currentProfile?.currentGroupName)
      setTimeout(() => {
        if(tabIndexes > -1){
          this.tabsController.changeIndex(tabIndexes)
          this.currentIndex = tabIndexes
        }
      }, 200)
    }
  }
  changeProxy(g: string, item: Item){
    if(this.currentProfile){
      ClashViewModel.changeProxy(this.currentProfile, g, item.text)
    }
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
      //代理节点分组方式切换
      EditTitle({ title: $r('app.string.Packet_mode') })

      Column() {
        ForEach([{t: $r('app.string.Tabs'), v: ProxyGroupType.Tabs}, {t: $r('app.string.List'), v: ProxyGroupType.List}], (n: [Resource, number], i: number) => {
          Row() {
            Text(n["t"])
              .EditText()
            Radio({
              value: 'ProxyArrangementSelected1', group: 'ProxyArrangementSelectedRadioGroup',
              indicatorType: RadioIndicatorType.TICK,
            })
              .checked(this.appConfig.proxyGroupType == n["v"])
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  animateTo({ duration: 500 }, () => {
                    this.appConfig.proxyGroupType = n["v"]
                  })
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
              this.appConfig.proxyGroupType = n["v"]
            })
          })
          if(!isEnd(2, i)){
            Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })
          }
        })
      }
      .height(94)
      .EditColumn()

      //代理节点排列切换
      EditTitle({ title: $r('app.string.Arrangement') })
      Column() {
        ForEach([
          {t: $r('app.string.Default'), v: ProxySort.Default},
          {t: $r('app.string.Delay'), v: ProxySort.Delay},
          {t: $r('app.string.Name'), v: ProxySort.Title}
        ], (n: [Resource, number], i: number) => {
          Row() {
            Text(n["t"])
              .EditText()
            Radio({
              value: 'SortRadio1', group: 'SortRadioGroup',
              indicatorType: RadioIndicatorType.TICK
            })
              .checked(this.appConfig.proxySort == n["v"])
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  EventHub.sendEvent(EventKey.ProxySort, n["v"])
                  animateTo({ duration: 500 }, () => {
                    this.appConfig.proxySort = n["v"]
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
            EventHub.sendEvent(EventKey.ProxySort, n["v"])
            animateTo({ duration: 500 }, () => {
              this.appConfig.proxySort = n["v"]
            })
          })
          if (!isEnd(3, i))
            Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })
        })
      }
      .height(142)
      .EditColumn()

      //代理节点卡片尺寸切换
      EditTitle({ title: $r('app.string.Card_Size') })
      Column() {
        ForEach([
          {t: $r('app.string.Thin'), v: ProxyCardSize.Small},
          {t: $r('app.string.Wide'), v: ProxyCardSize.Large},
          {t: $r('app.string.Mini'), v: ProxyCardSize.Mini}
        ], (n: [Resource, number], i: number) => {
          Row() {
            Text(n["t"])
              .EditText()
            Radio({
              value: 'ProxyGroupItemSelectedRadio1', group: 'ProxyGroupItemSelectedRadioGroup',
              indicatorType: RadioIndicatorType.TICK
            })
              .checked(this.appConfig.proxyCardSize == n["v"])
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  animateTo({ duration: 500 }, () => {
                    this.currentRadioValue3 = 0
                    this.appConfig.proxyCardSize = n["v"]
                  })
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
              this.appConfig.proxyCardSize = n["v"]
            })
          })
          if (!isEnd(3,i)){
            Divider().strokeWidth(1).color($r('app.color.divider')).padding({ left: 5, right: 10 })
          }
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

      if (this.proxyGroups.length == 0) {
        Column({ space: 5 }) {
          SymbolGlyph($r('sys.symbol.doc')).fontSize(32).fontColor([this.icon_secondary])
          Text($r('app.string.None_Proxy')).fontSize(20).fontColor(this.font_secondary).textAlign(TextAlign.Center)
        }
        .width('100%')
        .height('90%')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center) //.padding({top:TAB_CONTENT_TITLE_HEIGHT})
        // transition保证组件离场不被立即析构，可设置其他转场效果
        .transition(this.isAnimation ? TransitionEffect.OPACITY:null)
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
      } else if (this.proxyGroups.length > 0) {
        // 代理页分组TAB+list主体
        Stack({ alignContent: this.stackAlignContentAlignment  }) {
          //根据ProxyArrangementSelected的状态决定是否显示
          if (this.appConfig.proxyGroupType === ProxyGroupType.Tabs) {
            Column() { //分组标签页 start
              Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
                ForEach(this.proxyGroups, (g:ProxyGroup, i: number)=>{
                  TabContent() {
                    ProxyGroupItem({
                      items: g.proxies as Item[],
                      ProxyGroupItemSelected: this.appConfig.proxyCardSize,
                      disabled: g.type !== ProxyType.Selector,
                      selectedProxy: this.currentProfile?.getSelectedProxy(g) ?? "",
                      OnProxyChange: (item) => {
                        console.log("xxxxx", item)
                        this.changeProxy(g.name, item)
                      }
                    }) //list相关在components/ProxyGroupItem.ets文件里
                      .padding({right: this.breakPointStateTabContentTitleMargin.value,})
                      .width('100%')
                      .height('100%')
                  }
                  .tabBar(this.TabBuilder(g.name, i))
                })
              }
              .animationDuration(200)
              .barMode(BarMode.Scrollable)
              .barHeight(55)
              .fadingEdge(false)
              .onChange((index: number) => {
                this.currentIndex = index;
                if(this.currentProfile){
                  this.currentProfile.currentGroupName = this.proxyGroups[index].name
                  ClashViewModel.updateProfile(this.currentProfile)
                }
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
          else if (this.appConfig.proxyGroupType === ProxyGroupType.List) {
            ProxyArrangement()// transition保证组件离场不被立即析构，可设置其他转场效果
              .transition(this.isAnimation ? TransitionEffect.OPACITY:null)
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