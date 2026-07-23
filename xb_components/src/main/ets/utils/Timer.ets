
/**
 * 计时器类 - 正计时
 * 职责：管理计时状态（开始、暂停、重置），计算时间差
 */
export class Xb_Timer {
  private startTime: number = 0;
  private elapsed: number = 0;
  private timerId: number | undefined = undefined;
  private callback: ((ms: number) => void) | undefined = undefined;

  constructor() {
    this.reset();
  }

  /**
   * 启动计时器
   * @param callback 每次时间更新的回调，参数为毫秒数
   * @param startTime 可选，指定起始时间戳
   */
  public start(callback?: (ms: number) => void, startTime?: number): void {
    this.callback = callback;
    if (startTime !== undefined) {
      this.startTime = startTime;
    } else {
      this.startTime = Date.now() - this.elapsed;
    }

    // 清除旧定时器
    if (this.timerId) clearInterval(this.timerId);

    // 启动新定时器
    this.timerId = setInterval(() => this.tick(), 900);
    this.tick(); // 立即触发一次
  }

  /**
   * 暂停计时器
   */
  public pause(): void {
    if (this.timerId) {
      this.elapsed = Date.now() - this.startTime;
      clearInterval(this.timerId);
      this.timerId = undefined;
    }
  }

  /**
   * 继续计时，支持累加额外时间
   */
  public resumeWithExtraTime(extraTime: number = 0): void {
    this.elapsed += extraTime;
    this.start(this.callback);
  }

  /**
   * 重置计时器
   */
  public reset(): void {
    if (this.timerId) clearInterval(this.timerId);
    this.timerId = undefined;
    this.startTime = 0;
    this.elapsed = 0;
  }

  /**
   * 获取当前计时毫秒数
   */
  public getTime(): number {
    if (this.timerId !== undefined) {
      return Date.now() - this.startTime;
    }
    return this.elapsed;
  }

  private tick(): void {
    if (this.callback) {
      this.callback(this.getTime());
    }
  }

}

/**
 * 倒计时类
 * 职责：管理倒计时状态
 */
export class Xb_TimeCountdown {
  private timerId: number | undefined = undefined;
  private remainingTime: number = 0;

  /**
   * 启动倒计时
   * @param duration 总时长(毫秒)
   * @param onUpdate 更新回调
   * @param onDone 完成回调
   */
  public start(duration: number, onUpdate: (ms: number) => void, onDone: () => void): void {
    this.stop();
    this.remainingTime = duration;
    onUpdate(this.remainingTime); // 立即显示初始时间

    this.timerId = setInterval(() => {
      this.remainingTime -= 1000;

      if (this.remainingTime <= 0) {
        this.remainingTime = 0;
        onUpdate(this.remainingTime);
        onDone();
        this.stop();
      } else {
        onUpdate(this.remainingTime);
      }
    }, 1000);
  }

  public stop(): void {
    if (this.timerId) clearInterval(this.timerId);
    this.timerId = undefined;
  }

}

// 导出默认实例, 可选择使用
export const globalTimer = new Xb_Timer();
export const globalTimeCountDown = new Xb_TimeCountdown()
