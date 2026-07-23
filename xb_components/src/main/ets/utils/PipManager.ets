
// 画中画控制器单例
import { BuilderNode, NodeController, PiPWindow, typeNode } from '@kit.ArkUI'; // 引入PiPWindow模块
import { BusinessError } from '@kit.BasicServicesKit';
import { AVPlayer} from './SimpleAVPlayer'

class Params {
  text1: string = ""
  text2: string = ""
  text2Color: ResourceColor = ''
}

@Builder
function PipBackgroundBuilder(params: Params) {
  Row() {
    Stack() {
      Text() {
        Span(params.text1)
        Span(params.text2)
          .fontColor(params.text2Color)
      }
        .fontWeight(FontWeight.Bold)
        .fontSize(52)
        .zIndex(2)
        .fontColor($r('sys.color.font_primary'))
      Image($r('app.media.xb_pip_background'))
        .width('100%')
    }
  }.width('100%').height('100%')
  .backgroundColor($r('app.color.pip_background'))
  .justifyContent(FlexAlign.Center)
  .alignItems(VerticalAlign.Center)
}

// 自定义节点
class PipBackgroundNodeController extends NodeController {
  private pipBackgroundNode: BuilderNode<[Params]> | null = null;
  private wrapBuilder: WrappedBuilder<[Params]> = wrapBuilder(PipBackgroundBuilder);
  private currentParams: Params = new Params()

  // 设置参数
  setParams(params: Params): void {
    this.currentParams.text1 = params.text1
    this.currentParams.text2 = params.text2
    this.currentParams.text2Color = params.text2Color
    if (this.pipBackgroundNode) {
      this.pipBackgroundNode.build(this.wrapBuilder, this.currentParams);
    }
  }
  makeNode(uiContext: UIContext): FrameNode {
    if (this.pipBackgroundNode == null) {
      this.pipBackgroundNode = new BuilderNode(uiContext);
      this.pipBackgroundNode.build(this.wrapBuilder, this.currentParams);
    }
    return this.pipBackgroundNode!.getFrameNode()!;
  }
}

// 自定义XComponentController
class CustomXComponentController extends XComponentController {

  constructor() {
    super()
  }
  // 监听onSurfaceCreated，并将surfaceId设置给播放器

  override onSurfaceCreated(surfaceId: string): void {
    console.log(TAG, `onSurfaceCreated surfaceId: ${surfaceId}`);
    Xb_PipManager.getInstance().onSurfaceId?.(parseInt(surfaceId))
  }

  override onSurfaceDestroyed(surfaceId: string): void {
    console.log(TAG, `onSurfaceDestroyed surfaceId: ${surfaceId}`);
    Xb_PipManager.getInstance().onSurfaceId?.(-1)
  }
}

const TAG = 'Xb_PipManager';

export class Xb_PipManager {
  player: AVPlayer;
  private static instance: Xb_PipManager = new Xb_PipManager();
  private pipController?: PiPWindow.PiPController = undefined;
  private mXComponentController: XComponentController;
  /** @description typeNode节点 */
  private xComponent: typeNode.XComponent | null = null;
  private nodeController: PipBackgroundNodeController | null = null;
  currentParams: Params = new Params();
  onSurfaceId: ((id: number)=> void) | undefined = undefined

  public static getInstance(): Xb_PipManager {
    return Xb_PipManager.instance;
  }

  constructor() {
    this.player = new AVPlayer();
    this.mXComponentController = new CustomXComponentController();
  }

  // 设置显示的参数
  setDisplayText(params: Params): void {
    this.currentParams.text1 = params.text1
    this.currentParams.text2 = params.text2
    this.currentParams.text2Color = params.text2Color
    if (this.nodeController) {
      this.nodeController.setParams(params);
    }
  }

  onActionEvent(control: PiPWindow.ControlEventParam) {
    switch (control.controlType) {
      case PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE:
        if (control.status === PiPWindow.PiPControlStatus.PAUSE) {
          //停止视频
        } else if (control.status === PiPWindow.PiPControlStatus.PLAY) {
          //播放视频
        }
        break;
      case PiPWindow.PiPControlType.VIDEO_NEXT:
        // 切换到下一个视频
        break;
      case PiPWindow.PiPControlType.VIDEO_PREVIOUS:
        // 切换到上一个视频
        break;
      case PiPWindow.PiPControlType.FAST_FORWARD:
        // 视频进度快进
        break;
      case PiPWindow.PiPControlType.FAST_BACKWARD:
        // 视频进度后退
        break;
      default:
        break;
    }
    console.info('onActionEvent, controlType:' + control.controlType + ', status' + control.status);
  }

  // 监听画中画生命周期
  onStateChange(state: PiPWindow.PiPState, reason: string) {
    let curState: string = '';
    switch (state) {
      case PiPWindow.PiPState.ABOUT_TO_START:
        curState = "ABOUT_TO_START";
        break;
      case PiPWindow.PiPState.STARTED:
        curState = "STARTED";
        break;
      case PiPWindow.PiPState.ABOUT_TO_STOP:
        curState = "ABOUT_TO_STOP";
        break;
      case PiPWindow.PiPState.STOPPED:
        curState = "STOPPED";
        break;
      case PiPWindow.PiPState.ABOUT_TO_RESTORE:
        curState = "ABOUT_TO_RESTORE";
        break;
      case PiPWindow.PiPState.ERROR:
        curState = "ERROR";
        break;
      default:
        break;
    }
    console.info(`[${TAG}] onStateChange: ${curState}, reason: ${reason}`);
  }

