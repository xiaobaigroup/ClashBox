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
import { cardManager } from '../common/utils/CardManageUtil';
import { rpc } from '@kit.IPCKit';
import { ProxyActionType } from '../widget/model/FormCardConstant';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { UrlUtils } from '../common/utils/UrlUtils';
import { BundleInfo, PROXY_STARTED_DURATION_INIT_VALUE } from '../common/entity/Constants'
import { commonEventManager } from '@kit.BasicServicesKit';
import { Timer } from '../common/utils/HHmmssTimer';
import { number2Time } from '../common/utils/TimeConvertUtil';


export default class EntryAbility extends UIAbility {

  private want?: Want
  private isChangeCore = false
  // 设备断点获取
  private uiContext?: UIContext;
  private debugVpn: SocketStubService | null = null
  private onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    let widthBp: WidthBreakpoint = this.uiContext!.getWindowWidthBreakpoint();
    AppStorage.setOrCreate('currentWidthBreakpoint', widthBp);
    console.log(`断点测试 widthBp: ${widthBp}`)
  };
  /** @description ClashCore是否初始化过 */
  private clashCoreInitialized: boolean = false
  /** @description ClashCore是否初始化过 */
  private cardCoreInitialized: boolean = false
  /** @description 包名信息 */
  private bundleInfo: BundleInfo = new BundleInfo()
  private subscriber: commonEventManager.CommonEventSubscriber | null = null;
  private subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
    events: ["VpnServiceTimeEvent"]
  };
  private proxyStartedTimer = new Timer()

  // 冷启动
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    // 赋值临时储存want
    this.want = want
    // 优先级最高-初始化内核
    await ClashViewModel.ChangeCore(undefined, false)
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

    // 订阅ClashVpnAbility中的事件
    commonEventManager.createSubscriber(this.subscribeInfo, (err: BusinessError, commonEventSubscriber: commonEventManager.CommonEventSubscriber) => {
      if (!err) {
        console.info(`Succeeded in creating subscriber.`);
        this.subscriber = commonEventSubscriber;
        try {
          commonEventManager.subscribe(this.subscriber,
            (err: BusinessError, data: commonEventManager.CommonEventData) => {
              if (err) {
                console.error(`Failed to subscribe. Code is ${err.code}, message is ${err.message}`);
              } else {
                // TODO 将运行时间同步显示在 卡片
                console.info(`Succeeded in subscribing, data is ` + JSON.stringify(data));
                if (data.code === 0) {
                  // 计算时间
                  const vpnServiceStartTime = Number(data.data)
                  // 启动前先初始化卡片显示文本
                  cardManager.pushCartVpnServiceTime(PROXY_STARTED_DURATION_INIT_VALUE)
                  this.proxyStartedTimer.start((time)=>{
                    EventHub.sendEvent(EventKey.ProxyDuration, time)
                    cardManager.pushCartVpnServiceTime(number2Time(time))
                  },vpnServiceStartTime)

                  EventHub.on(EventKey.StopedClashEntry,()=>{
                    this.proxyStartedTimer.reset()
                  })
                }
              }
            });
        } catch (error) {
          let err: BusinessError = error as BusinessError;
          console.error(`Failed to subscribe. Code is ${err.code}, message is ${err.message}`);
        }
      } else {
        console.error(`Failed to create subscriber. Code is ${err.code}, message is ${err.message}`);
      }
    });

  }

  // 热启动
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    this.getShareData(want, true);
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

    const storage = new LocalStorage()
    storage.setOrCreate<BundleInfo>('bundleInfo', this.bundleInfo)

    windowStage.loadContent('pages/Index', storage, async (err) => {
      if (err.code) {
        hilog.error(0x0000, 'EntryAbility', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }

      // 初始化应用配置
      await AppState.init()

      try {
        const data = await windowStage.getMainWindow()
        // 确保UI上下文被赋值
        this.uiContext = data.getUIContext()

        // 初始化窗口避让属性
        this.intRectWindow(windowStage)

        // 设备断点获取
        let widthBp: WidthBreakpoint = this.uiContext.getWindowWidthBreakpoint()
        AppStorage.setOrCreate('currentWidthBreakpoint', widthBp)
        data.on('windowSizeChange', this.onWindowSizeChange)

        // 卡片初始化过就无须再次初始化
        if (!this.clashCoreInitialized) {
          await ClashViewModel.init(this.context, this.uiContext.getPromptAction()!)
        }

        // 卡片初始化过就无须再次初始化
        if (!this.clashCoreInitialized) {
          await this.ClashCoreInit();
        }

        // 卡片初始化过打开应用获取一次代理节点
        if (this.cardCoreInitialized) {
          ClashViewModel.loadConfig(true, '卡片初始化过打开应用获取一次代理节点')
        }

        // 获取分享的包名信息(初始)
        await this.getShareData(this.want!);

        // 通过主窗口UIContext创建typeNode节点
        PipManager.getInstance().makeTypeNode(this.uiContext)

      } catch (err) {
        console.error(`Failed to obtain the main window. Cause code: ${err.code}, message: ${err.message}`);
      }

      // 执行首次窗口检测
      // this.onWindowModeChange(windowStage, windowClass)

      // 初始化完成标记
      AppStorage.setOrCreate('awaitInit', true)
    });

    let deviceTypeInfo: string = deviceInfo.deviceType;
    if (deviceTypeInfo === '2in1') {
      AppStorage.setOrCreate('2in1', true)
    } else {
      AppStorage.setOrCreate('2in1', false)
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

  onDestroy(): void {
    hilog.info(0x0000, 'EntryAbility', '%{public}s', 'Ability onDestroy');

    this.saveConfigThePreferences()
    // 移除卡片监听事件
    this.callee.off('updateFormId');
    this.callee.off('cardChangeProxy');
    cardManager.pushCartProxyMode(false)
  }

  /** @description 存储配置文件到首选项 */
  private saveConfigThePreferences() {
    const appConfig = AppStorage.get<AppConfig>("appConfig");
    const clashConfig = AppStorage.get<ClashConfig>("clashConfig");
    appConfig && cardManager.setAppConfig(appConfig);
    clashConfig && cardManager.setClashConfig(clashConfig);
  }

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
    this.isChangeCore = true
    if (clashCore != ClashCore.mihomo) {
      let service = new SocketStubService(this.context);
      service.startService();
    }
    ClashViewModel.initProfile();
    EventHub.on(EventKey.LoadClashConfig, (isPatch: boolean) => {
      ClashViewModel.loadConfig(isPatch, 'ClashCoreInit-EventKey.LoadClashConfig');
    });
    // 监测vpn服务是否被回收，并且重新启动
    setInterval(async () => {
      if (!ClashViewModel.socketProxy.active) {
        ClashViewModel.socketProxy.active = true;
        ClashViewModel.socketProxy.offlineTime.push(Date.now());
        this.uiContext?.getPromptAction().showToast({ message: `核心恢复中(${ClashViewModel.socketProxy.offlineTime.length})...` });
        // let clashCore = AppStorage.get<AppConfig>("appConfig")?.clashCore;
        if (!this.isChangeCore) {
          let result = await ClashViewModel.ChangeCore(clashCore);
          if (result) {
            await ClashViewModel.ReStartVpn();
          }
        } else {
          this.isChangeCore = false
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
      this.cardCoreInitialized = true
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

  private intRectWindow(windowStage: window.WindowStage) {
    // 获取应用主窗口
    let windowClass: window.Window = windowStage.getMainWindowSync();
    // 设置窗口全屏
    let isLayoutFullScreen = true;
    windowClass.setWindowLayoutFullScreen(isLayoutFullScreen).then(() => {
      console.info('Succeeded in setting the window layout to full-screen mode.');
    }).catch((err: BusinessError) => {
      console.error('Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
    });

    // 缓存window窗口对象
    AppStorage.setOrCreate('WindowClass', windowClass)
    console.info('Succeeded in 保存窗口对象.');

    // 获取布局避让遮挡的区域
    let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR; // 以导航条避让为例
    let avoidArea = windowClass.getWindowAvoidArea(type);
    let bottomRectHeight = this.uiContext?.px2vp(avoidArea.bottomRect.height); // 获取到导航条区域的高度
    AppStorage.setOrCreate('bottomRectHeight', bottomRectHeight);

    type = window.AvoidAreaType.TYPE_SYSTEM; // 以状态栏避让为例
    avoidArea = windowClass.getWindowAvoidArea(type);
    let topRectHeight = this.uiContext?.px2vp(avoidArea.topRect.height); // 获取状态栏区域高度
    AppStorage.setOrCreate('topRectHeight', topRectHeight);
    hilog.info(0x0000, 'EntryAbility', '初始避让高度 Top：%{public}d Bottom: %{public}i', topRectHeight, bottomRectHeight);
    // 注册监听函数，动态获取避让区域数据
    windowClass.on('avoidAreaChange', (data) => {
      let topRectActiveHeight = 0
      let bottomRectActiveHeight = 0
      if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
        topRectActiveHeight = data.area.topRect.height;
        AppStorage.setOrCreate('topRectHeight', this.uiContext?.px2vp(topRectActiveHeight));
      } else if (data.type == window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
        bottomRectActiveHeight = this.uiContext?.px2vp(data.area.bottomRect.height)!;
        AppStorage.setOrCreate('bottomRectHeight', bottomRectActiveHeight);
      }
      hilog.info(0x0000, 'EntryAbility', '动态避让高度 Top：%{public}d Bottom: %{public}i', topRectActiveHeight, bottomRectActiveHeight);
    });

    // 应用窗口初始高度和宽度
    let properties = windowClass.getWindowProperties()
    let rect = properties.windowRect
    let WindowHeight = this.uiContext?.px2vp(rect.height)
    let WindowWidth = this.uiContext?.px2vp(rect.width)
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
        WindowWidth = this.uiContext?.px2vp(data.width)!
        WindowHeight = this.uiContext?.px2vp(data.height)!
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

}

class Params implements rpc.Parcelable {
  marshalling(dataOut: rpc.MessageSequence): boolean {
    return true
  }

  unmarshalling(dataIn: rpc.MessageSequence): boolean {
    return true
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