import { Context, WantAgent, wantAgent } from "@kit.AbilityKit";
import { backgroundTaskManager } from "@kit.BackgroundTasksKit";
import { notificationManager } from "@kit.NotificationKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { AppConfig, AppFlowingState } from "../../entryability/AppState";

/**
 * 长时后台下载服务
 * 负责展示持续的下载进度通知（例如 VPN 流量监控）
 */
export class BackgroundDownService {
  private notificationId?: number = undefined;
  private noticeTimer?: number;

  /**
   * 启动后台任务与通知
   */
  async start(context: Context): Promise<void> {
    if (this.notificationId) {
      hilog.info(0xFF00, "BackgroundDownService", "任务已在运行，无需重复启动");
      return;
    }

    const id = await this.startContinuousTask(context);
    if (id < 0) {
      hilog.error(0xFF00, "BackgroundDownService", "无法启动后台长时任务");
      return;
    }

    this.notificationId = id;

    clearInterval(this.noticeTimer);
    await this.updateTraffic();

    // 定期更新通知内容
    this.noticeTimer = setInterval(async () => {
      await this.updateTraffic();
    }, 10000);

    hilog.info(0xFF00, "BackgroundDownService", "后台长时任务已启动");
  }

  /**
   * 停止后台任务
   */
  async stop(context: Context): Promise<void> {
    clearInterval(this.noticeTimer);
    this.noticeTimer = undefined;

    this.notificationId = undefined;
    hilog.info(0xFF00, "BackgroundDownService", "准备停止后台任务");

    try {
      await backgroundTaskManager.stopBackgroundRunning(context);
      hilog.info(0xFF00, "BackgroundDownService", "后台任务停止成功");
    } catch (err) {
      hilog.error(
        0xFF00,
        "BackgroundDownService",
        `后台任务停止失败：${JSON.stringify(err)}`
      );
    }
  }

  /**
   * 定时更新下载进度通知
   */
  async updateTraffic(): Promise<void> {
    try {
      const appConfig: AppConfig =
        AppStorage.get<AppConfig>("appConfig") ?? new AppConfig();
      const appFlowingState: AppFlowingState =
        AppStorage.get<AppFlowingState>("appFlowingState") ?? new AppFlowingState();

      const lastTraffic = appFlowingState.traffics.getLast?.();
      const downSpeed = lastTraffic?.down?.toString() ?? "0";
      const upSpeed = lastTraffic?.up?.toString() ?? "0";

      const message = `${upSpeed}/s ↑ ${downSpeed}/s ↓`;
      const proxyName = appConfig.currentProxyName ?? "ClashBox";

      hilog.info(
        0xFF00,
        "BackgroundDownService",
        `updateTraffic -> ${message}`
      );

      if (this.notificationId) {
        this.updateProcess(this.notificationId, proxyName, message, 99.9);
      }
    } catch (err) {
      hilog.error(
        0xFF00,
        "BackgroundDownService",
        `updateTraffic 异常: ${JSON.stringify(err)}`
      );
    }
  }

  /**
   * 更新系统下载通知进度条
   */
  private updateProcess(id: number, title: string, message: string, progress: number): void {
    notificationManager
      .isSupportTemplate("downloadTemplate")
      .then((supported: boolean) => {
        if (!supported) {
          hilog.error(0xFF00, "BackgroundDownService", "设备不支持下载模板通知");
          return;
        }

        const template: notificationManager.NotificationTemplate = {
          name: "downloadTemplate",
          data: {
            title: message,
            fileName: "VPN隧道数据传输中,删除通知隧道失效",
            progressValue: progress,
          },
        };

        const request: notificationManager.NotificationRequest = {
          id,
          notificationSlotType: notificationManager.SlotType.LIVE_VIEW,
          template,
          content: {
            notificationContentType:
            notificationManager.ContentType.NOTIFICATION_CONTENT_SYSTEM_LIVE_VIEW,
            systemLiveView: {
              typeCode: 8,
              title,
              text: message,
            },
          },
        };

        notificationManager
          .publish(request)
          .then(() => {
            hilog.info(0xFF00, "BackgroundDownService", `通知更新成功 id=${id}`);
          })
          .catch((err: BusinessError) => {
            hilog.error(
              0xFF00,
              "BackgroundDownService",
              `通知发布失败: ${JSON.stringify(err)}`
            );
          });
      })
      .catch((err: BusinessError) => {
        hilog.error(
          0xFF00,
          "BackgroundDownService",
          `不支持模板通知: Code=${err.code}, Msg=${err.message}`
        );
      });
  }

  /**
   * 启动 HarmonyOS 后台长时任务
   */
  private async startContinuousTask(context: Context): Promise<number> {
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
        ["dataTransfer"],
        wantAgentObj
      );
      hilog.info(
        0xFF00,
        "BackgroundDownService",
        `长时任务启动成功 notificationId=${result.notificationId}`
      );
      return result.notificationId;
    } catch (err) {
      hilog.error(
        0xFF00,
        "BackgroundDownService",
        `长时任务启动失败: Code=${err.code}, Msg=${err.message}`
      );
      return -1;
    }
  }
}

export default new BackgroundDownService();
