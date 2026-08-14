/**
 * 时间间隔单位接口
 */
export interface Xb_TimeGap {
  value: number;
  unit: number;
}

/**
 * 时间处理工具类
 * 包含时间戳格式化、持续时间格式化、时间间隔与毫秒转换等功能
 * 静态方法，无状态，可直接调用
 */
export class Xb_TimeUtils {

  // 默认超时时间（毫秒），默认为1分钟
  public static readonly DEFAULT_TIMEOUT_MS: number = 60000;

  /**
   * @description 时间单位到毫秒的转换映射 (0:分钟, 1:小时, 2:天)
   * 根据 CONFIG_AUTO_UPDATE_TIME_GAT_STRING_ARR 的索引返回对应的毫秒倍数
   */
  public static readonly TIME_UNIT_MAP: Map<number, number> = new Map([
    [0, 60 * 1000],          // Minute: 60秒 * 1000毫秒 = 60000毫秒
    [1, 60 * 60 * 1000],     // Hour: 60分钟 * 60秒 * 1000毫秒 = 3600000毫秒
    [2, 24 * 60 * 60 * 1000] // Day: 24小时 * 60分钟 * 60秒 * 1000毫秒 = 86400000毫秒
  ]);

  /**
   * 时间戳转化工具
   * @param timeStamp 传入的时间戳
   * @param styles 输出样式-默认为xxxx/xx/xx
   * @param needNorm 是否强制使用标准日期格式（忽略相对时间）
   * @param needTime 是否包含时分秒
   */
  static convertTime(
    timeStamp: number,
    styles: '/' | '-' = '/',
    needNorm: boolean = false,
    needTime: boolean = false
  ): ResourceStr
  {
    const now = new Date();
    const midnight = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);
    const diffMs = now.getTime() - midnight.getTime();
    const timeDifference = now.getTime() - timeStamp;

    // 处理相对时间
    if (!needTime && !needNorm) {
      if (timeDifference < 15000 || !timeDifference) {
        return $r('app.string.xb_now');
      } else if (timeDifference < diffMs) {
        return $r('app.string.xb_today');
      } else if (timeDifference < diffMs + 86400000) {
        return $r('app.string.xb_yesterday');
      }
    }

    // 处理标准日期格式
    const date = new Date(timeStamp);
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');

    if (needTime) {
      const hours = date.getHours().toString().padStart(2, '0');
      const minutes = date.getMinutes().toString().padStart(2, '0');
      const seconds = date.getSeconds().toString().padStart(2, '0');
      const timeStr = `${hours}:${minutes}:${seconds}`;
      return styles === '/' ? `${year}/${month}/${day} ${timeStr}` : `${year}-${month}-${day} ${timeStr}`;
    } else {
      return styles === '/' ? `${year}/${month}/${day}` : `${year}-${month}-${day}`;
    }
  }

  /**
   * 时间戳转化日常时间工具 XXXX-XX-XX XX:XX:XX
   * @param timestamp 传入的时间戳
   */
  static timestampToDateTime(timestamp: number | string): string {
    if(typeof timestamp == "string")
      timestamp = Xb_TimeUtils.toTimestamp(timestamp)
    const date = new Date(timestamp)
    const year = date.getFullYear()
    const month = (date.getMonth() + 1).toString().padStart(2, '0')
    const day = date.getDate().toString().padStart(2, '0')
    const hours = date.getHours().toString().padStart(2, '0')
    const minutes = date.getMinutes().toString().padStart(2, '0')
    const seconds = date.getSeconds().toString().padStart(2, '0')

    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
  }

  static toTimestamp(dateString: string): number {
    const timestampMs = new Date(dateString.split("Z")[0].slice(0, -3) + "Z").getTime();
    // 转换为秒级时间戳（如果需要）
    const timestampSec = Math.floor(timestampMs / 1000);
    return timestampMs
  }

  /**
   * 将毫秒数格式化为 HH:mm:ss 字符串
   * @param milliseconds 毫秒数
   * @param showHours 是否总是显示小时位，默认 false (不足1小时则不显示小时)
   */
  static formatDuration(milliseconds: number, showHours: boolean = false): string {
    const hours = Math.floor(milliseconds / 3600000);
    const minutes = Math.floor((milliseconds % 3600000) / 60000);
    const seconds = Math.floor((milliseconds % 60000) / 1000);

    const h = hours.toString().padStart(2, '0');
    const m = minutes.toString().padStart(2, '0');
    const s = seconds.toString().padStart(2, '0');

    if (hours > 0 || showHours) {
      return `${h}:${m}:${s}`;
    }
    return `${m}:${s}`;
  }

  /**
   * 将毫秒数格式化为中文描述 (如: 1小时20分)
   * @param milliseconds 毫秒数
   */
  static formatDurationChinese(milliseconds: number): string {
    const hours = Math.floor(milliseconds / 3600000);
    const minutes = Math.floor((milliseconds % 3600000) / 60000);
    const seconds = Math.floor((milliseconds % 60000) / 1000);

    if (hours > 0 && minutes > 0 && seconds > 0) return `${hours}小时${minutes}分${seconds}秒`;
    if (hours > 0 && minutes > 0) return `${hours}小时${minutes}分`;
    if (hours > 0) return `${hours}小时`;
    if (minutes > 0) return `${minutes}分钟`;
    return `不到1分钟`;
  }

  /**
   * 数字转换成时间格式
   * @param isTextStyle 是否为文本样式（XX小时XX分）(默认否)
   */
  static number2Time(number: number, isTextStyle: boolean = false) {
    const hours = Math.floor(number / 3600000)
    const minutes = Math.floor((number % 3600000) / 60000)
    const seconds = Math.floor((number % 60000) / 1000)

    if (isTextStyle) {
      return `${hours}小时${minutes}分${seconds}秒`
    } else {
      return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
    }
  }

  /**
   * 将时、分、秒转换为毫秒数
   */
  static timeToMilliseconds(hours: number = 0, minutes: number = 0, seconds: number = 0): number {
    return (hours * 3600 + minutes * 60 + seconds) * 1000;
  }

  /**
   * 将时间间隔值转换为毫秒
   * @param value 时间间隔数值
   * @param unitIndex 时间单位索引 (0=Minute, 1=Hour, 2=Day)
   */
  static convertTimeGapToMilliseconds(value: number, unitIndex?: number): number {
    if (unitIndex === undefined || unitIndex === null) {
      return value * Xb_TimeUtils.DEFAULT_TIMEOUT_MS;
    }
    const multiplier = Xb_TimeUtils.TIME_UNIT_MAP.get(unitIndex);
    return multiplier ? value * multiplier : value * Xb_TimeUtils.DEFAULT_TIMEOUT_MS;
  }

  /**
   * 将毫秒转换为时间间隔对象
   */
  static convertMillisecondsToTimeGap(value: number): Xb_TimeGap {
    let timeGap: Xb_TimeGap = { value: 0, unit: 0 };
    Xb_TimeUtils.TIME_UNIT_MAP.forEach((multiplier, index) => {
      if (value % multiplier === 0) {
        timeGap = { value: value / multiplier, unit: index };
      }
    });
    return timeGap;
  }

  /**
   * 异步等待指定时间
   * @param timeout 指定时间(毫秒数)
   */
  static sleep(timeout: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, timeout));
  }

}
