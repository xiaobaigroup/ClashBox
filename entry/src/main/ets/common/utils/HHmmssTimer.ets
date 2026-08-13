/**
 * HH:mm:ss 计时器
 * 使用方式
 *  1. 启动：新建Timer对象之后，调用`start()`方法，参数是一个callback回调函数，函数参数值的范围为：[00:00:00 - 999:59:59]
 *          可选：输出时间格式 isTextStyle
 *  2. 暂停：调用`pause()`方法
 *  3. 二次启动：调用`resumeWithExtraTime(需累加时间戳)`方法可传入需累加时间戳
 *  4. 重置：调用`reset()`方法
 */
export class Timer {
  private startTime: number
  private elapsed: number
  private timerId: number | undefined
  private callback: ((time: number) => void) | undefined

  constructor() {
    this.startTime = 0
    this.elapsed = 0
    this.timerId = undefined
  }

  public start(callback?: (time: number) => void, startTime?: number): void {
    this.callback = callback
    if (startTime !== undefined) {
      this.startTime = startTime
    } else {
      this.startTime = Date.now() - this.elapsed
    }
    // 重复启动只保留一个调度器，避免多个 interval 交错刷新同一显示值。
    if (this.timerId !== undefined) {
      clearInterval(this.timerId)
    }
    this.timerId = setInterval(() => this.updateTimer(), 900)
    // 首次启动立即同步，避免先显示 00:00:00、下一拍才跳到真实运行时长。
    this.updateTimer()
  }

  public pause(): void {
    if (this.timerId !== undefined) {
      this.elapsed = Date.now() - this.startTime
      clearInterval(this.timerId)
      this.timerId = undefined
    }
  }

  public resumeWithExtraTime(extraTime: number): void {
    this.elapsed += extraTime
    this.start(this.callback)
  }

  /** @description 前台恢复前立即发布当前运行时长，消除后台定时器节流造成的陈旧首帧。 */
  public refresh(): void {
    if (this.timerId !== undefined) {
      this.updateTimer()
    }
  }

  private updateTimer(): void {
    if (this.callback) {
      const timeString = this.getTime()
      this.callback(timeString)
    }
  }

  public reset(): void {
    if (this.timerId !== undefined) {
      clearInterval(this.timerId);
      this.timerId = undefined;
    }
    this.startTime = 0
    this.elapsed = 0
  }

  private getTime(): number {
    const totalMilliseconds = Date.now() - this.startTime
    return totalMilliseconds
  }
}

