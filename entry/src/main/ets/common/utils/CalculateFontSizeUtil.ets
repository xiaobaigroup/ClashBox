
/**根据字符数设置字符大小*/
export function calculateFontSizeLinear(
  str: string,
  minSize = 20,
  maxSize = 33,
  step = 1
): number {
  const length = str.length;
  const maxAllowedLength = Math.floor((maxSize - minSize) / step);
  const clampedLength = Math.min(length, maxAllowedLength);
  return Math.max(minSize, maxSize - clampedLength * step);
}