import fs from '@ohos.file.fs';
import { getProfilePath, getProfilesPath } from './appPath';
import { Context } from '@kit.AbilityKit';
import { fileUri } from '@kit.CoreFileKit';
import { ProxyGroup, ProxyType, SubscriptionInfo } from './models/Common';
import { JSON, taskpool, util } from '@kit.ArkTS';
import { http } from '@kit.NetworkKit';
import { parse, YAMLError } from 'yaml'

/**
 * 在后台线程中解析 YAML 内容
 * @param content - 待解析的 YAML 字符串内容
 * @returns 解析成功返回 true，失败返回 false
 */
@Concurrent
function parseYAMLInBackground(content: string): boolean {
  try {
    parse(content);
    return true;
  } catch (e) {
    console.error("TaskPool YAML parse error:", e);
    return false;
  }
}

export function generateUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

export enum ProfileType {
  File,
  Url,
  External
}

let utf8e = new util.TextEncoder()
export class Profile {
  id: string
  name: string | null
  type: ProfileType
  url: string = ""
  currentGroupName: string | null = null
  isUpdating: boolean = false
  autoUpdate: boolean = true
  lastUpdateDate: number
  autoUpdateDuration: number
  subscriptionInfo: SubscriptionInfo | null
  proxySelected: Map<string, string> = new Map()
  context?: Context

  constructor(type = ProfileType.Url, url: string) {
    this.id = generateUUID()
    this.name = null
    this.type = type // 0 url
    this.url = url
    this.autoUpdateDuration = 60 * 1000 // 1 分钟
    this.lastUpdateDate = new Date().getTime()
    this.subscriptionInfo = null
  }
  private globalUa: string = "clash.meta/1.19.5"
  loadContext(context: Context | undefined, globalUa: string | undefined = "clash.meta/1.19.5"){
    this.context = context
    this.globalUa = globalUa
  }
  async checkAndUpdate(vailConfig: (config: string) =>Promise<string>): Promise<void>{
    const isExists = await this.check();
    if (!isExists) {
      if (this.url != "") {
        await this.update(vailConfig);
      }
    }
  }
  async check(): Promise<boolean>{
    let profilePath = await getProfilePath(this.context, this.id);
    return await fs.access(profilePath, fs.AccessModeType.EXIST)
  }
  async delete(): Promise<void>{
    if(!await this.check())
      return
    let profileDir = await getProfilesPath(this.context)
    let profilePath = await getProfilePath(this.context, this.id);
    fs.unlink(profilePath)
    fs.unlink(profileDir)
  }
  async update(vailConfig: (config: string) => Promise<string>): Promise<boolean> {
    let httpRequest = http.createHttp();
    const resp = await httpRequest.request(this.url, {
      header: {
        "User-Agent": this.globalUa ?? "clash.meta/1.19.5"
      },
      connectTimeout: 20000,
      readTimeout: 20000,
      maxLimit: 100 * 1024 * 1024,
    });
    const disposition = resp.header["content-disposition"] as string;
    console.debug(`UpdateConfig resp：${JSON.stringify(resp, null, 2)} disposition: ${disposition}`);
    const userinfo = resp.header["subscription-userinfo"] as string;
    if (!this.name || this.name == "") {
      this.name = getFileNameFromDisposition(disposition) ?? this.id;
    }
    if (userinfo) {
      this.subscriptionInfo = SubscriptionInfo.formHString(userinfo);
    }
    console.info(`UpdateConfig this.name: ${this.name} userinfo: ${userinfo}`);
    if (resp.result) {
      // JSON 数据，直接按错误处理
      try {
        let json = JSON.parse(resp.result as string) as object
        let msg = json?.["msg"] as string
        if (msg) {
          throw new Error(msg);
        } else {
          throw new Error("非配置JSON数据");
        }
      } catch (_) {
      }
      const value = await isYAML(resp.result as string | ArrayBuffer);
      console.debug(`UpdateConfig raw is yaml:${value} value: ${JSON.stringify(resp.result)}`);
      if (!value) {
        console.error(`UpdateConfig 非yaml数据，不保存配置`);
        throw new Error("无有效链接数据");
      } else {
        await this.save(resp.result as string | ArrayBuffer, vailConfig);
        return true;
      }
    }
    // 无resp.result，直接抛出
    throw new Error("无响应数据");
  }

