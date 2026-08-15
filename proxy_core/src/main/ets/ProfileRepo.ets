import { relationalStore, ValuesBucket } from '@kit.ArkData'
import { common } from '@kit.AbilityKit';
import { Profile } from './Profile';
import { SubscriptionInfo } from './models/Common';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';

const DB_VERSION = 5;

export class ProfileRepo {
  store: relationalStore.RdbStore | undefined

  constructor() { }

  async init(context: common.Context) {
    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: 'fsclash.db',
      securityLevel: relationalStore.SecurityLevel.S1
    };
    try {
      this.store = await relationalStore.getRdbStore(context, STORE_CONFIG);
      const versionRs = await this.store.querySql('PRAGMA user_version;');
      versionRs.goToNextRow();
      const currentVersion = versionRs.getLong(0);
      versionRs.close();

      const tableRs = await this.store.querySql("SELECT count(*) FROM sqlite_master WHERE type='table' AND name='Profiles'");
      tableRs.goToNextRow();
      const isTableExist = tableRs.getLong(0) > 0;
      tableRs.close();

      if (!isTableExist) {
        this.initDb();
        await this.store.executeSql(`PRAGMA user_version = ${DB_VERSION};`);
      } else if (currentVersion < DB_VERSION) {
        await this.upgradeDatabase(currentVersion);
      }
    } catch (error) {
      console.error(`ProfileRepo.init 失败, code: ${error.code}, message: ${error.message}`);
    }
  }

  private async upgradeDatabase(oldVersion: number) {
    if (oldVersion < 2) {
      try {
        await this.store!.executeSql("ALTER TABLE Profiles ADD COLUMN customUA TEXT;");
      } catch (e) {
        console.warn("ProfileRepo 升级 V1->V2: 跳过");
      }
    }
    if (oldVersion < 3) {
      try {
        await this.store!.executeSql("ALTER TABLE Profiles ADD COLUMN flag TEXT;");
      } catch (e) {
        console.warn("ProfileRepo 升级 V2->V3: 跳过");
      }
    }
    if (oldVersion < 4) {
      try {
        await this.store!.executeSql("ALTER TABLE Profiles ADD COLUMN overrideMode TEXT;");
      } catch (e) {
        console.warn("ProfileRepo 升级 V3->V4: 跳过");
      }
    }
    if (oldVersion < 5) {
      try {
        await this.store!.executeSql("ALTER TABLE Profiles ADD COLUMN customRules TEXT;");
      } catch (e) {
        console.warn("ProfileRepo 升级 V4->V5: 跳过");
      }
    }
    await this.store!.executeSql(`PRAGMA user_version = ${DB_VERSION};`);
  }

  initDb() {
    try {
      const SQL_CREATE_TABLE = "CREATE TABLE IF NOT EXISTS Profiles(" +
        "id TEXT PRIMARY KEY, " +
        "name TEXT, " +
        "type INTEGER NOT NULL, " +
        "url TEXT, " +
        "currentGroupName TEXT, " +
        "isUpdating INTEGER, " +
        "autoUpdate INTEGER, " +
        "lastUpdateDate INTEGER, " +
        "autoUpdateDuration INTEGER, " +
        "subscriptionInfo TEXT, " +
        "proxySelected Text, " +
        "customUA TEXT," +
        "flag TEXT," +
        "overrideMode TEXT," +
        "customRules TEXT)"
      this.store?.executeSql(SQL_CREATE_TABLE);
    } catch (e) {
      console.error("initDb failure", e)
    }
  }

  async delete(uuid: string) {
    const predicates = new relationalStore.RdbPredicates('Profiles')
    predicates.equalTo('id', uuid);
    await this.store!.delete(predicates);
  }

  async ClearAll(context: Context) {
    const list = await this.queryAll()
    for (let d of list) {
      d.loadContext(context)
      await this.delete(d.id)
      await d.delete()
    }
  }

  async query(uuid: string | undefined) {
    if (uuid == undefined) return null
    const predicates = new relationalStore.RdbPredicates('Profiles')
    predicates.equalTo('id', uuid);
    const cursor = await this.store!.query(predicates);
    if (cursor.rowCount > 0) {
      cursor.goToNextRow();
      return this.getFromCursor(cursor);
    } else {
      return null;
    }
  }

  queryAll(): Promise<Profile[]> {
    const predicates = new relationalStore.RdbPredicates('Profiles');
    const list: Profile[] = [];
    if (this.store) {
      return this.store.query(predicates)
        .then((cursor) => {
          try {
            while (cursor.goToNextRow()) {
              list.push(this.getFromCursor(cursor));
            }
            return list;
          } finally {
            cursor.close();
          }
        })
        .catch((err: BusinessError) => {
          console.error(`ProfileRepo.queryAll failed, code is ${err.code}, message is ${err.message}`);
          return [];
        })
    } else {
      return Promise.resolve([])
    }
  }

  async addOrUpdate(details: Profile): Promise<number> {
    const predicates = new relationalStore.RdbPredicates('Profiles')
    predicates.equalTo('id', details.id);
    const old = await this.store!.query(predicates)
    const jsonObject = details.getSelectedMap()
    const input: ValuesBucket = {
      id: details.id,
      name: details.name,
      type: details.type,
      url: details.url,
      currentGroupName: details.currentGroupName,
      isUpdating: details.isUpdating ? 1 : 0,
      autoUpdate: details.autoUpdate ? 1 : 0,
      lastUpdateDate: details.lastUpdateDate,
      autoUpdateDuration: details.autoUpdateDuration,
      subscriptionInfo: JSON.stringify(details.subscriptionInfo),
      proxySelected: JSON.stringify(jsonObject),
      customUA: details.customUA,
      flag: details.flag,
      // 如果未定义则默认存储 'rule'
      overrideMode: details.overrideMode ? details.overrideMode : 'rule'
    }
    if (old.rowCount > 0) {
      await this.store!.update(input, predicates)
      return 1
    } else {
      await this.store!.insert("Profiles", input)
      return 0
    }
  }

  /**
   * 更新指定 Profile 的 overrideMode
   * @param profileId Profile 的 ID
   * @param mode 'rule' 或 'script'
   */
  async updateOverrideMode(profileId: string, mode: 'rule' | 'script') {
    if (!this.store) {
      console.error("ProfileRepo.updateOverrideMode: store is not initialized");
      return;
    }
    const predicates = new relationalStore.RdbPredicates('Profiles');
    predicates.equalTo('id', profileId);

    // 只更新 overrideMode 字段
    const value: ValuesBucket = {
      overrideMode: mode
    };

    try {
      await this.store.update(value, predicates);
    } catch (error) {
      console.error(`ProfileRepo.updateOverrideMode 失败, code: ${error.code}, message: ${error.message}`);
    }
  }

  /**
   * 获取指定 Profile 的 overrideMode
   * @param profileId Profile 的 ID
   * @returns 'rule' | 'script' | null (如果找不到对应 Profile)
   */
  async getOverrideMode(profileId: string): Promise<'rule' | 'script' | null> {
    const profile = await this.query(profileId);
    if (profile) {
      // 如果为空返回默认值 'rule'，否则返回数据库存的值
      return profile.overrideMode ? profile.overrideMode : 'rule';
    }
    return null;
  }

  /**
   * 更新指定 Profile 的自定义规则
   * @param profileId Profile 的 ID
   * @param rules 自定义规则数组
   */
  async updateCustomRules(profileId: string, rules: string[]) {
    if (!this.store) {
      console.error("ProfileRepo.updateCustomRules: store is not initialized");
      return;
    }
    const predicates = new relationalStore.RdbPredicates('Profiles');
    predicates.equalTo('id', profileId);

    const value: ValuesBucket = {
      customRules: rules.length > 0 ? JSON.stringify(rules) : ''
    };

    try {
      await this.store.update(value, predicates);
    } catch (error) {
      console.error(`ProfileRepo.updateCustomRules 失败, code: ${error.code}, message: ${error.message}`);
    }
  }

  /**
   * 获取指定 Profile 的自定义规则
   * @param profileId Profile 的 ID
   * @returns 自定义规则数组
   */
  async getCustomRules(profileId: string): Promise<string[]> {
    const profile = await this.query(profileId);
    if (profile) {
      return profile.customRules || [];
    }
    return [];
  }

  // 使用列名动态获取索引
  getFromCursor(c: relationalStore.ResultSet): Profile {
    const details = new Profile(0, "");
    try {
      details.id = c.getString(c.getColumnIndex("id"));
      details.name = c.getString(c.getColumnIndex("name"));
      details.type = c.getLong(c.getColumnIndex("type"));
      details.url = c.getString(c.getColumnIndex("url"));
      details.currentGroupName = c.getString(c.getColumnIndex("currentGroupName"));
      details.isUpdating = c.getLong(c.getColumnIndex("isUpdating")) == 1;
      details.autoUpdate = c.getLong(c.getColumnIndex("autoUpdate")) == 1;
      details.lastUpdateDate = c.getLong(c.getColumnIndex("lastUpdateDate"));
      details.autoUpdateDuration = c.getLong(c.getColumnIndex("autoUpdateDuration"));
      const subStr = c.getString(c.getColumnIndex("subscriptionInfo"));
      details.subscriptionInfo = subStr ? JSON.parse(subStr) as SubscriptionInfo : null;

      const map = new Map<string, string>();
      const proxyStr = c.getString(c.getColumnIndex("proxySelected"));
      if (proxyStr) {
        let json = JSON.parse(proxyStr) as Record<string, string>
        Object.keys(json).forEach((key) => {
          map.set(key, json[key]);
        });
      }
      details.proxySelected = map;
      details.customUA = c.getString(c.getColumnIndex("customUA"));
      details.flag = c.getString(c.getColumnIndex("flag"));

      // 读取 overrideMode，如果数据库中为空字符串则赋值为 'rule'
      const modeStr = c.getString(c.getColumnIndex("overrideMode"));
      details.overrideMode = (modeStr === 'script' ? 'script' : 'rule');

      // 读取 customRules（兼容旧版本数据库没有该列的情况）
      try {
        const rulesStr = c.getString(c.getColumnIndex("customRules"));
        if (rulesStr) {
          try {
            const parsed = JSON.parse(rulesStr);
            if (Array.isArray(parsed)) {
              details.customRules = parsed as string[];
            }
          } catch (_) {
            details.customRules = [];
          }
        } else {
          details.customRules = [];
        }
      } catch (_) {
        // 旧版本数据库没有 customRules 列
        details.customRules = [];
      }

    } catch (e) {
      console.error("ProfileRepo.getFromCursor 解析异常", e)
      details.subscriptionInfo = null
      details.proxySelected = new Map()
      details.customUA = "";
      details.flag = ''
      details.overrideMode = 'rule'; // 解析异常时给个默认值
      details.customRules = [];
    }
    return details;
  }

}
