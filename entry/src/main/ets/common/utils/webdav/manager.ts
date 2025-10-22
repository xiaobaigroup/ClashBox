import { BusinessError } from '@kit.BasicServicesKit';
import { xml, util, buffer } from '@kit.ArkTS';
import { fileUri, picker, ReadOptions } from '@kit.CoreFileKit'
import { fileIo as fs } from '@kit.CoreFileKit';
import { Context } from '@kit.AbilityKit';
import { WebDavClient } from './client';
import { FileInfo, LogCallback, WebDavResponse } from './config';
import { rcp } from '@kit.RemoteCommunicationKit';
import { WebDavLogger } from './logger';

/**
 * WebDav操作工具
 */
export class WebDavManager {

  private webdavClient: WebDavClient;
  private context: Context
  private logger: WebDavLogger;

  // 构造函数传入 webdavClient
  constructor(client: WebDavClient, context: Context) {
    this.webdavClient = client;
    this.context = context;
    this.logger = WebDavLogger.getInstance();
    this.logger.info('WebDavManager', 'WebDavManager初始化完成');
  }

  /**
   * 添加日志监听器
   */
  addLogListener(callback: LogCallback): void {
    this.logger.addCallback(callback);
    this.logger.info('WebDavManager.addLogListener', 'LogListener初始化完成');
  }

  clearLogs() {
    this.logger.clearCallback()
  }

  /**
   * 移除日志监听器
   */
  removeLogListener(callback: LogCallback): void {
    this.logger.removeCallback(callback);
  }

  /**
   * 设置日志级别
   */
  setLogLevel(level: 'DEBUG' | 'INFO' | 'WARN' | 'ERROR'): void {
    this.logger.setLevel(level);
  }

  /**
   * 获取当前日志等级
   */
  getLogLevel() {
    return this.logger.getLevel()
  }

  /**
   * 销毁WebDAV客户端并释放底层网络资源
   * 在客户端不再使用时应调用此方法
   */
  public destroy(): void {
    this.webdavClient.destroy()
  }

  /**
   * WebDav连接测试
   * @returns {Promise<ConnectionTestResult>} 返回一个 Promise，解析为连接状态
   */
  async linkTest(checkByTest: boolean = false) {
    try {
      const result = await this.webdavClient.testConnection()
      if (result.success) {
        this.logger.info('WebDavManager.linkTest', result.message, { result });
        // 生成服务器能力报告
        return await this.getServerCapabilityReport(checkByTest)
      } else {
        this.logger.error('WebDavManager.linkTest', result.message, { result });
        return result.message
      };
    } catch (err) {
      this.logger.error('WebDavManager.linkTest', '连通性测试失败', {
        error: err,
        name: err.name,
        message: err.message
      });
      throw new Error(`连通性测试失败，err.name: ${err.name}, err.message: ${err.message}`)
    }
  }

  /**
   * 创建指定文件夹
   * @param {string} path - 要列出的目录路径，例如 '/'
   * @returns {Promise<WebDavResponse>} 返回一个 Promise，解析为创建操作的响应
   */
  async createDirectory(path: string, headers?: rcp.RequestHeaders): Promise<WebDavResponse> {
    this.logger.info('WebDavManager', `开始创建目录: ${path}`, { path, headers });
    try {
      // 规范化路径
      const normalizedPath = path.startsWith('/') ? path : `/${path}`;
      const finalPath = normalizedPath.endsWith('/') && normalizedPath !== '/'
        ? normalizedPath.slice(0, -1)
        : normalizedPath;

      // 确保父目录存在
      const parentPath = finalPath.substring(0, finalPath.lastIndexOf('/'));
      this.validatePath(parentPath)
      if (parentPath) {
        const parentExists = await this.checkDirectoryExists(parentPath);
        if (!parentExists) {
          await this.createDirectory(parentPath); // 递归创建
        }
      }

      // 添加必要的请求头
      const finalHeaders = {
        ...headers,
        'Content-Length': '0'
      };

      const result = await this.webdavClient.mkcol(finalPath, finalHeaders);

      this.logger.info('WebDavManager', `目录创建成功`, {
        path,
        statusCode: result.statusCode
      });

      return result
    } catch (err) {
      this.handleError('创建文件夹', err)
    }
  }

