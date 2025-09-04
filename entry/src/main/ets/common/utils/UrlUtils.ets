import { PromptAction } from "@kit.ArkUI";

export class UrlUtils {
  /**
   * 从华为应用商店URL中提取应用包名
   * @param url 华为应用商店的完整URL字符串
   * @returns 应用包名，如果提取失败返回空字符串
   *
   * 示例：
   * 输入: "https://appgallery.huawei.com/app/detail?id=yylx.danmaku.bili&channelId=SHARE"
   * 输出: "yylx.danmaku.bili"
   */
  static extractPackageName(url: string, promptAction: PromptAction): string {
    try {
      // 判断是否为华为应用商店URL
      if (!UrlUtils.isValidAppGalleryUrl(url, promptAction)) {
        return '';
      }

      // 使用正则表达式匹配id参数的值
      const regex = /[?&]id=([^&]*)/;
      const match = url.match(regex);

      if (match && match[1]) {
        // 对URL编码的字符进行解码
        return decodeURIComponent(match[1]);
      }

      return '';
    } catch (error) {
      promptAction.showToast({
        message: '提取包名时发生错误:' + error,
      })
      console.error('提取包名时发生错误:', error);
      return '';
    }
  }

  /**
   * 验证是否为有效的华为应用商店URL
   * @param url 待验证的URL字符串
   * @returns 如果是有效的华为应用商店URL返回true，否则返回false
   */
  static isValidAppGalleryUrl(url: string, promptAction: PromptAction): boolean {
    try {
      return url.startsWith('https://appgallery.huawei.com/app/detail');
    } catch (error) {
      promptAction.showToast({
        message: '验证URL时发生错误:' + error,
      })
      console.error('验证URL时发生错误:', error);
      return false;
    }
  }
}
