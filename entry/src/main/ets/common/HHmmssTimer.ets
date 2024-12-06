/**
 * HH:mm:ss 计时器
 * 使用方式
 *  1. 启动：新建Timer对象之后，调用`start()`方法，参数是一个callback回调函数，函数参数值的范围为：[00:00:00 - 999:59:59]
 *  2. 暂停：调用`pause()`方法
 *  2. 停止：调用`start()`方法
 */
import { hilog } from '@kit.PerformanceAnalysisKit'


export class Timer {
  private hours: number = 0
  private minutes: number = 0
  private seconds: number = 0
  // 周期：超过 999:59:59之后值就 += 1，时分秒归零重新开始
  private cycle: number = 0
  private intervalId: number | null = null

  // 格式化时间为 HH:mm:ss
  private formatTime(): string {
    const pad = (num: number) => num.toString().padStart(2, '0')
    return `${pad(this.hours)}:${pad(this.minutes)}:${pad(this.seconds)}`
  }

  // 每秒更新时间
  private tick(): void {
    this.seconds++

    if (this.seconds >= 60) {
      this.seconds = 0
      this.minutes++
    }
    if (this.minutes >= 60) {
      this.minutes = 0
      this.hours++
    }
    if (this.hours >= 999) {
      this.hours = 0
      this.minutes = 0
      this.seconds = 0
      this.cycle++
    }

    // hilog.info(0xA002, 'HHmmssTimer', `Time: ${this.formatTime()} | cycle: ${this.cycle}`)
  }

  /**
   * 启动计时器
   * @param callback 参数为当前定时器的字符串类型的值
   */
  public start( callback: Callback<string> ): void {
    if (this.intervalId === null) {
      this.intervalId = setInterval(() => {
        this.tick()
        callback(this.formatTime())
      }, 1000)
      hilog.info(0xA002, 'HHmmssTimer', `Timer start. Time: ${this.formatTime()} | cycle: ${this.cycle} | Time range is [00:00:00 - 999:59:59]`)
    }
  }

  // 暂停计时器
  public pause(): void {
    if (this.intervalId !== null) {
      clearInterval(this.intervalId)
      this.intervalId = null
      hilog.info(0xA002, 'HHmmssTimer', `Timer pause. Time: ${this.formatTime()} | cycle: ${this.cycle} | Time range is [00:00:00 - 999:59:59]`)
    }
  }

  // 重置计时器
  public reset(): void {
    this.pause()
    hilog.info(0xA002, 'HHmmssTimer', `Timer reset. Time: ${this.formatTime()} | cycle: ${this.cycle} | Time range is [00:00:00 - 999:59:59]`)
    this.hours = 0
    this.minutes = 0
    this.seconds = 0
    this.cycle = 0
  }
}