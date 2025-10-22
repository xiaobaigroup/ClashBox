import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { buffer, util } from '@kit.ArkTS';
import { ConnectionTestResult, WebDavConfig, WebDavResponse } from './config';
import { WebDavLogger } from './logger';

/**
 * WebDAV 客户端类
 */
export class WebDavClient {

  private config: WebDavConfig;
  private logger: WebDavLogger;
  private session: rcp.Session;
  private authHeaders: rcp.RequestHeaders;
  private static readonly DEFAULT_HEADERS: rcp.RequestHeaders = {
    'Accept': 'application/xml, text/xml',
    'User-Agent': 'HarmonyOS-WebDAV-Client/1.0'
  };

  /**
   * 构造函数，用于创建 WebDAV 客户端实例
   * @param config WebDAV 配置
   */
  constructor(config: WebDavConfig) {
    this.config = config;
    this.authHeaders = this.buildAuthHeaders();
    this.logger = WebDavLogger.getInstance();  // 获取全局实例
    this.logger.info('WebDavClient', 'WebDavClient初始化', { serverUrl: config.baseUrl });
    this.session = rcp.createSession();
    this.logger.info('WebDavClient', 'RCP Session已创建');
  }

  // ==================== WebDAV 基础操作方法 ====================
  /**
   * 测试与 WebDAV 服务器的连通性
   * 此方法会向服务器根路径发送一个 PROPFIND 请求来验证连接、认证和服务器类型
   * @returns {Promise<ConnectionTestResult>} 返回一个 Promise，解析为详细的测试结果
   */
  public async testConnection(): Promise<ConnectionTestResult> {
    // 测试根路径是通用做法
    const url = this.buildUrl('/');

    // PROPFIND 请求需要 Depth 头，0 表示只请求当前目录的属性
    const headers: rcp.RequestHeaders = {
      ...this.buildAuthHeaders(),
      'Depth': '0'
    };

    // 创建一个最小的 PROPFIND 请求体
    const propfindXml = `<?xml version="1.0" encoding="utf-8" ?>
      <D:propfind xmlns:D="DAV:">
        <D:prop>
          <D:resourcetype />
        </D:prop>
      </D:propfind>`;

    const requestBody = buffer.from(propfindXml, 'utf-8').buffer as ArrayBuffer;

    const request = new rcp.Request(url, 'PROPFIND', headers, requestBody);

    try {
      const response = await this.session.fetch(request);
      const statusCode = response.statusCode;

      // 根据状态码判断结果
      if (statusCode === 207) {
        // 207 Multi-Status 是 WebDAV PROPFIND 请求的标准成功响应
        return {
          success: true,
          message: '连接成功：WebDAV服务器有效',
          statusCode: statusCode
        };
      } else if (statusCode === 401) {
        // 401 Unauthorized 表示服务器可达，但用户名或密码错误
        return {
          success: false,
          message: '认证失败：请检查用户名和密码是否正确',
          statusCode: statusCode
        };
      } else if (statusCode === 405) {
        // 405 Method Not Allowed 表示服务器可达，但可能不支持 WebDAV
        return {
          success: false,
          message: '连接失败：服务器不支持 WebDAV 协议',
          statusCode: statusCode
        };
      } else if (statusCode >= 200 && statusCode < 300) {
        // 其他 2xx 状态码，说明服务器可达，但不是标准的 WebDAV 响应
        return {
          success: false,
          message: '连接失败：服务器响应正常，但不是 WebDAV 服务',
          statusCode: statusCode
        };
      } else {
        // 其他错误状态码
        return {
          success: false,
          message: `服务器返回错误：HTTP ${statusCode}`,
          statusCode: statusCode
        };
      }
    } catch (err) {
      // 捕获网络错误、DNS 解析失败等
      const error = err as BusinessError;
      const errorMessage = error?.message || String(err);
      this.logger.error('WebDavClient.testConnection', `网络请求失败: ${errorMessage}`, {
        error: errorMessage,
        url: url
      });
      return {
        success: false,
        message: `网络连接失败：${errorMessage}`
      };
    }
  }

