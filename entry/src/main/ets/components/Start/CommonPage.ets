import { UIConfig } from "../../entryability/AppState"
import { common } from "@kit.AbilityKit"
import { webview } from "@kit.ArkWeb"
import { i18n } from "@kit.LocalizationKit"
import { BusinessError } from "@kit.BasicServicesKit"


@Component
export struct CommonPage {

  @State webHeight:number = 0
  @State nextPage: string = ''
  // 是否最后一页
  @State isEnd: boolean = false
  @Consume isShowWelcome: boolean
  @State isWebAtEnd:boolean = false
  @State docSrc: Resource | string = ''
  @State isWelcomeStack: boolean = false
  // 单前通信端口
  @State currentPorts: webview.WebMessagePort[]  = []
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 欢迎页面栈
  @Consume('WelcomeNavPathStack') welcomePageInfos: NavPathStack
  // 设置页面栈
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  @State controller: webview.WebviewController = new webview.WebviewController()
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext

  aboutToAppear(): void {
    this.isEnableIndexForegroundBlur = true
    // 配置Web开启调试模式
    webview.WebviewController.setWebDebuggingAccess(true);
  }

  createPorts() {
    this.currentPorts = this.controller.createWebMessagePorts()
    if (this.currentPorts.length) {
      // 传递一个端口
      this.controller.postMessage("trans_port", [this.currentPorts[1]], "*")
      this.currentPorts[0].onMessageEvent((event: webview.WebMessage) => {
        console.log(`CommonPage #webview #onMessageEvent ${JSON.stringify(event)}`)
        if (event === 'ok') {
          this.setLanguage()
        }
      })
    }
  }

  setLanguage() {
    // 用户优先级高
    this.currentPorts[0].postMessageEvent(`${this.uiConfig.userLanguage === 'default' ? this.uiConfig.systemLanguage : this.uiConfig.userLanguage}`);
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

  build() {
    Flex({
      direction: FlexDirection.Column,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.Center,
    }) {
      // 内容
      Flex({
        direction: FlexDirection.Column,
        alignContent: FlexAlign.Start,
        justifyContent: FlexAlign.Center,
      }) {
        Web({ src: this.docSrc, controller: this.controller })
          .fileAccess(true)
          .databaseAccess(true)
          .javaScriptAccess(true)
          // .forceDarkAccess(true)
          .domStorageAccess(true)
          .darkMode(WebDarkMode.Auto)
          .backgroundColor('#00ffffff')
          .onPageBegin((event) => {
            console.log(`CommonPage #webviewBuilder ${JSON.stringify(event)}`)
          })
          .onPageEnd(() => {
            this.getWebHeight()
            this.createPorts()
          })
          .onScroll(() => {
            this.getWebScrollEnd()
          })
          .onControllerAttached(() => {
            try {
              // 设置允许可以跨域访问的路径列表
              this.controller.setPathAllowingUniversalAccess([
                getContext().resourceDir,
              ])
            } catch (error) {
              console.error(`#Webview ErrorCode: ${(error as BusinessError).code},  Message: ${(error as BusinessError).message}`);
            }
          })
          .onAlert((event) => {
            console.log('#Webview event.message:' + event.message)
            return true
          })
      }.width('100%')
      .layoutWeight(1)
      // 按钮
      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.Center
      }) {
        Button(this.isWelcomeStack ? $r('app.string.reject_exit') : $r('app.string.return'))
          .width('50%')
          .fontColor(this.isWelcomeStack ? Color.Red : this.icon_emphasize)
          .margin({ right: 16})
          .backgroundColor($r('app.color.container_background'))
          .onClick(() => {
            if (this.isWelcomeStack) {
              // 拒绝并退出
              this.context.terminateSelf()
            } else {
              this.SettingsPageInfos.pop(true)
            }
          })
        Button(this.isEnd ? $r('app.string.complete') : $r('app.string.agree_continue'))
          .enabled(this.isWebAtEnd)
          .width('50%')
          .fontColor(Color.White)
          .backgroundColor(this.icon_emphasize)
          .onClick(() => {
            if (this.isEnd) {
              // 回到设置首页
              this.SettingsPageInfos.clear()
            } else {
              if (this.isWelcomeStack) {
                this.welcomePageInfos.pushPathByName(this.nextPage, false)
              } else {
                this.SettingsPageInfos.pushPathByName(this.nextPage, false)
              }
            }
          })
      }.width('90%')
      .margin({ top: 12, bottom: 5 })
    }.padding({left: 5, right: 5,  bottom: 15})
  }
}