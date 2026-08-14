import { BusinessError } from '@kit.BasicServicesKit';
import { AppStorageV2, display, window } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';

@ObservedV2
class ScreenInfo {
  @Trace orientation: window.Orientation = window.Orientation.AUTO_ROTATION

  // 注意：windowClass应该在应用UI里初始化
  public windowClass?: window.Window

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
  @Trace WidthBp: number = 1


  //设置状态栏文本颜色颜色为白色
  @Monitor('onColorModeChange')
  onColorModeChange(): void {
    let windowClass = AppStorage.get<window.Window>('windowClass') as window.Window;
    windowClass.setWindowSystemBarProperties({
      statusBarContentColor: '#FFFFFF'
    });
  }

  //监听屏幕信息，尺寸以及方向
 /* onWinChange() {
    //获取当前应用内最上层的子窗口
    if (this.windowClass) {
      this.windowClass.on('windowSizeChange', (w: window.Size) => {
        saveUI.winWidth = w.width
        saveUI.winHeight = w.height

        console.info('屏幕#尺寸', '宽：' + w.width, '高：' + w.height)
      })
    }
  }*/
  @Trace direction: number = -1
  @Trace deviceType: string = ''
  @Monitor('deviceType')
  //查询设备信息
  deviceInfo(){
    let deviceTypeInfo: string = deviceInfo.deviceType;
    let ret: boolean = false;

    ret = display.isFoldable();
    // TODO fix
    //  && saveUI.winWidth > 2200
    if (ret ) {
      this.deviceType = 'foldable'
    }else {
      this.deviceType = deviceTypeInfo
    }
  }
}

export const screenInfo: ScreenInfo = AppStorageV2.connect(ScreenInfo,'ScreenInfo', () => new ScreenInfo())!;
