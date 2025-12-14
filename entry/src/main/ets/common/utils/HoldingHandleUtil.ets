import { motion } from "@kit.MultimodalAwarenessKit";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { UIConfig } from "../../entryability/AppState";
import { EventHub, EventKey } from '../EventHub'
import { curves } from "@kit.ArkUI";

/**
 * @projectName:    clashnext
 * @fileName:      HoldingHandleUtil
 * @author:     SummerKaze
 * @description:  适人握持工具类
 * @date:    2025/12/13 16:16
 * @version:    1.0
 */

const TAG = 'HoldingHandleUtil';

@ObservedV2
class HoldingHandleUtil {
  private ctx?: UIContext;
  /** @description 是否开启 */
  private isStart: boolean = false;
  /** @description 当前握持的手 */
  @Trace holdingHandler: motion.HoldingHandStatus = motion.HoldingHandStatus.NOT_HELD;

  setContext(context: UIContext) {
    this.ctx = context;
  }

  start(): void {
    const UIConfig: UIConfig = AppStorage.get("uiConfig")!;

    if (this.isStart || !UIConfig.isHoldingHand) {
      return
    }

    motion.on('holdingHandChanged', (status: motion.HoldingHandStatus) => {
      let str: string = ""
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
      hilog.info(0x114514, TAG, `HoldingHandChanged: ${status} - ${str}`)
      this.holdingHandler = status;
    });
  }

  stop(): void {
    motion.off('holdingHandChanged');
    this.holdingHandler = motion.HoldingHandStatus.NOT_HELD;
    this.isStart = false;
  }

  @Monitor('holdingHandler')
  changeHandling(): void {
    const uiConfig: UIConfig = AppStorage.get("uiConfig")!;

    switch (this.holdingHandler) {
      case motion.HoldingHandStatus.LEFT_HAND_HELD:
        // 左手
        this.ctx?.animateTo(uiConfig.isAnimation ?
          { duration: uiConfig.animationSpeed, curve: curves.springMotion() } : null,
          () => {
            uiConfig.buttonPositionIndex = 2;
          })
        break;
      /* TODO 双手 -> 考虑是否需要添加
      case motion.HoldingHandStatus.BOTH_HANDS_HELD:
        // 双手
        this.ctx?.animateTo(uiConfig.isAnimation ?
          { duration: uiConfig.animationSpeed, curve: curves.springMotion() } : null,
          () => {
            uiConfig.buttonPositionIndex = 1;
          })
        break;*/
      case motion.HoldingHandStatus.RIGHT_HAND_HELD:
      default: // 右手和默认
        this.ctx?.animateTo(uiConfig.isAnimation ?
          { duration: uiConfig.animationSpeed, curve: curves.springMotion() } : null,
          () => {
            uiConfig.buttonPositionIndex = 0;
          })
        break;
    }

    EventHub.sendEvent(EventKey.SwitchButtonPosition)
  }
}

export const holdingHandleUtil = new HoldingHandleUtil();