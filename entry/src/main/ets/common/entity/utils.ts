/**
 * json数组类型
 */
export type JsonArrayType = 'boolean' | 'string' | 'undefined';

/**
 * 判断一个JSON字符串是boolean数组还是string数组
 * @param jsonStr 待判断的JSON字符串
 * @returns 返回 'boolean', 'string' 或 'undefined'
 */
export function getJsonArrayType(jsonStr: string): JsonArrayType {
  try {
    // 尝试解析JSON字符串
    const parsedValue = JSON.parse(jsonStr);
    // 检查解析结果是否为一个非空数组
    if (!Array.isArray(parsedValue) || parsedValue.length === 0) {
      return 'undefined';
    }
    const arr = parsedValue as any[]; // 类型断言，因为我们已经确认它是一个数组
    // 检查数组中的所有元素是否都是布尔类型
    // Array.prototype.every() 方法测试一个数组内的所有元素是否都能通过某个指定函数的测试
    const isAllBooleans = arr.every(item => typeof item === 'boolean');
    if (isAllBooleans) {
      return 'boolean';
    }
    // 检查数组中的所有元素是否都是字符串类型
    const isAllStrings = arr.every(item => typeof item === 'string');
    if (isAllStrings) {
      return 'string';
    }
    // 如果既不是全布尔，也不是全字符串（例如混合类型 [true, "a"]），则返回 'undefined'
    return 'undefined';
  } catch (error) {
    // 如果JSON.parse失败，说明它不是一个有效的JSON字符串
    return 'undefined';
  }
}
