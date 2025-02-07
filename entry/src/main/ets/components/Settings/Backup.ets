import { BreakpointState } from "../../common/breakpointsystem"
import { ExperimentalFunction, skipRowList } from "../Common"
import TopBuilder from "./TopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"
import {  UIConfig } from "../../entryability/AppState"

@Component
struct Backup {
  // 设置 -> 备份与恢复 -> 是否启用云备份配置
  @Consume isShowCloudconfig: boolean
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 设置页路由表
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 实验功能提示框展示变量
  @Consume isShowExperimentalFunction: boolean
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 页面内边距
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>
  /**
   * 备份应用数据
   */
  onBackupData() {
    hilog.info(0xFF00, "BackupTag", "开始备份应用数据")

  }
  /**
   * 从备份文件恢复应用数据
   */
  onRestoreData() {
    hilog.info(0xFF00, "BackupTag", "开始从备份文件恢复应用数据")

  }

  @Builder
  CloudBackupTipsText() {
    Text(this.isShowCloudconfig ? $r('app.string.enabled') : $r('app.string.not_enabled'))
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

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Backup_Recovery')})
      // 功能区
      Column({space: 10}) {
        // 云备份
        if(this.isShowExperimentalFunction) {
          skipRowList({
            title: $r('app.string.cloud_backup'),
            subtitle: $r('app.string.cloud_backup_subtitle'),
            tips: (): void => { this.CloudBackupTipsText() },
            isExperimentalFunction: true
          })
            .onClick(() => {
              // 跳转至云备份
              this.SettingsPageInfos.pushPathByName('CloudBackup', false)
            })
        }
        Column() {
          // 备份
          skipRowList({
            icons: $r('sys.symbol.arrowshape_up_to_line_fill'),
            title: $r('app.string.backup'),
            subtitle: $r('app.string.backup_subtitle'),
            tips: (): void => { this.BackupTipsText() },
            isExperimentalFunction: false
          })
            .onClick(() => {
              // 备份数据
              this.onBackupData()
            })
          // 分割线
          Row().height(0.5).backgroundColor('#0D000000').width('93%')
          // 恢复
          skipRowList({
            icons: $r('sys.symbol.arrowshape_down_to_line_fill'),
            title: $r('app.string.restore'),
            subtitle: $r('app.string.restore_subtitle'),
            tips: (): void => { this.RestoreTipsText() },
            isExperimentalFunction: false
          })
            .onClick(() => {
              // 恢复数据
              this.onRestoreData()
            })
        }
        .width('100%')
        .borderRadius(20)
        .clickEffect(this.uiConfig.isAnimation ? { level: ClickEffectLevel.MIDDLE, scale: 0.8} : null)
        .backgroundColor($r('app.color.container_background'))
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .padding({ left: this.breakPointStatemorePageMargin.value, right: this.breakPointStatemorePageMargin.value })
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.SettingsPageInfos.clear();
      return true;
    })
  }
}
export default Backup



@Component
export struct CloudBackup {
  @Consume isShowCloudconfig: boolean // TODO 【用户首选项】保存云备份启用状态 Ya@2025-01-12
  // 实验功能提示框展示变量
  @Consume isShowExperimentalFunction: boolean
  @State isLogon: boolean = false
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 页面内边距
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Backup_Recovery'), subtitle: $r('app.string.cloud_backup')})
      Column() {
        // 云备份开关
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
              if(this.isShowExperimentalFunction) {
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
          Toggle({ type: ToggleType.Switch, isOn: $$this.isShowCloudconfig })
            .selectedColor(this.icon_emphasize)
            .margin({right: 12})
            .onChange((isOn: boolean) => {
              // 开关云备份 显式动画 TODO 【用户首选项】保存云备份启用状态 Ya@2024-12-24
              this.getUIContext()?.animateTo({
                duration: this.uiConfig.animationSpeed,
                curve: Curve.Ease
              }, () => {
                this.isShowCloudconfig = isOn
              })
            })
        }
        .width('100%')
        .height(53)
        .borderRadius(20)
        .margin({bottom: 10})
          .clickEffect(this.uiConfig.isAnimation ? { level: ClickEffectLevel.MIDDLE, scale: 0.8} : null)
        .backgroundColor($r('app.color.container_background'))
        .onClick( ()=> {
          // 展开流量提醒设置列表行 显式动画
          this.getUIContext()?.animateTo({
            duration: this.uiConfig.animationSpeed
          }, () => {
            this.isShowCloudconfig = !this.isShowCloudconfig
          })
        })

        // WebDav服务器配置区
        if(this.isShowCloudconfig) {
          Column({space: 10}) {
            Column() {
              Text($r('app.string.webdav_config'))
                .fontSize(14)
                .fontWeight(FontWeight.Normal)
            }.width('100%').alignItems(HorizontalAlign.Start)
            TextInput({placeholder: $r('app.string.server_address')})
              .height(40)
              .width('100%')
            TextInput({placeholder: $r('app.string.account_name')})
              .height(40)
              .width('100%')
            TextInput({placeholder: $r('app.string.password')})
              .height(40)
              .width('100%')
              .type(InputType.Password)
            Row() {
              Button($r('app.string.log_on'), { type: ButtonType.Normal })
                .width(120)
                .height(40)
                .borderRadius(20)
                .backgroundColor(this.icon_emphasize)
                  .clickEffect(this.uiConfig.isAnimation ? { level: ClickEffectLevel.MIDDLE, scale: 0.8} : null)
                .onClick(() => {
                  // 暂时写成点击后赋值为true，后续需要根据登录状态来赋值
                  this.isLogon = true
                  // 登录事件逻辑 TODO 【用户首选项】保存WebDav配置 Ya@2024-12-24

                })
              Button($r('app.string.connect_test'), { type: ButtonType.Normal })
                .width(120)
                .height(40)
                .borderRadius(20)
                .margin({left: 10})
                .backgroundColor(this.icon_emphasize)
                  .clickEffect(this.uiConfig.isAnimation ? { level: ClickEffectLevel.MIDDLE, scale: 0.8} : null)
                .enabled(this.isLogon ? true : false)
                .onClick(() => {
                  // 连接测试

                })
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .padding(10)
          .borderRadius(20)
            .clickEffect(this.uiConfig.isAnimation ? { level: ClickEffectLevel.MIDDLE, scale: 0.8} : null)
          .backgroundColor($r('app.color.container_background'))
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: this.breakPointStatemorePageMargin.value, right: this.breakPointStatemorePageMargin.value })
    }
    .width('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.SettingsPageInfos.pop(true)
      return true
    })
  }
}