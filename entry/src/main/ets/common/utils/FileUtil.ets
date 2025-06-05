/**
 * 文件系统相关工具类
 *
 * @author Enlin
 */

import { fileIo as fs, ListFileOptions } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { BusinessError } from '@kit.BasicServicesKit'


const componentName: string = 'FileIOUtil'


/**
 * 文件是否存在
 *
 * @param context     common.UIAbilityContext
 * @param fileName    带后缀名的文件名
 * @returns
 */
export function fileIsExist(context: common.UIAbilityContext, fileName: string): boolean {
  let isExist: boolean = fs.accessSync(`${context.filesDir}/${fileName}`, fs.AccessModeType.EXIST)
  hilog.info(0x1020, componentName, `#fileIsExist#文件“${context.filesDir}/${fileName}”是否存在: ${isExist}`)
  return isExist
}

/**
 * 同步获取指定[应用沙箱路径]下的所有文件名
 *
 * @param path 沙箱路径
 */
export function showFileNameListOfFileDir(path: string): Array<string> {
  // let fileNames: Array<string> = this.fileNameFilter.trim() ? this.fileNameFilter.split(',') : []
  hilog.info(0x1020, componentName, `#showFileNameListOfFileDir#开始获取“${path}”文件夹下面的所有文件名称`)
// hilog.info(0x1020, componentName, `#showFileNameListOfFileDir#开始获取“${path}”文件夹下面文件名过滤：“${JSON.stringify(fileNames)}”的所有文件名称`)
// hilog.info(0x1020, componentName, `#showFileNameListOfFileDir#${fileNames.length}`)

  // 文件名称List
  const fileNameArray: Array<string> = []

  // 文件筛选选项
  const listFileOption: ListFileOptions = {
    recursion: false,
    listNum: 0,
    filter: {
      suffix: ['.yaml', '.yml'],
      // mimeType: [],
      fileSizeOver: 0,
      // lastModifiedAfter: new Date(0).getTime(),
      // displayName: fileNames
    }
  }
  // 获取所有文件名
  try {
    fileNameArray.push(...fs.listFileSync(path, listFileOption))
    hilog.info(0x1020, componentName, `#showFileNameListOfFileDir#获取到“${path}”文件夹下面的所有文件名称: ${JSON.stringify(fileNameArray)}`)
  } catch (e) {
    let error: BusinessError = e as BusinessError
    hilog.error(0x1020, componentName, `ERROR:#showFileNameListOfFileDir#listFileSync: code is ${error.code}, message is ${error.message}`)
  }

  // 输出文件信息
  // fileNameArray.forEach( (fileName: string) => {
  //   const fileStat: fs.Stat = fs.statSync(`${context.filesDir}/${fileName}`)
  //   hilog.info(0x1020, componentName, `#showFileNameListOfFileDir#“${path}”文件夹下文件“${fileName}”的大小为: ${fileStat.size}Byte = ${Decimal.div(fileStat.size, 1024).toFixed(2, Decimal.ROUND_DOWN)}KB`)
  // })

  return fileNameArray

}

/**
 * 删除指定沙箱路径下面的所有文件
 * @param pathArray
 */
export function clearAllFiles(pathArray: Array<string>): boolean{
  if (pathArray == null || pathArray.length <= 0) {
    hilog.warn(0x1020, componentName, `#clearAllFiles#待删除文件列表为空`)
    return false
  }
  let currentPathIndex: number = -1
  try {
    pathArray.forEach( (path: string, index: number) => {
      hilog.info(0x1020, componentName, `#clearAllFiles#待删除文件[${index}]: ${path}`)
      currentPathIndex = index
      fs.unlinkSync(path)
      pathArray[index]
    })
  } catch (e) {
    let error: BusinessError = e as BusinessError
    hilog.error(0x1020, componentName, `ERROR:#clearAllFiles#删除“index: ${currentPathIndex}, value: ${pathArray[currentPathIndex]}”文件时发生错误, code is ${error.code}, message is ${error.message}`)
  }
  return true
}