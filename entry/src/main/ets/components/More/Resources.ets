import { BreakpointState } from "../../common/breakpoint/breakpointsystem"
import { BIND_SHEET_DRAG_BAR_HEIGHT, BORDER_RADIUS_20, CONTENT_END_OFFSET_150,
  TAB_CONTENT_TITLE_HEIGHT } from "../../common/entity/Constants"
import { Nothing, theCustomDialog } from "../Common/Common"
import { MoreTop } from "./MoreTopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { convertTime } from "../../common/utils/TimeConvertUtil"
import { ClashConfig } from 'proxy_core'
import { curves, promptAction } from '@kit.ArkUI'
import { copy, UIConfig } from '../../entryability/AppState'
import ClashViewModel from '../../entryability/ClashViewModel'
import { getResourceString } from "../../common/utils/ResourceStringUtil"
import { EventHub, EventKey } from "../../common/EventHub"
import { customAnimationUtil, isON } from "../../common/utils/Animation"
import { i18n } from "@kit.LocalizationKit"
import { PageMargin } from "../../common/breakpoint/BreakPoint"
import { icon_primary } from "../Common/Common"

// 资源数据（假设）
interface ResourcesData {
  // 资源名
  resourceName: string
  key: string
  fileName: string
  // 资源大小（KB）
  resourceSize: number
  // 更新时间(展示的时间)
  updateTime: number
}

/**
 * 文件大小转换
 */
function switchResourceSize(size: number) {
  if (size < 1000) {
    return `${size}KB`
  } else if (size < 1000000) {
    return `${Math.floor(size / 1000)}MB`
  } else if (size < 1000000000) {
    return `${Math.floor(size / 1000000)}GB`
  } else if (size < 1000000000000) {
    return `${Math.floor(size / 1000000000)}TB`
  } else {
    return `${size}KB`
  }
}

export const theResouresData: Array<ResourcesData> = [
  {
    key: "geoip",
    resourceName: 'GeoIp',
    fileName: "GeoIP.dat",
    resourceSize: 6543,
    updateTime: 1749640201580,
  },
  {
    key: "geosite",
    resourceName: 'GeoSite',
    fileName: "GeoSite.dat",
    resourceSize: 8654,
    updateTime: 1749640201580,
  },
  {
    key: "mmdb",
    resourceName: 'MMDB',
    fileName: "geoip.metadb",
    resourceSize: 8654,
    updateTime: 1749640201580,
  },
  {
    key: "asn",
    resourceName: 'ASN',
    fileName: "ASN.mmdb",
    resourceSize: 8654,
    updateTime: 1749640201580,
  }
]

export const resourcesBlankData: Array<ResourcesData> = [
  {
    key: "NN",
    resourceName: '',
    fileName: "",
    resourceSize: 0,
    updateTime: 0,
  }
]


@Component
struct Resources {
  // 是否进入二级界面
  @Consume isSecondary: boolean
  @State theNumberUpdated: number = 0
  @State isRefreshing: boolean = false
  @Consume('NavPathStack') pageInfos: NavPathStack
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 使用默认文本位置传递列表行的index
  @State theEditIndex: number = 0
  // 编辑资源保存的输入文本
  @State SaveEditInputValue: string = ''
  // 编辑资源弹窗当前输入文本
  @State currentEditInputValue: string = ''
  // 编辑路由地址弹窗标题
  @State theEditDialogTitle: ResourceStr = $r('app.string.edit_resource')
  @State isLoading: number = -1
  @State isLoadingAll: boolean = false
  @Provide isShowGroupSort: Boolean = false
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  @Provide resourceListData: Array<ResourcesData> = theResouresData
  // 开关不触发list转场动画判定
  @State isON:isON = new isON()
  // page内顶部标题偏移量
  @Consume curYOffset: number

