

class Color {

  private  context: Context | null = null

  init(context: Context) {
    this.context = context
  }

  /**
   * 获取禁用变灰颜色
   */
  public getUnableColor(color: ResourceColor) {
    return this.getColorWithAlpha(color, 0x33); // 透明度固定为 0x33
  }

  /**
   * 获取一个应用了指定透明度的颜色值
   */
  public getColorWithAlpha(color: ResourceColor, alpha: number): number {
    const baseColor = this.getNormalColor(color);
    const clampedAlpha = Math.max(0, Math.min(255, alpha));
    const rgb = baseColor & 0x00FFFFFF;
    return (clampedAlpha << 24) | rgb;
  }

  /**
   * 将十六进制颜色字符串解析为数字
   * @private
   */
  private parseColorString(colorStr: string): number | null {
    if (colorStr.startsWith('#')) {
      const hex = colorStr.slice(1);
      if (hex.length === 8) { // #AARRGGBB
        return parseInt(hex, 16);
      } else if (hex.length === 6) { // #RRGGBB，默认不透明
        return 0xFF000000 | parseInt(hex, 16);
      }
    }
    return null;
  }

  /**
   * 获取一个应用了指定透明度的颜色值 输出为string
   */
  public getColorWithAlphaString(color: ResourceColor, alpha: number): string {
    const baseColor = this.getNormalColor(color);
    const clampedAlpha = Math.max(0, Math.min(255, alpha));
    // 1. 截取后24位，去掉原本可能存在的透明度
    const rgb = baseColor & 0x00FFFFFF;

    // 2. 拼接成一个新的 32 位颜色数值（Number类型）
    const argbNumber = (clampedAlpha << 24) | rgb;

    // 3. 转换为十六进制字符串
    // toString(16) 会转成类似 "ff1a2b3c" 的字符串
    let hexString = argbNumber.toString(16).padStart(8, '0');

    // 4. 加上 # 号前缀，符合标准的颜色字符串格式
    return `#${hexString}`;
  }

  /**
   * 获取一个标准的、未经修改的颜色值（number类型）
   */
  private getNormalColor(color: ResourceColor): number {
    if (!this.context) {
      console.error(`颜色工具没有初始化`);
      throw new Error('颜色工具没有初始化');
    }
    if (typeof color === 'number') return color;
    if (typeof color === 'string') {
      const parsed = this.parseColorString(color);
      if (parsed !== null) return parsed;
      throw new Error(`无法解析的颜色字符串: ${color}`);
    }
    // 处理资源对象
    try {
      return this.context.resourceManager.getColorSync(color.id);
    } catch (error) {
      console.error(`getColorSync错误，message: ${error.message}`);
      throw new Error(`getColorSync错误，message: ${error.message}`);
    }
  }

}

export const Xb_ColorUtils = new Color()