

/**
 * 通过指定索引来删除数组中指定元素
 * @param array 原数组 - T [ ]
 * @param indicesToRemove 指定的要删除的索引数组-number[]
 * @returns 删除后的数组 - T [ ]
 */
export function removeItemsByIndex<T>(array: T[], indicesToRemove: number[]): T[] {
  // 对索引进行排序，确保从大到小删除，防止删除元素后索引变化
  indicesToRemove.sort((a, b) => b - a)
  // 删除指定索引的元素
  indicesToRemove.forEach(index => {
    if (index >= 0 && index < array.length) {
      array.splice(index, 1)
    }
  })
  return array
}