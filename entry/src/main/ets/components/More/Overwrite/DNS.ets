
import { BreakpointState } from "../../../common/breakpointsystem"
import { ListOverwriteDNSData,  moreData } from "../../../common/Constants"
import { hilog } from "@kit.PerformanceAnalysisKit"
import OverwriteTop from "./OverwriteTopBuilder"

// 编辑FakeIP范围弹窗
@CustomDialog
struct FakeIPCustomDialog {
  @Link SaveInputValue: string
  @Link currentInputValue: string
  cancel?: () => void
  confirm?: () => void
  controller: CustomDialogController
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor

  build() {
    Column() {
      Text($r('app.string.Edit_FakeIP_Range'))
        .fontWeight(FontWeight.Medium)
        .fontSize(20)
        .margin({ top: 15, bottom: 15 })
      TextInput({placeholder: '例如：198.18.0.1/16', text: this.currentInputValue })
        .onChange((value: string) => {
          this.currentInputValue = value
        })
        .margin({bottom: 8 })
      Button($r('app.string.Save'))
        .width('100%')
        .height(39)
        .onClick(() => {
          this.SaveInputValue = this.currentInputValue
          this.controller.close()
          if (this.confirm) {
            this.confirm()
          }
        })
        .backgroundColor(this.icon_emphasize)
        .fontColor(Color.White)
      Button($r('app.string.Cancel'))
        .height(39)
        .width('100%')
        .fontColor(this.icon_emphasize)
        .backgroundColor($r('app.color.container_background'))
        .onClick(() => {
          this.controller.close()
          if (this.cancel) {
            this.cancel()
          }
        })
    }
    .padding({left: 16, right: 16})
    .backgroundColor($r('app.color.container_background'))
    .width('100%')
    .height(195)
  }
}

