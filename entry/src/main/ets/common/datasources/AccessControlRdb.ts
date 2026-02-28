import { distributedKVStore, relationalStore } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { Base64Util } from '../utils/Base64Util'

const TAG = 'AccessControlRdb'
const DB_NAME = 'AccessControl.db'

/**
 * 列表类型枚举 -- 域 + 状态设计
 * 确保黑白名单数据在数据库层面完全隔离
 */
export enum ListType {
  // --- 白名单域 ---
  WHITE_SELECTED = 1,     // 白名单：已选中
  WHITE_UNSELECTED = 10, // 白名单：未选中（仅白名单模式显示）

  // --- 黑名单域 ---
  BLACK_SELECTED = 2,     // 黑名单：已选中
  BLACK_UNSELECTED = 20   // 黑名单：未选中（仅黑名单模式显示）
}

/**
 * 数据库实体
 */
export interface AppInfoRdb {
  package_name: string
  list_type: ListType
  app_name: string
  icon_blob: Uint8Array
  create_time: number
}

/**
 * UI 使用的实体
 */
export interface AppInfo {
  name: string
  package_name: string
  time: number
  iconUintArr?: Uint8Array
  isSelected: boolean
}

/**
 * Config 使用的实体
 */
export interface AppInfoConfig {
  package_name: string
  list_type: number
  app_name: string
  icon_base64: string
  create_time: number
  isSelected: boolean
}

/**
 * 导入导出的配置结构
 */
export interface AccessConfigExport {
  version: string
  exportTime: number
  enable: boolean
  mode: string
  sort: string
  apps: Array<AppInfoConfig>
}

/**
 * 访问控制数据库管理类
 */
export class AccessControlRdb {
  private static instance: AccessControlRdb | null = null
  private rdbStore: relationalStore.RdbStore | null = null
  private context: common.UIAbilityContext | null = null
  private isInitializing: boolean = false
  private initPromise: Promise<void> | null = null

  private constructor() {}

  static getInstance(): AccessControlRdb {
    if (!AccessControlRdb.instance) {
      AccessControlRdb.instance = new AccessControlRdb()
    }
    return AccessControlRdb.instance
  }

  /**
   * 初始化数据库实例
   * @param context 应用上下文
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.rdbStore) return

    if (this.isInitializing && this.initPromise) {
      return this.initPromise
    }

    this.isInitializing = true
    this.context = context
    this.initPromise = this.doInit()
    await this.initPromise
    this.isInitializing = false
  }

  private async doInit(): Promise<void> {
    try {
      const config: relationalStore.StoreConfig = {
        name: DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      }
      this.rdbStore = await relationalStore.getRdbStore(this.context!, config)

      // 创建表结构
      this.createTable()

      hilog.info(0x0000, TAG, '数据库初始化成功')
    } catch (error) {
      hilog.error(0x0000, TAG, `数据库初始化失败: ${JSON.stringify(error)}`)
      throw new Error(error)
    }
  }

  private createTable(): void {
    const sql = `
      CREATE TABLE IF NOT EXISTS access_control_apps (
        package_name TEXT NOT NULL,
        list_type INTEGER NOT NULL,
        app_name TEXT NOT NULL,
        icon_blob BLOB,
        create_time INTEGER NOT NULL,
        PRIMARY KEY (package_name, list_type)
      )
    `
    this.rdbStore?.executeSql(sql)
    // 添加索引以优化查询性能
    this.rdbStore?.executeSql('CREATE INDEX IF NOT EXISTS idx_app_name ON access_control_apps(app_name)')
    this.rdbStore?.executeSql('CREATE INDEX IF NOT EXISTS idx_package_name ON access_control_apps(package_name)')
  }

  /**
   * 获取指定域的所有应用（已选中 + 未选中）
   * @param domain 名单域 ('WHITE' | 'BLACK')
   * @param sortBy 排序字段 ('name' | 'time')
   * @returns 应用列表
   */
  async getAppsByDomain(domain: 'WHITE' | 'BLACK', sortBy: 'name' | 'time' = 'time'): Promise<AppInfo[]> {
    this.ensureInitialized()
    const predicates = new relationalStore.RdbPredicates('access_control_apps')

    if (domain === 'WHITE') {
      predicates.in('list_type', [ListType.WHITE_SELECTED, ListType.WHITE_UNSELECTED])
    } else {
      predicates.in('list_type', [ListType.BLACK_SELECTED, ListType.BLACK_UNSELECTED])
    }

    // 主排序：按选中状态排（list_type 升序，选中的 1/2 在前，未选中的 10/20 在后）
    predicates.orderByAsc('list_type')
    // 次排序：按名称或时间排
    if (sortBy === 'name') {
      predicates.orderByAsc('app_name')
    } else {
      predicates.orderByDesc('create_time')
    }

    const resultSet = await this.rdbStore!.query(predicates)
    const apps = this.parseResultSetToUIList(resultSet)
    resultSet.close()
    return apps
  }