  // 解注册监听
  unregisterPipStateChangeListener() {
    console.info(TAG, 'aboutToDisappear');
    this.pipController?.off('stateChange');
    this.pipController?.off('controlEvent');
  }

  getXComponentController(): XComponentController {
    return this.mXComponentController;
  }

  // 创建画中画控制器，注册生命周期事件以及控制事件回调
  async init(ctx: UIContext, initialParams: Params, onSurfaceId: ((id: number)=> void) | undefined = undefined) {
    if (this.pipController !== null && this.pipController != undefined) {
      console.info(TAG, `PipManager.init pipController不存在`);
      return;
    }
    this.onSurfaceId = onSurfaceId
    this.currentParams.text1 = initialParams.text1
    this.currentParams.text2 = initialParams.text2
    this.currentParams.text2Color = initialParams.text2Color
    console.info(TAG, 'onPageShow');
    if (!PiPWindow.isPiPEnabled()) {
      console.error(TAG, `picture in picture disabled for current OS`);
      return;
    }

    this.nodeController = new PipBackgroundNodeController();
    this.nodeController.setParams(this.currentParams);

    let config: PiPWindow.PiPConfiguration = {
      context: ctx.getHostContext()!,
      componentController: this.mXComponentController,
      templateType: PiPWindow.PiPTemplateType.VIDEO_PLAY,
      contentWidth: 160, // 使用typeNode启动画中画时，contentWidth需设置为大于0的值，否则将设置为16:9默认比例
      contentHeight: 90, // 使用typeNode启动画中画时，contentHeight需设置为大于0的值，否则将设置为16:9默认比例
      customUIController:  this.onSurfaceId ? undefined : this.nodeController
    };
    try {
      this.makeTypeNode(ctx)
      // 通过create接口创建画中画控制器实例
      let controller: PiPWindow.PiPController = await PiPWindow.create(config, this.xComponent);
      this.pipController = controller;
      console.log(TAG, `成功创建 pip controller`);
      // 通过画中画控制器实例的setAutoStartEnabled接口设置是否需要在应用返回桌面时自动启动画中画
      // this.pipController.setAutoStartEnabled(true);
      // 通过画中画控制器实例的on('stateChange')接口注册生命周期事件回调
      this.pipController.on('stateChange', (state: PiPWindow.PiPState, reason: string) => {
        this.onStateChange(state, reason);
      });
      // 通过画中画控制器实例的on('controlEvent')接口注册控制事件回调
      this.pipController.on('controlEvent', (control: PiPWindow.ControlEventParam) => {
        this.onActionEvent(control);
      });
    } catch (err) {
      console.error(TAG, `Failed to create pip controller. Cause:${err.code}, message:${err.message}`);
    }
  }

  // 创建画中画控制器实例后，通过startPiP接口启动画中画
  startPip() {
    if (this.pipController === null || this.pipController === undefined) {
      console.info(TAG, `#startPip pipController不存在, pipController: ${this.pipController}`);
      return;
    }

    this.pipController?.startPiP().then(() => {
      console.info(TAG, `Succeeded in starting pip.`);
    }).catch((err: BusinessError) => {
      console.error(TAG, `Failed to start pip. Cause:${err.code}, message:${err.message}`);
    });
  }

  // 更新媒体源尺寸信息
  updateContentSize(width: number, height: number) {
    if (this.pipController) {
      this.pipController.updateContentSize(width, height);
    }
  }

  // 关闭画中画
  stopPip() {
    if (this.pipController === null || this.pipController === undefined) {
      console.info(TAG, `#stopPip pipController不存在`);
      return;
    }
    let promise: Promise<void> = this.pipController.stopPiP();
    promise.then(() => {
      console.info(TAG, `Succeeded in stopping pip.`);
    }).catch((err: BusinessError) => {
      console.error(TAG, `Failed to stop pip. Cause:${err.code}, message:${err.message}`);
    });
  }

  setAutoStart(autoStart: boolean): void {
    this.pipController?.setAutoStartEnabled(autoStart);
  }

  // 创建typeNode节点
  makeTypeNode(ctx: UIContext) {
    console.info(TAG, `进入makeTypeNode`);
    if (this.xComponent === null || this.xComponent === undefined) {
      console.info(TAG, `开始makeTypeNode`);
      // 创建typeNode
      // let xc_options: XComponentOptions = {
      //   type: XComponentType.TEXTURE, // 类型设置为TEXTURE
      //   controller: Xb_PipManager.getInstance().getXComponentController(), // 设置XComponentController
      // }
      // this.xComponent = typeNode.createNode(ctx, "XComponent", xc_options);

      // 创建XComponent类型的typeNode
      this.xComponent = typeNode.createNode(ctx, "XComponent", {
        type: XComponentType.SURFACE, // 类型设置为SURFACE
        controller: Xb_PipManager.getInstance().mXComponentController, // 设置XComponentController
      });
    }
  }
}