  /**
   * 获取资源属性, 一个或多个资源的属性（如文件名、大小等）
   * @param {string} path - 要查询的资源路径，'/' 表示根目录
   * @param {'0' | '1' | 'infinity'} [depth='0'] - 查询深度
   *   - '0': 仅查询指定路径的资源
   *   - '1': 查询指定路径及其直接子项
   *   - 'infinity': 查询指定路径及其所有子项
   * @param {string[]} [props] - 要查询的属性名数组，如 ['displayname', 'getcontentlength']
   * @param {rcp.RequestHeaders} [headers] - 可选的额外请求头
   * @returns {Promise<WebDavResponse>} 返回一个 Promise，解析为 WebDAV xml返回值
   * - `207 Multi-Status`: 请求成功，响应体为包含各资源属性的 XML
   * - `401 Unauthorized`: 认证失败
   * - `403 Forbidden`: 权限不足
   * - `404 Not Found`: 指定的路径不存在
   * - `405 Method Not Allowed`: 服务器不支持 PROPFIND 方法
   */
  async propfind(path: string, depth: '0' | '1' | 'infinity' = '1', props?: string[], headers?: rcp.RequestHeaders): Promise<WebDavResponse> {
    const body = WebDavClient.buildPropfindXml(props);
    this.logger.debug('WebDavClient.propfind', `准备列出目录的完整 URL: ${this.buildUrl(path)}`, {
      path,
      depth,
      url: this.buildUrl(path)
    });

    const finalHeaders: rcp.RequestHeaders = {};
    if (headers) {
      for (const key of Object.keys(headers)) {
        finalHeaders[key] = headers[key];
      }
    }
    finalHeaders['Depth'] = depth;
    const listResponse = await this._request('PROPFIND', path, body, finalHeaders)
    return listResponse
  }

  /**
   * 创建文件夹
   * @param path 文件夹相对路径，例如 '/new_folder'
   * @param headers 额外请求头
   *  * @returns {Promise<WebDavResponse>} 返回一个 Promise，解析为 WebDAV 操作结果
   * - `201 Created`: 文件夹创建成功
   * - `401 Unauthorized`: 认证失败，用户名或密码错误
   * - `403 Forbidden`: 权限不足，当前用户无权创建文件夹
   * - `405 Method Not Allowed`: 服务器不支持 MKCOL 方法
   * - `409 Conflict`: 文件夹已存在
   * - `507 Insufficient Storage`: 服务器存储空间不足
   */
  async mkcol(path: string, headers?: rcp.RequestHeaders): Promise<WebDavResponse> {
    return this._request('MKCOL', path, undefined, headers);
  }

  /**
   * 删除指定的文件或文件夹
   * @param {string} path - 要删除的资源相对路径，例如 '/folder/file.txt'
   * @param {rcp.RequestHeaders} [headers] - 可选的额外请求头
   * @returns {Promise<WebDavResponse>} 返回一个 Promise，解析为 WebDAV 操作结果
   * - `204 No Content`: 资源删除成功
   * - `400 Bad Request`：客户端错误，请求格式或语法问题，服务器拒绝处理
   * - `401 Unauthorized`: 认证失败
   * - `403 Forbidden`: 权限不足
   * - `404 Not Found`: 要删除的资源不存在
   * - `405 Method Not Allowed`: 服务器不支持 DELETE 方法
   * - `423 Locked`: 资源被锁定，无法删除
   */
  async delete(path: string, headers?: rcp.RequestHeaders): Promise<WebDavResponse> {
    return this._request('DELETE', path, undefined, headers);
  }

  /**
   * 获取指定文件的内容（二进制格式）
   * @param {string} path - 要下载的文件相对路径，例如 '/folder/image.png'
   * @param {rcp.RequestHeaders} [headers] - 可选的额外请求头
   * @returns {Promise<WebDavResponse>} 返回一个 Promise，解析为 WebDAV 操作结果
   * - `200 OK`: 文件下载成功，`response.data` 包含文件的二进制内容
   * - `401 Unauthorized`: 认证失败
   * - `403 Forbidden`: 权限不足
   * - `404 Not Found`: 文件不存在
   * - `409 Request Error`: 请求链接错误
   */
  async get(path: string, headers?: rcp.RequestHeaders): Promise<WebDavResponse> {
    return this._request('GET', path, undefined, headers, true);
  }


