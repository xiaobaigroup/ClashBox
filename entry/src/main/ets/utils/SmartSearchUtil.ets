
interface Option {
  fields?: string[];
  strictCase?: boolean;
  matchMode?: 'all' | 'any';
}

/**
 * 安全获取嵌套字段值
 * @param obj 目标对象
 * @param path 字段路径（如 'user.profile.name'）
 * @returns 字段值的字符串表示
 */
function getFieldValue<T>(obj: T, path: string): string {
  let current: T = obj;

  for (const key of path.split('.')) {
    if (typeof current !== 'object' || current === null) return '';
    current = (current as Record<string, T>)[key];
  }

  return String(current ?? '');
}

/**
 * 通用智能搜索函数
 * @param data 待搜索的数组（任意对象类型）
 * @param input 搜索输入（关键词或正则表达式）
 * @param options 配置项：
 *   - fields: 要搜索的字段路径（默认 [''] 表示直接搜索对象本身）
 *   - strictCase: 是否区分大小写（默认 false）
 *   - matchMode: 'all' 需匹配所有关键词 | 'any' 匹配任一关键词（默认 'all'）
 */
function universalSearch<T>(
  data: T[],
  input: string,
  options: Option = {}
): T[] {

  const fields = options.fields ?? ['']
  const strictCase = options.strictCase ?? false
  const matchMode = options.matchMode ?? 'all'

  if (!input.trim()) return data;

  // 输入预处理
  const isRegex = input.startsWith('/') && input.endsWith('/') && input.length > 2;

  try {
    if (isRegex) {
      // 正则模式
      const pattern = input.slice(1, -1);
      const regex = new RegExp(pattern, strictCase ? '' : 'i');

      return data.filter(item =>
      fields.some(field => regex.test(getFieldValue(item, field)))
      );
    } else {
      // 关键词模式
      const keywords = input
        .split(/\s+/)
        .map(k => strictCase ? k : k.toLowerCase())
        .filter(k => k);

      return data.filter(item => {
        const matchFn = (keyword: string) =>
        fields.some(field => {
          const value = getFieldValue(item, field);
          const searchValue = strictCase ? value : value.toLowerCase();
          return searchValue.includes(keyword);
        });

        return matchMode === 'all'
          ? keywords.every(matchFn)
          : keywords.some(matchFn);
      });
    }
  } catch (e) {
    console.error('搜索失败:', e);
    return [];
  }
}