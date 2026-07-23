import { appInfoManager } from '@kit.AppGalleryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { deviceInfo } from '@kit.BasicServicesKit';

const TAG = 'DynamicIconManager';


/**
 * 设备后缀映射
 * 手机不加，平板加 1，PC/2in1 加 2
 */
const DEVICE_SUFFIX: Record<string, string> = {
  'phone': '',
  'tablet': '1',
  'pc': '2',
  '2in1': '2',
  // wearable/tv 默认走空字符串
};

export class DynamicIconManager {
  private static instance: DynamicIconManager;
  private iconMap: Record<string, string> = {};
  private deviceType: string;

  private constructor() {
    this.deviceType = deviceInfo.deviceType;
  }

  /**
   * 获取单例
   * @param iconMap 传入你的 value -> iconId 映射表
   */
  static getInstance(iconMap?: Record<string, string>): DynamicIconManager {
    if (!DynamicIconManager.instance) {
      DynamicIconManager.instance = new DynamicIconManager();
    }
    // 传了 map 就更新，没传就用上次的（兼容不传参的场景）
    if (iconMap) {
      DynamicIconManager.instance.iconMap = iconMap;
    }
    return DynamicIconManager.instance;
  }

  /** 可在运行时单独更新映射表 */
  updateIconMap(iconMap: Record<string, string>): void {
    this.iconMap = iconMap;
  }

  async printAllIcons(): Promise<void> {
    try {
      const icons = await appInfoManager.queryDynamicIcons();
      hilog.info(0, TAG, `共 ${icons.length} 个动态图标, 当前设备:${this.deviceType}`);
      icons.forEach((icon, i) => {
        hilog.info(0, TAG, `[${i}]${JSON.stringify(icon)}`);
      });
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0, TAG, `查询失败: ${err.code}${err.message}`);
    }
  }

  async switchByValue(value: string): Promise<boolean> {
    const baseId = this.iconMap[value];
    if (!baseId) {
      hilog.error(0, TAG, `未配置 value="${value}"`);
      return false;
    }

    const suffix = DEVICE_SUFFIX[this.deviceType] ?? '';
    const iconId = baseId + suffix;

    return this.selectIcon(iconId);
  }

  async selectIcon(iconId: string): Promise<boolean> {
    try {
      await appInfoManager.selectDynamicIcon(iconId);
      hilog.info(0, TAG, `切换成功: ${iconId}`);
      return true;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0, TAG, `切换失败: ${err.code}${err.message}`);
      return false;
    }
  }

  async restoreDefault(): Promise<boolean> {
    try {
      await appInfoManager.disableDynamicIcon();
      hilog.info(0, TAG, '已恢复默认图标');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0, TAG, `恢复失败: ${err.code}${err.message}`);
      return false;
    }
  }

}

export const Xb_DynamicIconManager = DynamicIconManager.getInstance();