@Component
struct DNS {
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  @Consume('NavPathStack') pageInfos: NavPathStack
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @State overwriteDNSList: moreData[] = ListOverwriteDNSData()
  @Consume('breakPointStatemorePagelistBottom') listBottom: BreakpointState<number>
  // 列表高度
  @Consume('breakPointStateListHeight') listHeight: BreakpointState<number>
  // 平板竖屏判断
  @StorageProp('istabletVertical')  private istabletVertical: boolean = false
  @State SaveInputValue: string = ''
  @State currentInputValue: string = ''
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean
  // 弹窗控制器
  dialogController: CustomDialogController = new CustomDialogController({
    builder: FakeIPCustomDialog({
      currentInputValue: $currentInputValue,
      SaveInputValue: $SaveInputValue,
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onAccept() },
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      // 1、PRESS_BACK    点击三键back、左滑/右滑、键盘ESC。
      // 2、TOUCH_OUTSIDE    点击遮障层时
      // 3、CLOSE_BUTTON    点击关闭按钮
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        // 点击遮蔽层不响应，防误触
      } else {
        // 完成IP地址查询后主动通过dismiss主动关闭对话框
        dismissDialogAction.dismiss()
        // 关闭背景模糊
        this.isEnableIndexForegroundBlur = false
      }
    },
  })

  onCancel() {
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
  }
  onAccept() {
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
    // 更新UI数组中对应元素
    let FakeIPRangeData = this.overwriteDNSList[9]
    FakeIPRangeData.subtitle = this.SaveInputValue
    this.overwriteDNSList.splice(9,1,FakeIPRangeData)
    // 处理FakeIP范围变更

  }

  // 列表行点击事件处理
  handleCheck(index: number) {
    if(index === 9) {
      // 启用背景模糊
      this.isEnableIndexForegroundBlur = true
      this.dialogController.open()
    } else {
      // 跳转
      let itemData = this.overwriteDNSList[index]
      this.pageInfos.pushPathByName(itemData.name, false)
    }
  }

  // DNS页面开关处理
  handleToggle(index: number) {
    switch (index) {
      case 0:
        // 覆写DNS
        hilog.info(0xFF00, "DNStestTag", "覆写DNS")

        break
      case 2:
        // 状态
        hilog.info(0xFF00, "DNStestTag", "状态")

        break
      case 3:
        // 使用Hosts
        hilog.info(0xFF00, "DNStestTag", "使用Hosts")

        break
      case 4:
        // 使用系统Hosts
        hilog.info(0xFF00, "DNStestTag", "使用系统Hosts")

        break
      case 5:
        // Ipv6
        hilog.info(0xFF00, "DNStestTag", "Ipv6")

        break
      case 6:
        // 遵守规则
        hilog.info(0xFF00, "DNStestTag", "遵守规则")

        break
      case 7:
        // 优先使用H3
        hilog.info(0xFF00, "DNStestTag", "优先使用H3")

        break
      case 17:
        // GeoIP
        hilog.info(0xFF00, "DNStestTag", "GeoIP")

        break
    }

  }

  build() {
    NavDestination() {
      // 导航栏
      OverwriteTop({
        title: $r('app.string.DNS'),
        subtitle: ''
      })

      List() {
        ForEach(this.overwriteDNSList, (item: moreData, index: number) => {
          if (item.sign === 0 ) {
            // 展开型
            ListItem() {
              Row() {
                Row() {
                  Text(item.title)
                    .fontWeight(FontWeight.Medium)
                    .fontSize(16)
                    .padding({ left: 12 })
                  Blank()
                  Text(item.subtitle)
                    .fontWeight(FontWeight.Normal)
                    .margin({top: 2 })
                    .fontSize(14)
                  SymbolGlyph($r('sys.symbol.arrowtriangle_down_fill'))
                    .fontSize(14)
                    .fontColor([this.icon_primary])
                    .margin({left: 7, right: 20})
                }
                .width('94%')
                .height(53)
                .borderRadius(20)
                .backgroundColor($r('app.color.container_background'))
                Row()
                  .height(10)
              }
              .onClick(() => {
                this.handleCheck(index)
              })
            }
            .margin({bottom: this.listBottom.value })
          } else
            if (item.sign === 1 ) {
              // 跳转型
              ListItem() {
                Row() {
                  Row() {
                    Column() {
                      Text(item.title)
                        .fontWeight(FontWeight.Medium)
                        .fontSize(16)
                      if(index != 9 && index != 18 && item.subtitle) {
                        Text(item.subtitle)
                          .fontWeight(FontWeight.Normal)
                          .textOverflow({ overflow: TextOverflow.MARQUEE })
                          .maxLines(1)
                          .width('85%')
                          .margin({ top: 2 })
                          .fontSize(14)
                      }
                    }
                    .alignItems(HorizontalAlign.Start)
                    .margin({ left: 12 })
                    Blank()
                    if(index === 9 || index === 18) {
                      Text(item.subtitle)
                        .fontWeight(FontWeight.Normal)
                        .margin({right: 4 })
                        .fontSize(14)
                    }
                    SymbolGlyph($r('sys.symbol.chevron_right'))
                      .fontSize(28)
                      .margin({right: 12})
                      .fontColor([this.icon_primary])
                  }
                  .width('94%')
                  .height(53)
                  .borderRadius(20)
                  .backgroundColor($r('app.color.container_background'))
                  Row()
                    .height(10)
                }
                .onClick(() => {
                  this.handleCheck(index)
                })
              }
              .margin({bottom: this.listBottom.value })
            } else
            if (item.sign === 2 ) {
              // 开关型
              ListItem() {
                Row() {
                  Row() {
                    Text(item.title)
                      .fontWeight(FontWeight.Medium)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .width('86%')
                      .maxLines(1)
                      .fontSize(16)
                      .padding({ left: 12 })
                    Blank()
                    Toggle({ type: ToggleType.Switch, isOn: item.isCheck })
                      .margin({right: 12})
                      .selectedColor(this.icon_emphasize)
                      .onChange((isOn: boolean) => {
                        if(isOn) {
                          this.handleToggle(index)
                        }
                      })
                  }
                  .width('94%')
                  .height(53)
                  .borderRadius(20)
                  .backgroundColor($r('app.color.container_background'))
                  Row()
                    .height(10)
                }
                .onClick(() => {
                  this.handleCheck(index)
                })
              }
              .margin({bottom: this.listBottom.value })
            } else
            if (item.sign === 3) {
              // 标题栏
              ListItem() {
               Row() {
                 Row() {
                   Text(item.title)
                     .fontWeight(FontWeight.Normal)
                     .fontSize(16)
                   //.padding({ left: 12 })
                   Blank()
                 }
                 .width('94%')
                 .height(29)
                 Row()
                   .height(10)
               }
             }
            }

        })

      }
      .width('100%')
      .height(this.isLandscapePhone ? 275 : (this.istabletVertical ? 900 : this.listHeight.value))
      .margin({ top: 10, left: this.morePageMargin.value, right: this.morePageMargin.value })
      .borderRadius(18)
      .alignListItem(ListItemAlign.Center)

    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.pageInfos.clear();
      return true;
    })
  }
}
export default DNS