  /**
   * 上传文件。如果文件已存在，则会覆盖
   * @param {string} path - 文件保存的相对路径，例如 '/folder/file.txt'
   * @param {ArrayBuffer} data - 文件的二进制数据
   * @param {rcp.RequestHeaders} [headers] - 可选的额外请求头，例如 'Content-Type'
   * @returns {Promise<WebDavResponse>} 返回一个 Promise，解析为 WebDAV 操作结果
   * - `201 Created`: 文件是新建的，上传成功
   * - `204 No Content`: 文件已存在并被成功覆盖
   * - `400 Bad Request`: 请求错误，请检查Headers
   * - `401 Unauthorized`: 认证失败
   * - `403 Forbidden`: 权限不足
   * - `404 Not Found`: 父目录不存在
   * - `409 Conflict`: 可能由于其他原因（如锁定）导致冲突
   * - `507 Insufficient Storage`: 服务器存储空间不足
   */
  async put(path: string, data: ArrayBuffer, headers?: rcp.RequestHeaders): Promise<WebDavResponse> {
    return this._request('PUT', path, data, headers);
  }

  /**
   * 将资源从WebDav一个位置复制到另一个位置
   * @param {string} sourcePath - 源资源的相对路径，例如 '/source/file.txt'
   * @param {string} destinationPath - 目标位置的相对路径，例如 '/destination/file_copy.txt'
   * @param {'T' | 'F'} [overwrite='F'] - 是否覆盖目标位置已存在的文件
   *   - 'T': 如果目标文件存在，则覆盖
   *   - 'F': 如果目标文件存在，则操作失败
   * @param {rcp.RequestHeaders} [headers] - 可选的额外请求头
   * @returns {Promise<WebDavResponse>} 返回一个 Promise，解析为 WebDAV 操作结果
   * - `201 Created`: 目标文件是新创建的，复制成功
   * - `204 No Content`: 目标文件已存在并被成功覆盖
   * - `401 Unauthorized`: 认证失败
   * - `403 Forbidden`: 权限不足
   * - `404 Not Found`: 源文件不存在
   * - `405 Method Not Allowed`: 服务器不支持 COPY 方法
   * - `409 Conflict` 或 `412 Precondition Failed`: 目标文件已存在且 `overwrite` 设置为 'F'
   * - `423 Locked`: 源或目标资源被锁定
   */
  async copy(sourcePath: string, destinationPath: string, overwrite: 'T' | 'F' = 'F', headers?: rcp.RequestHeaders): Promise<WebDavResponse> {
    const finalHeaders: rcp.RequestHeaders = {};
    if (headers) {
      for (const key of Object.keys(headers)) {
        finalHeaders[key] = headers[key];
      }
    }
    finalHeaders['Destination'] = this.buildUrl(destinationPath);
    finalHeaders['Overwrite'] = overwrite;
    return this._request('COPY', sourcePath, undefined, finalHeaders);
  }

  /**
   * 将资源从WebDav一个位置移动到另一个位置（可用于重命名）
   * @param {string} sourcePath - 源资源的相对路径，例如 '/old_name.txt'
   * @param {string} destinationPath - 目标位置的相对路径，例如 '/new_name.txt'
   * @param {'T' | 'F'} [overwrite='F'] - 是否覆盖目标位置已存在的文件
   *   - 'T': 如果目标文件存在，则覆盖
   *   - 'F': 如果目标文件存在，则操作失败
   * @param {rcp.RequestHeaders} [headers] - 可选的额外请求头
   * @returns {Promise<WebDavResponse>} 返回一个 Promise，解析为 WebDAV 操作结果
   * - `201 Created`: 目标文件是新创建的，移动成功
   * - `204 No Content`: 目标文件已存在并被成功覆盖
   * - `401 Unauthorized`: 认证失败
   * - `403 Forbidden`: 权限不足
   * - `404 Not Found`: 源文件不存在
   * - `405 Method Not Allowed`: 服务器不支持 MOVE 方法
   * - `409 Conflict` 或 `412 Precondition Failed`: 目标文件已存在且 `overwrite` 设置为 'F'
   * - `423 Locked`: 源或目标资源被锁定
   */
  async move(sourcePath: string, destinationPath: string, overwrite: 'T' | 'F' = 'F', headers?: rcp.RequestHeaders): Promise<WebDavResponse> {
    const finalHeaders: rcp.RequestHeaders = {};
    if (headers) {
      for (const key of Object.keys(headers)) {
        finalHeaders[key] = headers[key];
      }
    }
    finalHeaders['Destination'] = this.buildUrl(destinationPath);
    finalHeaders['Overwrite'] = overwrite;
    return this._request('MOVE', sourcePath, undefined, finalHeaders);
  }

