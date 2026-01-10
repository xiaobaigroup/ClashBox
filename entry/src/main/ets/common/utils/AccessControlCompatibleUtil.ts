
import { distributedKVStore } from "@kit.ArkData";

/**
 * 访问控制列表兼容合并工具类
 */
export class AccessControlCompatibleMerger {

  /**
   * 解析导入的访问控制列表数据，兼容新旧格式
   * @param listString 从配置文件中读取的列表字符串
   * @param prefix 列表的前缀 (如 'accept_' 或 'reject_')
   * @returns 包含包名的 Set
   */
  public static parseImportedListData(listString: string | undefined, prefix: string): Set<string> {
    if (!listString || listString.trim() === '') {
      return new Set<string>();
    }
    try {
      const parsed = JSON.parse(listString);
      if (!Array.isArray(parsed) || parsed.length === 0) {
        return new Set<string>();
      }
      // 检查是否为新版格式 (键值对数组)
      if (typeof parsed[0] === 'object' && parsed[0] !== null && 'key' in parsed[0]) {
        const entries = parsed as Array<{ key: string, value: string }>;
        return new Set(entries.map(entry => entry.key.substring(prefix.length)));
      }
      // 否则为旧版格式 (包名数组)
      else if (typeof parsed[0] === 'string') {
        const packageNames = parsed as string[];
        return new Set(packageNames);
      }
    } catch (e) {
      console.error(`AccessControlMerger: 解析导入列表数据失败: ${listString}`, e);
    }
    return new Set<string>();
  }

  /**
   * 计算并构造合并所需的最终数据结构
   * @param currentAcceptSet 当前白名单的包名集合
   * @param currentRejectSet 当前黑名单的包名集合
   * @param importedAcceptList 从配置文件中解析出的白名单字符串
   * @param importedRejectList 从配置文件中解析出的黑名单字符串
   * @returns 包含需要删除的键和需要添加的完整Entry的对象
   */
  public static calculateMergeDifferences(
    currentAcceptSet: Set<string>,
    currentRejectSet: Set<string>,
    importedAcceptList: string,
    importedRejectList: string
  ): {
    keysToDelete: string[],
    entriesToAdd: distributedKVStore.Entry[]
  } {
    // 解析导入列表
    const importedAcceptSet = AccessControlCompatibleMerger.parseImportedListData(importedAcceptList, 'accept_');
    const importedRejectSet = AccessControlCompatibleMerger.parseImportedListData(importedRejectList, 'reject_');

    // 计算最终状态
    const finalAcceptSet = new Set([...currentAcceptSet].filter(pkg => !importedRejectSet.has(pkg)));
    for (const pkg of importedAcceptSet) finalAcceptSet.add(pkg);

    const finalRejectSet = new Set([...currentRejectSet].filter(pkg => !importedAcceptSet.has(pkg)));
    for (const pkg of importedRejectSet) finalRejectSet.add(pkg);

    // 计算需要删除的键
    const toDeleteFromAccept = [...currentAcceptSet].filter(pkg => !finalAcceptSet.has(pkg));
    const toDeleteFromReject = [...currentRejectSet].filter(pkg => !finalRejectSet.has(pkg));
    const keysToDelete = [
      ...toDeleteFromAccept.map(pkg => `accept_${pkg}`),
      ...toDeleteFromReject.map(pkg => `reject_${pkg}`)
    ];

    // 构造需要添加的完整 distributedKVStore.Entry 对象
    const toAddToAccept = [...finalAcceptSet].filter(pkg => !currentAcceptSet.has(pkg));
    const toAddToReject = [...finalRejectSet].filter(pkg => !currentRejectSet.has(pkg));
    const entriesToAdd: distributedKVStore.Entry[] = [
      ...toAddToAccept.map(pkg => ({
        key: `accept_${pkg}`,
        value: { type: distributedKVStore.ValueType.STRING, value: pkg }
      })),
      ...toAddToReject.map(pkg => ({
        key: `reject_${pkg}`,
        value: { type: distributedKVStore.ValueType.STRING, value: pkg }
      }))
    ];

    return { keysToDelete, entriesToAdd };
  }
}
