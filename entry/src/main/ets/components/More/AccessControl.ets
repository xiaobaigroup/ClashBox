import { MoreTop } from "./MoreTopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { universalSearch } from "../../common/utils/SmartSearchUtil"
import { ButtonBuilder, checkoutRowListItem,
  font_primary, KVCustomDialog, toggleRowList } from "../Common/Common"
import { NeedClearMoreStack, PageMargin } from "../../common/breakpoint/BreakPoint"
import { BundleInfo, TAB_CONTENT_TITLE_HEIGHT } from "../../common/entity/Constants"
import { AppConfig, UIConfig } from "../../entryability/AppState"
import { ItemRestriction, SegmentButton, SegmentButtonOptions, SegmentButtonTextItem } from "@kit.ArkUI"
import { KeyValueData } from "./Overwrite/EditArrayConfig"
import { getResourceString } from "../../common/utils/ResourceStringUtil"
import { intl } from "@kit.LocalizationKit"
import { Xb_CapsuleButton, Xb_CircleButton, Xb_FileUtils, Xb_GetResourceString, Xb_ToastUtil } from "xb_components"
import { customAnimationUtil } from "../../common/utils/Animation"
import { EventHub, EventKey } from '../../common/EventHub'

@Builder
export function AccessControlBuilder(name: string, param: Object){
  AccessControl()
}

@Component
export struct AccessControl {

