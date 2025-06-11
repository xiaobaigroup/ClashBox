import { BreakpointState } from "../../common/breakpoint/breakpointsystem"
import {
  BIND_SHEET_CONTAINER_HEIGHT,
  BIND_SHEET_DRAG_BAR_HEIGHT, BIND_SHEET_TITLE_CONTAINER_HEIGHT,
  BORDER_RADIUS_20,
  TAB_CONTENT_TITLE_HEIGHT } from "../../common/entity/Constants"
import { skipRowList, toggleRowList } from "../Common/Common"
import { MoreTop } from "./MoreTopBuilder"
import { curves, promptAction, SymbolGlyphModifier } from "@kit.ArkUI"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { UIConfig } from "../../entryability/AppState"
import { customAnimationUtil } from "../../common/utils/Animation"
import { PageMargin } from "../../common/breakpoint/BreakPoint"

/**
 *
 * 暂时屏蔽，等待API更新支持
 *
 */
@Component
struct Diversion {
  // 是否进入二级界面
  @Consume isSecondary: boolean
  // 添加or编辑策略判断变量
  @State isAdd: boolean = false
  // 资源删除判断变量
  @State isDelete: boolean = false
  // 选中的列表行
  @State SelectedListItem: number = 0
  // 添加&编辑策略半模态页展示变量
  @State isShowPolicy: boolean = false
  @Consume('NavPathStack') pageInfos: NavPathStack
  // 保存的分流策略名
  @State SaveNameInputValue: string = ''
  // 保存的资源路径
  @State SavePathInputValue: string = ''
  // 自动更新启用变量
  @State EnabledAutoUpdate: boolean = false
  // 插入资源启用变量
  @State EnabledInsertResource: boolean = false
  // 分流策略数据表
  @State DiversionList: DiversionData[] = createDiversionData()
  // 一级图标色，黑色
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary')
  // 手机横屏判断变量
  @StorageLink ('isLandscapePhone') private isLandscapePhone: boolean = false
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  // 是否开启 `Index` 页面的前景模糊
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  //page内顶部标题偏移量
  @Consume curYOffset: number

