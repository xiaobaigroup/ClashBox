import { AbilityConstant, AbilityStage } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { TrayManager } from '../common/utils/TrayManager';

const TAG = 'ClashAbilityStage'

/**
 * @description 应用级 AbilityStage：
 *              实现 onPrepareTermination 以区分"系统托盘/任务栏发起的应用退出"
 *              与"UIAbility 窗口关闭(关闭到托盘)"。
 *              依据 SDK 语义：实现本回调后，用户在托盘或任务栏(Dock)右键关闭应用时，
 *              不再回调 UIAbility.onPrepareToTerminate，而是走本回调 ——
 *              因此系统托盘自带的"退出"项在此真实终止应用，不会被窗口关闭拦截吞掉。
 *              窗口 X 关闭仍由 EntryAbility.onPrepareToTerminate 隐藏到托盘。
 */
export default class ClashAbilityStage extends AbilityStage {

  onCreate(): void {
    hilog.info(0x0000, TAG, 'onCreate')
  }

  /**
   * @description 用户从系统托盘/任务栏关闭应用(应用级退出)。
   *              仅标记退出并同步清理托盘资源，然后放行系统正常终止；
   *              不在预终止回调内主动杀死当前进程。
   */
  onPrepareTermination(): AbilityConstant.PrepareTermination {
    hilog.info(0x0000, TAG, 'onPrepareTermination 系统托盘/任务栏发起应用退出')
    TrayManager.getInstance().exitApp()
    return AbilityConstant.PrepareTermination.TERMINATE_IMMEDIATELY
  }
}