  // page内顶部标题偏移量
  @Consume curYOffset: number
  @Consume needSearch: boolean
  // 是否进入二级界面
  @Consume isSecondary: boolean
  @State isNewApp: boolean = true
  @State currentIndex: number = 0
  @State isShowSheet: boolean = false
  @State isDeleteing: boolean = false
  @State appListData: AppInfo[] = []
  @State nameStringData: string[] = []
  @State lastAppListData: AppInfo[] = []
  @State kvDialogTitle: ResourceStr = ''
  @Consume @Watch('applist') isSearching: boolean
  @Consume @Watch('searchApps') searchText: string
  @StorageLink('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @State keyValueData: KeyValueData = new KeyValueData("")
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 状态栏高度
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @State modeTabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.white_list') }, { text: $r('app.string.blacklist')
    }] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: $r('app.color.container_background'),
    backgroundBlurStyle: BlurStyle.BACKGROUND_THICK,
    textPadding: { top: 5, bottom: 5 },
    fontColor: font_primary,
  })
  @State sortTabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.Name') }, { text: $r('app.string.time')
    }] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: $r('app.color.container_background'),
    backgroundBlurStyle: BlurStyle.BACKGROUND_THICK,
    textPadding: { top: 5, bottom: 5 },
    fontColor: font_primary,
  })
  @State @Watch('onModeChange') modeTabSelectedIndexes: number[] = [1]
  @State @Watch('onSortChange') sortTabSelectedIndexes: number[] = [0]

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        // 标题栏
        MoreTop({
          title: $r('app.string.access_control'),
          name: 'AccessControl',
          enableClick2: true,
          onClick2: () => {
            this.isEnableIndexForegroundBlur = true
            this.isShowSheet = true
          },
          icon2: $r('sys.symbol.dot_grid_2x2'),
        })
        // 控制区
        Column({ space: 10}) {
          Blank().height(TAB_CONTENT_TITLE_HEIGHT - (this.uiConfig.stringDisplayIndex === 0 ? 12 : 6) + (this.widthBp < 2 ? this.topRectHeight : 0))
          // 访问控制开关
          toggleRowList({
            title: $r('app.string.app_access_control'),
            subtitle: $r('app.string.access_control_tips'),
            toggle: () => { this.controlBuilder() }
          })
            .margin({ right: PageMargin(this.widthBp, this.heightBp), left: PageMargin(this.widthBp, this.heightBp) })
            .transition(customAnimationUtil.isScaleTran(0, this.uiConfig))
            .onClick(() => {
              this.appConfig.accessControl = !this.appConfig.accessControl
            })
          // 显示栏
          Row({ space: 10}) {
            Column() {
              Text(`${Xb_GetResourceString($r('app.string.selected'), this)} ${this.nameStringData.length}`)
              Text(this.isDeleteing ? `${Xb_GetResourceString($r('app.string.Edit'), this)}${Xb_GetResourceString($r('app.string.mode'), this)}`
                : this.appConfig.accessControlMode != 'AcceptSelected' ? $r('app.string.white_list_tips') : $r('app.string.blacklist_tips'))
                .maxLines(this.uiConfig.stringDisplayIndex === 0 ? 1 : 2)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize(14)
                .textOverflow({ overflow: this.uiConfig.stringDisplayIndex === 0 ? TextOverflow.Ellipsis : TextOverflow.Clip })
            }
            .width('56%')
            .alignItems(HorizontalAlign.Start)
            if (this.isDeleteing) {
              Xb_CapsuleButton({
                icon: undefined,
                fontSize: 16,
                iconColor: font_primary,
                text: $r('app.string.exit'),
                theBackgroundColor: $r('app.color.settings_container_background'),
                onCheck: () => {
                  this.isDeleteing = false
                  // this.cancelSelected()
                  this.loadAppsInfo()
                }
              })
            }
            Blank()
            if (this.appConfig.accessControl) {
              ButtonBuilder({
                icon: $r('sys.symbol.plus'),
                onCheck: () => {
                  this.addApp()
                }
              })
                .enabled(this.appConfig.accessControl)
              if (this.appListData.length != 0) {
                ButtonBuilder({
                  icon: this.isDeleteing ? $r('sys.symbol.trash_fill') : $r('sys.symbol.square_and_pencil'),
                  onCheck: () => {
                    if (this.isDeleteing) {
                      this.deleteApp()
                    } else {
                      this.isDeleteing = true
                      this.cancelSelected()
                    }
                  }
                })
                  .enabled(this.appConfig.accessControl)
              }
            }
            CheckboxGroup({ group: 'App' })
              .enabled(this.appConfig.accessControl)
              .checkboxShape(CheckBoxShape.CIRCLE)
              .selectedColor(this.icon_emphasize)
              .onChange((itemName: CheckboxGroupResult) => {
                console.info("AccessControl CheckBoxGroup#onChange checkbox group content" + JSON.stringify(itemName))
                this.nameStringData = itemName.name
                if (this.appConfig.accessControlMode == 'AcceptSelected') {
                  // 白名单
                  this.appConfig.accessControlAcceptList = JSON.stringify(itemName.name)
                  console.info("AccessControl CheckBoxGroup#onChange this.appConfig.accessControlAcceptList: " +  this.appConfig.accessControlAcceptList)
                } else {
                  // 黑名单
                  this.appConfig.accessControlRejectList = JSON.stringify(itemName.name)
                  console.info("AccessControl CheckBoxGroup#onChange this.appConfig.accessControlRejectList: " + this.appConfig.accessControlRejectList)
                }
              })
          }.width('100%')
          .backgroundColor($r('app.color.background'))
          .transition(customAnimationUtil.isScaleTran(1, this.uiConfig))
          .padding({ right: PageMargin(this.widthBp, this.heightBp) + 12, left: PageMargin(this.widthBp, this.heightBp) + 12 })
        }
        .hitTestBehavior(HitTestMode.Transparent)
        .width('100%')
        .zIndex(2)
        // .height('100%')
        // 应用列表
        Column() {
          Blank().height(TAB_CONTENT_TITLE_HEIGHT + (this.uiConfig.stringDisplayIndex === 0 ? 112 : 139) + (this.widthBp < 2 ? this.topRectHeight : 0))
          Scroll() {
            List({space: 8}) {
              ForEach(this.appListData, (item: AppInfo, index) => {
                ListItem() {
                  checkoutRowListItem({
                    title: item.name,
                    subtitle: item.package_name,
                    isSelected: item.isSelected,
                    enabledClick: this.appConfig.accessControl
                  })
                }
                .swipeAction({
                  end: {
                    builder: () => { this.swipeActionEnd(index, item) },
                    // 侧滑到一定距离会触发 onAction
                    // onAction: () => {
                    //   animateTo({ duration: 1000 }, () => {
                    //     // 侧滑删除
                    //     this.deleteApp(index)
                    //   })
                    // },
                    // onAction 侧滑距离
                    actionAreaDistance: 56,
                  },
                  edgeEffect: SwipeEdgeEffect.None
                })
                .enabled(this.appConfig.accessControl)
                .transition(customAnimationUtil.isScaleTran(index + 2, this.uiConfig))
                .onClick(() => {
                  const itemData = this.appListData[index]
                  itemData.isSelected = !itemData.isSelected
                  this.appListData.splice(index, 1, itemData)
                })
                .onMouse((event) => {
                  if (event.action == MouseAction.Press && event.button == MouseButton.Right) {
                    this.currentIndex = index
                    this.openDialog(item)
                  }
                })
                .gesture(LongPressGesture()
                  .onAction(() => {
                    this.currentIndex = index
                    this.openDialog(item)
                  }))
              })
            }
            .width('100%')
            .height('100%')
            .contentEndOffset(260)
            .chainAnimation(true)
            .edgeEffect(EdgeEffect.Spring)
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            })
            .padding({ right: PageMargin(this.widthBp, this.heightBp), left: PageMargin(this.widthBp, this.heightBp) })
            .bindSheet($$this.isShowSheet, this.SheetBuilder(), {
              detents: [SheetSize.MEDIUM],
              dragBar: false,
              backgroundColor: $r('app.color.background'),
              keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
              scrollSizeMode: ScrollSizeMode.CONTINUOUS,
              preferType: SheetType.CENTER,
              onWillDismiss: () => {
                this.isShowSheet = false
                this.isEnableIndexForegroundBlur = false
              }
            })
          }
          .edgeEffect(this.uiConfig.isAnimation ? EdgeEffect.Spring : null)
        }
        // .width('100%')
        // .height('100%')
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onShown(() => {
      // 初始化搜索按钮 TODO 暂时关闭搜索
      this.needSearch = false
    })
    .onWillHide(() => {
      this.needSearch = false
      this.isSearching = false
    })
    .onBackPressed(() => {
      if (this.isSearching) {
        this.isSearching = false
        this.searchText = ''
        return true
      }
      if (this.isDeleteing) {
        this.isDeleteing = false
        // this.cancelSelected()
        this.loadAppsInfo()
        return true
      }
      if (NeedClearMoreStack(this.widthBp, this.heightBp)) {
        this.pageInfos.clear()
        this.isSecondary = false
        return false
      } else {
       // this.isSecondary = false
        return false
      }
    })

  }

  kvDialogController = new CustomDialogController({
    builder: KVCustomDialog({
      value: $keyValueData,
      keyPlaceholder: $r('app.string.the_app_name'),
      valuePlaceholder: $r('app.string.package_name'),
      theDialogTitle: this.kvDialogTitle,
      confirm: (value) => {
        // 非空处理
        if (value.key.toString().trim() === '') {
          Xb_ToastUtil.showToast({ message: $r('app.string.appName_isEmpty') })
          return
        }
        if ((value.value as string).trim() === '') {
          Xb_ToastUtil.showToast({ message: $r('app.string.appPackageName_isEmpty') })
          return
        }

        // 关闭背景模糊
        this.isEnableIndexForegroundBlur = false
        console.log(`AccessControl kvCustomdialog 当前value: ${JSON.stringify(value)}`)
        const indexes = this.appListData.findIndex((d) => d.name == value.key)
        console.log(`AccessControl kvCustomdialog 当前indexes序号: ${indexes} 当前currentIndex序号: ${this.currentIndex}`)
        if (this.isNewApp) {
          console.log(`AccessControl kvCustomdialog 窗口为新增`)
          // 应用为新增
          if (indexes === -1 && value.value !== this.getUIContext().getHostContext()!.applicationInfo.name) {
            // 应用名称不存在
            const param: AppInfo = {
              name: value.key,
              package_name: value.value as string,
              time: Date.now(),
              isSelected: false
            }
            this.appListData.push(param)
            // 添加后保存数据
            this.appConfig.accessControlAppInfo = JSON.stringify(this.appListData)
          } else {
            // 应用名称存在
            this.getUIContext().getPromptAction().showToast({ message: $r('app.string.app_already_exist') })
          }

        } else {
          console.log(`AccessControl kvCustomdialog 窗口为非新增`)
          // 应用非新增
          let data = this.appListData[this.currentIndex]
          data.name = value.key
          data.package_name = value.value as string
          this.appListData.splice(this.currentIndex, 1, data)
          // 添加后保存数据
          this.appConfig.accessControlAppInfo = JSON.stringify(this.appListData)
        }
        // 保存后重置数据
        this.keyValueData = new KeyValueData("")
        this.isNewApp = true
      },
      cancel: ()=> {
        // 关闭背景模糊
        this.keyValueData = new KeyValueData("")
        this.isEnableIndexForegroundBlur = false
      },
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      // 1、PRESS_BACK    点击三键back、左滑/右滑、键盘ESC。
      // 2、TOUCH_OUTSIDE    点击遮障层时
      // 3、CLOSE_BUTTON    点击关闭按钮
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        // 点击遮蔽层不响应，防误触
      } else {
        // 完成任务后主动通过dismiss主动关闭对话框
        dismissDialogAction.dismiss()
        // 关闭背景模糊
        this.isEnableIndexForegroundBlur = false
      }
    }
  })

  @Builder
  SheetBuilder() {
    Column({space: 5}) {
      // 模式
      Text($r('app.string.mode'))
      SegmentButton({
        options: this.modeTabOptions,
        selectedIndexes: this.modeTabSelectedIndexes
      })
      // 排序
      Text($r('app.string.sort'))
      SegmentButton({
        options: this.sortTabOptions,
        selectedIndexes: this.sortTabSelectedIndexes
      })
    }
    .padding({ top: 56, bottom: 12, left: 12, right: 12})
    .alignItems(HorizontalAlign.Start)
    // 操作
    Text($r('app.string.operation'))
    Row({space: 7}) {
      Xb_CapsuleButton({
        fontSize: 15,
        icon: undefined,
        buttonHeight: 40,
        iconColor: $r('sys.color.font_primary'),
        theBackgroundColor: $r('app.color.container_background'),
        text: $r('app.string.export_access'),
        onCheck: () => {
          this.exportAccessConfig()
        }
      })
      Xb_CapsuleButton({
        fontSize: 15,
        icon: undefined,
        buttonHeight: 40,
        theBackgroundColor: $r('app.color.container_background'),
        text: $r('app.string.import_access'),
        iconColor: $r('sys.color.font_primary'),
        onCheck: () => {
          this.importAccessConfig()
        }
      })
    }
  }

  @Builder
  controlBuilder() {
    Toggle({ type: ToggleType.Switch, isOn: this.appConfig.accessControl })
      .hitTestBehavior(HitTestMode.None)
      .selectedColor(this.icon_emphasize)
      .onChange((isOn) => {
        this.appConfig.accessControl = isOn
      })
  }

  @Builder
  swipeActionEnd(id: number, item: AppInfo) {
    Row() {
      Xb_CircleButton({
        icon: $r('sys.symbol.trash_fill'),
        iconColor: Color.Red,
        iconBackgroundColor: undefined,
        theBackgroundColor: $r('app.color.container_background'),
        onCheck: () => {
          console.log(`AccessControl 点击 #deleteApp ${id}`)
          // 删除列表行
          this.deleteApp(id, item)
        }
      })
    }
    .height('100%')
    .padding({ left: 12 })
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  aboutToAppear(): void {
    EventHub.on(EventKey.AddAPP, (bundleInfo: BundleInfo) => {
      this.keyValueData = new KeyValueData(bundleInfo?.appName || '', bundleInfo?.bundleName || '')
      this.addApp()
    })
    console.info("AccessControl #aboutToAppear this.appConfig.accessControlRejectList: " + this.appConfig.accessControlRejectList)
    this.loadAppsInfo()
    this.sortTabSelectedIndexes.splice(0, 1, this.appConfig.accessControlSort == 'name' ? 0 : 1)
  }

  aboutToDisappear(): void {
    this.appConfig.accessControlAppInfo = JSON.stringify(this.appListData)
  }

  addApp() {
    this.kvDialogTitle = getResourceString($r('app.string.add_app'), this)
    this.kvDialogController.open()
  }

  loadAppsInfo() {
    try {
      this.appListData = JSON.parse(this.appConfig.accessControlAppInfo ?? "[]")
      if (this.appConfig.accessControlMode == 'AcceptSelected') {
        // 白名单
        this.modeTabSelectedIndexes.splice(0, 1, 0)
        const packagenameStringData: string[] = JSON.parse(this.appConfig.accessControlAcceptList ?? "[]")
        console.log(`AccessControl #loadAppsInfo ${JSON.stringify(packagenameStringData)}`)
        this.selectedApp(packagenameStringData)
      } else {
        // 黑名单
        this.modeTabSelectedIndexes.splice(0, 1, 1)
        const packagenameStringData = JSON.parse(this.appConfig.accessControlRejectList ?? "[]") as string[]
        console.log(`AccessControl #loadAppsInfo ${JSON.stringify(packagenameStringData)}`)
        this.selectedApp(packagenameStringData)
      }
    } catch (e) {
      console.error(`AccessControl 错误: ${e}`)
    }
  }

  deleteApp(index?: number, item?: AppInfo) {
    console.log(`AccessControl 进入删除 #deleteApp ${index}`)
    console.log(`AccessControl #deleteApp 前 this.appConfig.accessControlAcceptList值：${this.appConfig.accessControlRejectList}`)
    let rejectString = JSON.parse(this.appConfig.accessControlRejectList ?? "[]") as string[]
    let acceptString = JSON.parse(this.appConfig.accessControlAcceptList ?? "[]") as string[]
    if (index != undefined && item != undefined) {
      console.log(`AccessControl #deleteApp 前 this.appListData值：${JSON.stringify(this.appListData)}`)
      this.appListData.splice(index, 1)
      console.log(`AccessControl #deleteApp 后 this.appListData值：${JSON.stringify(this.appListData)}`)
      this.appConfig.accessControlAppInfo = JSON.stringify(this.appListData)
      console.log(`AccessControl #deleteApp ${index}`)
      // 黑名单
      rejectString = rejectString.filter(stringData => stringData != item.package_name)
      // 白名单
      acceptString = acceptString.filter(stringData => stringData != item.package_name)
    } else {
      // 批量删除
      const deleteSet = new Set(this.nameStringData)
      this.appListData = this.appListData.filter(app => !deleteSet.has(app.package_name))
      this.appConfig.accessControlAppInfo = JSON.stringify(this.appListData)
      // 黑名单
      rejectString = rejectString.filter(packageName => !deleteSet.has(packageName))
      // 白名单
      acceptString = acceptString.filter(packageName => !deleteSet.has(packageName))
    }
    this.appConfig.accessControlRejectList = JSON.stringify(rejectString)
    this.appConfig.accessControlAcceptList = JSON.stringify(acceptString)
    console.log(`AccessControl #deleteApp 后 this.appConfig.accessControlAcceptList值：${this.appConfig.accessControlRejectList}`)
  }

  // 取消所有选中
  cancelSelected() {
    this.appListData = this.appListData.map((app): AppInfo => ({
      name: app.name,
      package_name: app.package_name,
      time: app.time,
      isSelected: false
    }))
  }

  selectedApp(packageNames: string[]) {
    const selectedPackagesSet = new Set(packageNames)
    this.appListData = this.appListData.map((app): AppInfo => ({
      name: app.name,
      package_name: app.package_name,
      time: app.time,
      isSelected: selectedPackagesSet.has(app.package_name)
    }))
    console.log(`AccessControl #selectedApp 黑 列表数据：${JSON.stringify(this.appListData)} 包名数据：${JSON.stringify(packageNames)}`)
  }

  // 导出配置
  exportAccessConfig() {
    const config: AccessConfig = {
      enable: this.appConfig.accessControl,
      mode: this.appConfig.accessControlMode,
      sort: this.appConfig.accessControlSort,
      appList: this.appConfig.accessControlAppInfo,
      acceptList: this.appConfig.accessControlAcceptList,
      rejectList: this.appConfig.accessControlRejectList
    }
    Xb_FileUtils.exportDataByFile<AccessConfig>('ClashBox AccessControlConfig', config, this.getUIContext().getHostContext()!).then(() => {
      Xb_ToastUtil.showToast({ message: $r('app.string.export_success') })
      console.log(`AccessControl 配置文件导出成功`)
    }).catch(() => {
      Xb_ToastUtil.showToast({ message: $r('app.string.export_failed') })
      console.error(`AccessControl 配置文件导出失败`)
    })
  }

  // 导入配置
  async importAccessConfig() {
    let config: AccessConfig | null
    Xb_FileUtils.openFile(this.getUIContext().getHostContext()!).then(async (uri) => {
      if (uri) {
        config = await Xb_FileUtils.importDataByFile<AccessConfig>(uri)
        if (config) {
          this.appConfig.accessControl = config.enable
          this.appConfig.accessControlMode = config.mode
          this.appConfig.accessControlSort = config.sort as "name" | "time"
          this.appConfig.accessControlAppInfo = config.appList
          this.appConfig.accessControlAcceptList = config.acceptList
          this.appConfig.accessControlRejectList = config.rejectList
          this.loadAppsInfo()
          Xb_ToastUtil.showToast({ message: $r('app.string.import_success') })
        } else {
          console.error(`AccessControl 配置解析失败`)
          Xb_ToastUtil.showToast({ message: Xb_GetResourceString($r('app.string.import_failed'), this) + '配置解析失败' })
        }
      } else {
        Xb_ToastUtil.showToast({ message: Xb_GetResourceString($r('app.string.import_failed'), this) + '文件uri不存在' })
        console.error(`AccessControl 文件uri不存在`)
      }
    })
  }

  onModeChange() {
    console.log(`AccessControl 运行 #onModeChange nameStringData值：${JSON.stringify(this.nameStringData)}`)
    console.log(`AccessControl 运行 #onModeChange-实际 nameStringData[0]值：${JSON.stringify(this.nameStringData[0])}`)
    if (this.modeTabSelectedIndexes[0] == 0) {
      // 白名单
      this.appConfig.accessControlMode = 'AcceptSelected'
    } else {
      // 黑名单
      this.appConfig.accessControlMode = 'RejectSelected'
    }
    if (!this.nameStringData[0])
      return
    if (this.modeTabSelectedIndexes[0] == 0) {
      // 白名单
      console.log(`AccessControl #onModeChange 模式：${ this.appConfig.accessControlMode}`)
      this.appConfig.accessControlAcceptList = JSON.stringify(this.nameStringData)
    } else {
      // 黑名单
      console.log(`AccessControl #onModeChange 模式：${ this.appConfig.accessControlMode}`)
      this.appConfig.accessControlRejectList = JSON.stringify(this.nameStringData)
    }
  }

  onSortChange() {
    if (this.sortTabSelectedIndexes[0] == 0) {
      // 名称
      this.appConfig.accessControlSort = 'name'
      this.appListData.sort((a, b) => nameSortCollator.compare(a.name, b.name))
    } else {
      // 时间
      this.appConfig.accessControlSort = 'time'
      this.appListData.sort((a, b) => {
        return a.time - b.time
      })
    }
  }

  openDialog(item: AppInfo) {
    const kvData: KeyValueData = new KeyValueData(item.name, item.package_name)
    this.keyValueData = kvData
    this.kvDialogTitle = getResourceString($r('app.string.edit_app'), this)
    this.isNewApp = false
    this.kvDialogController.open()
  }

  applist() {
    if (this.isSearching) {
      if (this.searchText === '') {
        return
      }
    } else {
      // 如果不在搜索，还原应用列表
      this.appListData = this.lastAppListData
    }
  }

  /**应用搜索*/
  searchApps(keyword: string) {
    hilog.info(0xFF00, 'AccessControl', `#smartsearchLogs 搜索文本：${this.searchText}`)
    keyword = this.searchText
    if (keyword !== '') {
      hilog.info(0xFF00, 'AccessControl', `#smartsearchLogs 开始搜索，搜索文本：${this.searchText}`)
      this.appListData = universalSearch(this.appListData, keyword, {
        fields: ['name', 'package_name']
      })
    } else {
      hilog.info(0xFF00, 'AccessControl', `#smartsearchLogs 空搜索文本：${this.searchText}`)
      // 空文本恢复数据
      this.appListData = this.lastAppListData
    }
  }

}

const nameSortCollator = new intl.Collator("zh-CN")

interface AppInfo {
  name: string
  package_name: string
  time: number
  icon?: Resource,
  isSelected: boolean
}

interface AccessConfig {
  enable: boolean
  mode: string
  sort: string
  appList: string
  acceptList: string
  rejectList: string
}