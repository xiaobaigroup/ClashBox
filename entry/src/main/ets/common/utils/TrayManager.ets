/**
 * @description 系统托盘控制器单例。
 *              仅在桌面环境(HarmonyOS PC / MatePad Edge PC模式)下生效：
 *              - 负责托盘图标的注册/注销(一次生命周期一份资源，无重复监听)
 *              - 左键点击 -> 恢复既有主窗口(showAbility)
 *              - 右键菜单 -> 复用既有代理状态(ClashViewModel/Profile)的快捷节点切换
 *              - 关闭窗口 -> 隐藏到托盘，VPN/Mihomo 与既有长连接不受影响
 *              - 系统退出 -> 注销监听、移除托盘，由系统完成正常生命周期终止
 *              - 应用内直接退出 -> 完成同样清理后沿用既有强制退出语义
 */
import { statusBarManager } from '@kit.DeskTopExtensionKit';
import { image } from '@kit.ImageKit';
import { window } from '@kit.ArkUI';
import { common, contextConstant, StartOptions, Want } from '@kit.AbilityKit';
import { emitter, BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ClashConfig, Profile, ProxyGroup, ProxyMode, ProxyType } from 'proxy_core';
import ClashViewModel from '../../entryability/ClashViewModel';
import { AppConfig, AppState } from '../../entryability/AppState';
import { EventHub, EventKey } from '../EventHub';
import { cardManager } from './CardManageUtil';
import { ProxyItem } from '../datasources/ProxyData';
import { Xb_ToastUtil } from 'xb_components';
import { DesktopEnvironment } from './DesktopEnvironment';

const TAG = 'TrayManager'
/** 右键菜单项唯一标识 */
const MENU_CODE_OPEN = 'clashbox.tray.open'
const MENU_CODE_MORE = 'clashbox.tray.more'
/** 平台限制：单个一级菜单最多20个子菜单项 */
const MAX_SUB_MENU = 20
/** 平台限制：所有分组一级菜单项总和不超过20个(为操作组预留2项) */
const MAX_GROUP_MENU = 18
/** 菜单重建防抖(ms) - 避免配置加载期间的密集刷新触发1010710003 */
const MENU_REBUILD_DEBOUNCE = 300

export class TrayManager {
  private static instance: TrayManager | undefined = undefined
  private context: common.UIAbilityContext | undefined = undefined
  /** 托盘是否已初始化(图标+监听，仅一次) */
  private initialized: boolean = false
  /** 托盘是否正在初始化(防止异步图标加载期间重复注册) */
  private initializing: boolean = false
  /** 是否正在显式退出(拦截系统终止回调时放行) */
  private exiting: boolean = false
  /** menuCode -> [分组名, 节点名] 映射，重建菜单时整体替换 */
  private menuCodeMap: Map<string, [string, string]> = new Map()
  private rebuildTimer: number = -1

  static getInstance(): TrayManager {
    if (TrayManager.instance === undefined) {
      TrayManager.instance = new TrayManager()
    }
    return TrayManager.instance
  }

  /** @description 托盘是否已激活(图标已添加且监听已注册) */
  isActive(): boolean {
    return this.initialized && !this.exiting
  }

  /** @description 是否正在显式退出 */
  isExiting(): boolean {
    return this.exiting
  }