  @Builder
  diversionOther() {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph()
        .fontSize(24)
        .fontColor([this.icon_primary])
    }
    .transition(customAnimationUtil.isSlide(0,this.uiConfig))
    .width(40)
    .height(40)
    .backgroundColor($r('app.color.settings_container_background'))
    .onClick(() => {

    })
  }

  /**
   * 添加&编辑半模态弹窗
   */
  @Builder
  PolicySheet() {
    Column() {
      Policy({
        isAdd: this.isAdd,
        isDelete: this.isDelete,
        isShowPolicy: this.isShowPolicy,
        SaveNameInputValue: this.SaveNameInputValue,
        SavePathInputValue: this.SavePathInputValue,
        SelectedListItem: this.SelectedListItem,
        DiversionList: this.DiversionList
      })
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 列表行删除
   */
  onDelete() {
    hilog.info(0xFF00, "DiversionDeletetestTag", "删除状态 %{public}s", this.isDelete)
    if(this.isDelete) {
      this.DiversionList.splice(this.SelectedListItem, 1)
      this.isDelete = false
      hilog.info(0xFF00, "DiversionDeletetestTag", "已删除 %{public}s", this.isDelete)
    }
  }

  /**
   * 功能菜单
   */
  @Builder
  FunctionMenu() {
    Menu() {
      MenuItem({
        content: $r('app.string.update'),
        symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.arrow_clockwise'))
      }).onClick(() => [
        // 更新

      ])
      MenuItem({
        content: $r('app.string.delete'),
        symbolStartIcon: new SymbolGlyphModifier($r('sys.symbol.trash_fill')).fontColor([Color.Red])
      }).labelFontColor(Color.Red)
        .onClick(() => {
          this.isDelete = true
          this.onDelete()
        })
    }
  }

  build() {
    NavDestination() {
      Stack() {
          MoreTop({
            title: $r('app.string.Diversion_Strategy'),
            icon2: $r('sys.symbol.plus'),
            onClick2: () => {
              this.isAdd = true
              // 启用背景模糊
              this.isEnableIndexForegroundBlur = true
              this.isShowPolicy = true
            }
          })

        Column() {
          Blank().height(TAB_CONTENT_TITLE_HEIGHT+6)
          Scroll() {
            // 数据列表行
            List({space: 12}) {
              ForEach(this.DiversionList, (item: DiversionData, index: number) => {
                ListItem() {
                  Row() {
                    Row() {
                      Text(item.name)
                        .fontWeight(FontWeight.Medium)
                        .fontSize(16)
                        .margin({ left: 12 })
                      Blank()
                      SymbolGlyph($r('sys.symbol.chevron_right'))
                        .fontColor([this.icon_primary])
                        .fontSize(28)
                        .margin({ right: 12 })
                    }
                    .width('100%')
                    .height(53)
                    .borderRadius(BORDER_RADIUS_20)
                    .backgroundColor($r('app.color.container_background'))

                    Row()
                      .height(10)
                  }

                }
                .transition(customAnimationUtil.isScaleTran(index, this.uiConfig))
                .onClick(() => {
                  // 启用背景模糊
                  this.isEnableIndexForegroundBlur = true
                  this.SelectedListItem = index
                  // 进入列表行数据编辑半模态页
                  this.isShowPolicy = true
                })
                .bindContextMenu(this.FunctionMenu, ResponseType.LongPress, {
                  preview: MenuPreviewMode.IMAGE,
                  onAppear: (() => {
                    this.SelectedListItem = index
                  }),
                  previewAnimationOptions: {
                    scale: [0.95, 1.0],
                    transition: this.uiConfig.isAnimation ? TransitionEffect.prototype.animation({ tempo: 1.5 }) :
                      undefined
                  }
                })

              })

            }
            .width('100%')
            .borderRadius(BORDER_RADIUS_20)
            .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
            .alignListItem(ListItemAlign.Center)
            .height(this.isLandscapePhone ? 275 : 650)
            .bindSheet($$this.isShowPolicy, this.PolicySheet(),
              {
                detents: [BIND_SHEET_CONTAINER_HEIGHT, SheetSize.LARGE],
                dragBar: false,
                backgroundColor: $r('app.color.background'),
                scrollSizeMode: ScrollSizeMode.CONTINUOUS,
                //keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
                preferType: SheetType.CENTER,
                onWillDismiss: () => {
                  this.isShowPolicy = false
                  this.isEnableIndexForegroundBlur = false
                  // 置空文本保存变量
                  this.SaveNameInputValue = ''
                  this.SavePathInputValue = ''
                  if (this.isAdd) {
                    this.isAdd = false
                  }
                },
                onDisappear: () => {
                  // 等待半模态窗口完全退出后删除列表行
                  if (this.isDelete) {
                    setTimeout(() => {
                      this.onDelete()
                    }, 20)
                  }
                }
              })
            .chainAnimation(true)
            .nestedScroll({
              scrollForward: NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            })
          }
          .edgeEffect(this.uiConfig.isAnimation?EdgeEffect.Spring:null)//,{alwaysEnabled:true})
          .onDidScroll((xOffset: number, yOffset: number): void => {
            // 累计计算当前父组件滚动在Y轴方向的偏移量
            if (this.uiConfig.isAnimation){
              this.curYOffset += yOffset
            }
            console.info("yOffset" + this.curYOffset);
          })
        }
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      this.pageInfos.clear();
      this.isSecondary = false
      return true;
    })
  }
}

export default Diversion

@Component
struct Policy {
  @Link isAdd: boolean
  @State isSave: boolean = false
  @Link isDelete: boolean
  @Link isShowPolicy: boolean
  // 选中的列表行
  @Link SelectedListItem: number
  // 保存的分流策略名
  @Link SaveNameInputValue: string
  // 保存的资源路径
  @Link SavePathInputValue: string
  // 分流策略数据表
  @Link DiversionList: DiversionData[]
  // 自动更新启用变量
  @State EnabledAutoUpdate: boolean = false
  // 插入资源启用变量
  @State EnabledInsertResource: boolean = false
  // 一级图标色，黑色
  @State save_icon: ResourceColor = $r('app.color.container_background')
  // 主题色
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 是否开启 `Index` 页面的前景模糊
  @Consume('isEnableIndexForegroundBlur') isEnableIndexForegroundBlur: boolean
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()

  @Builder
  AutoTipsText() {
  }
  @Builder
  DeleteTipsText() {
  }

  saveValue() {
    const itemData: DiversionData = new DiversionData(
      this.SaveNameInputValue,
      this.SavePathInputValue,
      this.EnabledAutoUpdate,
      this.EnabledInsertResource)
    if(this.isAdd) {
      this.DiversionList = [...this.DiversionList, itemData]
    } else {
      this.DiversionList.splice(this.SelectedListItem, 1, itemData)
    }
  }

  build() {
    Column({space: 10}) {
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
        .margin({ top: BIND_SHEET_DRAG_BAR_HEIGHT })
        .clickEffect({ level: ClickEffectLevel.LIGHT })
        .backgroundColor(this.icon_emphasize)
        .onClick(() => {
          this.isSave = true
          this.saveValue()
          // 关闭半模态窗口
          this.isShowPolicy = false
          this.isEnableIndexForegroundBlur = false
          this.isAdd = false
          // 置空文本保存变量
          this.SaveNameInputValue = ''
          this.SavePathInputValue = ''
          promptAction.showToast({message: $r('app.string.saved'), duration: 2000 })
        })
        Text(this.isAdd ? $r('app.string.add_policy') : $r('app.string.edit_policy'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({left: 8, top: 15 })
      }
      .alignItems(VerticalAlign.Center)
      .width('100%')
      .height(BIND_SHEET_TITLE_CONTAINER_HEIGHT)
      // 功能区 Start
      Text($r('app.string.policy_name'))
        .fontWeight(FontWeight.Normal)
        .fontSize(15)
      TextInput({
        placeholder: $r('app.string.policy_name_placeholder'),
        text: this.isAdd ? undefined : this.DiversionList[this.SelectedListItem].name
      })
        .onChange((value: string) => {
          this.SaveNameInputValue = value
          hilog.info(0xFF00, "DiversiontestTag", "保存的策略名1：%{public}s", this.SaveNameInputValue)
        })
      Text($r('app.string.resource_path'))
        .fontWeight(FontWeight.Normal)
        .fontSize(15)
      // 资源路径
      Row({space: 4}) {
        TextInput({
          placeholder: $r('app.string.resource_path_placeholder'),
          text: this.isAdd ? undefined : this.DiversionList[this.SelectedListItem].url
        })
          .layoutWeight(1)
          .onChange((value: string) => {
            this.SavePathInputValue = value
            hilog.info(0xFF00, "DiversiontestTag", "保存的资源路径1：%{public}s", this.SavePathInputValue)
          })
        // 选择文件按钮
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.folder'))
            .fontSize(24)
            .fontColor([Color.White])
        }
        .width(40)
        .height(40)
        .clickEffect({ level: ClickEffectLevel.LIGHT })
        .backgroundColor(this.icon_emphasize)
        .onClick(() => {

        })
      }.height(40).width('100%')
      .alignItems(VerticalAlign.Center)
      // 插入资源
      Row() {
        toggleRowList({
          title: $r('app.string.insert_resource'),
          subtitle: $r('app.string.insert_resource_subtitle')
        }) {
          // 插入资源开关
          Toggle({ type: ToggleType.Switch, isOn: $$this.EnabledInsertResource })
            .selectedColor(this.icon_emphasize)
            .margin({right: 12})
            .hitTestBehavior(HitTestMode.None)
            // .onChange((isOn: boolean) => {
            //   // 启用插入资源 显式动画
            //   this.getUIContext()?.animateTo({
            //     duration: this.uiConfig.animationSpeed ,
            //     curve: Curve.Ease
            //   }, () => {
            //     this.EnabledInsertResource = isOn
            //   })
            // })
        }
      }.onClick(() => {
        this.getUIContext()?.animateTo({
          duration: this.uiConfig.animationSpeed ,
        }, () => {
          this.EnabledInsertResource = !this.EnabledInsertResource
        })
      })
      // 自动更新
      Column() {
        Row() {
          toggleRowList({
            title: $r('app.string.auto_update')
          }) {
            // 自动更新开关
            Toggle({ type: ToggleType.Switch, isOn: $$this.EnabledAutoUpdate })
              .selectedColor(this.icon_emphasize)
              .margin({right: 12})
              .hitTestBehavior(HitTestMode.None)
              // .onChange((isOn: boolean) => {
              //   // 启用自动更新 显式动画
              //   this.getUIContext()?.animateTo({
              //     duration: this.uiConfig.animationSpeed ,
              //     curve: Curve.Ease
              //   }, () => {
              //     this.EnabledAutoUpdate = isOn
              //   })
              // })
          }
        }.onClick(() => {
          this.getUIContext()?.animateTo({
            duration: this.uiConfig.animationSpeed ,
          }, () => {
            this.EnabledAutoUpdate = !this.EnabledAutoUpdate
          })
        })
        // 分割线
        Row().height(0.5).backgroundColor('#0D000000').width('93%')
        // 自动更新间隔
        skipRowList({
          title: $r('app.string.auto_update_interval'),
          tips: (): void => { this.AutoTipsText() },
          isExperimentalFunction: false
        })
          .onClick(() => {

          })
      }.width('100%')
      .borderRadius(BORDER_RADIUS_20)
      .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
      .backgroundColor($r('app.color.container_background'))
      // 删除资源
      if (!this.isAdd) {
        Row() {
          Text($r('app.string.delete_resource'))
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.Red)
            .margin({left: 12})
            .fontSize(16)
        }.width('100%')
        .height(53)
        .borderRadius(BORDER_RADIUS_20)
        .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
        .backgroundColor($r('app.color.container_background'))
        .onClick(() => {
          // 删除资源，在半模态窗口关闭后删除数组元素
          this.isDelete = true
          // 关闭半模态窗口
          this.isShowPolicy = false
          this.isEnableIndexForegroundBlur = false
          // 置空文本保存变量
          this.SaveNameInputValue = ''
          this.SavePathInputValue = ''
          this.isAdd = false
        })
      }
      // 功能区 End
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: PageMargin(this.widthBp, this.heightBp), right: PageMargin(this.widthBp, this.heightBp) })
    .onAppear(() => {
      this.EnabledAutoUpdate = this.DiversionList[this.SelectedListItem].isAutoUpdate
      this.EnabledInsertResource = this.DiversionList[this.SelectedListItem].isInsert
    })
  }
}


/**
 * 分流策略列表数据类
 */
class DiversionData {
  name: string
  url: string
  isInsert: boolean
  isAutoUpdate: boolean

  constructor(name: string, url: string, isInsert: boolean, isAutoUpdate: boolean ) {
    this.name = name
    this.url = url
    this.isInsert = isInsert
    this.isAutoUpdate = isAutoUpdate
  }
}

// 临时数据
const createDiversionData = (): DiversionData[] => {
  let result: DiversionData[] = new Array()
  result = [
    new DiversionData('Youtube', 'https://youtube.com', false, false),
    new DiversionData('名称', 'https://xxx', false, false),

  ]
  return result
}
