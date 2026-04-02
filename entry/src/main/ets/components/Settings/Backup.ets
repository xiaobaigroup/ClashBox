import { skipRowList } from "../Common/Common"
import TopBuilder from "./TopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"
import {  UIConfig } from "../../entryability/AppState"
import { customAnimationUtil } from "../../common/utils/Animation"
import { PageMargin } from "../../common/breakpoint/BreakPoint"
import BackupRestoreUtil, { BackupConfig } from '../../common/utils/BackupRestoreUtil';
import { Xb_GetResourceString, Xb_KVdbUtil, Xb_ToastUtil } from "xb_components"
import { EventHub, EventKey } from "../../common/EventHub"
// import { FileInfo, WebDavClient, WebDavConfig, WebDavManager } from "@ya520/webdav"
import { WebDavManager } from "../../common/utils/webdav/manager"
import { WebDavClient } from "../../common/utils/webdav/client"
import { FileInfo, WebDavConfig } from "../../common/utils/webdav/config"
import { Xb_AnimationStyle } from "xb_components"


@Component
struct Backup {

  @State rawFiles: FileInfo[] = []
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 选中的文件
  @State @Watch('onSelectFileChange') selectFilePath: string = ''
  // 设置页路由表
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack

  // 账号
  @StorageLink('User') user: string = ''
  // 密码
  @StorageLink('Password') password: string = ''
  // 云备份是否登录
  @StorageLink('Login') isLogin: boolean = false
  // 服务器地址
  @StorageLink('Server') server_address: string = ''
  // WebDav
  @StorageLink('WebDAVManager') webdavManager: WebDavManager | null = null
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 弹窗时背景模糊
  @StorageLink('CustomDialog') showCustomDialogBackgroundBlur: boolean = false
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1

