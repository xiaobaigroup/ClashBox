import { BreakpointState } from "../../common/breakpointsystem"
import { BIND_SHEET_DRAG_BAR_HEIGHT, BORDER_RADIUS_20, CONTENT_END_OFFSET_110 } from "../../common/Constants"
import { Nothing, theCustomDialog } from "../Common"
import { MoreTop } from "./MoreTopBuilder"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { convertTime } from "../../utils/TimeConvertUtil"
import { ClashConfig } from 'proxy_core'
import { curves, promptAction } from '@kit.ArkUI'
import { copy, UIConfig } from '../../entryability/AppState'
import ClashViewModel from '../../entryability/ClashViewModel'
import { getResourceString } from "../../utils/ResourceStringUtil"
import { EventHub, EventKey } from "../../common/EventHub"
import { customAnimationUtil } from "../../utils/Animation"

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



@Component
struct Resources {
  // 是否进入二级界面
  @Consume isSecondary: boolean
  @Consume('NavPathStack') pageInfos: NavPathStack
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
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
  @State isLoading: boolean = false
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  // 临时数据
  @State
  private resourceListData: Array<ResourcesData> = [
    {
      key: "geoip",
      resourceName: 'GeoIp',
      fileName: "GeoIP.dat",
      resourceSize: 6543,
      updateTime: 1736990475781,
    },
    {
      key: "geosite",
      resourceName: 'GeoSite',
      fileName: "GeoSite.dat",
      resourceSize: 8654,
      updateTime: 1736990575781,
    },
    {
      key: "mmdb",
      resourceName: 'MMDB',
      fileName: "geoip.metadb",
      resourceSize: 8654,
      updateTime: 1736990575781,
    },
    {
      key: "asn",
      resourceName: 'ASN',
      fileName: "ASN.mmdb",
      resourceSize: 8654,
      updateTime: 1736990575781,
    }
  ]

  @Builder
  reaourceSearch() {
  }
  @Builder
  reaourceOther() {
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
        // 关闭背景模糊
        this.isEnableIndexForegroundBlur = false
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
    this.updateUrl(editItem.resourceName, this.SaveEditInputValue)
    this.resourceListData.splice(this.theEditIndex, 1, editItem)
  }
  updateUrl(name: string, url: string){
    let geoMap = this.clashConfig?.['geox-url']
    if(geoMap){
      geoMap[name] = url
      this.clashConfig['geox-url'] = copy(geoMap)
    }
    EventHub.sendEvent(EventKey.LoadClashConfig)
  }

  async updateGeoDateItem(item: ResourcesData){
    this.isLoading = true
    try {
      const message = await ClashViewModel.updateGeoData(
         item.resourceName,
         item.fileName,
      );
      this.isLoading = false
      if (message != "") {
        promptAction.showToast({ message: getResourceString($r('app.string.update_failed'), this) +" " + message })
      }
      else {
        promptAction.showToast({ message: getResourceString($r('app.string.update_success'), this) })
      }
    } catch (e) {
      this.isLoading = false
      promptAction.showToast({message: getResourceString($r('app.string.update_failed'), this) + (e.message | e)})
    }
  }

  build() {
    NavDestination() {
      Stack() {
        if(this.isLoading) {
          // 加载动画
          Column() {
            LoadingProgress()
              .color(this.icon_emphasize)
              .width(80).height(80)
            Text('资源更新中..')
              .fontSize(16)
          }.zIndex(2)
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor(Color.Transparent)
        }
        Column() {
          Row() {
            MoreTop({
              title: $r('app.string.Resources'),
              searchButton: this.reaourceSearch,
              otherButton: (): void => { this.reaourceOther() }
            })
          }.width('100%')
          .padding({right: this.morePageMargin.value, left: this.morePageMargin.value})
          .transition(customAnimationUtil.isSlide(200,this.uiConfig))
          // 页面
          if(this.resourceListData.length === 0) {
            Nothing({ name: $r('app.string.Resources') })
          } else {
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
                        .fontColor([this.icon_primary])
                    }.ButtonStyle().margin({ right: 12 })
                    .onClick(() => {
                      hilog.info(0xFF00, "ResourcestestTag", "已点击")
                      // 启用背景模糊
                      this.isEnableIndexForegroundBlur = true
                      // 进入列表行数据编辑
                      this.currentEditInputValue = this.clashConfig?.['geox-url']?.[item.key] ?? ""
                      this.theEditIndex = index
                      hilog.info(0xFF00, "ResourcestestTag", "编辑中的序号：%{public}d", this.theEditIndex)
                      hilog.info(0xFF00, "ResourcestestTag", "编辑中的链接：%{public}s", this.currentEditInputValue)
                      this.editDialogController.open()
                    })
                    // 更新按钮
                    Button({ type: ButtonType.Circle, stateEffect: true }) {
                      SymbolGlyph($r('sys.symbol.arrow_clockwise'))
                        .fontSize(24)
                        .fontColor([this.icon_primary])
                    }.ButtonStyle()
                    .onClick(() => {
                      // 资源更新处理
                      this.updateGeoDateItem(item)
                    })
                  }.width('100%')
                  .padding(12)
                  .justifyContent(FlexAlign.Center)
                  .width('100%')
                  .backgroundColor($r('app.color.container_background'))
                  .borderRadius(BORDER_RADIUS_20)
                }.width('100%')
                .transition(customAnimationUtil.isScaleTran(index,this.uiConfig))
              })
            }.width('100%')
            .height('100%')
            .contentEndOffset(CONTENT_END_OFFSET_110)
            .padding({right: this.morePageMargin.value, left: this.morePageMargin.value})
          }
        }.width('100%')
        .height('100%')
      }.width('100%')
      .height('100%')
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
  .clickEffect({ level: ClickEffectLevel.LIGHT })
  .backgroundColor($r('app.color.settings_container_background'))
}