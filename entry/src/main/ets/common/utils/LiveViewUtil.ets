
import { liveViewManager } from '@kit.LiveViewKit';
import { Want, wantAgent } from '@kit.AbilityKit';
import { Xb_GetResourceString } from 'xb_components';
import { AppConfig } from '../../entryability/AppState';
import { BusinessError } from '@kit.BasicServicesKit';

class LiveViewUtil {

  private static context: Context;
  liveID: number = 0

  public async init(context: Context): Promise<boolean> {
    LiveViewUtil.context = context
    return true
  }

  public async startLiveView(): Promise<liveViewManager.LiveViewResult> {
    // 校验实况窗开关是否打开
    if (!await LiveViewUtil.isLiveViewEnabled()) {
      throw new Error("LiveViewUtil Live view is disabled.");
    }
    this.liveID = setInterval(async () => {
      this.updateLiveView()
    }, 1000)
    // 创建实况窗
    const defaultView = await this.buildDefaultView();
    try {
      return await liveViewManager.startLiveView(defaultView);
    } catch (error) {
      throw new Error(error);
    }
  }

  private async updateLiveView(): Promise<liveViewManager.LiveViewResult> {
    // 校验实况窗开关是否打开
    if (!await LiveViewUtil.isLiveViewEnabled()) {
      throw new Error("LiveViewUtil Live view is disabled.");
    }
    const appConfig: AppConfig = AppStorage.get<AppConfig>("appConfig") ?? new AppConfig()
    const themeColor = AppStorage.get<string>("ThemeColor") ?? "#E61E4377"
    const proxyStartingDuration = AppStorage.get<string>('proxyStartingDuration') ?? '0:0:0'
    // 实况窗内容
    const defaultView = await this.buildDefaultView();
    defaultView.liveViewData.primary.title = appConfig.currentProxyName;
    // 实况窗
    defaultView.liveViewData.primary.content = [
      { text: Xb_GetResourceString($r('app.string.px_sec_screen_use_time'), LiveViewUtil.context) },
      { text: `: ${proxyStartingDuration}`, textColor: themeColor }, // 运行时间
    ];
    defaultView.liveViewData.primary.layoutData = {
      layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PROGRESS,
      progress: 0,
      lineType: 0,
    };
    // 实况胶囊
    defaultView.liveViewData.capsule = {
      type: liveViewManager.CapsuleType.CAPSULE_TYPE_TEXT,
      status: 1,
      icon: 'foreground_box_cat_large.png', // 实况胶囊的图标，取值为“/resources/rawfile”路径下的文件名或image.PixelMap
      backgroundColor: themeColor,
      title: proxyStartingDuration
    };
    // 更新实况窗
    return await liveViewManager.updateLiveView(defaultView);
  }

  public async stopLiveView(): Promise<liveViewManager.LiveViewResult> {
    // 校验实况窗开关是否打开
    if (!await LiveViewUtil.isLiveViewEnabled()) {
      throw new Error("LiveViewUtil Live view is disabled.");
    }
    // 实况窗内容
    const defaultView = await this.buildDefaultView();
    defaultView.liveViewData.primary.content = [
      { text: 'ClashBox' },
    ];
    defaultView.id = this.liveID
    clearInterval(this.liveID)
    this.liveID = 0
    // 结束实况窗
    try {
      return await liveViewManager.stopLiveView(defaultView);
    } catch (error) {
      throw new Error(error);
    }
  }

  private async buildDefaultView(): Promise<liveViewManager.LiveView> {
    const appConfig: AppConfig = AppStorage.get<AppConfig>("appConfig") ?? new AppConfig()
    const themeColor = AppStorage.get<string>("ThemeColor") ?? "#E61E4377"
    const proxyStartingDuration = AppStorage.get<string>('proxyStartingDuration') ?? '0:0:0'
    return {
      // 构造实况窗请求体
      id: this.liveID, // 实况窗ID，开发者生成
      event: "QUEUE", // 实况窗的应用场景。QUEUE：排队
      timer: {
        time: 620000,
        isCountdown: false,
        isPaused: false
      },
      liveViewData: {
        primary: {
          title: appConfig.currentProxyName,  // 节点名
          content: [
            { text: Xb_GetResourceString($r('app.string.px_sec_screen_use_time'), LiveViewUtil.context) },
            { text: `${proxyStartingDuration}`, textColor: themeColor }, // 运行时间
          ], // 设置textColor字段时，所有拥有textColor字段的对象仅能设置同一种颜色，不设置textColor时，默认展示#FF000000
          keepTime: 15,
          clickAction: await LiveViewUtil.buildWantAgent(),
          layoutData: {
            layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_PROGRESS,
            progress: 0,
            color: "#FFFF0000",
            backgroundColor: "#FF000000",
            indicatorType: liveViewManager.IndicatorType.INDICATOR_TYPE_OVERLAY,
            indicatorIcon: "indicator.png", // 进度条指示器图标，取值为“/resources/rawfile”路径下的文件名或image.PixelMap
            lineType: liveViewManager.LineType.LINE_TYPE_DOTTED_LINE,
            nodeIcons: ["icon_1.png","icon_2.png"] // 进度条节点图标集合，每个元素取值为“/resources/rawfile”路径下的文件名或image.PixelMap
          }
        }
      }
    };
  }

  private static async isLiveViewEnabled(): Promise<boolean> {
    return await liveViewManager.isLiveViewEnabled();
  }

  private static async buildWantAgent(): Promise<Want> {
    const wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: LiveViewUtil.context.applicationInfo.name, // 应用实际bundleName
          abilityName: 'EntryAbility'
        } as Want
      ],
      actionType: wantAgent.OperationType.START_ABILITIES,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    const agent = await wantAgent.getWantAgent(wantAgentInfo);
    return agent;
  }

}

export default new LiveViewUtil()