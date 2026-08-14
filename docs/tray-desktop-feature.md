# 桌面托盘(系统状态栏图标)功能设计 — ClashBox LTS

分支：`fix/lts-stable-long-connections`。本功能基于 HarmonyOS NEXT 官方的
PC 托盘(状态栏图标)机制实现，参考官方示例(PCStatusBar，`@kit.DeskTopExtensionKit`)，
并复用 ClashBox 既有代理状态与切换实现，不引入独立的代理管理系统。

## 能力检测(不依赖设备型号)

```text
DesktopEnvironment.isDesktopEnvironment()
  = canIUse('SystemCapability.PCService.StatusBarManager')   // 托盘服务能力(运行时探测)
    AND 主窗口处于桌面式窗口模式(WindowMode 既有检测 或 getWindowStatus() ∈ {FLOATING, MAXIMIZE})
```

- **HarmonyOS PC**：托盘能力 ✓ + 窗口自由悬浮/最大化 ✓ → 启用
- **MatePad Edge PC/桌面模式**：实现预期为系统在该模式下提供 PC 服务(托盘能力 ✓)、
  窗口自由悬浮 ✓ → 启用。**该预期须真机实测验证** —— 官方文档仍将托盘/终止回调
  描述为对 2-in-1 设备生效，MatePad Edge 两种模式下系统实际暴露的能力以
  `TrayDiag` 诊断日志为准(见下)。
- **MatePad Edge 平板模式 / 普通平板 / 手机**：预期托盘能力 ✗ → 不启用，保持既有行为
- 未硬编码任何设备型号；能力探测优先于设备类别判断

## 关闭到托盘 vs 应用退出(职责分离)

| 操作 | 路由 | 结果 |
| --- | --- | --- |
| 窗口 X(自定义按钮) | TopBar → `hideAbility()` | 隐藏到托盘，VPN/核心/连接原样运行 |
| 最近任务/窗口级关闭 | `EntryAbility.onPrepareToTerminate` → 返回 `true` | 隐藏到托盘 |
| 系统托盘"退出"项 / 任务栏(Dock)右键关闭 | `AbilityStage.onPrepareTermination`(实现后优先走此回调) → `exitApp()` + `TERMINATE_IMMEDIATELY` | 标记退出 → 注销监听 → 移除托盘 → 回调返回，由系统正常终止应用；`ClashVpnAbility.onDestroy` 是 TUN 的清理归属点，Mihomo 随应用进程退出 |
| 兜底：托盘退出未走 AbilityStage 时 | `ClashTrayHolderAbility.onPrepareToTerminate` → 幂等 `exitApp()` + 返回 `false` | 同上；与 AbilityStage 共享退出守卫，不会重复清理 |

- 应用**不再自建**托盘右键"退出"项 —— 系统在托盘右键菜单自动提供"退出"，
  避免重复退出入口。
- 隐藏/恢复路径**不触发** `loadConfig`、`clearConnections`、`StopVpn`、
  `ReStartVpn` 等任何连接清理逻辑，长连接修复(lts-stable)不受影响。

## 托盘交互

- **左键**：`statusBarIconClick` 事件(官方定义：返回 `iconClickType`，取值 `leftClick`)
  → `showAbility()` 恢复既有主窗口。
- **右键**：`updateStatusBarMenu` 动态菜单 —
  - 分组1：Selector 类型代理分组(隐藏分组除外)，子菜单为节点列表，
    当前选中节点带 `✓ ` 前缀；节点切换调用与代理页完全相同的
    `ClashViewModel.changeProxy(profile, g, p)` + 卡片持久化。
  - 分组2：打开ClashBox(notifyOnly + menuCode，由 `rightMenuClick` 事件处理)；
    "退出"使用系统自带项。
- 菜单同步：`ClashViewModel.changeProxy` 与 `loadProfileAndConfig` 成功后发送
  `EventKey.TrayMenuRefresh`(10025)，TrayManager 防抖(300ms)重建菜单。

## 保活绑定

`ClashTrayHolderAbility` 以 `ATTACH_TO_STATUS_BAR_ITEM + STARTUP_HIDE` 启动
(不新建进程)：

1. 将应用进程附着到状态栏图标 —— 托盘对用户可见、可退出，进程可后台保活
   (HarmonyOS PC 不允许不可见进程后台运行，托盘是官方保活通道)；