  @Builder
  SortSheet() {
    Column() {
      Sort()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  LoadingBuilder() {
    Column({space: 5}) {
      LoadingProgress()
        .color(this.icon_emphasize)
        .width(40)
        .height(40)
      Text() {
        Span($r('app.string.resource_updating'))
        Span('  ')
        Span(this.theNumberUpdated.toString())
        Span('/')
        Span(this.resourceListData.length.toString())
      }
      .fontSize(16)
    }.margin({bottom: 6})
  }

  /**
   * 资源编辑弹窗控制器
   */
  editDialogController: CustomDialogController = new CustomDialogController({
    builder: theCustomDialog({
      theplaceholder: $theEditIndex,
      currentInputValue: $currentEditInputValue,
      SaveInputValue: $SaveEditInputValue,
      isArea: true,
      theDialogTitle: this.theEditDialogTitle,
      cancel: ()=> { this.onCancel() },
      confirm: ()=> { this.onAccept() },
    }),
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      // 1、PRESS_BACK    点击三键back、左滑/右滑、键盘ESC。
      // 2、TOUCH_OUTSIDE    点击遮障层时
      // 3、CLOSE_BUTTON    点击关闭按钮
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        // 点击遮蔽层不响应，防误触
      } else {
        // 完成IP地址查询后主动通过dismiss主动关闭对话框
        dismissDialogAction.dismiss()
      }
    },
  })

  onCancel() {
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
  }
  onAccept() {
    // 关闭背景模糊
    this.isEnableIndexForegroundBlur = false
    // 更新资源数组中对应元素
    const editItem = this.resourceListData[this.theEditIndex]
    this.updateUrl(editItem.key, this.SaveEditInputValue)
    // this.resourceListData.splice(this.theEditIndex, 1, editItem)
    this.updateTime(this.theEditIndex)
  }

  updateUrl(name: string, url: string){
    let geoMap = this.clashConfig?.['geox-url']
    if(geoMap){
      geoMap[name] = url
      this.clashConfig['geox-url'] = copy(geoMap)
    }
    EventHub.sendEvent(EventKey.LoadClashConfig, true)
  }

  updateTime(index: number) {
    let ItemData = this.resourceListData[index]
    ItemData.updateTime = new Date().getTime()
    this.resourceListData.splice(index, 1, ItemData)
  }

  async updateGeoDateItem(item: ResourcesData) {
    try {
      const message = await ClashViewModel.updateGeoData(
         item.resourceName,
         item.fileName,
      );
      this.isLoading = -1
      this.isLoadingAll = false
      if (message != "") {
        promptAction.showToast({ message: getResourceString($r('app.string.update_failed'), this) +" " + message })
      }
      else {
        promptAction.showToast({ message: getResourceString($r('app.string.update_success'), this) })
      }
    } catch (e) {
      this.isLoading = -1
      this.isLoadingAll = false
      promptAction.showToast({message: getResourceString($r('app.string.update_failed'), this) + (e.message | e)})
    }
  }

  updateGeoDate() {
    this.resourceListData.forEach(async (item, index) => {
      await this.updateGeoDateItem(item)
      this.updateTime(index)
      this.theNumberUpdated++
      if (index === this.resourceListData.length - 1) {
        this.isRefreshing = false
      }
    })
  }

  aboutToAppear(): void {
    this.resourceListData = JSON.parse(this.uiConfig.resourcesData)
  }

  aboutToDisappear(): void {
    this.uiConfig.resourcesData = JSON.stringify(this.resourceListData)
  }

