import { common, Context, WantAgent, wantAgent } from "@kit.AbilityKit";
import { backgroundTaskManager } from "@kit.BackgroundTasksKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { hilog } from "@kit.PerformanceAnalysisKit";
import ClashViewModel from "../../entryability/ClashViewModel";
import { Profile, ProfileType } from "proxy_core";
import { convertMillisecondsToTimeGap, DEFAULT_TIMEOUT } from "../entity/Constants";
import { Xb_GetResourceString, Xb_NotificationUtils } from "xb_components";
import { notificationManager } from "@kit.NotificationKit";

/**
 * 配置自动更新服务
 * 负责定期检查并更新配置文件
 */
export class ConfigAutoUpdateService {
  private context: Context | null = null;
  /** 定时任务ID */
  private updateTimerId?: number = undefined;
  /** 后台任务通知ID */
  private notificationId?: number = undefined;
  /** 是否正在更新 */
  private isUpdating: boolean = false;
  /** 需要自动更新的配置 */
  private autoUpdateProfiles: Profile[] = [];

  initContext(context: Context): void {
    this.context = context;
    hilog.debug(0xFF00, "ConfigAutoUpdateService", "初始化配置自动更新服务");
  }

  /**
   * 启动配置自动更新服务
   * @param context 应用上下文
   */
  async start(): Promise<void> {
    if (this.updateTimerId) {
      hilog.debug(0xFF00, "ConfigAutoUpdateService", "配置自动更新服务已在运行");
      return;
    }

    hilog.warn(0xFF00, "ConfigAutoUpdateService", "启动配置自动更新服务");

    try { // 立即执行一次检查
      await this.checkAndUpdateConfigs();
    } catch (e) {
      return Promise.reject(e);
    }

    // 启动后台长时任务
    // const notificationId = await this.startContinuousTask();
    // if (notificationId > 0) {
    //   this.notificationId = notificationId;
    // }

    // 找出更新频率最快的配置的毫秒值
    const updateIntervalArray: number[] = this.autoUpdateProfiles.map((profile: Profile) => {
      // 小于1分钟的重置为默认值并更新一次数据库
      if (profile.autoUpdateDuration < DEFAULT_TIMEOUT) {
        profile.autoUpdateDuration = DEFAULT_TIMEOUT; // 默认1分钟
        ClashViewModel.updateProfile(profile);
      }

      return profile.autoUpdateDuration;
    })

    const updateInterval: number = Math.min(...updateIntervalArray) // 默认1分钟

    // 启动定时任务
    this.updateTimerId = setInterval(async () => {
      await this.checkAndUpdateConfigs();
    }, updateInterval);

    hilog.warn(0xFF00, "ConfigAutoUpdateService", "配置自动更新服务启动成功");
  }

  /**
   * 停止配置自动更新服务
   * @param context 应用上下文
   */
  async stop(): Promise<void> {
    if (!this.context) {
      hilog.error(0xFF00, "ConfigAutoUpdateService", "关闭后台长时任务失败，请检查应用上下文");
      return Promise.reject("请检查应用上下文");
    }

    hilog.error(0xFF00, "ConfigAutoUpdateService", "停止配置自动更新服务");

    // 清除定时器
    if (this.updateTimerId) {
      clearInterval(this.updateTimerId);
      this.updateTimerId = undefined;
    }

    // 停止后台任务
    // if (this.notificationId) {
    //   try {
    //     await backgroundTaskManager.stopBackgroundRunning(this.context, this.notificationId);
    //     this.notificationId = undefined;
    //     hilog.info(0xFF00, "ConfigAutoUpdateService", "后台任务停止成功");
    //   } catch (err) {
    //     hilog.error(0xFF00, "ConfigAutoUpdateService",
    //       `后台任务停止失败: ${JSON.stringify(err)}`);
    //   }
    // }

    hilog.info(0xFF00, "ConfigAutoUpdateService", "配置自动更新服务已停止");
  }

  /**
   * 重置配置自动更新服务
   */
  async reset() {
    if (!this.updateTimerId) {
      hilog.info(0xFF00, "ConfigAutoUpdateService", "配置自动更新服务已处于停止状态");
      // 没启动过 -> 执行一次检查是否需要开启自动更新
      try {
        await this.start();
      } catch (error) {
        hilog.error(0xFF00, 'ConfigAutoUpdateService',
          `配置自动更新服务启动失败 - ${JSON.stringify(error)}`);
      }
      return;
    }

    hilog.warn(0xFF00, "ConfigAutoUpdateService", "重置配置自动更新服务");

    try {
      await this.stop();
      await this.start();
    } catch (error) {
      hilog.error(0xFF00, 'ConfigAutoUpdateService',
        `配置自动更新服务启动失败 - ${JSON.stringify(error)}`);
    }
  }

  /**
   * 手动触发检查更新（用于应用切回前台时）
   */
  async checkNow(): Promise<void> {
    hilog.info(0xFF00, "ConfigAutoUpdateService", "手动触发配置更新检查");
    await this.checkAndUpdateConfigs();
  }