  /**
   * 获取所有应用数据（不区分黑白名单）
   * @param sortBy 排序字段
   * @returns 所有应用列表
   */
  async getAllApps(sortBy: 'name' | 'time' = 'name'): Promise<AppInfo[]> {
    this.ensureInitialized()
    const predicates = new relationalStore.RdbPredicates('access_control_apps')

    // 全局排序逻辑
    predicates.orderByAsc('list_type')
    if (sortBy === 'name') {
      predicates.orderByAsc('app_name')
    } else {
      predicates.orderByDesc('create_time')
    }

    const resultSet = await this.rdbStore!.query(predicates)
    const apps = this.parseResultSetToUIList(resultSet)
    resultSet.close()
    return apps
  }

  /**
   * 获取所有原始应用数据（包含详细的 list_type 和原始 Blob 图标）
   * 专门用于导出功能
   */
  async getAllAppsRaw(): Promise<AppInfoRdb[]> {
    this.ensureInitialized()
    const predicates = new relationalStore.RdbPredicates('access_control_apps')
    // 按照默认顺序排序，保持一致性
    predicates.orderByAsc('list_type').orderByAsc('app_name')

    const resultSet = await this.rdbStore!.query(predicates)
    const apps: AppInfoRdb[] = []

    while (resultSet.goToNextRow()) {
      apps.push({
        package_name: resultSet.getString(resultSet.getColumnIndex('package_name')),
        list_type: resultSet.getLong(resultSet.getColumnIndex('list_type')),
        app_name: resultSet.getString(resultSet.getColumnIndex('app_name')),
        icon_blob: resultSet.getBlob(resultSet.getColumnIndex('icon_blob')),
        create_time: resultSet.getLong(resultSet.getColumnIndex('create_time'))
      })
    }
    resultSet.close()
    return apps
  }

  /**
   * 添加应用到指定域（默认为未选中状态）
   * @param info 应用基础信息
   * @param domain 目标域 ('WHITE' | 'BLACK')
   */
  async addAppToDomain(info: AppInfo, domain: 'WHITE' | 'BLACK'): Promise<void> {
    this.ensureInitialized()
    const listType = (domain === 'WHITE') ? ListType.WHITE_UNSELECTED : ListType.BLACK_UNSELECTED

    await this.insertOrReplaceApp({
      package_name: info.package_name,
      list_type: listType,
      app_name: info.name,
      icon_blob: info.iconUintArr,
      create_time: info.time
    })
  }

