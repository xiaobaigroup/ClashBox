
interface ID { id: number | null }

/**
 * 根据id值更新数组
 *
 */
export async function Xb_BatchUpsert<T extends ID>(
  targetArray: T[],
  newItems: T[]
): Promise<T[]> {
  // 合并两个数组（新数组在后，确保新项优先）
  const merged = [...targetArray, ...newItems];

  // 使用 Map 根据唯一键去重
  const uniqueMap = new Map<string, T>();

  merged.forEach(item => {
    // 使用 id 作为唯一键
    const key = String(item.id);
    uniqueMap.set(key, item);
  });

  // 将 Map 的值转回数组
  return Array.from(uniqueMap.values());
}