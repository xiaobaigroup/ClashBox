
interface GeneratedUnitInterface {
  TB: number
  GB: number
  MB: number
  KB: number
}

interface ConvertedUnit {
  value: number;
  unit: 'TB' | 'GB' | 'MB' | 'KB' | 'B';
}

const conversionFactors: GeneratedUnitInterface = {
  TB: 1024 ** 4,
  GB: 1024 ** 3,
  MB: 1024 ** 2,
  KB: 1024,
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
    default:
      throw new Error(`Unsupported unit: ${unit}`);
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