  async save(raw: string | ArrayBuffer, vailConfig:(config: string)=> Promise<string>): Promise<Profile>{
    let bytes = new Uint8Array()
    if (typeof raw == "string") {
      bytes= utf8e.encodeInto(raw)
    } else {
      bytes = new Uint8Array(raw)
    }
    const filePath = await getProfilePath(this.context, this.id)
    const tempPath = this.context!.tempDir + "/temp.config";
    const temp = await fs.open(tempPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC)
    await fs.write(temp.fd, bytes.buffer)
    await fs.close(temp.fd)
    let message = await vailConfig(tempPath);
    await fs.unlink(tempPath);
    if (message != "") {
      throw new Error(message);
    }
    const file = await fs.open(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC)
    await fs.write(file.fd, bytes.buffer)
    await fs.fsync(file.fd)
    await fs.close(file.fd)
    this.lastUpdateDate = new Date().getTime()
    return this
  }
  async saveByUri(uri: string): Promise<Profile>{
    const filePath = await getProfilePath(this.context, this.id)
    try {
      await fs.copy(uri, fileUri.getUriFromPath(filePath))
    } catch (error) {
      throw error as Error
    }
    return this
  }
  getSelectedProxy(g: ProxyGroup): string | undefined{
    if (g.type !== ProxyType.Selector)
      return g.now
    let dd = this.proxySelected.get(g.name) ?? g.now
    return dd
  }
  getSelectedMap(): Record<string, string>{
    const jsonObject: Record<string, string> = {};
    this.proxySelected.forEach((value, key) => {
      jsonObject[key] = value;
    });
    return jsonObject
  }
}

async function isYAML(data: string | ArrayBuffer): Promise<boolean> {
  try {
    let content: string;
    if (typeof data === 'string') {
      content = data;
    } else if (data instanceof ArrayBuffer) {
      const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      content = decoder.decodeWithStream(new Uint8Array(data));
    } else {
      return false;
    }

    // 先进行快速的格式校验（在主线程进行轻量级检查）
    const trimmedContent = content.trim();
    // 如果内容是单行的、以 { 开头和 } 结尾的紧凑 JSON，不是典型的 YAML 配置
    if (trimmedContent.startsWith('{') && trimmedContent.endsWith('}') && !trimmedContent.includes('\n')) {
      return false;
    }

    // 使用 TaskPool 在后台线程执行耗时的 YAML 解析
    // 避免大数据量时阻塞 UI 主线程导致卡顿
    const task = new taskpool.Task(parseYAMLInBackground, content);
    const parseResult = await taskpool.execute(task) as boolean;

    if (!parseResult) {
      console.error("YAML 解析失败: TaskPool 解析返回 false");
      return false;
    }

    // 合法 YAML 配置
    return true;

  } catch (e) {
    console.error("YAML 解析失败:", e);
    return false;
  }
}

/**
 * 从 Content-Disposition 响应头中提取文件名
 * @param disposition - Content-Disposition 头的值，
 * @returns {string | null} - 提取到的文件名，如果解析失败返回 null
 */
function getFileNameFromDisposition(disposition: string | null | undefined): string | null {
  if (!disposition) return null;
  // 去除字符串两端的空格
  const cleanDisposition = disposition.trim();
  // 优先尝试解析 RFC 5987 格式
  // 使用更灵活的正则，允许大小写、空格等变化
  const filenameStarRegex = /filename\*\s*=\s*(?:UTF-8|utf-8)\s*''\s*([^;]+)/i;
  const filenameStarMatch = cleanDisposition.match(filenameStarRegex);

  if (filenameStarMatch && filenameStarMatch[1]) {
    // 去除可能的空格并进行 URL 解码
    const encodedFileName = filenameStarMatch[1].trim();
    return decodeURIComponent(encodedFileName);
  }
  // 无 filename*，尝试解析普通的 filename=
  const filenameRegex = /filename\s*=\s*"?([^;"]+)"?/i;
  const filenameMatch = cleanDisposition.match(filenameRegex);

  if (filenameMatch && filenameMatch[1]) {
    return filenameMatch[1].trim();
  }

  // 都没匹配到，返回 null
  return null;
}
