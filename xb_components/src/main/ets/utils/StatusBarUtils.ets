
import { image } from '@kit.ImageKit';
import { emitter } from '@kit.BasicServicesKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { Xb_ImageUtils } from './ImageUtils';
import { Xb_GetResourceString } from './ResourceStringUtil';
import { statusBarManager } from '@kit.DeskTopExtensionKit';

// 定义图标资源接口
export interface StatusBarIconResource {
  white: string;
  black: string;
}

// 定义状态栏配置接口
export interface StatusBarConfig {
  icon: string | StatusBarIconResource;
  title?: string; // 用于设置悬停显示的应用名称 - 传入待接入模块的model-name
  abilityName?: string; // 用于设置点击启动的Ability名称
  quick?: statusBarManager.QuickOperation; // 如果提供，将完全覆盖默认的左键“点击打开”行为，用于自定义弹窗
  menus?: statusBarManager.StatusBarGroupMenu[];
}

// 定义事件数据接口
interface IconClickEventData {
  iconClickType: string;
}

interface RightMenuClickEventData {
  menuCode: string;
}

class StatusBarUtils {
  private context: common.Context | null = null;
  private UIContext: UIContext | null = null;
  private isAdded: boolean = false;
  private iconClickCallback?: (eventData: emitter.EventData) => void;
  private rightMenuClickCallback?: (eventData: emitter.EventData) => void;

  /**
   * 从 rawfile 文件名加载图片并生成 PixelMap
   * @param icon 图标资源
   * @returns Promise<image.PixelMap>
   */
  private async loadPixelMap(icon: string): Promise<image.PixelMap> {
    if (!this.UIContext) {
      throw new Error("UIContext is not initialized.");
    }
    try {
      return await Xb_ImageUtils.getPixelImage(this.UIContext, icon)
    } catch (error) {
      const err = error as BusinessError;
      console.error(`Failed to load pixel map. Code: ${err.code}, Message: ${err.message}`);
      throw new Error(err.message);
    }
  }

  /**
   * 初始化状态栏图标
   * @param UIContext UI上下文
   * @param config 状态栏配置
   */
  async initStatusBar(UIContext: UIContext, config: StatusBarConfig) {
    this.UIContext = UIContext;
    this.context = UIContext.getHostContext()!;
    if (!this.UIContext) {
      throw new Error("StatusBarUtils.initStatusBar UIContext is not initialized.");
    }
    if (!this.context) {
      throw new Error("StatusBarUtils.initStatusBar context is not initialized.");
    }
    console.debug("StatusBarUtils.initStatusBar 准备添加状态栏图标");
    try {
      // 处理图标资源
      let whiteIcon: string;
      let blackIcon: string;
      const iconResource = config.icon as StatusBarIconResource;
      if (iconResource.white !== undefined && iconResource.black !== undefined) {
        whiteIcon = iconResource.white;
        blackIcon = iconResource.black;
      } else {
        whiteIcon = config.icon as string;
        blackIcon = config.icon as string;
      }
      // 创建PixelMap
      const whitePixelMap = await this.loadPixelMap(whiteIcon);
      const blackPixelMap = await this.loadPixelMap(blackIcon);

      // 检查设备支持情况
      if (canIUse("SystemCapability.PCService.StatusBarManager")) {
        let finalQuickOperation: statusBarManager.QuickOperation;
        let targetAbilityName: string; // 用于统一菜单的Ability名称

        if (config.quick) {
          finalQuickOperation = config.quick;
          targetAbilityName = finalQuickOperation.abilityName ?? "EntryAbility";
          console.info("StatusBarUtils.initStatusBar Using user-provided quickOperation with custom popup.");
        } else {
          targetAbilityName = config?.abilityName || '';
          finalQuickOperation = {
            title: config?.title || "应用", // 使用配置的 title 或默认值
            abilityName: targetAbilityName, // 留空表示，接管状态栏图标点击事件
            moduleName: config?.title || "应用",
            height: 100,
            loadingStatus: true
          };
          targetAbilityName = config?.abilityName || "EntryAbility";
          console.info(`StatusBarUtils.initStatusBar Using default click-to-open behavior. moduleName: "${finalQuickOperation.moduleName}", Ability: "${finalQuickOperation.abilityName}"`);
        }
        // 构建默认右键菜单，使用统一的 targetAbilityName
        const defaultMenus: statusBarManager.StatusBarGroupMenu[] = [
          [
            {
              title: Xb_GetResourceString($r('app.string.xb_open'), this.UIContext!),
              menuAction: { abilityName: targetAbilityName }
            } as statusBarManager.StatusBarMenuItem
          ]
        ];
        // 构建状态栏项
        const statusBarItem: statusBarManager.StatusBarItem = {
          icons: {
            white: whitePixelMap,
            black: blackPixelMap
          } as statusBarManager.StatusBarIcon,
          quickOperation: finalQuickOperation,
          statusBarGroupMenu: config.menus ?? defaultMenus
        };

        statusBarManager.addToStatusBar(this.context, statusBarItem, () => {
          this.isAdded = true;
          console.info("StatusBarUtils.initStatusBar 状态栏添加完成");
        });
        // 注册监听
        this.registerClickListeners()
      } else {
        console.error("StatusBarUtils.initStatusBar 当前设备不支持设置状态栏图标");
      }
    } catch (e) {
      const err = e as BusinessError;
      console.error(`StatusBarUtils.initStatusBar 状态栏图标添加失败. Code: ${err.code}, Message: ${err.message}`);
    }
  }

