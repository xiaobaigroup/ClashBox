import { webview } from "@kit.ArkWeb";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { BusinessError } from "@kit.BasicServicesKit";

/**
 * 编辑器消息基础接口
 */
export interface EditorMessageBase {
  type: 'command' | 'event' | 'response' | 'config';
  id?: string;
  timestamp: number;
}

/**
 * 命令消息
 */
export interface EditorCommandMessage extends EditorMessageBase {
  type: 'command';
  command: string;
  data?: Record<string, unknown>;
}

/**
 * 事件消息
 */
export interface EditorEventMessage extends EditorMessageBase {
  type: 'event';
  event: string;
  data?: EditorSelection | boolean | string | EditorConfig;
}

/**
 * 响应消息
 */
export interface EditorResponseMessage extends EditorMessageBase {
  type: 'response';
  id: string;
  data?: unknown;
  error?: string;
}

/**
 * 配置消息
 */
export interface EditorConfigMessage extends EditorMessageBase {
  type: 'config';
  data: EditorConfig;
}

/**
 * 消息联合类型
 */
export type EditorMessage = EditorCommandMessage | EditorEventMessage | EditorResponseMessage | EditorConfigMessage;

/**
 * 编辑器选区信息
 */
export interface EditorSelection {
  from: number;
  to: number;
  text: string;
}

/**
 * 编辑器就绪状态信息
 */
export interface EditorReadyInfo {
  status: 'success' | 'error';
  theme?: 'dark' | 'light';
  message?: string;
}

/**
 * 配置应用完成信息
 */
export interface ConfigAppliedInfo {
  theme: 'dark' | 'light';
  language: string;
}


/**
 * 编辑器配置
 */
export interface EditorConfig {
  theme: 'dark' | 'light' | 'vs-dark';
  language: 'javascript' | 'typescript' | 'jsx' | 'tsx' | 'css' | 'html' | 'json' | 'python' | 'java';
  fontSize: string;
  tabSize: number;
  content: string;
  minimap: boolean;
  wordWrap?: boolean;
}

/**
 * Web 代码编辑器配置选项
 */
export interface WebCodeEditorOptions {
  // 回调函数
  onContentChange?: (content: string) => void;
  onSelectionChange?: (selection: EditorSelection) => void;
  onEditingChange?: (isEditing: boolean) => void;
  onSave?: () => void;
  onReady?: () => void;
  onError?: (error: string) => void;

  // 编辑器配置
  theme?: 'dark' | 'light';
  language?: 'javascript' | 'typescript' | 'jsx' | 'tsx' | 'css' | 'html' | 'json' | 'python' | 'java';
  fontSize?: string;
  tabSize?: number;
  content?: string;
  showLineNumbers?: boolean;
  wordWrap?: boolean;
  showMinimap?: boolean;
}

/**
 * 命令请求回调
 */
export interface CommandRequestCallback {
  resolve: (data: unknown) => void;
  reject: (error: string) => void;
}

/**
 * 事件回调函数
 */
export type EventCallback = (data?: EditorSelection | boolean | string | EditorConfig | EditorReadyInfo | ConfigAppliedInfo) => void;

const TAG = 'WebCodeEditor';

/**
 * 通信管理器
 */
export class EditorCommunicationManager {
  private controller: webview.WebviewController;
  private messagePort: webview.WebMessagePort | null = null;
  private pendingRequests: Map<string, CommandRequestCallback> = new Map();
  private eventCallbacks: Map<string, EventCallback[]> = new Map();
  private lastSentConfigKey: string = '';
  private isDestroyed: boolean = false; // 是否销毁标志
  private isPortValid: boolean = false; // 端口有效性标记
  private retryCount: number = 0; // 重试计数

  constructor(controller: webview.WebviewController) {
    this.controller = controller;
  }

