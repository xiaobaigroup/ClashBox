import { JSContext, JSValue  } from "@devzeng/quickjs";


export class ScriptExecutor {
  /**
   * 执行 JS 脚本修改配置
   * @param scriptContent JS 脚本内容（需包含 main 函数）
   * @param configJsonStr 配置的 JSON 字符串
   * @param profileName 配置名称
   * @returns 修改后的 JSON 字符串
   */
  static execute(scriptContent: string, configJsonStr: string, profileName: string): string {
    const context = new JSContext();
    try {
      // 注入一个空的 console 对象，防止用户脚本里的 console.log 报错
      context.evaluateScript(`
        var console = {
          log: function() {},
          error: function() {},
          warn: function() {}
        };
      `);

      // 执行用户的脚本，定义 main 函数
      context.evaluateScript(scriptContent);

      // 构建包装器函数
      const wrapperScript = `
        (function(configStr, pName) {
          if (typeof main !== 'function') {
            throw new Error("JS脚本中未找到 main(config, profileName) 函数");
          }
          try {
            var config = JSON.parse(configStr);
            var result = main(config, pName);
            if (!result) {
                throw new Error("main 函数未返回有效配置对象");
            }
            return JSON.stringify(result);
          } catch(e) {
            throw new Error("JS执行异常: " + e.message);
          }
        })
      `;

      // 获取包装器函数
      const wrapperFn = context.evaluateScript(wrapperScript);

      // 准备参数并调用包装器
      const configVal = JSValue.valueWithString(configJsonStr, context);
      const nameVal = JSValue.valueWithString(profileName, context);

      const retValue = wrapperFn.callWithArguments([configVal, nameVal]);

      // 提取结果字符串
      const resultStr = retValue.toString();
      if (!resultStr || resultStr === 'undefined' || resultStr === 'null') {
        throw new Error("脚本执行未返回有效配置");
      }

      return resultStr;
    } catch (e) {
      console.error(`[QuickJS] 脚本执行错误: ${e}`);
      throw new Error(e)
    } finally {
      // 无论成功失败，必须释放 QuickJS 上下文，防止内存泄漏！
      context.release();
    }
  }

}
