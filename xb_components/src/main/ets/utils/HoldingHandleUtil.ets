import { motion } from "@kit.MultimodalAwarenessKit";
import { hilog } from "@kit.PerformanceAnalysisKit";

const TAG = 'HoldingHandleUtil';

// 定义握持状态的回调类型
export type HoldingHandCallback = (status: motion.HoldingHandStatus) => void;

class HoldingHandleUtil {
  // 缓存系统能力是否可用
  private isCapabilityAvailable: boolean = false;
  // 内部保存回调引用
  private callback: HoldingHandCallback | null = null;

  /**
   * 启动握持检测
   * @param callback 状态变化时的回调函数
   */
  start(callback: HoldingHandCallback): void {
    // 检查系统能力
    if (!canIUse("SystemCapability.MultimodalAwareness.Motion")) {
      this.isCapabilityAvailable = false;
      hilog.warn(0x4514, TAG, `当前设备不支持握持检测 API`);
      return;
    }
    // 防止重复注册
    if (this.isCapabilityAvailable) {
      hilog.info(0x4514, TAG, `握持检测已在运行中`);
      return;
    }

    this.isCapabilityAvailable = true;
    this.callback = callback;
    try {
      motion.on('holdingHandChanged', (status: motion.HoldingHandStatus) => {
        // 打印日志
        this.logStatus(status);
        // 触发回调
        if (this.callback) {
          this.callback(status);
        }
      });
      hilog.info(0x4514, TAG, `握持检测已启动`);
    } catch (e) {
      hilog.error(0x4514, TAG, `开启握持事件失败: ${JSON.stringify(e)}`);
      this.isCapabilityAvailable = false;
    }
  }

  /**
   * 停止握持检测
   */
  stop(): void {
    if (!this.isCapabilityAvailable) {
      return;
    }

    try {
      if (canIUse("SystemCapability.MultimodalAwareness.Motion")) {
        motion.off('holdingHandChanged');
        hilog.info(0x4514, TAG, `握持检测已停止`);
      }
    } catch (error) {
      hilog.error(0x4514, TAG, `关闭握持事件失败: ${JSON.stringify(error)}`);
    } finally {
      this.isCapabilityAvailable = false;
      this.callback = null;
    }
  }

  private logStatus(status: motion.HoldingHandStatus) {
    let str = "";
    switch (status) {
      case motion.HoldingHandStatus.NOT_HELD: str = '未握持'; break;
      case motion.HoldingHandStatus.LEFT_HAND_HELD: str = '左手握持'; break;
      case motion.HoldingHandStatus.RIGHT_HAND_HELD: str = '右手握持'; break;
      case motion.HoldingHandStatus.BOTH_HANDS_HELD: str = '双手握持'; break;
    }
    hilog.debug(0x4514, TAG, `状态变化: ${status} - ${str}`);
  }

}

// 导出单例
export const Xb_HoldingHandleUtil = new HoldingHandleUtil();
