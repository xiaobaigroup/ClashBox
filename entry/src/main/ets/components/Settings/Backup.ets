import { BreakpointState } from "../../common/breakpointsystem"
import { ANIMATION_DURATION_300, BackupList, BackupListItemProp } from "../../common/Constants"
import TopBuilder from "./TopBuilder"

@Component
struct Backup {
  @State backupList: BackupListItemProp[] = BackupList
  // 设置 -> 备份与恢复 -> 是否启用云备份配置
  @Consume isShowCloudconfig: boolean
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 设置页路由表
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 页面内边距
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>

  handleClick(index: number) {
    if(index === 0) {
      // 跳转至云备份
      this.SettingsPageInfos.pushPathByName('CloudBackup', false)
    } else if(index === 1) {
      // 备份数据
      this.onBackupData()
    } else if(index === 2) {
      // 恢复数据
      this.onRestoreData()
    }
  }

  /**
   * 备份应用数据
   */
  onBackupData() {

  }
  /**
   * 从备份文件恢复应用数据
   */
  onRestoreData() {

  }


  build() {
    NavDestination() {
      TopBuilder({title: $r('app.string.Backup_Recovery')})
      // 功能区
      Column() {
        ForEach(this.backupList, (item: BackupListItemProp, index: number) => {
          Row() {
            SymbolGlyph(item.icons)
              .fontSize(24)
              .margin({left: 12})
              .fontColor([this.icon_emphasize])
            Column() {
              Text(item.title)
                .fontWeight(FontWeight.Medium)
                .fontSize(16)
              Text(item.subtitle)
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
            Text(item.subtitle3)
              .fontWeight(FontWeight.Normal)
              .margin({right: 4 })
              .fontSize(14)
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontSize(28)
              .margin({right: 12})
              .fontColor([this.icon_primary])
          }
          .width('100%')
          .height(53)
          .borderRadius(20)
          .margin({bottom: 10})
          .backgroundColor($r('app.color.container_background'))
          .onClick(() => {
            this.handleClick(index)
          })
        })
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
    // 当备份与恢复页即将弹出至栈顶时触发 TODO 【用户首选项】保存备份与恢复页的数组 即云备份启用状态 Ya@2024-12-24
    .onWillShow(() => {
      if(this.isShowCloudconfig) {
        // 更新备份页数组 -> 已启用
        const ItemData = this.backupList[0]
        ItemData.subtitle3 = $r('app.string.enabled')
        this.backupList.splice(0, 1, ItemData)
      } else {
        // 更新备份页数组 -> 未启用
        const ItemData = this.backupList[0]
        ItemData.subtitle3 = $r('app.string.not_enabled')
        this.backupList.splice(0, 1, ItemData)
      }
    })

  }
}
export default Backup

@Component
export struct CloudBackup {
  @Consume isShowCloudconfig: boolean
  // 实验功能提示框展示变量
  @Consume isShowExperimentalFunction: boolean
  @State isLogon: boolean = false
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @Consume('breakPointStatemorePageMargin') breakPointStatemorePageMargin: BreakpointState<number>

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
                duration: ANIMATION_DURATION_300,
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
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .backgroundColor($r('app.color.container_background'))
        .onClick( ()=> {
          // 展开流量提醒设置列表行 显式动画
          this.getUIContext()?.animateTo({
            duration: ANIMATION_DURATION_300
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
                .clickEffect({ level: ClickEffectLevel.MIDDLE })
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
                .clickEffect({ level: ClickEffectLevel.MIDDLE })
                .opacity(this.isLogon ? 1 : 0.5)
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
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
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