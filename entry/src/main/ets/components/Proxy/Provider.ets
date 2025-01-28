import { BreakpointState } from "../../common/breakpointsystem"
import { ANIMATION_DURATION_300, BORDER_RADIUS_20 } from "../../common/Constants"
import { Nothing, theCustomDialog } from "../Common"
import { convertTime } from "../../utils/TimeConvertUtil"
import { ClashConfig } from 'proxy_core'
import ClashViewModel from '../../entryability/ClashViewModel'
import { Provider } from "proxy_core"
import { hilog } from "@kit.PerformanceAnalysisKit"


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
  @Watch('loadingChange')
  @State isLoading: number = -1;
  @Watch('loadingChange')
  @State isLoadingAll: number = -1;
  @StorageLink('clashConfig') clashConfig: ClashConfig = new ClashConfig()
  // 临时数据
  @State
  private resourceListData: Array<Provider> = [ ]
  @Consume isProviderEdit: boolean
  //fl clash条目数量判定
  @State entriesNumber:number =0
  /* 是否开启全局动画判定 */
  @Consume ('isAnimation') isAnimation: boolean

  /**
   * 监听加载状态改变执行UI数组更新
   */
  async loadingChange(): Promise<void> {
    if(this.isLoading === -1) {
      hilog.debug(0xFF00, "ProvidertestTag", "进入loadingChange状态改变执行 %{public}s")
      const newlist = await ClashViewModel.getProviders()
      this.resourceListData = newlist
      hilog.debug(0xFF00, "ProvidertestTag", "getProviders: %{public}s", JSON.stringify(newlist))
    }
  }

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
      Column(){
        //顶部半模拟态标题及按钮
        this.titleStyle()

        List() {
          ListItem(){
            // 代理提供者相关
            if (this.resourceListData.length === 0) {
              Nothing({ name: $r('app.string.Resources') })
            } else {
              Column({ space: 8 }) {
                //副标题
                Text( $r('app.string.proxy_provider') )
                  .subtitleText()

                List({ space: 8 }) {
                  ForEach(this.resourceListData, (item: Provider, index: number) => {
                    if (item.type === "Proxy") {
                      ListItem() {
                        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
                          // 文本显示区
                          Column({ space: 2 }) {
                            Text(item.name)
                              .nameText()

                            Row() {
                              Text($r('app.string.update_by'))
                                .smallText()
                              Text(convertTime(item["update-at"]))
                                .smallText()
                              //clash meta 暂无此数据，TODO 后期fl clash接入后可改
                              if (this.entriesNumber>0) {
                                Text('.')
                                  .smallText()
                                Text($r('app.string.list_item_number'))
                                  .smallText()
                              }
                            }

                            Row(){
                              if (item["subscription-info"]?.download != undefined) {
                                Text(item["subscription-info"]?.download+'/')
                                  .smallText()
                              }else {
                                Text($r('app.string.usd_cellular_data'))
                                  .smallText()
                              }
                              if (item["subscription-info"]?.total != undefined) {
                                Text(item["subscription-info"]?.total.toString())
                                  .smallText()
                              }else {
                                Text($r('app.string.total_cellular_data'))
                                  .smallText()
                              }
                            }.padding({bottom:4})

                            //
                            Column() {
                              Progress({
                                value: item["subscription-info"]?.download,
                                total: item["subscription-info"]?.total,
                                type: ProgressType.Capsule
                              })//value为使用流量的值
                                .style({enableSmoothEffect: true,borderColor:'#00ffffff'})
                                .color('#ff46b1e3')
                                .width('100%')
                                .height('100%')
                            }
                            .width('100%')
                            .backgroundColor('#4d46b1e3')
                            .height(6)
                            .borderRadius(6)

                            //       Text(item.path)
                            //        .smallText()
                          }.height(87).textColumn()

                          Divider().strokeWidth(1).color($r('app.color.divider'))

                          Row({space:8}) {
                            // 功能按钮区
                            // 上传按钮
                            Button({ type: ButtonType.Normal, stateEffect: true }) {
                              Row({space:4.67}) {
                                SymbolGlyph($r('sys.symbol.arrowshape_up_to_line_fill'))
                                  .fontSize(14.67)
                                  .fontColor([this.icon_emphasize])
                                Text($r('app.string.upload')).fontSize(12).fontColor(this.icon_emphasize)
                              }
                            }.ButtonStyle()
                            .width(76)
                            .height(28)
                            .onClick(() => {
                              this.theEditIndex = index
                              //  this.editDialogController.open()   //改为了上传按钮 TODO 上传按钮暂无后端相关参数
                            })

                            // 更新按钮
                            Button({ type: ButtonType.Normal, stateEffect: true }) {
                              if (this.isLoading ===index ||this.isLoadingAll ===this.resourceListData.length) {
                                Row({ space: 4.67 }) {
                                  LoadingProgress()
                                    .color(this.icon_emphasize)
                                    .width(20).height(20)
                                  Text($r('app.string.updating')).fontSize(12).fontColor(this.icon_emphasize)
                                }
                                .width(100)
                                .height(28)
                                .justifyContent(FlexAlign.Center)
                              } else{
                                Row({ space: 4.67 }) {
                                  SymbolGlyph($r('sys.symbol.arrow_clockwise'))
                                    .fontSize(14.67)
                                    .fontColor([this.icon_emphasize])
                                  Text($r('app.string.update')).fontSize(12).fontColor(this.icon_emphasize)
                                }
                                .width(76)
                                .height(28)
                                .justifyContent(FlexAlign.Center)
                              }
                            }.ButtonStyle()
                            .onClick(() => {
                              // 资源更新处理
                              ClashViewModel.updateProvider(item).then((result) => {
                                this.isLoading = -1
                              }).catch((error: Error) => {
                                this.isLoading = -1
                              })
                              animateTo({
                                duration: ANIMATION_DURATION_300,
                                curve: Curve.Friction,
                                iterations: 1, // 设置-1表示动画无限循环
                              }, () => {
                                this.isLoading = index
                              })
                            })
                          }.buttonColumn()
                        }
                        .listFlex()
                      }
                //      .transition(this.isAnimation ?TransitionEffect.OPACITY.animation({ duration: ANIMATION_DURATION_300, delay: 0 })
                 //       .combine(TransitionEffect.SLIDE):null)
                    }
                  })
                }.providerList()


                //规则提供者相关
                //副标题
                Text($r('app.string.rule_provider'))
                  .subtitleText()

                List({ space: 8 }) {
                  ForEach(this.resourceListData, (item: Provider, index: number) => {
                    if (item.type === "Rule") {
                      ListItem() {
                        Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Start, justifyContent: FlexAlign.Start }) {
                          // 文本显示区
                          Column({space:2}){
                            Text(item.name)
                              .nameText()

                            Row({ space: 2 }) {
                              Text($r('app.string.update_by'))
                                .smallText()
                              Text(convertTime(item["update-at"]))
                                .smallText()
                              //clash meta 暂无此数据，TODO 后期fl clash接入后可改
                              if (this.entriesNumber>0) {
                                Text('.')
                                  .smallText()
                                Text(''+ $r('app.string.list_item_number'))
                                  .smallText()
                              }
                            }
                          }.height(53).textColumn()

                          Divider().strokeWidth(1).color($r('app.color.divider'))
                          //      Text(item.path)
                          //        .smallText().margin({ bottom: 8 })

                          Row({space:8}) {
                            // 功能按钮区
                            // 上传按钮
                            Button({ type: ButtonType.Normal, stateEffect: true }) {
                              Row({space:4.67}) {
                                SymbolGlyph($r('sys.symbol.arrowshape_up_to_line_fill'))
                                  .fontSize(14.67)
                                  .fontColor([this.icon_emphasize])
                                Text($r('app.string.upload')).fontSize(12).fontColor(this.icon_emphasize)
                              }
                            }.ButtonStyle()
                            .width(76)
                            .height(28)
                            .onClick(() => {
                              this.theEditIndex = index
                              //  this.editDialogController.open()   //改为了上传按钮 TODO 上传按钮暂无后端相关参数
                            })

                            // 更新按钮
                            Button({ type: ButtonType.Normal, stateEffect: true }) {
                              if (this.isLoading ===index || this.isLoadingAll ===this.resourceListData.length) {
                                Row({ space: 4.67 }) {
                                  LoadingProgress()
                                    .color(this.icon_emphasize)
                                    .width(20).height(20)
                                  Text($r('app.string.updating')).fontSize(12).fontColor(this.icon_emphasize)
                                }
                                .width(100)
                                .height(28)
                                .justifyContent(FlexAlign.Center)
                              } else{
                                  Row({ space: 4.67 }) {
                                  SymbolGlyph($r('sys.symbol.arrow_clockwise'))
                                    .fontSize(14.67)
                                    .fontColor([this.icon_emphasize])
                                  Text($r('app.string.update')).fontSize(12).fontColor(this.icon_emphasize)
                                }
                                  .width(76)
                                  .height(28)
                                  .justifyContent(FlexAlign.Center)
                              }
                            }.ButtonStyle()
                            .onClick(() => {
                              // 资源更新处理
                              ClashViewModel.updateProvider(item).then((result) => {
                                this.isLoading = -1
                              }).catch((error: Error) => {
                                this.isLoading = -1
                              })
                              // 建议使用this.getUIContext()?.animateTo()
                              animateTo({
                                duration: ANIMATION_DURATION_300,
                                curve: Curve.Friction,
                                iterations: 1, // 设置-1表示动画无限循环
                              }, () => {
                                this.isLoading = index
                              })
                            })
                          }.buttonColumn()
                        }
                        .listFlex()
                      }
                   //   .transition(this.isAnimation ?TransitionEffect.OPACITY.animation({ duration: ANIMATION_DURATION_300, delay: 0 })
                  //      .combine(TransitionEffect.SLIDE):null)
                    }
                  })
                }
                .providerList()
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
          }
        }.width('100%')
        .contentEndOffset(150)
        .scrollBar(BarState.Off)
      }
    }.width('100%')
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      return true;
    })
  }

  //顶部半模拟态标题及按钮
  @Builder
  titleStyle(){
    //顶部标题区域
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Text($r('app.string.provider'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .maxLines(1)
        .fontColor($r('sys.color.font_primary'))

      Row({space:10}){
        //全部更新按钮
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.arrow_clockwise'))
            .fontSize(24)//      .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)//分层颜色
            .fontColor([this.icon_primary])
        }
        .width(40)
        .height(40)
        .backgroundColor($r('app.color.settings_container_background'))
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .onClick(() => {
          animateTo({
            duration: ANIMATION_DURATION_300,
            curve: Curve.Friction,
            iterations: 1, // 设置-1表示动画无限循环
          }, () => {
            this.resourceListData.forEach((item: Provider) => {
              convertTime(item["update-at"])
              this.isLoadingAll =this.resourceListData.length
              ClashViewModel.updateProvider(item).then((result) => {
                this.isLoadingAll = -1
              }).catch((error: Error) => {
                this.isLoadingAll = -1
              })
            })
          })

        })

        //关闭按钮
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          SymbolGlyph($r('sys.symbol.xmark'))
            .fontSize(24)//      .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)//分层颜色
            .fontColor([this.icon_primary])
        }
        .width(40)
        .height(40)
        .backgroundColor($r('app.color.settings_container_background'))
        .clickEffect({ level: ClickEffectLevel.MIDDLE })
        .onClick(() => {
          this.isProviderEdit = false
          this.isEnableIndexForegroundBlur=false
        })
      }
    }.width('100%').height(56).margin({top:8})
  }
}

