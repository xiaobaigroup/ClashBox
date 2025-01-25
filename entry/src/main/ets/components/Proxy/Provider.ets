import { BreakpointState } from "../../common/breakpointsystem"
import {  BORDER_RADIUS_20 } from "../../common/Constants"
import { Nothing, theCustomDialog } from "../Common"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { convertTime } from "../../utils/TimeConvertUtil"
import { ClashConfig } from 'proxy_core'
import ClashViewModel from '../../entryability/ClashViewModel'
import { Provider } from "proxy_core"

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
export struct ProviderPage {
  @Consume('breakPointStatemorePageMargin') morePageMargin: BreakpointState<number>
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
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
  private resourceListData: Array<Provider> = [ ]

  async aboutToAppear(): Promise<void> {
    const list = await ClashViewModel.getProviders()
    this.resourceListData = list
    console.debug("getProviders", JSON.stringify(list))
  }
  /**
   * 资源编辑弹窗控制器
   */
  editDialogController: CustomDialogController = new CustomDialogController({
    builder: theCustomDialog({
      theplaceholder: $theEditIndex,
      currentInputValue: $currentEditInputValue,
      SaveInputValue: $SaveEditInputValue,
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
    editItem.path = this.SaveEditInputValue
    this.resourceListData.splice(this.theEditIndex, 1, editItem)
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
          // 页面
          if(this.resourceListData.length === 0) {
            Nothing({ name: $r('app.string.Resources') })
          } else {
            List({ space: 10 }) {
              ForEach(this.resourceListData, (item: Provider, index: number) => {
                ListItem() {
                  Row() {
                    // 文本显示区
                    Column() {
                      Text(item.name)
                        .fontWeight(FontWeight.Bold)
                        .margin({ bottom: 2 })
                        .fontSize(17)
                      Column() {
                        Row({ space: 2 }) {
                          Text(item.type + "/" + item["vehicle-type"])
                            .smallText()
                          Text()
                            .smallText()
                          Text(convertTime(item["update-at"]))
                            .smallText()
                        }.justifyContent(FlexAlign.Start)
                        Text(item.path)
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
                      this.theEditIndex = index
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
                      // TODO  添加 loading
                      ClashViewModel.updateProvider(item)
                    })
                  }.width('100%')
                  .padding(12)
                  .justifyContent(FlexAlign.Center)
                  .width('100%')
                  .backgroundColor($r('app.color.container_background'))
                  .borderRadius(BORDER_RADIUS_20)
                }.width('100%')
              })
            }.width('100%')
            .height('100%')
          }
        }.width('100%')
        .height('100%')
        .padding({right: this.morePageMargin.value, left: this.morePageMargin.value})
      }.width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      return true;
    })
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
  .clickEffect({ level: ClickEffectLevel.LIGHT })
  .backgroundColor($r('app.color.settings_container_background'))
}