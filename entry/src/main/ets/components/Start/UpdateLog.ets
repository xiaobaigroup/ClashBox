import { Xb_GetResourceString, Xb_UpdateLog } from "xb_components"
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
  // 欢迎页半模态窗口
  @Consume isShowWelcome: boolean
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @Consume('NavSettingsPathStack') SettingsPageInfos: NavPathStack
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 是否开启`Index`页面的前景模糊
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  // 显示的是更新日志
  @StorageLink('ShowUpdateLog') showUpdateLog: boolean = false

  build() {
    NavDestination() {
      Column() {
        TopBuilder({
          title: $r('app.string.update_log'),
          showBackButton: this.showBackButton,
          pathStack: this.SettingsPageInfos
        })
        Xb_UpdateLog({
          logoImage: $r('app.media.background_white_large'),
          logoImageBg: $r("app.media.foreground_box_cat_large"),
          appNameImage: $r("app.media.clash_box_blue"),
          listItemGroupBgColor: $r('app.color.container_background'),
          versionName: `${AppState.versionName}(${AppState.versionCode})`,
          updateLog: UpdateLogData,
          alignRow: VerticalAlign.Bottom,
          marginTitle: 8,
          isBackPress: !this.showUpdateLog,
          isShowClose: false,
          needTopTitle: false,
          backPressColor: $r('app.color.back'),
          iconSize: 28,
          isShowAnimation: this.uiConfig.isAnimation,
          animationSpeed: this.uiConfig.animationSpeed,
          widthBp: this.widthBp,
          heightBp: this.heightBp,
          closeUse: () => {
            this.isShowWelcome = false
            this.isEnableIndexForegroundBlur = false
          }
        })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .hideBackButton(true)
    .hideToolBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.SettingsPageInfos.pop()
      return true
    })
  }

  aboutToAppear(): void {
    this.currentGroup = this.updateLog[0].title
  }

}

const UpdateLogData: TCItemProp[] = [
  // 名称：版本号+时间
  {
    title: '1.7.4 2026.1.18',
    content:'MiHoMo核心部分：\n* 更新核心为最新 \n* 支持本地网卡注入（需API22） \n 配置修复：\n* 修复配置文件编辑功能保存数据错误问题 \n* 优化YAML解析性能 \n* 优化代理页节点列表过多掉帧问题 \n* 支持大于5M的配置文件下载，最大100M \n访问控制部分：\n* 访问控制新增在线搜索功能 \n* 修复访问控制全选后失效问题 \n* 访问控制勾选应用置顶显示 \n* 访问控制添加本地图标显示 \n* 访问控制黑名单限制勾选64个，白名单限制勾选62个(因为系统BUG) \n其他部分：\n* 其他体验bug修复'
  },
  {
    title: '1.7.2 2025.12.27',
    content: '* 新增适人握持功能 \n* 新增主页卡片自定义排序功能 \n* 新增配置自定义排序功能 \n* 新增收藏节点一键删除功能 \n* 重构应用持久化数据 \n* 修改配置项单击不刷新（双击刷新） \n* 优化部分界面显示效果 \n* 修复主页IP大卡片IP自动刷新功能失效问题 \n* 优化访问控制功能（黑白名单可以设置勾选不同的应用） \n* 其他体验BUG修复'
  },
  {
    title: '1.7.1 2025.12.12',
    content: '* 修复5.1系统上主页开关消失问题 \n* 修复英文状态下网速曲线UI问题'
  },
  {
    title: '1.7.0 2025.12.03',
    content: '* 如果启动后ip地址显示在国内可以多尝试几次刷新或者重新开关启动按钮 \n* 暂时禁用小组件卡片功能，等待官方修复VPN问题后开放 \n* 更新部分UI（导航栏样式可选悬浮或普通）\n* 新增配置分享二维码功能（不支持本地配置） \n* PC端小猫咪接入状态栏 \n* 新增虚拟ip地址功能（解决部分用户ip冲突问题） \n* 新增配置导出功能 \n* 新增配置文本编辑功能 \n* 新增支持一次性配置链接 \n* 修复配置自动更新功能失效问题 \n* 修复自动获取配置名错误问题 \n* 修复首页ip地址无法获取ipv6地址问题 \n* 修复首页网速图表无法正常显示流量曲线 \n* 更换新的webdav库 \n* 其他体验bug修复'
  },
  {
    title: '1.6.6 2025.10.07',
    content: '*优化模拟下载逻辑 \n* 新增配置碰一碰传输 \n* 新增计算任务（目前只支持平板和PC） \n* 修复6.0.0.107升级后导致出境易和卓易通内应用无法代理问题 \n* 其他体验bug修复'
  },
  {
    title: '1.6.5 2025.09.20',
    content: '* 新增扫码导入配置功能（6.0系统支持更多二维码识别） \n* 新增更新日志显示功能 \n* 新增备份恢复功能 \n* 新增ClashBox小组件卡片功能（卡片在无后台的情况下启动可能失效，等待后续更新） \n* 新增请求列表支持清空操作 \n* 修复覆写-DNS-域名服务器添加内容失效问题（覆盖升级后请到覆写功能里面点击重置覆写设置） \n* 优化延迟排序测速自动排序功能 \n* 修复内核初始化问题 \n* 更改内核前台模式与后台模拟定位为默认功能，保持连接稳定 \n* 访问控制白名单新增内置出境服务 \n* 修复主页收藏卡片显示异常 \n* 其它体验bug修复'
  },
  {
    title: '1.6.0 2025.08.28',
    content: '* 更新内核适配更多协议与修复部分协议相关问题 \n* 修复测速后刷新（提交来自ErBWs） \n* 访问控制新增通过华为市场分享应用到clashbox快速获取包名 \n* 修复了后台过久卡顿的问题 \n* 修复IP显示比较慢的问题 \n* 修复常驻通知没有关闭声音震动一直提示问题 \n* 尝试优化模拟定位功耗问题 \n* 后台运行新增模拟下载功能，(开启模拟下载功能后一定要重启clashbox应用，模拟下载通知不能手动删除，会导致模拟下载功能失效，如果嫌弃开启模拟下载后通知过多可以去clashbox设置里面关闭常驻通知和常驻状态栏功能) \n* 修复并完善tab触发机制和消失问题 \n* 尝试修复配置分组名导致的闪退和其它配置可能引发的问题 \n* 其它体验bug修复'
  },
]