  /**
   * 注册状态栏点击事件监听 (仅在需要复杂自定义逻辑时使用)
   */
  private registerClickListeners() {
    // 左键点击监听
    if (canIUse("SystemCapability.PCService.StatusBarManager")) {
      statusBarManager.on("statusBarIconClick", (eventData: emitter.EventData) => {
        if (this.iconClickCallback) {
          this.iconClickCallback(eventData);
        }
      });
    } else {
      console.error("StatusBarUtils.registerClickListeners 当前设备不支持statusBarManager-左键点击监听");
    }

    // 右键菜单点击监听
    if (canIUse("SystemCapability.PCService.StatusBarManager")) {
      statusBarManager.on("rightMenuClick", (eventData: emitter.EventData) => {
        if (this.rightMenuClickCallback) {
          this.rightMenuClickCallback(eventData);
        }
      });
    } else {
      console.error("StatusBarUtils.registerClickListeners 当前设备不支持statusBarManager-右键菜单点击监听");
    }
  }

  removeStatusBar() {
    if (!this.context) {
      console.error("StatusBarUtils 未初始化");
      return;
    }
    if (!this.isAdded) {
      console.warn("StatusBarUtils 状态栏图标未添加");
      return;
    }
    try {
      if (canIUse("SystemCapability.PCService.StatusBarManager")) {
        statusBarManager.removeFromStatusBar(this.context);
      } else {
        console.error(`StatusBarUtils 状态栏图标移除失败, 当前设备不支持此操作`);
      }
      this.isAdded = false;
      console.info("StatusBarUtils 状态栏图标已移除");
    } catch (e) {
      console.error(`StatusBarUtils 移除失败: ${JSON.stringify(e)}`);
    }
  }

  async updateStatusBarIcon(icon: string | StatusBarIconResource) {
    if (!this.context || !this.isAdded) {
      console.error("StatusBarUtils 状态栏未初始化或未添加");
      return;
    }
    try {
      let whiteIcon: string;
      let blackIcon: string;
      const iconResource = icon as StatusBarIconResource;
      if (iconResource.white !== undefined && iconResource.black !== undefined) {
        whiteIcon = iconResource.white;
        blackIcon = iconResource.black;
      } else {
        whiteIcon = icon as string;
        blackIcon = icon as string;
      }
      const whitePixelMap = await this.loadPixelMap(whiteIcon);
      const blackPixelMap = await this.loadPixelMap(blackIcon);
      if (canIUse("SystemCapability.PCService.StatusBarManager")) {
        statusBarManager.updateStatusBarIcon(this.context, {
          white: whitePixelMap,
          black: blackPixelMap
        });
      } else {
        console.error(`StatusBarUtils 状态栏图标更新失败, 当前设备不支持此操作`);
      }
      console.info("StatusBarUtils 状态栏图标已更新");
    } catch (e) {
      const err = e as BusinessError;
      console.error(`StatusBarUtils 更新图标失败. Code: ${err.code}, Message: ${err.message}`);
    }
  }

  updateStatusBarMenu(menus: statusBarManager.StatusBarGroupMenu[]) {
    if (!this.context || !this.isAdded) {
      console.error("StatusBarUtils 状态栏未初始化或未添加");
      return;
    }
    try {
      if (canIUse("SystemCapability.PCService.StatusBarManager")) {
        statusBarManager.updateStatusBarMenu(this.context, menus);
      } else {
        console.error(`StatusBarUtils 右键菜单更新失败, 当前设备不支持此操作`);
      }
      console.info("StatusBarUtils 右键菜单已更新");
    } catch (e) {
      console.error(`StatusBarUtils 更新菜单失败: ${JSON.stringify(e)}`);
    }
  }

  updateQuickOperationHeight(height: number) {
    if (!this.context || !this.isAdded) {
      console.error("StatusBarUtils 状态栏未初始化或未添加");
      return;
    }
    try {
      if (canIUse("SystemCapability.PCService.StatusBarManager")) {
        statusBarManager.updateQuickOperationHeight(this.context, height);
      } else {
        console.error(`StatusBarUtils 更新高度失败, 当前设备不支持此操作`);
      }
      console.info(`StatusBarUtils 弹窗高度已更新为: ${height}`);
    } catch (e) {
      console.error(`StatusBarUtils 更新高度失败: ${JSON.stringify(e)}`);
    }
  }

  setIconClickCallback(callback?: (eventData: emitter.EventData) => void) {
    if (callback) {
      this.iconClickCallback = callback;
    } else {
      // 默认注册拉起应用窗口
      this.iconClickCallback = () => {
        if (!this.UIContext) {
          throw new Error("StatusBarUtils.setIconClickCallback UIContext is not initialized.");
        }
        let context = this.UIContext.getHostContext() as common.UIAbilityContext;
        context.showAbility().then(() => {
          console.info(`StatusBarUtils.setIconClickCallback.showAbility success`);
        }).catch((err: BusinessError) => {
          console.error(`StatusBarUtils.setIconClickCallback.showAbility fail, err: ${JSON.stringify(err)}`);
        });
        console.info(`StatusBarUtils.setIconClickCallback 已注册默认监听 -> 打开应用窗口`)
      }
    }
  }

  setRightMenuClickCallback(callback: (eventData: emitter.EventData) => void) {
    this.rightMenuClickCallback = callback;
  }

  destroy() {
    if (canIUse("SystemCapability.PCService.StatusBarManager")) {
      statusBarManager.off("statusBarIconClick");
      statusBarManager.off("rightMenuClick");
    }
    this.iconClickCallback = undefined;
    this.rightMenuClickCallback = undefined;
    this.context = null;
    this.UIContext = null;
    this.isAdded = false;
  }

}

export const Xb_StatusBarUtils = new StatusBarUtils();