  /**
   * 切换指定域内应用的选中状态 (勾选/取消勾选)
   * @param package_name 应用包名
   * @param domain 当前所在的域 ('WHITE' | 'BLACK')
   * @returns 操作是否成功 (false 表示已达到上限，无法勾选)
   */
  async toggleSelection(package_name: string, domain: 'WHITE' | 'BLACK'): Promise<boolean> {
    this.ensureInitialized()
    // 查找当前应用
    const apps = await this.getAppsByPackageName(package_name)
    const currentApp = apps.find(app => {
      if (domain === 'WHITE') return app.list_type === ListType.WHITE_SELECTED || app.list_type === ListType.WHITE_UNSELECTED
      return app.list_type === ListType.BLACK_SELECTED || app.list_type === ListType.BLACK_UNSELECTED
    })
    if (!currentApp) {
      hilog.warn(0x0000, TAG, `toggleSelection: 未找到应用 ${package_name} 在域 ${domain}`)
      return false
    }
    // 计算新的状态类型
    let newType: ListType
    if (domain === 'WHITE') {
      newType = (currentApp.list_type === ListType.WHITE_UNSELECTED) ? ListType.WHITE_SELECTED : ListType.WHITE_UNSELECTED
    } else {
      newType = (currentApp.list_type === ListType.BLACK_UNSELECTED) ? ListType.BLACK_SELECTED : ListType.BLACK_UNSELECTED
    }
    // 数量限制检查
    // 只有当目标是“选中”状态时，才需要检查数量限制
    const isTargetSelected = (newType === ListType.WHITE_SELECTED || newType === ListType.BLACK_SELECTED)
    if (isTargetSelected) {
      const maxLimit = (domain === 'WHITE') ? 254 : 256
      // 查询当前域内已选中的数量
      const countPredicates = new relationalStore.RdbPredicates('access_control_apps')
        .equalTo('list_type', newType)
      const resultSet = await this.rdbStore!.query(countPredicates)
      const currentCount = resultSet.rowCount
      resultSet.close() // 记得关闭结果集

      if (currentCount >= maxLimit) {
        hilog.warn(0x0000, TAG, `toggleSelection: ${domain} 名单已满 (${currentCount}/${maxLimit})`)
        return false // 已满，返回 false
      }
    }
    // 执行事务：先删后增
    this.beginTransaction()
    try {
      // 删除旧状态
      const deletePredicates = new relationalStore.RdbPredicates('access_control_apps')
        .equalTo('package_name', package_name)
        .equalTo('list_type', currentApp.list_type)
      await this.rdbStore!.delete(deletePredicates)
      // 插入新状态
      await this.insertOrReplaceApp({
        ...currentApp,
        list_type: newType
      })
      this.commitTransaction()
      hilog.info(0x0000, TAG, `切换状态成功: ${package_name} -> ${newType}`)
      return true // 操作成功
    } catch (e) {
      this.rollBackTransaction()
      hilog.error(0x0000, TAG, `切换状态失败: ${JSON.stringify(e)}`)
      throw e
    }
  }


  /**
   * 将应用复制到对面名单
   * 原名单中的记录保留，新名单中增加一条对应记录（选中状态同步）
   * @param package_name 应用包名
   * @param sourceDomain 当前所在的源域 ('WHITE' | 'BLACK')
   */
  async copyToOppositeDomain(package_name: string, sourceDomain: 'WHITE' | 'BLACK'): Promise<void> {
    this.ensureInitialized()
    // 获取该包名在两个域中的所有记录
    const apps = await this.getAppsByPackageName(package_name)
    // 找到源域的记录
    const sourceApp = apps.find(app => {
      if (sourceDomain === 'WHITE') return app.list_type === ListType.WHITE_SELECTED || app.list_type === ListType.WHITE_UNSELECTED
      return app.list_type === ListType.BLACK_SELECTED || app.list_type === ListType.BLACK_UNSELECTED
    })
    if (!sourceApp) return
    // 确定目标域
    const targetDomain = sourceDomain === 'WHITE' ? 'BLACK' : 'WHITE'
    // 检查目标域是否已存在该应用
    const existsInTarget = apps.some(app => {
      if (targetDomain === 'WHITE') {
        return app.list_type === ListType.WHITE_SELECTED || app.list_type === ListType.WHITE_UNSELECTED
      } else {
        return app.list_type === ListType.BLACK_SELECTED || app.list_type === ListType.BLACK_UNSELECTED
      }
    })
    // 如果目标域已经存在，抛出错误，阻止复制
    if (existsInTarget) {
      throw new Error('目标名单中已存在该应用')
    }
    // 计算目标域的 list_type (保持选中状态一致)
    let targetType: ListType
    const isSelected = (sourceApp.list_type === ListType.WHITE_SELECTED || sourceApp.list_type === ListType.BLACK_SELECTED)
    if (sourceDomain === 'WHITE') {
      // 白 -> 黑
      targetType = isSelected ? ListType.BLACK_SELECTED : ListType.BLACK_UNSELECTED
    } else {
      // 黑 -> 白
      targetType = isSelected ? ListType.WHITE_SELECTED : ListType.WHITE_UNSELECTED
    }
    await this.insertOrReplaceApp({
      ...sourceApp,
      list_type: targetType,
      create_time: Date.now() // 更新为当前操作时间
    })
  }

