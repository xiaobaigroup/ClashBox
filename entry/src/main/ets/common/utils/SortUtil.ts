

/**
 * 根据指定的 ID 顺序对对象数组进行排序
 * @param {Array<Object>} arrayToSort 需要排序的对象数组
 * @param {Array<number|string>} idOrder 排序依据的 ID 数组
 * @param {string} idKey 对象中 ID 的键名，默认为 'id'
 * @returns {Array<Object>} 排序后的新数组
 */
export function sortByCustomOrder<T>(
  arrayToSort: T[],
  idOrder: (number | string)[],
  idKey: string = 'id'
): T[] {
  // 创建 Map 以实现快速查找
  // Map 的键类型会自动推断为 number | string，与 idOrder 的元素类型匹配
  const orderMap = new Map(idOrder.map((id, index) => [id, index]));

  // 创建数组副本并排序
  return [...arrayToSort].sort((a, b) => {
    const indexA = orderMap.get(a[idKey]) ?? Infinity;
    const indexB = orderMap.get(b[idKey]) ?? Infinity;

    return indexA - indexB;
  });
}
