import { common, Want, wantConstant } from '@kit.AbilityKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import fs from '@ohos.file.fs';
import { promptAction } from '@kit.ArkUI';

/**
 * 需要再module.json5配置文件中声明文件打开能力
 * 接入声明看这个网站 https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/file-processing-apps-startup#目标方接入步骤
 * wantFile()用来拉起应用 放入EntryAbility.ets 的onCreate和onNewWant里
 */

@ObservedV2
class FileConnectApp{
  wantFile(want: Want, filePath: string) {
    // 从want信息中获取uri字段  todo 导入数据
    let uri = want.uri;
    if (uri == null || uri == undefined) {
      console.info('uri is invalid');
      return;
    }else{
      filePath = uri
    }

    try {
      // 根据待打开文件的URI进行相应操作。例如同步读写的方式打开URI获取file对象
      let file = fs.openSync(uri, fs.OpenMode.READ_WRITE);
      console.info('Succeed to open file.');
    } catch (err) {
      let error: BusinessError = err as BusinessError;
      console.error(`Failed to open file openSync, code: ${error.code}, message: ${error.message}`);
    }
  }
}

export const Xb_FileConnectApp: FileConnectApp = new FileConnectApp()