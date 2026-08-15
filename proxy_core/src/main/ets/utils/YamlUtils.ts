import { parse, stringify, parseDocument, isScalar, isSeq, isMap } from 'yaml';
import type { Scalar, YAMLSeq, YAMLMap } from 'yaml';
import { util } from '@kit.ArkTS';

export class YamlUtils {
  /**
   * ★ 安全解析 YAML：修复被 yaml 库解析为 Infinity/NaN 的数值标量。
   * 订阅中无引号的 16 进制/科学计数法形态字符串(如 password: 48654786e0504509)会被
   * 解析为数字并按指数溢出为 Infinity, 再 stringify 时输出 ".inf", 导致密码损坏。
   * 此处用 parseDocument 保留的原始 source 还原为字符串, 保证 parse→stringify 往返不丢数据。
   */
  static parseYamlSafe(yamlContent: string): Record<string, Object | undefined> {
    try {
      const doc = parseDocument(yamlContent);
      YamlUtils.fixInfiniteScalars(doc.contents);
      return doc.toJS() as Record<string, Object | undefined>;
    } catch (e) {
      console.warn('YAML 安全解析失败，回退普通解析:', e);
      return YamlUtils.parseYamlSafe(yamlContent);
    }
  }

  /** 递归修复节点树中值为 Infinity/NaN 的标量，还原为其原始字符串 source */
  private static fixInfiniteScalars(node: Object | null | undefined): void {
    if (!node) return;
    if (isScalar(node)) {
      const sc = node as Scalar<unknown>;
      if (typeof sc.value === 'number' && !Number.isFinite(sc.value as number) && sc.source != null) {
        sc.value = sc.source;
      }
      return;
    }
    if (isSeq(node)) {
      const seq = node as YAMLSeq;
      for (const item of seq.items) {
        YamlUtils.fixInfiniteScalars(item as Object);
      }
      return;
    }
    if (isMap(node)) {
      const map = node as YAMLMap;
      for (const pair of map.items) {
        YamlUtils.fixInfiniteScalars(pair.key as Object);
        YamlUtils.fixInfiniteScalars(pair.value as Object);
      }
    }
  }

  /**
   * 判断指纹是否"不保证支持后量子加密曲线（ML-KEM/X25519MLKEM768）"
   * 后量子握手要求 ClientHello 携带 ML-KEM key share，uTLS 中仅新版 chrome/edge（Chrome 131+）
   * 的指纹携带；firefox/ios/safari/android 及 golang/random/utls、旧版本号指纹均不携带，
   * 服务器强制后量子协商时会握手失败导致节点无法连接。
   */
  private static isPqUnsafeFingerprint(fp: string): boolean {
    const f = fp.toLowerCase();
    if (f === '') return true;
    // 白名单：chrome / edge 裸名（uTLS 模拟最新版，携带 ML-KEM key share）
    if (f === 'chrome' || f === 'edge') return false;
    // 白名单：chrome_131+ / edge_131+ 等新版本号指纹（自 131 起携带 ML-KEM）
    const verMatch = f.match(/^(chrome|edge)_(\d+)/);
    if (verMatch && parseInt(verMatch[2], 10) >= 131) return false;
    // 其余（firefox/ios/safari/android/qq/360/opera/golang/random/utls 及旧版本号）视为不支持后量子
    return true;
  }

