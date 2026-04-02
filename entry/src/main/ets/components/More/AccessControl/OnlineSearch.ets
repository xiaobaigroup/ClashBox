import { accessControlRdb, AppInfo } from '../../../common/datasources/AccessControlRdb'
import TopBuilder from '../../Settings/TopBuilder'
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { checkoutRowListItem, theRowCustomDialog } from '../../Common/Common'
import { CONTENT_END_OFFSET_150 } from '../../../common/entity/Constants'
import { PageMargin } from '../../../common/breakpoint/BreakPoint'
import { EventHub, Xb_ImageUtils, Xb_ToastUtil } from 'xb_components'
import { http } from '@kit.NetworkKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { AppConfig, UIConfig } from '../../../entryability/AppState'
import { EventKey } from '../../../common/EventHub'
import { customAnimationUtil } from '../../../common/utils/Animation'
import { EmptySearchResult } from './SubmitApp'

@Builder
export function OnlineSearchBuilder(name: string, param: Object) {
  OnlineSearch()
}

const TAG = "OnlineSearch"

/**
 * 服务状态枚举
 * @description 用于表示在线服务的运行状态
 */
enum ServiceStatus {
  /** 故障 */
  DOWN = 0,
  /** 正常 */
  UP = 1,
  /** 重试 */
  RETRY = 2,
  /** 维护中 */
  MAINTENANCE = 3
}

/**
 * @projectName:    clashnext
 * @fileName:      OnlineSearch
 * @author:     SummerKaze
 * @description:  在线搜索
 * @date:    2026/1/13 16:19
 * @version:    1.0
 */

