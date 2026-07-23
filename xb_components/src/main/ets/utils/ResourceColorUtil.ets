import { common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit';


/**
 * ResourceColor转换为string格式
 * @param color ResourceColor
 * @param context common.Context
 *
 * @returns 输出 #AARRGGBB
 */
export function Xb_ResourceColorUtil(color: ResourceColor, context: common.Context) {
  let decimal: number = 0
  if (!color) {
    return ""
  } else
  if (typeof color == "string") {
    return color
  } else
  if (typeof color == "number") {
    decimal = color
  } else
  if (color.id) {
    try {
      decimal = context.resourceManager.getColorSync(color.id)
    } catch (error) {
      let code = (error as BusinessError).code;
      let message = (error as BusinessError).message;
      console.error(`getColorSync failed, error code: ${code}, message: ${message}.`);
      return ""
    }
  } else {
    return ""
  }
  const a = (decimal >> 24) & 0xFF // 透明度
  const r = (decimal >> 16) & 0xFF
  const g = (decimal >> 8) & 0xFF
  const b = decimal & 0xFF
  const toHex = (c: number) => c.toString(16).padStart(2, '0')
  return `#${toHex(a)}${toHex(r)}${toHex(g)}${toHex(b)}`
}