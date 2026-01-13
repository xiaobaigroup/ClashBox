/**
 * @projectName:    clashnext
 * @fileName:      OnlineSearch
 * @author:     SummerKaze
 * @description:  在线搜索
 * @date:    2026/1/13 16:19
 * @version:    1.0
 */

import { AppInfo } from '../../../common/datasources/AccessControlRdb'
import TopBuilder from '../../Settings/TopBuilder'
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { checkoutRowListItem } from '../../Common/Common'
import { CONTENT_END_OFFSET_150 } from '../../../common/entity/Constants'
import { PageMargin } from '../../../common/breakpoint/BreakPoint'
import { Xb_ImageUtils } from 'xb_components'
import { http } from '@kit.NetworkKit'
import { hilog } from '@kit.PerformanceAnalysisKit'

@Builder
export function OnlineSearchBuilder(name: string, param: Object) {
  OnlineSearch()
}

const TAG = "OnlineSearch"

@Component
struct OnlineSearch {
  @StorageLink('OnlineSearchPageInfos') addPageInfos: NavPathStack = new NavPathStack()
  // 高度断点
  @StorageLink('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @State searchText: string = ''
  @State apps: AppInfo[] = []

  build() {
    NavDestination() {
      TopBuilder({
        showBackButton: true,
        title: $r('app.string.online_search'),
        pathStack: this.addPageInfos
      })

      Column() {
        Search({ value: this.searchText, placeholder: $r('app.string.enter_search') })
          .enterKeyType(EnterKeyType.Search)
          .copyOption(CopyOptions.LocalDevice)
          .searchIcon(new SymbolGlyphModifier($r('sys.symbol.magnifyingglass')).fontColor([this.icon_emphasize]))
          .margin({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
          .cancelButton({
            style: CancelButtonStyle.CONSTANT,
            icon: new SymbolGlyphModifier($r('sys.symbol.xmark')).fontColor([this.icon_emphasize])
          })
          .onSubmit(async (value: string) => {
            // 发送搜索
            this.searchText = value
            if (value.length > 0) {
              try {
                const response = await getAppList(value)

                if (response.success && response.data) {
                  this.apps = await convertToAppInfo(response.data)
                  hilog.info(0xFF00, TAG, "搜索成功，获取到 %{public}d 条数据", this.apps.length)
                }
              } catch (error) {
                hilog.error(0xFF00, TAG, "搜索失败: %{public}s", error.message)
              }
            }
          })


        List() {
          ForEach(this.apps, (app: AppInfo) => {
            ListItem() {
              checkoutRowListItem({
                icon: app.iconUintArr ? Xb_ImageUtils.uint8ArrayToPixelMap(app.iconUintArr) :
                  $r('app.media.box_cat_round'),
                title: app.name,
                endSymbol: $r('sys.symbol.plus_circle'),
                subtitle: app.package_name,
                enabledClick: true
              })
            }
          })
        }
        .width('100%')
        .alignListItem(ListItemAlign.Center)
        .contentEndOffset(CONTENT_END_OFFSET_150 - 75)
        .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
      }
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
  }
}

/** API 返回的单个应用信息 */
interface SearchAppItem {
  name: string
  pkg_name: string
  icon_url: string
  download_count: number
  download_count_desc: string
}

/** API 搜索响应结构 */
interface SearchResponse {
  success: boolean
  data: SearchAppItem[]
  message: string | null
  total: number
  limit: number
  timestamp: string
}

/** TODO 建议抽离到 Xb_ImageUtils 去
 * 从 URL 下载图片并转换为 Uint8Array
 * @param url 图片的在线 URL 地址
 * @returns Promise<Uint8Array | undefined> 图片的 Uint8Array 数据，失败返回 undefined
 */
function downloadImageAsUint8Array(url: string): Promise<Uint8Array | undefined> {
  return new Promise<Uint8Array | undefined>((resolve) => {
    if (!url) {
      resolve(undefined)
      return
    }

    let httpRequest = http.createHttp()
    httpRequest.request(url, {
      method: http.RequestMethod.GET,
      expectDataType: http.HttpDataType.ARRAY_BUFFER
    }, (err: Error, data: http.HttpResponse) => {
      if (!err && data.result instanceof ArrayBuffer) {
        const uint8Array = new Uint8Array(data.result)
        hilog.info(0xFF00, TAG, "图片下载成功: %{public}s, 大小: %{public}d bytes", url, uint8Array.length)
        resolve(uint8Array)
      } else {
        hilog.warn(0xFF00, TAG, "图片下载失败: %{public}s", url)
        resolve(undefined)
      }
      httpRequest.destroy()
    })
  })
}

/**
 * 获取应用列表
 * @param q 搜索关键词
 * @param page 页码，默认为 1
 * @param pageSize 每页数量，默认为 10
 * @returns Promise<SearchResponse> 搜索响应
 */
function getAppList(q: string, page: number = 1, pageSize: number = 10): Promise<SearchResponse> {
  return new Promise<SearchResponse>((resolve, reject) => {
    let httpRequest = http.createHttp()
    const url =
      `https://next.vcck.cn/api/apps/search-by-name?q=${encodeURIComponent(q)}&page=${page}&page_size=${pageSize}`

    httpRequest.request(url, (err: Error, data: http.HttpResponse) => {
      if (!err) {
        hilog.info(0xFF00, TAG, "HTTP返回值: %{public}s", JSON.stringify(data))
        // 确保 data.result 是字符串类型
        if (typeof data.result === 'string') {
          try {
            // 将 data.result 字符串解析为 JSON 对象
            const response = JSON.parse(data.result) as SearchResponse
            resolve(response)
          } catch (parseErr) {
            reject(new Error('无法解析响应: ' + parseErr.message))
            hilog.error(0xFF00, TAG, "无法解析响应: %{public}s", parseErr.message)
          }
        } else {
          reject(new Error('返回值不是string'))
          hilog.warn(0xFF00, TAG, "返回值不是string")
        }
      } else {
        reject(new Error(JSON.stringify(err)))
      }
      httpRequest.destroy()
    })
  })
}

/**
 * 将 API 返回的数据转换为 AppInfo 数组（异步下载图片）
 * @param items API 返回的应用信息数组
 * @returns Promise<AppInfo[]> 转换后的应用信息数组
 */
async function convertToAppInfo(items: SearchAppItem[]): Promise<AppInfo[]> {
  const appInfoList: AppInfo[] = []

  for (const item of items) {
    // 下载图片并转换为 Uint8Array
    const iconUintArr = await downloadImageAsUint8Array(item.icon_url)

    appInfoList.push({
      name: item.name,
      package_name: item.pkg_name,
      iconUintArr: iconUintArr,
      time: Date.now(),
      isSelected: false
    } as AppInfo)
  }

  return appInfoList
}