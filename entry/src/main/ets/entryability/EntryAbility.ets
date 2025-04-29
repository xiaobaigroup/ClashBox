import { AbilityConstant,  ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hiAppEvent, hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import ClashViewModel from './ClashViewModel';
import { AppConfig, AppFlowingState, AppState, ClashCore } from './AppState';
import { EventHub, EventKey } from '../common/EventHub';
import { PipManager } from '../common/PipManager';
import { ClashConfig, SocketProxyService, SocketStubService } from 'proxy_core';

export default class EntryAbility extends UIAbility {
 private currentLanguage: string | undefined = undefined
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onCreate');
    // 添加崩溃监听
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
        AppStorage.setOrCreate('crash', true)
        AppStorage.setOrCreate('crashEvent', appEventGroups)
      }
    })
    // 当前主题模式
    AppStorage.setOrCreate<ConfigurationConstant.ColorMode>('currentColorMode', this.context.config.colorMode)
  }
  debugVpn: SocketStubService | null = null

  onDestroy(): void {
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onDestroy');
  }
  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onWindowStageCreate');

    // 设置自动记忆最后关闭的窗口大小(仅2in1设备生效)
    try {
      let AutoSave = windowStage.setWindowRectAutoSave(true);
      AutoSave.then(() => {
        hilog.info(0xFF00, "EntryAbilityTestTag", 'Succeeded in setting window rect auto-save')
      }).catch((err: BusinessError) => {
        hilog.error(0xFF00, "EntryAbilityTestTag", 'Failed to set window rect auto-save. Cause code: %{public}s smessage: %{public}s', err.code, err.message)
      });
    } catch (exception) {
      hilog.error(0xFF00, "EntryAbilityTestTag", 'Failed to set window rect auto-save. Cause code: %{public}s smessage: %{public}s', exception.code, exception.message)
    }

    await ClashViewModel.init(this.context)
    windowStage.loadContent('pages/Index', async (err) => {
      if (err.code) {
        hilog.error(0x0000, 'EntryAbility', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      await AppState.init()
      let clashCore = AppStorage.get<AppConfig>("appConfig")?.clashCore
      // 切换核心
      promptAction.showToast({message: "核心启动中..."})
      await ClashViewModel.ChangeCore(clashCore)
      if(clashCore != ClashCore.FlClash){
        let service = new SocketStubService(this.context);
        service.startService()
      }
      ClashViewModel.initProfile()
      EventHub.on(EventKey.LoadClashConfig, (isPatch: boolean)=>{
        ClashViewModel.loadConfig(isPatch)
      })
      // 监测vpn服务是否被回收，并且重新启动
      setInterval(async ()=>{
        if(!ClashViewModel.socketProxy.active){
          ClashViewModel.socketProxy.active = true
          promptAction.showToast({message: `核心恢复中(${ClashViewModel.socketProxy.offlineTime.length})...`})
          let clashCore = AppStorage.get<AppConfig>("appConfig")?.clashCore
          await ClashViewModel.ChangeCore(clashCore)
          await ClashViewModel.ReStartVpn()
        }
      }, 1000)
      EventHub.sendEvent(EventKey.checkIpInfo)
      hilog.info(0x0000, 'EntryAbility', 'Succeeded in loading the content.');
    });

    // 通过主窗口UIContext创建typeNode节点
    windowStage.getMainWindow().then((window) => {
      let ctx = window.getUIContext();
      PipManager.getInstance().makeTypeNode(ctx)
    })

    // 获取应用主窗口
    let windowClass: window.Window = windowStage.getMainWindowSync();
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

    // 应用窗口初始高度和宽度
    let properties = windowClass.getWindowProperties()
    let rect = properties.windowRect
    let WindowHeight = rect.height
    let WindowWidth = rect.width
    hilog.info(0x0000, 'WindowLog', '窗口高度：%{public}d 宽度：%{public}i', rect.height, rect.width)
    AppStorage.setOrCreate('windowHeight', px2vp(WindowHeight))
    AppStorage.setOrCreate('windowWidth', px2vp(WindowWidth))
    // 监听窗口大小变化
    try {
      windowClass.on('windowSizeChange', (data) => {
        console.info('#WindowChange Succeeded in enabling the listener for window size changes. Data: ' + JSON.stringify(data))
        AppStorage.setOrCreate('windowHeight', px2vp(data.height)) // 980px 约等于 512vp
        AppStorage.setOrCreate('windowWidth', px2vp(data.width))
      })
    } catch (exception) {
      console.error(`#EntryAbility Failed to enable the listener for window size changes. Cause code: ${exception.code}, message: ${exception.message}`)
    }
  }

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

export function sleep(timeout: number): Promise<void>{
  return new Promise((resolve, reject)=>{
      setTimeout(()=>{
        resolve()
      }, timeout)
  })
}