@Component
struct OnlineSearch {
  @StorageLink('OnlineSearchPageInfos') addPageInfos: NavPathStack = new NavPathStack()
  // 高度断点
  @StorageLink('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // UI控制变量
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 搜索文本
  @State searchText: string = ''
  // 搜索结果列表
  @State apps: SearchAppInfo[] = []
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  // 是否正在搜索
  @State isSearch: boolean = false;
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  // 在线服务状态（0: 故障, 2: 重试, 1: 正常, 3: 维护）
  @State serviceStatus: ServiceStatus = ServiceStatus.RETRY
  // 临时的搜索结果列表 -> 用于刷新列表使用的存储一下减少请求次数
  private resultApps: SearchAppItem[] = []
  // 防抖定时器ID
  private debounceTimerId: number = -1
  // 防抖延迟时间（毫秒）
  private readonly DEBOUNCE_DELAY: number = 400
  // 待删除的应用信息
  private pendingDeleteApp: SearchAppInfo | null = null
  // 服务状态请求定时器ID
  private serviceStatusTimerId: number = -1
  // 服务状态请求间隔 (5分钟/次)
  private readonly SERVICE_STATUS_INTERVAL: number = 5 * 60 * 1000
  // 红绿灯状态指示器尺寸
  private readonly INDICATOR_SIZE: number = 16

  aboutToAppear(): void {
    this.fetchServiceStatus()

    // 5分钟获取一次服务状态
    this.serviceStatusTimerId = setInterval(() => {
      this.fetchServiceStatus()
    }, this.SERVICE_STATUS_INTERVAL)
  }

  aboutToDisappear(): void {
    this.clearDebounceTimer()
    clearInterval(this.serviceStatusTimerId)
  }

  build() {
    NavDestination() {
      TopBuilder({
        showBackButton: true,
        title: $r('app.string.online_search'),
        pathStack: this.addPageInfos,
        extraBuilder: () => {
          this.statusIndicatorBuilder()
        }
      })

      Column() {
        Search({ value: this.searchText, placeholder: $r('app.string.the_app_name') })
          .enterKeyType(EnterKeyType.Search)
          .copyOption(CopyOptions.LocalDevice)
          .searchIcon(new SymbolGlyphModifier($r('sys.symbol.magnifyingglass')).fontColor([this.icon_emphasize]))
          .margin({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
          .cancelButton({
            style: CancelButtonStyle.CONSTANT,
            icon: new SymbolGlyphModifier($r('sys.symbol.xmark')).fontColor([this.icon_emphasize])
          })
          .onChange((value: string) => {
            // 使用防抖 (Debounce) 进行搜索
            this.debounceSearch(value)
          })
          .onSubmit(async (value: string) => {
            // 提交时立即执行搜索（清除防抖定时器）
            this.clearDebounceTimer()
            await this.searchApps(value)
          })

        if (this.isSearch) {
          // 搜索动画
          Row() {
            LoadingProgress()
              .color(this.icon_emphasize)
              .width("20%")
              .aspectRatio(1)
              .transition(customAnimationUtil.isOpacity(this.uiConfig))
          }
          .justifyContent(FlexAlign.Center)
          .layoutWeight(1)
        } else if (this.apps.length === 0 && this.searchText.trim() !== '') {
          // 搜索结果为空，显示提交应用建议
          EmptySearchResult({
            searchText: this.searchText,
            onSubmitSuccess: () => {
              // 提交成功后的回调（可选：重新搜索）
            }
          })
        } else {
          List() {
            ForEach(this.apps, (app: SearchAppInfo) => {
              ListItem() {
                checkoutRowListItem({
                  icon: Xb_ImageUtils.uint8ArrayToPixelMap(app.iconUintArr) || $r('app.media.box_cat_round'),
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
                  // 1. --- 新增逻辑 ---
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
                  Xb_ToastUtil.showToast({ message: $r('app.string.add_success'), duration: 1000 })

                  // 重新加载列表（仅新增时执行）
                  this.apps = await this.convertToAppInfo(this.resultApps)
                  EventHub.sendEvent(EventKey.ReLoadAccessControl)
                } else {
                  // 2. 删除逻辑 - 显示确认弹窗防止误操作
                  this.pendingDeleteApp = app
                  this.deleteDialogController.open()
                }
              })
            })
          }
          .width('100%')
          .contentStartOffset(5)
          .alignListItem(ListItemAlign.Center)
          .contentEndOffset(CONTENT_END_OFFSET_150 - 55)
          .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
        }
      }
      .padding({ bottom: 32 })
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
  }

  /** 红绿灯状态指示器 */
  @Builder
  statusIndicatorBuilder() {
    Row() {
      // 外层泛光效果容器
      Stack() {
        // 泛光层（底层发光效果）
        Row()
          .borderRadius("50%")
          .backgroundColor(this.getStatusColor())
          .width(this.INDICATOR_SIZE * 0.75)
          .aspectRatio(1)
          .shadow({
            radius: this.INDICATOR_SIZE * 0.5,
            color: this.getStatusColor(),
            offsetX: 0,
            offsetY: 0
          })
          .opacity(0.6)

        // 主指示灯
        Row()
          .borderRadius("50%")
          .backgroundColor(this.getStatusColor())
          .width(this.INDICATOR_SIZE * 0.58)
          .aspectRatio(1)
          .shadow({
            radius: this.INDICATOR_SIZE * 0.25,
            color: this.getStatusColor(),
            offsetX: 0,
            offsetY: 0
          })
        // 高光点（增加立体感）
        Row()
          .borderRadius("50%")
          .backgroundColor('#FFFFFF')
          .width(this.INDICATOR_SIZE / 6)
          .aspectRatio(1)
          .opacity(0.7)
          .offset({ x: -this.INDICATOR_SIZE / 8, y: -this.INDICATOR_SIZE / 8 })
      }
      .width(this.INDICATOR_SIZE)
      .aspectRatio(1)
      .margin({ left: 8 })
    }
    .alignItems(VerticalAlign.Center)
  }

  /** 删除确认弹窗控制器 */
  deleteDialogController: CustomDialogController = new CustomDialogController({
    builder: theRowCustomDialog({
      contentText: $r('app.string.delete_app_confirm'),
      cancel: () => {
        this.onDeleteCancel()
      },
      confirm: () => {
        this.onDeleteConfirm()
      },
      leftButton: () => {
        this.deleteBuilder()
      }
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        // 点击遮蔽层不响应，防误触
      } else {
        dismissDialogAction.dismiss()
        this.isEnableIndexForegroundBlur = false
      }
    }
  })

  /** 删除按钮样式 */
  @Builder
  deleteBuilder() {
    Button($r('app.string.delete'))
      .width('100%')
      .height(39)
      .fontColor(Color.Red)
      .backgroundColor($r('app.color.container_background'))
  }

  /** 取消删除回调 */
  onDeleteCancel(): void {
    this.pendingDeleteApp = null
    this.isEnableIndexForegroundBlur = false
  }

  /** 确认删除回调 */
  async onDeleteConfirm(): Promise<void> {
    if (this.pendingDeleteApp) {
      const domain = this.appConfig.accessControlMode === 'AcceptSelected' ? 'WHITE' : 'BLACK'
      try {
        await accessControlRdb.removeAppFromDomain(this.pendingDeleteApp.package_name, domain)
        Xb_ToastUtil.showToast({ message: $r('app.string.delete_success'), duration: 1000 })

        // 刷新列表
        this.apps = await this.convertToAppInfo(this.resultApps)
        EventHub.sendEvent(EventKey.ReLoadAccessControl)
      } catch (error) {
        hilog.error(0xFF00, TAG, "删除失败: %{public}s", error.message)
        Xb_ToastUtil.showToast({ message: $r('app.string.delete_failed') })
      }
    }
    this.pendingDeleteApp = null
    this.isEnableIndexForegroundBlur = false
  }

  /**
   * 根据服务状态获取对应颜色
   * @returns 状态对应的颜色值
   */
  private getStatusColor(): ResourceColor {
    switch (this.serviceStatus) {
      case ServiceStatus.UP:
        // 正常 - 绿色
        return '#00C853'
      case ServiceStatus.DOWN:
        // 故障 - 红色
        return '#FF1744'
      case ServiceStatus.MAINTENANCE:
        // 维护 - 黄色/橙色
        return '#FFAB00'
      case ServiceStatus.RETRY:
      default:
      // 加载/重试状态 - 灰色
        return '#9E9E9E'
    }
  }

  /**
   * 获取在线服务状态
   * @description 从 API 获取心跳数据，解析服务状态
   */
  private fetchServiceStatus(): void {
    const httpRequest = http.createHttp()
    const url = 'https://jk.vcck.cn/api/status-page/heartbeat/clashbox'

    httpRequest.request(url, (err: Error, data: http.HttpResponse) => {
      if (!err && typeof data.result === 'string') {
        try {
          const response = JSON.parse(data.result) as HeartbeatResponse
          // 获取 key 为 "8" 的心跳列表
          const heartbeatList8 = response.heartbeatList['8']
          if (heartbeatList8 && heartbeatList8.length > 0) {
            // 取最后一个对象的 status 值
            const lastHeartbeat = heartbeatList8[heartbeatList8.length - 1]
            this.serviceStatus = lastHeartbeat.status as ServiceStatus
            hilog.info(0xFF00, TAG, "服务状态获取成功: %{public}d", this.serviceStatus)
          }
        } catch (parseErr) {
          hilog.error(0xFF00, TAG, "解析服务状态失败: %{public}s", (parseErr as Error).message)
          this.serviceStatus = ServiceStatus.DOWN
        }
      } else {
        hilog.error(0xFF00, TAG, "获取服务状态失败")
        this.serviceStatus = ServiceStatus.DOWN
      }
      httpRequest.destroy()
    })
  }

  /** 清除防抖定时器 */
  private clearDebounceTimer(): void {
    if (this.debounceTimerId !== -1) {
      clearTimeout(this.debounceTimerId)
      this.debounceTimerId = -1
    }
  }

  /**
   * 防抖搜索 - 延迟执行搜索，避免频繁请求
   * @param value 搜索关键词
   */
  private debounceSearch(value: string): void {
    // 清除之前的定时器
    this.clearDebounceTimer()

    // 如果输入为空，直接清空结果
    if (value.length === 0) {
      this.searchText = ''
      this.apps = []
      this.resultApps = []
      return
    }

    // 设置新的定时器
    this.debounceTimerId = setTimeout(async () => {
      await this.searchApps(value)
      this.debounceTimerId = -1
    }, this.DEBOUNCE_DELAY)
  }

  /**
   * 加载已添加的应用列表
   * @returns Promise<AppInfo[]> 应用列表
   */
  private async loadAppsInfo(): Promise<AppInfo[]> {
    // 确定当前域
    const domain = this.appConfig.accessControlMode === 'AcceptSelected' ? 'WHITE' : 'BLACK'
    // 确定排序方式
    const sortBy = this.appConfig.accessControlSort === 'name' ? 'name' : 'time'
    // 直接查询数据库，数据库已处理排序和选中状态
    const appListData = await accessControlRdb.getAppsByDomain(domain, sortBy)

    return appListData
  }

  /**
   * 执行在线搜索应用
   * @param value 搜索关键词
   */
  private async searchApps(value: string): Promise<void> {
    this.searchText = value
    if (value.length > 0) {
      try {
        this.isSearch = true
        const response = await this.getAppList(value)

        if (response.success && response.data) {
          this.resultApps = response.data
          this.apps = await this.convertToAppInfo(this.resultApps)

          this.isSearch = false
          hilog.info(0xFF00, TAG, "搜索成功，获取到 %{public}d 条数据", this.apps.length)
        }
      } catch (error) {
        hilog.error(0xFF00, TAG, "搜索失败: %{public}s", error.message)
      }
    }
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

/** 心跳响应数据结构 */
interface HeartbeatItem {
  status: number
  time: string
  msg: string
  ping: number
}

/** 心跳 API 响应结构 */
interface HeartbeatResponse {
  heartbeatList: Record<string, HeartbeatItem[]>
  uptimeList: Record<string, number>
}
