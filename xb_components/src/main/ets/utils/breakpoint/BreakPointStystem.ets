// 一维断点管理系统

// 断点类型
type WidthBreakpoint = 'sm' | 'md' | 'lg' | 'xl'

// 顺序映射
const WIDTH_BP_ORDER: WidthBreakpoint[] = ['sm', 'md', 'lg', 'xl']

// 配置类型
type BreakpointConfig<T> = Record<WidthBreakpoint, T>


/**函数方案一维断点系统*/
export function Xb_BreakpointFunction<T>(config: BreakpointConfig<T>) {
  // 预先计算所有可能的组合
  const Value: T[] = []

  for (let widthIdx = 0; widthIdx < WIDTH_BP_ORDER.length; widthIdx++) {
    const widthKey = WIDTH_BP_ORDER[widthIdx]

    Value.push(config[widthKey])
  }

  // 返回可直接访问数组的函数
  return (widthBp: number): T => {

    const widthIndex = Math.min(
      Math.max(widthBp - 1, 0),
      WIDTH_BP_ORDER.length - 1
    )

    return Value[widthIndex]
  }
}

// 使用示例
// export const getOneFontSize = BreakpointFunction<number>({
//   ['sm']: 14, ['md']: 15, ['lg']: 16, ['xl']: 17
// })