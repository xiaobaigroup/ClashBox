import { BreakpointState } from "../../../common/breakpointsystem"
import { ANIMATION_DURATION_300, ListOverwriteBasicData,  moreData } from "../../../common/Constants"
import { hilog } from "@kit.PerformanceAnalysisKit"
import OverwriteTop from "./OverwriteTopBuilder"
import { menuRowList, skipRowList, toggleRowList } from "../../Common"
import { ClashConfig, LogLevel } from 'proxy_core'
import { AppConfig, copy } from '../../../entryability/AppState'

@Component
struct Basic {
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  //一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')

  @Consume('NavPathStack') pageInfos: NavPathStack
  @StorageProp('isLandscapePhone')  private isLandscapePhone: boolean = false
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  @State overwriteBasicList: moreData[] = []
  @Consume('breakPointStatemorePagelistBottom') listBottom: BreakpointState<number>
  // 列表高度
  @Consume('breakPointStateListHeight') listHeight: BreakpointState<number>
  // 平板竖屏判断
  @StorageProp('istabletVertical')  private istabletVertical: boolean = false
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  aboutToAppear(): void {
    this.overwriteBasicList = ListOverwriteBasicData(this.clashConfig, this.appConfig)
  }
  changeChange(name: string, value: string | boolean | number | Record<string, string>){
    if (this.clashConfig){
      if (name == "LogLevel"){
        this.clashConfig["log-level"] = value as LogLevel
      }
      if (name == "ProxyPort"){
        this.clashConfig["mixed-port"] = value as number
      }
      if (name == "UnifiedLatency"){
        this.clashConfig["unified-delay"] = value as boolean
      }
      if(name == "Ipv6"){
        this.clashConfig.ipv6 = value as boolean
      }
      if(name == "TCP-Concurrency"){
        this.clashConfig['tcp-concurrent'] = value as boolean
      }
      if(name == "Hosts"){
        // 非基础类型需要copy，才能持久化
        this.clashConfig["hosts"] = copy(value as Record<string, string>)
      }
    }
  }
  handleCheck(index: number) {
    // 跳转
    let itemData = this.overwriteBasicList[index]
    this.pageInfos.pushPathByName(itemData.name, false)

  }
  // 开关处理
  handleToggle(index: number) {
    switch (index) {
      case 6:
        // IPv6状态切换
        hilog.info(0xFF00, "BasictestTag", "IPv6")

        break
      case 7:
        // 统一延迟实现
        hilog.info(0xFF00, "BasictestTag", "统一延迟")

        break
      case 8:
        // TCP并发切换
        hilog.info(0xFF00, "BasictestTag", "TCP并发")

        break
      case 9:
        // 外部控制实现
        hilog.info(0xFF00, "BasictestTag", "外部控制")

        break
    }

  }

  @Builder
  basicMenuTipsBuilder(tips: ResourceStr) {
    Text(tips)
      .fontWeight(FontWeight.Normal)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .margin({top: 2 })
      .fontSize(14)
  }
  @Builder
  basicSkipTipsBuilder(tips: ResourceStr) {
    Text(tips)
      .fontWeight(FontWeight.Normal)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .maxLines(1)
      .margin({top: 2, right: 2 })
      .fontSize(14)
  }
  @Builder
  basicToggleBuilder(isON: boolean) {
    Toggle({ type: ToggleType.Switch, isOn: isON })
      .margin({right: 12})
      .hitTestBehavior(HitTestMode.None)
      .selectedColor(this.icon_emphasize)
  }
  build() {
    NavDestination() {
      OverwriteTop({
        title: $r('app.string.Basic'),
        subtitle: ''
      })
      // 列表
      List({space: this.listBottom.value}) {
        ForEach(this.overwriteBasicList, (item: moreData, index: number) => {
          if (item.sign === 0 ) {
            ListItem() {
              // 展开型
              menuRowList({
                icons: item.icons,
                title: item.title,
                isPrimaryIcons: true,
                tips: () => { this.basicMenuTipsBuilder(item.subtitle) }
              })
            }
          } else if (item.sign === 1) {
            ListItem() {
              // 跳转型
              skipRowList({
                icons: item.icons,
                title: item.title,
                isPrimaryIcons: true,
                tips: () => { this.basicSkipTipsBuilder(item.subtitle) }
              })
            }.onClick(() => {
              this.handleCheck(index)
            })
          } else if (item.sign === 2 ) {
            ListItem() {
              // 开关型
              toggleRowList({
                icons: item.icons,
                title: item.title,
                subtitle: item.subtitle,
                isPrimaryIcons: true,
                toggle:  () => { this.basicToggleBuilder(item.isCheck) }
              })
            }.onClick(() => {
              hilog.info(0xFF00, "BasictestTag", "开关状态1:  %{public}s", item.isCheck)
              this.getUIContext()?.animateTo({
                duration: ANIMATION_DURATION_300
              }, () => {
                const toggleItem = this.overwriteBasicList[index]
                toggleItem.isCheck = !toggleItem.isCheck
                this.overwriteBasicList.splice(index, 1, toggleItem)
                hilog.info(0xFF00, "BasictestTag", "开关状态2:  %{public}s", toggleItem.isCheck)
                this.changeChange(toggleItem.name as string, toggleItem.isCheck)
                if(toggleItem.isCheck) {
                  hilog.info(0xFF00, "BasictestTag", "开关已打开")
                  this.handleToggle(index)
                }
              })
            })
          }

        })

      }
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .width('100%')
      .height(this.isLandscapePhone ? 275 : (this.istabletVertical ? 900 : this.listHeight.value))
      .padding({ left: this.morePageMargin.value, right: this.morePageMargin.value })
      .margin({ top: 10 })
      .borderRadius(18)
      .alignListItem(ListItemAlign.Center)

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
export default Basic