  /**
   * 初始化通信端口
   */
  initializePorts(): boolean {
    try {
      // 清理旧端口
      if (this.messagePort) {
        try {
          this.messagePort.close();
        } catch (error) {
          hilog.warn(0x0000, TAG, `Failed to close old port: ${error}`);
        }
      }
      const ports: webview.WebMessagePort[] = this.controller.createWebMessagePorts();
      if (ports.length === 2) {
        const [localPort, remotePort] = ports;
        this.messagePort = localPort;
        // 验证端口有效性
        this.isPortValid = this.validatePort(localPort);
        if (!this.isPortValid) {
          hilog.error(0x0000, TAG, 'Invalid port created');
          return false;
        }
        // 设置消息监听
        localPort.onMessageEvent((message: webview.WebMessage) => {
          this.handleMessage(message);
        });
        // 发送端口到Web端
        this.controller.postMessage("initEditorPort", [remotePort], "*");
        hilog.info(0x0000, TAG, 'Communication ports initialized successfully');
        this.retryCount = 0; // 重置重试计数
        return true;
      }
    } catch (error) {
      const err = error as Error;
      hilog.error(0x0000, TAG, `Failed to initialize ports: ${err.message}`);
    }
    return false;
  }

  /**
   * 验证端口有效性
   */
  private validatePort(port: webview.WebMessagePort): boolean {
    try {
      return typeof port.postMessageEvent === 'function' &&
        typeof port.onMessageEvent === 'function';
    } catch (error) {
      return false;
    }
  }

  /**
   * 处理收到的消息
   */
  private handleMessage(message: webview.WebMessage): void {
    try {
      const messageData: string = String(message);
      hilog.debug(0x0000, TAG, `Received message: ${messageData}`);
      const parsedMessage: EditorMessage = JSON.parse(messageData) as EditorMessage;

      switch (parsedMessage.type) {
        case 'response':
          this.handleResponse(parsedMessage as EditorResponseMessage);
          break;
        case 'event':
          this.handleEvent(parsedMessage as EditorEventMessage);
          break;
        default:
          hilog.warn(0x0000, TAG, `Unknown message type: ${parsedMessage.type}`);
      }
    } catch (error) {
      const err = error as Error;
      hilog.error(0x0000, TAG, `Failed to parse message: ${err.message}`);
    }
  }

  /**
   * 处理响应消息
   */
  private handleResponse(message: EditorResponseMessage): void {
    const callback = this.pendingRequests.get(message.id);
    if (callback) {
      this.pendingRequests.delete(message.id);
      if (message.error) {
        callback.reject(message.error);
      } else {
        callback.resolve(message.data);
      }
    }
  }

  /**
   * 处理事件消息
   */
  private handleEvent(message: EditorEventMessage): void {
    hilog.debug(0x0000, TAG, `Handling event: ${message.event}`);
    const callbacks = this.eventCallbacks.get(message.event) || [];

    if (message.event === 'ready') {
      hilog.info(0x0000, TAG, 'Ready event received, triggering callbacks');
    }

    callbacks.forEach(callback => {
      try {
        callback(message.data);
      } catch (error) {
        hilog.error(0x0000, TAG, `Error in event callback: ${error}`);
      }
    });
  }

  /**
   * 发送命令到Web端
   */
  sendCommand(command: string, data?: Record<string, unknown>): Promise<string | EditorSelection> {
    return new Promise((resolve, reject) => {
      // 销毁检查
      if (this.isDestroyed) {
        reject('sendCommand: Communication manager is destroyed');
        return;
      }
      // 检查端口有效性
      if (!this.messagePort || !this.isPortValid) {
        // 尝试重新初始化
        if (this.retryCount < 3) {
          hilog.warn(0x0000, TAG, `Port invalid, retrying initialization (${this.retryCount + 1}/3)`);
          this.retryCount++;
          setTimeout(() => {
            if (this.initializePorts()) {
              this.sendCommand(command, data).then(resolve).catch(reject);
            } else {
              reject('Communication port not ready after retry');
            }
          }, 1000 * this.retryCount);
        } else {
          reject('Communication port not ready');
        }
        return;
      }

      const messageId: string = this.generateMessageId();
      const message: EditorCommandMessage = {
        type: 'command',
        id: messageId,
        command,
        data,
        timestamp: Date.now()
      };

      this.pendingRequests.set(messageId, { resolve, reject });

      // 超时时间
      let timeout: number;
      switch (command) {
        case 'setTheme':
          timeout = 6000; // 主题切换：60秒（最耗时）
          break;
        case 'setContent':
          timeout = 3000;  // 设置大量内容：3秒
          break;
        case 'getContent':
        case 'getSelection':
        case 'focus':
          timeout = 1000;  // 快速命令：1秒
          break;
        default:
          timeout = 5000;  // 其他命令：5秒
      }

      setTimeout(() => {
        if (this.pendingRequests.has(messageId)) {
          this.pendingRequests.delete(messageId);
          reject('Command timeout');
        }
      }, timeout);

      try {
        hilog.info(0x0000, TAG, `Sending command: ${command} with data:${JSON.stringify(data)}`);
        this.messagePort.postMessageEvent(JSON.stringify(message));
      } catch (error) {
        const err = error as Error;
        this.pendingRequests.delete(messageId);
        // 标记端口无效
        this.isPortValid = false;
        reject(`Failed to send command: ${err.message}`);
      }
    });
  }