  /**
   * 修正 TLS 指纹：对启用 TLS 的节点补全/替换 client-fingerprint 为支持后量子曲线的新版 chrome
   * @param doc 已 parse 的 YAML 文档对象（原地修改 proxies）
   */
  private static fixTlsFingerprints(doc: Record<string, Object | undefined>): void {
    const proxies = doc['proxies'] as Array<Record<string, Object | undefined>> | undefined;
    if (!proxies || !Array.isArray(proxies)) return;

    for (const p of proxies) {
      if (!p || typeof p !== 'object') continue;
      const type = p['type'] as string | undefined;
      // 仅处理实际走 TLS 的节点：显式 tls: true、reality 节点、trojan（协议强制 TLS）
      const useTls = p['tls'] === true || p['reality-opts'] !== undefined || type === 'trojan';
      if (!useTls) continue;

      const fp = p['client-fingerprint'] as string | undefined;
      if (fp === undefined || fp === null) {
        // A：无指纹的 TLS 节点补全 chrome（新版 utls 指纹自带 ML-KEM key share）
        p['client-fingerprint'] = 'chrome';
      } else if (this.isPqUnsafeFingerprint(String(fp))) {
        // B：旧/不支持后量子的指纹替换为 chrome
        p['client-fingerprint'] = 'chrome';
      }
    }
  }

  /**
   * 补全 anytls 节点的 alpn：缺失或仅声明 [h2] 时补为 [h2, http/1.1]。
   * anytls 官方文档默认 alpn 为 [h2, http/1.1]，客户端只声明 h2 时，
   * 服务端（新版 xray）ALPN 协商可能失败导致 TLS 握手中止（日志 CURLcode 35）。
   */
  private static fixAnyTlsAlpn(doc: Record<string, Object | undefined>): void {
    const proxies = doc['proxies'] as Array<Record<string, Object | undefined>> | undefined;
    if (!proxies || !Array.isArray(proxies)) return;

    for (const p of proxies) {
      if (!p || typeof p !== 'object') continue;
      if (p['type'] !== 'anytls') continue;

      const alpn = p['alpn'];
      if (Array.isArray(alpn)) {
        const list = alpn as Array<string | undefined>;
        // 已含 http/1.1 则保持不动（尊重用户/订阅配置）
        if (list.some((v) => String(v).toLowerCase() === 'http/1.1')) continue;
        // 含 h2 但缺 http/1.1 时补全
        if (list.some((v) => String(v).toLowerCase() === 'h2')) {
          p['alpn'] = ['h2', 'http/1.1'];
        }
        // 其它组合（不含 h2）：保持原样
      } else if (alpn === undefined || alpn === null) {
        p['alpn'] = ['h2', 'http/1.1'];
      }
    }
  }

  /**
   * 向 YAML 内容中注入 DNS 相关的 proxies 和 rules
   * @param yamlContent 原始 YAML 字符串
   * @param customRules 自定义注入的规则数组（将插入到固定规则之后）
   * @param deleteRules 需要从配置中删除的规则数组
   * @param fixTlsFingerprint 是否自动修正 TLS 指纹（补全/替换为支持后量子曲线的新版 chrome），默认开启
   */
  /** YAML 覆写键名修饰符解析结果: name=实际键名, force=!强制覆盖, prepend=+前缀前置, append=+后缀追加 */
  private static parseKeyModifiers(key: string): { name: string, force: boolean, prepend: boolean, append: boolean } {
    let raw = key
    let prepend = false
    let append = false
    let force = false
    if (raw.startsWith('+')) {
      prepend = true
      raw = raw.substring(1)
    }
    if (raw.endsWith('+') && raw.length > 1) {
      append = true
      raw = raw.substring(0, raw.length - 1)
    }
    if (raw.endsWith('!') && raw.length > 1) {
      force = true
      raw = raw.substring(0, raw.length - 1)
    }
    let name = raw
    if (raw.startsWith('<') && raw.endsWith('>') && raw.length > 2) {
      name = raw.substring(1, raw.length - 1)
    }
    return { name: name, force: force, prepend: prepend, append: append }
  }

