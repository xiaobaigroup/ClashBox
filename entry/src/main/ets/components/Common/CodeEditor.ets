import { webview } from '@kit.ArkWeb';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  ConfigAppliedInfo,
  EditorCommunicationManager,EditorConfig,
  EditorReadyInfo,EditorSelection, WebCodeEditorOptions } from '../../common/entity/WebCodeEditor';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'WebCodeEditor';

@Component
export struct WebCodeEditor {

  @Link options: WebCodeEditorOptions;
  @Link webController: webview.WebviewController
  @Link commManager: EditorCommunicationManager;

  @Consume('currentColorMode') @Watch('onColorModeChange') currentColorMode: boolean
  @State private hasSentInitialConfig: boolean = false;
  @State private isEditorReady: boolean = false;
  @State private isWebPageLoaded: boolean = false; // 页面加载状态
  private currentContent: string = '';
  private retryCount: number = 0; // 重试计数

  // 资源映射
  private readonly schemeMap: Map<string, string> = new Map<string, string>([
    ["https://localhost.localdomain/editor.html", "html/editor.html"],
    ["https://localhost.localdomain/js/editor-core.js", "html/js/editor-core.js"],
    ["https://localhost.localdomain/js/state.js", "html/js/state.js"],
    ["https://localhost.localdomain/js/view.js", "html/js/view.js"],
    ["https://localhost.localdomain/js/commands.js", "html/js/commands.js"],
    ["https://localhost.localdomain/js/language.js", "html/js/language.js"],
    ["https://localhost.localdomain/js/autocomplete.js", "html/js/autocomplete.js"],
    ["https://localhost.localdomain/js/search.js", "html/js/search.js"],
    ["https://localhost.localdomain/js/lint.js", "html/js/lint.js"],
    ["https://localhost.localdomain/js/highlight.js", "html/js/highlight.js"],
    ["https://localhost.localdomain/js/common.js", "html/js/common.js"],
    ["https://localhost.localdomain/js/lr.js", "html/js/lr.js"],
    ["https://localhost.localdomain/js/lazer-javascript.js", "html/js/lazer-javascript.js"],
    ["https://localhost.localdomain/js/theme-one-dark.js", "html/js/theme-one-dark.js"],
    ["https://localhost.localdomain/js/lang-javascript.js", "html/js/lang-javascript.js"],
    ["https://localhost.localdomain/js/codemirror-minimap.js", "html/js/codemirror-minimap.js"],
    ["https://localhost.localdomain/js/find-cluster-break.js", "html/js/find-cluster-break.js"],
    ["https://localhost.localdomain/js/style-mod.js", "html/js/style-mod.js"],
    ["https://localhost.localdomain/js/w3c-keyname.js", "html/js/w3c-keyname.js"],
    ["https://localhost.localdomain/js/crelt.js", "html/js/crelt.js"],
  ]);

  private readonly mimeTypeMap: Map<string, string> = new Map<string, string>([
    ["html/editor.html", 'text/html'],
    ["html/js/editor-core.js", "text/javascript"],
    ["html/js/state.js", "text/javascript"],
    ["html/js/view.js", "text/javascript"],
    ["html/js/commands.js", "text/javascript"],
    ["html/js/language.js", "text/javascript"],
    ["html/js/autocomplete.js", "text/javascript"],
    ["html/js/search.js", "text/javascript"],
    ["html/js/lint.js", "text/javascript"],
    ["html/js/highlight.js", "text/javascript"],
    ["html/js/common.js", "text/javascript"],
    ["html/js/lr.js", "text/javascript"],
    ["html/js/lazer-javascript.js", "text/javascript"],
    ["html/js/theme-one-dark.js", "text/javascript"],
    ["html/js/lang-javascript.js", "text/javascript"],
    ["html/js/codemirror-minimap.js", "text/javascript"],
    ["html/js/find-cluster-break.js", "text/javascript"],
    ["html/js/style-mod.js", "text/javascript"],
    ["html/js/w3c-keyname.js", "text/javascript"],
    ["html/js/crelt.js", "text/javascript"],
  ]);

  aboutToAppear(): void {
    // 初始化通信管理器
    this.commManager = new EditorCommunicationManager(this.webController);
    this.setupEventListeners();
  }

  aboutToDisappear(): void {
    // 清理编辑器
    if (this.webController) {
      this.webController.runJavaScript('window.editorAPI?.destroy()').catch((err: BusinessError) => {
        this.handleWebConsole(4, err.message)
      });
    }
  }

