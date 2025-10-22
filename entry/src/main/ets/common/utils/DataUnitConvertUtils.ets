
interface GeneratedUnitInterface {
  TB: number
  GB: number
  MB: number
  KB: number
  B: number
}

export interface ConvertedUnit {
  value: number;
  unit: 'TB' | 'GB' | 'MB' | 'KB' | 'B';
}

export interface NormalizedDataResult {
  normalizedData: number[];
  maxValue: number;
}

const conversionFactors: GeneratedUnitInterface = {
  TB: 1024 ** 4,
  GB: 1024 ** 3,
  MB: 1024 ** 2,
  KB: 1024,
  B: 1,
}

/**
 * 将给定的数值数组从字节转换为对应的单位（Number[]）（0 ~ 1024）
 * @param bNumber - 要转换的数值数组(单位：字节)
 * @returns 转换后的对应单位数值数组
 */
export function convertDataArray(bNumber: number[]): ConvertedUnit[] {
  const convertedNumber: ConvertedUnit[] = bNumber.map((b): ConvertedUnit => {
    if (b >= conversionFactors.TB) {
      return { value: b / conversionFactors.TB, unit: 'TB' }
    } else if (b >= conversionFactors.GB) {
      return { value: b / conversionFactors.GB, unit: 'GB' }
    } else if (b >= conversionFactors.MB) {
      return { value: b / conversionFactors.MB, unit: 'MB' }
    } else if (b >= conversionFactors.KB) {
      return { value: b / conversionFactors.KB, unit: 'KB' }
    } else {
      // 如果小于1KB，则保持为B
      return { value: b, unit: 'B' }
    }
  })
  return convertedNumber
}

/**
 * 将给定的数值从字节转换为对应的单位（Number）（0 ~ 1024）
 * @param bNumber - 要转换的数值(单位：字节)
 * @returns 转换后的对应单位数值
 */
export function convertDataNumber(bNumber: number): number {

  if (bNumber >= conversionFactors.TB) {
    return bNumber / conversionFactors.TB;
  } else if (bNumber >= conversionFactors.GB) {
    return bNumber / conversionFactors.GB;
  } else if (bNumber >= conversionFactors.MB) {
    return bNumber / conversionFactors.MB;
  } else if (bNumber >= conversionFactors.KB) {
    return bNumber / conversionFactors.KB;
  } else {
    // 如果小于1KB，则保持为B
    return bNumber;
  }
}

/**
 * 将B单位数值转换为选择的单位值
 * @param value - 要转换的数值
 * @param unit - 单位（'TB'、'GB'、'MB'、'KB'）
 */
export function convertToSwitchNub(value: number, unit: keyof GeneratedUnitInterface): number {
  switch (unit) {
    case 'TB':
      return value / Math.pow(1024, 4);
    case 'GB':
      return value / Math.pow(1024, 3);
    case 'MB':
      return value / Math.pow(1024, 2);
    case 'KB':
      return value / Math.pow(1024, 1);
    case 'B':
      return value;
    default:
      throw new Error(`Unsupported unit: ${unit}`);
  }
}

/**
 * 将B单位数值转换为选择的单位值
 * @param value - 要转换的数值
 * @param unit - 单位（'TB'、'GB'、'MB'、'KB'）
 */
export function convertToSwitchNub1(value: number, unitT: TrafficUnit,unitU:TrafficUnit): number {
  switch (unitT) {
    case 'TB':
      if (unitU=='GB'){
        return  value / Math.pow(1024, 1)
      }else if (unitU=='MB'){
        return  value / Math.pow(1024, 2)
      }else if(unitU=='KB'){
        return  value / Math.pow(1024, 3)
      }else if(unitU=='B'){
        return  value / Math.pow(1024, 4)
      }else {
        return  value
      } ;
    case 'GB':
      if (unitU=='TB'){
        return  value * Math.pow(1024, 1)
      }else if (unitU=='MB'){
        return  value / Math.pow(1024, 1)
      }else if(unitU=='KB'){
        return  value / Math.pow(1024, 2)
      }else if(unitU=='B'){
        return  value / Math.pow(1024, 3)
      }else {
        return  value
      } ;
    case 'MB':
      if (unitU=='TB'){
        return  value * Math.pow(1024, 2)
      }else if (unitU=='GB'){
        return  value * Math.pow(1024, 1)
      }else if(unitU=='KB'){
        return  value / Math.pow(1024, 1)
      }else if(unitU=='B'){
        return  value / Math.pow(1024, 2)
      }else {
        return  value
      } ;
    case 'KB':
      if (unitU=='TB'){
        return  value * Math.pow(1024, 3)
      }else if (unitU=='GB'){
        return  value * Math.pow(1024, 2)
      }else if(unitU=='MB'){
        return  value * Math.pow(1024, 1)
      }else if(unitU=='B'){
        return  value / Math.pow(1024, 1)
      }else {
        return  value
      } ;
    case 'B':
      if (unitU=='TB'){
        return  value * Math.pow(1024, 3)
      }else if (unitU=='GB'){
        return  value * Math.pow(1024, 2)
      }else if(unitU=='MB'){
        return  value * Math.pow(1024, 1)
      }else if(unitU=='B'){
        return  value / Math.pow(1024, 1)
      }else {
        return  value
      } ;
    default:
      throw new Error(`Unsupported unit: `);
  }
}

