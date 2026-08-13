import { UIAbility } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { TrayManager } from '../common/utils/TrayManager';

const TAG = 'ClashTrayHolderAbility'

/**
 * @description 托盘保活Ability：以 ATTACH_TO_STATUS_BAR_ITEM + STARTUP_HIDE 模式启动，
 *              将应用进程附着到状态栏图标(托盘对用户可见、可退出，进程可后台保活)，
 *              同时满足 showAbility/hideAbility 的前置条件。
 *              本Ability无窗口、无页面，仅承载生命周期与终止拦截。
 */
export default class ClashTrayHolderAbility extends UIAbility {

  onCreate(): void {
    hilog.info(0x0000, TAG, 'onCreate 托盘保活Ability已启动(隐藏模式)')
  }

  /**
   * @description 系统托盘"退出"终止的是附着到托盘图标的保活Ability。
   *              此处只认领并清理一次退出状态，然后返回false让系统继续正常终止；
   *              TrayManager的幂等守卫避免与AbilityStage回调重复清理。
   *              注：实现 AbilityStage.onPrepareTermination 后，托盘/任务栏关闭
   *              优先走 AbilityStage；本回调作为其未生效时的兜底路径。
   */
  onPrepareToTerminate(): boolean {
    hilog.info(0x0000, TAG, 'onPrepareToTerminate 系统托盘退出 -> 显式退出应用')
    TrayManager.getInstance().exitApp()
    return false
  }

  onDestroy(): void {
    hilog.info(0x0000, TAG, 'onDestroy')
  }
}
