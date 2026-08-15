import { parse, stringify } from 'yaml';
import { YamlUtils } from "./YamlUtils";
import { ScriptExecutor } from './ScriptExecutor'

export class YamlUtil {

  /**
   * 执行用户 JS 脚本修改配置，并注入 DNS 规则
   * @param yamlContent 原始 YAML 字符串
   * @param scriptContent 用户的 JS 脚本内容
   * @param profileName 当前配置的名称
   * @param customRules 自定义注入的规则数组
   * @param deleteRules 需要删除的规则数组
   * @returns 处理后的最终 YAML 字符串
   */
  static executeScriptAndInject(
    yamlContent: string,
    scriptContent: string = "",
    profileName: string = "",
    customRules: string[] = [],
    deleteRules: string[] = [],
    fixTlsFingerprint: boolean = true
  ): string {
    let processedYaml = yamlContent;

    if (scriptContent && scriptContent.trim().length > 0) {
      try {
        console.info(`[YamlUtils] 开始执行配置 [${profileName}] 的 JS 脚本`);
        // ★ 使用安全解析: 无引号 16 进制/科学计数法形态字符串(如 password: 48654786e0504509)
        // 会被 yaml 解析为 Infinity, JSON.stringify(Infinity) 输出 null 导致密码丢失
        const configJsonStr = JSON.stringify(YamlUtils.parseYamlSafe(yamlContent));

        const modifiedConfigJsonStr = ScriptExecutor.execute(scriptContent, configJsonStr, profileName);

        // 变更检测：如果脚本执行后内容没变，直接返回原内容，标记未修改
        if (configJsonStr === modifiedConfigJsonStr) {
          console.info(`[YamlUtils] 配置 [${profileName}] 未被脚本修改，跳过备份和注入`);
          return yamlContent;
        }

        processedYaml = stringify(JSON.parse(modifiedConfigJsonStr));
        console.info(`[YamlUtils] 配置 [${profileName}] JS 脚本执行完毕，已发生修改`);
      } catch (e) {
        console.error(`[YamlUtils] 执行用户脚本失败: ${e}`);
        throw new Error(e);
      }
    }

    return YamlUtils.injectDnsFields(processedYaml, customRules, deleteRules, fixTlsFingerprint);
  }


}