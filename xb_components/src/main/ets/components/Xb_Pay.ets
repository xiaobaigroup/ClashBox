import { colorChange } from "./Common";
import { Xb_TopTitleBar } from "./Xb_TopTitleBar";
import { KeyCode } from "@kit.InputKit";
import { BORDER_RADIUS_24, PADDING_VALUE_12, PADDING_VALUE_16 } from "./Constants";
import { SwitchButtonItem, Xb_SwitchButton } from "./Xb_SwitchButton";
import { SettingsGroup, SettingsItem } from "../settings/SettingsCommonOp";
import { IntroduceItem } from "../view/Xb_IntroduceItem";

/**
 * 通用付款页面
 */
@ComponentV2
export struct Xb_Pay{
  //nav params相关
  @Param pageInfos: NavPathStack = new NavPathStack();
  @Param isBuyOut: boolean = true
  @Param buyIcon?: Resource = undefined
  @Param sellerName: ResourceStr = ''
  @Param price: ResourceStr = ''
  @Param isSheet: boolean = true
  @Param heightTotal?: number = undefined
  @Param isBackPress: boolean = false
  @Param payTimeIndex: number = 0
  @Param @Require listGroup: Array<SettingsGroup> = []
  @Param navPageBackgroundColor: ResourceColor = $r('app.color.start_window_background')
  @Param listItemBgColor: ResourceColor = $r('app.color.comp_background_list_card')
  @Param needClose: boolean = true
  @Param topRect: Length = 8
  @Param navIconSize: number = 24
  @Param topButtonColor: ResourceColor = colorChange.color1

  @Param isShowPayLoading: boolean = false
  @Param payButtonText: ResourceStr = $r('app.string.pay_button')
  @Param payButtonBgColor: ResourceColor = Color.Transparent
  @Param payButtonColor: ResourceColor = $r('sys.color.icon_emphasize')
  @Event payButtonClick: () => void

  @Param buttonPayList: SwitchButtonItem[] = []

  @Event switchOnClick: (i: number) => void
  @Event close: () => void
  @Event appear: () => void

  aboutToAppear(): void {
    this.appear()
  }

  build() {
    NavDestination() {
      Stack(){
        // 标题
        Xb_TopTitleBar({
          name: this.isBuyOut ? $r('app.string.xb_pay_title_buy_out') : $r('app.string.xb_pay_title_subscribe'),
          fontSize: 20,
          iconSize: this.navIconSize,
          buttonColor: this.topButtonColor,
          heightTotal: this.heightTotal,
          isBackPress: this.isBackPress,
          animationUse: false,
          icon2: this.needClose ? $r("sys.symbol.xmark") : undefined,
          onClickIcon: (i: number) => {
            if (i == 1) {//关闭按钮回调
              this.close()
            }else if (2){//返回按钮
              this.pageInfos.pop()
            }
          }
        }).width('100%').padding({top: this.topRect}).position({top: 0}).zIndex(1)
          .backgroundColor($r('app.color.background'))

        // 详细信息list
        List(){
          ListItem(){
            // 付款样式
            if (this.isBuyOut){//买断样式
              this.BuyOut()
            }else {//订阅样式
              this.Subscribe()
            }
          }

          ForEach(this.listGroup, (g: SettingsGroup, gi: number)=>{
            ListItemGroup({ header: this.ListTitle(g.title) })
              .padding({
                top: PADDING_VALUE_16,
                bottom: PADDING_VALUE_16
              })

            ListItemGroup(){
              ForEach(g.items, (v: SettingsItem, i: number)=>{
                IntroduceItem({
                  item: v,
                  space: 0,
                  heightAll: 'auto'
                }).padding({top: PADDING_VALUE_12, bottom: PADDING_VALUE_12})
              })
            }.listItemGroup().backgroundColor(this.listItemBgColor)
          })
        }.width('100%').height('100%').contentStartOffset(56).padding({top: this.topRect}).scrollBar(BarState.Off)
        .contentEndOffset(130)

        Column({space: 6}){
          //Text($r('app.string.pay_button_sec')).textStyle(14, $r('sys.color.font_tertiary'), FontWeight.Regular)
          Button({ type: ButtonType.Capsule, stateEffect: true }){
            Row({ space: 5 }){
              if (this.isShowPayLoading){
                LoadingProgress().width(24).height(24).color(Color.White)
              }
              Text(this.payButtonText).fontSize(16).fontWeight(FontWeight.Medium)
            }.width('100%').justifyContent(FlexAlign.Center)
          }
          .zIndex(2)
          .backgroundColor(this.payButtonColor)
          .padding({right: 16, left: 16})
          .height(44)
        }.width('100%').position({bottom: 0}).padding({top: 32, right: 16, left: 16, bottom: 44})
        .linearGradient({
          angle: 0,
          colors: [[this.payButtonBgColor, 0.0], [this.payButtonBgColor, 0.7], ['#00000000', 1],] // 数组末尾元素占比小于1时满足重复着色效果
        })
        .onTouch((event)=>{
          if (event.type == TouchType.Down) {
            this.payButtonClick()
          }
        })
      }.width('100%').height('100%').alignContent(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .padding({left: PADDING_VALUE_16, right: PADDING_VALUE_16})
    .onBackPressed(() => {
      this.pageInfos.pop();
      return true
    })
    .onKeyEvent((e: KeyEvent)=>{
      if (e){
        if (e.keyCode == KeyCode.KEYCODE_ESCAPE && e.type === KeyType.Down) {
          this.pageInfos.pop();
        }
      }
    })
  }

  //买断
  @Builder
  BuyOut(){
    Row({space: 10}){
      Image(this.buyIcon)
        .size({width: 64, height: 64})
        .borderRadius(12)
      Column({space: 2}){
        Text(this.sellerName)//商品名
          .textStyle(16, $r('sys.color.font_primary'), FontWeight.Medium)
        Text(this.price)//售价
          .textStyle(20, $r('sys.color.multi_color_10'), FontWeight.Bold)
      }.alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .padding(PADDING_VALUE_12)
  }

  //订阅
  @Builder
  Subscribe(){
    Column(){
      this.BuyOut()
      Xb_SwitchButton({
        items: this.buttonPayList,
        switchOne: undefined,
        heightAll: 50,
        borderRadiusAll: 20,
        onClickUse: (i) => {
          this.switchOnClick(i)
        }
      })
    }.padding({right: 8, left: 8, bottom: 8}).width('100%').clip(true).backgroundColor(this.listItemBgColor).borderRadius(BORDER_RADIUS_24)
  }

  //list标题组件
  @Builder
  ListTitle(t: ResourceStr){
    Xb_TopTitleBar({
      name: t,
      animationUse: false,
      fontColor: $r("sys.color.font_tertiary"),
      fontSize: 16,
      icon1: undefined,
      icon2: undefined,
      paddingValue: 0,
      isBackPress: false
    })
  }
}

@Extend(Text)
function textStyle(s: string | number | Resource, c: ResourceColor, w: FontWeight){
  .fontSize(s)
  .fontColor(c)
  .fontWeight(w)
  .textAlign(TextAlign.Start)
}

//分组list样式
@Extend(ListItemGroup)
function listItemGroup(){
  .borderRadius(BORDER_RADIUS_24)
  .padding({left: PADDING_VALUE_12, right: PADDING_VALUE_12})
  .divider({ color: $r("app.color.divider_light"), strokeWidth: 1,})
}