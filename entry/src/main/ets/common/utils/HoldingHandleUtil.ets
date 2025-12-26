import { motion } from "@kit.MultimodalAwarenessKit"; // 保留引入，编译时需使用高版本SDK
import { hilog } from "@kit.PerformanceAnalysisKit";
import { UIConfig } from "../../entryability/AppState";
import { EventHub, EventKey } from '../EventHub'
import { curves } from "@kit.ArkUI";

const TAG = 'HoldingHandleUtil';

@ObservedV2
class HoldingHandleUtil {
  private ctx?: UIContext;
  // 缓存上一次按钮位置
  private lastButtonPosition: number = 0
  // 缓存系统能力是否可用，避免每次都查询
  private isCapabilityAvailable: boolean = false;

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
    const uiConfig: UIConfig = AppStorage.get("uiConfig")!;
    let targetIndex = 0; // 默认为右手/未握持
    switch (holdingHandler) {
      case motion.HoldingHandStatus.LEFT_HAND_HELD:
        targetIndex = 2;
        break;
      case motion.HoldingHandStatus.BOTH_HANDS_HELD:
        targetIndex = this.lastButtonPosition; // 双手逻辑
        break;
      case motion.HoldingHandStatus.RIGHT_HAND_HELD:
      default:
        targetIndex = 0;
        break;
    }
    // 执行动画和状态更新
    // 必须判断 ctx 是否存在，否则不执行动画逻辑
    if (this.ctx) {
      this.ctx.animateTo(uiConfig.isAnimation ?
        { duration: uiConfig.animationSpeed, curve: curves.springMotion() } : null,
        () => {
          uiConfig.buttonPositionIndex = targetIndex;
        });
    } else {
      // 如果 ctx 不存在（未初始化），直接赋值（无动画）
      hilog.warn(0x4514, TAG, `UIContext 未初始化，跳过动画，直接更新索引: ${targetIndex}`);
      uiConfig.buttonPositionIndex = targetIndex;
    }
    EventHub.sendEvent(EventKey.SwitchButtonPosition, targetIndex);
    this.lastButtonPosition = targetIndex
    hilog.debug(0x4514, TAG, `#changeHandling holdingHandler: ${holdingHandler} buttonPositionIndex 变更为: ${targetIndex}`);
  }

}

export const holdingHandleUtil = new HoldingHandleUtil();
