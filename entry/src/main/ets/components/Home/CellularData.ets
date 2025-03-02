import { BreakpointState } from '../../common/breakpointsystem'
import { ColorMetrics, mediaquery, SymbolGlyphModifier } from '@kit.ArkUI'
import { FONT_SIZE_14, FONT_SIZE_16, MarginGenerate } from '../../common/Constants'
import { CardTitle } from './CardTitleBuilder'
import { AppFlowingState, TrafficUnit, UIConfig } from '../../entryability/AppState'
import { convertDataNumberT, convertToSwitchNub } from '../../utils/DataUnitConvertUtils'
import { customVibrator } from '../../utils/VibratorUtil'


/* 输入总流量自定义弹窗相关 */
@CustomDialog
struct totalCustomDialog {
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur')
  private isEnableIndexForegroundBlur: boolean
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @State TotalCellular: number = 0
  @State index : number = 1

  controller?: CustomDialogController
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  // 切换单位
  switchUnit(index: number) {
    switch (index) {
      case 0:
        this.uiConfig.switchUnit=TrafficUnit.KB
        break;
      case 1:
        this.uiConfig.switchUnit=TrafficUnit.MB
        break
      case 2:
        this.uiConfig.switchUnit=TrafficUnit.GB
        break
      case 3:
        this.uiConfig.switchUnit=TrafficUnit.TB
        break
    }
  }

  @Builder
  itemEnd() {
    Select([{ value: TrafficUnit.KB},
      { value: TrafficUnit.MB},
      { value: TrafficUnit.GB},
      { value: TrafficUnit.TB}])
     //.width(80)
      .align(Alignment.Center)
      .selected(this.uiConfig.cellularDataIndex)
      .value(this.uiConfig.switchUnit)
      .font({ size: FONT_SIZE_16, weight: 500 })
      .fontColor($r('sys.color.font_primary'))
      .selectedOptionFont({ size: FONT_SIZE_16, weight: 400 })
      .optionFont({ size: FONT_SIZE_16, weight: 400 })
      .backgroundColor(Color.Transparent)
      .onSelect((index: number) => {
        this.index=index
                      if (this.uiConfig.isVibrate) {
                customVibrator.vibratorTriggerOfHapticClockTimer()
              }
        console.info('Select:' + index+this.uiConfig.switchUnit);
      })
      .selectedOptionBgColor(this.icon_emphasize)
      .selectedOptionFontColor($r('sys.color.font_on_primary'))
      .optionBgColor($r('app.color.container_background'))
      .menuBackgroundColor($r('app.color.container_background'))
      .menuBackgroundBlurStyle(BlurStyle.NONE)
      .onClick(() => {
                      if (this.uiConfig.isVibrate) {
                customVibrator.vibratorTriggerOfHapticClockTimer()
              }
      })
  }

