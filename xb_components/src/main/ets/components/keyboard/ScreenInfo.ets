import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2, display, window } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@ObservedV2
class ScreenInfo {
  @Trace orientation: window.Orientation = window.Orientation.AUTO_ROTATION_RESTRICTED

  // 注意：windowClass应该在应用UI里初始化
  public windowClass?: window.Window
  @Trace uiContext?: UIContext
  //设置屏幕方向
  public setOrientation(orientation: number) {
    if (this.windowClass) {
      this.windowClass.setPreferredOrientation(orientation).then(() => {
        console.info('setWindowOrientation: ' + orientation + ' Succeeded.');
      }).catch((err: BusinessError) => {
        console.error('setWindowOrientation: ' + orientation + ' Failed. Cause: ' + JSON.stringify(err));
      })
    }
  }

  /*设备断点获取*/
  @Trace WidthBp: number = -1
  @Trace HeightBp: number = -1


  //设置状态栏文本颜色颜色为白色
  onColorModeChange(): void {
    let windowClass = AppStorage.get<window.Window>('windowClass') as window.Window;
    windowClass?.setWindowSystemBarProperties({
      statusBarContentColor: '#FFFFFF'
    });
  }

  @Trace direction: number = -1
  @Trace deviceType: string = ''
  @Monitor('deviceType')
  //查询设备信息
  deviceInfo(){
    let deviceTypeInfo: string = deviceInfo.deviceType;
    let ret: boolean = false;

    ret = display.isFoldable();
    // if (ret && saveUI.winWidth > 2200 ) {
    //   this.deviceType = 'foldable'
    // }else {
    //   this.deviceType = deviceTypeInfo
    // }
  }

  @Trace leftRects: number = 0//左侧挖孔避让
  @Trace rightRects: number = 0//右侧挖孔避让
  @Trace leftRectsT: number = 0//虚拟手柄侧边栏呼出键挖孔避让
  //挖孔避让
    async getCutoutInfo() {
      // const saveUI = makeSaveUI()
      //  获取默认显示设备
      // const displayClass = display.getDefaultDisplaySync();
      // // 获取挖孔信息
      // const res = await displayClass.getCutoutInfo();
      // res.boundingRects.filter((v: display.Rect)=>{
      //   if (this.deviceType == 'phone') { //手机
      //     if (v.left < v.top && v.top < saveUI.winHeight / 2) { //横屏挖孔在左边
      //       this.leftRects = screenInfo.uiContext!.px2vp(v.left + 4)
      //     } else if (v.left > v.top && v.left > saveUI.winWidth / 2) { //横屏挖孔在右边
      //       this.rightRects = screenInfo.uiContext!.px2vp(saveUI.winWidth - v.left - v.width + 4)
      //     } else {
      //       this.leftRects = 0
      //       this.rightRects = 0
      //     }
      //     console.log('屏幕信息#设备', '手机设备')
      //   }else if (screenInfo.deviceType == 'tablet' || screenInfo.deviceType == 'foldable') {
      //     if (v.width == v.height) { //单挖孔设备
      //       if ((v.left <= v.top && v.top < saveUI.winHeight / 2 && v.left < saveUI.winWidth / 2) || //横屏挖孔在左上角
      //         (v.left >= v.top && v.left > saveUI.winWidth / 2 && v.top < saveUI.winHeight / 2)) { //竖屏挖孔在右上角
      //         this.leftRectsT = screenInfo.uiContext!.px2vp(v.width)
      //       } else {
      //         this.leftRectsT = 0
      //         this.leftRects = 0
      //         this.rightRects = 0
      //       }
      //       console.log('屏幕信息#设备', '单挖孔平板或折叠屏（如mpp11）')
      //     } else {//13.2平板设备
      //       this.leftRects = 0
      //       this.rightRects = 0
      //       console.log('屏幕信息#设备', '非单挖孔平板或折叠屏（如mpp13.2）')
      //     }
      //   } else if (screenInfo.deviceType === '2in1'){// pc设备
      //     this.leftRects = 0
      //     this.rightRects = 0
      //     appState.topRect = 0
      //     console.log('屏幕信息#设备', 'pc设备')
      //   }
      // })
      // console.info('屏幕信息#挖孔避让：', JSON.stringify(res.boundingRects),'左侧避让：', screenInfo.leftRects, '右侧避让', this.rightRects,
      //   '状态栏避让：', appState.topRect)
    }

    //临时查看pc窗口状态
  @Trace fullScreenState: number = 0

  //pc全屏化
  maximize(): void {
    this.fullScreenState = this.windowClass!.getWindowStatus()
    if (this.windowClass!.getWindowStatus() != window.WindowStatusType.FULL_SCREEN) {
      console.info('#pc全屏:','即将进入全屏')

      this.windowClass!.maximize(window.MaximizePresentation.ENTER_IMMERSIVE_DISABLE_TITLE_AND_DOCK_HOVER)
        .then(() => {
          console.info('#pc全屏:','成功进入全屏')
          hilog.info(0x0000, 'testTag', '%{public}s', `Succeed in maximizing the window.`);
        })
        .catch((err: BusinessError) => {
          console.info('#pc全屏:','进入失败')
          hilog.error(0x0000, 'testTag', `Failed to maximize the window. Code: ${err.code}, message: ${err.message}`,
            JSON.stringify(err) ?? '');
        });
    }
  }

  //pc窗口化
  recover(): void {
    if (this.windowClass!.getWindowStatus() === window.WindowStatusType.FULL_SCREEN) {
      if (this.fullScreenState === window.WindowStatusType.FLOATING){//全屏之前为悬浮窗口时
        console.info('#pc全屏:','即将退出全屏')
        this.windowClass!.recover()//还原为悬浮窗口
          .then(() => {
            console.info('#pc全屏:','成功退出全屏')
            hilog.info(0x0000, 'testTag', '%{public}s', `Succeed in recovering the window.`);
          })
          .catch((err: BusinessError) => {
            console.info('#pc全屏:','退出失败')
            hilog.error(0x0000, 'testTag', `Failed to recover the window. Code: ${err.code}, message: ${err.message}`,
              JSON.stringify(err) ?? '');
          });
      }else if (this.fullScreenState === window.WindowStatusType.MAXIMIZE){//全屏之前为最大化窗口时
        console.info('#pc全屏:','即将转为最大化窗口')
        this.windowClass!.maximize(1)//还原为最大化窗口
          .then(() => {
            console.info('#pc全屏:','成功转为最大化窗口')
            hilog.info(0x0000, 'testTag', '%{public}s', `Succeed in maximizing the window.`);
          })
          .catch((err: BusinessError) => {
            console.info('#pc全屏:','最大化窗口失败')
            hilog.error(0x0000, 'testTag', `Failed to maximize the window. Code: ${err.code}, message: ${err.message}`,
              JSON.stringify(err) ?? '');
          });
      }
    }
  }

  //pc是否全屏判定
  isPcFullScreen(){
    // if (saveUI.pcFullScreen) {
    //   this.maximize()
    // }else {
    //   this.recover()
    // }
  }

}

export const screenInfo: ScreenInfo = AppStorageV2.connect(ScreenInfo,'ScreenInfo', () => new ScreenInfo())!;
