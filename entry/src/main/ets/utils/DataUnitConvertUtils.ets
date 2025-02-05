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
 * 将给定的数值从指定的大单位转换为GB
 * @param value - 要转换的数值
 * @param unit - 单位（'TB'、'GB'、'MB'、'KB'）
 * @returns 转换后的GB数值
 */
export function convertToGB(value: number, unit: keyof GeneratedUnitInterface): number {
  switch (unit) {
    case 'TB':
      return value / 1024**3;
    case 'GB':
      return value / 1024**3;
    case 'MB':
      return value / 1024**2;
    case 'KB':
      return value / 1024;
    default:
      throw new Error(`Unsupported unit: ${unit}`);
  }
}