  build() {
    Column() {
      Text($r('app.string.input_cellular_data'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
      Blank(15)

      Row(){
      TextInput({ placeholder: '0', text: this.uiConfig.inputTotal.toString() })
        .width(144)
        .fontSize(FONT_SIZE_16)
        .caretColor(this.icon_emphasize)
        .type(InputType.Number)
        .onChange((value: string) => {
          this.TotalCellular = Number(value)
      //    console.info('inputTotal', Number(value))
        })

        this.itemEnd()
      }.width('100%').alignItems(VerticalAlign.Center).justifyContent(FlexAlign.Center)


      Blank(15)

      Row({ space: 8 }) {
        Button($r('app.string.Cancel'))
          .width(144)
          .fontSize(FONT_SIZE_16)
          .fontColor(this.icon_emphasize)
          .backgroundColor('#00ffffff')
          .onClick(() => {
            if (this.controller != undefined) {
              this.controller.close()
              this.isEnableIndexForegroundBlur = false
            }
          })

        Button($r('app.string.Save'))
          .width(144)
          .fontSize(FONT_SIZE_16)
          .fontColor($r('sys.color.font_on_primary'))
          .backgroundColor(this.icon_emphasize)
          .onClick(() => {
           this.uiConfig.inputTotal= this.TotalCellular
            this.uiConfig.cellularDataIndex=this.index
            this.switchUnit(this.uiConfig.cellularDataIndex)
       //     console.info('inputTotal1', this.uiConfig.inputTotal)
            if (this.controller != undefined) {
              this.controller.close()
              this.isEnableIndexForegroundBlur = false
            }
          })
      }
    }
    .backgroundColor($r('app.color.container_background'))
    .width('100%')
    .padding({
      top: 15,
      bottom: 15,
      left: 24,
      right: 24
    })
  }
}

@Component
struct CellularDataStat {
  @StorageProp("appFlowingState") @Watch('dataTotalChange') appFlowingState: AppFlowingState = new AppFlowingState()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
  @State totalData:number =0
  @State icon_primary: ResourceColor = $r('sys.color.icon_primary') //一级图标色，黑色
  @State font_primary: ResourceColor = $r('sys.color.font_primary')

  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  // 内容文本字体大小
  @Consume('breakPointStateCardCellularDataFontSize') private fontSize: BreakpointState<number>
  // 上下行箭头图标大小
  @Consume('breakPointStateCardCellularDataChevronSize') private chevronSize: BreakpointState<number>
  // 箭头组件部分间距
  @Consume('breakPointStateCardCellularDataChevronRowMargin') private RowMargin: BreakpointState<number>
  // 统计条高度
  @Consume('breakPointStateCardCellularDatabarHeight') private barHeight: BreakpointState<number>
  // 统计条边距
  @Consume('breakPointStateCardCellularDatabarMargin') private barMargin: BreakpointState<MarginGenerate>
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding') private cardPadding: BreakpointState<MarginGenerate>
  @Consume('breakPointStateHomeCardTitleBottomMargin') private titleBottomMargin: BreakpointState<number>

//下部文字大小
  @Consume('HomeCardCellularDataSmFontSize') private HomeCardCellularDataSmFontSize: BreakpointState<number>
  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');
  /**
   * 主页流量统计卡片padding高度
   */
  @Consume('HomeCardCellularDataPadding')
  private HomeCardCellularDataPadding: BreakpointState<number>
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean
  //编辑按钮点击后显示编辑状态判定
  @Consume isShowHomeEdit: boolean


  /* 总流量输入弹窗数据  */
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: totalCustomDialog({
      cancel: () => {
        this.onCancel()
      },
      confirm: () => {
        this.onAccept()
      }
    }),
    cancel: this.existApp,
    autoCancel: true,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      console.info("reason=" + JSON.stringify(dismissDialogAction.reason))
      console.log("dialog onWillDismiss")
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
            this.isEnableIndexForegroundBlur=false
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
           this.isEnableIndexForegroundBlur=false
      }
    },
    alignment: DialogAlignment.Center,
    cornerRadius: 32,
    gridCount: 4,
    backgroundBlurStyle: BlurStyle.NONE,
   // backgroundColor: $r('app.color.container_background')
  })

  aboutToAppear(): void {
    this.uiConfig.dataTotalLast=this.uiConfig.dataTotal
    console.info('dataTotal',this.totalData,this.uiConfig.dataTotalLast,this.uiConfig.dataTotal)
  }
  // 在自定义组件即将析构销毁时将弹窗置空
  aboutToDisappear() {
    this.dialogController = null // 将dialogController置空
    this.uiConfig.dataTotalLast=this.uiConfig.dataTotal
    console.info('dataTotal',this.totalData,this.uiConfig.dataTotalLast,this.uiConfig.dataTotal)
  }

  onCancel() {
    console.info('Callback when the first button is clicked')
  }

  onAccept() {
    console.info('Callback when the second button is clicked')
  }

  existApp() {
    console.info('Click the callback in the blank area')
  }


  dataTotalChange() {
    console.info('dataTotal',this.totalData,this.uiConfig.dataTotalLast,this.uiConfig.dataTotal)
    if (this.appFlowingState.totalTraffic.downRaw>=0) {
      this.totalData=this.appFlowingState.totalTraffic.upRaw+this.appFlowingState.totalTraffic.downRaw
    }
    return this.uiConfig.dataTotal=this.uiConfig.dataTotalLast+this.totalData
  }

  build() {
    Column() {
      CardTitle({title: $r('app.string.CellularData')})

      Column({space:this.RowMargin.value}) {
        Row({ space: 10 }) {
          //已使用上传流量
          Column() {
            Text() {
              SymbolSpan($r('sys.symbol.chevron_up'))
            }
            .fontSize(this.isLandscapePhone ? FONT_SIZE_14 : this.chevronSize.value)
            .fontColor(this.icon_primary)

            Text(this.appFlowingState.totalTraffic.up.toString())
              .fontSize(this.isLandscapePhone ? FONT_SIZE_14 : this.fontSize.value)
              .fontColor(this.icon_primary)
              .maxLines(1)
              .textAlign(TextAlign.End)
          }

          //已使用下载流量
          Column() {
            Text() {
              SymbolSpan($r('sys.symbol.chevron_down'))
            }
            .fontSize(this.isLandscapePhone ? FONT_SIZE_14 : this.chevronSize.value)
            .fontColor(this.icon_primary)

            Text(this.appFlowingState.totalTraffic.down.toString())
              .fontSize(this.isLandscapePhone ? FONT_SIZE_14 : this.fontSize.value)
              .fontColor(this.icon_primary)
              .maxLines(1)
              .textAlign(TextAlign.End)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        //使用流量进度条
        Column() {
          Progress({
            value: convertToSwitchNub(this.uiConfig.dataTotal,this.uiConfig.switchUnit),
            total: this.uiConfig.inputTotal,
            type: ProgressType.Capsule
          })//value为使用流量的值
            .style({ enableSmoothEffect: true, borderColor: '#00ffffff' })
            .color('#ff46b1e3')
            .width('100%')
            .height('100%')
        }
        .width('90%')
        .backgroundColor('#4d46b1e3')
        .height(this.barHeight.value)
        .borderRadius(this.barHeight.value)

        Row({space:2}) {
          //使用流量/总流量
          Text(convertDataNumberT(this.uiConfig.dataTotal) + ' / ' + this.uiConfig.inputTotal.toString())
            .fontSize(this.isLandscapePhone ? 10 : this.HomeCardCellularDataSmFontSize.value)
            .fontColor($r('sys.color.font_secondary'))

          //总量单位
          Text(this.uiConfig.switchUnit)
            .fontSize(this.isLandscapePhone ? 10 : this.HomeCardCellularDataSmFontSize.value)
            .fontColor($r('sys.color.font_secondary'))
      }

      if( this.uiConfig.inputTotal === 0 ||this.uiConfig.inputTotal === undefined){
      Text($r('app.string.cellular_data_tips'))
        .fontSize(this.isLandscapePhone ? 10 : this.HomeCardCellularDataSmFontSize.value)
        .fontColor($r('sys.color.font_secondary'))
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .padding({bottom:this.isLandscapePhone ? 30: this.HomeCardCellularDataPadding.value})
      .onClick(()=>{
        if (this.dialogController != null) {
          //在home页编辑状态时，无法操作
          if (this.isShowHomeEdit===false ) {
            this.dialogController.open()
            this.isEnableIndexForegroundBlur=true
          }
          if (this.uiConfig.isVibrate) {
            customVibrator.vibratorTriggerOfHapticClockTimer()
          }
          console.info('Total',convertToSwitchNub(this.appFlowingState.totalTraffic.upRaw+this.appFlowingState.totalTraffic.downRaw,this.uiConfig.switchUnit),this.uiConfig.inputTotal)
        }
      })
    //  .alignItems(HorizontalAlign.Center)
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
    .id('CellularDataId')
  }
}

export default CellularDataStat