  // ==================== 核心请求方法 ====================
  // _request 方法，自动处理 URL 和认证
  async _request(
    method: string,
    path: string,
    body?: string | ArrayBuffer,
    headers?: rcp.RequestHeaders,
    expectBinary: boolean = false
  ): Promise<WebDavResponse> {
    const url = this.buildUrl(path);

    // 合并 headers
    const finalHeaders: rcp.RequestHeaders = { ...WebDavClient.DEFAULT_HEADERS };

    // 添加认证头
    if (this.authHeaders) {
      Object.assign(finalHeaders, this.authHeaders);
    }

    // 添加自定义头（但不要覆盖 Content-Length）
    if (headers) {
      for (const key of Object.keys(headers)) {
        if (key.toLowerCase() !== 'content-length') {
          finalHeaders[key] = headers[key];
        }
      }
    }

    // 根据 body 动态设置 Content-Length
    if (body && !finalHeaders['Content-Length']) {
      if (typeof body === 'string') {
        finalHeaders['Content-Length'] = body.length.toString();
      } else if (body instanceof ArrayBuffer) {
        finalHeaders['Content-Length'] = body.byteLength.toString();
      }
    }

    let buffer: Uint8Array = new Uint8Array(0);
    let binaryBuffer: ArrayBuffer = new ArrayBuffer(0);
    let responseHeaders: rcp.ResponseHeaders = {};
    let statusCode: number = 0;

    this.logger.debug('WebDavClient._request', `请求方法: ${method}`, { method });
    this.logger.debug('WebDavClient._request', `请求URL: ${url}`, { url });
    this.logger.debug('WebDavClient._request', `请求头: ${JSON.stringify(finalHeaders)}`, {
      headers: finalHeaders,
      hasBody: !!body,
      expectBinary,
      contentLength: finalHeaders['Content-Length']
    });


    const customHttpEventsHandler: rcp.HttpEventsHandler = {
      onDataReceive: (incomingData: ArrayBuffer) => {
        if (expectBinary) {
          const newBuffer = new ArrayBuffer(binaryBuffer.byteLength + incomingData.byteLength);
          const newView = new Uint8Array(newBuffer);
          newView.set(new Uint8Array(binaryBuffer), 0);
          newView.set(new Uint8Array(incomingData), binaryBuffer.byteLength);
          binaryBuffer = newBuffer;
        } else {
          const chunk = new Uint8Array(incomingData);
          const newBuffer = new Uint8Array(buffer.length + chunk.length);
          newBuffer.set(buffer);
          newBuffer.set(chunk, buffer.length);
          buffer = newBuffer;
        }
      },
      onDataEnd: () => {
        // 数据接收完毕，后续在 fetch Promise 中统一处理
      },
      onHeaderReceive: (headers: rcp.ResponseHeaders) => {
        responseHeaders = headers;
      }
    };

    const tracingConfig: rcp.TracingConfiguration = {
      verbose: true,
      infoToCollect: {
        incomingData: true,
        outgoingData: true,
        incomingHeader: true,
        outgoingHeader: true
      },
      collectTimeInfo: true,
      httpEventsHandler: customHttpEventsHandler
    };

    try {
      // 先销毁再创建
      this.destroy()
      this.session = rcp.createSession({
        requestConfiguration: {
          tracing: tracingConfig
        }
      });
      this.logger.info('WebDavClient._request', 'RCP Session已重新创建');
      const request = new rcp.Request(url, method, finalHeaders, body);
      try {
        const response = await this.session.fetch(request);
        statusCode = response.statusCode;
        this.logger.info('WebDavClient._request', `响应状态码: ${statusCode}`, {
          statusCode,
          method,
          url
        });
        this.logger.info('WebDavClient._request', `响应头: ${JSON.stringify(response.headers)}`, {
          responseHeaders: response.headers
        });

        // 检查服务器返回的错误信息
        if (statusCode === 405) {
          const allowHeader = response.headers['Allow'] || response.headers['allow'];
          if (allowHeader) {
            this.logger.info('WebDavClient._request', `服务器支持的方法: ${allowHeader}`, {
              allowHeader,
              method
            });
          }

          const serverHeader = response.headers['Server'] || response.headers['server'];
          if (serverHeader) {
            this.logger.info('WebDavClient._request', `服务器类型: ${serverHeader}`, {
              serverHeader
            });
          }
        }
        const responseData = expectBinary ? binaryBuffer : util.TextDecoder.create('utf-8').decodeWithStream(buffer);
        return {
          statusCode,
          headers: responseHeaders,
          data: responseData
        };
      } catch (err) {
        this.logger.error('WebDavClient._request', `session.fetch失败`, {
          error: (err as Error).message,
          method,
          url
        });
        throw new Error(`session.fetch失败，message: ${(err as Error).message}`)
      }
    } catch (error) {
      this.logger.error('WebDavClient._request', `rcp.Request失败`, {
        error: (error as Error).message,
        method,
        url
      });
      throw new Error(`rcp.Request失败，message: ${(error as Error).message}`)
    }
  }