  /** 深度合并: 支持 ! 强制覆盖、+ 数组前置/追加、<> 歧义键字面 */
  private static deepMerge(target: Record<string, Object | undefined>, src: Record<string, Object | undefined>): void {
    const keys = Object.keys(src)
    for (const key of keys) {
      const sv = src[key]
      const parsed = YamlUtils.parseKeyModifiers(key)
      if (parsed.force) {
        target[parsed.name] = sv
        continue
      }
      if (parsed.prepend || parsed.append) {
        const tv = target[parsed.name]
        let svArr: Array<Object | undefined> = []
        if (Array.isArray(sv)) {
          svArr = sv as Array<Object | undefined>
        } else {
          svArr.push(sv)
        }
        if (Array.isArray(tv)) {
          const baseArr = tv as Array<Object | undefined>
          target[parsed.name] = parsed.prepend ? svArr.concat(baseArr) : baseArr.concat(svArr)
        } else {
          target[parsed.name] = svArr
        }
        continue
      }
      if (sv !== undefined && sv !== null && typeof sv === 'object' && !Array.isArray(sv)) {
        const tv = target[parsed.name]
        if (tv !== undefined && tv !== null && typeof tv === 'object' && !Array.isArray(tv)) {
          YamlUtils.deepMerge(tv as Record<string, Object | undefined>, sv as Record<string, Object | undefined>)
        } else {
          target[parsed.name] = sv
        }
      } else {
        target[parsed.name] = sv
      }
    }
  }

  /** ★ YAML 覆写: 深度合并到配置(简单值覆盖/嵌套递归; ! 强制覆盖; + 前置/追加; <> 字面键) */
  static applyYamlOverride(yamlContent: string, overrideStr: string): string {
    if (!overrideStr || overrideStr.trim() === '') {
      return yamlContent
    }
    try {
      const base = YamlUtils.parseYamlSafe(yamlContent);
      const ov = YamlUtils.parseYamlSafe(overrideStr);
      if (!ov || typeof ov !== 'object') {
        return yamlContent
      }
      YamlUtils.deepMerge(base, ov)
      return stringify(base)
    } catch (e) {
      console.warn('YAML 覆写合并失败，保留原配置:', e)
      return yamlContent
    }
  }

