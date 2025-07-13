import { abilityAccessCtrl,
  common,
  Context,
  PermissionRequestResult,
  Permissions, WantAgent, wantAgent } from "@kit.AbilityKit";
import { backgroundTaskManager } from "@kit.BackgroundTasksKit";
import { notificationManager } from "@kit.NotificationKit";
import { BusinessError, request } from "@kit.BasicServicesKit";
import { http } from "@kit.NetworkKit";
import { AppConfig, AppFlowingState, AppState } from "../../entryability/AppState";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { geoLocationManager } from "@kit.LocationKit";
import fs from '@ohos.file.fs';
import { rcp } from '@kit.RemoteCommunicationKit';


/**
 * 模拟下载长时任务
 */
export class BackgroundDownService {
  notificationId?: number = undefined;
  ping: number = 0;
  notice: number = 0;
  message: string = '';
  downloadTask?: request.DownloadTask;
  isLooping: boolean = false; // 新增循环控制标志

  async start(context: common.UIAbilityContext) {
    this.isLooping = true; // 开启循环
    this.downloadService(context);
  }

  stop(context: Context) {
    this.isLooping = false; // 停止循环

    this.downloadTask?.delete((err: BusinessError, result: boolean) => {
      if (err) {
        console.error(`SimulateDownload Failed to remove the download task. Code: ${err.code}, message: ${err.message}`);
        return;
      }
      const filePath = context.filesDir + '/' + '模拟下载中';
      try {
        if (fs.accessSync(filePath)) {
          fs.unlinkSync(filePath);
          console.info("SimulateDownload 文件存在，已删除");
        }
      } catch (e) {
        console.error("SimulateDownload 删除文件失败:", e);
      }
      console.info('SimulateDownload Succeeded in removing the download task.');
    });
  }

  downloadService(context: common.UIAbilityContext) {
    if (!this.isLooping) return; // 检查循环状态

    const filePath = context.filesDir + '/' + '模拟下载中';
    try {
      if (fs.accessSync(filePath)) {
        fs.unlinkSync(filePath);
        console.info("SimulateDownload 文件存在，已删除");
      }
    } catch (e) {
      console.warn("SimulateDownload 删除文件失败（可能不存在）:", e);
    }

    try {
      console.info("SimulateDownload 模拟下载开始");
      request.downloadFile(context, {
        url: 'https://dldir1v6.qq.com/qqfile/qq/QQNT/Windows/QQ_9.9.20_250710_x64_01.exe', // TODO 下载链接待替换
        filePath: filePath,
        background: true
      }, (err: BusinessError, data: request.DownloadTask) => {
        if (err) {
          console.error(`SimulateDownload Failed to request the download. Code: ${err.code}, message: ${err.message}`);
          this.retryDownload(context); // 错误时重试
          return;
        }
        this.downloadTask = data;

        // 进度回调保持不变
        let progressCallback = (receivedSize: number, totalSize: number) => {
          console.info("SimulateDownload receivedSize:" + receivedSize + " totalSize:" + totalSize);
        };

        // 修改完成回调：删除文件+重新下载
        let completeCallback = () => {
          console.info('SimulateDownload 模拟下载完成');
          try {
            if (fs.accessSync(filePath)) {
              fs.unlinkSync(filePath);
              console.info("SimulateDownload 下载后删除文件成功");
            }
          } catch (e) {
            console.error("SimulateDownload 下载后删除文件失败:", e);
          }

          // 延迟1秒后重新开始下载
          setTimeout(() => {
            if (this.isLooping) {
              this.downloadService(context);
            }
          }, 1000);
        };

        // 失败回调：重试下载
        let failCallback = (errCode: number) => {
          console.error(`SimulateDownload Failed to download the task. Code: ${errCode}`);
          this.retryDownload(context);
        };

        this.downloadTask.on('progress', progressCallback);
        this.downloadTask.on('complete', completeCallback);
        this.downloadTask.on('fail', failCallback);
      });
    } catch (err) {
      console.error(`SimulateDownload Failed to request the download. err: ${JSON.stringify(err)}`);
      this.retryDownload(context);
    }
  }

  // 新增重试方法
  private retryDownload(context: common.UIAbilityContext) {
    if (!this.isLooping) return;

    console.info("SimulateDownload 5秒后重试下载...");
    setTimeout(() => {
      if (this.isLooping) {
        this.downloadService(context);
      }
    }, 5000);
  }
}

export default  new BackgroundDownService()


const TAG = 'DownloadSync'; // 日志标签
const NetworkOutputQueue = rcp.NetworkOutputQueue;

export class ThrottledDownloader {
  private url: string;
  private speedLimitKBps: number;
  private chunkSizeKB: number;
  private timeoutMs: number;
  private session?: rcp.Session;
  private networkOutputQueue: rcp.INetworkOutputQueue | null = null;
  private isDownloading: boolean = false;
  private isPaused: boolean = false;
  private downloadedBytes: number = 0;
  private totalBytes: number = 0;
  private startTime: number = 0;
  private lastChunkTime: number = 0;