  build() {
    NavDestination() {
      Stack() {
        MoreTop({
          title: $r('app.string.Resources'),
          icon1: $r('sys.symbol.arrow_clockwise'),
          icon2: $r('sys.symbol.sort'),
          onClick1: () => {
            this.isON.toggleAnim = true
            this.isLoadingAll = true
            promptAction.showToast({ message: getResourceString($r('app.string.resource_updating'), this) })
            this.updateGeoDate()
          },
          onClick2: () => {
            this.isON.toggleAnim = true
            this.isEnableIndexForegroundBlur = true
            this.isShowGroupSort = true
          },
        })

        Column() {
          Blank().height(TAB_CONTENT_TITLE_HEIGHT+6)
          // 页面
          if (this.resourceListData.length === 0) {
            Nothing({ name: $r('app.string.Resources') })
          } else {
            Refresh({refreshing: $$this.isRefreshing, builder: this.LoadingBuilder()}) {
              List({ space: 10 }) {
                ForEach(this.resourceListData, (item: ResourcesData, index: number) => {
                  ListItem() {
                    Row() {
                      // 文本显示区
                      Column() {
                        Text(item.resourceName)
                          .fontWeight(FontWeight.Bold)
                          .margin({ bottom: 2 })
                          .fontSize(17)
                        Column() {
                          Row({ space: 2 }) {
                            Text(switchResourceSize(item.resourceSize))
                              .smallText()
                            Text('·')
                              .smallText()
                            Text(convertTime(item.updateTime))
                              .smallText()
                          }.justifyContent(FlexAlign.Start)

                          Text(this.clashConfig?.['geox-url']?.[item.key] ?? "")
                            .smallText()
                        }
                        .alignItems(HorizontalAlign.Start)
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)

                      Blank()
                      // 功能按钮区
                      // 编辑按钮
                      Button({ type: ButtonType.Circle, stateEffect: true }) {
                        SymbolGlyph($r('sys.symbol.square_and_pencil'))
                          .fontSize(24)
                          .fontColor([icon_primary])
                      }.ButtonStyle().margin({ right: 12 })
                      .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                      .onClick(() => {
                        // 进入列表行数据编辑
                        this.currentEditInputValue = this.clashConfig?.['geox-url']?.[item.key] ?? ""
                        this.theEditIndex = index
                        hilog.info(0xFF00, "ResourcestestTag", "编辑中的序号：%{public}d", this.theEditIndex)
                        hilog.info(0xFF00, "ResourcestestTag", "编辑中的链接：%{public}s", this.currentEditInputValue)
                        this.editDialogController.open()
                      })


                      // 更新按钮
                      Button({ type: ButtonType.Circle, stateEffect: true }) {
                        if(this.isLoading == index || this.isLoadingAll) {
                          LoadingProgress()//.color(this.icon_emphasize)
                            .size({ width: 35, height: 35 })
                            //.transition(customAnimationUtil.isOpacity(this.uiConfig))
                        }else {
                          SymbolGlyph($r('sys.symbol.arrow_clockwise'))
                            .fontSize(24)
                            .fontColor([icon_primary])
                            //.transition(customAnimationUtil.isOpacity(this.uiConfig))
                        }
                      }.ButtonStyle()
                      .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                      .onClick(async () => {
                        this.isON.toggleAnim = true
                        this.isLoading = index
                        this.updateTime(index)
                        // 资源更新处理
                        await this.updateGeoDateItem(item)
                        this.isLoading = -1
                      })
                    }
                    .padding(12)
                    .width('100%')
                    .justifyContent(FlexAlign.Center)
                    .backgroundColor($r('app.color.container_background'))
                    .borderRadius(BORDER_RADIUS_20)
                  }.width('100%')
                  .transition(this.isON.toggleAnim ? null : customAnimationUtil.isScaleTran(index, this.uiConfig))
                })

                if (this.uiConfig.userLanguage === 'zh-Hans' || (this.uiConfig.systemLanguage === 'zh-Hans' && this.uiConfig.userLanguage === 'default')) {
                  // 资源更新提示
                  ListItem() {
                    Text($r('app.string.resources_tips'))
                      .fontColor($r('sys.color.font_secondary'))
                      .fontWeight(FontWeight.Normal)
                      .fontSize(14)
                  }.transition(customAnimationUtil.isScaleTran(4, this.uiConfig))
                }

              }.width('100%')
              .height('100%')
              .alignListItem(ListItemAlign.Center)
              .contentEndOffset(CONTENT_END_OFFSET_150)
              .padding({ right: PageMargin(this.widthBp, this.heightBp), left: PageMargin(this.widthBp, this.heightBp) })
              .chainAnimation(true)
              .nestedScroll({
                scrollForward: NestedScrollMode.PARENT_FIRST,
                scrollBackward: NestedScrollMode.SELF_FIRST
              })
            }
            .refreshOffset(64)
            .pullToRefresh(true)
            .onStateChange(() => {
              this.theNumberUpdated = 0
            })
            .onRefreshing(() => {
              this.updateGeoDate()
            })
            /*Scroll() {
            }
            .edgeEffect(this.uiConfig.isAnimation?EdgeEffect.Spring:null)//,{alwaysEnabled:true})
            .onDidScroll((xOffset: number, yOffset: number): void => {
              // 累计计算当前父组件滚动在Y轴方向的偏移量
              if (this.uiConfig.isAnimation){
                this.curYOffset += yOffset
              }
              console.info("yOffset" + this.curYOffset);
            })*/
          }
        }
      }.width('100%')
      .height('100%')
      .bindSheet($$this.isShowGroupSort, this.SortSheet(),
        {
          detents: [684, 300],
          dragBar: false,
          backgroundColor: $r('app.color.background'),
          preferType: SheetType.CENTER,
          onWillDismiss: () => {
            this.isShowGroupSort = false
            this.isEnableIndexForegroundBlur = false
          },
          onDisappear: () => {
          }
        })

    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.pageInfos.clear()
      this.isSecondary = false
      return true;
    })
  }
}

