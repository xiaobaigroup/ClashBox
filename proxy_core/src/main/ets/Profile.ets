import fs from '@ohos.file.fs';
import { getProfileDir, getProfilePath, getProfilesPath } from './appPath';
import { Context } from '@kit.AbilityKit';
import { ProxyGroup, ProxyType, SubscriptionInfo } from './models/Common';
import { JSON, taskpool, util } from '@kit.ArkTS';
import { http } from '@kit.NetworkKit';
import { parse, stringify } from 'yaml'
import { YamlUtils } from './utils/YamlUtils'
import { YamlUtil } from './utils/YamlUtil';
import { SocketProxyService } from './rpc/SocketProxyService';

class  ConfigUserInfo {
  'content-disposition': string
  'subscription-userinfo': string
}
export enum ProfileType {
  File,
  Url,
  External
}

export function generateUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

let utf8e = new util.TextEncoder()

export class Profile {
  id: string
  name: string | null
  type: ProfileType
  url: string = ""
  flag: string = ""
  customUA: string = ""
  overrideMode?: 'rule' | 'script' = 'rule'
  // 自定义附加规则（每个配置独立）
  customRules: string[] = []
  currentGroupName: string | null = null
  isUpdating: boolean = false
  autoUpdate: boolean = true
  lastUpdateDate: number
  autoUpdateDuration: number
  subscriptionInfo: SubscriptionInfo | null
  proxySelected: Map<string, string> = new Map()
  context?: Context
  // 是否自动修正 TLS 指纹（补全/替换为支持后量子曲线 ML-KEM 的新版 chrome），默认开启
  fixTlsFingerprint: boolean = true
  // YAML 覆写片段(entry 层注入, 所有配置生成路径统一应用深度合并)
  yamlOverride: string = ''

  constructor(type = ProfileType.Url, url: string) {
    this.id = generateUUID()
    this.name = null
    this.type = type // 0 url
    this.url = url
    this.autoUpdateDuration = 60 * 1000 // 1 分钟
    this.lastUpdateDate = new Date().getTime()
    this.subscriptionInfo = null
  }

  private globalUa: string = "clash-verge/v2.5.1"

  loadContext(context: Context | undefined, globalUa: string | undefined = "clash-verge/v2.5.1") {
    this.context = context
    this.globalUa = globalUa
  }

  async checkAndUpdate(socketProxy: SocketProxyService, customRules: string[] = [], deleteRules: string[] = []): Promise<void> {
    const isExists = await this.check();
    if (!isExists) {
      if (this.url != "") {
        await this.update(socketProxy, customRules, deleteRules);
      }
    }
  }

  async check(): Promise<boolean> {
    let profilePath = await getProfilePath(this.context, this.id);
    return await fs.access(profilePath, fs.AccessModeType.EXIST)
  }

  async delete(): Promise<void> {
    if (!await this.check()) return
    const profileDir = await getProfilesPath(this.context)
    const profilePath = await getProfilePath(this.context, this.id);
    // 删除配置文件
    await fs.unlink(profilePath)
    // 尝试删除“当前配置的专属目录”（如果存在且为空）
    // getProfilesPath 返回的是 profiles/；子目录按 id 命名
    const idDir = `${profileDir}/${this.id}`
    try {
      // listFile 判断是否为空
      const files = await fs.listFile(idDir)
      if (files.length === 0) {
        await fs.rmdir(idDir)
      }
    } catch (_) {
      // 不存在或非空，就不管
    }
  }

