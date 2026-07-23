import { util } from "@kit.ArkTS"

interface Unit {
  TB: number
  GB: number
  MB: number
  KB: number
  B: number
}

class DataSwitch {

  // 根据不同的单位转换数据
  ConvertData(value: number, unit: keyof Unit){
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

  // 根据不同流量单位转换数据
  ConvertTraffic(value: number, unit: string){
    switch (unit) {
      case 'Kbps':
        return value * 8;
      case 'KB/s':
        return value ;
      default:
        throw new Error(`Unsupported unit: ${unit}`);
    }
  }

  // --- Base64 ---
  // 工具链接：https://developer.huawei.com/consumer/cn/blog/topic/03189343128566020
  /**
   * 创建 Base64Helper 实例
   * @returns Base64Helper 实例
   */
  private static createBase64Helper(): util.Base64Helper {
    return new util.Base64Helper();
  }

  /**
   * 编码为 Uint8Array（异步）
   * @param array 输入的 Uint8Array 数据
   * @returns 编码后的 Uint8Array 对象
   */
  static encode(array: Uint8Array): Promise<Uint8Array> {
    const base64 = DataSwitch.createBase64Helper();
    return base64.encode(array);
  }

  /**
   * 编码为 Uint8Array（同步）
   * @param array 输入的 Uint8Array 数据
   * @returns 编码后的 Uint8Array 对象
   */
  static encodeSync(array: Uint8Array): Uint8Array {
    const base64 = DataSwitch.createBase64Helper();
    return base64.encodeSync(array);
  }

  /**
   * 编码为字符串（异步）
   * @param array 输入的 Uint8Array 数据
   * @param options 可选参数
   * @returns 编码后的字符串
   */
  static encodeToStr(array: Uint8Array, options?: util.Type): Promise<string> {
    const base64 = DataSwitch.createBase64Helper();
    return base64.encodeToString(array, options);
  }

  /**
   * 编码为字符串（同步）
   * @param array 输入的 Uint8Array 数据
   * @param options 可选参数
   * @returns 编码后的字符串
   */
  static encodeToStrSync(array: Uint8Array, options?: util.Type): string {
    const base64 = DataSwitch.createBase64Helper();
    return base64.encodeToStringSync(array, options);
  }

  /**
   * 解码为 Uint8Array（异步）
   * @param input 输入的 Uint8Array 或字符串
   * @param options 可选参数
   * @returns 解码后的 Uint8Array 对象
   */
  static decode(input: Uint8Array | string, options?: util.Type): Promise<Uint8Array> {
    const base64 = DataSwitch.createBase64Helper();
    return base64.decode(input, options);
  }

  /**
   * 解码为 Uint8Array（同步）
   * @param input 输入的 Uint8Array 或字符串
   * @param options 可选参数
   * @returns 解码后的 Uint8Array 对象
   */
  static decodeSync(input: Uint8Array | string, options?: util.Type): Uint8Array {
    const base64 = DataSwitch.createBase64Helper();
    return base64.decodeSync(input, options);
  }

}

export const Xb_DataSwitch: DataSwitch = new DataSwitch()
