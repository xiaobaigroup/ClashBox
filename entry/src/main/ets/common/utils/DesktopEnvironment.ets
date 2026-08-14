/**
 * @description 桌面环境检测 - 用于判断当前窗口是否处于桌面级窗口模式。
 *              状态栏 syscap 仅作为诊断信息；MatePad Edge 桌面窗口实测可使用状态栏 API，
 *              但 canIUse(SystemCapability.PCService.StatusBarManager) 返回 false。
 *              实际能力以 statusBarManager.addToStatusBar 的返回为准。
 */
import { window } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

/** 本地诊断日志标签(仅本地日志，不采集不上传)：hilog | grep TrayDiag */
const TAG = 'TrayDiag'

export class DesktopEnvironment {
  /** 系统状态栏服务 syscap 名称(仅用于诊断，不作为硬门槛) */
  private static readonly STATUS_BAR_SYSCAP: string = 'SystemCapability.PCService.StatusBarManager'
  /** syscap 上报结果缓存(设备能力在运行期内不变) */
  private static trayCapability: boolean | undefined = undefined

  /**
   * @description 读取系统是否上报状态栏 syscap，仅用于诊断。
   *              该值在 MatePad Edge 桌面窗口模式存在假阴性，不能据此跳过真实 API 调用。
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
   * @description 是否为桌面环境：以桌面式窗口模式为准。
   *              状态栏能力由调用方实际执行 addToStatusBar 并处理 BusinessError 验证。
   *              HarmonyOS PC、MatePad Edge PC 模式 -> true；
   *              普通平板/手机/MatePad Edge 平板模式 -> false(保留既有行为)。
   */
  static isDesktopEnvironment(windowClass?: window.Window): boolean {
    const trayCapable = DesktopEnvironment.isTraySupported()
    const desktopWindow = DesktopEnvironment.isDesktopWindowMode(windowClass)
    const result = desktopWindow
    // syscap 结果保留在诊断日志中，但不再阻断 MatePad Edge 的真实状态栏 API 探测。
    hilog.info(0x0000, TAG,
      `isDesktopEnvironment deviceType=${deviceInfo.deviceType} sdkApi=${deviceInfo.sdkApiVersion} syscapReported=${trayCapable} desktopWindow=${desktopWindow} -> ${result}`)
    return result
  }
}
