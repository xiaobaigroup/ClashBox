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
export class BackgroundLocateService{
  client = http.createHttp()
  notificationId ?: number = undefined
  ping: number = 0
  notice:number = 0


  async start(context: Context){
    if(this.notificationId)
      return
    let id = await this.startContinuousTask(context)
    this.notificationId = id
    // 启动后台定位
    this.getLocation(context)

    clearInterval(this.notice)
    // 定位需要另一种通知
    // this.updateTraffic()
    // this.notice = setInterval(async ()=> {
    //   this.updateTraffic()
    // }, 2000)
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
      priority: geoLocationManager.LocationRequestPriority.FIRST_FIX, // Quick location acquisition is preferred
      scenario: geoLocationManager.LocationRequestScenario.UNSET, // Indicates that no scenario information is set
      timeInterval: 10, // Interval for reporting the location information
      distanceInterval: 0, // Distance for reporting location information
      maxAccuracy: 100 // The precision value required when the application requests location information from the system
    };
    geoLocationManager.on('locationChange', request, ()=>{ });
  }



  async updateTraffic(): Promise<void>{

    let appFlowingState: AppFlowingState = AppStorage.get<AppFlowingState>("appFlowingState") ?? new AppFlowingState()
    let now = appFlowingState.traffics.getLast()?.down?.toString()
    let result = appFlowingState.traffics.getLast()?.up?.toString()
    let message = `${result} ↑\t${now} ↓`
    hilog.info(0xFF00, 'BackgroundLocateService', "updateProcess %{public}s", message)
    this.updateProcess(this.notificationId ?? 0, message )
  }

  stop(context: Context){
    this.notificationId = undefined
    clearInterval(this.ping)
    clearInterval(this.notice)
    backgroundTaskManager.stopBackgroundRunning(context)
  }

  updateProcess(id: number, message: string){
    notificationManager.isSupportTemplate('downloadTemplate').then((data:boolean) => {
      hilog.info(0xFF00, 'BackgroundLocateService', '当前设备支持下载进度条模板')
      let downLoadTemplate: notificationManager.NotificationTemplate = {
        name: 'downloadTemplate', // 当前只支持downloadTemplate，保持不变
        data: {
          title: getContext().resourceManager.getStringSync($r('app.string.runing_download_background')), // 必填。
          fileName: message, // 必填。
          progressValue: (Math.random() * 100), // 应用更新进度值，自定义
        }
      }

      let request: notificationManager.NotificationRequest = {
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
      let res = await backgroundTaskManager.startBackgroundRunning(getContext(this), ["location"], wantAgentObj)
      return res.notificationId
    } catch (err) {
      hilog.error(0xFF00, 'BackgroundLocateService', `Failed to operation startBackgroundRunning. Code is ${err.code}, message is ${err.message}`)
      return -1
    }
  }
}

export default  new BackgroundLocateService()