export default Resources

@Component
struct Sort {
  @Consume isShowGroupSort: Boolean
  @Consume resourceListData: Array<ResourcesData>
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  @State lastSortList: string = ''
  @State SortHideList: Array<ResourcesData> = resourcesBlankData
  // 拖拽项
  @State dragItem: ResourcesData | null = null
  // 被拖拽项的原始索引
  @State dragItemIndex: number = -1
  // 1表示GroupSortList，2表示GroupSortHideList
  @State currentList: number = 0
  @State isSave: boolean = false
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean

  // 定义一个空白的GroupSortListItemType作为占位符
  private placeholderItem: ResourcesData = {
    key: "NN",
    resourceName: '',
    fileName: "",
    resourceSize: 0,
    updateTime: 0,
  }

  aboutToAppear(): void {
    const lastData = JSON.stringify(this.resourceListData)
    this.lastSortList = lastData
    hilog.info(0xFF00, "ResourcestestTag", "上一次布局：%{public}s", this.lastSortList)
    this.SortHideList = JSON.parse(this.uiConfig.resourcesHideData)
  }
  aboutToDisappear(): void {
    if(!this.isSave) {
      hilog.info(0xFF00, "ResourcestestTag", "布局：%{public}s", this.lastSortList)
      this.resourceListData = JSON.parse(this.lastSortList)
      hilog.info(0xFF00, "ResourcestestTag", "布局：%{public}s", JSON.stringify(this.resourceListData))
    }
  }

  // 列表项Builder
  @Builder
  listItemBuilder(item: ResourcesData) {
    Row() {
      Text(item.resourceName)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_primary'))
      Blank()
      SymbolGlyph(item.key=== 'NN' ? undefined : $r('sys.symbol.sort'))
        .fontSize(24)
        .fontColor([$r('sys.color.font_primary')])
    }
    .width('100%')
    .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
    .padding({left: 12, right: 12, top: 16, bottom: 16})
  }

  // 拖拽预览Builder（与列表项相同）
  @Builder
  dragPreviewBuilder(text: string) {
    Row() {
      Text(text)
        .fontWeight(FontWeight.Medium)
      Blank()
      SymbolGlyph($r('sys.symbol.sort'))
        .fontSize(24)
    }
    .width(450)
    .borderRadius(BORDER_RADIUS_20)
    .backgroundColor($r('app.color.container_background'))
    .padding({left: 12, right: 12, top: 16, bottom: 16})
  }


