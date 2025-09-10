import { abilityAccessCtrl, Context,
  PermissionRequestResult,
  Permissions, WantAgent, wantAgent } from "@kit.AbilityKit";
import { backgroundTaskManager } from "@kit.BackgroundTasksKit";
import { notificationManager } from "@kit.NotificationKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { http } from "@kit.NetworkKit";
import { AppFlowingState, AppState } from "../../entryability/AppState";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { geoLocationManager } from "@kit.LocationKit";


/**
 * 模拟定位长时任务
 */
export class BackgroundLocateService {
  client = http.createHttp()
  notificationId ?: number = undefined

  async start(context: Context) {
    if (this.notificationId)
      return
    let id = await this.startContinuousTask(context)
    this.notificationId = id
    // 启动后台定位
    this.getLocation(context)
  }

  async requestPermissionsFromUser(context: Context): Promise<boolean> {
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    let permissionList: Permissions[] = [
      'ohos.permission.INTERNET',
      'ohos.permission.LOCATION',
      'ohos.permission.APPROXIMATELY_LOCATION'
    ];
    try {
      await atManager.requestPermissionsFromUser(context, permissionList)
      return true
    } catch (e) {
      return false
    }

  }

  async getLocation(context: Context) {
    await this.requestPermissionsFromUser(context)
    let request: geoLocationManager.LocationRequest = {
      priority: geoLocationManager.LocationRequestPriority.LOW_POWER, // Quick location acquisition is preferred
      timeInterval: 7200, // Interval for reporting the location information
      distanceInterval: 10000, // Distance for reporting location information
      maxAccuracy: 1000 // The precision value required when the application requests location information from the system
    };
    geoLocationManager.on('locationChange', request, ()=>{ });
  }

  stop(context: Context){
    this.notificationId = undefined
    backgroundTaskManager.stopBackgroundRunning(context).then(() => {
      console.log(`BackgroundDownService 模拟定位停止成功`)
    }).catch((err: Error) => {
      console.error(`BackgroundLocateService 后台定位长时任务关闭失败：${err}`)
    })
  }

  // 不可用
  updateProcess(id: number, message: string) {
    // 副文本赋值
    const appFlowingState: AppFlowingState = AppStorage.get<AppFlowingState>("appFlowingState") ?? new AppFlowingState()
    const now = appFlowingState.traffics.getLast()?.down?.toString()
    const result = appFlowingState.traffics.getLast()?.up?.toString()
    const newContent = `${result} ↑\t${now} ↓`
    notificationManager.isSupportTemplate('downloadTemplate').then((data:boolean) => {
      hilog.info(0xFF00, 'BackgroundLocateService', '当前设备支持下载进度条模板')

      const downLoadTemplate: notificationManager.NotificationTemplate = {
        name: 'downloadTemplate', // 当前只支持downloadTemplate，保持不变
        data: {
          title: newContent, // 必填。
          fileName: message, // 必填。
          progressValue: (Math.random() * 100), // 应用更新进度值，自定义
        }
      }

      const request: notificationManager.NotificationRequest = {
        content: {
          // 系统实况类型，保持不变
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_SYSTEM_LIVE_VIEW,
          systemLiveView: {
            typeCode: 8, // 上传下载类型需要填写 8，当前仅支持此类型。保持不变
            title: "clash", // 应用自定义
            text: "clash", // 应用自定义
          },
        },
        id: id, // 必须是申请长时任务返回的id，否则应用更新通知失败。
        notificationSlotType: notificationManager.SlotType.LIVE_VIEW, // 实况窗类型，保持不变
        template: downLoadTemplate,
      }
      // 发布通知
      try {
        notificationManager.publish(request).then(() => {
          hilog.info(0xFF00, 'BackgroundLocateService', "publish success, id = %{public}d", id)
        }).catch((err: BusinessError) => {
          hilog.error(0xFF00, 'BackgroundLocateService', `publish fail: ${JSON.stringify(err)}`)
        })
      } catch (err) {
        hilog.error(0xFF00, 'BackgroundLocateService', `publish fail: ${JSON.stringify(err)}`)
      }

    }).catch((err: BusinessError) => {
      hilog.error(0xFF00, 'BackgroundLocateService', `当前设备不支持下载进度条模板 Code is ${err.code}, message is ${err.message}`)
    })
  }

  async startContinuousTask(context: Context): Promise<number>{
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      // 点击通知后，将要执行的动作列表
      // 添加需要被拉起应用的bundleName和abilityName
      wants: [
        {
          bundleName: context.applicationInfo.name, // release: org.xbgroup.clashbox, debug: org.xbgroup.clashboxb
          abilityName: "EntryAbility"
        }
      ],
      // 指定点击通知栏消息后的动作是拉起ability
      actionType: wantAgent.OperationType.START_ABILITY,
      // 使用者自定义的一个私有值
      requestCode: 0,
      // 点击通知后，动作执行属性
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    }
    // 通过wantAgent模块下getWantAgent方法获取WantAgent对象
    try {
      let wantAgentObj: WantAgent =  await wantAgent.getWantAgent(wantAgentInfo)
      let res = await backgroundTaskManager.startBackgroundRunning(context, ["location"], wantAgentObj)
      return res.notificationId
    } catch (err) {
      hilog.error(0xFF00, 'BackgroundLocateService', `Failed to operation startBackgroundRunning. Code is ${err.code}, message is ${err.message}`)
      return -1
    }
  }

}

export default  new BackgroundLocateService()