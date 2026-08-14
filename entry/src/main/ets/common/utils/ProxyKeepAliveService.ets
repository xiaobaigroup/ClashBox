import { Context, WantAgent, wantAgent } from "@kit.AbilityKit";
import { backgroundTaskManager } from "@kit.BackgroundTasksKit";
import { BusinessError, deviceInfo } from "@kit.BasicServicesKit";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { UIConfig } from "../../entryability/AppState";

const TAG = 'ProxyKeepAliveService'
// 系统撤销长时任务后的重试参数
const RETRY_DELAY_MS = 3000
const MAX_RETRY = 5

/**
 * 代理运行期间的长时任务自动保活。
 *
 * 背景：HarmonyOS 在机器锁定/息屏后会对后台应用进程做冻结与回收，
 * 未持有长时任务(continuous task)的应用进程会被系统杀掉。ClashBox 的
 * 内核(mihomo)运行在 UI 进程(前台模式)或由 UI 进程托管全部控制面 RPC、
 * 托盘与 1s 恢复看门狗；UI 进程一旦被回收，代理随之中断，
 * 依赖代理的应用(如 Codex)即无法连接。
 *
 * 策略：代理启动时自动申请 TASK_KEEPING 长时任务(PC/2in1/平板可用)，
 * 代理停止时释放。与用户手动开启的 模拟下载/模拟定位/任务保持 保活互斥，
 * 避免同一 UIAbility 重复申请长时任务。
 * 系统若撤销长时任务，通过 continuousTaskCancel 事件自动重新申请(有界重试)。
 */
export class ProxyKeepAliveService {
  // 当前是否持有本服务申请的长时任务
  private taskStarted: boolean = false
  // 代理运行期间是否应持有长时任务(start/stop 维护)
  private wanted: boolean = false
  // continuousTaskCancel 监听是否已注册
  private cancelHandlerRegistered: boolean = false
  // 系统连续撤销时的重试计数
  private retryCount: number = 0

  /**
   * 代理启动后调用(幂等)：申请长时任务。
   */
  async start(context: Context): Promise<void> {
    this.wanted = true
    this.retryCount = 0
    await this.requestTask(context, 'proxy-start')
  }

  /**
   * 代理停止后调用(幂等)：仅释放本服务自己申请的长时任务，
   * 不影响用户手动开启的 模拟下载/模拟定位/任务保持 长时任务。
   */
  async stop(context: Context): Promise<void> {
    this.wanted = false
    this.retryCount = 0
    if (!this.taskStarted) {
      return
    }
    this.taskStarted = false
    try {
      await backgroundTaskManager.stopBackgroundRunning(context)
      hilog.info(0xFF00, TAG, '长时任务已释放')
    } catch (err) {
      let e = err as BusinessError
      hilog.error(0xFF00, TAG,
        `长时任务释放失败 code=${e.code} message=${e.message}`)
    }
  }

  /**
   * 锁屏/解锁等系统状态变化时调用：若系统撤销了长时任务则重新申请。
   */
  async reassert(context: Context): Promise<void> {
    if (!this.wanted) {
      return
    }
    await this.requestTask(context, 'system-state-reassert')
  }

  private async requestTask(context: Context, reason: string): Promise<void> {
    if (this.taskStarted) {
      return
    }
    // TASK_KEEPING(计算任务)在 API 20 及之前仅对 PC/2in1 设备开放(平板沿用
    // 应用内既有「任务保持」开关的设备范围)。手机等设备跳过自动保活，
    // 保留原有 模拟下载/模拟定位 的手动保活行为。
    const type = deviceInfo.deviceType
    if (type !== '2in1' && type !== 'tablet') {
      hilog.info(0xFF00, TAG,
        `设备类型 ${type} 不支持 TASK_KEEPING 自动保活，跳过`)
      return
    }
    // 用户已手动开启任意后台保持开关时，避免同一 UIAbility 重复申请长时任务
    const uiConfig = AppStorage.get<UIConfig>('uiConfig')
    if (uiConfig && uiConfig.Enablebackgrounder) {
      hilog.info(0xFF00, TAG, '用户已启用后台保持(模拟下载/定位/任务保持)，跳过自动保活')
      return
    }
    this.registerCancelListener(context)
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: context.applicationInfo.name,
          abilityName: 'EntryAbility'
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    try {
      const wantAgentObj: WantAgent = await wantAgent.getWantAgent(wantAgentInfo)
      await backgroundTaskManager.startBackgroundRunning(context,
        backgroundTaskManager.BackgroundMode.TASK_KEEPING, wantAgentObj)
      this.taskStarted = true
      this.retryCount = 0
      hilog.info(0xFF00, TAG, `长时任务申请成功 reason=${reason}`)
    } catch (err) {
      let e = err as BusinessError
      hilog.error(0xFF00, TAG,
        `长时任务申请失败 reason=${reason} code=${e.code} message=${e.message}`)
    }
  }

  /**
   * 监听系统撤销长时任务：代理仍开启时自动重新申请(有界重试)。
   */
  private registerCancelListener(context: Context): void {
    if (this.cancelHandlerRegistered) {
      return
    }
    this.cancelHandlerRegistered = true
    try {
      backgroundTaskManager.on('continuousTaskCancel',
        (info: backgroundTaskManager.ContinuousTaskCancelInfo) => {
          hilog.warn(0xFF00, TAG,
            `长时任务被系统撤销 id=${info.id} reason=${info.reason}`)
          if (!this.wanted) {
            return
          }
          this.taskStarted = false
          if (this.retryCount < MAX_RETRY) {
            this.retryCount++
            setTimeout(() => {
              this.requestTask(context, 'cancel-retry')
            }, RETRY_DELAY_MS)
          } else {
            hilog.error(0xFF00, TAG, '长时任务重试次数超限，放弃自动保活')
          }
        })
    } catch (err) {
      let e = err as BusinessError
      hilog.error(0xFF00, TAG,
        `注册长时任务撤销监听失败 code=${e.code} message=${e.message}`)
    }
  }
}

export default new ProxyKeepAliveService()
