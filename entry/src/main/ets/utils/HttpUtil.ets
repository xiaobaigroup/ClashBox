/**
 * 网络请求相关工具类
 *
 * @author Enlin
 */

// import { rcp } from '@kit.RemoteCommunicationKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { BusinessError, request } from '@kit.BasicServicesKit'
import { common } from '@kit.AbilityKit'
// import { fileIo as fs } from '@kit.CoreFileKit'
// import { buffer } from '@kit.ArkTS'


const componentName: string = 'HttpUtil'
let downloadTask: request.DownloadTask | null = null

// export async function httpGet(url: rcp.URLOrString): Promise<rcp.Response> {
//   const method: rcp.HttpMethod = 'GET'
//   const req = new rcp.Request(url, method)
//   const session = rcp.createSession()
//   return session.fetch(req)
// }


/**
 * 根据指定`URL`下载文件，并保存在指定路径下
 * @param context   common.UIAbilityContext
 * @param url       文件url字符串
 * @param savePath  包含文件名的保存路径（例如：/data/storage/el2/base/haps/entry/files/abc.txt）
 * @param callback  下载并保存成功的回调方法
 */
export async function requestDownloadFile(context: common.UIAbilityContext, url: string, savePath: string, callback?: Function): Promise<void> {

  try {
    // 下载文件开始
    hilog.info(0x6000, componentName, `#requestDownloadFile#下载文件开始, url: ${url}, 保存为: ${savePath}`)
    request.downloadFile(context, { url, filePath: savePath })
      .then((downloadTask: request.DownloadTask) => {
        // 下载完成
        downloadTask.on('complete', () => {
          hilog.info(0x6000, componentName, `#requestDownloadFile#downloadTask#complete#下载已完成`)
          if (callback != undefined && callback != null) {
            callback()
          }
          // 打开文件
          // hilog.info(0x6000, componentName, `#requestDownloadFile#打开文件: filePath is: ${savePath}`)
          // let file = fs.openSync(savePath, fs.OpenMode.READ_WRITE)
          // let arrayBuffer = new ArrayBuffer(1024)
          // let readLen = fs.readSync(file.fd, arrayBuffer)
          // let buf = buffer.from(arrayBuffer, 0, readLen)
          // hilog.info(0x6000, componentName, `#requestDownloadFile#打开文件: filePath is: ${savePath}, The content of file: ${buf.toString()}`)
          // fs.closeSync(file)
        })

      })
      .catch((err: BusinessError) => {
        hilog.error(0x6000, componentName,
          `ERROR:#requestDownloadFile#Invoke downloadTask failed, code is ${err.code}, message is ${err.message}`)
      })
  } catch (error) {
    let err: BusinessError = error as BusinessError
    hilog.error(0x6000, componentName,
      `ERROR:#requestDownloadFile#Invoke downloadFile failed, code is ${err.code}, message is ${err.message}`)
  }
}

/**
 * 移除下载任务
 *
 * @param callback  移除成功之后的回调
 */
export function deleteDownloadTask(callback?: Function):void {
  hilog.info(0x1010, componentName, `#deleteDownloadTask#移除下载任务开始`)
  try {
    // 下载文件开始
    downloadTask?.delete()
      .then( (result: boolean) => {
        hilog.info(0x1010, componentName, `#deleteDownloadTask#移除下载任务成功}`)
        if (callback != undefined && callback != null) {
          callback()
        }
      })
  } catch (error) {
    let err: BusinessError = error as BusinessError
    hilog.error(0x1000, componentName, `ERROR:#deleteDownloadTask#Invoke delete downloadTask failed, code is ${err.code}, message is ${err.message}`)
  }
}