  async update(socketProxy: SocketProxyService, customRules: string[] = [], deleteRules: string[] = []): Promise<boolean> {
    console.debug(`[Profile] UpdateConfig this.url: ${this.url}`);
    const requestUa = this.globalUa ?? "clash-verge/v2.5.1";
    const tempYamlPath = this.context?.tempDir + "/temp.yaml";

    const maxRetries = 2;
    let lastError: Error | null = null;
    // 原生 Go 下载器一旦失败（多为 TLS 证书问题），后续重试直接走系统 http 兜底，
    // 避免每次重试都先经历一次原生失败等待，加快整体下载速度
    let nativeFailed = false;

    for (let attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        let result: string;
        if (!nativeFailed) {
          try {
            result = await socketProxy.downloadConfig(this.url, requestUa, tempYamlPath)
          } catch (e) {
            nativeFailed = true
            // 原生 Go 下载器严格校验 TLS 证书（部分订阅源用自签名/私有 CA 证书会失败），
            // 降级为系统 @ohos.net.http 模块兜底下载（走系统证书链），失败则抛出原错误
            const nativeErr = e instanceof Error ? e.message : String(e)
            console.warn(`[Profile] UpdateConfig 原生下载失败，尝试系统 HTTP 兜底: ${nativeErr}`)
            result = await this.downloadConfigFallback(this.url, requestUa, tempYamlPath)
          }
        } else {
          // 原生已确认失败（如 TLS 证书问题），重试直接走系统 http 兜底
          result = await this.downloadConfigFallback(this.url, requestUa, tempYamlPath)
        }
        let disposition :string | undefined;
        let userinfo: string | undefined;
        try {
          let configInfo = JSON.parse(result) as object;
          disposition = configInfo['content-disposition'];
          userinfo = configInfo['subscription-userinfo'];
        } catch (e) {
          throw Error(result)
        }
        const parsedName = getFileNameFromDisposition(disposition);
        if (parsedName) {
          // disposition 是权威来源：即使重试期间被 URL 兜底污染也覆盖（如反爬页重试后拿到真实订阅）
          this.name = parsedName;
        } else if (!this.name || this.name == "") {
          // disposition 缺失/解析失败时从 URL 提取名称，避免显示 UUID
          this.name = this.getDefaultNameFromUrl(this.url) ?? this.id;
        }
        if (userinfo) {
          this.subscriptionInfo = SubscriptionInfo.formHString(userinfo);
        }
        console.debug(`[Profile] UpdateConfig this.name: ${this.name} userinfo: ${userinfo}`);

        let configContent = await fs.readText(tempYamlPath)
        if (configContent) {
          const trimmedStr = configContent.trim();
          console.debug(`[Profile] UpdateConfig this.name: ${this.name} contentLen: ${trimmedStr.length}`);
          if ( trimmedStr.startsWith('<!DOCTYPE') || trimmedStr.startsWith('<!doctype') || trimmedStr.startsWith('<html') || trimmedStr.startsWith('<HTML') || trimmedStr.includes('<title>Just a moment...</title>') || trimmedStr.includes('location.replace(location.href') || trimmedStr.includes('location.href') && trimmedStr.includes('replace') ) {
            throw new Error("返回内容是 HTML/Cloudflare 拦截页，不是 Clash 订阅配置");
          }

          if (trimmedStr.length < 200) {
            console.error(`[Profile] UpdateConfig 内容过短: ${trimmedStr}`);
            throw new Error(`订阅返回内容过短（${trimmedStr.length}字节），疑似错误响应:${trimmedStr.substring(0, 100)}`);
          }

          const convertedYaml = YamlUtils.convertUniversalToClashYaml(configContent);
        // 打印转换结果，确认是否走进了转换逻辑
        if (convertedYaml) {
          console.info(`[Profile] UpdateConfig Base64/Universal 转换成功，已生成 Clash YAML`);
        } else {
          console.info(`[Profile] UpdateConfig Base64/Universal 转换返回 null，将使用原始内容`);
        }

          let finalStr = convertedYaml ? convertedYaml : configContent;

          await this.save(finalStr, async (config)=> await socketProxy.vailConfig(config), customRules, deleteRules);
        // 清理备份配置
          this.cleanScriptBackup()

          // 成功完成后清理临时文件
          try { await fs.unlink(tempYamlPath); } catch (_) {}
          return true;
        }
        throw new Error("无响应数据");
      } catch (error) {
        lastError = error instanceof Error ? error : new Error(String(error));

        try {
          if (await fs.access(tempYamlPath, fs.AccessModeType.EXIST)) {
            await fs.unlink(tempYamlPath);
          }
        } catch (_) {}

        if (attempt < maxRetries) {
          console.warn(`[Profile] UpdateConfig 第${attempt}次下载失败: ${lastError.message}，${1000}ms后重试...`);
          await new Promise<void>(resolve => setTimeout(resolve, 1000));
        }
      }
    }