//副文本样式
@Extend(Text)
function smallText() {
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .fontWeight(FontWeight.Normal)
  .fontSize(14)
  .maxLines(1)
  .fontColor($r('sys.color.font_secondary'))
}

//副标题文本样式
@Extend(Text)
function subtitleText() {
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .fontWeight(FontWeight.Normal)
  .fontSize(16)
  .fontColor($r('sys.color.font_secondary'))
  .maxLines(1)
}

//名字文本样式
@Extend(Text)
function nameText() {
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .fontWeight(FontWeight.Bold)
  .fontSize(16)
  .fontColor($r('sys.color.font_primary'))
  .maxLines(1)
}

//列表样式
@Extend(List)
function providerList() {
  .scrollBar(BarState.Off)
  .width('100%')
  .enableScrollInteraction(false)
}

//右上角按钮样式
@Extend(Button)
function ButtonStyle() {
  .borderRadius(14)
  .clickEffect({ level: ClickEffectLevel.LIGHT })
  .backgroundColor($r('app.color.button_container_background'))
  .animation({ duration: ANIMATION_DURATION_300, curve: Curve.Ease })
}

//文本竖排组件样式
@Extend(Column)
function textColumn() {
  .width('100%')
  .alignItems(HorizontalAlign.Start)
  .justifyContent(FlexAlign.Center)
}

//按钮横排组件样式
@Extend(Row)
function buttonColumn() {
  .width('100%')
  .height(44)
  .alignItems(VerticalAlign.Center)
  .justifyContent(FlexAlign.Start)
}

//flex组件样式
@Extend(Flex)
function listFlex() {
  .width('100%')
  .padding({ left: 12, right: 12 })
  .backgroundColor($r('app.color.container_background'))
  .borderRadius(BORDER_RADIUS_20)
}

