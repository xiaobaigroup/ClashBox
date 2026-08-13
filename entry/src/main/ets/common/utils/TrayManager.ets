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
import { ClashConfig, ProxyGroup, ProxyMode, ProxyType } from 'proxy_core';
import ClashViewModel from '../../entryability/ClashViewModel';
import { AppConfig, AppState } from '../../entryability/AppState';
import { EventHub, EventKey } from '../EventHub';
import { ProxyItem } from '../datasources/ProxyData';
import { Xb_ToastUtil } from 'xb_components';
import { DesktopEnvironment } from './DesktopEnvironment';

const TAG = 'TrayManager'
/** 右键菜单项唯一标识 */
const MENU_CODE_OPEN = 'clashbox.tray.open'
const MENU_CODE_MORE = 'clashbox.tray.more'
/**
 * 状态栏菜单动作必须指定一个 UIAbility。notifyOnly 只开启 rightMenuClick
 * 通知，并不阻止系统拉起该 Ability，因此不能指向主界面 EntryAbility。
 */
const MENU_ACTION_ABILITY = 'ClashTrayHolderAbility'
/** 平台限制：单个一级菜单最多20个子菜单项 */
const MAX_SUB_MENU = 20
/** 平台限制：所有分组一级菜单项总和不超过20个(为操作组预留2项) */
const MAX_GROUP_MENU = 18
/** 菜单重建防抖(ms) - 避免配置加载期间的密集刷新触发1010710003 */
const MENU_REBUILD_DEBOUNCE = 300

interface TrayMenuSnapshot {
  groupMenus: statusBarManager.StatusBarGroupMenu[]
  codeMap: Map<string, [string, string]>
}

export class TrayManager {
  private static instance: TrayManager | undefined = undefined
  private context: common.UIAbilityContext | undefined = undefined
  /** 托盘图标是否已添加 */
  private initialized: boolean = false
  /** 保活Ability是否已完成状态栏附着 */
  private holderAttached: boolean = false
  /** 正在进行的状态栏初始化；并发入口共享同一个任务，避免重复注册或提前隐藏 */
  private initialization: Promise<void> | undefined = undefined
  /** 主窗口正在隐藏/恢复，防止连续点击并发执行可见性操作 */
  private visibilityChanging: boolean = false
  /** 是否正在显式退出(拦截系统终止回调时放行) */
  private exiting: boolean = false
  /** menuCode -> [分组名, 节点名] 映射，重建菜单时整体替换 */
  private menuCodeMap: Map<string, [string, string]> = new Map()
  /** 每份已发布菜单使用独立代码，避免更新过渡期将旧菜单映射到新节点 */
  private menuGeneration: number = 0
  /** 菜单更新串行化，防止慢查询覆盖后到的最新状态 */
  private menuRefreshInProgress: boolean = false
  private menuRefreshRequested: boolean = false
  private rebuildTimer: number = -1

  static getInstance(): TrayManager {
    if (TrayManager.instance === undefined) {
      TrayManager.instance = new TrayManager()
    }
    return TrayManager.instance
  }

  /** @description 托盘是否已激活(图标已添加且监听已注册) */
  isActive(): boolean {
    return this.initialized && this.holderAttached && !this.exiting
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
    // 即使窗口模式尚未就绪也先缓存上下文，X 键可在模式就绪后补做初始化。
    this.context = context
    if (this.exiting) {
      return
    }
    // 图标已经添加但保活Ability尚未附着时，仍须等待同一个初始化任务。
    // 因此 pending 检查必须早于 initialized，避免刚启动时点击 X 偶发无响应。
    const pending: Promise<void> | undefined = this.initialization
    if (pending) {
      await pending
      return
    }
    if (this.initialized) {
      return
    }
    // EntryAbility 缓存的主窗口对象(供桌面窗口模式探测)
    const mainWindow = AppStorage.get<window.Window>('WindowClass')
    if (!DesktopEnvironment.isDesktopEnvironment(mainWindow)) {
      hilog.info(0x0000, TAG, '非桌面环境，跳过托盘初始化')
      return
    }
    const task: Promise<void> = this.initialize(context)
    this.initialization = task
    try {
      await task
    } finally {
      this.initialization = undefined
    }
  }

