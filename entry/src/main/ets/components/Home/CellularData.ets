import { BreakpointState } from '../../common/breakpointsystem'
import { mediaquery } from '@kit.ArkUI'
import { FONT_SIZE_16, MarginGenerate } from '../../common/Constants'
import { CardTitle } from './CardTitleBuilder'
import { AppFlowingState, TrafficUnit, UIConfig } from '../../entryability/AppState'
import { convertDataNumberGB, convertToGB } from '../../utils/DataUnitConvertUtils'

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
  @State index: number = 2

  controller?: CustomDialogController
  cancel: () => void = () => {
  }
  confirm: () => void = () => {
  }

  // 切换单位
  switchUnit(index: number) {
    switch (index) {
      case 0:
        TrafficUnit.KB
        this.uiConfig.switchUnit = TrafficUnit.KB
        break;
      case 1:
        TrafficUnit.MB
        this.uiConfig.switchUnit = TrafficUnit.MB
        break
      case 2:
        TrafficUnit.GB
        this.uiConfig.switchUnit = TrafficUnit.GB
        break
      case 3:
        TrafficUnit.TB
        this.uiConfig.switchUnit = TrafficUnit.TB
        break
    }
  }

  @Builder
  itemEnd() {
    Select([{ value: TrafficUnit.KB},
      { value: TrafficUnit.MB },
      { value: TrafficUnit.GB },
      { value: TrafficUnit.TB }])
      .width(80)
      .align(Alignment.Center)
      .value(this.uiConfig.switchUnit.length > 0 ? this.uiConfig.switchUnit : TrafficUnit.MB )
      .font({ size: FONT_SIZE_16, weight: 500 })
      .fontColor($r('sys.color.font_primary'))
      .selectedOptionFont({ size: FONT_SIZE_16, weight: 400 })
      .optionFont({ size: FONT_SIZE_16, weight: 400 })
      .backgroundColor(Color.Transparent)
      .onSelect((index: number) => {
        this.index=index
        console.info('Select:' + index+this.uiConfig.switchUnit);
      })
  }

  build() {
    Column() {
      Text('输入总流量数值')
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
            this.switchUnit(this.index)
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
  @StorageProp("appFlowingState") appFlowingState: AppFlowingState = new AppFlowingState()
  @StorageLink('uiConfig') uiConfig: UIConfig = new UIConfig()
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

  // 下部文字大小
  @Consume('HomeCardCellularDataSmFontSize') private HomeCardCellularDataSmFontSize: BreakpointState<number>
  phonelistener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');
  /**
   * 主页流量统计卡片padding高度
   */
  @Consume('HomeCardCellularDataPadding')
  private HomeCardCellularDataPadding: BreakpointState<number>
  /* 是否开启 `Index` 页面的前景模糊 */
  @Consume('isEnableIndexForegroundBlur') private isEnableIndexForegroundBlur: boolean

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

  }
  // 在自定义组件即将析构销毁时将弹窗置空
  aboutToDisappear() {
    this.dialogController = null // 将dialogController置空
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


  build() {
    Column() {
      CardTitle({title: $r('app.string.CellularData')})

      Column({space:this.RowMargin.value}) {
        Row({ space: 10 }) {
          //已使用下载流量
          Column() {
            Text() {
              SymbolSpan($r('sys.symbol.chevron_down'))
            }
            .fontSize(this.isLandscapePhone ? 14 : this.chevronSize.value)
            .fontColor(this.icon_primary)

            Text(this.appFlowingState.totalTraffic.down.toString())
              .fontSize(this.isLandscapePhone ? 14 : this.fontSize.value)
              .fontColor(this.icon_primary)
              .maxLines(1)
              .textAlign(TextAlign.End)
          }

          //已使用上传流量
          Column() {
            Text() {
              SymbolSpan($r('sys.symbol.chevron_up'))
            }
            .fontSize(this.isLandscapePhone ? 14 : this.chevronSize.value)
            .fontColor(this.icon_primary)

            Text(this.appFlowingState.totalTraffic.up.toString())
              .fontSize(this.isLandscapePhone ? 14 : this.fontSize.value)
              .fontColor(this.icon_primary)
              .maxLines(1)
              .textAlign(TextAlign.End)
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        // 使用流量进度条
        Column() {
          Progress({
            value: convertDataNumberGB(this.appFlowingState.totalTraffic.upRaw + this.appFlowingState.totalTraffic.downRaw),
            total: convertToGB(this.uiConfig.inputTotal,this.uiConfig.switchUnit),
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
          Text(this.appFlowingState.totalTraffic.total().toString() + ' / ' + this.uiConfig.inputTotal.toString())
            .fontSize(this.isLandscapePhone ? 10 : this.HomeCardCellularDataSmFontSize.value)
            .fontColor($r('sys.color.font_secondary'))

          //总量单位
          Text(this.uiConfig.switchUnit)
            .fontSize(this.isLandscapePhone ? 10 : this.HomeCardCellularDataSmFontSize.value)
            .fontColor($r('sys.color.font_secondary'))
      }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
  //    .backgroundColor('#ba942020')
      .padding({bottom:this.isLandscapePhone ? 30: this.HomeCardCellularDataPadding.value})
      .onClick(()=>{
        if (this.dialogController != null) {
          this.dialogController.open()
          this.isEnableIndexForegroundBlur=true
          console.info('Total', convertDataNumberGB(this.appFlowingState.totalTraffic.upRaw+this.appFlowingState.totalTraffic.downRaw),convertToGB(this.uiConfig.inputTotal,this.uiConfig.switchUnit))
        }
      })
    //  .alignItems(HorizontalAlign.Center)
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
//.backgroundColor('#ff55b54e')
    .id('CellularDataId')
  }
}

export default CellularDataStat