2. 是 `showAbility()/hideAbility()` 的前置条件
   (错误码 16000067：调用方须以 ATTACH_TO_STATUS_BAR_ITEM 模式启动)。

## 平台限制(记录在案)

- 右键菜单总一级菜单项 ≤ 20、单一级菜单子项 ≤ 20 → 代理分组截断为 ≤18 组、
  每组 ≤19 个节点 + "更多节点…"入口打开主界面。
- `hoverTips` 为 API 22(6.0.2) 能力，本项目 targetSdk 20 未使用。
- `removeFromStatusBar` 在无前台窗口时返回 1010710004 → 退出时忽略该错误，
  进程终止后系统自动清理图标。
- `AbilityStage.onPrepareTermination` / `UIAbility.onPrepareToTerminate`
  官方说明仅在 2-in-1 设备生效；不生效的设备上依赖 X 按钮的显式拦截
  (既有自定义窗口按钮)。
- `ApplicationContext.killAllProcesses()` 仅适合异常场景且不会执行完整正常生命周期，
  因此系统托盘/Dock的预终止回调不再调用它；它只保留给应用内既有的"直接退出"模式。
- 正常退出路径保留了 `EntryAbility` / VPN Extension 的 `onDestroy` 生命周期机会；崩溃、
  强制停止等异常退出不保证回调。MatePad Edge 上系统托盘退出的实际回调顺序、TUN 与
  Mihomo 的消失仍须通过下述真机步骤确认。
- 本项目未注册 `windowStage.on('windowStageClose')`：PC 模式下系统标题栏
  (三键栏)被既有代码隐藏(`setWindowDecorVisible(false)` 等)，原生关闭按钮
  不可达，关闭路径为自定义 X 按钮 + 上述终止回调。
- 托盘图标优先使用 `rawfile/clash_status_white.svg / clash_status_black.svg`
  (24vp 黑白状态栏图标)，解码失败时回退 `box_cat_round.png`。

## 真机能力验证(TrayDiag 本地诊断日志)

在 MatePad Edge 平板模式与 PC/桌面模式分别启动一次，抓取本地日志：

```text
hilog | grep TrayDiag
```

关注以下行(仅本地日志，不采集不上传)：

```text
TrayDiag canIUse(SystemCapability.PCService.StatusBarManager) = <true|false>
TrayDiag isDesktopEnvironment deviceType=<...> sdkApi=<...> trayCapable=<...> desktopWindow=<...> -> <true|false>
TrayDiag trayInit result=<success|failed code=...>
TrayDiag holderAbility start=<success|failed code=...>
```

- 平板模式预期：`canIUse=false`、`isDesktopEnvironment -> false`、无 `trayInit` 行；
- PC 模式预期：`canIUse=true`、`isDesktopEnvironment -> true`、`trayInit result=success`。
- 若 PC 模式实测与预期不符(如 canIUse=false)，记录日志后以实测为准调整判定条件。

## 生命周期不变量

- 托盘资源(图标/监听/事件订阅)每个应用生命周期仅初始化一次(`TrayManager.initialized`)；
  仅在真正退出时销毁(`onDestroy` / `exitApp`)。
- hide/show 反复执行不产生重复图标、窗口、监听器。
- 长连接保护：托盘全部路径均为窗口操作或只读查询(`queryProxyGroups`)，
  与 `docs/lts-connection-lifecycle-audit.md` 的破坏性路径清单无交集。

## 手动验收步骤

1. HarmonyOS PC / MatePad Edge(PC模式) 启动 ClashBox LTS，连接代理并建立长连接；
2. 点击窗口 X → 窗口消失、托盘图标仍在、流量与连接不中断；
3. 左键托盘 → 同一窗口恢复(重复多次)；
4. 右键托盘 → 分组菜单出现，切换节点 → 立即生效、菜单 ✓ 更新、主界面同步；
5. 长列表配置 → 分组显示"更多节点…"入口；
6. 右键托盘 → 系统"退出"项 → 应用与托盘图标完全终止(不要点应用自建的项——不存在)；
7. MatePad Edge 切回平板模式 → 无托盘、行为与旧版一致(用 TrayDiag 日志确认)。