  static injectDnsFields(yamlContent: string, customRules: string[] = [], deleteRules: string[] = [], fixTlsFingerprint: boolean = true): string {
    try {
      const doc = YamlUtils.parseYamlSafe(yamlContent);

      // --- 修正 TLS 指纹（后量子兼容） ---
      if (fixTlsFingerprint) {
        try {
          this.fixTlsFingerprints(doc);
        } catch (e) {
          console.warn("TLS 指纹修正失败，跳过:", e);
        }
      }

      // --- 补全 anytls 节点 alpn（[h2] → [h2, http/1.1]，避免 ALPN 协商失败） ---
      try {
        this.fixAnyTlsAlpn(doc);
      } catch (e) {
        console.warn("anytls alpn 补全失败，跳过:", e);
      }

      // --- 插入/清理 rules ---
      let rules = doc['rules'] as Array<string> | undefined;
      if (!rules) {
        rules = [];
      }

      // 固定保障规则不再写死强制注入：
      // 之前硬编码 AND 规则会让"关闭后仍被重复注入"，反复修复导致配置损坏无法加载。
      // AND 规则改为普通附加规则，由 customRules(启用)/deleteRules(禁用) 驱动注入与删除。
      const fixedRules: string[] = [];

      // 提取原配置中 MATCH 的目标策略
      let matchTarget = 'DIRECT'; // 默认兜底策略
      for (const rule of rules) {
        if (rule.trim().startsWith('MATCH,')) {
          matchTarget = rule.split(',')[1]?.trim() || 'DIRECT';
          break;
        }
      }

      // 预处理规则：将以 MATCH 结尾的规则，替换为实际的 matchTarget
      const processRuleAction = (rule: string): string => {
        if (rule.endsWith(',MATCH')) {
          return rule.substring(0, rule.length - 6) + ',' + matchTarget;
        }
        return rule;
      };

      const processedFixedRules = fixedRules.map(processRuleAction);

      // 过滤自定义规则：去除与固定规则重复的，以及与要删除的规则重复的
      const validCustomRules = customRules.filter(r =>
      !fixedRules.includes(r) && !deleteRules.includes(r)
      );
      const processedCustomRules = validCustomRules.map(processRuleAction);

      // 过滤原有规则：剔除要删除的规则，以及将要插入的规则（防止重复）
      // 需要同时比对处理前后的规则，确保旧的匹配项被彻底清理
      const cleanedOriginalRules = rules.filter(r =>
      !fixedRules.includes(r) &&
        !processedFixedRules.includes(r) &&
        !customRules.includes(r) &&
        !processedCustomRules.includes(r) &&
        !deleteRules.includes(r) &&
        !deleteRules.some(dRule => processRuleAction(dRule) === r)
      );

      // 固定规则：剔除被禁用的规则（允许禁用固定保障规则）
      const finalFixedRules = processedFixedRules.filter(r =>
        !deleteRules.includes(r) && !deleteRules.some(dRule => processRuleAction(dRule) === r)
      );

      // 规则格式规范化：部分订阅源使用空格分隔规则（如 "DOMAIN ipinfo.io PROXY"），
      // mihomo 内核要求逗号分隔，parse/stringify 往返不会自动修复，导致 format invalid 报错。
      const normalizeRuleSpacing = (rule: string): string => {
        const trimmed = rule.trim();
        if (trimmed.includes(',')) return rule;
        const parts = trimmed.split(/\s+/);
        // 形如 "TYPE payload action"（首段为规则类型且至少三段）才转换，避免误改普通字符串
        if (parts.length >= 3 && /^[A-Z][A-Z0-9-]*$/.test(parts[0])) {
          return parts.join(',');
        }
        return rule;
      };

      // 拼接规则：固定规则 + 自定义规则 + 清理后的原有规则
      const finalRules = [...finalFixedRules, ...processedCustomRules, ...cleanedOriginalRules]
        .map(normalizeRuleSpacing);

      // 内核 overrideRules（proxy_core/src/flclash/common.go）在加载配置时会按顺序扫描规则：
      // 任一规则按逗号分割后字段数 !=2 则直接 return（不注入）；遇到 2 字段的 "MATCH,xxx"
      // 则把 ipinfo.io 等 IP 检测域名以空格分隔（"DOMAIN ipinfo.io PROXY"）插入规则首位。
      // 而 mihomo 规则只认逗号分隔，导致 rules[0] ... format invalid、配置无法加载。
      // 这里在 ArkTS 侧精确复刻该触发条件：仅当内核确实会注入时，先注入逗号分隔的等价规则
      // （DOMAIN,ipinfo.io,xxx 等 4 条，3 字段）置于首位 —— 内核 overrideRules 遇到首条
      // 非 2 段规则即 return，不再注入空格分隔规则；同时这 4 条规则本身合法，
      // 保留"IP 归属地检测走代理"的功能。其他配置（内核本就不注入）行为完全不变。
      // 注：文件已含注入结果时（如 repair/更新重复处理），先按完全匹配移除旧注入再写入，
      //     避免规则翻倍，且不影响用户自定义的其他目标（如 DOMAIN,ipinfo.io,DIRECT）。
      let kernelWouldInject = false;
      for (const r of finalRules) {
        const parts = r.split(',');
        if (parts.length !== 2) break;
        if (parts[0].trim().toUpperCase() === 'MATCH') {
          kernelWouldInject = true;
          break;
        }
      }
      if (kernelWouldInject) {
        const ipDetectDomains: string[] = ['ipinfo.io', 'ipapi.co', 'api.ip.sb', 'ipwho.is'];
        for (let i = 0; i < ipDetectDomains.length; i++) {
          const guardRule = `DOMAIN,${ipDetectDomains[i]},${matchTarget}`;
          for (let j = finalRules.length - 1; j >= 0; j--) {
            if (finalRules[j] === guardRule) {
              finalRules.splice(j, 1);
            }
          }
        }
        for (let i = ipDetectDomains.length - 1; i >= 0; i--) {
          finalRules.unshift(`DOMAIN,${ipDetectDomains[i]},${matchTarget}`);
        }
      }
      doc['rules'] = finalRules;

      // --- 提供者懒加载注入 ---
      // 远程 http proxy-provider / rule-provider 未设置 lazy 时, mihomo 加载配置会同步下载
      // 所有远程订阅源与规则集, 导致配置切换/冷启动加载缓慢(网络往返+失败重试)。
      // 注入 lazy: true 让订阅/规则集按需懒加载, 显著加快切换与启动速度
      // (节点由健康检查/懒加载逐步填充, 规则集首次命中规则时才拉取)。
      try {
        for (const section of ['proxy-providers', 'rule-providers']) {
          const providers = doc[section] as Record<string, Object | undefined> | undefined;
          if (providers && typeof providers === 'object') {
            for (const key of Object.keys(providers)) {
              const p = providers[key] as Record<string, Object | undefined> | undefined;
              if (p && typeof p === 'object' && p['lazy'] === undefined) {
                p['lazy'] = true;
              }
            }
          }
        }
      } catch (e) {
        console.warn("providers lazy 注入失败，跳过:", e);
      }

      // 按需插入 dns 代理节点：仅当最终规则中存在以 dns 为动作的规则
      // （如 AND,((NETWORK,UDP),(DST-PORT,53)),dns）时才插入。
      // 之前无条件插入：无 dns: 段的订阅配置在关闭 AND 规则后，
      // dns 节点无任何规则引用 → mihomo 校验失败导致配置无法加载。
      const needsDnsProxy = finalRules.some(r => {
        const idx = r.lastIndexOf(',');
        return idx > 0 && r.substring(idx + 1).trim() === 'dns';
      });
      if (needsDnsProxy) {
        let proxies = doc['proxies'] as Array<Record<string, string>> | undefined;
        if (!proxies) {
          proxies = [];
        }
        const hasDnsProxy = proxies.some((p: Record<string, string>) => p['name'] === 'dns' && p['type'] === 'dns');
        if (!hasDnsProxy) {
          proxies.unshift({ 'name': 'dns', 'type': 'dns' });
        }
        doc['proxies'] = proxies;
      } else if (!doc['dns']) {
        // 无规则引用 dns 且配置本身没有 dns: 段时，清理残留的 dns 节点：
        // 之前开启 AND 规则时注入的 dns 节点若未删除，关闭 AND 后
        // 该节点无任何规则引用 → mihomo 校验失败导致配置无法加载
        let proxies = doc['proxies'] as Array<Record<string, string>> | undefined;
        if (proxies) {
          proxies = proxies.filter((p: Record<string, string>) => !(p['name'] === 'dns' && p['type'] === 'dns'));
          doc['proxies'] = proxies;
        }
      }

      return stringify(doc);
    } catch (e) {
      console.error("YAML 注入字段失败，返回原内容:", e);
      return yamlContent;
    }
  }