  build() {
    Web({
      src: "https://localhost.localdomain/editor.html",
      controller: this.webController
    })
      .width('100%')
      .height('100%')
      .forceDarkAccess(true)
      .domStorageAccess(true)
      .javaScriptAccess(true)
      // .backgroundColor(Color.Transparent)
      .onInterceptRequest((event) => {
        if (!event) {
          return null;
        }
        const requestUrl: string = event.request.getRequestUrl();

        if (this.schemeMap.has(requestUrl)) {
          const rawfileName: string = this.schemeMap.get(requestUrl)!;
          const mimeType: string | undefined = this.mimeTypeMap.get(rawfileName);

          if (mimeType) {
            const response = new WebResourceResponse();
            response.setResponseData($rawfile(rawfileName));
            response.setResponseEncoding('utf-8');
            response.setResponseMimeType(mimeType);
            response.setResponseCode(200);
            response.setReasonMessage('OK');
            response.setResponseIsReady(true);
            return response;
          }
        }
        return null;
      })
      .onPageEnd(() => {
        hilog.info(0x0000, TAG, 'Web page loaded, initializing communication');
        this.isWebPageLoaded = true; // 标记页面已加载
        this.initializeEditor();
      })
      .onConsole((event) => {
        if (event) {
          const level: number = event.message.getMessageLevel();
          const message: string = event.message.getMessage();
          this.handleWebConsole(level, message);
        }
        return false;
      })
  }

  onColorModeChange() {
    // hilog.debug(0x1000, TAG, `#媒体查询 #深色模式: ${this.currentColorMode}`)
    if (this.currentColorMode) {
      this.setTheme('dark')
    } else {
      this.setTheme('light')
    }
  }

  /**
   * 设置事件监听器
   */
  private setupEventListeners(): void {
    this.commManager.on('ready', (data) => {
      const readyInfo = data as EditorReadyInfo;
      if (readyInfo.status === 'success') {
        hilog.info(0x0000, TAG, 'Editor ready event received');
        this.isEditorReady = true;
        this.options.onReady?.();
      } else {
        hilog.error(0x0000, TAG, `Editor initialization failed: ${readyInfo.message}`);
        this.options.onError?.(`Initialization failed: ${readyInfo.message}`);
      }
    });

    // 监听配置应用完成事件
    this.commManager.on('configApplied', (data) => {
      const configInfo = data as ConfigAppliedInfo;
      hilog.info(0x0000, TAG, `Configuration applied: theme=${configInfo.theme}, language=${configInfo.language}`);
      // 可以在这里添加配置应用完成后的逻辑
    });

    // 监听端口断开事件
    this.commManager.on('portDisconnected', () => {
      hilog.warn(0x0000, TAG, 'Communication port disconnected');
      this.isEditorReady = false;
      this.hasSentInitialConfig = false;
    });

    this.commManager.on('contentChange', (data) => {
      const content: string = (data as string) || '';
      this.currentContent = content;
      this.options.onContentChange?.(content);
    });

    this.commManager.on('selectionChange', (data) => {
      const selection = data as EditorSelection
      this.options.onSelectionChange?.(selection);
    });

    this.commManager.on('editingChange', (data) => {
      const isEditing = data as boolean
      this.options.onEditingChange?.(isEditing);
    });

    this.commManager.on('save', () => {
      this.options.onSave?.();
    });

    this.commManager.on('error', (data) => {
      const error: string = (data as string) || 'Unknown error';
      this.options.onError?.(error);
    });
  }

  /**
   * 初始化编辑器
   */
  private initializeEditor(): void {
    // 检查页面是否已加载
    if (!this.isWebPageLoaded) {
      hilog.warn(0x0000, TAG, 'Web page not loaded yet, skipping initialization');
      return;
    }

    // 立即初始化通信端口
    hilog.info(0x0000, TAG, 'Starting communication port initialization');
    const success: boolean = this.commManager.initializePorts();

    if (!success) {
      const errorMsg: string = 'Failed to initialize communication ports';
      hilog.error(0x0000, TAG, errorMsg);

      // 增加重试机制
      if (this.retryCount < 3) {
        this.retryCount++;
        hilog.warn(0x0000, TAG, `Retrying port initialization (${this.retryCount}/3)`);
        setTimeout(() => {
          this.initializeEditor();
        }, this.retryCount * 1000);
      } else {
        this.options.onError?.(errorMsg);
      }
    } else {
      hilog.info(0x0000, TAG, 'Communication ports initialized successfully');
      // 端口初始化成功后，等待一小段时间再发送配置，确保Web端已准备好
      setTimeout(() => {
        this.sendInitialConfig();
      }, 100);
    }
  }