  /**
   * 检查并更新所有需要自动更新的配置
   */
  private async checkAndUpdateConfigs(): Promise<void> {
    // 防止重复执行
    if (this.isUpdating) {
      hilog.warn(0xFF00, "ConfigAutoUpdateService", "配置更新正在进行中，跳过本次检查");
      return;
    }

    this.isUpdating = true;

    try {
      hilog.warn(0xFF00, "ConfigAutoUpdateService", "开始检查配置更新");

      // 获取所有配置
      const profiles = await ClashViewModel.getProfiles();
      hilog.info(0xFF00, "ConfigAutoUpdateService", `获取到 ${profiles.length} 个配置`);

      // 筛选需要自动更新的配置
      this.autoUpdateProfiles = profiles.filter((profile: Profile) => {
        return profile.autoUpdate && profile.type === ProfileType.Url;
      });

      hilog.info(0xFF00, "ConfigAutoUpdateService",
        `需要自动更新的配置数量: ${this.autoUpdateProfiles.length}`);

      if (this.autoUpdateProfiles.length === 0) {
        return Promise.reject("没有需要自动更新的配置");
      }

      // 当前时间
      const now = Date.now();

      // 检查每个配置是否需要更新
      for (const profile of this.autoUpdateProfiles) {
        try {
          const updateInterval = profile.autoUpdateDuration
          // 忽略小于等于0的间隔
          if (updateInterval <= 0) {
            return
          }

          const lastUpdateTime = profile.lastUpdateDate || 0;
          const timeSinceLastUpdate = now - lastUpdateTime;

          // 格式化打印字符串
          let updateIntervalStr = `${updateInterval}毫秒`
          const timeGap = convertMillisecondsToTimeGap(updateInterval)
          switch (timeGap.unit) {
            case 0: // 分钟
              updateIntervalStr = `${timeGap.value}分钟`
              break;
            case 1: // 小时
              updateIntervalStr = `${timeGap.value}小时`
              break;
            case 2: // 天
              updateIntervalStr = `${timeGap.value}天`
              break;
          }

          // 更新间隔 => 允许5秒误差
          const tolerance = 5 * 1000;
          const updateThreshold = updateInterval - tolerance;

          hilog.info(0xFF00, "ConfigAutoUpdateService",
            `配置 [${profile.name}] - 上次更新: ${new Date(lastUpdateTime).toLocaleString()}, ` +
              `更新间隔: ${updateInterval} - ${updateIntervalStr}, 距离上次更新: ${Math.floor(timeSinceLastUpdate /
                1000 / 60)}分钟, ` +
              `允许误差: ${tolerance / 1000}秒`);

          // 判断是否需要更新
          if (timeSinceLastUpdate >= updateThreshold) {
            hilog.info(0xFF00, "ConfigAutoUpdateService",
              `配置 [${profile.name}] 需要更新，开始更新...`);

            // 执行更新
            await ClashViewModel.updateProfileConfig(profile.id);

            // 推送通知消息 - 成功
            if (this.context) {
              await Xb_NotificationUtils.publishTextNotification(
                (this.context as common.UIAbilityContext),
                Number(profile.id),
                {
                  title: "ClashBox",
                  text: `${Xb_GetResourceString($r('app.string.Configuration'),
                    this.context)} ${profile.name} ${Xb_GetResourceString($r('app.string.update_success'),
                    this.context)}`
                },
                notificationManager.SlotType.SERVICE_INFORMATION,
                { abilityName: 'EntryAbility' }
              )
            }

            hilog.info(0xFF00, "ConfigAutoUpdateService",
              `配置 [${profile.name}] 更新完成`);
          } else {
            const remainingTime = Math.floor((updateInterval - timeSinceLastUpdate) / 1000 / 60);
            hilog.info(0xFF00, "ConfigAutoUpdateService",
              `配置 [${profile.name}] 无需更新，还需等待 ${remainingTime} 分钟`);
          }
        } catch (error) {
          hilog.error(0xFF00, "ConfigAutoUpdateService", error);

          // 推送通知消息 - 失败
          if (this.context) {
            await Xb_NotificationUtils.publishTextNotification(
              (this.context as common.UIAbilityContext),
              Number(profile.id),
              {
                title: "ClashBox",
                text: error
              },
              notificationManager.SlotType.SERVICE_INFORMATION,
              { abilityName: 'EntryAbility' }
            )
          }
        }
      }

      hilog.info(0xFF00, "ConfigAutoUpdateService", "配置更新检查完成");
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0xFF00, "ConfigAutoUpdateService",
        `配置更新检查失败: ${err.message}`);
      return Promise.reject(err.message);
    } finally {
      this.isUpdating = false;
    }
  }

  /**
   *  启动后台长时任务
   * @param context 应用上下文
   * @returns 通知ID
   */
  private async startContinuousTask(): Promise<number> {
    if (!this.context) {
      hilog.error(0xFF00, "ConfigAutoUpdateService", "启动后台长时任务失败，请检查应用上下文");
      return -1;
    }

    const context = this.context;

    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: context.applicationInfo.name,
          abilityName: "EntryAbility",
        },
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG],
    };

    try {
      const wantAgentObj: WantAgent = await wantAgent.getWantAgent(wantAgentInfo);
      const result = await backgroundTaskManager.startBackgroundRunning(
        context,
        ["dataTransfer"], // 使用数据传输类型
        wantAgentObj
      );
      hilog.info(0xFF00, "ConfigAutoUpdateService",
        `后台长时任务启动成功, notificationId=${result.notificationId}`);
      return result.notificationId;
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(0xFF00, "ConfigAutoUpdateService",
        `后台长时任务启动失败: Code=${error.code}, Msg=${error.message}`);
      return -1;
    }
  }
}

export default new ConfigAutoUpdateService();

