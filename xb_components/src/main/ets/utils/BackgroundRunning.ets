import { WantAgent, wantAgent } from "@kit.AbilityKit";
import { backgroundTaskManager } from "@kit.BackgroundTasksKit";
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * 后台任务工具（含通知栏操作）
 * 需在module.json5文件里增加相关申明
   "module": {
     "requestPermissions": [ { "name" : "ohos.permission.KEEP_BACKGROUND_RUNNING" }, ]
     "abilities": [
        "backgroundModes": [ "taskKeeping" ],
      ]
    }
  */
class BackgroundRunning {

  async start(context: Context) {
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      // 点击通知后，将要执行的动作列表
      wants: [
        {
          bundleName: context.applicationInfo.name, //"org.xbstudio.openvpn",
          abilityName: "EntryAbility"
        }
      ],
      // 点击通知后，动作类型
      actionType: wantAgent.OperationType.START_ABILITY,
      // 使用者自定义的一个私有值
      requestCode: 0,
      // 点击通知后，动作执行属性
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    try {
      // 通过wantAgent模块下getWantAgent方法获取WantAgent对象
      // 在元服务中，请使用wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: object) => {替换下面一行代码
      const wantAgentObj: WantAgent =  await wantAgent.getWantAgent(wantAgentInfo)
      try {
        backgroundTaskManager.startBackgroundRunning(context,
          backgroundTaskManager.BackgroundMode.TASK_KEEPING, wantAgentObj).then(() => {
          console.info("Operation startBackgroundRunning succeeded");
        }).catch((error: BusinessError) => {
          console.error(`Operation startBackgroundRunning failed. code is ${error.code} message is ${error.message}`);
        });
      } catch (error) {
        console.error(`Operation startBackgroundRunning failed. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
      }
    } catch (error) {
      console.error(`Operation getWantAgent failed. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
    }
  }

  stop(context: Context) {
    backgroundTaskManager.stopBackgroundRunning(context).then(() => {
      console.log(`BackgroundDownService 计算任务停止成功`)
    }).catch((err: Error) => {
      console.error(`BackgroundLocateService 计算长时任务关闭失败：${err}`)
    })
  }

}

export const Xb_BackgroundRunning = new BackgroundRunning()