  /**
   * 将应用移动到对面名单
   * 原名单中的记录删除，新名单中增加一条对应记录（选中状态同步）
   * @param package_name 应用包名
   * @param sourceDomain 当前所在的源域 ('WHITE' | 'BLACK')
   */
  async moveToOppositeDomain(package_name: string, sourceDomain: 'WHITE' | 'BLACK'): Promise<void> {
    this.ensureInitialized()
    // 先执行复制逻辑
    await this.copyToOppositeDomain(package_name, sourceDomain)
    // 再执行删除源域逻辑
    await this.removeAppFromDomain(package_name, sourceDomain)
  }

  /**
   * 从指定域移除应用 (删除该域下的所有记录)
   * @param package_name 应用包名
   * @param domain 目标域 ('WHITE' | 'BLACK')
   * @returns 删除的行数
   */
  async removeAppFromDomain(package_name: string, domain: 'WHITE' | 'BLACK'): Promise<number> {
    this.ensureInitialized()
    const typesToDelete = (domain === 'WHITE') ? [ListType.WHITE_SELECTED, ListType.WHITE_UNSELECTED] : [ListType.BLACK_SELECTED, ListType.BLACK_UNSELECTED]

    const predicates = new relationalStore.RdbPredicates('access_control_apps')
      .equalTo('package_name', package_name)
      .in('list_type', typesToDelete)

    return await this.rdbStore!.delete(predicates)
  }

  /**
   * 保存导入的配置数据
   * @param config 已经解析好的配置对象（包含 Base64 图标字符串）
   * @returns 成功导入的数量
   */
  async saveImportedApps(config: AccessConfigExport): Promise<number> {
    this.ensureInitialized()

    if (!config || !config.apps || config.apps.length === 0) {
      return 0
    }

    this.beginTransaction()
    let count = 0
    try {
      for (const appData of config.apps) {
        // hilog.debug(0x0000, TAG, `导入数据 appData: ${JSON.stringify(appData)}`)
        // 将 Base64 字符串解码回 Uint8Array
        const iconUint8 = appData.icon_base64 ? Base64Util.decodeSync(appData.icon_base64) : new Uint8Array(0);
        // hilog.debug(0x0000, TAG, `导入数据 iconUint8: ${JSON.stringify(iconUint8)}`)
        await this.saveOrMergeApp({
          package_name: appData.package_name,
          list_type: appData.list_type,
          app_name: appData.app_name,
          icon_blob: iconUint8,
          create_time: appData.create_time
        })
        count++
      }
      this.commitTransaction()
      return count
    } catch (e) {
      this.rollBackTransaction()
      hilog.error(0x0000, TAG, `导入数据写入失败, message: ${e.message}, code: ${e.code}`)
      throw e
    }
  }

  /**
   * 彻底删除应用 (所有域的所有记录)
   * @param package_name 应用包名
   * @returns 删除的行数
   */
  async deleteAppCompletely(package_name: string): Promise<number> {
    this.ensureInitialized()
    const predicates = new relationalStore.RdbPredicates('access_control_apps')
      .equalTo('package_name', package_name)
    return await this.rdbStore!.delete(predicates)
  }