  /**
   * @description 初始化系统托盘。整个应用生命周期仅执行一次，
   *              重复调用(如窗口重建/页面重载)不会产生重复图标与监听。
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.initialized || this.initializing || this.exiting) {
      return
    }
    // EntryAbility 缓存的主窗口对象(供桌面窗口模式探测)
    const windowClass = AppStorage.get<window.Window>('WindowClass')
    if (!DesktopEnvironment.isDesktopEnvironment(windowClass)) {
      hilog.info(0x0000, TAG, '非桌面环境，跳过托盘初始化')
      return
    }
    this.initializing = true
    try {
      this.context = context
      // 托盘图标(黑/白两份适配深浅色壁纸)
      const icons = await this.loadStatusBarIcon(context)
      // 图标加载期间可能已经收到系统退出请求，不再创建新的托盘资源
      if (this.exiting) {
        return
      }
      // 左键弹窗信息：abilityName 传空字符串 -> 左键点击走 statusBarIconClick 事件，直接恢复主窗口
      const operation: statusBarManager.QuickOperation = {
        abilityName: '',
        title: 'ClashBox',
        height: 30,
        moduleName: 'entry'
      }
      const item: statusBarManager.StatusBarItem = {
        icons: icons,
        quickOperation: operation
      }
      try {
        statusBarManager.addToStatusBar(context, item)
        hilog.info(0x0000, TAG, 'addToStatusBar success')
        hilog.info(0x0000, 'TrayDiag', 'trayInit result=success')
      } catch (e) {
        hilog.error(0x0000, TAG, `addToStatusBar failed. code: ${e.code}, message: ${e.message}`)
        hilog.error(0x0000, 'TrayDiag', `trayInit result=failed code=${e.code ?? ''} message=${e.message}`)
        return
      }
      this.initialized = true
      // 注册点击事件(仅此一次)
      try {
        statusBarManager.on('statusBarIconClick', this.onStatusBarIconClick)
        statusBarManager.on('rightMenuClick', this.onRightMenuClick)
      } catch (e) {
        hilog.error(0x0000, TAG, `register statusBar event failed. message: ${e.message}`)
      }
      // 订阅代理状态变化 -> 重建右键菜单(与主界面共用同一份代理状态)
      EventHub.on(EventKey.TrayMenuRefresh, () => {
        this.requestRebuildMenu()
      })
      // 绑定保活Ability：使应用进程附着到状态栏图标(托盘可见、可退出)，
      // 同时是 showAbility/hideAbility 的前置条件(ATTACH_TO_STATUS_BAR_ITEM)
      this.startHolderAbility()
      hilog.info(0x0000, 'TrayDiag', 'trayInit 已完成：图标+监听+保活Ability(ATTACH_TO_STATUS_BAR_ITEM)')
      // 初始构建右键菜单(代理数据就绪后由 TrayMenuRefresh 再次刷新)
      this.requestRebuildMenu()
    } finally {
      this.initializing = false
    }
  }

  /** @description 隐藏主窗口到托盘(不终止应用，VPN/长连接保持) */
  hideMainWindow(): void {
    if (!this.context) {
      return
    }
    this.context.hideAbility().catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `hideAbility fail, code: ${err.code}, message: ${err.message}`)
      // 降级：隐藏失败时退回后台，保证不退出应用
      this.context?.moveAbilityToBackground().catch((bgErr: BusinessError) => {
        hilog.error(0x0000, TAG, `moveAbilityToBackground fail, code: ${bgErr.code}, message: ${bgErr.message}`)
      })
    })
  }

  /** @description 恢复既有主窗口(不创建新窗口实例)，并刷新托盘菜单状态 */
  restoreMainWindow(): void {
    if (!this.context) {
      return
    }
    this.context.showAbility().then(() => {
      hilog.info(0x0000, TAG, 'showAbility success')
      // 恢复后顺带刷新一次菜单，保证与主界面状态同步
      this.requestRebuildMenu()
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `showAbility fail, code: ${err.code}, message: ${err.message}`)
    })
  }

  /**
   * @description 协调系统发起的应用退出：只执行同步、轻量且幂等的托盘清理。
   *              调用方随后返回 TERMINATE_IMMEDIATELY/false，由系统继续正常生命周期；
   *              不在预终止回调内主动杀死当前进程。
   */
  exitApp(): void {
    this.beginExit()
  }

  /**
   * @description 应用界面内的直接退出入口。保留既有 killAllProcesses 语义，
   *              但与系统预终止路径分离，避免在生命周期回调返回前杀死当前进程。
   */
  forceExitApp(): void {
    if (!this.beginExit()) {
      return
    }
    if (this.context) {
      this.context.getApplicationContext().killAllProcesses().catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, `killAllProcesses fail, code: ${err.code}, message: ${err.message}`)
      })
    } else {
      // 非桌面环境未缓存托盘上下文时沿用原有UI退出工具
      Xb_ToastUtil.exitApp()
    }
  }

  /** @description 原子地取得退出所有权，防止多个终止回调重复清理/退出。 */
  private beginExit(): boolean {
    if (this.exiting) {
      return false
    }
    this.exiting = true
    hilog.info(0x0000, TAG, '开始协调应用退出')
    this.destroy()
    return true
  }

  /** @description 注销监听并移除托盘图标。仅在应用真正退出时调用。 */
  destroy(): void {
    if (!this.initialized) {
      return
    }
    this.initialized = false
    clearTimeout(this.rebuildTimer)
    try {
      statusBarManager.off('statusBarIconClick', this.onStatusBarIconClick)
      statusBarManager.off('rightMenuClick', this.onRightMenuClick)
    } catch (e) {
      hilog.error(0x0000, TAG, `off statusBar event failed. message: ${e.message}`)
    }
    EventHub.off(EventKey.TrayMenuRefresh)
    if (this.context) {
      try {
        // 无前台窗口时可能返回1010710004，此时进程退出后由系统清理图标
        statusBarManager.removeFromStatusBar(this.context)
        hilog.info(0x0000, TAG, 'removeFromStatusBar success')
      } catch (e) {
        hilog.error(0x0000, TAG, `removeFromStatusBar failed. code: ${e.code}, message: ${e.message}`)
      }
    }
    this.menuCodeMap.clear()
  }

  /** @description 托盘图标左键点击 -> 恢复既有主窗口 */
  private onStatusBarIconClick = (eventData: emitter.EventData) => {
    const data = eventData.data as Record<string, string>
    if (data) {
      // 官方文档定义：仅返回 iconClickType，取值 leftClick(左键)
      const iconClickType = data['iconClickType']
      if (iconClickType === 'leftClick') {
        hilog.info(0x0000, TAG, `statusBarIconClick ${iconClickType} 恢复主窗口`)
        this.restoreMainWindow()
      }
    }
  }

  /** @description 托盘图标右键菜单点击 -> 节点切换/打开主界面(退出走系统自带项) */
  private onRightMenuClick = (eventData: emitter.EventData) => {
    const data = eventData.data as Record<string, string>
    if (!data) {
      return
    }
    const menuCode = data['menuCode']
    hilog.info(0x0000, TAG, `rightMenuClick menuCode: ${menuCode}`)
    switch (menuCode) {
      case MENU_CODE_OPEN:
      case MENU_CODE_MORE:
        // 打开主界面(更多节点场景下进入代理页自行选择)
        this.restoreMainWindow()
        break
      default: {
        const target = this.menuCodeMap.get(menuCode)
        if (target) {
          this.switchProxy(target[0], target[1])
        }
        break
      }
    }
  }

  /**
   * @description 快捷节点切换 - 与代理页切换完全相同的实现路径
   *              (ClashViewModel.changeProxy + 卡片持久化 + 主界面选中态同步)，
   *              不创建独立的代理状态系统。
   */
  private async switchProxy(group: string, node: string): Promise<void> {
    try {
      const appConfig = AppStorage.get<AppConfig>('appConfig')
      if (!appConfig?.currentProfileId) {
        hilog.error(0x0000, TAG, `switchProxy 无当前配置，无法切换节点`)
        return
      }
      const profile = await ClashViewModel.getProfile(appConfig.currentProfileId)
      if (!profile) {
        hilog.error(0x0000, TAG, `switchProxy 配置不存在，无法切换节点`)
        return
      }
      // 与 ProxyPage.changeProxy 一致的核心切换路径(内部触发 TrayMenuRefresh 刷新菜单)
      await ClashViewModel.changeProxy(profile, group, node)
      // 卡片持久化(与 ProxyPage.changeProxy 一致)
      cardManager.setSelectedProxyNode(profile, group, node)
      // 主界面选中态同步(与 ProxyGroupItem.selectProxy 一致)
      appConfig.currentProxyName = node
      const groups = await ClashViewModel.getProxyGroups(
        AppStorage.get<ClashConfig>('clashConfig')?.mode ?? ProxyMode.Rule, true)
      appConfig.currentProxyItem = AppState.fetchProxyItem(groups, group, node) as ProxyItem
      cardManager.pushCartCurrentProxyName(node)
    } catch (e) {
      hilog.error(0x0000, TAG, `switchProxy 切换节点失败: ${e.message}`)
    }
  }

  /** @description 启动托盘保活Ability(ATTACH_TO_STATUS_BAR_ITEM + 隐藏启动) */
  private startHolderAbility(): void {
    if (!this.context) {
      return
    }
    const want: Want = {
      bundleName: this.context.abilityInfo.bundleName,
      abilityName: 'ClashTrayHolderAbility'
    }
    const options: StartOptions = {
      // 附着到状态栏图标(不强制新建进程)：托盘可见、可退出，进程可保活
      processMode: contextConstant.ProcessMode.ATTACH_TO_STATUS_BAR_ITEM,
      // 目标Ability启动后隐藏，不显示窗口
      startupVisibility: contextConstant.StartupVisibility.STARTUP_HIDE
    }
    this.context.startAbility(want, options).then(() => {
      hilog.info(0x0000, TAG, 'startHolderAbility success')
      hilog.info(0x0000, 'TrayDiag', 'holderAbility start=success (ATTACH_TO_STATUS_BAR_ITEM + STARTUP_HIDE)')
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `startHolderAbility fail, code: ${err.code}, message: ${err.message}`)
      hilog.error(0x0000, 'TrayDiag', `holderAbility start=failed code=${err.code ?? ''} message=${err.message}`)
    })
  }

  /** @description 防抖重建右键菜单 */
  private requestRebuildMenu(): void {
    clearTimeout(this.rebuildTimer)
    this.rebuildTimer = setTimeout(() => {
      this.refreshProxyMenu()
    }, MENU_REBUILD_DEBOUNCE)
  }

  /** @description 依据当前代理分组数据重建右键菜单并推送到托盘 */
  private async refreshProxyMenu(): Promise<void> {
    if (!this.initialized || this.exiting || !this.context) {
      return
    }
    try {
      const groupMenus = await this.buildGroupMenus()
      statusBarManager.updateStatusBarMenu(this.context, groupMenus)
      hilog.info(0x0000, TAG, `updateStatusBarMenu success, groups: ${groupMenus.length}`)
    } catch (e) {
      // 代理数据暂不可用(Mihomo未就绪/配置加载中)时保留上一次菜单，不崩溃
      hilog.error(0x0000, TAG, `refreshProxyMenu failed. code: ${e.code}, message: ${e.message}`)
    }
  }

  /**
   * @description 构建右键分组菜单：
   *              分组1 - 可切换的代理分组(Selector类型)，当前选中节点带 ✓ 前缀；
   *              分组2 - 打开ClashBox / 退出。
   *              超长节点列表按平台限制截断，并提供"更多节点"入口。
   */
  private async buildGroupMenus(): Promise<statusBarManager.StatusBarGroupMenu[]> {
    const appConfig = AppStorage.get<AppConfig>('appConfig')
    const clashConfig = AppStorage.get<ClashConfig>('clashConfig')
    let profile: Profile | null = null
    if (appConfig?.currentProfileId) {
      profile = await ClashViewModel.getProfile(appConfig.currentProfileId)
    }
    // 静默获取(不弹Toast)，代理数据暂不可用时返回空列表
    const groups = await ClashViewModel.getProxyGroups(clashConfig?.mode ?? ProxyMode.Rule, true)
    const selectable = groups.filter((g: ProxyGroup) => g.type === ProxyType.Selector && g.hidden !== true)

    const codeMap = new Map<string, [string, string]>()
    const proxyMenu: statusBarManager.StatusBarMenuItem[] = []
    const maxGroups = Math.min(selectable.length, MAX_GROUP_MENU)
    for (let i = 0; i < maxGroups; i++) {
      const group = selectable[i]
      const nodes = group.proxies ?? []
      // 空分组会产生"既无子菜单又无行为"的菜单项(1010720001)，跳过
      if (nodes.length === 0) {
        continue
      }
      const selected = profile ? profile.getSelectedProxy(group) : group.now
      const subMenus: statusBarManager.StatusBarSubMenuItem[] = []
      // 每个一级菜单最多 MAX_SUB_MENU 个子菜单项(平台限制)
      const maxNodes = Math.min(nodes.length, MAX_SUB_MENU - 1)
      for (let j = 0; j < maxNodes; j++) {
        const node = nodes[j]
        const menuCode = `clashbox.tray.m${i}-${j}`
        codeMap.set(menuCode, [group.name, node.name])
        const isSelected = node.name === selected
        subMenus.push({
          subTitle: (isSelected ? '✓ ' : '') + node.name,
          menuAction: this.notifyMenuAction(menuCode)
        })
      }
      if (nodes.length > MAX_SUB_MENU - 1) {
        // 节点过多被截断：提供"更多节点"入口打开主界面
        subMenus.push({
          subTitle: this.getString($r('app.string.tray_more_nodes'), '更多节点…'),
          menuAction: this.notifyMenuAction(MENU_CODE_MORE)
        })
      }
      proxyMenu.push({ title: group.name, subMenu: subMenus })
    }

    // 注意：系统会在托盘右键菜单自动提供"退出"项(经 AbilityStage.onPrepareTermination
    // 真实终止应用)，应用不再自建退出项，避免重复退出入口。
    const actionMenu: statusBarManager.StatusBarMenuItem[] = [
      {
        title: this.getString($r('app.string.tray_open_app'), '打开ClashBox'),
        menuAction: this.notifyMenuAction(MENU_CODE_OPEN)
      }
    ]
    this.menuCodeMap = codeMap

    const groupMenus: statusBarManager.StatusBarGroupMenu[] = []
    if (proxyMenu.length > 0) {
      groupMenus.push(proxyMenu)
    }
    groupMenus.push(actionMenu)
    return groupMenus
  }

  /** @description 构建 notifyOnly 菜单行为(点击仅通知应用，由 rightMenuClick 统一处理) */
  private notifyMenuAction(menuCode: string): statusBarManager.StatusBarMenuAction {
    return {
      abilityName: 'EntryAbility',
      moduleName: 'entry',
      notifyOnly: true,
      menuCode: menuCode
    }
  }

  /** @description 加载托盘图标(黑/白两份)。优先使用专用状态栏图标，失败时回退到应用Logo */
  private async loadStatusBarIcon(context: common.UIAbilityContext): Promise<statusBarManager.StatusBarIcon> {
    try {
      const white = await this.createPixelMap(context, 'clash_status_white.svg')
      const black = await this.createPixelMap(context, 'clash_status_black.svg')
      return { white: white, black: black }
    } catch (e) {
      hilog.error(0x0000, TAG, `加载状态栏专用图标失败，回退Logo: ${e.message}`)
      const logo = await this.createPixelMap(context, 'box_cat_round.png')
      return { white: logo, black: logo }
    }
  }

  /** @description 从rawfile解码PixelMap */
  private async createPixelMap(context: common.UIAbilityContext, name: string): Promise<image.PixelMap> {
    const fileData = context.resourceManager.getRawFileContentSync(name)
    const imageSource = image.createImageSource(fileData.buffer)
    return await imageSource.createPixelMap()
  }

  /** @description 同步获取字符串资源(带兜底) */
  private getString(res: Resource, fallback: string): string {
    try {
      const value = this.context?.resourceManager.getStringSync(res)
      return value ?? fallback
    } catch (e) {
      return fallback
    }
  }
}