  private progressCallbacks: Array<(progress: DownloadProgress) => void> = [];
  private completionCallbacks: Array<() => void> = [];
  private errorCallbacks: Array<(error: Error) => void> = [];

  constructor(
    url: string,
    options: DownloadOption
  ) {
    this.url = url;
    this.speedLimitKBps = options.speedLimitKBps || 100;
    this.chunkSizeKB = options.chunkSizeKB || 10;
    this.timeoutMs = options.timeoutMs || 30000; // 默认30秒超时
    hilog.info(0x0001, TAG, `下载器已创建: URL=${url}, 限速=${this.speedLimitKBps}KB/s, 分块大小=${this.chunkSizeKB}KB`);
  }

  setSpeedLimit(speedLimitKBps: number): void {
    if (speedLimitKBps <= 0) {
      throw new Error('速度限制必须大于0');
    }
    this.speedLimitKBps = speedLimitKBps;
    hilog.info(0x0001, TAG, `下载速度限制已更新: ${speedLimitKBps}KB/s`);
  }

  onProgress(callback: (progress: DownloadProgress) => void): void {
    this.progressCallbacks.push(callback);
    hilog.debug(0x0001, TAG, '已注册进度回调');
  }

  onComplete(callback: () => void): void {
    this.completionCallbacks.push(callback);
    hilog.debug(0x0001, TAG, '已注册完成回调');
  }

  onError(callback: (error: Error) => void): void {
    this.errorCallbacks.push(callback);
    hilog.debug(0x0001, TAG, '已注册错误回调');
  }

  async start(): Promise<void> {
    if (this.isDownloading) {
      hilog.warn(0x0001, TAG, '下载已在进行中');
      return;
    }

    hilog.info(0x0001, TAG, '开始下载...');
    this.isDownloading = true;
    this.isPaused = false;
    this.downloadedBytes = 0;
    this.startTime = Date.now();
    this.lastChunkTime = this.startTime;

    try {
      // 创建会话和队列
      hilog.debug(0x0001, TAG, '创建会话和队列');
      this.session = rcp.createSession({
      });
      this.networkOutputQueue = new NetworkOutputQueue();
      hilog.debug(0x0001, TAG, `会话配置完成`);

      // 发起请求
      hilog.debug(0x0001, TAG, `发起GET请求: ${this.url}`);
      // 使用Promise.race实现超时控制
      const requestPromise = this.session.get(this.url, this.networkOutputQueue);
      const timeoutPromise = new Promise<void>((_, reject) => {
        setTimeout(() => {
          reject(new Error(`请求超时 (${this.timeoutMs}ms)`));
        }, this.timeoutMs);
      });
      const resp = await this.session.get(this.url, this.networkOutputQueue);

      // 获取内容长度（如果可用）
      if (resp?.headers?.['Content-Length']) {
        this.totalBytes = parseInt(JSON.stringify(resp.headers['Content-Length']), 10);
        hilog.debug(0x0001, TAG, `获取到内容长度: ${this.totalBytes}字节`);
      } else {
        hilog.warn(0x0001, TAG, '未获取到内容长度');
      }

      // 处理下载流
      hilog.debug(0x0001, TAG, '开始处理下载流');
      await this.processDownloadStream();
      hilog.info(0x0001, TAG, '下载流处理完成');

    } catch (error) {
      hilog.error(0x0001, TAG, `下载出错: ${JSON.stringify(error)}`);
      this.handleError(error);
    } finally {
      this.cleanup();
    }
  }

  pause(): void {
    if (!this.isPaused) {
      this.isPaused = true;
      hilog.info(0x0001, TAG, '下载已暂停');
    }
  }

  resume(): void {
    if (this.isPaused) {
      this.isPaused = false;
      hilog.info(0x0001, TAG, '下载已恢复');
    }
  }

  cancel(): void {
    this.isDownloading = false;
    hilog.info(0x0001, TAG, '下载已取消');
    this.cleanup();
  }