  // ==================== 辅助方法 ====================
  /**
   * 获取基础 URL
   */
  public getBaseUrl(): string {
    return this.config.baseUrl;
  }

  /**
   * 拼接完整的 URL
   * @param path 资源相对路径，例如 '/folder/file.txt'
   * @returns 完整的 URL
   */
  public buildUrl(path: string): string {
    const baseUrl = this.config.baseUrl.endsWith('/') ? this.config.baseUrl : `${this.config.baseUrl}/`;

    let normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    // 检查并移除重复的基础路径
    const baseUrlPath = baseUrl.replace(/^https?:\/\/[^\/]+/, ''); // 提取路径部分，如 "/dav/"
    if (baseUrlPath && normalizedPath.startsWith(baseUrlPath)) {
      normalizedPath = normalizedPath.substring(baseUrlPath.length);
      this.logger.warn('WebDavClient.buildUrl', '检测到重复路径，已自动修正', {
        originalPath: path,
        correctedPath: normalizedPath,
        baseUrlPath
      });
    }

    const finalUrl = `${baseUrl}${normalizedPath}`;

    this.logger.debug('WebDavClient.buildUrl', '构建URL', {
      originalPath: path,
      normalizedPath,
      finalUrl
    });

    return finalUrl;
  }


  /**
   * 销毁WebDAV客户端并释放底层网络资源
   * 在客户端不再使用时应调用此方法
   */
  public destroy(): void {
    if (this.session) {
      this.session.close(); // 调用框架的销毁方法
      this.logger.warn('WebDavClient', 'RCP Session已销毁');
    }
  }

  /**
   * 根据配置构建认证头
   */
  private buildAuthHeaders(): rcp.RequestHeaders {
    if (this.config.authType === 'basic' && this.config.username && this.config.password) {
      const credentials: string = `${this.config.username}:${this.config.password}`;
      const encoder: util.TextEncoder = new util.TextEncoder();
      const base64: string = new util.Base64Helper().encodeToStringSync((encoder.encodeInto(credentials)))
      return { 'Authorization': `Basic ${base64}` };
    }
    return {};
  }

  /**
   * 构建XML
   */
  private static buildPropfindXml(props: string[] = ['displayname', 'getcontentlength', 'getlastmodified']): string {
    const propsXml = props.map(prop => `<D:${prop}/>`).join('\n    ');
    return `<?xml version="1.0" encoding="utf-8" ?>
<D:propfind xmlns:D="DAV:">
  <D:prop>
    ${propsXml}
  </D:prop>
</D:propfind>`;
  }
}
