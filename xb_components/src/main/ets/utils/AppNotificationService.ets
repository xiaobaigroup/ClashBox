import { abilityAccessCtrl, common, Context, Permissions, WantAgent, wantAgent } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

// 通知内容类型
interface TextNotificationContent {
  title: string;
  text: string;
  additionalText?: string;
};

interface ProgressNotificationContent {
  title: string;
  fileName: string;
  progressValue: number;
};

// WantAgent参数类型
export interface  WantAgentParams {
  abilityName: string;
  parameters?: Record<string, Object>;
};

/**
 * 通用通知工具类 TODO 通知意图无法成功启用
 */
export class Xb_NotificationUtils {
  private static readonly TAG: string = 'Xb_NotificationUtils';

  /**
   * 检查通知权限状态
   * @param context 应用上下文
   * @returns 权限是否已授予
   */
  static async checkNotificationPermission(context?: common.UIAbilityContext): Promise<boolean> {
    try {
      const result = await notificationManager.isNotificationEnabled()
      return result
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0xFF00, Xb_NotificationUtils.TAG, `权限检查失败: code = ${err.code}, message = ${err.message}`);
      return false;
    }
  }


  /**
   * 请求通知权限
   * @param context 应用上下文
   * @returns 获得权限情况 1为有权限， 0为用户拒绝授权，-1为无权限
   */
  static async requestNotificationPermission(context: common.UIAbilityContext): Promise<number> {
    try {
      // 先检查是否已有权限
      if (await Xb_NotificationUtils.checkNotificationPermission(context)) {
        return 1
      }
      // 请求通知权限
      try {
        await notificationManager.requestEnableNotification(context)
        return 1
      } catch (err) {
        if ((err as BusinessError).code === 1600004) {
          hilog.error(0xFF00, "Xb_NotificationUtils.requestNotificationPermission",'用户拒绝授权')
          return 0
        }
        return -1
      }
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0xFF00, Xb_NotificationUtils.TAG, `权限请求失败: code = ${err.code}, message = ${err.message}`);
      return -1
    }
  }

  /**
   * 创建WantAgent
   * @param context 应用上下文
   * @param params WantAgent参数
   * @returns Promise<WantAgent> WantAgent对象
   */
  private static async createWantAgent(
    context: Context,
    params: WantAgentParams
  ): Promise<WantAgent> {
    try {
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [{
          bundleName: context.applicationInfo.name,
          abilityName: params.abilityName,
          parameters: params.parameters || undefined
        }],
        // 指定点击通知栏消息后的动作是拉起ability
        actionType: wantAgent.OperationType.START_ABILITY,
        requestCode: 0,
        // 点击通知后，动作执行属性
        actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      };
      return await wantAgent.getWantAgent(wantAgentInfo);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0xFF00, Xb_NotificationUtils.TAG, `创建WantAgent失败: code = ${err.code}, message = ${err.message}`);
      throw err as Error;
    }
  }

  /**
   * 发布文本通知
   * @param context 应用上下文
   * @param id 通知ID
   * @param content 通知内容
   * @param wantParams WantAgent参数（可选）
   */
  static async publishTextNotification(
    context: common.UIAbilityContext,
    id: number,
    content: TextNotificationContent,
    slotType?: notificationManager.SlotType,
    wantParams?: WantAgentParams
  ): Promise<void> {
    try {
      const enabled = await Xb_NotificationUtils.requestNotificationPermission(context)
      if (enabled !== 1 ) {
        throw new Error(`无通知权限: ${enabled}`);
      }

      let wantAgentObj: WantAgent | undefined;

      if (wantParams) {
        wantAgentObj = await Xb_NotificationUtils.createWantAgent(context, wantParams);
      }

      const request: notificationManager.NotificationRequest = {
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: content.title,
            text: content.text,
            additionalText: content.additionalText || ''
          }
        },
        id: id,
        // 通知消息的WantAgent
        wantAgent: wantAgentObj,
        notificationSlotType: slotType
      };

      await notificationManager.publish(request);
      hilog.info(0xFF00, Xb_NotificationUtils.TAG, `文本通知发布成功 ID: ${id}`);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0xFF00, Xb_NotificationUtils.TAG, `文本通知发布失败: code = ${err.code}, message = ${err.message}`);
    }
  }

  /**
   * 发布进度通知
   * @param context 应用上下文
   * @param id 通知ID
   * @param content 进度内容
   * @param wantParams WantAgent参数（可选）
   */
  static async publishProgressNotification(
    context: common.UIAbilityContext,
    id: number,
    content: ProgressNotificationContent,
    slotType?: notificationManager.SlotType,
    wantParams?: WantAgentParams
  ): Promise<void> {
    try {
      const enabled = await Xb_NotificationUtils.requestNotificationPermission(context)
      if (enabled !== 1 ) {
        throw new Error(`无通知权限: ${enabled}`);
      }
      // 检查设备是否支持进度模板
      const isSupported = await notificationManager.isSupportTemplate('downloadTemplate');
      if (!isSupported) {
        hilog.warn(0xFF00, Xb_NotificationUtils.TAG, '设备不支持进度条模板，使用文本通知替代');
        await Xb_NotificationUtils.publishTextNotification(context, id, {
          title: content.title,
          text: `${content.fileName} (${content.progressValue}%)`
        }, undefined, wantParams);
        return;
      }

      let wantAgentObj: WantAgent | undefined;
      if (wantParams) {
        wantAgentObj = await Xb_NotificationUtils.createWantAgent(context, wantParams);
      }

      const template: notificationManager.NotificationTemplate = {
        name: 'downloadTemplate',
        data: {
          title: content.title,
          fileName: content.fileName,
          progressValue: Math.min(100, Math.max(0, content.progressValue))
        }
      };

      const request: notificationManager.NotificationRequest = {
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_SYSTEM_LIVE_VIEW,
          systemLiveView: {
            typeCode: 8,  // 上传下载类型
            title: content.title,
            text: content.fileName
          }
        },
        id: id,
        // 通知消息的WantAgent
        wantAgent: wantAgentObj,
        notificationSlotType: slotType,
        template: template
      };

      await notificationManager.publish(request);
      hilog.info(0xFF00, Xb_NotificationUtils.TAG, `进度通知发布成功 ID: ${id}`);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0xFF00, Xb_NotificationUtils.TAG, `进度通知发布失败: code = ${err.code}, message = ${err.message}`);
    }
  }

  /**
   * 更新文本通知
   * @param id 通知ID
   * @param newContent 新内容
   */
  static async updateTextNotification(
    id: number,
    newContent: TextNotificationContent,
    slotType?: notificationManager.SlotType,
  ): Promise<void> {
    try {
      // 创建更新请求
      const updateRequest: notificationManager.NotificationRequest = {
        id: id,
        updateOnly: false,
        isAlertOnce: true,
        tapDismissed: false,
        notificationSlotType: slotType,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: newContent.title,
            text: newContent.text,
            additionalText: newContent.additionalText || ''
          }
        }
      };

      await notificationManager.publish(updateRequest);
      hilog.info(0xFF00, Xb_NotificationUtils.TAG, `文本通知更新成功 ID: ${id}`);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0xFF00, Xb_NotificationUtils.TAG, `通知更新失败: code = ${err.code}, message = ${err.message}`);
    }
  }

  /**
   * 更新进度通知
   * @param id 通知ID
   * @param newContent 新进度内容
   */
  static async updateProgressNotification(
    id: number,
    newContent: ProgressNotificationContent,
    slotType?: notificationManager.SlotType
  ): Promise<void> {
    try {
      // 检查模板支持
      const isSupported = await notificationManager.isSupportTemplate('downloadTemplate');
      if (!isSupported) {
        throw new Error('设备不支持进度模板');
      }

      // 创建更新请求
      const updateRequest: notificationManager.NotificationRequest = {
        id: id,
        updateOnly: false,
        isAlertOnce: true,
        tapDismissed: false,
        notificationSlotType: slotType,
        template: {
          name: 'downloadTemplate',
          data: {
            title: newContent.title,
            fileName: newContent.fileName,
            progressValue: Math.min(100, Math.max(0, newContent.progressValue))
          }
        },
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_SYSTEM_LIVE_VIEW,
          systemLiveView: {
            typeCode: 8,  // 上传下载类型
            title: newContent.title,
            text: newContent.fileName
          }
        },
      };

      await notificationManager.publish(updateRequest);
      hilog.info(0xFF00, Xb_NotificationUtils.TAG, `进度通知更新成功 ID: ${id}`);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0xFF00, Xb_NotificationUtils.TAG, `进度更新失败: code = ${err.code}, message = ${err.message}`);
    }
  }

  /**
   * 取消通知
   * @param id 通知ID
   */
  static async cancelNotification(id: number): Promise<void> {
    try {
      await notificationManager.cancel(id);
      hilog.info(0xFF00, Xb_NotificationUtils.TAG, `通知已取消 ID: ${id}`);
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0xFF00, Xb_NotificationUtils.TAG, `取消通知失败: code = ${err.code}, message = ${err.message}`);
    }
  }

  /**
   * 取消所有通知
   */
  static async cancelAllNotifications(): Promise<void> {
    try {
      await notificationManager.cancelAll();
      hilog.info(0xFF00, Xb_NotificationUtils.TAG, '所有通知已取消');
    } catch (error) {
      const err = error as BusinessError;
      hilog.error(0xFF00, Xb_NotificationUtils.TAG, `取消所有通知失败: code = ${err.code}, message = ${err.message}`);
    }
  }
}


/*
// 发布文本通知
Xb_NotificationUtils.publishTextNotification(
  context,
  1001,
  {
    title: '系统通知',
    text: '您有一条新消息',
    additionalText: '点击查看'
  },
  {
    abilityName: 'EntryAbility',
    parameters: { messageId: 12345 }
  }
);

// 发布进度通知
Xb_NotificationUtils.publishProgressNotification(
  context,
  2001,
  {
    title: '文件下载',
    fileName: 'document.pdf',
    progressValue: 0
  },
  {
    abilityName: 'DownloadManagerAbility'
  }
);

// 更新进度
Xb_NotificationUtils.updateProgressNotification(2001, {
  title: '文件下载',
  fileName: 'document.pdf',
  progressValue: 75
});

// 取消通知
Xb_NotificationUtils.cancelNotification(1001);*/
