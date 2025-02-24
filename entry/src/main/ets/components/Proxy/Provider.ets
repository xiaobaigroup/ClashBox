import { BreakpointState } from "../../common/breakpointsystem"
import { BIND_SHEET_TITLE_CONTAINER_HEIGHT, BORDER_RADIUS_20, CONTENT_END_OFFSET_150 } from "../../common/Constants"
import { cellularData, Nothing, proxyBindSheetTitleStyle, theCustomDialog } from "../Common"
import { convertTime } from "../../utils/TimeConvertUtil"
import { ClashConfig, SubscriptionInfo } from 'proxy_core'
import ClashViewModel from '../../entryability/ClashViewModel'
import { Provider } from "proxy_core"
import { hilog } from "@kit.PerformanceAnalysisKit"
import { isEnd, UIConfig } from "../../entryability/AppState"
import { picker } from "@kit.CoreFileKit"
import { customAnimationUtil, isON } from "../../utils/Animation"

/**
 * 提供者
 */
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
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  // 提供者数据
  @State
  public providerListData: Array<Provider> = []
  //fl clash条目数量判定
  @State entriesNumber: number = 0
  //开关不触发list转场动画判定
  @State isON: isON = new isON()
  //副标题是否显示
  @State textTwoTitle: boolean = true
  // 内容外边距
  @Consume('breakPointStateTabContentTitleMargin')
  private breakPointStateTabContentTitleMargin: BreakpointState<number>

  /**
   * 监听加载状态改变执行UI数组更新
   */
  async loadingChange(): Promise<void> {
    if (this.isLoading === -1) {
      hilog.debug(0xFF00, "ProvidertestTag", "进入loadingChange状态改变执行 %{public}s")
      const newlist = await ClashViewModel.getProviders()
      this.providerListData = newlist
      hilog.debug(0xFF00, "ProvidertestTag", "getProviders: %{public}s", JSON.stringify(newlist))
    }
  }

  async aboutToAppear(): Promise<void> {
    const list = await ClashViewModel.getProviders()
    this.providerListData = list
    console.debug("getProviders", JSON.stringify(list))
  }

  uploadProvider(item: Provider) {
    let filePicker = new picker.DocumentViewPicker(getContext(this))
    let options = new picker.DocumentSelectOptions()
    filePicker.select(options).then((documentSelectResult) => {
      const fileUrl = documentSelectResult[0];
      ClashViewModel.upLoadProvider(item, fileUrl).then(() => {
        this.isLoading = -1
      }).catch((error: Error) => {
        this.isLoading = -1
      })
    })
  }

  @Builder
  titleButton() {
    // 全部更新按钮
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      SymbolGlyph($r('sys.symbol.arrow_clockwise'))
        .fontSize(24)//      .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)//分层颜色
        .fontColor([this.icon_primary])
    }
    .width(40)
    .height(40)
    .margin({ right: 66 })
    .backgroundColor($r('app.color.settings_container_background'))
    .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
    .onClick(() => {
      this.isON.toggleAnim = true
      animateTo({
        duration: this.uiConfig.animationSpeed,
        curve: Curve.Friction,
        iterations: 1, // 设置-1表示动画无限循环
      }, () => {
        this.providerListData.forEach((item: Provider) => {
          convertTime(item["update-at"])
          this.isLoadingAll = this.providerListData.length
          ClashViewModel.updateProvider(item)
            .then((result) => {
              this.isLoadingAll = -1
            })
            .catch((error: Error) => {
              this.isLoadingAll = -1
            })
        })
      })
    })
  }

  build() {
    NavDestination() {
      // 顶部半模拟态标题及按钮
      proxyBindSheetTitleStyle({
        title: $r('app.string.provider'),
        otherButton: (): void => {
          this.titleButton()
        }
      })
      // this.titleStyle()
      List() {
        ListItem() {
          // 代理提供者相关
          if (this.providerListData.length === 0) {
            Nothing({ name: $r('app.string.Resources') })
              .width('100%')
              .height('100%')

          } else {
            Column({ space: 10 }) {
              //副标题
              Text($r('app.string.proxy_provider'))
                .subtitleText()

              List({ space: 10 }) {
                ForEach(this.providerListData, (item: Provider, index: number) => {
                  if (item.type === "Proxy") {
                    ListItem() {
                      Flex({
                        direction: FlexDirection.Column,
                        alignItems: ItemAlign.Start,
                        justifyContent: FlexAlign.Start
                      }) {
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
                            if (this.entriesNumber > 0) {
                              Text('.')
                                .smallText()
                              Text($r('app.string.list_item_number'))
                                .smallText()
                            }
                          }

                          //流量使用情况+进度条组件
                          cellularData(item["subscription-info"])

                        }.height(87).textColumn()

                        Divider().strokeWidth(1).color($r('app.color.divider'))

                        Row({ space: 8 }) {
                          // 功能按钮区
                          // 上传按钮
                          Button({ type: ButtonType.Normal, stateEffect: true }) {
                            Row({ space: 4.67 }) {
                              SymbolGlyph($r('sys.symbol.arrowshape_up_to_line_fill'))
                                .fontSize(14.67)
                                .fontColor([this.icon_emphasize])
                              Text($r('app.string.upload')).fontSize(12).fontColor(this.icon_emphasize)
                            }
                          }
                          .ButtonStyle()
                          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                          // .animation(this.uiConfig.isAnimation?{ duration: this.uiConfig.animationSpeed, curve: Curve.Ease }:null)
                          .width(76)
                          .height(28)
                          .onClick(() => {
                            this.theEditIndex = index
                            this.uploadProvider(item)
                          })

                          // 更新按钮
                          Button({ type: ButtonType.Normal, stateEffect: true }) {
                            if (this.isLoading === index || this.isLoadingAll === this.providerListData.length) {
                              Row({ space: 4.67 }) {
                                LoadingProgress()
                                  .color(this.icon_emphasize)
                                  .width(20).height(20)
                                Text($r('app.string.updating')).fontSize(12).fontColor(this.icon_emphasize)
                              }
                              .width(100)
                              .height(28)
                              .justifyContent(FlexAlign.Center)
                            } else {
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
                          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                          //.animation(this.uiConfig.isAnimation?{ duration: this.uiConfig.animationSpeed, curve: Curve.Ease }:null)
                          .onClick(() => {
                            // 资源更新处理
                            ClashViewModel.updateProvider(item).then((result) => {
                              this.isLoading = -1
                            }).catch((error: Error) => {
                              this.isLoading = -1
                            })
                            animateTo({
                              //  duration: this.isON.toggleAnim ?0:this.uiConfig.animationSpeed,
                              duration: this.uiConfig.animationSpeed,
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

                    //      .transition(this.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: 0 })
                    //       .combine(TransitionEffect.SLIDE):null)
                  }
                })
              }.providerList()


              //规则提供者相关
              //副标题)
              Text($r('app.string.rule_provider'))
                .subtitleText()

              List({ space: 10 }) {
                ForEach(this.providerListData, (item: Provider, index: number) => {
                  if (item.type === "Rule") {
                    ListItem() {
                      Flex({
                        direction: FlexDirection.Column,
                        alignItems: ItemAlign.Start,
                        justifyContent: FlexAlign.Start
                      }) {
                        // 文本显示区
                        Column({ space: 2 }) {
                          Text(item.name)
                            .nameText()

                          Row({ space: 2 }) {
                            Text($r('app.string.update_by'))
                              .smallText()
                            Text(convertTime(item["update-at"]))
                              .smallText()
                            //clash meta 暂无此数据，TODO 后期fl clash接入后可改
                            if (this.entriesNumber > 0) {
                              Text('.')
                                .smallText()
                              Text('' + $r('app.string.list_item_number'))
                                .smallText()
                            }
                          }
                        }.height(53).textColumn()

                        Divider().strokeWidth(1).color($r('app.color.divider'))
                        //      Text(item.path)
                        //        .smallText().margin({ bottom: 8 })

                        Row({ space: 8 }) {
                          // 功能按钮区
                          // 上传按钮
                          Button({ type: ButtonType.Normal, stateEffect: true }) {
                            Row({ space: 4.67 }) {
                              SymbolGlyph($r('sys.symbol.arrowshape_up_to_line_fill'))
                                .fontSize(14.67)
                                .fontColor([this.icon_emphasize])
                              Text($r('app.string.upload')).fontSize(12).fontColor(this.icon_emphasize)
                            }
                          }
                          .ButtonStyle()
                          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                          //    .animation(this.uiConfig.isAnimation?{ duration: this.uiConfig.animationSpeed, curve: Curve.Ease }:null)
                          .width(76)
                          .height(28)
                          .onClick(() => {
                            this.theEditIndex = index
                            this.uploadProvider(item)
                          })

                          // 更新按钮
                          Button({ type: ButtonType.Normal, stateEffect: true }) {
                            if (this.isLoading === index || this.isLoadingAll === this.providerListData.length) {
                              Row({ space: 4.67 }) {
                                LoadingProgress()
                                  .color(this.icon_emphasize)
                                  .width(20).height(20)
                                Text($r('app.string.updating')).fontSize(12).fontColor(this.icon_emphasize)
                              }
                              .width(100)
                              .height(28)
                              .justifyContent(FlexAlign.Center)
                            } else {
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
                          .clickEffect(customAnimationUtil.isClickEffect(this.uiConfig))
                          //   .animation(this.uiConfig.isAnimation?{ duration: this.uiConfig.animationSpeed, curve: Curve.Ease }:null)
                          .onClick(() => {
                            // 资源更新处理
                            ClashViewModel.updateProvider(item).then((result) => {
                              this.isLoading = -1
                            }).catch((error: Error) => {
                              this.isLoading = -1
                            })
                            // 建议使用this.getUIContext()?.animateTo()
                            animateTo({
                              // duration: this.isON.toggleAnim ?0:this.uiConfig.animationSpeed,
                              duration: this.uiConfig.animationSpeed,
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

                    //   .transition(this.isAnimation ?TransitionEffect.OPACITY.animation({ duration: this.uiConfig.animationSpeed, delay: 0 })
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
      .contentEndOffset(this.providerListData.length === 0 ? null : CONTENT_END_OFFSET_150 - 65)
      .padding({
        left: this.breakPointStateTabContentTitleMargin.value,
        right: this.breakPointStateTabContentTitleMargin.value,
      })
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background'))
    .onBackPressed(() => {
      return true;
    })
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
  .backgroundColor($r('app.color.button_container_background'))
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


