import { BreakpointState } from '../../common/breakpointsystem'
import { BIND_SHEET_CONTAINER_HEIGHT,
  BORDER_RADIUS_20,
  MarginGenerate, TEXT_AREA_MAX_LENGTH,
  TEXT_INPUT_HEIGHT,
} from '../../common/Constants'
import { CardTitle } from './CardTitleBuilder'
import { common, Want } from '@kit.AbilityKit'
import { PromptAction } from '@kit.ArkUI'

@Component
struct Shortcuts {
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  // 内容文本字体大小
  @Consume('breakPointStateHomeCardSwitchModeFontSize') private fontSize: BreakpointState<number>
  // 内容文本字体大小
  @Consume('breakPointStateCardCellularDataFontSize') private fontSize1: BreakpointState<number>
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding')  private cardPadding: BreakpointState<MarginGenerate>
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean

  @State isShowShortcutsEdit :boolean = false
  //标题输入文本内容
  @State inputTitleValue1: string = ""
  @State inputTitleValue2: string = ""
  @State inputTitleValue3: string = ""
  //web输入文本内容
  @Provide inputWebValue1: string = ""
  @Provide inputWebValue2: string = ""
  @Provide inputWebValue3: string = ""
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  @Consume('breakPointStateTabContentTitleMargin')
  private breakPointStateTabContentTitleMargin: BreakpointState<number>

  // 隐式 Want 跳转网站
  async implicitStartAbility(url: string) {
    try {
      let want: Want = {
        // 如果希望仅在特定包中隐式查询，请取消下面的注释行
        // bundleName: "com.example.myapplication",
        "action": "ohos.want.action.viewData",
        // entities可以省略
     //   "entities": [ "entity.system.browsable" ],
        "uri": url,
      }
      let context = getContext(this) as common.UIAbilityContext;
      await context.startAbility(want)
      console.info(`explicit start ability succeed`)
    } catch (error) {
      console.info(`explicit start ability failed with ${error.code}`)
    }
  }
  //收藏与ping延迟即时动作
  private ShortcutsPromptAction:PromptAction = this.getUIContext()?.getPromptAction()

