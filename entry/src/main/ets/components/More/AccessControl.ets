import { MoreTop } from "./MoreTopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { universalSearch } from "../../common/utils/SmartSearchUtil"
import { ButtonBuilder, checkoutRowListItem, KVCustomDialog, toggleRowList } from "../Common/Common"
import { PageMargin } from "../../common/breakpoint/BreakPoint"
import { TAB_CONTENT_TITLE_HEIGHT } from "../../common/entity/Constants"
import { AppConfig } from "../../entryability/AppState"
import { ItemRestriction, LengthMetrics, SegmentButton, SegmentButtonOptions, SegmentButtonTextItem } from "@kit.ArkUI"
import { KeyValueData } from "./Overwrite/EditArrayConfig"
import { getResourceString } from "../../common/utils/ResourceStringUtil"
import { intl } from "@kit.LocalizationKit"


@Component
export struct AccessControl {

  @Consume needSearch: boolean
  // 是否进入二级界面
  @Consume isSecondary: boolean
  @State appListData: AppInfo[] = []
  @State nameStringData: string[] = []
  @State isShowSheet: boolean = false
  @State lastAppListData: AppInfo[] = []
  @State kvDialogTitle: ResourceStr = ''
  @Consume @Watch('applist') isSearching: boolean
  @Consume @Watch('searchApps') searchText: string
  @Consume('NavPathStack') pageInfos: NavPathStack
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @State keyValueData: KeyValueData = new KeyValueData("")
  @StorageLink('appConfig') appConfig: AppConfig = new AppConfig()
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @State modeTabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.white_list') }, { text: $r('app.string.blacklist')
    }] as ItemRestriction<SegmentButtonTextItem>,
    backgroundBlurStyle: BlurStyle.BACKGROUND_THICK,
    textPadding: { top: 5, bottom: 5 },
  })
  @State sortTabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.Name') }, { text: $r('app.string.time')
    }] as ItemRestriction<SegmentButtonTextItem>,
    backgroundBlurStyle: BlurStyle.BACKGROUND_THICK,
    textPadding: { top: 5, bottom: 5 },
  })
  @State @Watch('onModeChange') modeTabSelectedIndexes: number[] = [1]
  @State @Watch('onSortChange') sortTabSelectedIndexes: number[] = [0]

  build() {
    NavDestination() {
      Column({ space: 10 }) {
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

        Blank().height(TAB_CONTENT_TITLE_HEIGHT)

        toggleRowList({
          title: $r('app.string.app_access_control'),
          subtitle: $r('app.string.access_control_tips'),
          toggle: () => { this.controlBuilder() }
        })
          .margin({ right: PageMargin(this.widthBp, this.heightBp), left: PageMargin(this.widthBp, this.heightBp) })

        Flex({
          direction: FlexDirection.Row,
          space: { main: LengthMetrics.vp(10) },
          justifyContent: FlexAlign.SpaceBetween,
          alignItems: ItemAlign.Center
        })
        {
          Column() {
            Text($r('app.string.selected'))
            Text(this.appConfig.accessControlMode != 'AcceptSelected' ? $r('app.string.white_list_tips') : $r('app.string.blacklist_tips'))
          }.width('100%')
          .alignItems(HorizontalAlign.Start)
          ButtonBuilder({
            icon: $r('sys.symbol.plus'),
            onCheck: () => {
              this.kvDialogTitle = getResourceString($r('app.string.add_app'), this)
              this.kvDialogController.open()
            }
          })
            .enabled(this.appConfig.accessControl)
          if (this.appListData.length != 0) {
            CheckboxGroup({ group: 'App' })
              .enabled(this.appConfig.accessControl)
              .checkboxShape(CheckBoxShape.CIRCLE)
              .selectedColor(this.icon_emphasize)
              .width(24)
              .onChange((itemName: CheckboxGroupResult) => {
                // console.info("AccessControl checkbox group content" + JSON.stringify(itemName))
                if (this.appConfig.accessControlMode == 'AcceptSelected') {
                  // 白名单
                  this.appConfig.accessControlAcceptList = JSON.stringify(itemName.name)
                } else {
                  // 黑名单
                  this.appConfig.accessControlRejectList = JSON.stringify(itemName.name)
                }
              })
          }
        }
        .padding({ right: PageMargin(this.widthBp, this.heightBp) + 12, left: PageMargin(this.widthBp, this.heightBp) + 12 })

        List({space: 8}) {
          ForEach(this.appListData, (item: AppInfo, index) => {
            ListItem() {
              checkoutRowListItem({
                title: item.name,
                subtitle: item.package_name,
                isSelected: item.isSelected
              })
            }
            .enabled(this.appConfig.accessControl)
            .onClick(() => {
              const itemData = this.appListData[index]
              itemData.isSelected = !itemData.isSelected
              this.appListData.splice(index, 1, itemData)
            })
            .onMouse((event) => {
              if (event.action == MouseAction.Press && event.button == MouseButton.Right) {
                this.openDialog(item)
              }
            })
            .gesture(LongPressGesture()
              .onAction(() => {
                this.openDialog(item)
              }))
          })
        }
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
    })
    .onBackPressed(() => {
      if(this.isSearching) {
        this.isSearching = false
        this.searchText = ''
        return true
      }
      this.pageInfos.clear()
      this.isSecondary = false
      return true
    })

  }

  kvDialogController = new CustomDialogController({
    builder: KVCustomDialog({
      value: $keyValueData,
      keyPlaceholder: $r('app.string.the_app_name'),
      valuePlaceholder: $r('app.string.package_name'),
      theDialogTitle: this.kvDialogTitle,
      confirm: (value) => {
        // 关闭背景模糊
        this.isEnableIndexForegroundBlur = false
        // console.log(`AccessControl kvCustomdialog 当前value: ${JSON.stringify(value)}`)
        const indexes = this.appListData.findIndex((d) => d.name == value.key)
        // console.log(`AccessControl kvCustomdialog 当前序号: ${indexes}`)
        if (indexes > -1) {
          this.appListData[indexes].package_name = value.value as string
          this.appListData = [... this.appListData]
        } else {
          const param: AppInfo = {
            name: value.key,
            package_name: value.value as string,
            time: Date.now(),
            isSelected: false
          }
          this.appListData = [...this.appListData, param]
        }
        // 保存后重置数据
        this.keyValueData = new KeyValueData("")
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
  }

  @Builder
  controlBuilder() {
    Toggle({ type: ToggleType.Switch, isOn: this.appConfig.accessControl })
      .selectedColor(this.icon_emphasize)
      .onChange((isOn) => {
        this.appConfig.accessControl = isOn
      })
  }

  aboutToAppear(): void {
    this.appListData.push({
      name: '哔哩哔哩',
      package_name: 'yylx.danmaku.bili',
      time: Date.now(),
      isSelected: false
    },
      {
      name: '浏览器',
      package_name: 'com.huawei.hmos.browser',
      time: Date.now(),
      isSelected: false
    })

    if (this.appConfig.accessControlMode == 'AcceptSelected') {
      // 白名单
      this.modeTabSelectedIndexes.splice(0, 1, 0)
      this.nameStringData = JSON.parse(this.appConfig.accessControlAcceptList)
    } else {
      // 黑名单
      this.modeTabSelectedIndexes.splice(0, 1, 1)
      this.nameStringData = JSON.parse(this.appConfig.accessControlRejectList)
    }
    console.log(`AccessControl #aboutToAppear ${JSON.stringify(this.nameStringData)}`)
    const selectedPackagesSet = new Set(this.nameStringData)
    this.appListData = this.appListData.map((app): AppInfo => ({
      name: app.name,
      package_name: app.package_name,
      time: app.time,
      isSelected: selectedPackagesSet.has(app.package_name)
    }))
    console.log(`AccessControl #aboutToAppear ${JSON.stringify(this.appListData)}`)
    this.sortTabSelectedIndexes.splice(0, 1, this.appConfig.accessControlSort == 'name' ? 0 : 1)
  }

  onModeChange() {
    if (this.modeTabSelectedIndexes[0] == 0) {
      // 白名单
      this.appConfig.accessControlMode = 'AcceptSelected'
    } else {
      // 黑名单
      this.appConfig.accessControlMode = 'RejectSelected'
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