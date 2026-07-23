import { fileShare, fileUri, picker, ReadOptions } from "@kit.CoreFileKit";
import Want from "@ohos.app.ability.Want";
import wantConstant from "@ohos.app.ability.wantConstant";
import common from "@ohos.app.ability.common";
import { JSON, util } from "@kit.ArkTS";
import { fileIo as fs } from '@kit.CoreFileKit';
import { Context } from "@kit.AbilityKit";

import { Xb_GlobalContext } from "../entity/GlobalContext";
import { Xb_ToastUtil } from "./ToastUtils";

export class Xb_FileUtils {
  /** 打开外部文件 */
  static async openFile(context: Context | undefined = undefined, fileSuffixFilters: string[] = []): Promise<string | undefined> {
    const documentPicker = new picker.DocumentViewPicker(context ?? Xb_GlobalContext.getContext());
    const documentSelectOptions = new picker.DocumentSelectOptions();
    documentSelectOptions.maxSelectNumber = 1;
    documentSelectOptions.fileSuffixFilters = fileSuffixFilters
    const result = await documentPicker.select(documentSelectOptions)
    const filePath = result.length > 0 ? result[0] : undefined;
    if (filePath != null) {
      return new fileUri.FileUri(filePath!).path
    }
    return undefined;
  }

  static async selectDir(): Promise<string | undefined> {
    let documentSelectOptions = new picker.DocumentSelectOptions();
    documentSelectOptions.selectMode = picker.DocumentSelectMode.FOLDER;
    const documentViewPicker = new picker.DocumentViewPicker(Xb_GlobalContext.getContext());
    const result = await documentViewPicker.select(documentSelectOptions)
    const filePath = result.length > 0 ? result[0] : undefined;
    if (filePath != null) {
      return new fileUri.FileUri(filePath!).path
    }
    return undefined;
  }

  static async persistPermissionDir(dir: string): Promise<void> {
    let uri = new fileUri.FileUri(dir).getFullDirectoryUri()
    let policies: fileShare.PolicyInfo[] = [{
        uri: uri,
        operationMode: fileShare.OperationMode.READ_MODE
      },
      {
        uri: uri,
        operationMode: fileShare.OperationMode.WRITE_MODE
      }
    ];
    try {
      if (canIUse("SystemCapability.FileManagement.AppFileService.FolderAuthorization")) {
        await fileShare.persistPermission(policies)
        console.info('persistPermission successfully');
      } else {
        // Fallback for unsupported SystemCapability
      }
    } catch (err) {
      console.error('persistPermission failed with error message: ' + err.message + ', error code: ' + err.code);
      if (err.code == 13900001 && err.data) {
        for (let i = 0; i < err.data.length; i++) {
          console.error('persistPermission error code : ' + JSON.stringify(err.data[i].code));
          console.error('persistPermission error uri : ' + JSON.stringify(err.data[i].uri));
          console.error('persistPermission error reason : ' + JSON.stringify(err.data[i].message));
        }
      }
      Xb_ToastUtil.showToast({message:"自定义文件权限持久化失败: " + err.message})
    }
    return
  }
  static async activatePermissionDir(dir: string): Promise<void> {
    let uri = new fileUri.FileUri(dir).getFullDirectoryUri()
    let policies: fileShare.PolicyInfo[] = [{
        uri: uri,
        operationMode: fileShare.OperationMode.READ_MODE
      },
      {
        uri: uri,
        operationMode: fileShare.OperationMode.WRITE_MODE
      }
    ];
    try {
      if (canIUse("SystemCapability.FileManagement.AppFileService.FolderAuthorization")) {
        await fileShare.activatePermission(policies)
        console.info('persistPermission successfully');
      } else {
        // Fallback for unsupported SystemCapability
      }
    } catch (err) {
      console.error('persistPermission failed with error message: ' + err.message + ', error code: ' + err.code);
      if (err.code == 13900001 && err.data) {
        for (let i = 0; i < err.data.length; i++) {
          console.error('persistPermission error code : ' + JSON.stringify(err.data[i].code));
          console.error('persistPermission error uri : ' + JSON.stringify(err.data[i].uri));
          console.error('persistPermission error reason : ' + JSON.stringify(err.data[i].message));
        }
      }
      Xb_ToastUtil.showToast({message:"自定义文件权限激活失败: " + err.message})
    }
    return
  }

  /**
   * 用其他应用打开文件（Want方式）
   */
  static async openFileBy(uri: string) {
    // 打开文件
    const want: Want = {
      action: 'ohos.want.action.sendData', // 表示发送数据的操作
      uri,
      // type:'', // 表示待打开文件的类型
      // 配置被分享文件的读写权限，例如对文件打开应用进行读写授权
      flags: wantConstant.Flags.FLAG_AUTH_READ_URI_PERMISSION
    }
    const context = getContext() as common.UIAbilityContext
    try {
      await context.startAbility(want)
    } catch (error) {
      console.error(`文件打开失败：${JSON.stringify(error)}`)
    }
  }