/*
根据数值带单位取最大单位整数
 */
export enum TrafficUnit{
  KB = "KB",
  MB = "MB",
  GB = "GB",
  TB = "TB",
  B = "B",
}

export function convertDataNumberT(bNumber: number): string {
  let show: number
  let unit: TrafficUnit
  if (bNumber > Math.pow(1024, 4)) {
    show = (bNumber / Math.pow(1024, 4))
    unit = TrafficUnit.TB
  }else if (bNumber > Math.pow(1024, 3)) {
    show = (bNumber / Math.pow(1024, 3))
    unit = TrafficUnit.GB
  }else if (bNumber > Math.pow(1024, 2)) {
    show = (bNumber / Math.pow(1024, 2))
    unit = TrafficUnit.MB
  }else if (bNumber > Math.pow(1024, 1)) {
    show = (bNumber / Math.pow(1024, 1))
    unit = TrafficUnit.KB
  } else{
    show = bNumber
    unit = TrafficUnit.B
  }
  if(!show)
    return "--"
    // 如果小于1KB，则保持为B
  return (show.toFixed(0)  + " " + unit).toString()
}

/**
 * @description 将带单位的数据数组标准化为统一单位的数字数组
 * 该方法会自动识别数据中的最高单位，并将所有数据统一转换为该单位
 * 
 * @param data - 带单位的数据数组 ConvertedUnit[] 或 number[]
 * @returns 标准化后的数据和最大值
 * 
 * @example
 * // 输入示例：混合单位的流量数据
 * const inputData = [
 *   {"value": 0, "unit": "B"},
 *   {"value": 421.99, "unit": "KB"},
 *   {"value": 3.44, "unit": "MB"},
 *   {"value": 4.46, "unit": "MB"},
 *   {"value": 4.50, "unit": "MB"},
 *   {"value": 4.40, "unit": "MB"},
 *   {"value": 3.99, "unit": "MB"},
 *   {"value": 4.13, "unit": "MB"},
 *   {"value": 4.15, "unit": "MB"},
 *   {"value": 4.57, "unit": "MB"},
 *   {"value": 3.63, "unit": "MB"},
 *   {"value": 238.94, "unit": "KB"}
 * ]
 * 
 * // 输出示例：统一转换为 MB 单位的数值数组
 * const result = normalizeChartData(inputData)
 *  result = {
 *    normalizedData: [0, 0.412, 3.44, 4.46, 4.50, 4.40, 3.99, 4.13, 4.15, 4.57, 3.63, 0.233],
 *    maxValue: 4.57
 *  }
 */
export function normalizeChartData(data: ConvertedUnit[] | number[]): NormalizedDataResult {
  // 如果是纯数字数组，直接返回
  if (typeof data[0] === 'number') {
    const numData = data as number[]
    const result: NormalizedDataResult = {
      normalizedData: numData,
      maxValue: Math.max(...numData)
    }
    return result
  }
  
  const convertedData = data as ConvertedUnit[]
  
  // 单位优先级权重（用于确定基准单位）
  const unitPriority: Record<string, number> = {
    'B': 1,
    'KB': 2,
    'MB': 3,
    'GB': 4,
    'TB': 5
  }
  
  // 找出数据中最高优先级的单位（通常是最大值的单位）
  let targetUnit: keyof GeneratedUnitInterface = 'KB' // 默认使用 KB
  let maxPriority = 0
  
  convertedData.forEach(item => {
    const priority = unitPriority[item.unit] || 0
    if (priority > maxPriority) {
      maxPriority = priority
      targetUnit = item.unit as keyof GeneratedUnitInterface
    }
  })
  
  // 将所有数据转换为目标单位
  const normalizedData = convertedData.map((item): number => {
    // 先转换为字节
    let itemBytes: number = 0
    switch (item.unit) {
      case 'TB':
        itemBytes = item.value * conversionFactors.TB
        break
      case 'GB':
        itemBytes = item.value * conversionFactors.GB
        break
      case 'MB':
        itemBytes = item.value * conversionFactors.MB
        break
      case 'KB':
        itemBytes = item.value * conversionFactors.KB
        break
      case 'B':
        itemBytes = item.value * conversionFactors.B
        break
    }
    
    // 再转换为目标单位
    let targetFactor: number = conversionFactors.KB // 默认
    switch (targetUnit) {
      case 'TB':
        targetFactor = conversionFactors.TB
        break
      case 'GB':
        targetFactor = conversionFactors.GB
        break
      case 'MB':
        targetFactor = conversionFactors.MB
        break
      case 'KB':
        targetFactor = conversionFactors.KB
        break
      case 'B':
        targetFactor = conversionFactors.B
        break
    }
    
    return itemBytes / targetFactor
  })
  
  const maxValue = Math.max(...normalizedData)
  
  const finalResult: NormalizedDataResult = {
    normalizedData,
    maxValue
  }
  return finalResult
}