  /**
   * 删除指定的文件或文件夹
   * @param {string} path - 要删除的资源相对路径，例如 '/folder/file.txt'
   * @param {rcp.RequestHeaders} [headers] - 可选的额外请求头
   * @returns {Promise<WebDavResponse>} 返回一个 Promise，解析为 WebDAV 操作响应
   */
  async delete(path: string, headers?: rcp.RequestHeaders): Promise<WebDavResponse> {
    try {
      const finalUrl = this.webdavClient.buildUrl(path);
      this.logger.debug('WebDavManager.delete', `准备删除，最终 URL: ${finalUrl}`, {
        path,
        finalUrl
      });
      const deleteHeaders: rcp.RequestHeaders = headers || {};
      deleteHeaders['Content-Length'] = '0';
      return await this.webdavClient.delete(path, deleteHeaders)
    } catch (err) {
      this.handleError('删除文件夹', err)
    }
  }

  /**
   * 列出指定路径下的所有文件和文件夹
   * @param {string} path - 要列出的目录路径，例如 '/'
   * @param {'0' | '1' | 'infinity'} [depth='1'] - 查询深度（默认非递归，层级类型 '1'）
   *   - '0': 仅查询指定路径的资源
   *   - '1': 查询指定路径及其直接子项
   *   - 'infinity': 查询指定路径及其所有子项
   * @param {rcp.RequestHeaders} [headers] - 可选的额外请求头
   * @returns {Promise<FileInfo[]>} 返回一个 Promise，解析为文件信息数组
   */
  async listDirectory(path: string, depth: "0" | "1" | "infinity" = "1", headers?: rcp.RequestHeaders): Promise<FileInfo[]> {
    const listResponse = await this.webdavClient.propfind(path, depth, ['displayname', 'getcontentlength', 'getlastmodified', 'resourcetype'], headers);
    if (listResponse.statusCode === 207) {
      let parsedData: Record<string, Object>;

      if (typeof listResponse.data === 'object' && listResponse.data !== null) {
        this.logger.debug('WebDavManager.listDirectory', '响应数据已是对象，直接使用', {
          path,
          depth
        });
        parsedData = listResponse.data as Record<string, Object>;
      } else if (listResponse.data) {
        const textDecoder = util.TextDecoder.create('utf-8');
        let rawXml: string;
        if (typeof listResponse.data === 'string') {
          rawXml = listResponse.data;
        } else {
          this.logger.debug('WebDavManager.listDirectory', `接收到的 ArrayBuffer 字节长度: ${(listResponse.data as ArrayBuffer).byteLength}`, {
            path,
            byteLength: (listResponse.data as ArrayBuffer).byteLength
          });
          rawXml = textDecoder.decodeToString(new Uint8Array(listResponse.data as ArrayBuffer));
        }
        this.logger.debug('WebDavManager.listDirectory', `服务器返回的原始 XML (前500字符): ${rawXml.substring(0, 500)}`, {
          path,
          xmlPreview: rawXml.substring(0, 500)
        });
        parsedData = WebDavManager.parseXml(rawXml);
      } else {
        this.logger.error('WebDavManager.listDirectory', 'listResponse.data 为空！', { path });
        return [];
      }

      let multistatus = WebDavManager.safeGetObject(parsedData, ['multistatus']);
      let responsesData = multistatus ? (multistatus['d:response'] || multistatus['D:response']) : undefined;

      if (!responsesData) {
        this.logger.warn('WebDavManager.listDirectory', '未找到 multistatus 节点，尝试从根节点查找 response', { path });
        responsesData = (parsedData['d:response'] || parsedData['D:response']);
      }

      if (!responsesData) {
        this.logger.error('WebDavManager.listDirectory', '无法在 XML 中找到任何 response 节点', {
          path,
          parsedData: JSON.stringify(parsedData)
        });
        throw new Error('无法在 XML 中找到任何 response 节点');
      }

      const itemsToProcess = Array.isArray(responsesData) ? responsesData : (responsesData ? [responsesData] : []);

      if (itemsToProcess.length === 0) {
        this.logger.warn('WebDavManager.listDirectory', '在 response 节点中未找到任何项目', { path });
        return [];
      }

      const fileList: FileInfo[] = [];

      for (const item of itemsToProcess) {
        const href = WebDavManager.safeGetString(item, ['href']);
        if (!href) continue;

        // 过滤逻辑：规范化路径后再比较，兼容有无斜杠的情况
        const normalizedHref = href.endsWith('/') ? href.slice(0, -1) : href;
        const builtUrl = this.webdavClient.buildUrl(path);
        const normalizedBuiltUrl = builtUrl.endsWith('/') ? builtUrl.slice(0, -1) : builtUrl;

        if (normalizedHref === normalizedBuiltUrl) {
          this.logger.debug('WebDavManager.listDirectory', `过滤掉目录本身: ${href}`, {
            path,
            href
          });
          continue;
        }

        const propstat = WebDavManager.safeGetObject(item, ['propstat']);
        if (!propstat) continue;
        const props = WebDavManager.safeGetObject(propstat, ['prop']);
        if (!props) continue;

        const displayName = WebDavManager.safeGetString(props, ['displayname']);
        const contentLengthStr = WebDavManager.safeGetString(props, ['getcontentlength']);
        const lastModified = WebDavManager.safeGetString(props, ['getlastmodified']);

        const resourceTypeData = WebDavManager.safeGetString(props, ['resourcetype']);
        const isDirectory = resourceTypeData && (resourceTypeData.includes('d:collection') || resourceTypeData.includes('D:collection') || resourceTypeData.includes('<collection'));

        // 如果 displayName 为空，则从 href 中提取文件名
        const finalName = displayName || WebDavManager.extractNameFromHref(href);

        fileList.push({
          name: finalName,
          path: href,
          isDirectory: !!isDirectory,
          size: contentLengthStr ? parseInt(contentLengthStr, 10) : 0,
          lastModified: lastModified
        });
      }

      return fileList;
    } else {
      throw new Error(`获取 ${path} 失败, code: ${listResponse.statusCode}`)
    }
  }