  /**
   * 发送初始配置
   */
  private sendInitialConfig(): void {
    const config: EditorConfig = {
      theme: this.currentColorMode ? 'dark' : 'light',
      language: this.options.language || 'javascript',
      fontSize: this.options.fontSize || '14px',
      tabSize: this.options.tabSize || 4,
      content: this.options.content || '// Welcome to Code Editor\nconsole.log("Hello, HarmonyOS!");',
      minimap: this.options.showMinimap !== false,
      wordWrap: this.options.wordWrap || true
    };
    hilog.info(0x0000, TAG, `Sending initial config with theme: ${config.theme}`);
    try {
      this.commManager.sendEvent('config', config);
      this.hasSentInitialConfig = true;
      hilog.info(0x0000, TAG, 'Initial config sent successfully');
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to send initial config: ${error}`);
      this.hasSentInitialConfig = false;
    }
  }

  /**
   *  重试初始化机制
   */
  private retryInitialization(): void {
    if (this.retryCount >= 3) {
      hilog.error(0x0000, TAG, 'Failed to initialize editor after 3 retries');
      return;
    }
    this.retryCount++;
    hilog.warn(0x0000, TAG, `Retrying initialization (${this.retryCount}/3)`);
    setTimeout(() => {
      this.initializeEditor();
    }, this.retryCount * 1000);
  }

  /**
   * 处理Web控制台输出
   */
  private handleWebConsole(level: number, message: string): void {
    const logLevels: Record<number, string> = {
      1: 'LOG',   // Debug
      2: 'INFO',  // Log
      3: 'WARN',  // Warning
      4: 'ERROR'  // Error
    };
    const levelName: string = logLevels[level] || 'UNKNOWN';
    switch (level) {
      case 4:
        hilog.error(0x0000, TAG, `[Web ${levelName}] ${message}`);
        break
      case 3:
        hilog.warn(0x0000, TAG, `[Web ${levelName}] ${message}`);
        break
      default :
        hilog.info(0x0000, TAG, `[Web ${levelName}] ${message}`);
    }
  }

  /**
   * 公共API方法（保持原有接口不变）
   */
  async setContent(content: string): Promise<void> {
    try {
      this.currentContent = content;
      await this.commManager.sendCommand('setContent', { content });
    } catch (error) {
      const errorMsg: string = `Failed to set content: ${error}`;
      hilog.error(0x0000, TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  async getContent(): Promise<string> {
    try {
      if (this.currentContent && this.isEditorReady) {
        return this.currentContent;
      }
      const content = await this.commManager.sendCommand('getContent');
      return content as string;
    } catch (error) {
      const errorMsg: string = `Failed to get content: ${error}`;
      hilog.error(0x0000, TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  async setTheme(theme: 'dark' | 'light' | 'vs-dark'): Promise<void> {
    try {
      hilog.info(0x0000, TAG, `Setting theme to: ${theme}`);
      // 更新本地配置
      this.options.theme = theme as 'dark' | 'light';
      // 发送主题切换命令
      await this.commManager.sendCommand('setTheme', { theme });
      hilog.info(0x0000, TAG, 'Theme switch command sent successfully');
    } catch (error) {
      const errorMsg: string = `Failed to set theme: ${error}`;
      hilog.error(0x0000, TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  async setLanguage(language: string): Promise<void> {
    try {
      await this.commManager.sendCommand('setLanguage', { language });
    } catch (error) {
      const errorMsg: string = `Failed to set language: ${error}`;
      hilog.error(0x0000, TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  public async insertText(text: string): Promise<void> {
    try {
      await this.commManager.sendCommand('insertText', { text });
    } catch (error) {
      const errorMsg: string = `Failed to insert text: ${error}`;
      hilog.error(0x0000, TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  public async getSelectedText(): Promise<string> {
    try {
      const selection = await this.commManager.sendCommand('getSelection');
      const typedSelection = selection as EditorSelection;
      return typedSelection?.text || '';
    } catch (error) {
      const errorMsg: string = `Failed to get selected text: ${error}`;
      hilog.error(0x0000, TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  public async focus(): Promise<void> {
    try {
      await this.commManager.sendCommand('focus');
    } catch (error) {
      const errorMsg: string = `Failed to focus editor: ${error}`;
      hilog.error(0x0000, TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  public async executeCommand(command: 'save' | 'undo' | 'redo' | 'selectAll' | 'find' | 'replace'): Promise<void> {
    try {
      await this.commManager.sendCommand('execute', { command });
    } catch (error) {
      const errorMsg: string = `Failed to execute command: ${error}`;
      hilog.error(0x0000, TAG, errorMsg);
      throw new Error(errorMsg);
    }
  }

  /**
   * 调试方法 - 手动触发配置发送
   */
  public debugSendConfig(): void {
    hilog.info(0x0000, TAG, 'Manual debug: sending config');
    this.sendInitialConfig();
  }

  /**
   * 调试方法 - 获取当前状态
   */
  public getStatus(): string {
    return JSON.stringify({
      isEditorReady: this.isEditorReady,
      isWebPageLoaded: this.isWebPageLoaded,
      currentContentLength: this.currentContent.length,
      hasCommManager: !!this.commManager,
      retryCount: this.retryCount
    });
  }

  /**
   * 调试方法 - 手动发送测试事件到Web
   */
  public debugSendTestEvent(): void {
    hilog.info(0x0000, TAG, 'Sending test event to Web');
    this.commManager.sendEvent('test', 'Hello from ArkTS debug');
  }

  /**
   * 获取编辑器就绪状态
   */
  public isReady(): boolean {
    return this.isEditorReady;
  }
}
