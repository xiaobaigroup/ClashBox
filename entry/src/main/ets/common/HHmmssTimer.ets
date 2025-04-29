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

  public start(callback?: (time: number) => void): void {
    this.callback = callback
    this.startTime = Date.now() - this.elapsed
    this.timerId = setInterval(() => this.updateTimer(), 900)
  }

  public pause(): void {
    if (this.timerId) {
      this.elapsed = Date.now() - this.startTime
      clearInterval(this.timerId)
      this.timerId = undefined
    }
  }

  public resumeWithExtraTime(extraTime: number): void {
    this.elapsed += extraTime
    this.start(this.callback)
  }

  private updateTimer(): void {
    if (this.callback) {
      const timeString = this.getTime()
      this.callback(timeString)
    }
  }

  public reset(): void {
    if (this.timerId) {
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



