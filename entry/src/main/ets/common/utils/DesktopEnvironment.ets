/**
 * @description 桌面环境检测 - 用于判断当前环境是否具备桌面级窗口能力(系统托盘/自由窗口)。
 *              不依赖具体设备型号：实现预期为 MatePad Edge 在 PC/桌面模式下会被系统
 *              标记为具备状态栏(托盘)服务能力，普通平板/手机模式则不具备 ——
 *              该预期须在真机实测验证(见 TrayDiag 本地诊断日志)。
 */
import { window } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

/** 本地诊断日志标签(仅本地日志，不采集不上传)：hilog | grep TrayDiag */
const TAG = 'TrayDiag'

export class DesktopEnvironment {
  /** 系统状态栏(托盘)服务能力 */
  private static readonly STATUS_BAR_SYSCAP: string = 'SystemCapability.PCService.StatusBarManager'
  /** 能力探测结果缓存(设备能力在运行期内不变) */
  private static trayCapability: boolean | undefined = undefined

  /**
   * @description 当前环境是否支持桌面系统托盘(状态栏图标)。
   *              通过运行时系统能力探测实现：HarmonyOS PC 与处于 PC/桌面模式的
   *              平板(如 MatePad Edge PC 模式)具备该能力，普通平板/手机模式不具备。
   */
  static isTraySupported(): boolean {
    if (DesktopEnvironment.trayCapability === undefined) {
      try {
        DesktopEnvironment.trayCapability = canIUse(DesktopEnvironment.STATUS_BAR_SYSCAP)
      } catch (e) {
        console.error(`DesktopEnvironment 能力探测失败，message: ${e.message}`)
        DesktopEnvironment.trayCapability = false
      }
      hilog.info(0x0000, TAG,
        `canIUse(${DesktopEnvironment.STATUS_BAR_SYSCAP}) = ${DesktopEnvironment.trayCapability}`)
    }
    return DesktopEnvironment.trayCapability
  }

  /**
   * @description 主窗口当前是否处于桌面式窗口模式(自由悬浮/最大化)。
   *              优先复用 EntryAbility 既有的 PC 窗口模式检测结果(WindowMode)，
   *              未检测时回退到窗口状态探测。
   */
  static isDesktopWindowMode(windowClass?: window.Window): boolean {
    // 复用 EntryAbility.onWindowModeChange 的既有检测结果
    const windowMode = AppStorage.get<boolean>('WindowMode')
    if (windowMode === true) {
      return true
    }
    // 回退：直接探测当前窗口状态(自由窗口/最大化 -> 桌面式窗口环境)
    if (windowClass) {
      try {
        const status = windowClass.getWindowStatus()
        hilog.info(0x0000, TAG,
          `WindowMode=${windowMode} windowStatus=${status}(FLOATING=${window.WindowStatusType.FLOATING},MAXIMIZE=${window.WindowStatusType.MAXIMIZE})`)
        return status === window.WindowStatusType.FLOATING ||
          status === window.WindowStatusType.MAXIMIZE
      } catch (e) {
        console.error(`DesktopEnvironment 窗口状态探测失败，message: ${e.message}`)
        hilog.error(0x0000, TAG, `getWindowStatus 探测失败: ${e.code ?? ''} ${e.message}`)
      }
    }
    return false
  }

  /**
   * @description 是否为桌面环境：托盘能力 + 桌面式窗口模式。
   *              HarmonyOS PC、MatePad Edge PC 模式 -> true；
   *              普通平板/手机/MatePad Edge 平板模式 -> false(保留既有行为)。
   */
  static isDesktopEnvironment(windowClass?: window.Window): boolean {
    const trayCapable = DesktopEnvironment.isTraySupported()
    const desktopWindow = DesktopEnvironment.isDesktopWindowMode(windowClass)
    const result = trayCapable && desktopWindow
    // 临时诊断日志(仅本地)：用于在 MatePad Edge 平板/PC 两种模式实测系统实际暴露的能力
    hilog.info(0x0000, TAG,
      `isDesktopEnvironment deviceType=${deviceInfo.deviceType} sdkApi=${deviceInfo.sdkApiVersion} trayCapable=${trayCapable} desktopWindow=${desktopWindow} -> ${result}`)
    return result
  }
}
