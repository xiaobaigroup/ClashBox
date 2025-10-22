import { LogCallback, LogEntry } from "./config";


/**
 * WebDAV日志工具
 */
export class WebDavLogger {
  private static instance: WebDavLogger;
  private callbacks: LogCallback[] = [];
  private currentLevel: number = 0; // DEBUG级别

  private constructor() {}

  static getInstance(): WebDavLogger {
    if (!WebDavLogger.instance) {
      WebDavLogger.instance = new WebDavLogger();
    }
    return WebDavLogger.instance;
  }

  clearCallback() {
    this.callbacks = []
  }

  // 添加/移除回调
  addCallback(callback: LogCallback): void {
    this.callbacks.push(callback);
  }

  removeCallback(callback: LogCallback): void {
    const index = this.callbacks.indexOf(callback);
    if (index > -1) {
      this.callbacks.splice(index, 1);
    }
  }

  setLevel(level: 'DEBUG' | 'INFO' | 'WARN' | 'ERROR'): void {
    const levels = { DEBUG: 0, INFO: 1, WARN: 2, ERROR: 3 };
    this.currentLevel = levels[level];
  }

  getLevel() {
    return this.currentLevel
  }

  // 核心日志方法
  private log(level: 'DEBUG' | 'INFO' | 'WARN' | 'ERROR', category: string, message: string, data?: any): void {
    const levels = { DEBUG: 0, INFO: 1, WARN: 2, ERROR: 3 };

    if (levels[level] < this.currentLevel) {
      return;
    }

    const logEntry: LogEntry = {
      timestamp: new Date(),
      level,
      category,  // 用于区分不同模块
      message,
      data
    };

    // 发送给所有回调
    this.callbacks.forEach(callback => {
      try {
        callback(logEntry);
      } catch (error) {
        console.error('日志回调错误:', error);
      }
    });

    // 控制台输出
    this.logToConsole(logEntry);
  }

  private logToConsole(log: LogEntry): void {
    const timeStr = log.timestamp.toLocaleTimeString();
    // 构建基础消息部分
    let message = `[${timeStr}]${log.level} [${log.category}]${log.message}`;

    // 当 data 存在且不为 null 时，尝试序列化
    if (log.data !== undefined && log.data !== null) {
      try {
        const serializedData = JSON.stringify(log.data);
        // 检查序列化结果是否有效（防止函数、Symbol等返回undefined）
        if (serializedData !== undefined) {
          // 在一切正常时，追加一个空格和序列化后的数据
          message += ` ${serializedData}`;
        }
      } catch (error) {
        // 如果数据是循环引用等无法序列化的对象，JSON.stringify会抛出异常
        // 这里可以捕获并打印一个友好的提示
        message += ` [无法序列化的数据: ${error.message}]`;
      }
    }

    // 将最终格式化好的消息输出到控制台
    switch (log.level) {
      case 'DEBUG':
        console.debug(message);
        break;
      case 'INFO':
        console.info(message);
        break;
      case 'WARN':
        console.warn(message);
        break;
      case 'ERROR':
        console.error(message);
        break;
    }
  }

  // 公共日志方法
  debug(category: string, message: string, data?: any): void {
    this.log('DEBUG', category, message, data);
  }

  info(category: string, message: string, data?: any): void {
    this.log('INFO', category, message, data);
  }

  warn(category: string, message: string, data?: any): void {
    this.log('WARN', category, message, data);
  }

  error(category: string, message: string, data?: any): void {
    this.log('ERROR', category, message, data);
  }
}

