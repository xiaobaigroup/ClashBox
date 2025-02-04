interface GeneratedUnitInterface {
  TB: number
  GB: number
  MB: number
  KB: number
}

const conversionFactors: GeneratedUnitInterface = {
  TB: 1024 ** 4,
  GB: 1024 ** 3,
  MB: 1024 ** 2,
  KB: 1024,
}

/**
 * 转换数值（Number数组）（0 ~ 1024）
 */
export function convertDataArray(bNumber: number[]): number[]  {

  const convertedNumber: number[] = bNumber.map(b => {
    if (b >= conversionFactors.TB) {
      return b / conversionFactors.TB
    } else if (b >= conversionFactors.GB) {
      return b / conversionFactors.GB
    } else if (b >= conversionFactors.MB) {
      return b / conversionFactors.MB
    } else {
      // 如果小于1KB，则保持为B
      return b
    }
  })
  return convertedNumber
}

/**
 * 转换数值（Number）（0 ~ 1024）
 */
export function convertDataNumber(bNumber: number, conversionFactors: GeneratedUnitInterface): number {

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
