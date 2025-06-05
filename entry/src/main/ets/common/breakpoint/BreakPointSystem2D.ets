
// 断点类型
type WidthBreakpoint = 'sm' | 'md' | 'lg' | 'xl';
type HeightBreakpoint = 'hsm' | 'hmd' | 'hlg';

// 顺序映射
const WIDTH_BP_ORDER: WidthBreakpoint[] = ['sm', 'md', 'lg', 'xl'];
const HEIGHT_BP_ORDER: HeightBreakpoint[] = ['hsm', 'hmd', 'hlg'];

// 配置类型
type WidthConfig<T> = Record<HeightBreakpoint, T> // hsm, hmd, hlg 对应的值
type BreakpointConfig<T> = Record<WidthBreakpoint, WidthConfig<T>>

/**实例方案断点系统*/
export class BreakpointType2D<T> {
  private config: BreakpointConfig<T>

  constructor(
    config: BreakpointConfig<T>
  ) {
    this.config = config
  }

  getValue(widthBp: number, heightBp: number): T {
    // 获取宽度断点
    const widthKey = WIDTH_BP_ORDER[
    Math.min(Math.max(widthBp - 1, 0), WIDTH_BP_ORDER.length - 1)
    ] ?? 'sm';

    // 获取高度断点
    const heightKey = HEIGHT_BP_ORDER[
    Math.min(Math.max(heightBp, 0), HEIGHT_BP_ORDER.length - 1)
    ] ?? 'hsm';

    return this.config[widthKey][heightKey]
  }

}



// 实例方案使用示例
export const FontSize = new BreakpointType2D({
  ['sm']: {['hsm']: 14, ['hmd']: 15, ['hlg']: 16},
  ['md']: {['hsm']: 17, ['hmd']: 18, ['hlg']: 19},
  ['lg']: {['hsm']: 20, ['hmd']: 21, ['hlg']: 22},
  ['xl']: {['hsm']: 23, ['hmd']: 24, ['hlg']: 25},
})

// FontSize.getValue(this.widthBp, this.heightBp)



/**函数方案断点系统*/
export function BreakpointFunction2D<T>(config: BreakpointConfig<T>) {

  const valueMatrix: T[][] = []

  for (let widthIdx = 0; widthIdx < WIDTH_BP_ORDER.length; widthIdx++) {
    const widthKey = WIDTH_BP_ORDER[widthIdx]
    const row: T[] = []

    for (let heightIdx = 0; heightIdx < HEIGHT_BP_ORDER.length; heightIdx++) {
      const heightKey = HEIGHT_BP_ORDER[heightIdx]
      row.push(config[widthKey][heightKey])
    }

    valueMatrix.push(row)
  }

  // 返回可直接访问矩阵的函数
  return (widthBp: number, heightBp: number): T => {
    const widthIndex = Math.min(
      Math.max(widthBp - 1, 0),
      WIDTH_BP_ORDER.length - 1
    )

    const heightIndex = Math.min(
      Math.max(heightBp, 0),
      HEIGHT_BP_ORDER.length - 1
    )

    return valueMatrix[widthIndex][heightIndex]
  }
}

// 函数方案使用示例
const getFontSize = BreakpointFunction2D<number>({
    ['sm']: {['hsm']: 14, ['hmd']: 15, ['hlg']: 16},
    ['md']: {['hsm']: 17, ['hmd']: 18, ['hlg']: 19},
    ['lg']: {['hsm']: 20, ['hmd']: 21, ['hlg']: 22},
    ['xl']: {['hsm']: 23, ['hmd']: 24, ['hlg']: 25},
  })

// getFontSize(this.widthBp, this.heightBp)