  /**
   * 从旧存储迁移数据
   * 策略：
   * 旧 accept_ -> ListType.WHITE_SELECTED (1)
   * 旧 reject_ -> ListType.BLACK_SELECTED (2)
   * 旧 appList 中剩下的 -> ListType.WHITE_UNSELECTED (10) 或 ListType.BLACK_UNSELECTED (20)
   */
  async migrateFromOldStorage(configContent: string, acceptEntries: distributedKVStore.Entry[], rejectEntries: distributedKVStore.Entry[], listType: ListType): Promise<void> {
    if (!this.rdbStore) return
    this.createTable()

    try {
      hilog.debug(0x0000, TAG, '#migrateFromOldStorage 开始从旧存储迁移数据...')
      // 读取旧数据
      const oldApps: AppInfo[] = JSON.parse(configContent)
      // JSON.parse 后 iconUintArr 可能是 number[]，需要转为 Uint8Array 以适配 RDB BLOB 字段
      const cleanApps = oldApps
        .filter(app => app && app.package_name) // 过滤掉没有包名的脏数据
        .map(app => {
          return {
            ...app,
            iconUintArr: Array.isArray(app.iconUintArr) ? new Uint8Array(app.iconUintArr) : app.iconUintArr
          } as AppInfo
        });

      const acceptSet = new Set<string>()
      acceptEntries.forEach(e => acceptSet.add(e.key.substring(7)))
      const rejectSet = new Set<string>()
      rejectEntries.forEach(e => rejectSet.add(e.key.substring(7)))

      hilog.info(0x0000, TAG, `#migrateFromOldStorage 迁移准备: app总数 = ${cleanApps.length}, accept = ${acceptSet.size}, reject = ${rejectSet.size}`)

      // 批量插入
      this.beginTransaction()
      try {
        for (const app of cleanApps) {
          const pkg = app.package_name
          let inserted = false

          if (acceptSet.has(pkg)) {
            await this.saveOrMergeApp({
              package_name: pkg,
              list_type: ListType.WHITE_SELECTED,
              app_name: app.name,
              icon_blob: app.iconUintArr,
              create_time: app.time
            })
            inserted = true
          }

          if (rejectSet.has(pkg)) {
            await this.saveOrMergeApp({
              package_name: pkg,
              list_type: ListType.BLACK_SELECTED,
              app_name: app.name,
              icon_blob: app.iconUintArr,
              create_time: app.time
            })
            inserted = true
          }

          // 如果既不在白也不在黑，归入当前模式的未选中，防止应用列表消失
          if (!inserted) {
            await this.saveOrMergeApp({
              package_name: pkg,
              list_type: listType,
              app_name: app.name,
              icon_blob: app.iconUintArr,
              create_time: app.time
            })
          }
        }
        this.commitTransaction()
        hilog.info(0x0000, TAG, '#migrateFromOldStorage 旧数据迁移完成')
      } catch (e) {
        const errorMsg = e instanceof Error ? e.message : JSON.stringify(e)
        hilog.error(0x0000, TAG, `#migrateFromOldStorage 迁移事务执行失败: ${errorMsg}`)
        // 打印堆栈以便追踪具体是哪一行出错
        if (e instanceof Error) {
          console.error(e.stack)
        }
        this.rollBackTransaction()
        throw e
      }
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : JSON.stringify(error)
      hilog.error(0x0000, TAG, `#migrateFromOldStorage 迁移失败: ${errorMsg}`)
    }
  }

