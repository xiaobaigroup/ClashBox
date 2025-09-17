import { Xb_GetResourceString } from "xb_components"
import { PageMargin } from "../../common/breakpoint/BreakPoint"
import { LIST_ITEM_HEIGHT, TCItemProp } from "../../common/entity/Constants"
import { customAnimationUtil } from "../../common/utils/Animation"
import { AppState, UIConfig } from "../../entryability/AppState"
import TopBuilder from "../Settings/TopBuilder"

@Component
export struct UpdateLog {

  @State showGroup: boolean = true
  @State currentGroup: ResourceStr = ''
  @State showBackButton: boolean = false
  @State updateLog: TCItemProp[] = UpdateLogData
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0

  build() {
    NavDestination() {
      TopBuilder({
        title: $r('app.string.update_log'),
        showBackButton: this.showBackButton
      })
      List({space: 10}) {
        // Logo & 名称
        ListItem() {
          Column({space: 15}) {
            // logo
            Stack() {
              Image($r('app.media.background_white_large'))
                .borderRadius(25)
                .height(106)
                .zIndex(1)
              Image($r("app.media.foreground_box_cat_large"))
                .height(106)
                .zIndex(2)
            }
            // 名称
            Image($r("app.media.clash_box_blue"))
              .width(192)
            Text() {
              Span($r('app.string.current_version'))
              Span('：')
              Span(AppState.versionName)
            }
              .fontSize(15)
              .fontWeight(FontWeight.Normal)
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .width('100%')
          .borderRadius(20)
          .height(220)
        }
        // 更新日志
        ForEach(this.updateLog, (item: TCItemProp) => {
          ListItemGroup({
            header: this.itemHead(item.title, ((this.showGroup && this.currentGroup === item.title) ? $r('sys.symbol.chevron_down') : $r('sys.symbol.chevron_right')))
          })
          {
            if (this.showGroup && this.currentGroup === item.title) {
              ListItem() {
                // 内容
                Text(item.content)
                  .fontSize(15)
                  .margin({top: 2})
                  .fontWeight(FontWeight.Normal)
              }
              .padding({ left: 10, right: 10 })
            }
          }
          .padding(10)
          .width('100%')
          .borderRadius(20)
          .backgroundColor($r('app.color.container_background'))
          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
          .onClick(() => {
            this.getUIContext().animateTo({
              duration: this.uiConfig.animationSpeed,
            },() => {
              this.currentGroup = item.title
              this.showGroup = !this.showGroup
            })
          })
        })
      }
      .width('100%')
      .alignListItem(ListItemAlign.Center)
      .contentEndOffset(86)
      .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.SettingsPageInfos.pop()
      return true
    })
  }

  @Builder
  itemHead(text: ResourceStr, icon: Resource) {
    Row() {
      Text(text)
        .maxLines(1)
        .fontSize(17)
        .fontColor($r('sys.color.font_primary'))
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      SymbolGlyph(icon)
        .fontSize(25).fontColor([$r('sys.color.icon_primary')])
    }
    .height(36)
    .width('100%')
    .borderRadius(20)
    .backgroundColor($r('app.color.container_background'))
    .padding({ left: 10, right: 10 })
    .justifyContent(FlexAlign.SpaceBetween)
    .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
  }

  aboutToAppear(): void {
    this.currentGroup = this.updateLog[0].title
  }

}

const UpdateLogData: TCItemProp[] = [
  // 名称：版本号+时间
  {
    title: '1.6.4 2025.09.16',
    content: '* 新增扫码导入配置功能（6.0系统支持更多二维码识别） \n* 新增更新日志显示功能 \n* 新增备份恢复功能 \n* 新增ClashBox小组件卡片功能（卡片在无后台的情况下启动可能失效，等待后续更新） \n* 新增请求列表支持清空操作 \n* 修复覆写-DNS-域名服务器添加内容失效问题（覆盖升级后请到覆写功能里面点击重置覆写设置） \n* 优化延迟排序测速自动排序功能 \n* 修复内核初始化问题 \n* 更改内核前台模式与后台模拟定位为默认功能，保持连接稳定 \n* 访问控制白名单新增内置出境服务 \n* 修复主页收藏卡片显示异常 \n* 其它体验bug修复'
  },
  {
    title: '1.6.0 2025.08.28',
    content: '* 更新内核适配更多协议与修复部分协议相关问题 \n* 修复测速后刷新（提交来自ErBWs） \n* 访问控制新增通过华为市场分享应用到clashbox快速获取包名 \n* 修复了后台过久卡顿的问题 \n* 修复IP显示比较慢的问题 \n* 修复常驻通知没有关闭声音震动一直提示问题 \n* 尝试优化模拟定位功耗问题 \n* 后台运行新增模拟下载功能，(开启模拟下载功能后一定要重启clashbox应用，模拟下载通知不能手动删除，会导致模拟下载功能失效，如果嫌弃开启模拟下载后通知过多可以去clashbox设置里面关闭常驻通知和常驻状态栏功能) \n* 修复并完善tab触发机制和消失问题 \n* 尝试修复配置分组名导致的闪退和其它配置可能引发的问题 \n* 其它体验bug修复'
  },
]