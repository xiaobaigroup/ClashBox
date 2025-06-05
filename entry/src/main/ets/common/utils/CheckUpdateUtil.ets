
import { http } from "@kit.NetworkKit";
import { hilog } from "@kit.PerformanceAnalysisKit";
// 使用GitHub的api来检查更新

// 定义一个接口来匹配GitHub API返回的release信息
interface Asset {
  browser_download_url: string
}

interface Release {
  tag_name: string
  name: string
  published_at: string
  assets: Asset[]
  body: string
}

export interface UpdateInfo {
  tag_name: string
  name: string
  published_at: string
  browser_download_url: string
  body: string
}

// http请求获取Release信息
export function getUpdateInfo(): Promise<Release> {
  return new Promise<Release>((resolve, reject) => {
    let httpRequest = http.createHttp()

    httpRequest.request(`https://api.github.com/repos/xiaobaigroup/ClashBox/releases/latest`, (err: Error, data: http.HttpResponse) => {
      if (!err) {
        hilog.info(0xFF00, "UpdateTestTag", "HTTP返回值: %{public}s", JSON.stringify(data))
        // 确保 data.result 是字符串类型
        if (typeof data.result === 'string') {
          try {
            // 将 data.result 字符串解析为 JSON 对象
            const updateInfo = JSON.parse(data.result) as Release
            resolve(updateInfo)
          } catch (parseErr) {
            reject(new Error('无法解析响应: ' + parseErr.message))
            hilog.info(0xFF00, "UpdateTestTag", "无法解析响应: %{public}s", parseErr.message)
          }
        } else {
          reject(new Error('返回值不是string'))
          hilog.info(0xFF00, "UpdateTestTag", "返回值不是string%{public}s")
        }
      } else {
        reject(new Error(JSON.stringify(err)))
      }
      httpRequest.destroy()
    })
  })
}

// 提取更新信息的函数
export function extractUpdateInfo(updateInfo: Release): UpdateInfo | null {
  return {
    tag_name: updateInfo.tag_name,
    name: updateInfo.name,
    published_at: updateInfo.published_at,
    browser_download_url: updateInfo.assets[0].browser_download_url,
    body: updateInfo.body
  }
}

export function compareVersions(versionA: string, versionB: string): boolean {
  const partsA: number[] = versionA.split('.').map(Number)
  const partsB: number[] = versionB.split('.').map(Number)
  const maxLength: number = Math.max(partsA.length, partsB.length)

  for (let i: number = 0; i < maxLength; i++) {
    const numA: number = partsA[i] !== undefined ? partsA[i] : 0
    const numB: number = partsB[i] !== undefined ? partsB[i] : 0

    if (numA > numB) {
      return true
    } else if (numA < numB) {
      return false
    }
  }

  return false
}