  /**
   * 发送事件到Web端
   */
  sendEvent(event: string, data?: EditorSelection | boolean | string | EditorConfig): void {
    // 销毁检查
    if (this.isDestroyed) {
      hilog.warn(0x0000, TAG, 'Cannot send event: communication manager is destroyed');
      return;
    }
    // 检查端口有效性
    if (!this.messagePort || !this.isPortValid) {
      hilog.warn(0x0000, TAG, 'Cannot send event: communication port not ready');
      return;
    }
    // 检查是否是重复的配置事件
    if (event === 'config') {
      const configData = data as EditorConfig;
      const configKey = `${configData.theme}-${configData.language}-${configData.content?.substring(0, 50)}`;

      if (this.lastSentConfigKey === configKey) {
        hilog.info(0x0000, TAG, 'Duplicate config detected, skipping send');
        return;
      }
      this.lastSentConfigKey = configKey;

      hilog.info(0x0000, TAG, `Sending config event with theme: ${configData.theme}`);
    }

    const message: EditorEventMessage = {
      type: 'event',
      event,
      data,
      timestamp: Date.now()
    };

    try {
      hilog.info(0x0000, TAG, `Sending event: ${event}`);
      this.messagePort.postMessageEvent(JSON.stringify(message));
    } catch (error) {
      const err = error as Error;
      hilog.error(0x0000, TAG, `Failed to send event: ${err.message}`);
      // 标记端口无效
      this.isPortValid = false;
    }
  }

  /**
   * 注册事件监听器
   */
  on(event: string, callback: EventCallback): void {
    if (!this.eventCallbacks.has(event)) {
      this.eventCallbacks.set(event, []);
    }
    this.eventCallbacks.get(event)!.push(callback);
    hilog.info(0x0000, TAG, `Registered callback for event: ${event}`);
  }

  /**
   * 生成消息ID
   */
  private generateMessageId(): string {
    return `msg_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * 重新初始化通信
   */
  public reinitialize(): void {
    hilog.warn(0x0000, TAG, 'Attempting to reinitialize communication');
    this.messagePort = null;
    this.isPortValid = false;
    this.lastSentConfigKey = '';
    this.retryCount = 0;

    // 拒绝所有待处理的请求
    this.pendingRequests.forEach((callback) => {
      callback.reject('Communication reinitialized');
    });
    this.pendingRequests.clear();
  }

  /**
   * 清理资源
   */
  destroy(): void {
    hilog.info(0x0000, TAG, 'Starting communication manager destroy process');
    // 设置销毁标志，阻止新操作
    this.isDestroyed = true;
    // 拒绝所有待处理的请求
    this.pendingRequests.forEach((callback, id) => {
      hilog.debug(0x0000, TAG, `Rejecting pending request: ${id}`);
      callback.reject('Communication manager destroyed');
    });
    this.pendingRequests.clear();
    // 清理事件回调
    this.eventCallbacks.clear();
    this.lastSentConfigKey = '';
    this.retryCount = 0;
    // 安全关闭端口
    if (this.messagePort) {
      try {
        // 先标记端口无效
        this.isPortValid = false;
        hilog.info(0x0000, TAG, 'Closing message port...');
        this.messagePort.close();
        hilog.info(0x0000, TAG, 'Message port closed successfully');
      } catch (error) {
        hilog.warn(0x0000, TAG, `Failed to close port during destroy: ${error}`);
      }
    }
    // 清理引用
    this.messagePort = null;
    hilog.info(0x0000, TAG, 'Communication manager destroy completed');
  }
}
