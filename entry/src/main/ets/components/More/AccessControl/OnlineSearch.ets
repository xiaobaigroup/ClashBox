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

@Builder
export function OnlineSearchBuilder(name: string, param: Object) {
  OnlineSearch()
}

const TAG = "OnlineSearch"

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
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  // 临时的搜索结果列表 -> 用于刷新列表使用的存储一下减少请求次数
  private resultApps: SearchAppItem[] = []
  // 防抖定时器ID
  private debounceTimerId: number = -1
  // 防抖延迟时间（毫秒）
  private readonly DEBOUNCE_DELAY: number = 400
  // 待删除的应用信息
  private pendingDeleteApp: SearchAppInfo | null = null
  /* 是否开启 `Index` 页面的前景模糊 */

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
        Xb_ToastUtil.showToast({ message: '删除成功', duration: 1000 })

        // 刷新列表
        this.apps = await this.convertToAppInfo(this.resultApps)
        EventHub.sendEvent(EventKey.ReLoadAccessControl)
      } catch (error) {
        hilog.error(0xFF00, TAG, "删除失败: %{public}s", error.message)
        Xb_ToastUtil.showToast({ message: '删除失败' })
      }
    }
    this.pendingDeleteApp = null
    this.isEnableIndexForegroundBlur = false
  }

  /** 组件销毁时清除防抖定时器 */
  aboutToDisappear(): void {
    this.clearDebounceTimer()
  }

  build() {
    NavDestination() {
      TopBuilder({
        showBackButton: true,
        title: $r('app.string.online_search'),
        pathStack: this.addPageInfos
      })

      Column() {
        // TODO 建议修改 placeholder 的内容，现在执行逻辑是 回车 和 用户输入停止一段时间 都会触发搜索
        Search({ value: this.searchText, placeholder: $r('app.string.enter_search') })
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
        } else {
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
                  Xb_ToastUtil.showToast({ message: '添加成功', duration: 1000 })

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