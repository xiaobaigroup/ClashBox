import { motion } from "@kit.MultimodalAwarenessKit"; // 保留引入，编译时需使用高版本SDK
import { hilog } from "@kit.PerformanceAnalysisKit";
import { UIConfig } from "../../entryability/AppState";
import { EventHub, EventKey } from '../EventHub'

const TAG = 'HoldingHandleUtil';

@ObservedV2
class HoldingHandleUtil {
  private ctx?: UIContext;
  // 缓存上一次按钮位置
  private lastButtonPosition: number = 0
  // 缓存系统能力是否可用，避免每次都查询
  private isCapabilityAvailable: boolean = false;
  // 上一次握持状态（防抖用）
  private oldHandStatus = motion.HoldingHandStatus.NOT_HELD;
  // 最新一次握持状态（防抖用）
  private newHandStatus = motion.HoldingHandStatus.NOT_HELD;
  // 防抖锁：true 表示可以响应新事件，false 表示正在防抖中
  private isDebouncing: boolean = true;

  setContext(context: UIContext) {
    this.ctx = context;
  }

  start(): void {
    const uiConfig: UIConfig = AppStorage.get("uiConfig")!;

    // 用户配置未开启，直接返回
    if (!uiConfig.isHoldingHand) {
      return;
    }
    // 严格检查系统能力
    // 如果不支持此能力，标记为不可用并直接返回，不执行后续 motion 相关代码
    if (!canIUse("SystemCapability.MultimodalAwareness.Motion")) {
      this.isCapabilityAvailable = false;
      hilog.warn(0x4514, TAG, `当前设备不支持握持检测 API (HoldingHand)，保持在默认状态。`);
      return;
    }
    this.isCapabilityAvailable = true;
    try {
      // 只有确定可用时，才调用 motion.on
      motion.on('holdingHandChanged', (status: motion.HoldingHandStatus) => {
        let str: string = "";
        switch (status) {
          case motion.HoldingHandStatus.NOT_HELD:
            str = '未握持';
            break;
          case motion.HoldingHandStatus.LEFT_HAND_HELD:
            str = '左手握持';
            break;
          case motion.HoldingHandStatus.RIGHT_HAND_HELD:
            str = '右手握持';
            break;
          case motion.HoldingHandStatus.BOTH_HANDS_HELD:
            str = '双手握持';
            break;
        }
        // 更新状态
        this.changeHandling(status)
        hilog.debug(0x4514, TAG, `HoldingHandChanged: 系统状态 - ${status} - ${str}`);
      });
    } catch (e) {
      hilog.error(0x4514, TAG, `开启适人握持事件失败: ${JSON.stringify(e)}`);
      this.isCapabilityAvailable = false;
    }
  }

  stop(): void {
    if (!this.isCapabilityAvailable) {
      return;
    }

    try {
      if (canIUse("SystemCapability.MultimodalAwareness.Motion")) {
        motion.off('holdingHandChanged');
        hilog.info(0x4514, TAG, `适人握持事件已取消订阅`);
      }
    } catch (error) {
      hilog.error(0x4514, TAG, `关闭适人握持事件失败: ${JSON.stringify(error)}`);
    } finally {
    }
  }

  changeHandling(holdingHandler: motion.HoldingHandStatus): void {
    // 状态未变，直接返回
    if (this.oldHandStatus === holdingHandler) {
      return;
    }

    // 只关心左手或右手握持
    if (holdingHandler === motion.HoldingHandStatus.LEFT_HAND_HELD ||
      holdingHandler === motion.HoldingHandStatus.RIGHT_HAND_HELD) {
      this.newHandStatus = holdingHandler;
      if (!this.isDebouncing) {
        return; // 防抖中，直接丢弃
      }
      this.isDebouncing = false; // 加锁
      this.oldHandStatus = holdingHandler; // 更新缓存
      this.processHandHeldChange(holdingHandler); // 执行业务
    }
  }

  /**
   * 真正执行业务逻辑的函数：
   * 1. 隐藏按钮（500ms动画）
   * 2. 切换左右位置
   * 3. 重新显示按钮（500ms动画）
   * 4. 1.5s防抖：期间若状态再次变化则递归调用，否则释放防抖锁
   */
  private processHandHeldChange(holdingHandler: motion.HoldingHandStatus): void {
    const uiConfig: UIConfig = AppStorage.get("uiConfig")!;

    // 1.5s后检查：如果期间状态又变了，则继续递归防抖；否则释放锁
    setTimeout(() => {
      if (this.newHandStatus !== this.oldHandStatus) {
        this.oldHandStatus = this.newHandStatus;
        this.processHandHeldChange(this.newHandStatus);
      } else {
        this.isDebouncing = true; // 释放防抖锁
      }
    }, 1500);

    // 立即隐藏按钮
    uiConfig.isFloatButtonVisible = false;

    // 500ms后切换左右并重新显示（与隐藏动画衔接）
    setTimeout(() => {
      const targetIndex = this.getTargetIndex(holdingHandler);
      uiConfig.buttonPositionIndex = targetIndex;
      EventHub.sendEvent(EventKey.SwitchButtonPosition, targetIndex);
      this.lastButtonPosition = targetIndex;
      uiConfig.isFloatButtonVisible = true;
      hilog.debug(0x4514, TAG, `#processHandHeldChange holdingHandler: ${holdingHandler} buttonPositionIndex 变更为: ${targetIndex}`);
    }, 500);
  }

  private getTargetIndex(holdingHandler: motion.HoldingHandStatus): number {
    switch (holdingHandler) {
      case motion.HoldingHandStatus.LEFT_HAND_HELD:
        return 2;
      case motion.HoldingHandStatus.RIGHT_HAND_HELD:
        return 0;
      case motion.HoldingHandStatus.BOTH_HANDS_HELD:
        return this.lastButtonPosition;
      default:
        return 0;
    }
  }
}

export const holdingHandleUtil = new HoldingHandleUtil();