  /**
   * 对 proxy-providers 与 rule-providers 注入 lazy: true 的轻量方法（不动 rules/dns/其他字段）。
   * 用于迁移已落盘的旧配置：导入时注入逻辑新增之前保存的 config.yaml
   * 缺少 lazy, 冷启动/切换时 mihomo 仍会同步下载远程订阅与规则集导致加载缓慢。
   * ★ rule-providers 同样需要 lazy: 订阅配置常含 20+ 远程规则集, 不注入则每次加载配置
   *   都同步下载全部规则集(网络慢时切换/启动卡很久), 注入后改为首次命中规则时懒加载。
   * @param yamlContent 配置内容
   * @returns 注入后的 YAML；若无需修改(无 providers 或已全部 lazy)返回原内容
   */
  static injectProvidersLazy(yamlContent: string): string {
    try {
      const doc = YamlUtils.parseYamlSafe(yamlContent);
      let changed = false;
      // proxy-providers 与 rule-providers 统一注入 lazy, 避免同步下载远程资源
      for (const section of ['proxy-providers', 'rule-providers']) {
        const providers = doc[section] as Record<string, Object | undefined> | undefined;
        if (!providers || typeof providers !== 'object') {
          continue;
        }
        for (const key of Object.keys(providers)) {
          const p = providers[key] as Record<string, Object | undefined> | undefined;
          if (p && typeof p === 'object' && p['lazy'] === undefined) {
            p['lazy'] = true;
            changed = true;
          }
        }
      }
      return changed ? stringify(doc) : yamlContent;
    } catch (e) {
      console.warn("providers lazy 注入失败，返回原内容:", e);
      return yamlContent;
    }
  }