  build() {
    //快捷小卡片主体 start
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Center }) {
      if (this.inputTitleValue1 != '' && this.inputTitleValue2 != '' && this.inputTitleValue3 != '' ) {
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween}) {
          CardTitle({ title: $r('app.string.shortcuts') })
          Text($r('app.string.click_modify')).fontSize(12).fontColor($r('sys.color.font_fourth')).textOverflow({overflow: TextOverflow.MARQUEE})
        }.width('100%')
          .onClick(() => {
            if (this.inputTitleValue1 != '' && this.inputTitleValue2 != '' && this.inputTitleValue3 != '') {
              this.isShowShortcutsEdit = true
              this.isEnableIndexForegroundBlur = true
            }
          })
      }else {CardTitle({ title: $r('app.string.shortcuts') })}
      Blank(5)
      Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceBetween }) {
        if (this.inputTitleValue1 != ''){
            Text(`${this.inputTitleValue1}`)
              .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
              .ShortcutsTextStyle()
              .onClick(() => {
                if (this.inputWebValue1 != '') {
                  this.implicitStartAbility(this.inputWebValue1)
                }else {
                  this.ShortcutsPromptAction.showToast({ message: $r('app.string.null_title_tips') })
                }
              })
        } else {
          Text($r('app.string.click_modify'))
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .ShortcutsTextStyle()
            .onClick(() => {
              this.isShowShortcutsEdit = true
              this.isEnableIndexForegroundBlur=true
            })
        }

        Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))

        if (this.inputTitleValue2 != '') {
          Text(`${this.inputTitleValue2}`)
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .ShortcutsTextStyle()
            .onClick(() => {
              if (this.inputWebValue2 != '') {
              this.implicitStartAbility(this.inputWebValue2)
              }else {
                this.ShortcutsPromptAction.showToast({ message: $r('app.string.null_title_tips') })
              }
            })
        }else {
          Text($r('app.string.click_modify'))
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .ShortcutsTextStyle()
            .onClick(() => {
              this.isShowShortcutsEdit = true
              this.isEnableIndexForegroundBlur=true
            })
        }

        Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))

        if (this.inputTitleValue3 != '') {
          Text(`${this.inputTitleValue3}`)
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .ShortcutsTextStyle()
            .onClick(() => {
              if (this.inputWebValue3 != '') {
                this.implicitStartAbility(this.inputWebValue3)
              }else {
                this.ShortcutsPromptAction.showToast({ message: $r('app.string.null_title_tips') })
              }
            })
        }else {
          Text($r('app.string.click_modify'))
            .fontSize(this.isLandscapePhone ? 16 : this.fontSize.value)
            .ShortcutsTextStyle()
            .onClick(() => {
              this.isShowShortcutsEdit = true
              this.isEnableIndexForegroundBlur=true
            })
        }

      }
      .width('100%')
      .height('82%')
      .backgroundColor($r('app.color.home_card_background'))
      .borderRadius(10)
      .padding({ top:8,bottom:8 ,left:5})
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
    .bindSheet($$this.isShowShortcutsEdit, this.ShortcutsEdit(), {
      detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.LARGE,],
      preferType: SheetType.CENTER,
      backgroundColor: $r('app.color.background'),
      showClose: true,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      title: { title: $r('app.string.shortcuts_card') },
      onWillDismiss: () => {
        this.isShowShortcutsEdit = false
        this.isEnableIndexForegroundBlur = false
      }
    })
  } //快捷小卡片主体 end

  /* web输入弹窗数据  */
  //绑定第一个按钮弹窗
  WebDialogController1: CustomDialogController | null = new CustomDialogController({
    builder: WebCustomDialog1({
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onAccept() }
    }),
    cancel: this.existApp,
    autoCancel: true,
    onWillDismiss:(dismissDialogAction: DismissDialogAction)=> {
      console.info("reason=" + JSON.stringify(dismissDialogAction.reason))
      console.log("dialog onWillDismiss")
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
    //    this.isEnableIndexForegroundBlur=false
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
     //   this.isEnableIndexForegroundBlur=false
      }
    },
    alignment: DialogAlignment.Center,
    cornerRadius: 32,
    gridCount: 4,
    backgroundColor: Color.White,
  })

  //绑定第二个按钮弹窗
  WebDialogController2: CustomDialogController | null = new CustomDialogController({
    builder: WebCustomDialog2({
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onAccept() }
    }),
    cancel: this.existApp,
    autoCancel: true,
    onWillDismiss:(dismissDialogAction: DismissDialogAction)=> {
      console.info("reason=" + JSON.stringify(dismissDialogAction.reason))
      console.log("dialog onWillDismiss")
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
     //   this.isEnableIndexForegroundBlur=false
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
    //    this.isEnableIndexForegroundBlur=false
      }
    },
    alignment: DialogAlignment.Center,
    cornerRadius: 32,
    gridCount: 4,
    backgroundColor: Color.White,
  })

  //绑定第三个按钮弹窗
  WebDialogController3: CustomDialogController | null = new CustomDialogController({
    builder: WebCustomDialog3({
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onAccept() }
    }),
    cancel: this.existApp,
    autoCancel: true,
    onWillDismiss:(dismissDialogAction: DismissDialogAction)=> {
      console.info("reason=" + JSON.stringify(dismissDialogAction.reason))
      console.log("dialog onWillDismiss")
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
     //   this.isEnableIndexForegroundBlur=false
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
     //   this.isEnableIndexForegroundBlur=false
      }
    },
    alignment: DialogAlignment.Center,
    cornerRadius: 32,
    gridCount: 4,
    backgroundColor: Color.White,
  })
  // 在自定义组件即将析构销毁时将弹窗置空
  aboutToDisappear() {
    this.WebDialogController1 = null // 将dialogController置空
    this.WebDialogController2 = null
    this.WebDialogController3 = null
  }

  onCancel() {
    console.info('Callback when the first button is clicked')
  }

  onAccept() {
    console.info('Callback when the second button is clicked')
  }

  existApp() {
    console.info('Click the callback in the blank area')
  }

  /* 半模拟态相关数据  */
  //半模拟态文本输入控制器及文本内容
  controller: TextInputController = new TextInputController()

  //半模态窗口
  @Builder
  ShortcutsEdit() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Center }) {
      Blank(10)

     Text($r('app.string.option1')).TitleTextStyle()
      Blank(10)
      Column({space:16}){
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
          Text($r('app.string.title')).TextStyle()

          Column({space:2}) {
            TextInput({ placeholder: $r('app.string.text_input_placeholder'), text: this.inputTitleValue1, controller: this.controller })
              .TextInputStyle()
              .caretColor(this.icon_emphasize)//   .underlineColor(this.icon_emphasize)
              .onSubmit((enterKey: EnterKeyType) => {
                enterKey.toString()
                this.inputTitleValue1 != ''
              })
              .onChange((value: string) => {
                this.inputTitleValue1 = value
                this.inputTitleValue1 != ''
              })
            Divider().strokeWidth(1).color(this.icon_emphasize)
          }.width('32%')
        }
        Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
          Text('URL').TextStyle()
          Button($r('app.string.write_url'))
            .ButtonStyle()
            .fontColor(this.icon_emphasize)
            .onClick(() => {
              if (this.WebDialogController1 != null) {
                this.WebDialogController1.open()
        //        this.isEnableIndexForegroundBlur=true
              }
            })
        }
      }.ColumnStyle()
      Blank(10)

      Text($r('app.string.option2')).TitleTextStyle()
      Blank(10)
      Column({space:16}){
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
          Text($r('app.string.title')).TextStyle()

          Column({space:2}) {
          TextInput({ placeholder: $r('app.string.text_input_placeholder'),text:this.inputTitleValue2,controller: this.controller})
            .TextInputStyle()
            .caretColor(this.icon_emphasize)
           // .underlineColor(this.icon_emphasize)
            .onSubmit((enterKey: EnterKeyType) => {
              enterKey.toString()
              this.inputTitleValue2 != ''
            })
            .onChange((value: string) => {
              this.inputTitleValue2 = value
              this.inputTitleValue2 != ''
            })
            Divider().strokeWidth(1).color(this.icon_emphasize)
          }.width('32%')
        }
        Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
          Text('URL').TextStyle()
          Button($r('app.string.write_url'))
            .ButtonStyle()
            .fontColor(this.icon_emphasize)
            .onClick(() => {
              if (this.WebDialogController2 != null) {
                this.WebDialogController2.open()
        //        this.isEnableIndexForegroundBlur=true
              }
            })
        }
      }.ColumnStyle()
      Blank(10)

      Text($r('app.string.option3')).TitleTextStyle()
      Blank(10)
      Column({space:16}){
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
          Text($r('app.string.title')).TextStyle()

          Column({space:2}) {
          TextInput({ placeholder: $r('app.string.text_input_placeholder'),text:this.inputTitleValue3,controller: this.controller})
            .TextInputStyle()
            .caretColor(this.icon_emphasize)
            //.underlineColor(this.icon_emphasize)
            .onSubmit((enterKey: EnterKeyType) => {
              enterKey.toString()
              this.inputTitleValue3 != ''
            })
            .onChange((value: string) => {
              this.inputTitleValue3 = value
              this.inputTitleValue3 != ''
            })
            Divider().strokeWidth(1).color(this.icon_emphasize)
          }.width('32%')
        }
        Divider().strokeWidth(1).color($r('app.color.FavoriteProxyDivider'))
        Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
          Text('URL').TextStyle()
          Button($r('app.string.write_url'))
            .ButtonStyle()
            .fontColor(this.icon_emphasize)
            .onClick(() => {
              if (this.WebDialogController3 != null) {
                this.WebDialogController3.open()
     //           this.isEnableIndexForegroundBlur=true
              }
            })
        }
      }.ColumnStyle()
    }
    .width('100%')
    .padding({
      left: this.breakPointStateTabContentTitleMargin.value,
      right: this.breakPointStateTabContentTitleMargin.value,
    })
  }
}
export default Shortcuts