  build() {
    NavDestination() {
      TopBuilder({
        title: $r('app.string.Backup_Recovery'),
        pathStack: this.SettingsPageInfos
      })
      // 功能区
      List({ space: 10 }) {
        // 云备份
        ListItem() {
          skipRowList({
            title: $r('app.string.cloud_backup'),
            subtitle: $r('app.string.cloud_backup_subtitle'),
            tips: (): void => { this.CloudBackupTipsText() },
          })
        }
        .onClick(() => {
          // 跳转至云备份
          this.SettingsPageInfos.pushPathByName('CloudBackup', false)
        })
        ListItem() {
          Column() {
            // 备份
            skipRowList({
              icons: $r('sys.symbol.arrowshape_up_to_line_fill'),
              title: $r('app.string.backup'),
              subtitle: this.getBackupSubtitle(),
              tips: (): void => { this.BackupTipsText() },
              isExperimentalFunction: false
            })
              .onClick(() => {
                // 备份数据
                this.onBackupData()
              })
            // 分割线
            Row().height(0.5).backgroundColor($r('app.color.divider')).width('93%')
            // 恢复
            skipRowList({
              icons: $r('sys.symbol.arrowshape_down_to_line_fill'),
              title: $r('app.string.restore'),
              subtitle: this.getRestoreSubtitle(),
              tips: (): void => { this.RestoreTipsText() },
              isExperimentalFunction: false
            })
              .gesture(
                LongPressGesture()
                  .onAction((event: GestureEvent) => {
                    if (event) {
                      // 本地文件恢复
                      this.onLocalRestore()
                    }
                  }))
              .gesture(
                TapGesture({ count: 1 })
                  .onAction((event: GestureEvent) => {
                    if (event) {
                      // 恢复数据
                      if (this.uiConfig.isShowCloudBackupConfig && this.isLogin) {
                        // 云文件恢复
                        this.cloudRestore()
                      } else {
                        // 本地文件恢复
                        this.onLocalRestore()
                      }
                    }
                  }))
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
        }
        .width('100%')
        .borderRadius(20)
        .backgroundColor($r('app.color.container_background'))
        // 恢复提示
        ListItem() {
          Text() {
            Span($r('app.string.file_config_restore_tips'))
            Span($r('app.string.restore_tips'))
              .fontColor(Color.Red)
            Span($r('app.string.restore_tips_2'))
              .fontColor(Color.Red)
          }
        }
      }
      .width('100%')
      .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })

    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.SettingsPageInfos.clear();
      return true;
    })
  }

  cloudFilesController: CustomDialogController = new CustomDialogController({
    builder: CloudFiles({
      selectFilePath: $selectFilePath,
      rawFiles: $rawFiles
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      this.showCustomDialogBackgroundBlur = false
      dismissDialogAction.dismiss()
    }
  })

  @Builder
  CloudBackupTipsText() {
    Text(this.uiConfig.isShowCloudBackupConfig ? (this.isLogin ? $r('app.string.login_success') : $r('app.string.not_login')) : $r('app.string.not_enabled'))
      .fontWeight(FontWeight.Normal)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .margin({top: 2 })
      .fontSize(14)
  }
  @Builder
  BackupTipsText() {
  }
  @Builder
  RestoreTipsText() {
  }

  async aboutToAppear(): Promise<void> {
    // WebDav登录事件
    EventHub.on(EventKey.LoginWebDav, async (showToast: boolean = false) => {
      const config: WebDavConfig = {
        baseUrl: this.server_address,
        username: this.user,
        password: this.password,
        authType: 'basic'
      }
      this.webdavManager = new WebDavManager(
        new WebDavClient(config),
        this.getUIContext().getHostContext()!
      )
      try {
        this.isLogin = true
        console.log(`WebDav 链接成功`)
        if (showToast || this.webdavManager) {
          Xb_ToastUtil.showToast({ message: $r('app.string.login_success') })
        }
      } catch (err) {
        this.isLogin = false
        if (showToast) {
          Xb_ToastUtil.showToast({ message: `${Xb_GetResourceString($r('app.string.login_failed'), this)} name: ${err.name} message: ${err.message}` })
        }
        console.error(`WebDav 链接失败 name: ${err.name} message: ${err.message}`)
      }
    })
    if (this.uiConfig.isShowCloudBackupConfig) {
      await this.loadWebDavConfig()
      if (this.server_address && this.user && this.password) {
        EventHub.sendEvent(EventKey.LoginWebDav)
      }
    }
  }

  // WebDav配置加载
  async loadWebDavConfig() {
    this.user = await Xb_KVdbUtil.getData('webdav_user') as string ?? ''
    this.password = await Xb_KVdbUtil.getData('webdav_password') as string ?? ''
    this.server_address = await Xb_KVdbUtil.getData('webdav_server_address') as string ?? ''
    console.debug(`WebDav 配置信息：user: ${this.user}, password: ${this.password}, server: ${this.server_address}`)
  }

  getBackupSubtitle(): ResourceStr {
    return this.uiConfig.isShowCloudBackupConfig && this.isLogin ? $r('app.string.logined_backup_subtitle') : $r('app.string.backup_subtitle')
  }

  getRestoreSubtitle(): ResourceStr {
    return this.uiConfig.isShowCloudBackupConfig && this.isLogin ? $r('app.string.logined_restore_subtitle') : $r('app.string.restore_subtitle')
  }

  /**
   * 备份应用数据
   */
  async onBackupData() {
    hilog.info(0xFF00, "BackupTag", "开始备份应用数据")
    // 本地备份
    const file_path = await BackupRestoreUtil.backup()
    console.log(`Backup 备份文件的缓存为：${file_path}`)
    if (this.uiConfig.isShowCloudBackupConfig && this.isLogin) {
      // 云备份
      try {
        const value = await this.webdavManager?.createDirectory('/ClashBox')
        if (value)
        console.log(`Backup 创建状态: ${value.statusCode === 201}`)
      } catch (err) {
        console.error(`Backup 创建失败 name: ${err.name} message: ${err.message}`)
      }
      await this.cloudBackup(file_path)
      Xb_ToastUtil.showToast({ message: $r('app.string.export_success') })
    } else {
      Xb_ToastUtil.showToast({ message: $r('app.string.export_success') })
    }
  }

  /**
   * 从本地备份文件恢复应用数据
   */
  onLocalRestore() {
    hilog.info(0xFF00, "BackupTag", "开始从备份文件恢复应用数据")
    BackupRestoreUtil.restore()
  }

  async cloudBackup(file_path: string) {
    try {
      if (this.webdavManager) {
        console.log(`待备份文件的路径是: ${file_path}`)
        const remotePath = '/ClashBox/'
        const value = await this.webdavManager.upload(remotePath, file_path)
        console.log(`云备份状态：${value.statusCode}`)
      }
    } catch (err) {
      Xb_ToastUtil.showToast({ message: `云备份失败 name: ${err.name} message: ${err.message}`, duration: 3000 })
      console.error(`WebDav 备份失败 name: ${err.name} message: ${err.message}`)
    }
  }

  async cloudRestore() {
    if (this.uiConfig.isShowCloudBackupConfig && this.isLogin && this.webdavManager) {
      try {
        const value = await this.webdavManager.listDirectory('/ClashBox')
        this.rawFiles = value.filter(item => item.path !== '/ClashBox/')
        console.log(`#cloudRestore 获取文件列表状态: ${JSON.stringify(this.rawFiles)}`)
        this.cloudFilesController.open()
      } catch (err) {
        Xb_ToastUtil.showToast({ message: `云恢复获取文件失败 name: ${err.name} message: ${err.message}`, duration: 3000 })
        console.error(`获取文件列表失败 name: ${err.name} message: ${err.message}`)
      }
    }
  }

  async onSelectFileChange() {
    console.log(`#cloudRestore 获取文件远端路径: ${this.selectFilePath}`)
    if (this.uiConfig.isShowCloudBackupConfig && this.isLogin) {
      try {
        const str = await this.webdavManager?.getTextFileContent(this.selectFilePath)
        console.log(`获取文件文本状态: ${str}`)
        if (!str) return
        const config = JSON.parse(str) as BackupConfig
        BackupRestoreUtil.restore(config).catch((err: Error) => {
          Xb_ToastUtil.showToast({ message: `云恢复失败 name: ${err.name} message: ${err.message}`, duration: 3000 })
          console.error(`云恢复失败 name: ${err.name} message: ${err.message}`)
        })
      } catch (err) {
        Xb_ToastUtil.showToast({ message: `云恢复文件流获取失败 name: ${err.name} message: ${err.message}`, duration: 3000 })
        console.error(`获取文件流失败 name: ${err.name} message: ${err.message}`)
      }
    }
  }

}

