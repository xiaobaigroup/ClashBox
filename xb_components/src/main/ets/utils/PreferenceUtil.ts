
import { preferences } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Context } from '@ohos.abilityAccessCtrl';

const TAG: string = 'PreferenceUtil';

/**
 * 首选项工具类
 * 使用单例模式，封装了首选项的常用异步操作。
 * 使用前必须先调用 init 方法进行初始化。
 */
class PreferenceUtil {
  private static instance: PreferenceUtil | null = null;
  private _preference: preferences.Preferences | null = null;
  private _context: Context | null = null;

  // 私有构造函数，防止外部通过 new 创建实例
  private constructor() {}

  /**
   * 获取单例实例
   * @returns PreferenceUtil实例
   */
  public static getInstance(): PreferenceUtil {
    if (!PreferenceUtil.instance) {
      PreferenceUtil.instance = new PreferenceUtil();
    }
    return PreferenceUtil.instance;
  }

  /**
   * 初始化首选项工具类，必须在调用其他方法前执行。
   * @param context 应用上下文
   * @param fileName 首选项文件名
   * @returns Promise<void>
   */
  public async init(context: Context, fileName: string = 'configPreference'): Promise<void> {
    if (this._preference) {
      hilog.warn(0x000, TAG, 'PreferencesUtil has already been initialized.');
      return;
    }
    this._context = context;
    try {
      this._preference = await preferences.getPreferences(context, { name: fileName });
      hilog.info(0x000, TAG, `Preferences initialized successfully with file: ${fileName}`);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x000, TAG, `Failed to initialize preferences. Code: ${err.code}, Message: ${err.message}`);
      throw new Error(`${err}`);
    }
  }

  /**
   * 确保已初始化的私有方法
   * @private
   */
  private _ensureInitialized(): void {
    if (!this._preference || !this._context) {
      throw new Error('PreferenceUtil is not initialized. Please call init() first.');
    }
  }

  // ==================== 高性能接口 (特殊场景使用) ====================

  /**
   * 【特殊】仅将数据写入内存缓存，不立即持久化到磁盘。
   * **警告**：此方法不保证数据安全，应用崩溃后数据会丢失。
   * 必须在合适的时机手动调用 save() 方法来保存。
   * 此方法是同步的，因为它只操作内存，速度极快，不会阻塞UI线程。
   * @param key 键
   * @param value 值
   */
  public putSync(key: string, value: preferences.ValueType): void {
    this._ensureInitialized();
    try {
      this._preference!.putSync(key, value);
      hilog.info(0x000, TAG, `PutSync key: ${key}, value:${value} to cache.`);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x000, TAG, `Failed to put key '${key}' to cache. Code:${err.code}, Message: ${err.message}`);
      throw new Error(`${err}`);
    }
  }

  /**
   * 【特殊】将内存中的所有缓存数据持久化到磁盘。
   * 通常在多次 putSync 调用后，或在应用进入后台时调用。
   * @returns Promise<void>
   */
  public async save(): Promise<void> {
    this._ensureInitialized();
    try {
      await this._preference!.flush();
      hilog.info(0x000, TAG, 'Saved preferences to disk successfully.');
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x000, TAG, `Failed to save preferences. Code: ${err.code}, Message:${err.message}`);
      throw new Error(`${err}`);
    }
  }

  // ==================== 常规接口 ====================

  /**
   * 保存或更新一个键值对
   * @param key 键
   * @param value 值，支持 number, string, boolean 及其数组类型
   * @returns Promise<void>
   */
  public async put(key: string, value: preferences.ValueType): Promise<void> {
    this._ensureInitialized();
    try {
      await this._preference!.put(key, value);
      await this._preference!.flush();
      hilog.info(0x000, TAG, `Saved key: ${key}, value: ${value}`);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x000, TAG, `Failed to save key '${key}'. Code: ${err.code}, Message: ${err.message}`);
      throw new Error(`${err}`);
    }
  }

  /**
   * 获取指定键的值
   * @param key 键
   * @param defValue 如果键不存在时返回的默认值
   * @returns Promise<T> 返回指定类型的值
   */
  public async get<T>(key: string, defValue: preferences.ValueType): Promise<T> {
    this._ensureInitialized();
    try {
      const value = await this._preference!.get(key, defValue);
      hilog.info(0x000, TAG, `Retrieved key: ${key}, value: ${value}`);
      return value as T;
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x000, TAG, `Failed to get key '${key}'. Code: ${err.code}, Message: ${err.message}`);
      return defValue as T; // 发生错误时返回默认值
    }
  }

  /**
   * 删除指定键的数据
   * @param key 键
   * @returns Promise<void>
   */
  public async delete(key: string): Promise<void> {
    this._ensureInitialized();
    try {
      await this._preference!.delete(key);
      await this._preference!.flush();
      hilog.info(0x000, TAG, `Deleted key: ${key}`);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x000, TAG, `Failed to delete key '${key}'. Code: ${err.code}, Message: ${err.message}`);
      throw new Error(`${err}`);
    }
  }

  /**
   * 清除所有首选项数据
   * @returns Promise<void>
   */
  public async clear(): Promise<void> {
    this._ensureInitialized();
    try {
      await this._preference!.clear();
      await this._preference!.flush();
      hilog.info(0x000, TAG, 'Cleared all preferences.');
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x000, TAG, `Failed to clear preferences. Code: ${err.code}, Message: ${err.message}`);
      throw new Error(`${err}`);
    }
  }

  /**
   * 检查某个键是否存在
   * @param key 键
   * @returns Promise<boolean> true表示存在，false表示不存在
   */
  public async has(key: string): Promise<boolean> {
    this._ensureInitialized();
    try {
      return await this._preference!.has(key);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0x000, TAG, `Failed to check key '${key}'. Code: ${err.code}, Message: ${err.message}`);
      return false;
    }
  }

  /**
   * 关闭首选项实例并释放资源。
   * 通常在应用退出时调用。
   * @returns Promise<void>
   */
  public async close(): Promise<void> {
    if (this._preference) {
      try {
        this._preference = null;
        this._context = null;
        hilog.info(0x000, TAG, 'Preferences instance closed.');
      } catch (error) {
        const err = error as BusinessError;
        hilog.error(0x000, TAG, `Failed to close preferences. Code: ${err.code}, Message: ${err.message}`);
      }
    }
  }
}

// 导出
export const Xb_PreferenceUtil = PreferenceUtil.getInstance();