    if (lastError) {
      throw lastError;
    }
    throw new Error("下载配置失败");
  }

  /**
   * 原生 Go 下载器 TLS 证书校验失败的兜底下载：
   * 使用系统 @ohos.net.http 模块（走系统证书链），将响应写入 tempYamlPath，
   * 返回与原生 downloadConfig 一致的 JSON（content-disposition / subscription-userinfo）
   */
  private async downloadConfigFallback(url: string, ua: string, filePath: string): Promise<string> {
    const httpRequest = http.createHttp()
    // 确保内置的 Let's Encrypt YE1 中间证书可用（rawfile → 应用目录）：
    // 部分订阅源服务器只发送叶子证书、缺失中间证书，导致链验证失败；
    // 用 caPath 补全中间证书即可通过系统 http 模块的证书校验
    let caFile = ''
    try {
      const baseDir = this.context?.filesDir ?? this.context?.tempDir ?? ''
      const target = baseDir + '/int-ye1.pem'
      if (baseDir !== '' && !await fs.access(target)) {
        const raw = await this.context?.resourceManager.getRawFileContent('int-ye1.pem')
        if (raw && raw.length > 0) {
          const caFileHandle = await fs.open(target, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC)
          const buffer: ArrayBuffer = raw.buffer.slice(raw.byteOffset, raw.byteOffset + raw.byteLength) as ArrayBuffer
          await fs.write(caFileHandle.fd, buffer)
          await fs.close(caFileHandle.fd)
        }
      }
      caFile = target
    } catch (e) {
      console.warn(`[Profile] 准备 CA 证书失败: ${(e as Error).message}`)
    }
    try {
      const options: http.HttpRequestOptions = {
        method: http.RequestMethod.GET,
        connectTimeout: 20000,
        readTimeout: 30000,
        header: { 'User-Agent': ua }
      }
      if (caFile !== '') {
        options.caPath = caFile
      }
      const resp = await httpRequest.request(url, options)
      if (resp.responseCode !== 200) {
        throw new Error(`HTTP ${resp.responseCode}`)
      }
      // 响应可能是 string 或 ArrayBuffer，统一转为字符串落盘
      let content: string
      if (typeof resp.result === 'string') {
        content = resp.result
      } else if (resp.result instanceof ArrayBuffer) {
        const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true })
        content = decoder.decodeToString(new Uint8Array(resp.result))
      } else {
        throw new Error('响应内容格式异常')
      }
      const bytes = utf8e.encodeInto(content)
      const file = await fs.open(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC)
      await fs.write(file.fd, bytes.buffer)
      await fs.close(file.fd)
      // 提取响应头（原生 downloadConfig 返回 JSON，含 content-disposition / subscription-userinfo）
      const headers = (resp.header ?? {}) as Record<string, string | string[]>
      const first = (v: string | string[] | undefined): string => {
        if (v === undefined) return ''
        return Array.isArray(v) ? (v[0] ?? '') : v
      }
      // HTTP 头键名大小写不敏感：系统 http 模块返回的 header 键可能是
      // "Content-Disposition" 或 "content-disposition"，统一小写比较避免取不到
      const getHeader = (name: string): string => {
        const lower = name.toLowerCase()
        const keys = Object.keys(headers)
        for (let i = 0; i < keys.length; i++) {
          if (keys[i].toLowerCase() === lower) {
            return first(headers[keys[i]])
          }
        }
        return ''
      }
      const configInfo: Record<string, string> = {}
      const disposition = getHeader('content-disposition')
      const userinfo = getHeader('subscription-userinfo')
      if (disposition) configInfo['content-disposition'] = disposition
      if (userinfo) configInfo['subscription-userinfo'] = userinfo
      return JSON.stringify(configInfo)
    } finally {
      httpRequest.destroy()
    }
  }

  /** 从订阅 URL 提取配置名（disposition 缺失时的兜底）：优先取路径最后一段，无则用主机名 */
  private getDefaultNameFromUrl(url: string): string | null {
    if (!url) return null
    try {
      // 剥离查询参数
      const noQuery = url.split('?')[0] ?? url
      // 取路径最后一段非空片段
      const segments = noQuery.split('/')
      for (let i = segments.length - 1; i >= 0; i--) {
        const seg = segments[i].trim()
        if (seg && seg !== '' && !seg.startsWith('http')) {
          // 截断过长片段，避免把整段 token 当名字
          return seg.length > 40 ? seg.substring(0, 40) : seg
        }
      }
      // 无路径片段时用主机名
      const hostMatch = url.match(/^https?:\/\/([^\/:]+)/)
      return hostMatch ? hostMatch[1] : null
    } catch (e) {
      return null
    }
  }

  // 负责 DNS 注入、校验和落盘
  async save(
    raw: string | ArrayBuffer,
    vailConfig: (config: string) => Promise<string>,
    customRules: string[] = [],
    deleteRules: string[] = [],
    scriptContent: string = ""): Promise<Profile> {
    let rawStr: string;
    if (typeof raw == "string") {
      rawStr = raw;
    } else {
      const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      rawStr = decoder.decodeToString(new Uint8Array(raw));
    }

    const trimmedStr = rawStr.trim();
    const isProbablyYaml = !( trimmedStr.startsWith('<!doctype') || trimmedStr.startsWith('<html') || trimmedStr.startsWith('<HTML') || (trimmedStr.startsWith('{') && trimmedStr.includes('"message"')) || trimmedStr.includes('<title>Just a moment...</title>'));

    let finalStr: string;
    if (isProbablyYaml) {
      const plainRules: string[] = [];
      for (const r of customRules) plainRules.push(r);
      const rulesJsonStr = JSON.stringify(plainRules);

      const plainDeleteRules: string[] = [];
      for (const r of deleteRules) plainDeleteRules.push(r);
      const deleteRulesJsonStr = JSON.stringify(plainDeleteRules);

      const injectTask = new taskpool.Task(injectDnsInBackground, rawStr, rulesJsonStr, deleteRulesJsonStr, scriptContent, this.name ?? '', this.fixTlsFingerprint, this.yamlOverride);
      finalStr = await taskpool.execute(injectTask) as string;
    } else {
      console.warn(`[Profile] save: 内容不像 YAML，跳过 DNS 注入，直接交给内核校验`);
      finalStr = rawStr;
    }

    // 编码并写入临时文件
    let bytes = utf8e.encodeInto(finalStr);
    const filePath = await getProfilePath(this.context, this.id);
    const tempPath = this.context!.tempDir + "/temp.config";
    const temp = await fs.open(tempPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
    await fs.write(temp.fd, bytes.buffer);
    await fs.close(temp.fd);

    // 内核校验
    console.debug(`[Profile][VailTrace] before vailConfig t=${Date.now()} path=${tempPath}`);
    let message = await vailConfig(tempPath);
    console.debug(`[Profile][VailTrace] after vailConfig t=${Date.now()} message=${message}`);
    await fs.unlink(tempPath);
    if (message != "") {
      throw new Error(message);
    }

    // 校验通过，写入正式文件
    const file = await fs.open(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
    await fs.write(file.fd, bytes.buffer);
    await fs.close(file.fd);
    this.lastUpdateDate = new Date().getTime();
    return this;
  }

  async saveByUri(uri: string, customRules: string[] = [], deleteRules: string[] = [], scriptContent: string = ""): Promise<Profile> {
    const filePath = await getProfilePath(this.context, this.id)
    try {
      const srcFile = await fs.open(uri, fs.OpenMode.READ_ONLY);
      const stat = await fs.stat(srcFile.fd);
      const buffer = new ArrayBuffer(stat.size);
      await fs.read(srcFile.fd, buffer);
      await fs.close(srcFile.fd);

      const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      let rawStr = decoder.decodeToString(new Uint8Array(buffer));

      // 手动构建纯数组 + 序列化成字符串，规避 V2 Proxy 无法序列化问题
      const plainRules: string[] = [];
      for (const r of customRules) plainRules.push(r);
      const rulesJsonStr = JSON.stringify(plainRules);

      const plainDeleteRules: string[] = [];
      for (const r of deleteRules) plainDeleteRules.push(r);
      const deleteRulesJsonStr = JSON.stringify(plainDeleteRules);

      const injectTask = new taskpool.Task(injectDnsInBackground, rawStr, rulesJsonStr, deleteRulesJsonStr, scriptContent, this.name ?? '', this.fixTlsFingerprint, this.yamlOverride);
      rawStr = await taskpool.execute(injectTask) as string;

      let bytes = utf8e.encodeInto(rawStr)
      const destFile = await fs.open(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC)
      await fs.write(destFile.fd, bytes.buffer)
      await fs.close(destFile.fd)
    } catch (error) {
      throw error as Error
    }
    return this
  }

  getSelectedProxyName(g: ProxyGroup): string | undefined {
    if (g.type !== ProxyType.Selector) return g.now
    let dd = this.proxySelected.get(g.name) ?? g.now
    return dd
  }

  getSelectedMap(): Record<string, string> {
    const jsonObject: Record<string, string> = {};
    this.proxySelected.forEach((value, key) => {
      jsonObject[key] = value;
    });
    return jsonObject
  }

  /**
   * 从配置文件的 YAML 中提取 MATCH 规则的目标策略
   * @returns MATCH 目标（如 "Proxy"、"DIRECT"、"REJECT"），读取失败默认 "DIRECT"
   */
  async getMatchTarget(): Promise<string> {
    try {
      const filePath = await getProfilePath(this.context!, this.id);
      if (!await fs.access(filePath)) return 'DIRECT';
      const file = await fs.open(filePath, fs.OpenMode.READ_ONLY);
      const stat = await fs.stat(filePath);
      const buf = new ArrayBuffer(stat.size);
      await fs.read(file.fd, buf);
      fs.close(file);
      const decoder = util.TextDecoder.create('utf-8');
      const content = decoder.decodeToString(new Uint8Array(buf));
      return YamlUtils.extractMatchTarget(content);
    } catch (e) {
      console.error('Profile.getMatchTarget 读取 MATCH 目标失败', e);
      return 'DIRECT';
    }
  }

  /**
   * 检查并修复单个配置文件中缺失的规则
   * @param customRules 自定义规则数组
   * @returns 是否进行了修复
   */
  async repairMissingRules(customRules: string[] = [], deleteRules: string[] = []): Promise<boolean> {
    const filePath = await getProfilePath(this.context, this.id);
    if (!await fs.access(filePath)) {
      return false;
    }

    try {
      const file = await fs.open(filePath, fs.OpenMode.READ_ONLY);
      const stat = await fs.stat(file.fd);
      const buffer = new ArrayBuffer(stat.size);
      await fs.read(file.fd, buffer);
      await fs.close(file.fd);

      const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      let rawStr = decoder.decodeToString(new Uint8Array(buffer));

      // 不再写死强制 AND 规则存在：
      // 之前硬编码会让"用户关闭 AND 后，后续修复仍把它当缺失重新注入"，
      // 反复修复破坏配置导致无法加载。AND 规则已作为普通附加规则，
      // 由 customRules(启用)/deleteRules(禁用) 驱动，无需在此强制。
      const fixedRules: string[] = [];

      const plainRules: string[] = [];
      for (const r of customRules) plainRules.push(r);
      const rulesJsonStr = JSON.stringify(plainRules);

      const plainDeleteRules: string[] = [];
      for (const r of deleteRules) plainDeleteRules.push(r);
      const deleteRulesJsonStr = JSON.stringify(plainDeleteRules);

      const allRequiredRules = [...fixedRules, ...plainRules];
      let needsRepair = false;

      // 转义正则特殊字符的辅助函数
      const escapeRegExp = (str: string) => str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

      // ★ 规范化: 去除全部空白, 使规则前后空格/逗号后空格均视为同一条规则
      // (如 DOMAIN-SUFFIX,mihoyo.com,DIRECT / DOMAIN-SUFFIX, mihoyo.com, DIRECT 等价)
      const normalizedRaw = rawStr.replace(/\s+/g, '');
      const normalizeRule = (s: string): string => s.replace(/\s+/g, '');

      // 检查是否有缺失的规则
      for (const rule of allRequiredRules) {
        if (rule.endsWith(',MATCH')) {
          // 如果规则是 xxx,MATCH，检查文件里是否有 xxx,xxx (排除本身还是 MATCH 的情况)
          const prefix = normalizeRule(rule.substring(0, rule.length - 6));
          const regex = new RegExp(escapeRegExp(prefix) + ',(?!MATCH\\b)');
          if (!regex.test(normalizedRaw)) {
            needsRepair = true;
            console.info(`ProfileRepair: 配置 [${this.name}] 缺失规则前缀${prefix} (MATCH)`);
            break;
          }
        } else {
          // ★ 去除全部空白后比较: 内容一致(前后/逗号后空格均可)视为同一条规则, 避免重复注入/误判
          if (!normalizedRaw.includes(normalizeRule(rule))) {
            needsRepair = true;
            console.info(`ProfileRepair: 配置 [${this.name}] 缺失规则${rule}`);
            break;
          }
        }
      }

      // 如果没有缺失，再检查是否包含需要删除的规则
      if (!needsRepair && plainDeleteRules.length > 0) {
        for (const rule of plainDeleteRules) {
          if (rule.endsWith(',MATCH')) {
            const prefix = normalizeRule(rule.substring(0, rule.length - 6));
            // 检查文件里是否存在该前缀的规则
            const regex = new RegExp(escapeRegExp(prefix) + ',');
            if (regex.test(normalizedRaw)) {
              needsRepair = true;
              console.info(`ProfileRepair: 配置 [${this.name}] 包含需删除的残留规则前缀${prefix} (MATCH)`);
              break;
            }
          } else {
            // ★ 去除全部空白后比较: 内容一致(前后/逗号后空格均可)视为同一条规则, 避免误删
            if (normalizedRaw.includes(normalizeRule(rule))) {
              needsRepair = true;
              console.info(`ProfileRepair: 配置 [${this.name}] 包含需删除的残留规则${rule}`);
              break;
            }
          }
        }
      }

      if (needsRepair) {
        console.info(`ProfileRepair: 开始修复配置 [${this.name}]`);
        const injectTask = new taskpool.Task(injectDnsInBackground, rawStr, rulesJsonStr, deleteRulesJsonStr, '', this.name || '', this.fixTlsFingerprint, this.yamlOverride);
        const repairedStr = await taskpool.execute(injectTask) as string;

        const utf8e = new util.TextEncoder();
        let bytes = utf8e.encodeInto(repairedStr);

        const destFile = await fs.open(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
        await fs.write(destFile.fd, bytes.buffer);
        await fs.close(destFile.fd);

        return true;
      }
      return false;
    } catch (e) {
      console.error(`ProfileRepair: 修复配置 [${this.name}] 失败`, e);
      return false;
    }
  }

  /**
   * ★ 强制按当前规则列表顺序重写配置中的 rules 段(规则排序后调用)。
   * 与 repairMissingRules 不同: 不检查缺失, 直接注入全部启用规则并按新顺序写回,
   * 确保排序结果同步到配置文件(repairMissingRules 在无缺失时不会写盘)。
   * @param customRules 按新顺序排列的启用规则列表
   * @param deleteRules 需删除的规则列表
   * @returns 是否写盘成功
   */
  async forceRewriteRules(customRules: string[] = [], deleteRules: string[] = []): Promise<boolean> {
    const filePath = await getProfilePath(this.context, this.id);
    if (!await fs.access(filePath)) {
      return false;
    }
    try {
      const file = await fs.open(filePath, fs.OpenMode.READ_ONLY);
      const stat = await fs.stat(file.fd);
      const buffer = new ArrayBuffer(stat.size);
      await fs.read(file.fd, buffer);
      await fs.close(file.fd);

      const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const rawStr = decoder.decodeToString(new Uint8Array(buffer));

      const rulesJsonStr = JSON.stringify(customRules);
      const deleteRulesJsonStr = JSON.stringify(deleteRules);
      const injectTask = new taskpool.Task(injectDnsInBackground, rawStr, rulesJsonStr, deleteRulesJsonStr, '', this.name || '', this.fixTlsFingerprint, this.yamlOverride);
      const injectedStr = await taskpool.execute(injectTask) as string;

      const utf8e = new util.TextEncoder();
      const bytes = utf8e.encodeInto(injectedStr);
      const destFile = await fs.open(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
      await fs.write(destFile.fd, bytes.buffer);
      await fs.close(destFile.fd);
      console.info(`ProfileRepair: 强制重写规则完成 [${this.name}] 规则数: ${customRules.length}`);
      return true;
    } catch (e) {
      console.error(`ProfileRepair: 强制重写规则失败 [${this.name}]`, e);
      return false;
    }
  }

  /**
   * 迁移已落盘的旧配置: 检查 config.yaml 的 proxy-providers 是否缺少 lazy: true,
   * 缺少则注入并写回, 使 mihomo 加载配置时不再同步下载远程订阅(冷启动/切换加载缓慢的根因)。
   * 幂等: 已全部 lazy 或内容未变时返回 false 且不写盘。
   * @returns 是否进行了注入写回
   */
  async ensureProvidersLazy(): Promise<boolean> {
    const filePath = await getProfilePath(this.context, this.id);
    if (!await fs.access(filePath)) {
      return false;
    }
    try {
      const file = await fs.open(filePath, fs.OpenMode.READ_ONLY);
      const stat = await fs.stat(file.fd);
      const buffer = new ArrayBuffer(stat.size);
      await fs.read(file.fd, buffer);
      await fs.close(file.fd);

      const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const rawStr = decoder.decodeToString(new Uint8Array(buffer));

      const injectedStr = YamlUtils.injectProvidersLazy(rawStr);
      if (injectedStr === rawStr) {
        return false; // 无 proxy-providers 或已全部 lazy, 无需写盘
      }

      const destFile = await fs.open(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
      const bytes = utf8e.encodeInto(injectedStr);
      await fs.write(destFile.fd, bytes.buffer);
      await fs.close(destFile.fd);
      console.info(`Profile [${this.name}] proxy-providers 已注入 lazy: true`);
      return true;
    } catch (e) {
      console.warn(`Profile [${this.name}] ensureProvidersLazy 失败`, e);
      return false;
    }
  }

  /**
   * 重新对当前配置文件执行指定的 JS 脚本并保存
   * @param vailConfig 内核校验回调
   * @param scriptContent 用户的 JS 脚本
   * @param customRules 自定义规则
   * @param deleteRules 需要删除的规则
   * @returns 是否执行成功
   */
  async reapplyScript(
    vailConfig: (config: string) => Promise<string>,
    scriptContent: string = "",
    customRules: string[] = [],
    deleteRules: string[] = [],
    yamlOverride: string = ""
  ): Promise<boolean> {
    const filePath = await getProfilePath(this.context, this.id);
    // YAML 覆写参数同步到实例字段, 供后台注入链统一应用
    this.yamlOverride = yamlOverride;
    console.info(`[ScriptTest] Profile.reapplyScript 读取文件: ${filePath}`);

    if (!await fs.access(filePath)) {
      console.warn(`[ScriptTest] 文件不存在，跳过: ${filePath}`);
      return false;
    }
    try {
      const file = await fs.open(filePath, fs.OpenMode.READ_ONLY);
      const stat = await fs.stat(file.fd);
      const buffer = new ArrayBuffer(stat.size);
      await fs.read(file.fd, buffer);
      await fs.close(file.fd);

      const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const rawStr = decoder.decodeToString(new Uint8Array(buffer));
      console.info(`[ScriptTest] 原始 YAML 内容读取成功，长度: ${rawStr.length}`);

      // 校验和落盘逻辑分离，先判断是否被修改
      const plainRules: string[] = [];
      for (const r of customRules) plainRules.push(r);
      const rulesJsonStr = JSON.stringify(plainRules);
      const plainDeleteRules: string[] = [];
      for (const r of deleteRules) plainDeleteRules.push(r);
      const deleteRulesJsonStr = JSON.stringify(plainDeleteRules);

      // 在后台线程执行脚本和注入
      const injectTask = new taskpool.Task(injectDnsInBackground, rawStr, rulesJsonStr, deleteRulesJsonStr, scriptContent, this.name ?? '', this.fixTlsFingerprint, this.yamlOverride);
      let finalStr = await taskpool.execute(injectTask) as string;

      // 如果脚本没修改配置，finalStr 和 rawStr 相同，直接返回成功，不备份不落盘
      if (finalStr === rawStr) {
        console.info(`[ScriptTest] 脚本未影响此配置 [${this.name}]，跳过保存`);
        return true;
      }

      // 执行到此，说明配置已被脚本修改，此时备份原始纯净配置
      await this.saveScriptBackup(rawStr);

      // 校验并落盘
      try {
        let bytes = utf8e.encodeInto(finalStr);
        const tempPath = this.context!.tempDir + "/temp.config";
        const temp = await fs.open(tempPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
        await fs.write(temp.fd, bytes.buffer);
        await fs.close(temp.fd);
        let message = await vailConfig(tempPath);
        await fs.unlink(tempPath);
        if (message != "") throw new Error(message);

        const filePath = await getProfilePath(this.context, this.id);
        const file = await fs.open(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
        await fs.write(file.fd, bytes.buffer);
        await fs.close(file.fd);
        console.info(`[ScriptTest] 脚本修改已保存: [${this.name}]`);
        return true;
      } catch (e) {
        console.error(`[ScriptTest] 脚本执行后校验失败:`, e);
        return false;
      }
    } catch (e) {
      console.error(`[ScriptTest] 配置变更失败:`, e);
      return false;
    }
  }

  // 获取脚本备份文件的专属路径 (与 config.yaml 同目录)
  private async getScriptBackupPath(): Promise<string> {
    const dir = await getProfileDir(this.context, this.id);
    return `${dir}/config_script_backup.yaml`;
  }

  // 保存脚本备份 (仅在没有备份文件时才创建)
  private async saveScriptBackup(rawStr: string) {
    try {
      const backupPath = await this.getScriptBackupPath();

      // 如果备份文件已经存在，说明之前已经备份过原始配置，直接返回不覆盖
      if (await fs.access(backupPath)) {
        console.info(`[ScriptBackup] 备份文件已存在，保留原始纯净配置，不覆盖`);
        return;
      }

      const bytes = utf8e.encodeInto(rawStr);
      const file = await fs.open(backupPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
      await fs.write(file.fd, bytes.buffer);
      await fs.close(file.fd);
      console.info(`[ScriptBackup] 首次执行脚本，原始配置备份成功: ${backupPath}`);
    } catch (e) {
      console.warn(`[ScriptBackup] 备份失败，不影响主流程:`, e);
    }
  }

  // 恢复到脚本执行前的状态
  async restoreScriptBackup(
    vailConfig: (config: string) => Promise<string>,
    customRules: string[] = [],
    deleteRules: string[] = []
  ): Promise<boolean> {
    const backupPath = await this.getScriptBackupPath();
    if (!await fs.access(backupPath)) {
      console.warn(`[ScriptBackup] 没有找到备份文件，无法恢复: ${backupPath}`);
      return false;
    }

    try {
      console.info(`[ScriptBackup] 开始恢复配置 [${this.name}]`);
      const file = await fs.open(backupPath, fs.OpenMode.READ_ONLY);
      const stat = await fs.stat(file.fd);
      const buffer = new ArrayBuffer(stat.size);
      await fs.read(file.fd, buffer);
      await fs.close(file.fd);

      const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      const rawStr = decoder.decodeToString(new Uint8Array(buffer));

      // 传入空的 scriptContent，恢复到纯净状态并重新注入基础 DNS 规则
      await this.save(rawStr, vailConfig, customRules, deleteRules, "");

      // 恢复成功后，删除备份文件
      await fs.unlink(backupPath);
      console.info(`[ScriptBackup] 恢复成功并已清理备份文件`);
      return true;
    } catch (e) {
      console.error(`[ScriptBackup] 恢复失败:`, e);
      return false;
    }
  }

  // 主动清理备份文件 (可在配置正常更新时调用)
  async cleanScriptBackup(): Promise<void> {
    try {
      const backupPath = await this.getScriptBackupPath();
      if (await fs.access(backupPath)) {
        await fs.unlink(backupPath);
        console.debug(`[ScriptBackup] 正常更新时清理了旧的脚本备份`);
      }
    } catch (_) {}
  }

  /**
   * 清理因为更新失败可能遗留的空文件夹
   */
  async cleanEmptyDir(): Promise<void> {
    try {
      const baseDir = await getProfilesPath(this.context);
      const profileDir = `${baseDir}/${this.id}`;
      console.debug(`Profile.cleanEmptyDir profileDir: ${profileDir}`);

      // 目录本身不存在就不处理
      if (!(await fs.access(profileDir))) {
        return;
      }
      // 列目录内容（非递归），只要不为空就不删
      const files = await fs.listFile(profileDir); // 不带 options 即非递归
      if (files.length === 0) {
        await fs.rmdir(profileDir);
        console.debug(`Profile.cleanEmptyDir 已清理空文件夹: ${profileDir}`);
      } else {
        console.debug(`Profile.cleanEmptyDir 目录非空，跳过清理: ${profileDir}`);
      }
    } catch (e) {
      // 发生任何异常都不影响主流程
      console.warn(`Profile.cleanEmptyDir 异常，放弃清理: ${JSON.stringify(e)}`);
    }
  }

}

// 已迁移至内核校验
async function isYAML(data: string | ArrayBuffer): Promise<boolean> {
  try {
    let content: string;
    if (typeof data === 'string') {
      content = data;
    } else if (data instanceof ArrayBuffer) {
      const decoder = util.TextDecoder.create('utf-8', { ignoreBOM: true });
      content = decoder.decodeToString(new Uint8Array(data));
    } else {
      return false;
    }

    const trimmedContent = content.trim();
    if (trimmedContent.startsWith('{') && trimmedContent.endsWith('}') && !trimmedContent.includes('\n')) {
      return false;
    }

    const task = new taskpool.Task(parseYAMLInBackground, content);
    const parseResult = await taskpool.execute(task) as boolean;
    if (!parseResult) {
      console.error("YAML 解析失败: TaskPool 解析返回 false");
      return false;
    }
    return true;
  } catch (e) {
    console.error("YAML 解析失败:", e);
    return false;
  }
}

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

@Concurrent
function injectDnsInBackground(
  yamlContent: string,
  rulesJsonStr: string,
  deleteRulesJsonStr: string,
  scriptContent: string = "",
  profileName: string = "",
  fixTlsFingerprint: boolean = true,
  yamlOverride: string = ""
): string {
  console.debug(`[Profile][InjectTrace] ENTER len=${yamlContent.length} t=${Date.now()}`);
  console.debug(`[Profile][ScriptTest] -> 后台任务开始执行 [${profileName}]`);
  console.debug(`[Profile][ScriptTest] -> 接收到的 YAML 长度: ${yamlContent.length}, 脚本长度: ${scriptContent.length}`);
  try {
    // ★ YAML 覆写: 后台任务开头先深度合并用户覆写片段, 再进行脚本/规则注入
    if (yamlOverride && yamlOverride.trim() !== '') {
      yamlContent = YamlUtils.applyYamlOverride(yamlContent, yamlOverride)
    }
  } catch (e) {
    console.warn(`[Profile] YAML 覆写合并失败: ${(e as Error)?.message ?? e}`)
  }

  let customRules: string[] = [];
  let deleteRules: string[] = [];
  try {
    if (rulesJsonStr && rulesJsonStr.length > 0) {
      customRules = JSON.parse(rulesJsonStr) as string[];
    }
    if (deleteRulesJsonStr && deleteRulesJsonStr.length > 0) {
      deleteRules = JSON.parse(deleteRulesJsonStr) as string[];
    }
  } catch (e) {
    console.warn("[Profile][ScriptTest] -> 解析 JSON 规则失败", e);
  }

  try {
    const t0 = Date.now();
    const result = YamlUtil.executeScriptAndInject(
      yamlContent,
      scriptContent,
      profileName,
      customRules,
      deleteRules,
      fixTlsFingerprint
    );
    console.debug(`[Profile][InjectTrace] executeScriptAndInject done cost=${Date.now()-t0}ms outlen=${result.length}`);
    console.debug(`[Profile][ScriptTest] -> YamlUtils 处理完成，返回 YAML 长度: ${result.length}`);
    return result;
  } catch (e) {
    console.error(`[Profile][ScriptTest] -> YamlUtils 抛出异常: ${e}`);
    throw new Error(e);
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
  // 使用正则，允许大小写、空格等变化
  const filenameStarRegex = /filename\*\s*=\s*(?:UTF-8|utf-8)\s*''\s*([^;]+)/i;
  const filenameStarMatch = cleanDisposition.match(filenameStarRegex);
  if (filenameStarMatch && filenameStarMatch[1]) {
    // 去除可能的空格并进行 URL 解码（非法百分号编码会抛异常，容错返回原始值）
    const encodedFileName = filenameStarMatch[1].trim();
    try {
      return decodeURIComponent(encodedFileName);
    } catch (e) {
      return encodedFileName;
    }
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
