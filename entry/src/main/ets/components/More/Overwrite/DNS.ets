
import { BreakpointState } from "../../../common/breakpointsystem"
import { DNSMenu, ListOverwriteDNSData, MenuListItemProp, moreData } from "../../../common/Constants"
import { hilog } from "@kit.PerformanceAnalysisKit"
import OverwriteTop from "./OverwriteTopBuilder"
import { menuRowList, skipRowList, toggleRowList } from "../../Common"
import { ClashConfig, Dns } from 'proxy_core'
import { AppConfig, copy, UIConfig } from '../../../entryability/AppState'
import { ArrayConfigParam } from "./EditArrayConfig"
import { EventHub, EventKey } from "../../../common/EventHub"
import { JSON } from "@kit.ArkTS"
import { SymbolGlyphModifier } from "@kit.ArkUI"

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
  // 是否进入二级界面
  @Consume isSecondary: boolean
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  @Consume('NavPathStack') pageInfos: NavPathStack
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @State overwriteDNSList: moreData[] = []
  @State DNSMenuList: MenuListItemProp[] = DNSMenu
  @Consume('breakPointStatemorePagelistBottom') listBottom: BreakpointState<number>
  // 列表高度
  @Consume('breakPointStateListHeight') listHeight: BreakpointState<number>
  // 平板竖屏判断
  @StorageProp('istabletVertical')  private istabletVertical: boolean = false
  @State SaveInputValue: string = ''
  @State currentInputValue: string = ''
  // DNS模式临时选择项
  @State DNSModeIndex: number = 0
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
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
  aboutToAppear(): void {
    this.overwriteDNSList = ListOverwriteDNSData(this.clashConfig, this.appConfig)
    let dns = this.clashConfig.dns ?? {} as Dns
    EventHub.on(EventKey.ArrayConfigChanged, (d: ArrayConfigParam) => {
      dns[d.key] = d.value
      this.changeDns(dns)
      this.overwriteDNSList = ListOverwriteDNSData(this.clashConfig, this.appConfig)
    })
  }
  changeDns(dns: Dns){
    this.clashConfig.dns = copy(dns)
  }

  // 列表行点击事件处理
  handleCheck(index: number) {
    let itemData = this.overwriteDNSList[index]
    if(typeof itemData.value == "string" && index === 9){
      this.isEnableIndexForegroundBlur = true
      this.dialogController.open()
    }else{
      this.pageInfos.pushPathByName("EditArrayConfig", {
        key: itemData.name,
        label: itemData.title,
        value: itemData.value
      } as ArrayConfigParam, true)
    }
  }

  // DNS页面开关处理
  handleToggle(index: number, checked: boolean) {
    let dns = this.clashConfig.dns ?? {} as Dns
    switch (index) {
      case 0:
        // 覆写DNS
        hilog.info(0xFF00, "DNStestTag", "覆写DNS")
        this.appConfig.overrideDns = checked
        break
      case 2:
        // 状态
        hilog.info(0xFF00, "DNStestTag", "状态")
        dns.enable = checked
        this.changeDns(dns)
        break
      case 3:
        // 使用Hosts
        hilog.info(0xFF00, "DNStestTag", "使用Hosts")
        dns['use-hosts'] = checked
        this.changeDns(dns)
        break
      case 4:
        // 使用系统Hosts
        hilog.info(0xFF00, "DNStestTag", "使用系统Hosts")
        dns['use-system-hosts'] = checked
        this.changeDns(dns)
        break
      case 5:
        // Ipv6
        hilog.info(0xFF00, "DNStestTag", "Ipv6")
        dns.ipv6 = checked
        this.changeDns(dns)
        break
      case 6:
        // 遵守规则
        hilog.info(0xFF00, "DNStestTag", "遵守规则")
        dns['respect-rules'] = checked
        this.changeDns(dns)
        break
      case 7:
        // 优先使用H3
        hilog.info(0xFF00, "DNStestTag", "优先使用H3")
        dns['prefer-h3'] = checked
        this.changeDns(dns)
        break
      case 17:
        // GeoIP
        hilog.info(0xFF00, "DNStestTag", "GeoIP")
        dns['fallback-filter']["geoIp"] = checked
        this.changeDns(dns)
        break
    }

  }

  @Builder
  switchMenu(item: MenuListItemProp[], index: number) {
    // 栈模式菜单
    Menu() {
      MenuItem({ content: $r('app.string.DNS_Mode') }).contentFont({ weight: FontWeight.Bold })
      ForEach(item, (menuItem: MenuListItemProp, index: number) => {
        MenuItem({
          content: menuItem.title,
          symbolEndIcon: this.DNSModeIndex === index ? new SymbolGlyphModifier($r('sys.symbol.checkmark')) : undefined
        })
          .selected(this.DNSModeIndex === index)
          .onChange(() => {
            this.DNSModeIndex = index
            if (this.DNSMenuList[0].children) {
              let Item = this.overwriteDNSList[8]
              Item.subtitle = menuItem.title
              this.overwriteDNSList.splice(8, 1, Item)
            }
          })
      }, (menuItem: MenuListItemProp) => JSON.stringify(menuItem))
    }
  }

  @Builder
  dnsMenuTipsBuilder(tips: ResourceStr) {
    Text(tips)
      .fontWeight(FontWeight.Normal)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .margin({top: 2 })
      .fontSize(14)
  }
  @Builder
  dnsSkipTipsBuilder(tips: ResourceStr) {
    Text(tips)
      .fontWeight(FontWeight.Normal)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .margin({top: 2, right: 2 })
      .fontSize(14)
  }
  @Builder
  dnsToggleBuilder(isON: boolean) {
    Toggle({ type: ToggleType.Switch, isOn: isON })
      .margin({right: 12})
      .hitTestBehavior(HitTestMode.None)
      .selectedColor(this.icon_emphasize)
  }
  @Builder
  MenuEntrance(index: number) {
    // 确保children存在
    if(this.DNSMenuList && this.DNSMenuList[0].children) {
      this.switchMenu(this.DNSMenuList[0].children, index)
    }
  }


  build() {
    NavDestination() {
      // 导航栏
      OverwriteTop({
        title: $r('app.string.DNS'),
        subtitle: ''
      })

      List({space: this.listBottom.value}) {
        ForEach(this.overwriteDNSList, (item: moreData, index: number) => {
          if (item.sign === 0 ) {
            // 展开型
            ListItem() {
              menuRowList({
                title: item.title,
                tips: () => { this.dnsMenuTipsBuilder(item.subtitle) },
                menu: (): void => { this.MenuEntrance(index) }
              })
            }
          } else
            if (item.sign === 1 ) {
              // 跳转型
              ListItem() {
                if(index != 9 && index != 18 && item.subtitle) {
                  skipRowList({
                    title: item.title,
                    subtitle: item.subtitle
                  })
                } else {
                  skipRowList({
                    title: item.title,
                    tips: () => { this.dnsSkipTipsBuilder(item.subtitle) }
                  })
                }
              }.onClick(() => {
                this.handleCheck(index)
              })
            } else
            if (item.sign === 2 ) {
              // 开关型
              ListItem() {
                toggleRowList({
                  title: item.title,
                  subtitle: item.subtitle,
                  toggle: () => { this.dnsToggleBuilder(item.isCheck) }
                })
              }.onClick(() => {
                hilog.info(0xFF00, "DNStestTag", "开关状态1:  %{public}s", item.isCheck)
                this.getUIContext()?.animateTo({
                  duration: this.uiConfig.animationSpeed
                }, () => {
                  const toggleItem = this.overwriteDNSList[index]
                  toggleItem.isCheck = !toggleItem.isCheck
                  this.overwriteDNSList.splice(index, 1, toggleItem)
                  hilog.info(0xFF00, "DNStestTag", "开关状态2:  %{public}s", toggleItem.isCheck)
                  hilog.info(0xFF00, "DNStestTag", "开关已打开")
                  this.handleToggle(index, toggleItem.isCheck)
                })
              })
            } else
            if (item.sign === 3) {
              // 标题栏
              ListItem() {
               Row() {
                 Text(item.title)
                   .fontWeight(FontWeight.Normal)
                   .fontSize(15)
                 Blank()
               }.width('100%')
                .justifyContent(FlexAlign.Start)
             }
            }

        })

      }
      .width('100%')
     // .height(this.isLandscapePhone ? 275 : (this.istabletVertical ? 945 : this.listHeight.value))
      .padding({ left: this.morePageMargin.value, right: this.morePageMargin.value })
      .margin({ top: 10 })
      .borderRadius(18)
      .alignListItem(ListItemAlign.Center)
      .contentEndOffset(70)
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      if(this.pageInfos.size() === 1) {
        this.pageInfos.clear()
      } else {
        this.pageInfos.pop(true)
      }
      return true
    })
  }
}
export default DNS