export default Backup

@CustomDialog
struct CloudFiles {

  @Link selectFilePath: string
  @Link rawFiles: FileInfo[]
  private controller: CustomDialogController
  // 弹窗时背景模糊
  @StorageLink('CustomDialog') showCustomDialogBackgroundBlur: boolean = false

  build() {
    Column({space: 10}) {
      Text($r('app.string.cloud_files_title'))
        .fontWeight(FontWeight.Medium)
        .fontSize(20)

      List({space: 10}) {
        ForEach(this.rawFiles, (item: FileInfo) => {
          ListItem() {
            Text(item.name.replace(/^\/ClashBox\//, ''))
              .fontWeight(FontWeight.Normal)
          }
          .width('100%')
          .align(Alignment.Start)
          .backgroundColor($r('app.color.list_item_background_color'))
          .clickEffect(Xb_AnimationStyle.isClick())
          .padding({ top: 16, bottom: 16, left: 12, right: 12 })
          .borderRadius(20)
          .onClick(() => {
            this.selectFilePath = 'ClashBox/' + item.name.replace(/.*?(ClashBox\/)/, "$1");
            this.showCustomDialogBackgroundBlur = false
            this.controller.close()
          })
        })
      }
      .width('100%')
      .padding({ top: 12, bottom: 12})
      .contentEndOffset(20)
      .scrollBar(BarState.Off)
    }
    .padding(16)
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.background'))
  }

  aboutToAppear(): void {
    this.showCustomDialogBackgroundBlur = true
  }

  aboutToDisappear(): void {
    this.showCustomDialogBackgroundBlur = false
  }

}

@Component
export struct CloudBackup {

  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack

  // 账号
  @StorageLink('User') user: string = ''
  // 密码
  @StorageLink('Password') password: string = ''
  // 是否登录
  @StorageLink('Login') isLogin: boolean = false
  // 服务器地址
  @StorageLink('Server') server_address: string = ''
  // WebDav
  @StorageLink('WebDAVManager') webdavManager: WebDavManager | null = null
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0

  build() {
    NavDestination() {
      TopBuilder({
        title: $r('app.string.Backup_Recovery'),
        subtitle: $r('app.string.cloud_backup'),
        pathStack: this.SettingsPageInfos
      })
      List() {
        // 云备份开关
        ListItem() {
          Row() {
            SymbolGlyph($r('sys.symbol.icloud'))
              .fontSize(24)
              .margin({left: 12})
              .fontColor([this.icon_emphasize])
            Column() {
              Row() {
                Text($r('app.string.cloud_backup'))
                  .fontWeight(FontWeight.Medium)
                  .fontSize(16)
                if(this.uiConfig.isShowExperimentalFunction) {
                  // 实验功能提示框
                  Column() {
                    Text($r('app.string.experimental_function'))
                      .fontColor(Color.White)
                      .fontSize(10)
                  }
                  .alignItems(HorizontalAlign.Center)
                  .justifyContent(FlexAlign.Center)
                  .width(50)
                  .height(18)
                  .borderRadius(4)
                  .margin({left: 2})
                  .backgroundColor(this.icon_emphasize)
                }
              }
              Text($r('app.string.cloud_backup_subtitle'))
                .fontWeight(FontWeight.Normal)
                .textOverflow({ overflow: TextOverflow.MARQUEE })
                .maxLines(1)
                .margin({top: 2})
                .fontSize(14)
                .width('65%')
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: $$this.uiConfig.isShowCloudBackupConfig })
              .selectedColor(this.icon_emphasize)
              .hitTestBehavior(HitTestMode.None)
              .margin({right: 12})
          }
          .width('100%')
          .borderRadius(20)
          .margin({bottom: 10})
          .padding({ top: 12, bottom: 12})
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .backgroundColor($r('app.color.container_background'))
          .onClick( ()=> {
            // 显式动画
            Xb_AnimationStyle.animToAPI18(()=>{
              this.uiConfig.isShowCloudBackupConfig = !this.uiConfig.isShowCloudBackupConfig
            }, this.uiConfig.animationSpeed, 'app')
          })
        }

        // WebDav服务器配置区
        if (this.uiConfig.isShowCloudBackupConfig) {
          ListItem() {
            Column({space: 10}) {
              Column() {
                Text($r('app.string.webdav_config'))
                  .fontSize(14)
                  .fontWeight(FontWeight.Normal)
              }.width('100%').alignItems(HorizontalAlign.Start)
              TextInput({ text: $$this.server_address, placeholder: $r('app.string.server_address') })
                .height(40)
                .width('100%')
                .type(InputType.URL)
                .enterKeyType(EnterKeyType.Next)
                .onChange(() => {
                  this.isLogin = false
                })
              TextInput({ text: $$this.user, placeholder: $r('app.string.account_name') })
                .height(40)
                .width('100%')
                .enterKeyType(EnterKeyType.Next)
                .onChange(() => {
                  this.isLogin = false
                })
              TextInput({ text: $$this.password, placeholder: $r('app.string.password') })
                .height(40)
                .width('100%')
                .type(InputType.Password)
                .enterKeyType(EnterKeyType.Done)
                .onChange(() => {
                  this.isLogin = false
                })
                .onSubmit(async (enterKey: EnterKeyType, event: SubmitEvent) => {
                  // 按下输入法回车键时登录WebDav
                  await this.save()
                  EventHub.sendEvent(EventKey.LoginWebDav, true)
                })
              Row() {
                Button(this.isLogin ? $r('app.string.login_success') : $r('app.string.log_on'), { type: ButtonType.Normal })
                  .width(120)
                  .height(40)
                  .borderRadius(20)
                  .backgroundColor(this.icon_emphasize)
                  .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                  .onClick(async () => {
                    // 登录事件
                    await this.save()
                    EventHub.sendEvent(EventKey.LoginWebDav, true)
                  })
                Button($r('app.string.connect_test'), { type: ButtonType.Normal })
                  .width(120)
                  .height(40)
                  .borderRadius(20)
                  .margin({left: 10})
                  .backgroundColor(this.icon_emphasize)
                  .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                  .enabled(this.isLogin ? true : false)
                  .onClick(async () => {
                    // 连接测试
                    try {
                      const value = await this.webdavManager?.linkTest()
                      console.log(`test #cloudRestore 获取文件列表状态: ${JSON.stringify(value, null, 2)}`)
                    } catch (err) {
                      // Xb_ToastUtil.showToast({ message: `文件列表获取失败，云恢复不可用 name: ${err.name} message: ${err.message}`, duration: 3000 })
                      console.error(`获取文件列表失败 name: ${err.name} message: ${err.message}`)
                    }
                  })
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
            }
            .padding(16)
            .width('100%')
            .borderRadius(20)
            .backgroundColor($r('app.color.container_background'))
            .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
            .transition(customAnimationUtil.isScaleTran(0, this.uiConfig))
          }
        }
      }
      .width('100%')
      .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
    }
    .width('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.SettingsPageInfos.pop(true)
      return true
    })
  }

  async aboutToAppear(): Promise<void> {
  }

  async save(): Promise<void> {
    await Xb_KVdbUtil.putData('webdav_server_address', this.server_address)
    await Xb_KVdbUtil.putData('webdav_password', this.password)
    await Xb_KVdbUtil.putData('webdav_user', this.user)
    console.log(`WebDav 保存的配置信息：user: ${this.user}, password: ${this.password}, server: ${this.server_address}`)
  }

  connect() {

  }


}