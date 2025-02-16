import { relationalStore, ValuesBucket } from '@kit.ArkData'
import { common } from '@kit.AbilityKit';
import { Profile } from './Profile';
import { SubscriptionInfo } from './models/Common';

export class ProfileRepo {
  store: relationalStore.RdbStore | undefined
  constructor() {
  }
  async init(context: common.Context) {
    const STORE_CONFIG: relationalStore.StoreConfig = {
      name: 'fsclash.db', // 数据库文件名
      securityLevel: relationalStore.SecurityLevel.S1 // 数据库安全级别
    };
    this.store = await relationalStore.getRdbStore(context, STORE_CONFIG)
    this.initDb()
  }
  initDb() {
    try {
      const SQL_CREATE_TABLE = "CREATE TABLE IF NOT EXISTS Profiles(id TEXT PRIMARY KEY, name TEXT, type INTEGER NOT NULL, url TEXT, currentGroupName TEXT, isUpdating INTEGER,autoUpdate INTEGER, lastUpdateDate INTEGER, autoUpdateDuration INTEGER, subscriptionInfo TEXT, proxySelected Text)"
      this.store?.executeSql(SQL_CREATE_TABLE); // 创建数据表
    } catch (e) {
      console.error("initDb failure", e)
    }
  }
  async delete(uuid: string) {
    const predicates = new relationalStore.RdbPredicates('Profiles')
    predicates.equalTo('id', uuid);
    await this.store!.delete(predicates);
  }
  async ClearAll(){
    const list = await this.queryAll()
    for (let d of list) {
      this.delete(d.id)
      await d.delete()
    }
  }
  async query(uuid: string | undefined) {
    if(uuid == undefined)
      return null
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
  async queryAll(): Promise<Profile[]> {
    const predicates = new relationalStore.RdbPredicates('Profiles')
    const cursor = await this.store!.query(predicates)
    const list: Profile[] = []
    cursor.goToNextRow()
    while (cursor.rowIndex >= 0 && cursor.rowIndex < cursor.rowCount) {
      list.push(this.getFromCursor(cursor))
      cursor.goToNextRow()
    }
    return list;
  }

  async addOrUpdate(details: Profile) {
    const predicates = new relationalStore.RdbPredicates('Profiles')
    predicates.equalTo('id', details.id);
    const old = await this.store!.query(predicates)
    const jsonObject = details.getSelectedMap()
    const input: ValuesBucket = {
      id: details.id,
      name: details.name ,
      type: details.type,
      url: details.url,
      currentGroupName: details.currentGroupName,
      isUpdating: details.isUpdating ? 1: 0,
      autoUpdate: details.autoUpdate ? 1 : 0,
      lastUpdateDate: details.lastUpdateDate,
      autoUpdateDuration: details.autoUpdateDuration,
      subscriptionInfo: JSON.stringify(details.subscriptionInfo),
      proxySelected: JSON.stringify(jsonObject)
    }
    if (old.rowCount > 0){
      await this.store!.update(input, predicates)
    }
    else
      await this.store!.insert("Profiles", input)
  }

  getFromCursor(c: relationalStore.ResultSet): Profile {
    const details = new Profile(0,"");
    details.id = c.getString(0);
    details.name = c.getString(1);
    details.type = c.getLong(2);
    details.url = c.getString(3);
    details.currentGroupName = c.getString(4);
    details.isUpdating = c.getLong(5) == 1;
    details.autoUpdate = c.getLong(6) == 1;
    details.lastUpdateDate = c.getLong(7);
    details.autoUpdateDuration = c.getLong(8);

    try {
      details.subscriptionInfo = JSON.parse(c.getString(9)) as SubscriptionInfo;
      const map = new Map<string, string>();
      let json = JSON.parse(c.getString(10)) as Record<string, string>
      Object.keys(json).forEach((key) => {
        map.set(key, json[key]);
      });
      details.proxySelected = map;
    } catch (e) {
      details.subscriptionInfo = null
      details.proxySelected = new Map()
    }
    return details;
  }
}