import { common } from "@kit.AbilityKit";
import { hiAppEvent } from "@kit.PerformanceAnalysisKit";

@ObservedV2
export class CrashUtils{
    context: common.UIAbilityContext | undefined
    @Trace hasCrash: boolean = false;
    nav?: NavPathStack
    init(context: common.UIAbilityContext){
      this.context = context
      hiAppEvent.addWatcher({
        name: "watcher",
        // 订阅崩溃事件
        appEventFilters: [
          {
            domain: hiAppEvent.domain.OS,
            names: [hiAppEvent.event.APP_CRASH]
          }
        ],
        onReceive: (domain: string, appEventGroups: Array<hiAppEvent.AppEventGroup>) => {
          // 先忽略空指针错误
          let signal:object = appEventGroups[0].appEventInfos[0].params['exception']["signal"]
          if(signal && signal["signo"] == 11 && (signal["address"] as string).startsWith("0x0000000000000")){
            return;
          }
          this.hasCrash = true;
          this.toCrashPage()
          AppStorage.setOrCreate('crashEvent', appEventGroups)
        }
      })
    }

  initPathStack(nav: NavPathStack){
    this.nav = nav
    this.toCrashPage()
  }
  private toCrashPage(){
      if(this.nav && this.hasCrash){
        this.nav.pushPath({name:"XbCrashPage"}, {launchMode:LaunchMode.MOVE_TO_TOP_SINGLETON})
      }
  }
}
export const crashUtils = new CrashUtils()