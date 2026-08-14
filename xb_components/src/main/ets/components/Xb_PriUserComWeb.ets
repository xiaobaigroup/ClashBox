import { webview } from "@kit.ArkWeb"
import { BusinessError } from "@kit.BasicServicesKit"
import { context } from "./Constants"


@ComponentV2
export struct Xb_PriUserComWeb {

  @Param appName: string = ''
  @Param nextPage: string = ''
  @Param fontColor: ResourceColor = $r('sys.color.font_primary')
  @Param emphasizeColor: ResourceColor = ''
  @Param docSrc: Resource | string = ''
  // 开发者
  @Param developerName: string = ''
  // 是否最后一页
  @Param isEnd: boolean = false
  @Param needAccount: boolean = false
  @Param needOpenSource: boolean = false
  @Param isWelcomeStack: boolean = false
  @Param topWebPaddingValue: Length | Padding | LocalizedPadding = { top: 0}
  //是否强制深色模式
  @Param isForceDark: boolean = false
  //是否开启滚动条
  @Param isShowBar: boolean = true

  @Param @Require currentLanguage: string
  // 欢迎页面栈
  @Param @Require priuserPageInfos: NavPathStack

  @Local webHeight:number = 0
  @Local isWebAtEnd:boolean = false
  // 当前通信端口
  @Local currentPorts: webview.WebMessagePort[]  = []
  @Local controller: webview.WebviewController = new webview.WebviewController()

  @Event onRightCheck?: () => void
  @Event onLeftCheck?: () => void

  build() {
    Flex({
      direction: FlexDirection.Column,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.Center,
    })
    {
      // 内容
      Flex({
        direction: FlexDirection.Column,
        alignContent: FlexAlign.Start,
        justifyContent: FlexAlign.Center,
      })
      {
        Web({ src: this.docSrc, controller: this.controller })
          .fileAccess(true)
          .databaseAccess(true)
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .darkMode(WebDarkMode.Auto)
          .forceDarkAccess(this.isForceDark)
          .backgroundColor(Color.Transparent)
          .overScrollMode(OverScrollMode.ALWAYS)
          .verticalScrollBarAccess(this.isShowBar)
          .nestedScroll({
            scrollForward: NestedScrollMode.SELF_ONLY,
            scrollBackward: NestedScrollMode.SELF_ONLY,
          })
          //.backgroundColor($r("sys.color.text_button_container_focus_color"))
          .onPageBegin((event) => {
            console.log(`Xb_PriUserComWeb #webviewBuilder ${JSON.stringify(event)}`)
          })
          .onPageEnd(() => {
            this.getWebHeight()
            this.createPorts()
          })
          .onScroll(() => {
            this.getWebScrollEnd()
          })
          // .onControllerAttached(() => {
          //   try {
          //     // 设置允许可以跨域访问的路径列表
          //     this.controller.setPathAllowingUniversalAccess([
          //       getContext().resourceDir,
          //     ])
          //   } catch (error) {
          //     console.error(`Xb_PriUserComWeb #Webview ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
          //   }
          // })
          .onAlert((event) => {
            console.log('Xb_PriUserComWeb #Webview event.message:' + event.message)
            return true
          })
      }.width('100%').padding(this.topWebPaddingValue)
      .layoutWeight(1)
      // 按钮
      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.Center
      }) {
        Button(this.isWelcomeStack ? $r('app.string.xb_reject_exit') : $r('app.string.xb_return'))
          .width('50%')
          .fontColor(this.isWelcomeStack ? Color.Red : this.fontColor)
          .margin({ right: 16})
          .backgroundColor($r('sys.color.container_modal_background'))
          .onClick(() => {
            if (this.isWelcomeStack) {
              // 拒绝并退出
              this.getUIContext()?.getHostContext()?.getApplicationContext().killAllProcesses().catch(() => {
                console.log(`已退出应用`)
              })
            } else {
              if (this.onLeftCheck) {
                this.onLeftCheck()
              } else {
                this.priuserPageInfos.pop(true)
              }
            }
          })
        Button(this.isEnd ? $r('app.string.xb_completed') : $r('app.string.xb_agree_continue'))
          .enabled(this.isWebAtEnd)
          .width('50%')
          .fontColor(Color.White)
          .backgroundColor(this.emphasizeColor)
          .onClick(() => {
            if (this.onRightCheck) {
              this.onRightCheck()
            } else {
              // 默认事件
              if (this.isEnd) {
                // 回到设置首页
                this.priuserPageInfos.clear()
              } else {
                this.priuserPageInfos.pushPathByName(this.nextPage, false)
              }
            }
            console.info('页面栈情况：', JSON.stringify(this.priuserPageInfos), '页面：', this.nextPage)
          })
      }.width('90%')
      .padding({ top: 12, bottom: 20 })
    }.padding({left: 5, right: 5})
  }

  aboutToAppear(): void {
    // 配置Web开启调试模式
    webview.WebviewController.setWebDebuggingAccess(true);
  }

  createPorts() {
    this.currentPorts = this.controller.createWebMessagePorts()
    if (this.currentPorts.length) {
      // 传递一个端口
      this.controller.postMessage("trans_port", [this.currentPorts[1]], "*")
      this.currentPorts[0].onMessageEvent((event: webview.WebMessage) => {
        console.log(`Xb_PriUserComWeb #webview #onMessageEvent ${JSON.stringify(event)}`)
        if (event === 'ok') {
          // 传递应用名|是否需要开源
          this.currentPorts[0].postMessageEvent(`CONFIG:${this.appName}|${this.needOpenSource}|${this.needAccount}|${this.developerName}`)
        }
        if (event.toString().includes('配置设置成功')) {
          this.setLanguage()
        }
      })
    }
  }

  setLanguage() {
    // 用户优先级高
    this.currentPorts[0].postMessageEvent('LANGUAGE:' + this.currentLanguage)
  }

  // 获取web高度
  getWebHeight() {
    try {
      this.controller?.runJavaScriptExt('window.innerHeight',
        (error, result) => {
          if (error || !result) {
            return;
          }
          if (result.getType() === webview.JsMessageType.NUMBER) {
            this.webHeight = result.getNumber()
          }
        })
    } catch (error) {
    }
  }

  getWebScrollEnd() {
    this.isWebAtEnd = false
    if (this.controller.getScrollOffset().y + this.webHeight >= this.controller.getPageHeight()) {
      this.isWebAtEnd = true
    }
  }

}