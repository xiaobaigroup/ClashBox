import { distributedKVStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { Context } from '@kit.AbilityKit';


class KVdbUtil {
  private kvManager: distributedKVStore.KVManager | undefined = undefined;
  private kvStore: distributedKVStore.SingleKVStore | undefined = undefined;
  private appId: string = '';
  private storeId: string = '';
  private context: Context | null = null;
  private options?: distributedKVStore.Options

  /**
   * 初始化KVManager
   * @param context 上下文对象
   * @param storeId 数据库ID
   */
  async initKVManager(context: Context, storeId: string, options?: distributedKVStore.Options): Promise<void> {
    this.context = context;
    this.appId = context.applicationInfo.name;
    this.storeId = storeId
    this.options = options
    const kvManagerConfig: distributedKVStore.KVManagerConfig = {
      context: context,
      bundleName: this.appId
    };
    try {
      this.kvManager = distributedKVStore.createKVManager(kvManagerConfig);
      console.info('Succeeded in creating KVManager.');
      this.getKVStore()
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to create KVManager. Code:${error.code},message:${error.message}`);
      throw error;
    }
  }

  /**
   * 创建或获取KVStore数据库
   * @param storeId 数据库ID
   * @param options 数据库配置选项
   */
  async getKVStore(): Promise<distributedKVStore.SingleKVStore> {
    if (!this.kvManager) {
      throw new Error('KVManager is not initialized. Call initKVManager first.');
    }

    const defaultOptions: distributedKVStore.Options = {
      createIfMissing: true,
      encrypt: false,
      backup: false,
      autoSync: true,
      kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
      securityLevel: distributedKVStore.SecurityLevel.S1
    };

    const finalOptions = this.options || defaultOptions;

    return new Promise((resolve, reject) => {
      this.kvManager!.getKVStore<distributedKVStore.SingleKVStore>(
        this.storeId,
        finalOptions,
        (err, store: distributedKVStore.SingleKVStore) => {
          if (err) {
            console.error(`Failed to get KVStore: Code:${err.code},message:${err.message}`);
            reject(err);
            return;
          }
          console.info('Succeeded in getting KVStore.');
          this.kvStore = store;
          resolve(store);
        }
      );
    });
  }

  /**
   * 向数据库插入数据
   * @param key 键
   * @param value 值（支持string、number、boolean、Uint8Array类型）
   */
  async putData(key: string, value: string | number | boolean | Uint8Array): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized. Call getKVStore first.');
    }

    return new Promise((resolve, reject) => {
      this.kvStore!.put(key, value, (err) => {
        if (err !== undefined) {
          console.error(`Failed to put data. Code:${err.code},message:${err.message}`);
          reject(err);
          return;
        }
        console.info(`KVdbUtil #putData Succeeded in putting ${key} data.`);
        resolve();
      });
    });
  }

  /**
   * 批量存储数据，所有键值对使用相同的值
   * @param keys 键名数组
   * @param value 统一的值
   */
  async putMultipleWithSameValue(
    keys: string[],
    value: string | number | boolean | Uint8Array
  ): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized.');
    }

    // 使用 Promise.all 并发执行所有 put 操作
    const promises = keys.map(key => this.putData(key, value));

    try {
      await Promise.all(promises);
      console.info(`Succeeded in putting ${keys.length} entries with the same value.`);
    } catch (error) {
      console.error(`Failed to put multiple entries. Error: ${error}`);
      throw error;
    }
  }

  /**
   * 从数据库获取数据
   * @param key 键
   * @returns 存储的值
   */
  async getData(key: string): Promise<string | number | boolean | Uint8Array> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized. Call getKVStore first.');
    }

    return new Promise((resolve, reject) => {
      this.kvStore!.get(key, (err, data) => {
        if (err !== undefined) {
          console.error(`Failed to get data. Code:${err.code},message:${err.message}`);
          reject(err);
          return;
        }
        console.info('Succeeded in getting data.');
        resolve(data);
      });
    });
  }

  /**
   * 获取所有数据
   * @returns 所有键值对数组
   */
  async getAllEntries(): Promise<Array<distributedKVStore.Entry>> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized.');
    }

    return new Promise((resolve, reject) => {
      // 传入空字符串 '' 作为前缀，获取所有数据
      this.kvStore.getEntries('', (err, entries) => {
        if (err) {
          console.error(`KVStore.getAllEntries Failed to get all entries. Code: ${err.code},message:${err.message}`);
          reject(err);
          return;
        }
        console.info(`KVStore.getAllEntries Succeeded in getting all ${entries.length} entries.`);
        resolve(entries);
      });
    });
  }

  /**
   * 从数据库删除数据
   * @param key 要删除的键
   */
  async deleteData(key: string): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized. Call getKVStore first.');
    }

    return new Promise((resolve, reject) => {
      this.kvStore!.delete(key, (err) => {
        if (err !== undefined) {
          console.error(`Failed to delete data. Code:${err.code},message:${err.message}`);
          reject(err);
          return;
        }
        console.info('Succeeded in deleting data.');
        resolve();
      });
    });
  }

  /**
   * 批量删除指定的键
   * @param keys 要删除的键名数组
   */
  async deleteKeysBatch(keys: string[]): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized.');
    }

    if (keys.length === 0) {
      console.info('No keys to delete, skipping.');
      return;
    }

    return new Promise((resolve, reject) => {
      this.kvStore!.deleteBatch(keys, (err) => {
        if (err) {
          console.error(`Failed to delete batch data. Code:${err.code},message:${err.message}`);
          reject(err);
          return;
        }
        console.info(`Succeeded in deleting ${keys.length} keys in a batch.`);
        resolve();
      });
    });
  }

  /**
   * 自动存储对象的所有属性
   * @param objectName 对象名称（用作键前缀）
   * @param obj 要存储的对象
   */
  async putObject(objectName: string, obj: Record<string, any>): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized.');
    }

    const promises: Promise<void>[] = [];

    // 遍历对象的所有属性
    for (const [key, value] of Object.entries(obj)) {
      if (value !== undefined && value !== null) {
        const fullKey = `${objectName}_${key}`;
        promises.push(this.putData(fullKey, value));
      }
    }

    await Promise.all(promises);
    console.info(`Succeeded in storing object: ${objectName}`);
  }

  /**
   * 批量插入数据
   * @param entries 键值对数组
   */
  async putEntriesBatch(entries: Array<distributedKVStore.Entry>): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized.');
    }

    return new Promise((resolve, reject) => {
      this.kvStore!.putBatch(entries, (err) => {
        if (err) {
          console.error(`Failed to put batch data. Code:${err.code},message:${err.message}`);
          reject(err);
          return;
        }
        console.info(`Succeeded in putting ${entries.length} entries in a batch.`);
        resolve();
      });
    });
  }

  /**
   * 自动获取对象的所有属性
   * @param objectName 对象名称（用作键前缀）
   * @returns 重建的对象
   */
  async getObject(objectName: string): Promise<Record<string, any>> {
    if (!this.kvStore) {
      throw new Error('KVStore.getObject is not initialized.');
    }
    return new Promise((resolve, reject) => {
      // 获取所有以 objectName_ 开头的键
      this.kvStore!.getEntries(`${objectName}_`, (err, entries) => {
        if (err) {
          console.error(`KVStore.getObject Failed to get object entries. Code:${err.code},message:${err.message}`);
          reject(err);
          return;
        }
        const obj: Record<string, any> = {};
        // 重建对象
        entries.forEach(entry => {
          // 移除前缀，获取原始属性名
          const originalKey = entry.key.replace(`${objectName}_`, '');
          obj[originalKey] = entry.value;
        });
        console.info(`KVStore.getObject Succeeded in getting object: ${objectName}`);
        resolve(obj);
      });
    });
  }

  /**
   * 更新对象的指定属性
   * @param objectName 对象名称
   * @param updates 要更新的属性对象
   */
  async updateObject(objectName: string, updates: Record<string, any>): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized.');
    }

    const promises: Promise<void>[] = [];

    for (const [key, value] of Object.entries(updates)) {
      if (value !== undefined && value !== null) {
        const fullKey = `${objectName}_${key}`;
        promises.push(this.putData(fullKey, value));
      }
    }

    await Promise.all(promises);
    console.info(`Succeeded in updating object: ${objectName}`);
  }

  /**
   * 保存对象（支持部分更新或完全替换）
   * @param objectName 对象名称
   * @param data 要保存的数据对象
   * @param options 选项 { replace: boolean } 是否完全替换旧对象
   */
  async saveObject(
    objectName: string,
    data: Record<string, any>,
    options?: { replace: boolean }
  ): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized.');
    }
    // 如果需要完全替换，先删除旧对象
    if (options?.replace) {
      try {
        await this.deleteObject(objectName);
      } catch (error) {
        // 如果对象不存在，忽略删除错误
        console.warn(`KVStore.saveObject Object ${objectName} not found for replacement, proceeding to save.`);
      }
    }
    // 保存新数据
    const promises: Promise<void>[] = [];
    for (const [key, value] of Object.entries(data)) {
      if (value !== undefined && value !== null) {
        const fullKey = `${objectName}_${key}`;
        promises.push(this.putData(fullKey, value));
      }
    }
    await Promise.all(promises);
    console.info(`KVStore.saveObject Succeeded in saving object: ${objectName} with replace: ${options?.replace}`);
  }

  /**
   * 删除对象的所有属性
   * @param objectName 对象名称
   */
  async deleteObject(objectName: string): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized.');
    }
    return new Promise((resolve, reject) => {
      // 先获取所有相关键
      this.kvStore!.getEntries(`${objectName}_`, (err, entries) => {
        if (err) {
          console.error(`KVStore.deleteObject Failed to get object entries for deletion. Code:${err.code},message:${err.message}`);
          reject(err);
          return;
        }
        // 删除所有相关键
        const deletePromises = entries.map(entry =>
        new Promise<void>((deleteResolve, deleteReject) => {
          this.kvStore!.delete(entry.key, (deleteErr) => {
            if (deleteErr) {
              deleteReject(deleteErr);
            } else {
              deleteResolve();
            }
          });
        })
        );
        Promise.all(deletePromises)
          .then(() => {
            console.info(`KVStore.deleteObject Succeeded in deleting object: ${objectName}`);
            resolve();
          })
          .catch(reject);
      });
    });
  }

  /**
   * 根据key前缀获取所有数据
   * @param prefix key前缀
   * @returns 匹配的键值对数组
   */
  async getEntriesByPrefix(prefix: string): Promise<Array<distributedKVStore.Entry>> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized.');
    }

    return new Promise((resolve, reject) => {
      this.kvStore!.getEntries(prefix, (err, entries) => {
        if (err) {
          console.error(`Failed to get entries by prefix. Code: ${err.code},message:${err.message}`);
          reject(err);
          return;
        }
        console.info(`Succeeded in getting ${entries.length} entries with prefix: ${prefix}`);
        resolve(entries);
      });
    });
  }

  /**
   * 根据value值查找所有匹配的key
   * @param value 要查找的值
   * @returns 匹配的key数组
   */
  async getKeysByValue(value: distributedKVStore.Value): Promise<string[]> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized.');
    }

    return new Promise((resolve, reject) => {
      this.kvStore!.getEntries('', (err, entries) => {
        if (err) {
          console.error(`Failed to get all entries for value search. Code: ${err.code},message:${err.message}`);
          reject(err);
          return;
        }

        const matchingKeys: string[] = [];
        entries.forEach(entry => {
          if (entry.value === value) {
            matchingKeys.push(entry.key);
          }
        });

        console.info(`Found ${matchingKeys.length} keys with value: ${value}`);
        resolve(matchingKeys);
      });
    });
  }

  /**
   * 根据value值查找所有匹配的键值对
   * @param value 要查找的值
   * @returns 匹配的键值对数组
   */
  async getEntriesByValue(value: distributedKVStore.Value): Promise<Array<distributedKVStore.Entry>> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized.');
    }

    return new Promise((resolve, reject) => {
      this.kvStore!.getEntries('', (err, entries) => {
        if (err) {
          console.error(`Failed to get all entries for value search. Code: ${err.code},message:${err.message}`);
          reject(err);
          return;
        }

        const matchingEntries: Array<distributedKVStore.Entry> = [];
        entries.forEach(entry => {
          if (entry.value === value) {
            matchingEntries.push(entry);
          }
        });

        console.info(`Found ${matchingEntries.length} entries with value: ${value}`);
        resolve(matchingEntries);
      });
    });
  }

  /**
   * 删除所有指定前缀的key
   * @param prefix key前缀
   * @returns 删除的key数量
   */
  async deleteEntriesByPrefix(prefix: string): Promise<number> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized.');
    }

    try {
      const entries = await this.getEntriesByPrefix(prefix);
      const deletePromises = entries.map(entry => this.deleteData(entry.key));
      await Promise.all(deletePromises);
      console.info(`Successfully deleted ${entries.length} entries with prefix: ${prefix}`);
      return entries.length;
    } catch (error) {
      console.error(`Failed to delete entries by prefix. Error: ${error}`);
      throw error;
    }
  }

  /**
   * 删除所有指定value的key
   * @param value 要删除的值
   * @returns 删除的key数量
   */
  async deleteEntriesByValue(value: distributedKVStore.Value): Promise<number> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized.');
    }

    try {
      const entries = await this.getEntriesByValue(value);
      const deletePromises = entries.map(entry => this.deleteData(entry.key));
      await Promise.all(deletePromises);
      console.info(`Successfully deleted ${entries.length} entries with value: ${value}`);
      return entries.length;
    } catch (error) {
      console.error(`Failed to delete entries by value. Error: ${error}`);
      throw error;
    }
  }

  /**
   * 检查指定的键是否存在于数据库中
   * @param key 要检查的键名
   * @returns Promise<boolean> 如果存在返回 true，否则返回 false
   */
  async hasKey(key: string): Promise<boolean> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized.');
    }

    try {
      // 尝试获取数据
      await this.getData(key);
      // 如果成功获取，说明key存在
      return true;
    } catch (error) {
      const businessError = error as BusinessError;
      // 如果错误码是 15100004 (KEY_NOT_FOUND)，说明key不存在
      if (businessError.code === 15100004) {
        return false;
      }
      throw error;
    }
  }

  /**
   * 订阅数据变更
   * @param callback 数据变更时的回调函数
   */
  subscribeDataChange(callback: (data: any) => void): void {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized. Call getKVStore first.');
    }
    try {
      this.kvStore!.on('dataChange', distributedKVStore.SubscribeType.SUBSCRIBE_TYPE_ALL, callback);
      console.info('Succeeded in subscribing to data changes.');
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to subscribe to data changes. Code:${error.code},message:${error.message}`);
      throw error;
    }
  }

  /**
   * 取消订阅数据变更
   */
  unsubscribeDataChange(): void {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized. Call getKVStore first.');
    }

    try {
      this.kvStore!.off('dataChange');
      console.info('Succeeded in unsubscribing from data changes.');
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to unsubscribe from data changes. Code:${error.code},message:${error.message}`);
      throw error;
    }
  }

  /**
   * 备份数据库
   * @param backupFile 备份文件名
   */
  async backupDatabase(backupFile: string): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized. Call getKVStore first.');
    }

    return new Promise((resolve, reject) => {
      this.kvStore!.backup(backupFile, (err) => {
        if (err) {
          console.error(`Failed to backup database. Code:${err.code},message:${err.message}`);
          reject(err);
          return;
        }
        console.info('Succeeded in backing up database.');
        resolve();
      });
    });
  }

  /**
   * 恢复数据库
   * @param backupFile 要恢复的备份文件名
   */
  async restoreDatabase(backupFile: string): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized. Call getKVStore first.');
    }

    return new Promise((resolve, reject) => {
      this.kvStore!.restore(backupFile, (err) => {
        if (err) {
          console.error(`Failed to restore database. Code:${err.code},message:${err.message}`);
          reject(err);
          return;
        }
        console.info('Succeeded in restoring database.');
        resolve();
      });
    });
  }

  /**
   * 删除备份文件
   * @param backupFiles 要删除的备份文件列表
   */
  async deleteBackup(backupFiles: string[]): Promise<void> {
    if (!this.kvStore) {
      throw new Error('KVStore is not initialized. Call getKVStore first.');
    }

    try {
      await this.kvStore!.deleteBackup(backupFiles);
      console.info('Succeeded in deleting backup.');
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to delete backup. Code:${error.code},message:${error.message}`);
      throw error;
    }
  }

  /**
   * 关闭数据库
   */
  async closeKVStore(): Promise<void> {
    if (!this.kvManager || !this.kvStore) {
      throw new Error('KVManager or KVStore is not initialized.');
    }

    return new Promise((resolve, reject) => {
      this.kvManager!.closeKVStore(this.appId, this.storeId, (err: BusinessError) => {
        if (err) {
          console.error(`Failed to close KVStore. Code:${err.code},message:${err.message}`);
          reject(err);
          return;
        }
        console.info('Succeeded in closing KVStore.');
        this.kvStore = undefined;
        resolve();
      });
    });
  }

  /**
   * 删除数据库
   */
  async deleteKVStore(): Promise<void> {
    if (!this.kvManager) {
      throw new Error('KVManager is not initialized.');
    }

    return new Promise((resolve, reject) => {
      this.kvManager!.deleteKVStore(this.appId, this.storeId, (err: BusinessError) => {
        if (err) {
          console.error(`Failed to delete KVStore. Code:${err.code},message:${err.message}`);
          reject(err);
          return;
        }
        console.info('Succeeded in deleting KVStore.');
        this.kvStore = undefined;
        resolve();
      });
    });
  }

}


/** 键值型数据库工具类封装 */
export const Xb_KVdbUtil = new KVdbUtil();