  /** 将数据导出为文件 */
  static async exportDataByFile<T>(fileName: string, data: T, context: common.Context,
    needCache: boolean = false): Promise<string> {
    try {
      let status = false
      let filePicker = new picker.DocumentViewPicker(context)
      let options = new picker.DocumentSaveOptions()
      options.newFileNames = [fileName]
      options.fileSuffixChoices = ["'文档|.json'"]
      options.pickerMode = picker.DocumentPickerMode.DOWNLOAD
      const result = await filePicker.save(options)
      const dateStr = new Date().toISOString().split('T')[0]
      let path = new fileUri.FileUri(result[0] + '/' + `${fileName}_${dateStr}.json`).path
      try {
        await Xb_FileUtils.saveData(path, data, context, `${fileName}_${dateStr}.json`, needCache)
        status = true
      } catch (err) {
        status = false
        console.debug('exportFile', 'err: ', err)
      }
      // 根据状态返回文件路径
      return status ? needCache ? context.filesDir + '/' + `${fileName}_${dateStr}.json` : path : ''
    } catch (e) {
      console.info("exportFile", "err: ", e)
      return ''
    }
  }

  /** 从文件指定类型数据 */
  static async importDataByFile<T>(fileUri: string): Promise<T | null> {
    try {
      // 打开文件获取文件描述符
      const file = fs.openSync(fileUri, fs.OpenMode.READ_ONLY);
      try {
        console.log('#Xb_FileUtils.importFile file fd:', file.fd);
        const stats = fs.statSync(file.path);
        const fileSize = stats.size;
        console.log('#Xb_FileUtils.importFile fileSize:', fileSize);
        let buffer = new ArrayBuffer(fileSize);
        const readOptions: ReadOptions = {
          offset: 0,
          length: fileSize
        };
        console.log('#Xb_FileUtils.importFile readOptions:', JSON.stringify(readOptions));
        fs.readSync(file.fd, buffer, readOptions);
        let textDecoder = util.TextDecoder.create("UTF-8", { ignoreBOM: false });
        let dataStr = textDecoder.decodeToString(new Uint8Array(buffer));
        console.debug(`#Xb_FileUtils.getFileList json数据： `, dataStr)
        // 清理和修复JSON字符串
        const cleanedJsonStr = Xb_FileUtils.cleanAndFixJson(dataStr);
        console.debug(`#Xb_FileUtils.importFile 修复后的JSON数据：`, cleanedJsonStr);
        try {
          const datas = JSON.parse(cleanedJsonStr) as T;
          console.debug(`#Xb_FileUtils.importFile 解析后数据: `, JSON.stringify(datas as object));
          return datas;
        } catch (parseError) {
          console.error('Xb_FileUtils.importFile JSON解析失败:', parseError);
          return null;
        }
      } catch (err) {
        console.error('Xb_FileUtils.importFile 解析File operation failed:', JSON.stringify(err));
        return null
      } finally {
        // 关闭文件
        fs.closeSync(file);
      }
    } catch (error) {
      console.error('Xb_FileUtils.importFile openSync operation failed:', JSON.stringify(error));
      return null
    }
  }

  // 清理和修复JSON字符串的方法
  private static cleanAndFixJson(jsonStr: string): string {
    // 去除响应式属性
    let cleanedStr = jsonStr
      .replace(/"__ob_/g, '"')  // 移除 "__ob_" 前缀
      .replace(/"___watch__obj_":\{[^}]*\},?/g, ''); // 移除 "___watch__obj_{...}" 键值对

    // 修复多余的逗号（可能会导致JSON无效）
    cleanedStr = cleanedStr.replace(/,(\s*[}\]])/g, '$1');

    // 修复多余的大括号
    // 计算大括号数量是否匹配
    const openBraces = (cleanedStr.match(/{/g) || []).length;
    const closeBraces = (cleanedStr.match(/}/g) || []).length;

    if (closeBraces > openBraces) {
      // 移除多余的大括号
      let fixedStr = cleanedStr;
      for (let i = 0; i < closeBraces - openBraces; i++) {
        fixedStr = fixedStr.replace(/}\s*$/, '');
      }
      return fixedStr;
    }

    return cleanedStr;
  }

  /** 保存数据文件 */
  private static async saveData<T>(uri: string, data: T, context: common.Context, file_name?: string,
    needCache: boolean = false): Promise<void> {
    try {
      const file = fs.openSync(uri, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      // 生成保存的内容
      const datas = JSON.stringify(data as Object, null, 2)
      fs.writeSync(file.fd, datas);
      fs.fsync(file.fd).catch((error: Error) => {
        console.error(`文件的缓存数据同步到存储失败：`, error)
      })
      if (needCache) {
        // 在沙箱缓存文件
        const filePath = context.filesDir + '/' + file_name
        console.log(`沙箱filePath的路径是: ${filePath}`)
        const cache = fs.openSync(filePath, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
        fs.writeSync(cache.fd, datas);
        fs.closeSync(cache)
      }
    } catch (e) {
      console.info("ExportLog", "Err: ", e.message)
    }
  }
}