  /**
   * 上传文件到 WebDAV 服务器
   * @param path 服务器上的文件夹目标路径，例如 '/ClashBox/'
   * @param localFilePath 可选，本地文件路径-Path
   * @param fileName 可选，强制使用此文件名，而不是从选择器中获取
   * @returns {Promise<WebDavResponse>} 返回一个 Promise，解析为上传操作的响应
   */
  async upload(path: string, localFilePath?: string, fileName?: string): Promise<WebDavResponse> {
    let filePath = ''
    if (localFilePath) {
      // 使用传入的文件路径
      filePath = localFilePath
    } else {
      // 选择文件
      const documentPicker = new picker.DocumentViewPicker(this.context);
      const documentSelectOptions = new picker.DocumentSelectOptions();
      documentSelectOptions.maxSelectNumber = 1;
      const result = await documentPicker.select(documentSelectOptions);
      if (result.length === 0) {
        throw new Error('用户取消了文件选择');
      }
      filePath = result[0];
    }
    const uri = new fileUri.FileUri(filePath).path;
    this.logger.info('WebDavManager.upload', `获取的文件路径: ${filePath}`, {
      filePath,
      uri
    });
    this.logger.info('WebDavManager.upload', `将要上传的路径-uri: ${uri}`, { uri });

    // 打开文件并获取大小
    const file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
    try {
      const stats = fs.statSync(file.path);
      const fileSize = stats.size;
      this.logger.info('WebDavManager.upload', '文件大小', { fileSize });
      const arrayBuffer = new ArrayBuffer(fileSize);

      // 将 fs.read 包装在 Promise 中，并 await
      const readLen = await new Promise<number>((resolve, reject) => {
        const readOptions: ReadOptions = {
          offset: 0,
          length: fileSize
        };
        fs.read(file.fd, arrayBuffer, readOptions, (err: BusinessError, readLen: number) => {
          if (err) {
            this.logger.error('WebDavManager.upload', '读取文件失败', {
              error: err.message,
              code: err.code
            });
            reject(new Error(`文件读取失败: ${err.message}`));
          } else {
            this.logger.info('WebDavManager.upload', '读取文件数据成功', {
              readLen,
              fileSize
            });
            resolve(readLen);
          }
        });
      });

      // 准备上传
      const originalName = uri.slice(uri.lastIndexOf('/') + 1);
      const finalName = fileName ?? originalName;
      const clearName = finalName.replace(/[:*?"<>|]/g, '_');
      if (clearName !== finalName) {
        this.logger.warn('WebDavManager.upload', `发现非法字符，正在清理`, {
          originalName: finalName,
          clearName
        });
      }

      const contentType = getContentType(clearName);
      const headers: rcp.RequestHeaders = {
        'Content-Type': contentType
      };
      this.logger.info('WebDavManager.upload', `正在上传文件 ${clearName}, Content-Type:${contentType}`, {
        clearName,
        contentType,
        fileSize: arrayBuffer.byteLength
      });

      const finalUploadPath = `${path}${clearName}`;
      this.logger.debug('WebDavManager.upload', `Final Upload Path: ${finalUploadPath}`, {
        finalUploadPath
      });

      // 执行上传
      const value = await this.webdavClient.put(finalUploadPath, arrayBuffer, headers);
      return value;
    } finally {
      // 确保文件句柄在任何情况下都会被关闭
      fs.closeSync(file);
    }
  }

  /**
   * 从 WebDAV 下载文件并通过系统文件选择器保存到本地文件夹（默认为应用下载文件夹）
   * @param remotePath WebDAV 服务器上的文件路径
   * @param fileName 可选，强制使用此文件名。格式为 "xxx.yyy"
   * @returns {Promise<boolean>} 返回一个 Promise，成功时解析为 true，失败时抛出错误
   */
  async downloadFile(remotePath: string, fileName?: string, downType: 'download' | 'user' = 'download'): Promise<boolean> {
    // 确定最终的文件名和后缀
    const getFileNameAndSuffix = (input?: string): { name: string; suffix: string } => {
      // 如果有传入的 fileName，解析文件名及后缀
      if (input) {
        const lastDotIndex = input.lastIndexOf('.');
        if (lastDotIndex > 0) {
          return { name: input.substring(0, lastDotIndex), suffix: input.substring(lastDotIndex + 1) };
        }
        // 如果 fileName 没有后缀，就整个作为名字，后缀为空
        return { name: input, suffix: '' };
      }

      // 如果没有传入 fileName，就从 remotePath 中提取
      const pathParts = remotePath.split('/');
      const fullFileName = pathParts[pathParts.length - 1];
      const lastDotIndexInPath = fullFileName.lastIndexOf('.');
      if (lastDotIndexInPath > 0) {
        return { name: fullFileName.substring(0, lastDotIndexInPath), suffix: fullFileName.substring(lastDotIndexInPath + 1) };
      }
      // 如果 path 中的文件也没有后缀
      return { name: fullFileName, suffix: '' };
    };

    const { name: finalName, suffix: finalSuffix } = getFileNameAndSuffix(fileName);

    // 配置并启动文件保存选择器
    const filePicker = new picker.DocumentViewPicker(this.context);
    const saveOptions = new picker.DocumentSaveOptions();

    // 设置默认文件名
    saveOptions.newFileNames = [finalName + (finalSuffix ? `.${finalSuffix}` : '')];

    // 设置文件类型过滤器
    // 'XX|.yyy' 中的 XX 是给用户看的描述，可以自定义，比如 "JSON文件" 或 "配置文件"
    // 如果没有后缀，就提供一个通用的 "所有文件" 选项
    if (finalSuffix) {
      saveOptions.fileSuffixChoices = [`文件|.${finalSuffix}`];
    } else {
      saveOptions.fileSuffixChoices = ['所有文件|.*'];
    }

    // 设置为下载模式，默认为直接在 Download 目录下创建一个以应用包名命名的文件夹
    saveOptions.pickerMode = downType === 'user' ? picker.DocumentPickerMode.DEFAULT :
      picker.DocumentPickerMode.DOWNLOAD

    try {
      // 拉起文件选择器，让用户确认保存位置（默认状态下，不会拉起弹窗，系统自动处理）
      const result = await filePicker.save(saveOptions);
      if (result.length === 0) {
        throw new Error('用户取消了文件保存');
      }

      // 获取数据并写入文件
      // 从 WebDAV 服务器获取文件数据
      const getResponse = await this.webdavClient.get(remotePath);
      if (getResponse.statusCode !== 200) {
        throw new Error(`从服务器获取文件失败，状态码: ${getResponse.statusCode}`);
      }

      // picker.save 返回的是一个目录 URI，需要拼接文件名
      const directoryUri = result[0];
      const fileUriToSave = `${directoryUri}/${finalName}.${finalSuffix}`;
      const localPath = new fileUri.FileUri(fileUriToSave).path;
      this.logger.info('WebDavManager.downloadFile', `将要保存的路径-uri：${localPath}`, {
        remotePath,
        localPath,
        finalName,
        finalSuffix
      });

      // 创建或打开文件，准备写入
      const file = fs.openSync(localPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);

      // 将数据写入文件
      fs.writeSync(file.fd, getResponse.data as ArrayBuffer);

      // 确保数据同步到存储设备
      fs.fsyncSync(file.fd);

      // 关闭文件
      fs.closeSync(file);

      this.logger.info('WebDavManager.downloadFile', '文件下载并保存成功', {
        remotePath,
        localPath
      });
      return true;
    } catch (err) {
      const error = err as BusinessError;
      this.logger.error('WebDavManager.downloadFile', '获取并保存失败', {
        error: error.message,
        name: error.name,
        remotePath
      });
      // 重新抛出错误，让调用者能够处理
      throw new Error(`获取并保存失败: ${error.message}`);
    }
  }

  /**
   * 获取远程文本文件的完整内容
   * 注意：此方法会将整个文件读入内存，不适合用于大文件
   * @param path WebDAV 服务器上的文件路径
   * @param headers 可选的额外请求头
   * @returns {Promise<string>} 返回一个 Promise，解析为文件的文本内容
   * @throws {Error} 当网络请求失败、状态码非 200 或文件解码失败时抛出错误
   */
  async getTextFileContent(path: string, headers?: rcp.RequestHeaders): Promise<string> {
    try {
      const response = await this.webdavClient.get(path, headers);

      // 检查 HTTP 状态码，确保请求成功
      if (response.statusCode !== 200) {
        throw new Error(`获取文件失败，服务器返回状态码: ${response.statusCode}`);
      }

      // 检查响应数据是否存在
      if (!response.data) {
        throw new Error('获取文件失败，响应体为空');
      }

      // 使用 TextDecoder 将 ArrayBuffer 解码为字符串
      // "utf-8" 是最通用的编码，ignoreBOM: true 可以避免某些文件开头的 BOM 字符干扰
      const textDecoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const str = textDecoder.decodeToString(new Uint8Array(response.data as ArrayBuffer));

      return str;
    } catch (err) {
      // 错误处理
      const error = err as BusinessError;
      const errorMessage = error?.message || String(err);
      this.logger.error('WebDavManager.getTextFileContent', '获取文本文件内容失败', {
        path,
        error: errorMessage
      });
      // 重新抛出带有更多上下文的错误
      this.handleError('获取文本文件内容', err)
    }
  }


  /**
   * 检查文件上传能力
   */
  async checkUploadCapability(): Promise<boolean> {
    this.logger.info('WebDavManager.checkUploadCapability', '检查文件上传能力...');

    try {
      // 尝试上传一个小的测试文件
      const testPath = `/test_upload_${Date.now()}.txt`;
      const testData = buffer.from('test', 'utf-8').buffer as ArrayBuffer;

      const response = await this.webdavClient.put(testPath, testData, {
        'Content-Type': 'text/plain'
      });

      // 清理测试文件
      if (response.statusCode === 201 || response.statusCode === 204) {
        await this.webdavClient.delete(testPath);
        this.logger.info('WebDavManager.checkUploadCapability', '✅ 服务器支持PUT上传');
        return true;
      }
    } catch (error) {
      this.logger.warn('WebDavManager.checkUploadCapability', '❌ 服务器不支持PUT上传', {
        error: error.message
      });
    }

    return false;
  }

  /**
   * 检查服务器支持的HTTP方法
   * 结合OPTIONS和实际测试来准确判断
   */
  async checkSupportedMethods(checkByTest: boolean): Promise<string[]> {
    this.logger.info('WebDavManager.checkSupportedMethods', '检查服务器支持的HTTP方法...');

    let supportedMethods: string[] = [];

    // 从OPTIONS获取基础方法列表
    try {
      const response = await this.webdavClient._request('OPTIONS', '/', undefined, {
        'Accept': '*/*'
      });

      const allowHeader = response.headers['Allow'] || response.headers['allow'];
      if (allowHeader && typeof allowHeader == 'string') {
        supportedMethods = allowHeader.split(',').map(method => method.trim().toUpperCase());
        this.logger.info('WebDavManager.checkSupportedMethods', 'OPTIONS返回的方法', {
          methods: supportedMethods
        });
      }
    } catch (error) {
      this.logger.warn('WebDavManager.checkSupportedMethods', 'OPTIONS请求失败', {
        error: error.message
      });
    }

    // 实际测试关键方法
    if (checkByTest) {
      const criticalMethods = ['MKCOL', 'PUT', 'GET'];
      const testResults: { [key: string]: boolean } = {};

      for (const method of criticalMethods) {
        testResults[method] = await this.testMethodSupport(method);
        if (testResults[method] && !supportedMethods.includes(method)) {
          supportedMethods.push(method);
          this.logger.info('WebDavManager.checkSupportedMethods', `✅ 实测发现支持 ${method} 方法，已添加到列表`, {
            method,
            supportedMethods
          });
        }
      }
    }

    this.logger.info('WebDavManager.checkSupportedMethods', '✅ 最终支持的方法', {
      supportedMethods
    });
    return supportedMethods;
  }

  /**
   * 实际测试某个HTTP方法是否支持
   */
  private async testMethodSupport(method: string): Promise<boolean> {
    this.logger.info('WebDavManager.testMethodSupport', `测试 ${method} 方法支持...`);

    try {
      let response: WebDavResponse;
      const testPath = `/test_${method.toLowerCase()}_${Date.now()}`;

      switch (method) {
        case 'MKCOL':
          // 测试MKCOL - 创建临时目录
          response = await this.webdavClient.mkcol(testPath);
          if (response.statusCode === 201) {
            // 清理测试目录
            await this.webdavClient.delete(testPath);
            this.logger.info('WebDavManager.testMethodSupport', `✅ ${method} 方法支持`);
            return true;
          }
          break;

        case 'PUT':
          // 测试PUT - 上传临时文件
          const testData = buffer.from('test', 'utf-8').buffer as ArrayBuffer;
          response = await this.webdavClient.put(testPath, testData);
          if (response.statusCode === 201) {
            // 清理测试文件
            await this.webdavClient.delete(testPath);
            this.logger.info('WebDavManager.testMethodSupport', `✅ ${method} 方法支持`);
            return true;
          }
          break;

        case 'GET':
          // 测试GET - 尝试获取根目录
          response = await this.webdavClient.get('/');
          if (response.statusCode === 200 || response.statusCode === 207) {
            this.logger.info('WebDavManager.testMethodSupport', `✅ ${method} 方法支持`);
            return true;
          }
          break;
      }
    } catch (error) {
      this.logger.warn('WebDavManager.testMethodSupport', `❌ ${method} 方法不支持`, {
        method,
        error: error.message
      });
    }

    return false;
  }

  /**
   * 获取服务器能力报告
   */
  async getServerCapabilityReport(checkByTest: boolean = false): Promise<{
    supportsWebDAV: boolean;
    supportedMethods: string[];
    canCreateDirectories: boolean;
    canUploadFiles: boolean;
    canDownloadFiles: boolean;
    recommendations: string[];
    mkcolTestResult?: {
      supported: boolean;
      statusCode?: number;
      tested: boolean;
    };
  }> {
    this.logger.info('WebDavManager.getServerCapabilityReport', '生成服务器能力报告...');

    const supportedMethods = await this.checkSupportedMethods(checkByTest);
    const canUploadFiles = supportedMethods.includes('PUT') || await this.checkUploadCapability();
    const canDownloadFiles = supportedMethods.includes('GET');

    // 特别测试MKCOL
    const mkcolTestResult = {
      supported: false,
      statusCode: undefined as number | undefined,
      tested: false
    };

    if (checkByTest) {
      try {
        const testPath = `/test_mkcol_${Date.now()}`;
        const response = await this.webdavClient.mkcol(testPath);
        mkcolTestResult.tested = true;
        mkcolTestResult.statusCode = response.statusCode;
        mkcolTestResult.supported = response.statusCode === 201;

        // 清理测试目录
        if (mkcolTestResult.supported) {
          await this.webdavClient.delete(testPath);
        }
      } catch (error) {
        mkcolTestResult.tested = true;
        this.logger.warn('WebDavManager.getServerCapabilityReport', 'MKCOL测试失败', {
          error: error.message
        });
      }
    }

    const report = {
      supportsWebDAV: supportedMethods.length > 5,
      supportedMethods,
      canCreateDirectories: mkcolTestResult.supported,
      canUploadFiles,
      canDownloadFiles,
      recommendations: [] as string[],
      mkcolTestResult
    };

    // 生成建议
    if (!report.canCreateDirectories) {
      if (mkcolTestResult.tested) {
        report.recommendations.push('服务器实测不支持MKCOL方法，建议检查服务器配置');
      } else {
        report.recommendations.push('默认无法测试MKCOL方法，建议手动开启深度测试，但要特别注意，部分WebDAV服务器无法清理根目录的文件夹，因此存在根目录的测试文件夹无法自动删除的状况');
      }
    }

    if (!report.canUploadFiles) {
      report.recommendations.push('服务器不支持PUT方法，无法上传文件');
    }

    if (!report.canDownloadFiles) {
      report.recommendations.push('服务器不支持GET方法，无法下载文件');
    }

    if (report.recommendations.length === 0) {
      report.recommendations.push('服务器配置完整，支持所有基本WebDAV操作');
    }

    this.logger.info('WebDavManager.getServerCapabilityReport', `服务器能力报告 ${JSON.stringify(report, null, 2)}`);
    return report;
  }


  /**
   * 解析 XML 字符串为对象（修复文本重复问题）
   * @param xmlString XML 字符串
   * @returns 解析后的对象
   */
  private static parseXml(xmlString: string): Record<string, Object> {
    const textEncoder: util.TextEncoder = new util.TextEncoder();
    const arrBuffer: Uint8Array = textEncoder.encodeInto(xmlString);
    const xmlParser: xml.XmlPullParser = new xml.XmlPullParser(arrBuffer.buffer as object as ArrayBuffer, 'UTF-8');

    let result: Record<string, Object> = {};
    let current: Record<string, Object> | null = null;
    const stack: Record<string, Object>[] = [];

    // 事件类型回调
    const tokenValueCallbackFunction = (eventType: xml.EventType, parseInfo: xml.ParseInfo): boolean => {
      switch (eventType) {
        case xml.EventType.START_DOCUMENT:
          result = {};
          break;
        case xml.EventType.START_TAG:
          const tagName = parseInfo.getName();
          const element: Record<string, Object> = {};
          if (current) {
            if (!current[tagName]) {
              current[tagName] = element;
            } else if (Array.isArray(current[tagName])) {
              (current[tagName] as Record<string, Object>[]).push(element);
            } else {
              current[tagName] = [current[tagName] as Record<string, Object>, element];
            }
            stack.push(current);
          } else {
            result = element;
          }
          current = element;
          break;
        case xml.EventType.TEXT:
          // 只在这里处理文本，避免重复
          const text = parseInfo.getText();
          if (current && text.trim() !== '') {
            current['_text'] = (current['_text'] || '') + text;
          }
          break;
        case xml.EventType.END_TAG:
          if (stack.length > 0) {
            current = stack.pop()!;
          } else {
            current = null;
          }
          break;
        case xml.EventType.END_DOCUMENT:
          break;
      }
      return true;
    };

    const options: xml.ParseOptions = {
      supportDoctype: true,
      ignoreNameSpace: true,
      tokenValueCallbackFunction
    };

    xmlParser.parseXml(options);
    return result;
  }

  /**
   * 安全地从嵌套对象中获取字符串值（兼容任意前缀）
   * @param obj 目标对象
   * @param path 属性路径，例如 ['href', 'displayname'] (注意：不需要带前缀)
   * @returns 找到的字符串，否则返回空字符串
   */
  private static safeGetString(obj: Object | null | undefined, path: string[]): string {
    if (!obj || typeof obj !== 'object' || path.length === 0) {
      return '';
    }
    let current: Object = obj;
    for (const key of path) {
      if (current && typeof current === 'object') {
        let found = false;
        // 遍历所有键，进行后缀匹配
        for (const objKey in current) {
          if (objKey.endsWith(`:${key}`) || objKey === key) {
            current = (current as Record<string, Object>)[objKey];
            found = true;
            break;
          }
        }
        if (!found) {
          return ''; // 路径中断
        }
      } else {
        return '';
      }
    }
    // 检查是否有 _text 属性
    if (current && typeof current === 'object' && '_text' in current) {
      return (current as Record<string, Object>)['_text'] as string;
    }
    return String(current);
  }

  /**
   * 安全地从嵌套对象中获取对象节点（兼容任意前缀）
   * @param obj 目标对象
   * @param path 属性路径，例如 ['multistatus', 'response'] (注意：不需要带前缀)
   * @returns 找到的对象，否则返回 null
   */
  private static safeGetObject(obj: Object | null | undefined, path: string[]): Record<string, Object> | null {
    if (!obj || typeof obj !== 'object' || path.length === 0) {
      return null;
    }
    let current: Object = obj;
    for (const key of path) {
      if (current && typeof current === 'object') {
        let found = false;
        // 遍历所有键，进行后缀匹配
        for (const objKey in current) {
          if (objKey.endsWith(`:${key}`) || objKey === key) {
            current = (current as Record<string, Object>)[objKey];
            found = true;
            break;
          }
        }
        if (!found) {
          return null; // 路径中断
        }
      } else {
        return null;
      }
    }
    // 检查最终结果是否为对象
    return (current && typeof current === 'object') ? (current as Record<string, Object>) : null;
  }

  /**
   * 从 href 路径中提取文件名或文件夹名
   * @param href 完整的 href 路径，例如 '/dav/XXXBox/file.txt' 或 '/dav/XXXBox/subfolder/'
   * @returns 提取的名称，例如 'file.txt' 或 'subfolder'
   */
  private static extractNameFromHref(href: string): string {
    if (!href) {
      return 'Unknown';
    }
    // 移除末尾的斜杠
    const pathWithoutTrailingSlash = href.endsWith('/') ? href.slice(0, -1) : href;
    // 获取最后一部分
    const parts = pathWithoutTrailingSlash.split('/');
    return parts[parts.length - 1] || 'Unknown';
  }

  /**
   * 防止路径遍历攻击
   */
  private validatePath(path: string): void {
    if (path.includes('..') || path.includes('~')) {
      throw new Error('Invalid path: path traversal detected');
    }
  }

  /**
   * 检查文件夹是否存在
   */
  private async checkDirectoryExists(path: string): Promise<boolean> {
    try {
      const response = await this.webdavClient.propfind(path, '0', ['resourcetype']);
      return response.statusCode === 207;
    } catch {
      return false;
    }
  }

  /**
   * 统一错误处理
   */
  private handleError(operation: string, err: any): never {
    const error = err as BusinessError;
    this.logger.error('WebDavManager.handleError', `${operation}失败`, {
      operation,
      error: error.message,
      code: error.code
    });
    throw new Error(`${operation}失败:${error.message} (code: ${error.code})`);
  }

}

/**
 * 根据文件扩展名获取 Content-Type
 * @param fileName 文件名
 * @returns 对应的 Content-Type，默认为 'application/octet-stream'
 */
function getContentType(fileName: string): string {
  const ext = fileName.split('.').pop()?.toLowerCase();
  switch (ext) {
    case 'json':
      return 'application/json';
    case 'js':
      return 'application/javascript';
    case 'css':
      return 'text/css';
    case 'html':
      return 'text/html';
    case 'txt':
      return 'text/plain';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'pdf':
      return 'application/pdf';
    case 'zip':
      return 'application/zip';
    default:
    // 对于未知类型，使用通用二进制流类型
      return 'application/octet-stream';
  }
}