  /**
   * 搜索应用 (在指定域内搜索)
   * @param keyword 搜索关键词
   * @param domain 目标域 ('WHITE' | 'BLACK')
   * @param sortBy 排序字段
   * @returns 匹配的应用列表
   */
  async searchApps(keyword: string, domain: 'WHITE' | 'BLACK', sortBy: 'name' | 'time' = 'time'): Promise<AppInfo[]> {
    this.ensureInitialized()
    if (!keyword.trim()) return this.getAppsByDomain(domain, sortBy)

    const predicates = new relationalStore.RdbPredicates('access_control_apps')
      .beginWrap()
      .contains('app_name', keyword)
      .or()
      .contains('package_name', keyword)
      .endWrap()

    // 限制域
    if (domain === 'WHITE') {
      predicates.in('list_type', [ListType.WHITE_SELECTED, ListType.WHITE_UNSELECTED])
    } else {
      predicates.in('list_type', [ListType.BLACK_SELECTED, ListType.BLACK_UNSELECTED])
    }

    // 主排序：按选中状态排
    predicates.orderByAsc('list_type')
    // 次排序：按名称或时间排
    if (sortBy === 'name') {
      predicates.orderByAsc('app_name')
    } else {
      predicates.orderByDesc('create_time')
    }

    const resultSet = await this.rdbStore!.query(predicates)
    const apps = this.parseResultSetToUIList(resultSet)
    resultSet.close()
    return apps
  }

  /**
   * 更新应用的基础信息（名称、包名、图标、时间）
   * 会同步更新该应用在黑白名单中的所有记录
   * @param oldPackageName 原包名（主键的一部分）
   * @param newInfo 新的应用信息
   */
  async updateAppBasicInfo(oldPackageName: string, newInfo: AppInfo): Promise<void> {
    this.ensureInitialized()
    // 获取旧包名的所有记录（可能在白名单也可能在黑名单）
    const oldApps = await this.getAppsByPackageName(oldPackageName)
    if (oldApps.length === 0) {
      hilog.warn(0x0000, TAG, `更新失败：未找到包名为 ${oldPackageName} 的应用`)
      return
    }
    // 开启事务，先删后加（因为包名是主键的一部分，修改包名相当于删除旧记录插入新记录）
    this.beginTransaction()
    try {
      // 删除旧记录
      await this.deleteAppCompletely(oldPackageName)
      // 插入新记录（保留原有的 list_type 状态）
      for (const oldApp of oldApps) {
        await this.insertOrReplaceApp({
          package_name: newInfo.package_name,
          list_type: oldApp.list_type, // 保持原有的黑白名单状态
          app_name: newInfo.name,
          icon_blob: newInfo.iconUintArr,
          create_time: newInfo.time
        })
      }
      this.commitTransaction()
      hilog.info(0x0000, TAG, `应用信息更新成功: ${oldPackageName} -> ${newInfo.package_name}`)
    } catch (e) {
      this.rollBackTransaction()
      hilog.error(0x0000, TAG, `应用信息更新失败: ${JSON.stringify(e)}`)
      throw e
    }
  }

  /**
   * 批量删除指定域的应用
   * @param packageNames 包名数组
   * @param domain 域 ('WHITE' | 'BLACK')
   * @returns 删除的行数
   */
  async batchRemoveFromDomain(packageNames: string[], domain: 'WHITE' | 'BLACK'): Promise<number> {
    this.ensureInitialized()
    if (packageNames.length === 0) return 0

    // 确定要删除的 list_type 范围
    const typesToDelete = (domain === 'WHITE')
      ? [ListType.WHITE_SELECTED, ListType.WHITE_UNSELECTED]
      : [ListType.BLACK_SELECTED, ListType.BLACK_UNSELECTED]

    // 构建批量删除谓词：package_name IN (...) AND list_type IN (...)
    const predicates = new relationalStore.RdbPredicates('access_control_apps')
      .in('package_name', packageNames)
      .in('list_type', typesToDelete)

    // 执行一次删除操作
    return await this.rdbStore!.delete(predicates)
  }

