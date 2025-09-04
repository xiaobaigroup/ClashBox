import { AbilityConstant, ConfigurationConstant, UIAbility, Want, WantAgent, wantAgent } from '@kit.AbilityKit';
import { hiAppEvent, hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import ClashViewModel from './ClashViewModel';
import { AppConfig, AppState, ClashCore } from './AppState';
import { EventHub, EventKey } from '../common/EventHub';
import { PipManager } from '../common/utils/PipManager';
import { ClashConfig, SocketStubService } from 'proxy_core';
import { deviceInfo } from '@kit.BasicServicesKit';
import { url } from '@kit.ArkTS';
import { Xb_StatusBarUtils } from 'xb_components';
import { cardManager } from '../common/utils/CardManageUtil';
import { rpc } from '@kit.IPCKit';
import { ProxyActionType } from '../widget/model/FormCardConstant';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { UrlUtils } from '../common/utils/UrlUtils';
import { BundleInfo } from '../common/entity/Constants'

class Params implements rpc.Parcelable {
  marshalling(dataOut: rpc.MessageSequence): boolean {
    return true
  }

  unmarshalling(dataIn: rpc.MessageSequence): boolean {
    return true
  }
}

export default class EntryAbility extends UIAbility {
  // 设备断点获取
  private uiContext?: UIContext;
  private onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    let widthBp: WidthBreakpoint = this.uiContext!.getWindowWidthBreakpoint();
    AppStorage.setOrCreate('currentWidthBreakpoint', widthBp);
    // let heightBp: HeightBreakpoint = this.uiContext!.getWindowHeightBreakpoint();
    // AppStorage.setOrCreate('currentHeightBreakpoint', heightBp);
    console.log(`断点测试 widthBp: ${widthBp}`)
  };
  /** @description ClashCore是否初始化过 */
  private clashCoreInitialized: boolean = false
  /** @description 包名信息 */
  private bundleInfo: BundleInfo = new BundleInfo()

  /** @description 注册卡片监听事件 */
  private registerCardEvent() {
    // 卡片持久化ID
    this.callee.on('updateFormId', (indata: rpc.MessageSequence) => {
      // 获取formId
      const obj = JSON.parse(indata.readString()) as object
      const formId = obj['formId'] as string
      // 持久化卡片Id
      cardManager.addCardId(formId)
      // 触发卡片更新事件
      return new Params()
    })

    // 卡片切换代理
    this.callee.on('cardChangeProxy', (indata: rpc.MessageSequence) => {
      const obj = JSON.parse(indata.readString()) as object
      const proxyActionType = obj['proxyActionType'] as ProxyActionType

      this.CardClashCoreEvent(proxyActionType)

      return null
    })

    // 刷新IP地址
    this.callee.on('refreshIPAddress', (indata: rpc.MessageSequence) => {
      refreshIPAddress();

      return null
    })
  }

  /** @description 初始化Clash核心 */
  private async ClashCoreInit() {
    const clashCore = (AppStorage.get<AppConfig>("appConfig") || cardManager.getAppConfig())?.clashCore
    await ClashViewModel.ChangeCore(clashCore);
    if (clashCore != ClashCore.mihomo) {
      let service = new SocketStubService(this.context);
      service.startService();
    }
    ClashViewModel.initProfile();
    EventHub.on(EventKey.LoadClashConfig, (isPatch: boolean) => {
      ClashViewModel.loadConfig(isPatch);
    });
    // 监测vpn服务是否被回收，并且重新启动
    setInterval(async () => {
      if (!ClashViewModel.socketProxy.active) {
        ClashViewModel.socketProxy.active = true;
        ClashViewModel.socketProxy.offlineTime.push(Date.now());
        this.uiContext?.getPromptAction().showToast({ message: `核心恢复中(${ClashViewModel.socketProxy.offlineTime.length})...` });
        let clashCore = AppStorage.get<AppConfig>("appConfig")?.clashCore;
        let result = await ClashViewModel.ChangeCore(clashCore);
        if (result) {
          await ClashViewModel.ReStartVpn();
        }
      }
    }, 1000);
    EventHub.sendEvent(EventKey.checkIpInfo);
    hilog.info(0x0000, 'EntryAbility', 'Succeeded in loading the content.');

    this.clashCoreInitialized = true
  }

  /** @description 卡片Clash核心触发事件 */
  private async CardClashCoreEvent(proxyActionType: ProxyActionType) {
    // 初始化核心
    if (!this.clashCoreInitialized) {
      await ClashViewModel.init(this.context, this.uiContext?.getPromptAction()!)
      await this.ClashCoreInit()
      const proxyNodeInfo = cardManager.getSelectedProxyNode()
      hilog.info(0x0000, 'EntryAbility', '%{public}s', JSON.stringify(proxyNodeInfo))
      if (proxyNodeInfo) {
        ClashViewModel.changeProxy(proxyNodeInfo.profile, proxyNodeInfo.g, proxyNodeInfo.p)
      }
    }

    console.log('卡片 - 启动/停止代理', proxyActionType)

    // 启动/停止代理
    if (proxyActionType === ProxyActionType.START) {
      // TODO 可能会启动失败
      ClashViewModel.StartVpn()
      setTimeout(() => {
        refreshIPAddress()
      }, 1000)
    } else {
      ClashViewModel.StopVpn()
    }
  }

  /**
   * @description 获取分享的包名信息
   * @param want want
   * @param launchMode false 热启动 true 冷启动
   * */
  private async getShareData(want: Want, launchMode: boolean = false) {
    try {
      // 获取共享数据
      const sharedData = await systemShare.getSharedData(want);
      hilog.info(0x0000, 'EntryAbility', '%{public}s', 'getSharedData success:', JSON.stringify(sharedData));

      // 处理包名
      let records: systemShare.SharedRecord[] = sharedData.getRecords();
      records.forEach(async (record: systemShare.SharedRecord) => {
        switch (record.utd) {
          // 文本类型
          case utd.UniformDataType.TEXT:
            if (record.content) {
              const bundleName = UrlUtils.extractPackageName(record.content, this.uiContext?.getPromptAction()!)
              this.bundleInfo = new BundleInfo(bundleName, record.title ?? '')
            }
            break;
          // 超链接类型
          case utd.UniformDataType.HYPERLINK:
            if (record.content) {
              const bundleName = UrlUtils.extractPackageName(record.content, this.uiContext?.getPromptAction()!)
              this.bundleInfo = new BundleInfo(bundleName, record.title ?? '')
            }
            break;
          default:
            break;
        }
      })
      if (BundleInfo.isEmpty(this.bundleInfo) && launchMode) {
        EventHub.sendEvent(EventKey.ShareBundle, this.bundleInfo)
      }
    } catch (e) {
      hilog.error(0x0000, 'EntryAbility', '%{public}s', 'getSharedData error: ', JSON.stringify(e));
    }
  }

  // 冷启动
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    // 获取分享的包名信息
    await this.getShareData(want);

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

    // 从want中获取传入的链接信息
    let uri = want?.uri
    if (uri) {
      let urlObject = url.URL.parseURL(want?.uri)
      let configUrl = urlObject.params.get('url')
      AppStorage.setOrCreate('openLinkConfigUrl', configUrl)
      hilog.info(0x0000, 'EntryAbility', '接收的configUrl为：%{public}s', configUrl)
    }
    // 卡片Id持久化管理 并 监听卡片事件
    cardManager.init(this.context)
    this.registerCardEvent()
  }

  // 热启动
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    this.getShareData(want, true);
  }

  debugVpn: SocketStubService | null = null

  /** @description 存储配置文件到首选项 */
  private saveConfigThePreferences() {
    const appConfig = AppStorage.get<AppConfig>("appConfig");
    const clashConfig = AppStorage.get<ClashConfig>("clashConfig");
    appConfig && cardManager.setAppConfig(appConfig);
    clashConfig && cardManager.setClashConfig(clashConfig);
  }

  onDestroy(): void {
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onDestroy');

    this.saveConfigThePreferences()
    // 移除卡片监听事件
    this.callee.off('updateFormId');
    this.callee.off('cardChangeProxy');
    cardManager.pushCartProxyMode(false)
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onWindowStageCreate');

    // 设置自动记忆最后关闭的窗口大小(仅2in1设备生效)
    try {
      await windowStage.setWindowRectAutoSave(true);
      hilog.info(0xFF00, "EntryAbility", 'Succeeded in setting window rect auto-save')
    } catch (exception) {
      hilog.error(0xFF00, "EntryAbility",
        'Failed to set window rect auto-save. Cause code: %{public}s smessage: %{public}s', exception.code,
        exception.message)
    }

    // 卡片初始化过就无须再次初始化
    if (!this.clashCoreInitialized) {
      await ClashViewModel.init(this.context, this.uiContext?.getPromptAction()!)
    }
    const storage = new LocalStorage()
    storage.setOrCreate<BundleInfo>('bundleInfo', this.bundleInfo)
    windowStage.loadContent('pages/Index', storage, async (err) => {
      if (err.code) {
        hilog.error(0x0000, 'EntryAbility', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      // 执行首次窗口检测
      // this.onWindowModeChange(windowStage, windowClass)
      // 初始化应用配置
      await AppState.init()

      // 卡片初始化过就无须再次初始化
      if (!this.clashCoreInitialized) {
        await this.ClashCoreInit();
        return
      }
      // 卡片初始化过打开应用获取一次代理节点
      ClashViewModel.loadConfig()
    });

    windowStage.getMainWindow().then((window: window.Window) => {
      // 通过主窗口UIContext创建typeNode节点
      let ctx = window.getUIContext();
      PipManager.getInstance().makeTypeNode(ctx)

      let deviceTypeInfo: string = deviceInfo.deviceType;
      if (deviceTypeInfo === '2in1') {
        AppStorage.setOrCreate('2in1', true)
      } else {
        AppStorage.setOrCreate('2in1', false)
      }

      // 设备断点获取
      windowStage.getMainWindow().then((data: window.Window) => {
        this.uiContext = data.getUIContext()
        let widthBp: WidthBreakpoint = this.uiContext.getWindowWidthBreakpoint()
        // let heightBp: HeightBreakpoint = this.uiContext.getWindowHeightBreakpoint()
        AppStorage.setOrCreate('currentWidthBreakpoint', widthBp)
        // AppStorage.setOrCreate('currentHeightBreakpoint', heightBp)
        // console.log(`断点测试 初始 widthBp: ${widthBp} heightBp: ${heightBp}`)
        data.on('windowSizeChange', this.onWindowSizeChange)
      }).catch((err: BusinessError) => {
        console.error(`Failed to obtain the main window. Cause code: ${err.code}, message: ${err.message}`);
      })

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
    AppStorage.setOrCreate('WindowClass', windowClass)

    // 2. 获取布局避让遮挡的区域
    let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // 以导航条避让为例
    let avoidArea = windowClass.getWindowAvoidArea(type);
    let bottomRectHeight = avoidArea.bottomRect.height; // 获取到导航条区域的高度
    AppStorage.setOrCreate('bottomRectHeight', px2vp(bottomRectHeight));

    type = window.AvoidAreaType.TYPE_SYSTEM; // 以状态栏避让为例
    avoidArea = windowClass.getWindowAvoidArea(type);
    let topRectHeight = avoidArea.topRect.height; // 获取状态栏区域高度
    AppStorage.setOrCreate('topRectHeight', px2vp(topRectHeight));
    hilog.info(0x0000, 'EntryAbility', '初始避让高度 Top：%{public}d Bottom: %{public}i', px2vp(topRectHeight),
      px2vp(bottomRectHeight));
    // 3. 注册监听函数，动态获取避让区域数据
    windowClass.on('avoidAreaChange', (data) => {
      let topRectActiveHeight = 0
      let bottomRectActiveHeight = 0
      if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
        topRectActiveHeight = data.area.topRect.height;
        AppStorage.setOrCreate('topRectHeight', px2vp(topRectActiveHeight));
      } else if (data.type == window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        bottomRectActiveHeight = data.area.bottomRect.height;
        AppStorage.setOrCreate('bottomRectHeight', px2vp(bottomRectActiveHeight));
      }
      hilog.info(0x0000, 'EntryAbility', '动态避让高度 Top：%{public}d Bottom: %{public}i', px2vp(topRectActiveHeight),
        px2vp(bottomRectActiveHeight));
    });

    // 应用窗口初始高度和宽度
    let properties = windowClass.getWindowProperties()
    let rect = properties.windowRect
    let WindowHeight = px2vp(rect.height)
    let WindowWidth = px2vp(rect.width)
    hilog.info(0x0000, 'WindowLog', '窗口高度：%{public}d px 宽度：%{public}i px', rect.height, rect.width)
    AppStorage.setOrCreate('windowHeight', WindowHeight)
    AppStorage.setOrCreate('windowWidth', WindowWidth)
    // 监听窗口大小变化
    try {
      windowClass.on('windowSizeChange', async (data) => {
        // 动态监听设备窗口模式
        this.onWindowModeChange(windowStage, windowClass)
        console.info('#WindowChange Succeeded in enabling the listener for window size changes. Data: ' +
        JSON.stringify(data))
        WindowWidth = px2vp(data.width)
        WindowHeight = px2vp(data.height)
        AppStorage.setOrCreate('windowWidth', WindowWidth)
        AppStorage.setOrCreate('windowHeight', WindowHeight) // 980px 约等于 512vp
        // 动态监听高度断点
        this.onHeightBpChange(WindowHeight, WindowWidth)
      })
    } catch (exception) {
      console.error(`#EntryAbility Failed to enable the listener for window size changes. Cause code: ${exception.code}, message: ${exception.message}`)
    }
  }

  async onWindowModeChange(windowStage: window.WindowStage, windowClass: window.Window) {
    try {
      // 设置默认标题栏是否显示
      windowClass.setWindowDecorVisible(false)
      // 设置默认标题栏功能按钮是否显示
      windowClass.setWindowTitleButtonVisible(false, false, false)
      // 全屏时鼠标移动至顶部不显示标题栏和dock栏，平板自由多窗则是无法唤起状态栏
      windowClass.setTitleAndDockHoverShown(false, false)
      // 设置标题栏高度
      // windowClass.setWindowDecorHeight(50)
      hilog.info(0xFF00, "EntryAbility", 'WindowMode 当前为PC窗口模式')
      AppStorage.setOrCreate('WindowMode', true)
    } catch (exception) {
      hilog.error(0xFF00, "EntryAbility",
        'WindowMode 当前为普通模式 Cause code: %{public}s smessage: %{public}s', exception.code, exception.message)
      AppStorage.setOrCreate('WindowMode', false)
    }
  }

  onHeightBpChange(WindowHeight: number, WindowWidth: number) {
    let heightBp = 0
    const WindowAspectRatio = WindowHeight / WindowWidth // 重写高度断点
    if (WindowAspectRatio < 0.79) {
      heightBp = 0
      AppStorage.setOrCreate('currentHeightBreakpoint', heightBp)
      console.log(`断点测试 heightBp: ${heightBp} 高宽比：${WindowAspectRatio}`)
    } else if (WindowAspectRatio >= 0.79 && WindowAspectRatio < 1.2) {
      heightBp = 1
      AppStorage.setOrCreate('currentHeightBreakpoint', heightBp)
      console.log(`断点测试 heightBp: ${heightBp} 高宽比：${WindowAspectRatio}`)
    } else if (WindowAspectRatio >= 1.2) {
      heightBp = 2
      AppStorage.setOrCreate('currentHeightBreakpoint', heightBp)
      console.log(`断点测试 heightBp: ${heightBp} 高宽比：${WindowAspectRatio}`)
    }
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    AppStorage.setOrCreate('ForewardState', true)
    hilog.info(0x0000, 'c', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    AppStorage.setOrCreate('ForewardState', false)
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onBackground');
    this.saveConfigThePreferences();
  }
}

function refreshIPAddress() {
  ClashViewModel.checkIpInfo().then((remoteIp) => {
    cardManager.pushCartProxyIpInfo(remoteIp);
    hilog.info(0x0000, 'EntryAbility', 'remoteIp - success : ' + JSON.stringify(remoteIp));
  }).catch((e: Error) => {
    hilog.info(0x0000, 'EntryAbility', 'remoteIp - error: ' + JSON.stringify(e));
  });
}

export function sleep(timeout: number): Promise<void> {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve()
    }, timeout)
  })
}