  /**
   * 尝试将 Base64/Universal 订阅解码并转换为 Clash 可用的 YAML
   * @param rawContent 原始响应文本（可能是 Base64 编码，也可能直接是 vmess:// 等明文）
   * @returns 转换后的 Clash YAML 字符串，如果转换失败返回 null
   */
  static convertUniversalToClashYaml(rawContent: string): string | null {
    try {
      let decodedStr = "";
      const trimmed = rawContent.trim();

      // 如果已经是明文协议头，不需要 Base64 解码
      if (trimmed.startsWith('vmess://') || trimmed.startsWith('ss://') || trimmed.startsWith('trojan://')) {
        decodedStr = trimmed;
      } else {
        // 尝试 Base64 解码
        try {
          const base64Helper = new util.Base64Helper();
          const decodedUint8Array = base64Helper.decodeSync(trimmed);
          const decoder = util.TextDecoder.create('utf-8');
          decodedStr = decoder.decodeToString(decodedUint8Array);
        } catch (e) {
          // 解码失败说明不是 Base64 格式
          return null;
        }
      }

      // 验证解码后的内容是否包含通用协议头
      if (!decodedStr.includes('vmess://') && !decodedStr.includes('ss://') && !decodedStr.includes('trojan://')) {
        return null;
      }

      // 解析节点列表
      const proxyList: Array<Record<string, Object>> = [];
      const proxyNames: string[] = [];
      const lines = decodedStr.split('\n');

      for (const line of lines) {
        const trimLine = line.trim();
        if (!trimLine) continue;

        if (trimLine.startsWith('vmess://')) {
          try {
            const b64Str = trimLine.replace('vmess://', '');
            // VMess 的 Base64 经常缺失填充符 '='，手动补齐避免解码失败
            const pad = b64Str.length % 4 === 0 ? '' : '='.repeat(4 - b64Str.length % 4);

            // 同样注意 util.Base64Helper 的使用
            const base64Helper = new util.Base64Helper();
            const jsonStr = util.TextDecoder.create('utf-8').decodeToString(base64Helper.decodeSync(b64Str + pad));

            const vmessObj = JSON.parse(jsonStr);
            const name = vmessObj.ps || `VMess-${proxyNames.length}`;

            const proxy: Record<string, Object> = {
              name: name,
              type: "vmess",
              server: vmessObj.add,
              port: parseInt(vmessObj.port) || 443,
              uuid: vmessObj.id,
              alterId: parseInt(vmessObj.aid) || 0,
              cipher: vmessObj.scy || "auto",
              udp: true
            };

            // 处理传输层 (network: ws / grpc 等)
            if (vmessObj.net === "ws") {
              proxy.network = "ws";
              proxy["ws-opts"] = {
                path: vmessObj.path || "/",
                headers: { Host: vmessObj.host || "" }
              };
            } else if (vmessObj.net === "grpc") {
              proxy.network = "grpc";
              proxy["grpc-opts"] = { "grpc-service-name": vmessObj.path || "" };
            }

            // 处理 TLS
            if (vmessObj.tls === "tls") {
              proxy.tls = true;
              if (vmessObj.sni) {
                proxy.servername = vmessObj.sni;
              }
              proxy["skip-cert-verify"] = false;
            }

            proxyList.push(proxy);
            proxyNames.push(name);
          } catch (e) {
            console.warn("解析单条 vmess 链接失败", e);
          }
        } else if (trimLine.startsWith('ss://')) {
          // Shadowsocks 解析逻辑略 (SIP002)
          const name = `SS-Node-${proxyNames.length}`;
          // TODO: 完善 SS 解析
          proxyList.push({ name: name, type: "ss", server: "0.0.0.0", port: 1, cipher: "aes-256-gcm", password: "password" });
          proxyNames.push(name);
        } else if (trimLine.startsWith('trojan://')) {
          // Trojan 解析逻辑略
          const name = `Trojan-Node-${proxyNames.length}`;
          // TODO: 完善 Trojan 解析
          proxyList.push({ name: name, type: "trojan", server: "0.0.0.0", port: 1, password: "password" });
          proxyNames.push(name);
        }
      }

      if (proxyNames.length === 0) return null;

      // 构建 Clash YAML 对象
      const clashDoc = {
        proxies: proxyList,
        "proxy-groups": [
          {
            name: "PROXY",
            type: "select",
            proxies: proxyNames
          }
        ],
        rules: ["MATCH,PROXY"]
      };

      // 序列化为字符串
      let finalYaml = stringify(clashDoc);

      // 调用注入方法，确保生成的配置也包含 DNS 规则
      finalYaml = this.injectDnsFields(finalYaml);

      return finalYaml;
    } catch (e) {
      console.error("Universal 订阅转换失败:", e);
      return null;
    }
  }