  /**
   * 批量设置选中状态
   * @param packageNames 包名数组
   * @param domain 域 ('WHITE' | 'BLACK')
   * @param isSelected 目标选中状态
   * @param sortBy 优先级排序 ('name' | 'time')，当选中数量超限时，按此顺序优先选中
   * @returns 实际被改变的包名列表
   */
  async batchToggleSelection(
    packageNames: string[],
    domain: 'WHITE' | 'BLACK',
    isSelected: boolean,
    sortBy: 'name' | 'time' = 'time'
  ): Promise<string[]> {
    this.ensureInitialized()
    if (packageNames.length === 0) return []
    // 确定源类型（当前状态）和目标类型
    const currentTypes = (domain === 'WHITE')
      ? (isSelected ? [ListType.WHITE_UNSELECTED] : [ListType.WHITE_SELECTED])
      : (isSelected ? [ListType.BLACK_UNSELECTED] : [ListType.BLACK_SELECTED])

    const targetType = (domain === 'WHITE')
      ? (isSelected ? ListType.WHITE_SELECTED : ListType.WHITE_UNSELECTED)
      : (isSelected ? ListType.BLACK_SELECTED : ListType.BLACK_UNSELECTED)
    // --- 执行选中操作 (需要检查限额) ---
    if (isSelected) {
      const maxLimit = (domain === 'WHITE') ? 254 : 256
      // 查询当前已选中的数量
      const currentPred = new relationalStore.RdbPredicates('access_control_apps')
        .equalTo('list_type', targetType)
      const currentRs = await this.rdbStore!.query(currentPred)
      const currentCount = currentRs.rowCount
      currentRs.close()
      // 计算剩余名额
      const remainingSlots = maxLimit - currentCount
      if (remainingSlots <= 0) {
        return [] // 没有空位，返回空列表
      }
      // 查询符合条件的应用并按优先级排序
      const candidatePred = new relationalStore.RdbPredicates('access_control_apps')
        .in('package_name', packageNames)
        .in('list_type', currentTypes)
      if (sortBy === 'name') {
        candidatePred.orderByAsc('app_name')
      } else {
        candidatePred.orderByDesc('create_time')
      }
      const candidateRs = await this.rdbStore!.query(candidatePred)
      // 筛选并截取前 N 个包名
      const actualPackages: string[] = []
      while (candidateRs.goToNextRow()) {
        if (actualPackages.length >= remainingSlots) break
        const pkg = candidateRs.getString(candidateRs.getColumnIndex('package_name'))
        actualPackages.push(pkg)
      }
      candidateRs.close()
      // 执行更新
      if (actualPackages.length > 0) {
        const updatePred = new relationalStore.RdbPredicates('access_control_apps')
          .in('package_name', actualPackages)
          .in('list_type', currentTypes)
        const valueBucket: relationalStore.ValuesBucket = { list_type: targetType }
        await this.rdbStore!.update(valueBucket, updatePred)
      }
      return actualPackages // 返回实际被选中的包名
    }
    // --- 执行取消选中操作 (无限制，但需精确返回实际发生改变的) ---
    // 为了确保返回准确，先查询哪些包名当前是“已选中”状态
    const targetPred = new relationalStore.RdbPredicates('access_control_apps')
      .in('package_name', packageNames)
      .in('list_type', currentTypes) // currentTypes 在这里是 SELECTED 状态
    const targetRs = await this.rdbStore!.query(targetPred)
    const actualToUnselect: string[] = []
    while (targetRs.goToNextRow()) {
      actualToUnselect.push(targetRs.getString(targetRs.getColumnIndex('package_name')))
    }
    targetRs.close()
    if (actualToUnselect.length > 0) {
      const updatePred = new relationalStore.RdbPredicates('access_control_apps')
        .in('package_name', actualToUnselect)
        .in('list_type', currentTypes)
      const valueBucket: relationalStore.ValuesBucket = { list_type: targetType }
      await this.rdbStore!.update(valueBucket, updatePred)
    }
    return actualToUnselect // 返回实际被取消选中的包名
  }


  private async insertOrReplaceApp(info: AppInfoRdb): Promise<number> {
    const valueBucket: relationalStore.ValuesBucket = {
      package_name: info.package_name,
      list_type: info.list_type,
      app_name: info.app_name,
      icon_blob: info.icon_blob,
      create_time: info.create_time
    }
    return await this.rdbStore!.insert('access_control_apps', valueBucket, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE)
  }

