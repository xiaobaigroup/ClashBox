import { abilityAccessCtrl, Context,
  Permissions, WantAgent, wantAgent } from "@kit.AbilityKit";
import { backgroundTaskManager } from "@kit.BackgroundTasksKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { http } from "@kit.NetworkKit";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { geoLocationManager } from "@kit.LocationKit";


/**
 * 模拟定位长时任务
 */
class BackgroundLocateService {

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

export const Xb_BackgroundLocateService = new BackgroundLocateService()
