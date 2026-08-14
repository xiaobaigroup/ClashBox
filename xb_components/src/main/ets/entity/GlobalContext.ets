import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { Xb_ToastUtil } from '../utils/ToastUtils';
import { fileUri, picker } from '@kit.CoreFileKit';
import { Xb_CrashUtils } from '../../../../Index';
import { CrashUtils } from '../utils/CrashUtils';

/**
 * 开发初始化和获取应用上下文的接口
 */
@ObservedV2
class GlobalContext {
  // 当前windowId
  windowId: number =0
  downloadDir: string = ""
  private context?: common.UIAbilityContext;


  public initContext(context: common.UIAbilityContext): void {
    this.context = context;
    Xb_CrashUtils.init(context)
  }
  // 需要在
  async initDownloadDir() : Promise<void>{
    try {
      const documentSaveOptions = new picker.DocumentSaveOptions();
      documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
      const documentViewPicker = new picker.DocumentViewPicker(this.context!);
      const path = await documentViewPicker.save(documentSaveOptions)
      const dir = new fileUri.FileUri(path[0]).path;
      this.downloadDir = dir
    } catch (e) {
      Xb_ToastUtil.showToast({message:"初始化下载目录失败:" + e.message})
    }
  }

  public initWindow(window: window.Window){
    try {
      this.windowId = window.getWindowProperties().id
      Xb_ToastUtil.initContext(window.getUIContext())
      Xb_CrashUtils.init(this.context!)
    } catch (error) {
      Xb_ToastUtil.showToast({message:"窗口id获取失败"})
    }
  }
  public getContext(): common.UIAbilityContext {
    return this.context!;
  }
}



export const Xb_GlobalContext: GlobalContext = new GlobalContext()