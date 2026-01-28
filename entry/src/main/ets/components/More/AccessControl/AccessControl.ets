import { MoreTop } from '../MoreTopBuilder'
import { hilog } from '@kit.PerformanceAnalysisKit'
import {
  ButtonBuilder,
  checkoutRowListItem,
  font_primary,
  icon_primary,
  KVCustomDialog,
  toggleRowList
} from '../../Common/Common'
import { NeedClearMoreStack, PageMargin } from '../../../common/breakpoint/BreakPoint'
import {
  BundleInfo,
  TAB_CONTENT_TITLE_HEIGHT
} from '../../../common/entity/Constants'
import { AppConfig, UIConfig } from '../../../entryability/AppState'
import { ItemRestriction, LengthMetrics, SegmentButton, SegmentButtonOptions, SegmentButtonTextItem } from '@kit.ArkUI'
import { KeyValueData } from '../Overwrite/EditArrayConfig'
import { getResourceString } from '../../../common/utils/ResourceStringUtil'
import {
  Xb_CapsuleButton,
  Xb_CircleButton,
  Xb_FileUtils,
  Xb_GetResourceString,
  Xb_ImageUtils,
  Xb_KVdbUtil,
  Xb_PreferenceUtil,
  Xb_ToastUtil
} from 'xb_components'
import { customAnimationUtil } from '../../../common/utils/Animation'
import { EventHub, EventKey } from '../../../common/EventHub'
import { AccessControlCompatibleMerger } from '../../../common/utils/AccessControlCompatibleUtil'
import {
  AccessConfigExport,
  accessControlRdb,
  AppInfo,
  AppInfoConfig,
  AppInfoRdb,
  ListType
} from '../../../common/datasources/AccessControlRdb'
import { JSON } from '@kit.ArkTS'
import { AddAppListComponent } from './AddAppListComponent'

