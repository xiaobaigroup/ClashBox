import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import ClashViewModel from './ClashViewModel';
import { KeyboardAvoidMode } from '@kit.ArkUI';
import { AppConfig, AppFlowingState, AppState, ClashCore } from './AppState';

export default class EntryAbility extends UIAbility {
 private currentLanguage: string | undefined = undefined
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onCreate');

/*    this.currentLanguage = this.context.config.language
    AppStorage.setOrCreate<string>('language', this.currentLanguage)
    hilog.info(0x0000, 'EntryAbility', `#onCreate#currentLanguage is [${this.currentLanguage}]`);*/
    // 当前主题模式
    AppStorage.setOrCreate<ConfigurationConstant.ColorMode>('currentColorMode', this.context.config.colorMode)
  }


  onDestroy(): void {
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onWindowStageCreate');
    let windowClass: window.Window = windowStage.getMainWindowSync(); // 获取应用主窗口

    await ClashViewModel.init(this.context)
    windowStage.loadContent('pages/Index', async (err) => {
      if (err.code) {
        hilog.error(0x0000, 'EntryAbility', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      AppState.init()
      let appConfig = AppStorage.get<AppConfig>("appConfig")?.clashCore
      let appFlowingState = AppStorage.get<AppFlowingState>("appFlowingState") ?? new AppFlowingState()
      // 切换核心
      promptAction.showToast({message: "核心启动中..."})
      await ClashViewModel.ChangeCore(appConfig)
      appFlowingState.removeIp = await ClashViewModel.checkIpInfo()
      await sleep(300)
      ClashViewModel.initProfile()
      setInterval(async ()=>{
          let now = await ClashViewModel.getTraffic()
          let total = await ClashViewModel.getTotalTraffic()
          appFlowingState.traffics.enqueue(now)
          appFlowingState.totalTraffic = total
      },1000)

      hilog.info(0x0000, 'EntryAbility', 'Succeeded in loading the content.');
    });

    // 1. 设置窗口全屏
    let isLayoutFullScreen = true;
    windowClass.setWindowLayoutFullScreen(isLayoutFullScreen).then(() => {
      console.info('Succeeded in setting the window layout to full-screen mode.');
    }).catch((err: BusinessError) => {
      console.error('Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
    });

    // 缓存window窗口对象
    AppStorage.setOrCreate('windowClass', windowClass);

    // 2. 获取布局避让遮挡的区域
    let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // 以导航条避让为例
    let avoidArea = windowClass.getWindowAvoidArea(type);
    let bottomRectHeight = avoidArea.bottomRect.height; // 获取到导航条区域的高度
    AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight);

    type = window.AvoidAreaType.TYPE_SYSTEM; // 以状态栏避让为例
    avoidArea = windowClass.getWindowAvoidArea(type);
    let topRectHeight = avoidArea.topRect.height; // 获取状态栏区域高度
    AppStorage.setOrCreate('topRectHeight', topRectHeight);

    // 3. 注册监听函数，动态获取避让区域数据
    windowClass.on('avoidAreaChange', (data) => {
      if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
        let topRectHeight = data.area.topRect.height;
        AppStorage.setOrCreate('topRectHeight', topRectHeight);
      } else if (data.type == window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        let bottomRectHeight = data.area.bottomRect.height;
        AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight);
      }
    });
  }

  /*onConfigurationUpdate(newConfig: Configuration): void {
    if (newConfig.language !== this.currentLanguage) {
      this.currentLanguage = newConfig.language
      hilog.info(0x0000, 'EntryAbility', `#onConfigurationUpdate#newConfig.language is [${this.currentLanguage}]`);
      AppStorage.setOrCreate<string>('language', newConfig.language)
    }

  }*/

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onBackground');
  }
}

function sleep(timeout: number): Promise<void>{
  return new Promise((resolve, reject)=>{
      setTimeout(()=>{
        resolve()
      }, timeout)
  })
}