  /**
   * 保存或合并应用配置
   * 如果包名已存在 -> 更新配置 (list_type, app_name, create_time)，保留原有图标 (icon_blob)
   * 如果包名不存在 -> 插入新记录
   */
  private async saveOrMergeApp(value: AppInfoRdb): Promise<number> {
    const tableName = 'access_control_apps'
    // 查询该包名是否已存在
    const pred = new relationalStore.RdbPredicates(tableName)
    pred.equalTo('package_name', value.package_name)
    const resultSet = await this.rdbStore.query(pred)
    let rowCount = 0

    if (resultSet.rowCount > 0) {
      // 数据已存在 -> 执行部分更新
      // 准备更新桶：只更新列表类型、名字、时间
      const updateBucket: relationalStore.ValuesBucket = {
        list_type: value.list_type,
        app_name: value.app_name,
        create_time: value.create_time
      }
      // 只有当导入的数据里有图标时，才更新图标字段
      // 如果导入的 icon_blob 是空的，updateBucket 里就不包含 icon_blob
      if (value.icon_blob && value.icon_blob.length > 0) {
        updateBucket.icon_blob = value.icon_blob
      }

      rowCount = await this.rdbStore.update(updateBucket, pred)
      hilog.debug(0x0000, TAG, `#saveOrMergeApp 更新已存在的应用: ${value.package_name}`)
    } else {
      // 数据不存在 -> 直接插入
      const valueBucket: relationalStore.ValuesBucket = {
        package_name: value.package_name,
        list_type: value.list_type,
        app_name: value.app_name,
        icon_blob: value.icon_blob,
        create_time: value.create_time
      }
      rowCount = await this.rdbStore.insert(tableName, valueBucket)
      hilog.debug(0x0000, TAG, `#saveOrMergeApp 插入新应用: ${value.package_name}`)
    }

    // 记得关闭查询结果集
    resultSet.close()
    return rowCount
  }

  private async getAppsByPackageName(packageName: string): Promise<AppInfoRdb[]> {
    const predicates = new relationalStore.RdbPredicates('access_control_apps')
      .equalTo('package_name', packageName)
    const resultSet = await this.rdbStore!.query(predicates)
    const apps: AppInfoRdb[] = []

    while (resultSet.goToNextRow()) {
      apps.push({
        package_name: resultSet.getString(resultSet.getColumnIndex('package_name')),
        list_type: resultSet.getLong(resultSet.getColumnIndex('list_type')),
        app_name: resultSet.getString(resultSet.getColumnIndex('app_name')),
        icon_blob: resultSet.getBlob(resultSet.getColumnIndex('icon_blob')),
        create_time: resultSet.getLong(resultSet.getColumnIndex('create_time'))
      })
    }
    resultSet.close()
    return apps
  }

  private parseResultSetToUIList(resultSet: relationalStore.ResultSet): AppInfo[] {
    const apps: AppInfo[] = []
    const typeIdx = resultSet.getColumnIndex('list_type')

    while (resultSet.goToNextRow()) {
      const listType = resultSet.getLong(typeIdx)
      const isSelected = (listType === ListType.WHITE_SELECTED || listType === ListType.BLACK_SELECTED)

      apps.push({
        name: resultSet.getString(resultSet.getColumnIndex('app_name')),
        package_name: resultSet.getString(resultSet.getColumnIndex('package_name')),
        time: resultSet.getLong(resultSet.getColumnIndex('create_time')),
        iconUintArr: resultSet.getBlob(resultSet.getColumnIndex('icon_blob')),
        isSelected: isSelected
      })
    }
    return apps
  }

  private beginTransaction(): void { this.rdbStore?.beginTransaction() }
  private commitTransaction(): void { this.rdbStore?.commit() }
  private rollBackTransaction(): void { this.rdbStore?.rollBack() }
  private ensureInitialized(): void {
    if (!this.rdbStore) throw new Error('RdbStore 未初始化')
  }

  /**
   * 关闭数据库连接
   */
  async close(): Promise<void> {
    if (this.rdbStore) {
      await this.rdbStore.close()
      this.rdbStore = null
    }
  }

}

export const accessControlRdb = AccessControlRdb.getInstance()
