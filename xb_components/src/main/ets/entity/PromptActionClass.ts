// 改编自https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/arkts-uicontext-custom-dialog#完整示例
import { BusinessError } from '@kit.BasicServicesKit';
import { ComponentContent, promptAction, UIContext } from '@kit.ArkUI';

export class Xb_PromptActionsClass {
  // 存储实例资源
  private static contextMap: Map<string, UIContext> = new Map();
  private static contentNodeMap: Map<string, ComponentContent<Object>> = new Map();

  // 使用单独的Map存储options，并允许共享
  private static optionsMap: Map<string, promptAction.BaseDialogOptions> = new Map();

  // 存储key到options名称的映射关系
  private static keyToOptionsNameMap: Map<string, string> = new Map();

  // 默认配置名称常量
  private static readonly DEFAULT_OPTIONS_NAME = "__DEFAULT__";

  // 初始化默认配置
  static {
    // 设置一个空对象作为默认配置
    Xb_PromptActionsClass.optionsMap.set(Xb_PromptActionsClass.DEFAULT_OPTIONS_NAME, {});
  }

  // 设置指定key的上下文
  static setContext(key: string, context: UIContext) {
    Xb_PromptActionsClass.contextMap.set(key, context);
  }

  // 设置指定key的内容节点
  static setContentNode(key: string, node: ComponentContent<Object>) {
    Xb_PromptActionsClass.contentNodeMap.set(key, node);
  }

  // 定义/设置共享的options配置
  static defineOptions(optionsName: string, options: promptAction.BaseDialogOptions) {
    Xb_PromptActionsClass.optionsMap.set(optionsName, options);
  }

  // 设置全局默认配置
  static setDefaultOptions(options: promptAction.BaseDialogOptions) {
    Xb_PromptActionsClass.optionsMap.set(Xb_PromptActionsClass.DEFAULT_OPTIONS_NAME, options);
  }

  // 将弹窗key关联到指定的options配置
  static useOptions(key: string, optionsName?: string) {
    // 如果不提供optionsName，则使用默认配置
    Xb_PromptActionsClass.keyToOptionsNameMap.set(key, optionsName || Xb_PromptActionsClass.DEFAULT_OPTIONS_NAME);
  }

  // 打开指定key的弹窗
  static openDialog(key: string, overrideOptions?: Partial<promptAction.BaseDialogOptions>) {
    const ctx = Xb_PromptActionsClass.contextMap.get(key);
    const contentNode = Xb_PromptActionsClass.contentNodeMap.get(key);

    if (!ctx || !contentNode) {
      console.error(`Missing context or contentNode for key: ${key}`);
      return;
    }

    // 获取配置名称（如果未设置则使用默认）
    const optionsName = Xb_PromptActionsClass.keyToOptionsNameMap.get(key) || Xb_PromptActionsClass.DEFAULT_OPTIONS_NAME;

    // 获取基础配置（如果不存在则使用空对象）
    const baseOptions = Xb_PromptActionsClass.optionsMap.get(optionsName) || {};

    // 合并覆盖选项
    const finalOptions = overrideOptions ?
      { ...baseOptions, ...overrideOptions } :
      baseOptions;

    ctx.getPromptAction().openCustomDialog(contentNode, finalOptions)
      .then(() => {
        console.info(`[${key}] OpenCustomDialog complete.`);
      })
      .catch((error: BusinessError) => {
        console.error(`[${key}] OpenCustomDialog failed: ${error.code} - ${error.message}`);
      });
  }

  // 关闭指定key的弹窗
  static closeDialog(key: string) {
    const ctx = Xb_PromptActionsClass.contextMap.get(key);
    const contentNode = Xb_PromptActionsClass.contentNodeMap.get(key);

    if (!ctx || !contentNode) {
      console.error(`Missing context or contentNode for key: ${key}`);
      return;
    }

    ctx.getPromptAction().closeCustomDialog(contentNode)
      .then(() => {
        console.info(`[${key}] CloseCustomDialog complete.`);
      })
      .catch((error: BusinessError) => {
        console.error(`[${key}] CloseCustomDialog failed: ${error.code} - ${error.message}`);
      });
  }

  // 更新共享的options配置
  static updateOptions(optionsName: string, newOptions: promptAction.BaseDialogOptions) {
    Xb_PromptActionsClass.optionsMap.set(optionsName, newOptions);
    console.info(`Options "${optionsName}" updated`);
  }

  // 清理指定key的资源
  static clearResources(key: string) {
    Xb_PromptActionsClass.contextMap.delete(key);
    Xb_PromptActionsClass.contentNodeMap.delete(key);
    Xb_PromptActionsClass.keyToOptionsNameMap.delete(key);
    console.info(`[${key}] Resources cleared`);
  }
}