  /**
   * 执行用户 JS 脚本修改配置，并注入 DNS 规则
   * @param yamlContent 原始 YAML 字符串
   * @param scriptContent 用户的 JS 脚本内容
   * @param profileName 当前配置的名称
   * @param customRules 自定义注入的规则数组
   * @param deleteRules 需要删除的规则数组
   * @returns 处理后的最终 YAML 字符串
   */
/**
 * 从 YAML 配置内容中提取 MATCH 规则的目标策略
 * @param yamlContent 原始 YAML 字符串
 * @returns MATCH 目标（如 "Proxy"、"DIRECT"、"REJECT"），未找到时默认 "DIRECT"
 */
static extractMatchTarget(yamlContent: string): string {
  try {
    const doc = YamlUtils.parseYamlSafe(yamlContent);
    const rules = doc['rules'] as Array<string> | undefined;
    if (!rules) return 'DIRECT';
    for (const rule of rules) {
      if (rule.trim().startsWith('MATCH,')) {
        const target = rule.split(',')[1]?.trim();
        return target || 'DIRECT';
      }
    }
  } catch (e) {
    console.error('extractMatchTarget 解析失败', e);
  }
  return 'DIRECT';
}

/*  static executeScriptAndInject(
    yamlContent: string,
    scriptContent: string = "",
    profileName: string = "",
    customRules: string[] = [],
    deleteRules: string[] = []
  ): string {
    let processedYaml = yamlContent;

    // 执行用户脚本 (如果有)
    if (scriptContent && scriptContent.trim().length > 0) {
      try {
        console.info(`[YamlUtils] 开始执行配置 [${profileName}] 的 JS 脚本`);
        // YAML 转 JSON
        const doc = parse(yamlContent);
        const configJsonStr = JSON.stringify(doc);
        // 调用 boa 引擎执行脚本
        const modifiedConfigJsonStr = executeScript(scriptContent, configJsonStr, profileName);
        // JSON 转回 YAML
        const modifiedDoc = JSON.parse(modifiedConfigJsonStr);
        processedYaml = stringify(modifiedDoc);
        console.info(`[YamlUtils] 配置 [${profileName}] JS 脚本执行完毕`);
      } catch (e) {
        console.error(`[YamlUtils] 执行用户脚本失败: ${e}`);
        throw e; // 抛出异常让上层感知
      }
    }
    // 统一注入 DNS 和规则
    return YamlUtils.injectDnsFields(processedYaml, customRules, deleteRules);
  }*/

}