/* 输入网址自定义弹窗相关 */
//第一个网址按钮打开的自定义弹窗
@CustomDialog
struct WebCustomDialog1 {
  //web输入文本内容
  @Consume inputWebValue1: string

  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean

  controller?: CustomDialogController
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  build() {
    Column() {
      Text($r('app.string.write_url'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
      Blank(15)

      TextArea({ placeholder: 'https://www.google.com',text:this.inputWebValue1})
        .WebTextAreaStyle()
        .caretColor(this.icon_emphasize)
        .onSubmit( (enterKey: EnterKeyType) => {
          enterKey.toString()
          this.inputWebValue1 != ''
        })
        .onChange((value: string) => {
          this.inputWebValue1 = value
        })
      Blank(8)

      Row({space:8}) {
        Button($r('app.string.Cancel'))
          .WebButtonStyle()
          .fontColor(this.icon_emphasize)
          .backgroundColor('#00ffffff')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
          //    this.isEnableIndexForegroundBlur = false
            }
          })

        Button($r('app.string.Save'))
          .WebButtonStyle()
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor(this.icon_emphasize)
          .onClick(() => {
            this.inputWebValue1.toString()
            if (this.controller != undefined) {
              this.controller.close()
           //   this.isEnableIndexForegroundBlur = false
            }
          })
      }

    } .width('100%').padding({top:15,bottom:15,left:24,right:24})
  }
}

//第二个网址按钮打开的自定义弹窗
@CustomDialog
struct WebCustomDialog2 {
  //web输入文本内容
  @Consume inputWebValue2: string
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean

