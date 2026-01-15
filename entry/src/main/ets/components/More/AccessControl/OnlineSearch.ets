/**
 * @projectName:    clashnext
 * @fileName:      OnlineSearch
 * @author:     SummerKaze
 * @description:  在线搜索
 * @date:    2026/1/13 16:19
 * @version:    1.0
 */

import { accessControlRdb, AppInfo } from '../../../common/datasources/AccessControlRdb'
import TopBuilder from '../../Settings/TopBuilder'
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { checkoutRowListItem } from '../../Common/Common'
import { CONTENT_END_OFFSET_150 } from '../../../common/entity/Constants'
import { PageMargin } from '../../../common/breakpoint/BreakPoint'
import { Xb_ImageUtils, Xb_ToastUtil } from 'xb_components'
import { http } from '@kit.NetworkKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { AppConfig } from '../../../entryability/AppState'

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
  // 搜索文本
  @State searchText: string = ''
  // 搜索结果列表
  @State apps: SearchAppInfo[] = []
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()

  private async loadAppsInfo(): Promise<AppInfo[]> {
    // 确定当前域
    const domain = this.appConfig.accessControlMode === 'AcceptSelected' ? 'WHITE' : 'BLACK'
    // 确定排序方式
    const sortBy = this.appConfig.accessControlSort === 'name' ? 'name' : 'time'
    // 直接查询数据库，数据库已处理排序和选中状态
    const appListData = await accessControlRdb.getAppsByDomain(domain, sortBy)

    return appListData
  }

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
                const response = await this.getAppList(value)

                if (response.success && response.data) {
                  this.apps = await this.convertToAppInfo(response.data)
                  hilog.info(0xFF00, TAG, "搜索成功，获取到 %{public}d 条数据", this.apps.length)
                }
              } catch (error) {
                hilog.error(0xFF00, TAG, "搜索失败: %{public}s", error.message)
              }
            }
          })

        List() {
          ForEach(this.apps, (app: SearchAppInfo) => {
            ListItem() {
              checkoutRowListItem({
                icon: app.iconUintArr ? Xb_ImageUtils.uint8ArrayToPixelMap(app.iconUintArr) :
                  $r('app.media.box_cat_round'),
                title: app.name,
                endSymbol: app.isExists ? $r('sys.symbol.xmark_circle') : $r('sys.symbol.plus_circle'),
                symbolColor: app.isExists ? "#FFE84026" : this.icon_emphasize,
                subtitle: app.package_name,
                needBackgroundColor: false,
                enabledClick: true
              })
            }
            .onClick(async () => {
              // 点击逻辑
              const newPackageName = app.package_name;
              const newAppName = app.name;
              const iconUintArr = app.iconUintArr

              if (!app.isExists) {
                // TODO 1. --- 新增逻辑 ---
                const newApp: AppInfo = {
                  name: newAppName,
                  package_name: newPackageName,
                  iconUintArr,
                  time: Date.now(),
                  isSelected: false
                };
                // 确定添加到哪个域
                const domain = this.appConfig.accessControlMode === 'AcceptSelected' ? 'WHITE' : 'BLACK'
                await accessControlRdb.addAppToDomain(newApp, domain)
              } else {
                // TODO 2. 后续设计删除提示弹窗
              }

              // TODO 3. 重新加载列表并关闭弹窗
            })
          })
        }
        .width('100%')
        .contentStartOffset(5)
        .alignListItem(ListItemAlign.Center)
        .contentEndOffset(CONTENT_END_OFFSET_150 - 55)
        .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
      }
      .padding({ bottom: 32 })
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
  }

  /**
   * 获取应用列表
   * @param q 搜索关键词
   * @param page 页码，默认为 1
   * @param pageSize 每页数量，默认为 10
   * @returns Promise<SearchResponse> 搜索响应
   */
  getAppList(q: string, page: number = 1, pageSize: number = 10): Promise<SearchResponse> {
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

  async convertToAppInfo(items: SearchAppItem[]): Promise<SearchAppInfo[]> {
    const appInfoList: SearchAppInfo[] = []
    // 获取当前列表中的所有包名
    const appListData = await this.loadAppsInfo()
    const appPackageList = appListData.map(app => app.package_name)

    for (const item of items) {
      // 下载图片并转换为 Uint8Array
      const iconUintArr = await Xb_ImageUtils.downloadImageAsUint8Array(item.icon_url)
      // 检查包名是否已存在于当前列表中
      const isExists = appPackageList.includes(item.pkg_name) ?? false;

      appInfoList.push({
        name: item.name,
        package_name: item.pkg_name,
        iconUintArr: iconUintArr,
        time: Date.now(),
        isSelected: false,
        isExists
      } as SearchAppInfo)
    }

    return appInfoList
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

interface SearchAppInfo extends AppInfo {
  // 此应用是否存在
  isExists: boolean
}