@Builder
export function AccessControlBuilder(name: string, param: Object) {
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
  @State isAddSelect: boolean = false
  @State isShowSheet: boolean = false
  @State isEditMode: boolean = false
  @State initialized: boolean = false
  @State appListData: AppInfo[] = []
  @State selectedPkgNames: Set<string> = new Set<string>()
  @State selectedDeletePkgNames: Set<string> = new Set<string>()
  @State kvDialogTitle: ResourceStr = ''
  @Consume @Watch('onSearchAppList') isSearching: boolean
  @Consume @Watch('searchApps') searchText: string
  @StorageLink('OnlineSearchPageInfos') addPageInfos: NavPathStack = new NavPathStack()
  @StorageLink('NavPathStack') pageInfos: NavPathStack = new NavPathStack()
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @State keyValueData: KeyValueData = new KeyValueData("")
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  // 高度断点
  @StorageLink('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 状态栏高度
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @State modeTabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.white_list') }, {
      text: $r('app.string.blacklist')
    }] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: $r('app.color.container_background'),
    backgroundBlurStyle: BlurStyle.BACKGROUND_THICK,
    textPadding: { top: 5, bottom: 5 },
    fontColor: font_primary,
  })
  @State sortTabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.Name') }, {
      text: $r('app.string.time')
    }] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: $r('app.color.container_background'),
    backgroundBlurStyle: BlurStyle.BACKGROUND_THICK,
    textPadding: { top: 5, bottom: 5 },
    fontColor: font_primary,
  })
  @State modeTabSelectedIndexes: number[] = [this.appConfig.accessControlMode == 'AcceptSelected' ? 0 : 1]
  @State sortTabSelectedIndexes: number[] = [this.appConfig.accessControlSort == 'name' ? 0 : 1]

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        // 标题栏
        MoreTop({
          title: $r('app.string.access_control'),
          name: 'AccessControl',
          enableClick2: true,
          onClick2: () => {
            this.isAddSelect = false
            this.isEnableIndexForegroundBlur = true
            this.isShowSheet = true
          },
          icon2: $r('sys.symbol.dot_grid_2x2'),
        })
        // 控制区
        Column({ space: 10 }) {
          Blank()
            .height(TAB_CONTENT_TITLE_HEIGHT - (this.uiConfig.stringDisplayIndex === 0 ? 12 : 6) +
              (this.widthBp < 2 ? this.topRectHeight : 0))
          // 访问控制开关
          toggleRowList({
            title: $r('app.string.app_access_control'),
            subtitle: $r('app.string.access_control_tips'),
            toggle: () => {
              this.controlBuilder()
            }
          })
            .margin({ right: PageMargin(this.widthBp, this.heightBp), left: PageMargin(this.widthBp, this.heightBp) })
            .transition(customAnimationUtil.isScaleTran(0, this.uiConfig))
            .onClick(() => {
              this.appConfig.accessControl = !this.appConfig.accessControl
            })
          // 显示栏
          Flex({
            direction: FlexDirection.Row,
            space: { main: LengthMetrics.vp(10) },
            alignItems: ItemAlign.Center
          }) {
            Column() {
              Text(`${Xb_GetResourceString($r('app.string.selected'), this)} ${this.isEditMode ?
                this.selectedDeletePkgNames.size : this.selectedPkgNames.size}`)
              Text(this.isEditMode ?
                `${Xb_GetResourceString($r('app.string.Edit'), this)}${Xb_GetResourceString($r('app.string.mode'),
                  this)}`
                : this.appConfig.accessControlMode != 'AcceptSelected' ? $r('app.string.white_list_tips') :
                  $r('app.string.blacklist_tips'))
                .maxLines(this.uiConfig.stringDisplayIndex === 0 ? 1 : 2)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize(14)
                .textOverflow({
                  overflow: this.uiConfig.stringDisplayIndex === 0 ? TextOverflow.Ellipsis : TextOverflow.Clip
                })
            }
            .alignItems(HorizontalAlign.Start)

            if (this.isEditMode) {
              Xb_CapsuleButton({
                icon: undefined,
                fontSize: 16,
                iconColor: font_primary,
                text: $r('app.string.exit'),
                theBackgroundColor: $r('app.color.settings_container_background'),
                onCheck: () => {
                  this.isEditMode = false
                  this.selectedDeletePkgNames.clear()
                  this.loadAppsInfo()
                }
              })
            }
            Blank()
            if (this.appConfig.accessControl) {
              if (!this.isEditMode) {
                ButtonBuilder({
                  icon: $r('sys.symbol.plus'),
                  onCheck: () => {
                    this.isAddSelect = true
                    this.isEnableIndexForegroundBlur = true
                    this.isShowSheet = true
                  }
                })
                  .enabled(this.appConfig.accessControl)
                  .transition(customAnimationUtil.isScaleTranIcon(10, this.uiConfig))
              }
              if (this.appListData.length != 0) {
                ButtonBuilder({
                  icon: this.isEditMode ? $r('sys.symbol.trash_fill') : $r('sys.symbol.square_and_pencil'),
                  onCheck: () => {
                    if (this.isEditMode) {
                      this.deleteApp()
                    } else {
                      this.isEditMode = true
                    }
                  }
                })
                  .enabled(this.appConfig.accessControl)
                  .transition(customAnimationUtil.isScaleTranIcon(10, this.uiConfig))
              }
              SymbolGlyph(this.getGroupSymbol())
                .fontSize(24)
                .fontColor([this.selectedPkgNames.size == 0 ||
                  (this.isEditMode && this.selectedDeletePkgNames.size == 0) ? icon_primary : this.icon_emphasize])
                .transition(customAnimationUtil.isScaleTranIcon(10, this.uiConfig))
                .onClick(() => {
                  if (this.initialized) {
                    if (this.isEditMode) {
                      // --- 处理删除模式的逻辑 ---
                      if (this.selectedDeletePkgNames.size == 0) {
                        // 如果当前没选中任何删除项 -> 全选
                        this.selectedDeletePkgNames = new Set(
                          this.appListData.map(a => a.package_name)
                        );
                        console.debug(`Select 删除选中数量: ${this.selectedDeletePkgNames.size}`);
                        this.loadAppsInfo();
                      } else {
                        // 如果当前已经选中了删除项 -> 全不选
                        this.selectedDeletePkgNames.clear();
                        this.loadAppsInfo();
                      }
                    } else {
                      // --- 处理普通模式的逻辑 ---
                      if (this.selectedPkgNames.size == 0) {
                        // 如果当前没选中任何应用 -> 全选
                        this.selectApps(this.appListData.map(a => a.package_name));
                      } else {
                        // 如果当前已经选中了应用 -> 全不选
                        this.cancelTotalSelected();
                      }
                    }
                  }
                })
            }
          }.width('100%')
          .backgroundColor($r('app.color.background'))
          .transition(customAnimationUtil.isScaleTran(1, this.uiConfig))
          .padding({
            right: PageMargin(this.widthBp, this.heightBp) + 12,
            left: PageMargin(this.widthBp, this.heightBp) + 12
          })
        }
        .hitTestBehavior(HitTestMode.Transparent)
        .width('100%')
        .zIndex(2)

        // 应用列表
        Column() {
          Blank()
            .height(TAB_CONTENT_TITLE_HEIGHT + (this.uiConfig.stringDisplayIndex === 0 ? 112 : 139) +
              (this.widthBp < 2 ? this.topRectHeight : 0))
          Scroll() {
            List({ space: 8 }) {
              ForEach(this.appListData, (item: AppInfo, index) => {
                ListItem() {
                  checkoutRowListItem({
                    icon: Xb_ImageUtils.uint8ArrayToPixelMap(item.iconUintArr) || $r('app.media.box_cat_round'),
                    title: item.name,
                    subtitle: item.package_name,
                    endSymbol: this.getListItemEndSymbol(item),
                    isSelected: this.isEditMode ? this.selectedDeletePkgNames.has(item.package_name) :
                      this.selectedPkgNames.has(item.package_name),
                    enabledClick: this.appConfig.accessControl
                  })
                }
                .swipeAction({
                  end: {
                    builder: () => {
                      this.swipeActionEnd(index, item)
                    },
                    actionAreaDistance: 56,
                  },
                  edgeEffect: SwipeEdgeEffect.None
                })
                .enabled(this.appConfig.accessControl)
                .transition(customAnimationUtil.isScaleTran(index + 2, this.uiConfig))
                .onClick(async () => {
                  const itemData = this.appListData[index]
                  itemData.isSelected = !itemData.isSelected
                  this.appListData.splice(index, 1, itemData)
                  if (this.isEditMode) {
                    if (this.selectedDeletePkgNames.has(item.package_name)) {
                      // 取消：移除列表
                      this.selectedDeletePkgNames.delete(item.package_name)
                    } else {
                      // 选中：加入列表
                      this.selectedDeletePkgNames.add(item.package_name)
                    }
                  } else {
                    // 选中或取消选中，更新数据库
                    const domain = this.appConfig.accessControlMode === 'AcceptSelected' ? 'WHITE' : 'BLACK'
                    const success = await accessControlRdb.toggleSelection(item.package_name, domain)
                    if (success) {
                      this.loadAppsInfo().then(() => {
                        console.debug(`AccessControl #onClick ${item.name}: ${item.isSelected}`)
                        // 更新全选复选框列表
                        if (this.selectedPkgNames.has(item.package_name)) {
                          // 取消：移除列表
                          this.selectedPkgNames.delete(item.package_name)
                        } else {
                          // 选中：加入列表
                          this.selectedPkgNames.add(item.package_name)
                        }
                      })
                    } else {
                      const msg = this.appConfig.accessControlMode === 'AcceptSelected'
                        ? $r('app.string.access_control_limit_msg_white')
                        : $r('app.string.access_control_limit_msg_black')
                      Xb_ToastUtil.showToast({ message: msg })
                    }
                  }
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
              }, /*(app: AppInfo) => app.package_name*/) // ??? 不自定义就能刷新列表是吧
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
          }
          .edgeEffect(this.uiConfig.isAnimation ? EdgeEffect.Spring : null)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onShown(() => {
      // 初始化搜索按钮
      this.needSearch = true
    })
    .onWillHide(() => {
      this.needSearch = false
      this.isSearching = false
      this.searchText = ''
    })
    .onBackPressed(() => {
      if (this.isSearching) {
        this.isSearching = false
        this.searchText = ''
        return true
      }
      if (this.isEditMode) {
        this.isEditMode = false
        this.loadAppsInfo()
        return true
      }
      if (NeedClearMoreStack(this.widthBp, this.heightBp)) {
        this.pageInfos.clear()
        this.isSecondary = false
        return false
      } else {
        return false
      }
    })
    .bindSheet($$this.isShowSheet, this.SheetBuilder(), {
      detents: [SheetSize.MEDIUM, SheetSize.LARGE],
      dragBar: false,
      backgroundColor: $r('app.color.background'),
      keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
      scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      preferType: SheetType.CENTER,
      onWillDismiss: () => {
        this.isShowSheet = false
        this.isEnableIndexForegroundBlur = false
        this.addPageInfos.clear()
      },
      onWillSpringBackWhenDismiss: () => {
      } // 注册回调，防止反向回弹
    })
  }

  kvDialogController = new CustomDialogController({
    builder: KVCustomDialog({
      type: "AccessControl",
      value: $keyValueData,
      keyPlaceholder: $r('app.string.the_app_name'),
      valuePlaceholder: $r('app.string.package_name'),
      theDialogTitle: this.kvDialogTitle,
      confirm: async (value) => {
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
        if (!this.isShowSheet) {
          this.isEnableIndexForegroundBlur = false
        }
        await this.saveApp(value)
        // 保存后重置弹窗状态
        this.keyValueData = new KeyValueData("")
        this.isNewApp = true
      },
      cancel: () => {
        // 关闭背景模糊
        this.keyValueData = new KeyValueData("")
        if (!this.isShowSheet) {
          this.isEnableIndexForegroundBlur = false
        }
      },
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        // 点击遮蔽层不响应，防误触
      } else {
        dismissDialogAction.dismiss()
        if (!this.isShowSheet) {
          this.isEnableIndexForegroundBlur = false
        }
      }
    }
  })

  @Builder
  SheetBuilder() {
    if (this.isAddSelect) {
      // 添加
      AddAppListComponent({
        isShowSheet: this.isShowSheet,
        addAppEvent: () => {
          // 这里通过箭头函数的特性将 this 指向 AccessControl 组件
          this.addApp()
        }
      })
    } else {
      // 操作
      this.OptionBuilder()
    }
  }

  @Builder
  OptionBuilder() {
    Column({ space: 5 }) {
      // 模式
      Text($r('app.string.mode'))
      SegmentButton({
        options: this.modeTabOptions,
        selectedIndexes: this.modeTabSelectedIndexes,
        onItemClicked: (tab) => {
          if (tab == 0) {
            this.appConfig.accessControlMode = 'AcceptSelected'
          } else {
            this.appConfig.accessControlMode = 'RejectSelected'
          }
          this.loadAppsInfo().then(() => {
            this.selectedPkgNames = new Set(
              this.appListData
                .filter(a => a.isSelected)
                .map(a => a.package_name)
            )
          })
        }
      })
      // 排序
      Text($r('app.string.sort'))
      SegmentButton({
        options: this.sortTabOptions,
        selectedIndexes: this.sortTabSelectedIndexes,
        onItemClicked: (tab) => {
          if (tab == 0) {
            this.appConfig.accessControlSort = 'name'
          } else {
            this.appConfig.accessControlSort = 'time'
          }
          this.loadAppsInfo()
        }
      })
      // 操作
      Text($r('app.string.operation'))
      Row({ space: 7 }) {
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
        Xb_CapsuleButton({
          fontSize: 15,
          icon: undefined,
          buttonHeight: 40,
          theBackgroundColor: $r('app.color.container_background'),
          text: $r('app.string.delete_old_data'),
          iconColor: $r('sys.color.font_primary'),
          onCheck: async () => {
            // 数据迁移成功后，可以清理旧数据以节省空间
            await Xb_PreferenceUtil.delete('access_control_apps')
            await Xb_KVdbUtil.deleteEntriesByPrefix('accept_')
            await Xb_KVdbUtil.deleteEntriesByPrefix('reject_')
            Xb_ToastUtil.showToast({ message: $r('app.string.old_data_cleared_success') })
          }
        })
      }
    }
    .padding({
      top: 56,
      bottom: 12,
      left: 12,
      right: 12
    })
    .alignItems(HorizontalAlign.Start)
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
      // 复制
      Xb_CircleButton({
        icon: $r('sys.symbol.doc_text_on_doc_text'),
        iconBackgroundColor: undefined,
        theBackgroundColor: $r('app.color.container_background'),
        onCheck: () => {
          const domain = this.appConfig.accessControlMode === 'AcceptSelected' ? 'WHITE' : 'BLACK'
          accessControlRdb.copyToOppositeDomain(item.package_name, domain).then(() => {
            // TODO 验证 %s 的占位符是否正确
            const msgRes = domain == 'WHITE' ? $r('app.string.copy_to_blacklist', item.name) :
              $r('app.string.copy_to_whitelist', item.name)
            Xb_ToastUtil.showToast({ message: msgRes })
          }).catch((err: Error) => {
            Xb_ToastUtil.showToast({ message: err.message })
          })
        }
      })
        .margin({ right: 6 })
      // 移动
      Xb_CircleButton({
        icon: $r('sys.symbol.arrow_left_arrow_right'),
        iconBackgroundColor: undefined,
        theBackgroundColor: $r('app.color.container_background'),
        onCheck: () => {
          const domain = this.appConfig.accessControlMode === 'AcceptSelected' ? 'WHITE' : 'BLACK'
          accessControlRdb.moveToOppositeDomain(item.package_name, domain).then(() => {
            this.loadAppsInfo()
            // TODO 验证 %s 的占位符是否正确
            const msgRes = domain == 'WHITE' ? $r('app.string.move_to_blacklist', item.name) :
              $r('app.string.move_to_whitelist', item.name)
            Xb_ToastUtil.showToast({ message: msgRes })
          }).catch((err: Error) => {
            Xb_ToastUtil.showToast({ message: err.message })
          })
        }
      })
        .margin({ right: 6 })
      // 删除
      Xb_CircleButton({
        icon: $r('sys.symbol.trash_fill'),
        iconColor: Color.Red,
        iconBackgroundColor: undefined,
        theBackgroundColor: $r('app.color.container_background'),
        onCheck: () => {
          console.log(`AccessControl 点击 #deleteApp ${id}`)
          this.selectedPkgNames.add(item.package_name)
          this.deleteApp(id, item)
        }
      })
    }
    .height('100%')
    .padding({ left: 12 })
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  async aboutToAppear(): Promise<void> {
    this.resisterEvent()

    this.loadAppsInfo().then(() => {
      this.selectedPkgNames = new Set(
        this.appListData
          .filter(a => a.isSelected)
          .map(a => a.package_name)
      )
      this.initialized = true
      console.debug(`AccessControl #aboutToAppear 访问控制页面数据加载完成: ${this.initialized}`)
    })
  }

  aboutToDisappear(): void {
    // TODO AddAPP 这个事件关闭了可能分享包名后续逻辑会出问题(待验证的优化内容

    EventHub.off(EventKey.ReLoadAccessControl)
  }

  private resisterEvent() {
    // 添加App事件
    EventHub.on(EventKey.AddAPP, (bundleInfo: BundleInfo) => {
      this.keyValueData =
        new KeyValueData(bundleInfo?.appName || '', bundleInfo?.bundleName || '', bundleInfo?.iconUintArr)
      this.addApp()
    })

    // 刷新访问控制数据
    EventHub.on(EventKey.ReLoadAccessControl, () => {
      this.loadAppsInfo().then(() => {
        this.selectedPkgNames = new Set(
          this.appListData
            .filter(a => a.isSelected)
            .map(a => a.package_name)
        )
        this.initialized = true
        console.debug(`AccessControl #aboutToAppear 访问控制页面数据加载完成: ${this.initialized}`)
      })
    })
  }

  getGroupSymbol() {
    // 根据模式获取当前选中的数量
    const size = this.isEditMode ? this.selectedDeletePkgNames.size : this.selectedPkgNames.size
    return size === this.appListData.length && this.appListData.length !== 0 ? $r('sys.symbol.checkmark_circle_fill_1')
      : size == 0 ? $r('sys.symbol.ohos_circle')
        : $r('sys.symbol.minus_circle_fill')
  }

  getListItemEndSymbol(item: AppInfo) {
    const status = this.isEditMode ? this.selectedDeletePkgNames.has(item.package_name) :
      this.selectedPkgNames.has(item.package_name)
    return status ? $r('sys.symbol.checkmark_circle_fill_1') : $r('sys.symbol.checkmark_circle')
  }

  addApp() {
    this.kvDialogTitle = getResourceString($r('app.string.add_app'), this)
    this.kvDialogController.open()
    this.isNewApp = true
  }

  /**
   * 保存（新增或编辑）应用
   */
  async saveApp(value: KeyValueData) {
    try {
      const newPackageName = (value.value as string).trim();
      const newAppName = value.key.toString().trim();
      const iconUintArr = value.iconUintArr

      // 校验
      if (!newPackageName || !newAppName) {
        Xb_ToastUtil.showToast({ message: $r('app.string.input_complete_info') })
        return
      }
      // 业务规则检查：不能添加自身
      if (newPackageName === this.getUIContext().getHostContext()!.applicationInfo.name) {
        console.debug("AccessControl 不能添加当前应用自身到控制列表");
        Xb_ToastUtil.showToast({ message: $r('app.string.cannot_add_self') })
        return;
      }

      if (this.isNewApp) {
        // --- 新增逻辑 ---
        // 检查包名是否已存在于当前UI列表中
        if (this.appListData.some(app => app.package_name === newPackageName)) {
          Xb_ToastUtil.showToast({ message: $r('app.string.app_already_exist') })
          return;
        }
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
        // --- 编辑逻辑 ---
        const originalPkg = this.appListData[this.currentIndex].package_name
        // 检查新的包名是否与当前UI列表中“其他”应用冲突
        if (this.appListData.some(app => app.package_name === newPackageName && app.package_name !== originalPkg)) {
          Xb_ToastUtil.showToast({ message: '应用包名已经存在' })
          return
        }

        const newApp: AppInfo = {
          name: newAppName,
          package_name: newPackageName,
          iconUintArr,
          time: Date.now(),
          isSelected: this.appListData[this.currentIndex].isSelected // 保持当前选中状态
        }
        // 刷新对应列表UI
        console.debug(`AccessControl 当前编辑序号：${this.currentIndex} 图标长度：${this.appListData[this.currentIndex].iconUintArr?.length}`);
        this.appListData.splice(this.currentIndex, 1, newApp)
        console.debug(`AccessControl 序号：${this.currentIndex} 图标长度：${this.appListData[this.currentIndex].iconUintArr?.length}`);
        // 调用数据库更新，会自动同步黑白名单中的所有记录
        await accessControlRdb.updateAppBasicInfo(originalPkg, newApp)
      }

      Xb_ToastUtil.showToast({
        message: this.isNewApp ? $r('app.string.add_success') : $r('app.string.modify_success')
      })

      // 列表重加载
      if (this.isNewApp) {
        await this.loadAppsInfo()
      }

      this.keyValueData = new KeyValueData("")
      this.isNewApp = true
      this.kvDialogController.close()

    } catch (error) {
      console.error('AccessControl saveApp 失败:', error)
      Xb_ToastUtil.showToast({ message: $r('app.string.save_failed') })
    }
  }

  /**
   * 加载应用列表（从数据库）
   */
  async loadAppsInfo(desIndex?: number) {
    try {
      // 确定当前域
      const domain = this.appConfig.accessControlMode === 'AcceptSelected' ? 'WHITE' : 'BLACK'
      // 确定排序方式
      const sortBy = this.appConfig.accessControlSort === 'name' ? 'name' : 'time'
      // 直接查询数据库，数据库已处理排序和选中状态
      let rawApps = await accessControlRdb.getAppsByDomain(domain, sortBy)
      console.debug(`[AccessControl] 原始数据加载完成，共 ${rawApps.length} 条, ${JSON.stringify(rawApps.map(item => item.isSelected))}`)
      rawApps.forEach((app, index) => {
        // 只打印前 5 条，防止控制台刷屏
        if (index < 5) {
          console.debug(`AccessControl [DEBUG App ${index}] 包名: ${app.package_name} 状态：${app.isSelected}`)
          if (app.iconUintArr) {
            console.debug(`AccessControl [DEBUG App ${index}] 图标数据存在，长度: ${app.iconUintArr.length}, 类型: ${typeof app.iconUintArr}`)
            // 如果图标数组长度为 0，将其强制置为 undefined
            if (app.iconUintArr.length === 0) {
              console.warn(`AccessControl [DEBUG App ${index}] 警告：检测到空图标数组，已强制置空以防止闪退！`)
              app.iconUintArr = undefined
            }
          } else {
            console.log(`AccessControl [DEBUG App ${index}] 图标数据为 null 或 undefined`)
          }
        } else {
          // 简单遍历检查是否有空数组
          if (app.iconUintArr && app.iconUintArr.length === 0) {
            console.warn(`[AccessControl] 警告：发现第 ${index} 条数据 (${app.package_name}) 包含空图标数组`)
            app.iconUintArr = undefined
          }
        }
      })
      this.appListData = rawApps
      console.debug(`AccessControl #loadAppsInfo 数据处理完毕`)
    } catch (e) {
      console.error(`AccessControl loadAppsInfo 错误: ${JSON.stringify(e)}`)
    }
  }

  /**
   * 删除应用
   */
  async deleteApp(index?: number, item?: AppInfo) {
    const domain = this.appConfig.accessControlMode === 'AcceptSelected' ? 'WHITE' : 'BLACK'
    const size = `${this.selectedDeletePkgNames.size}`
    const mode = index != undefined && item != undefined
    try {
      Xb_ToastUtil.showAlertDialog({
        title: mode ? $r('app.string.delete_app_confirm') : $r('app.string.delete_apps_confirm', size),
        message: '',
        primaryButton: {
          value: $r('app.string.Cancel'),
          action: () => {}
        },
        secondaryButton: {
          value: $r('app.string.confirm'),
          fontColor: Color.Red,
          action: async () => {
            if (mode) {
              // 单个删除
              this.selectedPkgNames.delete(item.package_name)
              this.selectedDeletePkgNames.delete((item.package_name))
              await accessControlRdb.removeAppFromDomain(item.package_name, domain)
            } else {
              // 批量删除
              const pkgToDeletes = Array.from(this.selectedDeletePkgNames)
              await accessControlRdb.batchRemoveFromDomain(pkgToDeletes, domain)
              // 清除对应应用选中
              pkgToDeletes.forEach(pkgName => {
                this.selectedPkgNames.delete(pkgName);
              })
              // 清空删除选中
              this.selectedDeletePkgNames.clear()
            }
            await this.loadAppsInfo()
            Xb_ToastUtil.showToast({ message: '删除成功' })
          }
        },
        onWillAppear: () => {
          this.isEnableIndexForegroundBlur = true
        },
        onWillDisappear: () => {
          this.isEnableIndexForegroundBlur = false
        }
      })
    } catch (error) {
      console.error('删除失败:', error)
      Xb_ToastUtil.showToast({ message: '删除失败' })
    }
  }

  // 全不选
  async cancelTotalSelected() {
    const domain = this.appConfig.accessControlMode === 'AcceptSelected' ? 'WHITE' : 'BLACK'

    // UI 改变显示状态
    this.appListData = this.appListData.map((app: AppInfo): AppInfo => {
      return {
        name: app.name,
        package_name: app.package_name,
        iconUintArr: app.iconUintArr,
        time: app.time,
        isSelected: false
      };
    });
    this.selectedPkgNames.clear()
    // 持久化层：批量修改为未选中
    await accessControlRdb.batchToggleSelection(
      this.appListData.map(a => a.package_name),
      domain,
      false
    )
  }

  async selectApps(apps: string[]) {
    const domain = this.appConfig.accessControlMode === 'AcceptSelected' ? 'WHITE' : 'BLACK'
    const sortBy = this.appConfig.accessControlSort
    try {
      // 获取实际被操作的包名列表
      const actualPackages = await accessControlRdb.batchToggleSelection(apps, domain, true, sortBy)
      // 添加选中
      this.selectedPkgNames = new Set(actualPackages);
      // 刷新列表
      await this.loadAppsInfo()
      // 提示逻辑
      if (actualPackages.length > 0 && actualPackages.length < apps.length) {
        const missedCount = apps.length - actualPackages.length
        Xb_ToastUtil.showToast({ message: $r('app.string.access_control_limit_msg', actualPackages.length, missedCount), duration: 2000 })
      }
    } catch (error) {
      const msg = error instanceof Error ? error.message : '操作失败'
      Xb_ToastUtil.showToast({ message: msg })
    }
  }

  async cancelSelected(item: AppInfo) {
    const domain = this.appConfig.accessControlMode === 'AcceptSelected' ? 'WHITE' : 'BLACK'
    await accessControlRdb.toggleSelection(item.package_name, domain)
    // 局部刷新 UI 状态
    item.isSelected = false
  }

  openDialog(item: AppInfo) {
    const kvData: KeyValueData = new KeyValueData(item.name, item.package_name, item.iconUintArr)
    this.keyValueData = kvData
    this.kvDialogTitle = getResourceString($r('app.string.edit_app'), this)
    this.isNewApp = false
    this.kvDialogController.open()
  }

  onSearchAppList() {
    if (!this.isSearching) {
      // 退出搜索，恢复数据
      this.loadAppsInfo()
      this.searchText = ''
    }
  }

  async searchApps() {
    const keyword = this.searchText
    hilog.debug(0xFF00, 'AccessControl', `#smartsearchLogs 搜索文本：${keyword}`)
    if (keyword === '') {
      hilog.debug(0xFF00, 'AccessControl', `#smartsearchLogs 无内容`)
      return
    }
    const domain = this.appConfig.accessControlMode === 'AcceptSelected' ? 'WHITE' : 'BLACK'
    const sortBy = this.appConfig.accessControlSort === 'name' ? 'name' : 'time'
    // 获取原始数据
    const rawList = await accessControlRdb.searchApps(keyword, domain, sortBy);
    this.appListData = rawList.map((item: AppInfo) => {
      const data: AppInfo = {
        name: item.name,
        package_name: item.package_name,
        time: item.time,
        iconUintArr: item.iconUintArr,
        isSelected: item.isSelected,
      };
      return data;
    });
    hilog.info(0xFF00, 'AccessControl', `#smartsearchLogs 搜索到：${this.appListData.length} 个`)
    if (this.appListData.length == 0) {
      Xb_ToastUtil.showToast({ message: `没有 ${keyword} 哦`, duration: 1000 })
    }
  }

  // 导出配置
  async exportAccessConfig() {
    try {
      const rawApps = await accessControlRdb.getAllAppsRaw()
      const exportApps: AppInfoConfig[] = rawApps.map((app: AppInfoRdb): AppInfoConfig => {
        const isSelected = (app.list_type === ListType.WHITE_SELECTED || app.list_type === ListType.BLACK_SELECTED);
        const base64Icon = /*app.icon_blob ? Base64Util.encodeToStrSync(app.icon_blob) :*/ ''; // TODO 正确的导出图标
        return {
          package_name: app.package_name,
          list_type: app.list_type as number,
          app_name: app.app_name,
          icon_base64: base64Icon,
          create_time: app.create_time,
          isSelected: isSelected
        };
      });

      const config: AccessConfigExport = {
        version: '2.0',
        exportTime: Date.now(),
        enable: this.appConfig.accessControl,
        mode: this.appConfig.accessControlMode,
        sort: this.appConfig.accessControlSort,
        apps: exportApps
      }

      const dateStr = new Date().toISOString().split('T')[0]
      const fileName = `ClashBox_AccessControl_${dateStr}.json`
      await Xb_FileUtils.exportDataByFile<AccessConfigExport>(fileName, config, this.getUIContext().getHostContext()!)

      Xb_ToastUtil.showToast({ message: $r('app.string.export_success') })
      console.log(`AccessControl 配置文件导出成功`)
    } catch (e) {
      Xb_ToastUtil.showToast({ message: $r('app.string.export_failed') })
      console.error(`AccessControl 配置文件导出失败: ${JSON.stringify(e)}`)
    }
  }

  // 导入配置 (兼容解析策略)
  async importAccessConfig() {
    try {
      const uri = await Xb_FileUtils.openFile(this.getUIContext().getHostContext()!)
      if (!uri) {
        throw new Error('文件uri不存在')
      }

      // --- 尝试解析为新版 V2.0 ---
      const v2Config = await Xb_FileUtils.importDataByFile<AccessConfigExport>(uri)

      if (v2Config && v2Config.version === '2.0' && Array.isArray(v2Config.apps)) {
        hilog.info(0x0000, 'AccessControl', '检测到 V2.0 配置，开始导入...')
        const count = await accessControlRdb.saveImportedApps(v2Config)
        Xb_ToastUtil.showToast({ message: `V2.0 导入成功 ${count} 条` })
        // 更新配置
        this.appConfig.accessControl = v2Config.enable
        this.appConfig.accessControlMode = v2Config.mode
        this.appConfig.accessControlSort = v2Config.sort as "name" | "time"
        this.modeTabSelectedIndexes = [v2Config.mode == 'AcceptSelected' ? 0 : 1]
      }
      // --- 如果不是新版，尝试解析为旧版 ---
      else {
        hilog.info(0x0000, 'AccessControl', '未检测到 V2.0 标记，尝试按旧版解析...')
        const v1Config = await Xb_FileUtils.importDataByFile<AccessConfig>(uri)
        if (v1Config) {
          // 解析旧版的 accept/reject 列表
          const mergeResult = AccessControlCompatibleMerger.calculateMergeDifferences(
            new Set<string>(), // 当前白名单为空
            new Set<string>(), // 当前黑名单为空
            v1Config.acceptList,
            v1Config.rejectList
          );
          // 从转换结果中分离出白名单和黑名单的 Entry 数组
          const acceptEntries = mergeResult.entriesToAdd.filter(entry => entry.key.startsWith('accept_'));
          const rejectEntries = mergeResult.entriesToAdd.filter(entry => entry.key.startsWith('reject_'));

          // 调用迁移接口
          await accessControlRdb.migrateFromOldStorage(
            v1Config.appList || '[]',
            acceptEntries,
            rejectEntries,
            v1Config.mode == 'AcceptSelected' ? ListType.WHITE_UNSELECTED : ListType.BLACK_UNSELECTED
          )
          Xb_ToastUtil.showToast({ message: '旧版配置导入成功' })
          // 更新配置
          this.appConfig.accessControl = v1Config.enable
          this.appConfig.accessControlMode = v1Config.mode
          this.appConfig.accessControlSort = v1Config.sort as "name" | "time"
          this.modeTabSelectedIndexes = [v1Config.mode == 'AcceptSelected' ? 0 : 1]
        } else {
          Xb_ToastUtil.showToast({ message: '文件格式不符合' })
        }
      }

      this.loadAppsInfo()
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '未知错误'
      hilog.error(0x0000, 'AccessControl', `导入失败: ${JSON.stringify(error)}`)
      Xb_ToastUtil.showToast({
        message: Xb_GetResourceString($r('app.string.import_failed'), this) + errorMessage
      })
    }
  }
}

// 旧版配置接口定义 (仅用于导入解析)
interface AccessConfig {
  enable: boolean
  mode: string
  sort: string
  appList: string
  acceptList: string
  rejectList: string
}
