import { MoreTop } from "./MoreTopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { universalSearch } from "../../common/utils/SmartSearchUtil"
import { ButtonBuilder, checkoutRowListItem,
  font_primary, KVCustomDialog, toggleRowList } from "../Common/Common"
import { NeedClearMoreStack, PageMargin } from "../../common/breakpoint/BreakPoint"
import { BundleInfo, TAB_CONTENT_TITLE_HEIGHT } from "../../common/entity/Constants"
import { AppConfig, UIConfig } from "../../entryability/AppState"
import { ItemRestriction, LengthMetrics, SegmentButton, SegmentButtonOptions, SegmentButtonTextItem } from "@kit.ArkUI"
import { KeyValueData } from "./Overwrite/EditArrayConfig"
import { getResourceString } from "../../common/utils/ResourceStringUtil"
import { intl } from "@kit.LocalizationKit"
import { Xb_CapsuleButton, Xb_CircleButton, Xb_FileUtils, Xb_GetResourceString,
  Xb_KVdbUtil,
  Xb_PreferenceUtil,
  Xb_ToastUtil } from "xb_components"
import { customAnimationUtil } from "../../common/utils/Animation"
import { EventHub, EventKey } from '../../common/EventHub'
import { distributedKVStore } from "@kit.ArkData"
import { AccessControlCompatibleMerger } from "../../common/utils/AccessControlCompatibleUtil"

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
  @State initialized: boolean = false
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
          Flex({
            direction: FlexDirection.Row,
            space: { main:LengthMetrics.vp(10) },
            alignItems: ItemAlign.Center
          })
          {
            Column() {
              Text(`${Xb_GetResourceString($r('app.string.selected'), this)} ${this.nameStringData.length}`)
              Text(this.isDeleteing ? `${Xb_GetResourceString($r('app.string.Edit'), this)}${Xb_GetResourceString($r('app.string.mode'), this)}`
                : this.appConfig.accessControlMode != 'AcceptSelected' ? $r('app.string.white_list_tips') : $r('app.string.blacklist_tips'))
                .maxLines(this.uiConfig.stringDisplayIndex === 0 ? 1 : 2)
                .fontColor($r('sys.color.font_secondary'))
                .fontSize(14)
                .textOverflow({ overflow: this.uiConfig.stringDisplayIndex === 0 ? TextOverflow.Ellipsis : TextOverflow.Clip })
            }
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
                      this.cancelTotalSelected(this.isDeleteing)
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
              .onChange(async (itemName: CheckboxGroupResult) => {
                this.nameStringData = itemName.name
              })
              .onClick(() => {
                if (!this.isDeleteing && this.initialized) {
                  if (this.nameStringData.length == this.appListData.length) {
                    // 全选
                    this.selectApps(this.nameStringData)
                  }
                  if (this.nameStringData.length == 0) {
                    // 全不选
                    this.cancelTotalSelected(false)
                  }
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
        // 应用列表
        Column() {
          Blank().height(TAB_CONTENT_TITLE_HEIGHT + (this.uiConfig.stringDisplayIndex === 0 ? 112 : 139) + (this.widthBp < 2 ? this.topRectHeight : 0))
          Scroll() {
            List({space: 8}) {
              ForEach(this.getSelectedSortApps(this.appListData), (item: AppInfo, index) => {
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
                .onClick(async () => {
                  const itemData = this.appListData[index]
                  itemData.isSelected = !itemData.isSelected
                  this.appListData.splice(index, 1, itemData)
                  if (!itemData.isSelected) {
                    // 取消当前选择
                    this.cancelSelected(item)
                  } else {
                    this.selectApps([item.package_name])
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
        this.isEnableIndexForegroundBlur = false
        console.log(`AccessControl kvCustomdialog 当前value: ${JSON.stringify(value)}`)
        // --- 核心逻辑：以磁盘数据为准 ---
        await this.saveApp(value)
        // 保存后重置弹窗状态
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
        selectedIndexes: this.modeTabSelectedIndexes,
        onItemClicked: (tab) => {
          console.debug(`AccessControl 模式 #onItemClicked，accessControlMode: ${tab}`)
          if (tab == 0) {
            // 白名单
            this.appConfig.accessControlMode = 'AcceptSelected'
          } else {
            // 黑名单
            this.appConfig.accessControlMode = 'RejectSelected'
          }
          this.loadAppsInfo()
        }
      })
      // 排序
      Text($r('app.string.sort'))
      SegmentButton({
        options: this.sortTabOptions,
        selectedIndexes: this.sortTabSelectedIndexes,
        onItemClicked: (tab) => {
          console.debug(`AccessControl 排序 #onItemClicked，accessControlMode: ${tab}`)
          if (tab == 0) {
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

  async aboutToAppear(): Promise<void> {
    EventHub.on(EventKey.AddAPP, (bundleInfo: BundleInfo) => {
      this.keyValueData = new KeyValueData(bundleInfo?.appName || '', bundleInfo?.bundleName || '', bundleInfo?.iconUintArr)
      this.addApp()
    })
    this.loadAppsInfo().then(() => {
      this.initialized = true
      console.debug(`AccessControl #aboutToAppear 数据初始化完成: ${this.initialized}`)
    })
  }

  async aboutToDisappear(): Promise<void> {

  }

  addApp() {
    this.kvDialogTitle = getResourceString($r('app.string.add_app'), this)
    this.kvDialogController.open()
    this.isNewApp = true
  }

  async saveApp(value: KeyValueData) {
    console.log(`AccessControl saveApp 开始处理弹窗数据保存: ${JSON.stringify(value)}`);
    try {
      // UI列表的副本，用于界面更新
      const originalUIList: AppInfo[] = [...this.appListData];
      // 持久化总清单的副本，从磁盘读取，用于数据保存
      const originalMasterList: AppInfo[] = JSON.parse(await Xb_PreferenceUtil.get('access_control_apps', "[]"));
      const newPackageName = (value.value as string).trim();
      const newAppName = value.key.toString().trim();
      if (this.isNewApp) {
        // --- 新增逻辑 ---
        console.log(`AccessControl saveApp 执行新增逻辑`);
        // 检查包名是否已存在于当前UI列表中（避免重复添加到同一页面）
        if (originalUIList.some(app => app.package_name === newPackageName)) {
          Xb_ToastUtil.showToast({ message: $r('app.string.app_already_exist') })
          return;
        }
        // 业务规则检查：不能添加自身
        if (newPackageName === this.getUIContext().getHostContext()!.applicationInfo.name) {
          console.log("不能添加当前应用自身到控制列表");
          return;
        }
        const newApp: AppInfo = {
          name: newAppName,
          package_name: newPackageName,
          time: Date.now(),
          isSelected: false
        };
        // 操作UI列表副本：添加新应用
        originalUIList.push(newApp);
        // 操作持久化列表副本：检查总清单中是否存在，不存在则添加
        if (!originalMasterList.some(app => app.package_name === newPackageName)) {
          originalMasterList.push(newApp);
        }
      } else {
        // --- 编辑逻辑 ---
        console.log(`AccessControl saveApp 执行编辑逻辑`);
        // 获取当前UI列表中待编辑应用的原始包名作为查找依据
        const originalPkgName = this.appListData[this.currentIndex].package_name;
        // 检查新的包名是否与当前UI列表中“其他”应用冲突
        if (originalUIList.some(app => app.package_name === newPackageName && app.package_name !== originalPkgName)) {
          Xb_ToastUtil.showToast({ message: '应用包名已经存在' })
          return;
        }
        // 操作UI列表副本：找到并更新应用
        const uiAppToEdit = originalUIList[this.currentIndex];
        uiAppToEdit.name = newAppName;
        uiAppToEdit.package_name = newPackageName;
        uiAppToEdit.time = Date.now();
        // 操作持久化列表副本：找到并更新应用
        const masterAppToEditIndex = originalMasterList.findIndex(app => app.package_name === originalPkgName);
        if (masterAppToEditIndex !== -1) {
          const masterAppToEdit = originalMasterList[masterAppToEditIndex];
          masterAppToEdit.name = newAppName;
          masterAppToEdit.package_name = newPackageName;
          masterAppToEdit.time = Date.now();
        } else {
          console.error("错误：要编辑的应用在总清单中未找到！");
          Xb_ToastUtil.showToast({ message: '编辑失败，数据异常' });
          return;
        }
      }

      // 更新UI状态
      this.appListData = originalUIList;
      // 执行持久化
      await Xb_PreferenceUtil.put('access_control_apps', JSON.stringify(originalMasterList));
      console.log(`AccessControl saveApp 应用列表已成功保存`);
    } catch (error) {
      console.error('AccessControl saveApp 保存应用列表失败:', error);
      Xb_ToastUtil.showToast({ message: '保存失败: ' + error.message });
    }
  }

  async loadAppsInfo() {
    try {
      const apps = await Xb_PreferenceUtil.get<string>('access_control_apps', "[]")
      console.debug(`AccessControl #loadAppsInfo apps: ${apps}，accessControlMode: ${this.appConfig.accessControlMode}`)
      this.appListData = JSON.parse(apps)
      if (this.appConfig.accessControlMode == 'AcceptSelected') {
        // 白名单
        const acceptData = await Xb_KVdbUtil.getEntriesByPrefix('accept_')
        console.debug(`AccessControl #loadAppsInfo acceptData: ${JSON.stringify(acceptData)}`)
        const packageNameStringData: string[] = acceptData.map(app => app.value.value as string)
        console.debug(`AccessControl #loadAppsInfo packageNameStringData: ${JSON.stringify(packageNameStringData)}`)
        this.selectSelectedApp(packageNameStringData)
      } else {
        // 黑名单
        const rejectData = await Xb_KVdbUtil.getEntriesByPrefix('reject_')
        console.debug(`AccessControl #loadAppsInfo acceptData: ${JSON.stringify(rejectData)}`)
        const packageNameStringData = rejectData.map(app => app.value.value as string)
        console.debug(`AccessControl #loadAppsInfo ${JSON.stringify(packageNameStringData)}`)
        this.selectSelectedApp(packageNameStringData)
      }
    } catch (e) {
      console.error(`AccessControl 错误: ${e}`)
    }
  }

  async deleteApp(index?: number, item?: AppInfo) {
    // UI列表的副本，用于界面更新
    const originalUIList: AppInfo[] = [...this.appListData];
    // 持久化总清单的副本，从磁盘读取，用于数据保存
    const originalMasterList: AppInfo[] = JSON.parse(await Xb_PreferenceUtil.get('access_control_apps', "[]"));

    if (index != undefined && item != undefined) {
      // --- 删除单个应用 ---
      console.log(`AccessControl #deleteApp [单个] 删除应用: ${item.name}`);
      try {
        let keyToDelete: string;
        let otherKeyPrefix: string;
        if (this.appConfig.accessControlMode == 'AcceptSelected') {
          keyToDelete = 'accept_' + item.package_name;
          otherKeyPrefix = 'reject_';
        } else {
          keyToDelete = 'reject_' + item.package_name;
          otherKeyPrefix = 'accept_';
        }
        // 从当前列表删除
        await Xb_KVdbUtil.deleteData(keyToDelete);
        // 操作UI列表副本：移除应用
        const uiIndexToRemove = originalUIList.findIndex(app => app.package_name === item.package_name);
        if (uiIndexToRemove > -1) {
          originalUIList.splice(uiIndexToRemove, 1);
        }
        // 检查另一个列表中是否存在
        const existsInOtherList = await Xb_KVdbUtil.hasKey(otherKeyPrefix + item.package_name);
        // 操作持久化列表副本：如果另一个列表中也不存在，则从总清单中删除
        if (!existsInOtherList) {
          const masterIndexToRemove = originalMasterList.findIndex(app => app.package_name === item.package_name);
          if (masterIndexToRemove > -1) {
            originalMasterList.splice(masterIndexToRemove, 1);
          }
        }
      } catch (error) {
        console.error(`删除单个应用 ${item.name} 失败:`, error);
      }
    } else {
      // --- 批量删除应用 ---
      if (!this.nameStringData || this.nameStringData.length === 0) {
        console.log('AccessControl #deleteApp [批量] 删除列表为空，无需操作。');
        return;
      }
      try {
        let keyPrefixToDelete: string;
        let otherKeyPrefix: string;
        if (this.appConfig.accessControlMode == 'AcceptSelected') {
          keyPrefixToDelete = 'accept_';
          otherKeyPrefix = 'reject_';
        } else {
          keyPrefixToDelete = 'reject_';
          otherKeyPrefix = 'accept_';
        }
        const keysToDelete = this.nameStringData.map(pkgName => keyPrefixToDelete + pkgName);
        await Xb_KVdbUtil.deleteKeysBatch(keysToDelete);

        const otherListEntries = await Xb_KVdbUtil.getEntriesByPrefix(otherKeyPrefix);
        const otherListPkgSet = new Set(
          otherListEntries.map(entry => entry.key.substring(otherKeyPrefix.length))
        );
        // 操作UI列表副本：移除所有选中的应用
        const packageNamesToRemoveSet = new Set(this.nameStringData);
        for (let i = originalUIList.length - 1; i >= 0; i--) {
          if (packageNamesToRemoveSet.has(originalUIList[i].package_name)) {
            originalUIList.splice(i, 1);
          }
        }
        // 操作持久化列表副本：移除在两个列表中都不存在的应用
        for (let i = originalMasterList.length - 1; i >= 0; i--) {
          const pkgName = originalMasterList[i].package_name;
          if (packageNamesToRemoveSet.has(pkgName) && !otherListPkgSet.has(pkgName)) {
            originalMasterList.splice(i, 1);
          }
        }
      } catch (error) {
        console.error('AccessControl #deleteApp [批量] 批量删除失败:', error);
      }
    }

    try {
      // 更新UI状态
      this.appListData = originalUIList;
      // 执行持久化
      await Xb_PreferenceUtil.put('access_control_apps', JSON.stringify(originalMasterList));
      console.log(`AccessControl #deleteApp 删除操作完成，UI和持久化数据已同步更新。`);
    } catch (error) {
      console.error('AccessControl #deleteApp 删除应用UI与磁盘同步更新失败:', error);
      Xb_ToastUtil.showToast({ message: '删除失败' });
    }
  }
  
  // 取消所有选中
  async cancelTotalSelected(onUI: boolean = false) {
    this.appListData = this.appListData.map((app): AppInfo => ({
      name: app.name,
      package_name: app.package_name,
      time: app.time,
      isSelected: false
    }))
    // 持久化
    if (!onUI) {
      const prefix = this.appConfig.accessControlMode === 'AcceptSelected' ? 'accept_' : 'reject_';
      await Xb_KVdbUtil.deleteEntriesByPrefix(prefix)
    }
  }

  async selectApps(apps: string[]) {
    const prefix = this.appConfig.accessControlMode === 'AcceptSelected' ? 'accept_' : 'reject_';
    // 分块大小，每次 50 个并发
    const CHUNK_SIZE = 50;
    for (let i = 0; i < apps.length; i += CHUNK_SIZE) {
      const chunk = apps.slice(i, i + CHUNK_SIZE);
      const tasks = chunk.map(app => {
        return Xb_KVdbUtil.putData(`${prefix}${app}`, app);
      });
      // 每次只等待分块完成
      await Promise.all(tasks);
    }
  }

  cancelSelected(item: AppInfo) {
    let key =''
    if (this.appConfig.accessControlMode == 'AcceptSelected') {
      // 白名单
      key = `accept_${item.package_name}`
    } else {
      key = `reject_${item.package_name}`
    }
    Xb_KVdbUtil.deleteData(key)
  }

  selectSelectedApp(packageNames: string[]) {
    console.debug(`AccessControl #selectedApp 列表数据：${JSON.stringify(this.appListData)} 包名数据：${JSON.stringify(packageNames)}`)
    const selectedPackagesSet = new Set(packageNames)
    this.appListData = this.appListData.map((app): AppInfo => ({
      name: app.name,
      package_name: app.package_name,
      time: app.time,
      isSelected: selectedPackagesSet.has(app.package_name)
    }))
  }

  // 导出配置
  async exportAccessConfig() {
    const apps = await Xb_PreferenceUtil.get<string>('access_control_apps', "[]")
    const acceptData = await Xb_KVdbUtil.getEntriesByPrefix('accept_')
    const rejectData = await Xb_KVdbUtil.getEntriesByPrefix('reject_')
    const config: AccessConfig = {
      enable: this.appConfig.accessControl,
      mode: this.appConfig.accessControlMode,
      sort: this.appConfig.accessControlSort,
      appList: apps,
      acceptList: JSON.stringify(acceptData),
      rejectList: JSON.stringify(rejectData)
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
    try {
      const uri = await Xb_FileUtils.openFile(this.getUIContext().getHostContext()!);
      if (!uri) {
        throw new Error('文件uri不存在');
      }
      const config = await this._parseConfigFile(uri);
      await this._mergeAndSaveAppList(config.appList);
      await this._mergeAndSaveAccessLists(config.acceptList, config.rejectList);
      // --- 所有数据操作成功后，再更新UI状态和视图 ---
      this.appConfig.accessControl = config.enable;
      this.appConfig.accessControlMode = config.mode;
      this.appConfig.accessControlSort = config.sort as "name" | "time";
      await this.loadAppsInfo();
      Xb_ToastUtil.showToast({ message: $r('app.string.import_success') });
    } catch (error) {
      // --- 错误处理 ---
      const errorMessage = error instanceof Error ? error.message : '未知错误';
      console.error('AccessControl 导入配置时发生错误:', error);
      Xb_ToastUtil.showToast({ message: Xb_GetResourceString($r('app.string.import_failed'), this) + errorMessage });
    } finally {
    }
  }

  // 解析配置文件
  private async _parseConfigFile(uri: string): Promise<AccessConfig> {
    console.log('AccessControl: 开始解析配置文件...');
    const config = await Xb_FileUtils.importDataByFile<AccessConfig>(uri);
    if (!config) {
      throw new Error('配置文件解析失败或内容为空');
    }
    return config;
  }

  // 合并并保存总应用清单
  private async _mergeAndSaveAppList(importedAppListString: string): Promise<void> {
    console.log('AccessControl: 开始合并总应用清单...');
    const currentAppList: AppInfo[] = JSON.parse(await Xb_PreferenceUtil.get('access_control_apps', "[]"));
    const importedAppList: AppInfo[] = JSON.parse(importedAppListString);

    const mergedAppMap = new Map<string, AppInfo>(currentAppList.map(app => [app.package_name, app]));
    importedAppList.forEach(app => mergedAppMap.set(app.package_name, app));

    const finalAppList = Array.from(mergedAppMap.values());
    await Xb_PreferenceUtil.put('access_control_apps', JSON.stringify(finalAppList));
    console.log(`AccessControl: 总清单合并完成，当前${currentAppList.length}条，导入${importedAppList.length}条，合并后${finalAppList.length}条。`);
  }

  // 合并并保存黑白名单
  private async _mergeAndSaveAccessLists(importedAcceptList: string, importedRejectList: string): Promise<void> {
    console.log('AccessControl: 开始合并访问控制黑白名单列表...');
    const currentAcceptEntries = await Xb_KVdbUtil.getEntriesByPrefix('accept_');
    const currentRejectEntries = await Xb_KVdbUtil.getEntriesByPrefix('reject_');
    const currentAcceptSet = new Set(currentAcceptEntries.map(entry => entry.key.substring('accept_'.length)));
    const currentRejectSet = new Set(currentRejectEntries.map(entry => entry.key.substring('reject_'.length)));

    const mergeResult = AccessControlCompatibleMerger.calculateMergeDifferences(
      currentAcceptSet,
      currentRejectSet,
      importedAcceptList,
      importedRejectList
    );

    if (mergeResult.keysToDelete.length > 0) {
      await Xb_KVdbUtil.deleteKeysBatch(mergeResult.keysToDelete);
      console.log(`AccessControl: 准备删除 ${mergeResult.keysToDelete.length} 条旧记录。`);
    }
    if (mergeResult.entriesToAdd.length > 0) {
      await Xb_KVdbUtil.putEntriesBatch(mergeResult.entriesToAdd);
      console.log(`AccessControl: 准备新增 ${mergeResult.entriesToAdd.length} 条新记录。`);
    }
    console.log('AccessControl: 访问列表合并完成。');
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

  getSelectedSortApps(appList: AppInfo[]) {
    return appList.sort((a, b) => {
      if (a.isSelected === b.isSelected) {
        return 0; // 状态相同，不动
      }
      // a 选中了，a 应该在前面 -> 返回负数
      return a.isSelected ? -1 : 1;
    });
  }

}

const nameSortCollator = new intl.Collator("zh-CN")

export interface AppInfo {
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