  /** @description 按“创建条目 -> 附着进程 -> 注册监听”的顺序完成状态栏接入。 */
  private async initialize(context: common.UIAbilityContext): Promise<void> {
    // 状态栏图标(黑/白两份适配深浅色壁纸)
    const icons = await this.loadStatusBarIcon(context)
    // 图标加载期间可能已经收到系统退出请求，不再创建新的状态栏资源
    if (this.exiting) {
      return
    }
    // abilityName 传空字符串：左键点击走 statusBarIconClick，直接恢复主窗口
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
      hilog.info(0x0000, 'TrayDiag', 'addToStatusBar request')
      // 使用回调重载等待系统确认，避免“API已返回但条目尚不能附着”的竞态。
      await this.addStatusBarItem(context, item)
      hilog.info(0x0000, TAG, 'addToStatusBar success')
      hilog.info(0x0000, 'TrayDiag', 'trayInit result=success')
    } catch (err) {
      const error = err as BusinessError
      hilog.error(0x0000, TAG,
        `addToStatusBar failed. code: ${error.code}, message: ${error.message}`)
      hilog.error(0x0000, 'TrayDiag',
        `trayInit result=failed code=${error.code ?? ''} message=${error.message}`)
      return
    }
    this.initialized = true
    if (this.exiting) {
      this.destroy()
      return
    }

    // 必须等保活Ability的附着启动请求成功后才对外宣告状态栏可用。
    const holderStarted = await this.startHolderAbility()
    if (this.exiting) {
      return
    }
    if (!holderStarted) {
      this.destroy()
      return
    }

    // 注册点击事件(仅此一次)
    try {
      statusBarManager.on('statusBarIconClick', this.onStatusBarIconClick)
      statusBarManager.on('rightMenuClick', this.onRightMenuClick)
    } catch (err) {
      const error = err as BusinessError
      hilog.error(0x0000, TAG,
        `register statusBar event failed. code: ${error.code}, message: ${error.message}`)
      // 事件未完整注册时不暴露半激活状态，并回收已添加的图标。
      this.destroy()
      return
    }