  controller?: CustomDialogController
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  build() {
    Column() {
      Text($r('app.string.write_url'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
      Blank(15)

      TextArea({ placeholder: 'https://www.google.com',text:this.inputWebValue2})
        .WebTextAreaStyle()
        .caretColor(this.icon_emphasize)
        .onSubmit( (enterKey: EnterKeyType) => {
          enterKey.toString()
          this.inputWebValue2 != ''
        })
        .onChange((value: string) => {
          this.inputWebValue2 = value
        })

      Blank(8)

      Row({space:8}) {
        Button($r('app.string.Cancel'))
          .WebButtonStyle()
          .fontColor(this.icon_emphasize)
          .backgroundColor('#00ffffff')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
          //    this.isEnableIndexForegroundBlur = false
            }
          })


        Button($r('app.string.Save'))
          .WebButtonStyle()
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor(this.icon_emphasize)
          .onClick(() => {
            this.inputWebValue2.toString()
            if (this.controller != undefined) {
              this.controller.close()
          //    this.isEnableIndexForegroundBlur = false
            }
          })

      }

    } .width('100%').padding({top:15,bottom:15,left:24,right:24})
  }
}

//第三个网址按钮打开的自定义弹窗
@CustomDialog
struct WebCustomDialog3 {
  //web输入文本内容
  @Consume inputWebValue3: string
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean

  controller?: CustomDialogController
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  build() {
    Column() {
      Text($r('app.string.write_url'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
      Blank(15)

      TextArea({ placeholder: 'https://www.google.com',text:this.inputWebValue3})
        .WebTextAreaStyle()
        .caretColor(this.icon_emphasize)
        .onSubmit( (enterKey: EnterKeyType) => {
          enterKey.toString()
          this.inputWebValue3 != ''
        })
        .onChange((value: string) => {
          this.inputWebValue3 = value
        })

      Blank(8)

      Row({space:8}) {
        Button($r('app.string.Cancel'))
          .WebButtonStyle()
          .fontColor(this.icon_emphasize)
          .backgroundColor('#00ffffff')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
      //        this.isEnableIndexForegroundBlur = false
            }
          })


        Button($r('app.string.Save'))
          .WebButtonStyle()
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor(this.icon_emphasize)
          .onClick(() => {
            this.inputWebValue3.toString()
            if (this.controller != undefined) {
              this.controller.close()
         //     this.isEnableIndexForegroundBlur = false
            }
          })

      }

    } .width('100%').padding({top:15,bottom:15,left:24,right:24})
  }
}



//半模拟态组件样式
@Extend(Column)
function ColumnStyle() {
  .width("100%")
  .backgroundColor($r('app.color.container_background'))
  .padding({ left:10, right:10,top:16,bottom:16 })
  .alignItems(HorizontalAlign.Center)
  .borderRadius(24)
}

//半模拟态内部文本样式
@Extend(Text)
function TextStyle() {
  .width("100%")
  .fontSize(16)
  .fontColor($r('sys.color.font_primary'))
}
//半模拟态小标题文本样式
@Extend(Text)
function TitleTextStyle() {
  .width("100%")
  .fontSize(16)
  .fontColor($r('sys.color.font_secondary'))
  .padding({left:3})
}

//半模拟态内部按钮样式
@Extend(Button)
function ButtonStyle() {
  .width('35%')
  .height(26)
  .fontSize(14)
  .backgroundColor($r('app.color.home_card_background'))
  .clickEffect({ level: ClickEffectLevel.MIDDLE })
}


//半模拟态内部文本输入样式
@Extend(TextInput)
function TextInputStyle() {
  .padding(0)
  .borderRadius(0)
  .placeholderFont({ size:14})
  .textAlign(TextAlign.Center)
  .fontColor($r('sys.color.font_secondary'))
  .showUnderline(false)
  .backgroundColor($r('app.color.container_background'))
}

/* 快捷方式卡片参数 */
//半模拟态内部文本输入样式
@Extend(Text)
function ShortcutsTextStyle() {
  .fontColor($r('sys.color.font_primary'))
  .maxLines(1)
  .width('100%')
  .clickEffect({ level: ClickEffectLevel.MIDDLE })
}

/* 网址输入弹窗参数 */
//网址弹窗文本输入样式
@Extend(TextArea)
function WebTextAreaStyle() {
  .width('100%')
  .height(TEXT_INPUT_HEIGHT * 2)
  .borderRadius(BORDER_RADIUS_20)
  .placeholderFont({ size:16})
  .textAlign(TextAlign.Start)
  .fontColor($r('sys.color.font_secondary'))
  .type(TextAreaType.URL)
  .wordBreak(WordBreak.BREAK_ALL)
  .maxLength(TEXT_AREA_MAX_LENGTH)
  .backgroundColor($r('app.color.home_card_background'))
}

//网址弹窗按钮样式
@Extend(Button)
function WebButtonStyle() {
  .width(144)
  .fontSize(16)
}