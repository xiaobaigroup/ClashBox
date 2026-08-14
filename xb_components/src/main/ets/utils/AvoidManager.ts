import { UIContext, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * 定义最终暴露给外部的避让数据结构
 */
export interface SmartAvoidance {
  top: number;    // 顶部总避让高度
  bottom: number; // 底部总避让高度
  left: number;   // 左侧总避让宽度
  right: number;  // 右侧总避让宽度
}

/**
 * 避让值变化监听器的类型定义
 * @param avoidance - 最新的智能避让数据
 */
export type AvoidanceChangeListener = (avoidance: SmartAvoidance) => void;

/**
 * 一个窗口避让区域管理器
 * 综合处理状态栏、导航栏和刘海屏（挖孔屏）等非安全区的综合避让，
 * 提供一个经过计算的、更符合实际布局需求的最终避让尺寸
 */
export class Xb_AvoidanceManager {
  private windowClass: window.Window;
  private uiContext: UIContext;
  private currentAvoidance: SmartAvoidance = { top: 0, bottom: 0, left: 0, right: 0 };
  private changeListener: (data: window.AvoidAreaOptions) => void;

  // 用于存储所有外部监听器的 Set
  private listeners: Set<AvoidanceChangeListener> = new Set();

  constructor(windowClass: window.Window, uiContext: UIContext) {
    if (!windowClass || !uiContext) {
      throw new Error('SmartAvoidanceManager: windowClass and uiContext are required.');
    }
    this.windowClass = windowClass;
    this.uiContext = uiContext;
    this.changeListener = this.onAvoidAreaChange.bind(this);
  }

  async init(): Promise<void> {
    hilog.debug(0x0000, 'SmartAvoidanceManager', 'Initializing...');
    await this.fetchAndCalculate();
    this.windowClass.on('avoidAreaChange', this.changeListener);
    hilog.debug(0x0000, 'SmartAvoidanceManager', 'Initialization complete. Initial avoidance: %{public}s', JSON.stringify(this.currentAvoidance));
  }

  getAvoidance(): SmartAvoidance {
    return this.currentAvoidance;
  }

  /**
   * 销毁管理器，注销监听，清空所有外部监听器
   */
  destroy(): void {
    hilog.debug(0x0000, 'SmartAvoidanceManager', 'Destroying...');
    if (this.windowClass && this.changeListener) {
      this.windowClass.off('avoidAreaChange', this.changeListener);
    }
    // 清空所有外部监听器，防止内存泄漏
    this.listeners.clear();
  }

  /**
   * 注册一个监听器，当避让值发生变化时会被调用
   * @param listener - 监听函数
   */
  onChangeListener(listener: AvoidanceChangeListener): void {
    this.listeners.add(listener);
    // 注册后立即调用一次，让调用方获取当前值
    listener(this.currentAvoidance);
  }

  /**
   * 移除一个已注册的监听器
   * @param listener - 需要移除的监听函数
   */
  offChangeListener(listener: AvoidanceChangeListener): void {
    this.listeners.delete(listener);
  }

  private async onAvoidAreaChange(data: window.AvoidAreaOptions): Promise<void> {
    hilog.debug(0x0000, 'SmartAvoidanceManager', `Avoidance area changed for type: ${data.type}, recalculating...`);
    await this.fetchAndCalculate();
    hilog.debug(0x0000, 'SmartAvoidanceManager', 'Recalculation complete. New avoidance: %{public}s', JSON.stringify(this.currentAvoidance));
  }

  // 通知所有监听器的私有方法
  private notifyListeners(): void {
    for (const listener of this.listeners) {
      try {
        listener(this.currentAvoidance);
      } catch (error) {
        hilog.error(0x0000, 'SmartAvoidanceManager', 'Error in avoidance listener: %{public}s', (error as Error).message);
      }
    }
  }

  /**
   * 获取所有类型的原始数据并触发智能计算
   */
  private async fetchAndCalculate(): Promise<void> {
    let systemArea: window.AvoidArea | undefined;
    let navigationArea: window.AvoidArea | undefined;
    let cutoutArea: window.AvoidArea | undefined;

    try {
      systemArea = this.windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
    } catch (e) {
      hilog.error(0x0000, 'Xb_AvoidanceManager', 'Failed to get TYPE_SYSTEM area.');
    }
    try {
      navigationArea = this.windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
    } catch (e) {
      hilog.error(0x0000, 'Xb_AvoidanceManager', 'Failed to get TYPE_NAVIGATION_INDICATOR area.');
    }
    try {
      cutoutArea = this.windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_CUTOUT);
    } catch (e) {
      hilog.error(0x0000, 'Xb_AvoidanceManager', 'Failed to get TYPE_CUTOUT area.');
    }

    hilog.debug(0x0000, 'Xb_AvoidanceManager', '========== [RAW DATA DUMP] ==========');
    hilog.debug(0x0000, 'Xb_AvoidanceManager', 'TYPE_SYSTEM Area: %{public}s', JSON.stringify(systemArea));
    hilog.debug(0x0000, 'Xb_AvoidanceManager', 'TYPE_NAVIGATION_INDICATOR Area: %{public}s', JSON.stringify(navigationArea));
    hilog.debug(0x0000, 'Xb_AvoidanceManager', 'TYPE_CUTOUT Area: %{public}s', JSON.stringify(cutoutArea));
    hilog.debug(0x0000, 'Xb_AvoidanceManager', '======================================');

    const newAvoidance = this.calculateSmartAvoidance(systemArea, navigationArea, cutoutArea);

    if (JSON.stringify(newAvoidance) !== JSON.stringify(this.currentAvoidance)) {
      this.currentAvoidance = newAvoidance;
      this.notifyListeners();
    }
  }

  /**
   * 核心计算逻辑：根据原始数据计算最终的智能避让值
   */
  private calculateSmartAvoidance(systemArea?: window.AvoidArea, navigationArea?: window.AvoidArea, cutoutArea?: window.AvoidArea): SmartAvoidance {
    // 初始化所有值为0
    let top = 0;
    let bottom = 0;
    let left = 0;
    let right = 0;

    // 计算系统状态栏的避让
    if (systemArea) {
      top = this.uiContext.px2vp(systemArea.topRect.height);
      left = this.uiContext.px2vp(systemArea.leftRect.width);
      right = this.uiContext.px2vp(systemArea.rightRect.width);
    }

    // 计算导航栏的避让
    if (navigationArea) {
      bottom = this.uiContext.px2vp(navigationArea.bottomRect.height);
    }

    // 计算Cutout（刘海/挖孔）的避让并与现有值合并
    if (cutoutArea) {
      // --- Cutout是否被顶部状态栏覆盖 ---
      let isCutoutCoveredByTopBar = false;
      if (systemArea && systemArea.topRect.height > 0) {
        const systemTopHeight = systemArea.topRect.height;
        const cutoutTopPos = cutoutArea.topRect.top;
        const cutoutLeftPos = cutoutArea.leftRect.top;
        const cutoutRightPos = cutoutArea.rightRect.top;

        if ((cutoutTopPos > 0 && cutoutTopPos < systemTopHeight) ||
          (cutoutLeftPos > 0 && cutoutLeftPos < systemTopHeight) ||
          (cutoutRightPos > 0 && cutoutRightPos < systemTopHeight)) {
          isCutoutCoveredByTopBar = true;
        }
      }

      // --- Cutout是否被底部导航栏覆盖 ---
      let isCutoutCoveredByBottomBar = false;
      if (navigationArea && navigationArea.bottomRect.height > 0) {
        const navigationBarTop = navigationArea.bottomRect.top;
        const cutoutTopPos = cutoutArea.topRect.top;
        const cutoutBottomPos = cutoutArea.bottomRect.top;
        const cutoutLeftPos = cutoutArea.leftRect.top;
        const cutoutRightPos = cutoutArea.rightRect.top;

        // 检查任何位置的Cutout，其底部是否进入了导航栏的垂直范围
        if ((cutoutTopPos > 0 && (cutoutTopPos + cutoutArea.topRect.height) > navigationBarTop) ||
          (cutoutBottomPos > 0 && (cutoutBottomPos + cutoutArea.bottomRect.height) > navigationBarTop) ||
          (cutoutLeftPos > 0 && (cutoutLeftPos + cutoutArea.leftRect.height) > navigationBarTop) ||
          (cutoutRightPos > 0 && (cutoutRightPos + cutoutArea.rightRect.height) > navigationBarTop)) {
          isCutoutCoveredByBottomBar = true;
        }
      }

      hilog.debug(0x0000, 'Xb_AvoidanceManager', '[DEBUG] isCutoutCoveredByTopBar: %{public}s', isCutoutCoveredByTopBar);
      hilog.debug(0x0000, 'Xb_AvoidanceManager', '[DEBUG] isCutoutCoveredByBottomBar: %{public}s', isCutoutCoveredByBottomBar);

      // 应用避让逻辑
      const cutoutTop = this.uiContext.px2vp(cutoutArea.topRect.height);
      const cutoutBottom = this.uiContext.px2vp(cutoutArea.bottomRect.height);
      const cutoutLeft = this.uiContext.px2vp(cutoutArea.leftRect.width);
      const cutoutRight = this.uiContext.px2vp(cutoutArea.rightRect.width);

      // 顶部：取最大值
      if (cutoutTop > 0) {
        top = Math.max(top, cutoutTop);
      }

      // 底部：相加
      if (cutoutBottom > 0) {
        bottom += cutoutBottom;
      }

      // 左侧和右侧：只有当Cutout不被顶部和底部栏覆盖时，才增加侧边避让
      if (cutoutLeft > 0) {
        if (!isCutoutCoveredByTopBar && !isCutoutCoveredByBottomBar) {
          left = Math.max(left, cutoutLeft);
        }
      }

      if (cutoutRight > 0) {
        if (!isCutoutCoveredByTopBar && !isCutoutCoveredByBottomBar) {
          right = Math.max(right, cutoutRight);
        }
      }
    }

    hilog.debug(0x0000, 'Xb_AvoidanceManager', 'Final calculated avoidance: %{public}s', JSON.stringify({ top, bottom, left, right }));
    return { top, bottom, left, right };
  }

}