    // 订阅代理状态变化 -> 重建右键菜单(与主界面共用同一份代理状态)
    EventHub.on(EventKey.TrayMenuRefresh, () => {
      this.requestRebuildMenu()
    })
    this.holderAttached = true
    hilog.info(0x0000, 'TrayDiag',
      'trayInit 已完成：图标+监听+保活Ability(ATTACH_TO_STATUS_BAR_ITEM)')
    // 初始构建右键菜单(代理数据就绪后由 TrayMenuRefresh 再次刷新)
    this.requestRebuildMenu()
  }

  /**
   * @description 隐藏主窗口到状态栏(不终止应用，VPN/长连接保持)。
   *              若初始化尚未完成，先等待同一初始化任务；不以最小化伪装成功。
   */
  async hideMainWindow(context?: common.UIAbilityContext): Promise<void> {
    if (this.visibilityChanging || this.exiting) {
      return
    }
    if (context) {
      this.context = context
    }
    this.visibilityChanging = true
    try {
      const abilityContext: common.UIAbilityContext | undefined = this.context
      if (!abilityContext) {
        hilog.error(0x0000, TAG, 'hideAbility skipped: UIAbilityContext unavailable')
        return
      }
      if (!this.isActive()) {
        await this.init(abilityContext)
      }
      if (!this.isActive()) {
        hilog.error(0x0000, TAG, 'hideAbility skipped: status bar attachment is not ready')
        return
      }
      await abilityContext.hideAbility()
      hilog.info(0x0000, TAG, 'hideAbility success')
    } catch (err) {
      const error = err as BusinessError
      hilog.error(0x0000, TAG, `hideAbility fail, code: ${error.code}, message: ${error.message}`)
    } finally {
      this.visibilityChanging = false
    }
  }

  /** @description 恢复既有主窗口(不创建新窗口实例)，并刷新托盘菜单状态 */
  async restoreMainWindow(): Promise<void> {
    if (this.visibilityChanging || this.exiting) {
      return
    }
    this.visibilityChanging = true
    try {
      const context: common.UIAbilityContext | undefined = this.context
      if (!context || !this.isActive()) {
        hilog.error(0x0000, TAG, 'showAbility skipped: status bar attachment is not ready')
        return
      }
      // 后台状态下 interval 可能被系统节流；先同步运行时长再显示窗口，
      // 避免首帧显示隐藏前的旧值、下一拍突然追平。
      ClashViewModel.refreshProxyDuration()
      await context.showAbility()
      hilog.info(0x0000, TAG, 'showAbility success')
      this.requestRebuildMenu()
    } catch (err) {
      const error = err as BusinessError
      hilog.error(0x0000, TAG, `showAbility fail, code: ${error.code}, message: ${error.message}`)
    } finally {
      this.visibilityChanging = false
    }
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
    this.holderAttached = false
    if (!this.initialized) {
      return
    }
    this.initialized = false
    clearTimeout(this.rebuildTimer)
    this.menuRefreshRequested = false
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
        this.restoreMainWindow().catch((err: BusinessError) => {
          hilog.error(0x0000, TAG, `restoreMainWindow fail, code: ${err.code}, message: ${err.message}`)
        })
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
        this.restoreMainWindow().catch((err: BusinessError) => {
          hilog.error(0x0000, TAG, `restoreMainWindow fail, code: ${err.code}, message: ${err.message}`)
        })
        break
      default: {
        const target = this.menuCodeMap.get(menuCode)
        if (target) {
          this.switchProxy(target[0], target[1]).catch((err: BusinessError) => {
            hilog.error(0x0000, TAG,
              `switchProxy fail, code: ${err.code}, message: ${err.message}`)
          })
        }
        break
      }
    }
  }

  /**
   * @description 快捷节点切换 - 与代理页使用同一 ClashViewModel 状态发布路径，
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
      // 只有内核确认切换成功后才更新卡片和主界面，避免本地假选中。
      const changed = await ClashViewModel.changeProxy(profile, group, node)
      if (!changed) {
        this.requestRebuildMenu()
        return
      }

      // 回读 Mihomo 运行时状态作为唯一真值，不用 Profile 缓存推测切换结果。
      const groups = await ClashViewModel.getProxyGroups(
        AppStorage.get<ClashConfig>('clashConfig')?.mode ?? ProxyMode.Rule, true)
      const actualGroup = groups.find((item: ProxyGroup) => item.name === group)
      const actualNode = actualGroup?.now
      if (!actualNode || actualNode !== node) {
        hilog.error(0x0000, TAG,
          `switchProxy 运行时校验失败, group: ${group}, requested: ${node}, actual: ${actualNode ?? ''}`)
        // 如果内核回读与请求不一致，用真实值修复持久化选择。
        if (actualNode) {
          await ClashViewModel.syncProxySelection(profile, group, actualNode)
          appConfig.currentProxyItem = AppState.fetchProxyItem(
            groups, group, actualNode) as ProxyItem
        }
        this.requestRebuildMenu()
        return
      }
      // currentProxyName/Profile/卡片已由 changeProxy 的成功事件统一更新。
      appConfig.currentProxyItem = AppState.fetchProxyItem(groups, group, node) as ProxyItem
      this.requestRebuildMenu()
    } catch (e) {
      hilog.error(0x0000, TAG, `switchProxy 切换节点失败: ${e.message}`)
      this.requestRebuildMenu()
    }
  }

  /** @description 启动状态栏保活Ability(当前进程附着 + 隐藏启动) */
  private async startHolderAbility(): Promise<boolean> {
    const context: common.UIAbilityContext | undefined = this.context
    if (!context) {
      return false
    }
    const want: Want = {
      bundleName: context.abilityInfo.bundleName,
      abilityName: 'ClashTrayHolderAbility'
    }
    const options: StartOptions = {
      // 当前进程附着到状态栏图标；TrayManager退出守卫可覆盖两个Ability回调。
      processMode: contextConstant.ProcessMode.ATTACH_TO_STATUS_BAR_ITEM,
      // 目标Ability启动后隐藏，不显示窗口
      startupVisibility: contextConstant.StartupVisibility.STARTUP_HIDE
    }
    let started: boolean = false
    await context.startAbility(want, options).then(() => {
      started = true
      hilog.info(0x0000, TAG, 'startHolderAbility success')
      hilog.info(0x0000, 'TrayDiag',
        'holderAbility start=success (ATTACH_TO_STATUS_BAR_ITEM + STARTUP_HIDE)')
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, `startHolderAbility fail, code: ${err.code}, message: ${err.message}`)
      hilog.error(0x0000, 'TrayDiag',
        `holderAbility start=failed code=${err.code ?? ''} message=${err.message}`)
    })
    return started
  }

  /** @description 完成一次状态栏注册；回调返回后系统条目才可用于进程附着。 */
  private addStatusBarItem(context: common.UIAbilityContext,
    item: statusBarManager.StatusBarItem): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      statusBarManager.addToStatusBar(context, item, (error: BusinessError) => {
        // HarmonyOS 的 AsyncCallback 在成功时不传 BusinessError。
        // 不能直接读取 error.code，否则成功回调会抛异常并让此 Promise 永久 pending。
        if (error) {
          reject(error)
          return
        }
        hilog.info(0x0000, 'TrayDiag', 'addToStatusBar callback=success')
        resolve()
      })
    })
  }

  /** @description 防抖重建右键菜单 */
  private requestRebuildMenu(): void {
    this.menuRefreshRequested = true
    if (this.menuRefreshInProgress) {
      return
    }
    clearTimeout(this.rebuildTimer)
    this.rebuildTimer = setTimeout(() => {
      this.rebuildTimer = -1
      this.refreshProxyMenu()
    }, MENU_REBUILD_DEBOUNCE)
  }

  /** @description 依据当前代理分组数据重建右键菜单并推送到托盘 */
  private async refreshProxyMenu(): Promise<void> {
    if (this.menuRefreshInProgress || !this.initialized || this.exiting || !this.context) {
      return
    }
    this.menuRefreshInProgress = true
    this.menuRefreshRequested = false
    try {
      const snapshot = await this.buildGroupMenus()
      // 更新期同时保留新旧代码：旧菜单或新菜单的点击都不会被错配。
      const previousCodeMap = this.menuCodeMap
      const transitionCodeMap = new Map<string, [string, string]>(previousCodeMap)
      snapshot.codeMap.forEach((value: [string, string], key: string) => {
        transitionCodeMap.set(key, value)
      })
      this.menuCodeMap = transitionCodeMap
      try {
        await this.updateStatusBarMenu(snapshot.groupMenus)
        this.menuCodeMap = snapshot.codeMap
      } catch (e) {
        this.menuCodeMap = previousCodeMap
        throw e as Error
      }
      hilog.info(0x0000, TAG,
        `updateStatusBarMenu success, groups: ${snapshot.groupMenus.length}`)
    } catch (e) {
      // 代理数据暂不可用(Mihomo未就绪/配置加载中)时保留上一次菜单，不崩溃
      hilog.error(0x0000, TAG, `refreshProxyMenu failed. code: ${e.code}, message: ${e.message}`)
    } finally {
      this.menuRefreshInProgress = false
      // 更新期又有代理状态变化时，防抖后再发布一份最新快照。
      if (this.menuRefreshRequested) {
        this.requestRebuildMenu()
      }
    }
  }

  /**
   * @description 构建右键分组菜单：
   *              分组1 - 可切换的代理分组(Selector类型)，当前选中节点带 ✓ 前缀；
   *              分组2 - 打开ClashBox / 退出。
   *              超长节点列表按平台限制截断，并提供"更多节点"入口。
   */
  private async buildGroupMenus(): Promise<TrayMenuSnapshot> {
    const clashConfig = AppStorage.get<ClashConfig>('clashConfig')
    // 静默获取(不弹Toast)，代理数据暂不可用时返回空列表
    const groups = await ClashViewModel.getProxyGroups(clashConfig?.mode ?? ProxyMode.Rule, true)
    const selectable = groups.filter((g: ProxyGroup) => g.type === ProxyType.Selector && g.hidden !== true)

    const codeMap = new Map<string, [string, string]>()
    const generation = ++this.menuGeneration
    const proxyMenu: statusBarManager.StatusBarMenuItem[] = []
    const maxGroups = Math.min(selectable.length, MAX_GROUP_MENU)
    for (let i = 0; i < maxGroups; i++) {
      const group = selectable[i]
      const nodes = group.proxies ?? []
      // 空分组会产生"既无子菜单又无行为"的菜单项(1010720001)，跳过
      if (nodes.length === 0) {
        continue
      }
      // group.now 来自 Mihomo 运行时查询，才是当前真正生效的节点。
      const selected = group.now
      const subMenus: statusBarManager.StatusBarSubMenuItem[] = []
      // 每个一级菜单最多 MAX_SUB_MENU 个子菜单项(平台限制)
      const maxNodes = Math.min(nodes.length, MAX_SUB_MENU - 1)
      for (let j = 0; j < maxNodes; j++) {
        const node = nodes[j]
        const menuCode = `clashbox.tray.n${generation}-${i}-${j}`
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
    const groupMenus: statusBarManager.StatusBarGroupMenu[] = []
    if (proxyMenu.length > 0) {
      groupMenus.push(proxyMenu)
    }
    groupMenus.push(actionMenu)
    return {
      groupMenus: groupMenus,
      codeMap: codeMap
    }
  }

  /** @description 构建托盘保活 Ability 路由 + rightMenuClick 通知的菜单行为。 */
  private notifyMenuAction(menuCode: string): statusBarManager.StatusBarMenuAction {
    return {
      // 菜单动作会拉起 abilityName；路由到无窗口的托盘保活 Ability，
      // 节点切换仅由 rightMenuClick 处理，不显示主界面。
      abilityName: MENU_ACTION_ABILITY,
      moduleName: 'entry',
      notifyOnly: true,
      menuCode: menuCode
    }
  }

  /** @description 等待系统确认菜单快照已发布，再切换对应的 menuCode 映射。 */
  private updateStatusBarMenu(groupMenus: statusBarManager.StatusBarGroupMenu[]): Promise<void> {
    const context = this.context
    if (!context) {
      return Promise.reject(new Error('UIAbilityContext unavailable'))
    }
    return new Promise<void>((resolve, reject) => {
      statusBarManager.updateStatusBarMenu(context, groupMenus, (error: BusinessError) => {
        if (error) {
          reject(error)
          return
        }
        resolve()
      })
    })
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