  build() {
    Column({space: 8}) {
      // 标题栏
      Row() {
        // 保存按钮
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.save'))
            .fontSize(24)
            .fontColor([Color.White])
        }
        .width(40)
        .height(40)
        .margin({ top: 16 })
        .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
        .backgroundColor(this.icon_emphasize)
        .onClick(() => {
          this.isSave = true
          this.uiConfig.resourcesHideData = JSON.stringify(this.SortHideList)
          this.isShowGroupSort = false
          this.isEnableIndexForegroundBlur = false
          promptAction.showToast({message: $r('app.string.saved'), duration: 2000 })
        })
        Text(`${getResourceString($r('app.string.Resources'), this)}${getResourceString($r('app.string.sort'), this)}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({left: 8, top: 15 })
      }
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .height(56)

      // 展示中标题
      Text('展示中')
        .fontWeight(FontWeight.Normal)
        .fontSize(15)
        .fontColor($r('sys.color.font_secondary'))

      // 展示列表
      List({ space: 10 }) {
        if(this.resourceListData.length === 0) {
          ListItem() {
            Row().width('100%')
          }.width('100%').height(56)
        }
        ForEach(this.resourceListData, (item: ResourcesData, index) => {
          ListItem() {
            this.listItemBuilder(item)
          }
        }, (item: ResourcesData) => item.key)
      }.width('100%')
      .borderRadius(BORDER_RADIUS_20)
      .backgroundColor($r('app.color.container_background'))
      .onItemDragStart((event: ItemDragInfo, index: number) => {
        this.dragItem = this.resourceListData[index]
        this.currentList = 1
        this.resourceListData.splice(index, 1)
        return this.dragPreviewBuilder(this.dragItem.resourceName)
      })
      .onItemDrop((event: ItemDragInfo, itemIndex: number, insertIndex: number, isSuccess: boolean) => {
        this.handleDrop(1, insertIndex)
      })
      .onItemDragMove((event: ItemDragInfo, itemIndex: number, insertIndex: number) => {
        animateTo({
          duration: 300,
          curve: Curve.EaseInOut
        }, () => {
          this.updatePlaceholder(1, insertIndex)
        })
      })
      .onItemDragLeave(() => {
        this.removePlaceholderItem(1)
      })

      // 已隐藏标题
      Text('已隐藏')
        .fontWeight(FontWeight.Normal)
        .fontSize(15)
        .fontColor($r('sys.color.font_secondary'))

      // 隐藏列表
      List({ space: 10 }) {
        if(this.SortHideList.length === 0) {
          ListItem() {
            Row().width('100%')
          }.width('100%').height(56)
        }
        ForEach(this.SortHideList, (item: ResourcesData, index) => {
          ListItem() {
            this.listItemBuilder(item)
          }
        }, (item: ResourcesData) => item.key)
      }.width('100%')
      .borderRadius(BORDER_RADIUS_20)
      .backgroundColor($r('app.color.container_background'))
      .onItemDragStart((event: ItemDragInfo, index: number) => {
        this.dragItem = this.SortHideList[index]
        this.currentList = 2
        this.SortHideList.splice(index, 1)
        return this.dragPreviewBuilder(this.dragItem.resourceName)
      })
      .onItemDrop((event: ItemDragInfo, itemIndex: number, insertIndex: number, isSuccess: boolean) => {
        this.handleDrop(2, insertIndex)
      })
      .onItemDragMove((event: ItemDragInfo, itemIndex: number, insertIndex: number) => {
        animateTo({
          duration: 300,
          curve: Curve.Smooth
        }, () => {
          this.updatePlaceholder(2, insertIndex)
        })
      })
      .onItemDragLeave(() => {
        this.removePlaceholderItem(2)
      })


    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 12, right: 12 })

  }

  // 移除占位符项
  private removePlaceholderItem(currentList: number) {
    const targetArray = currentList === 1 ? this.resourceListData : this.SortHideList
    const placeholderIndex = targetArray.findIndex(item => item.key === 'NN')
    if (placeholderIndex !== -1) {
      targetArray.splice(placeholderIndex, 1)
    }
  }
  // 更新占位符位置
  private updatePlaceholder(currentList: number, insertIndex: number) {
    // 首先移除旧的占位符
    this.removePlaceholderItem(currentList)
    const targetArray = currentList === 1 ? this.resourceListData : this.SortHideList
    // 插入新的占位符
    targetArray.splice(insertIndex, 0, this.placeholderItem)
  }
  // 处理拖拽释放的事件
  private handleDrop(currentList: number, insertIndex: number) {
    if (this.dragItem) {
      // 移除占位符
      this.removePlaceholderItem(currentList)
      const targetArray = currentList === 1 ? this.resourceListData : this.SortHideList
      // 实际插入拖拽的项
      targetArray.splice(insertIndex, 0, this.dragItem)
      // 重置拖拽项
      this.dragItem = null
    }
  }

}

@Extend(Text)
function smallText() {
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .fontWeight(FontWeight.Normal)
  .fontSize(15)
  .maxLines(1)
}

@Extend(Button)
function ButtonStyle() {
  .width(40)
  .height(40)
  .backgroundColor($r('app.color.settings_container_background'))
}