  private async processDownloadStream(): Promise<void> {
    if (!this.networkOutputQueue) {
      const errorMsg = '网络输出队列未初始化';
      hilog.error(0x0001, TAG, errorMsg);
      throw new Error(errorMsg);
    }

    let chunkCount = 0;
    let retryCount = 0;
    const MAX_RETRIES = 3;

    while (this.isDownloading) {
      if (this.isPaused) {
        hilog.debug(0x0001, TAG, '下载暂停中...');
        await new Promise<void>((resolve) => setTimeout(resolve, 100));
        continue;
      }

      // 计算每个数据块需要的理论时间
      const chunkTime = (this.chunkSizeKB / this.speedLimitKBps) * 1000;

      try {
        // 读取数据块
        const chunkSizeBytes = this.chunkSizeKB * 1024;
        hilog.debug(0x0001, TAG, `尝试读取 ${this.chunkSizeKB}KB 数据块`);

        const chunk = this.networkOutputQueue.read(chunkSizeBytes);
        retryCount = 0; // 重置重试计数
        chunkCount++;

        if (!chunk || chunk.byteLength === 0) {
          hilog.debug(0x0001, TAG, '读取到空数据块，可能已到达流末尾');
          break;
        }

        hilog.debug(0x0001, TAG, `成功读取数据块 #${chunkCount}: ${chunk.byteLength}字节`);

        // 更新下载量
        this.downloadedBytes += chunk.byteLength;

        // 计算当前速度
        const now = Date.now();
        const timeDiff = now - this.lastChunkTime;

        if (timeDiff > 0) {
          const speed = (chunk.byteLength / timeDiff) / 1024; // KB/s
          this.lastChunkTime = now;

          // 触发进度回调
          const progress: DownloadProgress = {
            loadedBytes: this.downloadedBytes,
            totalBytes: this.totalBytes,
            speedKBps: speed,
            percent: this.totalBytes > 0
              ? (this.downloadedBytes / this.totalBytes) * 100
              : 0,
            elapsedSeconds: (now - this.startTime) / 1000,
            remainingSeconds: this.totalBytes > 0 && speed > 0
              ? ((this.totalBytes - this.downloadedBytes) / 1024) / speed
              : 0
          };

          hilog.debug(0x0001, TAG, `进度更新:
          ${progress.percent.toFixed(1)}%,
          速度: ${progress.speedKBps.toFixed(1)}KB/s,
          已下载: ${(progress.loadedBytes / 1024).toFixed(1)}KB`);

          this.progressCallbacks.forEach(callback => callback(progress));
        }

        // 等待以达到限速效果
        if (chunkTime > 0) {
          hilog.debug(0x0001, TAG, `限速等待: ${chunkTime.toFixed(1)}ms`);
          await new Promise<void>((resolve) => setTimeout(resolve, chunkTime));
        }
      } catch (error) {
        hilog.error(0x0001, TAG, `处理数据块时出错: ${JSON.stringify(error)}`);
        if (retryCount < MAX_RETRIES) {
          retryCount++;
          hilog.warn(0x0001, TAG, `重试处理数据块 ${retryCount}/${MAX_RETRIES}`);
          await new Promise<void>((resolve) => setTimeout(resolve, 1000));
        } else {
          throw error as Error; // 超过重试次数，抛出错误
        }
      }

    }

    // 下载完成
    if (this.isDownloading) {
      hilog.info(0x0001, TAG, `下载完成! 总下载量: ${this.downloadedBytes}字节, 分块数: ${chunkCount}`);
      this.completionCallbacks.forEach(callback => callback());
      this.isDownloading = false;
    }
  }

  private handleError(error: Error): void {
    let errorObj: Error;

    if (error instanceof Error) {
      errorObj = error;
    } else if (typeof error === 'string') {
      errorObj = new Error(error);
    } else {
      errorObj = new Error('未知下载错误');
    }

    hilog.error(0x0001, TAG, `处理错误: ${errorObj.message}`);
    this.errorCallbacks.forEach(callback => callback(errorObj));
    this.isDownloading = false;
  }

  private cleanup(): void {
    hilog.debug(0x0001, TAG, '清理资源...');

    if (this.session) {
      try {
        this.session.close();
        hilog.debug(0x0001, TAG, '会话已关闭');
      } catch (error) {
        hilog.warn(0x0001, TAG, `关闭会话时出错: ${JSON.stringify(error)}`);
      }
      this.session = undefined;
    }

    this.networkOutputQueue = null;
  }
}

export interface DownloadProgress {
  loadedBytes: number;
  totalBytes: number;
  speedKBps: number;
  percent: number;
  elapsedSeconds: number;
  remainingSeconds: number;
}

interface DownloadOption {
  speedLimitKBps?: number;
  chunkSizeKB?: number;
  timeoutMs?: number;
}


/*const testNetworkOutputQueue = async (done: Function): Promise<void> => {
  // 创建同步读队列对象
  const NetworkOutputQueue = rcp.NetworkOutputQueue;
  const networkOutputQueue = new NetworkOutputQueue();
  // 创建session
  const session = rcp.createSession();
  // 配置请求流数据size
  const numOfChunks = 10;
  const chunkLength = 1000;
  const totalBytes = numOfChunks * chunkLength;
  // 发起同步读请求
  const resp = await session.get('https://httpbin.org/bytes/' + totalBytes.toString(), networkOutputQueue);
  // 分段读取请求到的数据
  for (let i = 0; i < numOfChunks; i++) {
    // 开发者需要根据实际场景处理后续业务
    const chunk = networkOutputQueue.read(chunkLength);
  }
  // 关闭session
  session.close();
  done();
}*/
