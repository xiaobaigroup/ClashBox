/**
 * 系统分享 https://developer.huawei.com/consumer/cn/doc/harmonyos-references-V5/share-system-share-V5
 *
 * @author Enlin
 */
import { systemShare } from '@kit.ShareKit'
import { uniformTypeDescriptor as utd } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { fileUri } from '@kit.CoreFileKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { fileIsExist } from './FileUtil'

const componentName: string = 'SystemShareUtil'

/**
 * 配置分享
 * @param context   common.UIAbilityContext
 * @param configURL URL字符串
 * @param configId  配置文件id（要通过此名称获取应用沙箱中该文件的uri）
 */
export function configShare(context: common.UIAbilityContext, configURL: string | null, configId: string): boolean{
  // 补充文件后缀
  if (!configId.endsWith('.yaml')) {
    configId = configId + '.yaml'
  }
  // 文件是否存在
  if (!fileIsExist(context, configId)){
    hilog.error(0x1000, componentName, `ERROR: #configShare: “${configId}”文件不存在`)
    return false
  }
  hilog.info(0x1000, componentName, `#configShare#confingURL: ${configURL}, configId: ${configId}`)
  try {

    // 通过沙箱路径获取文件uri
    let uri = fileUri.getUriFromPath(`${context.filesDir}/${configId}`)
    // 待分享数据
    let data: systemShare.SharedData
    // 系统分享控制器
    let controller: systemShare.ShareController

    // 配置文件分享
    data = new systemShare.SharedData({
      // utd: utd.UniformDataType.PLAIN_TEXT,
      utd: 'general.yaml',
      // label: utd.UniformDataType.FILE,
      uri,
      thumbnailUri: uri,
    })
    // URL 分享
    if (configURL != null && configURL.trim() !== '') {
      data.addRecord({
        utd: utd.UniformDataType.HYPERLINK,
        // title: 'URL',
        content: configURL.trim()
      })
      // 制作二维码
      // data.addRecord({
      //   utd: utd.UniformDataType.JPEG,
      //   // title: 'QR-Code',
      //   content:
      // })
    }

    controller = new systemShare.ShareController(data)
    controller.show(context, {
      previewMode: systemShare.SharePreviewMode.DETAIL,
      selectionMode: systemShare.SelectionMode.SINGLE
    })

    controller.on('dismiss', () => {
      hilog.info(0x1000, componentName, `#configShare#on('dismiss'): 分享面板已关闭`)
    })
    controller.off('dismiss', () => {
      hilog.info(0x1000, componentName, `#configShare#off('dismiss'): 取消[分享面板关闭事件]监听`)
    })
  } catch (e) {
    let error:BusinessError = e as BusinessError
    hilog.info(0x1000, componentName, `ERROR:#configShare: code is ${error.code}, message is ${error.message}`)
  }

  return true

  /*
    let records: systemShare.SharedRecord[] = data.getRecords()
    records.forEach((record: systemShare.SharedRecord) => {
      //
    })
    */

}
