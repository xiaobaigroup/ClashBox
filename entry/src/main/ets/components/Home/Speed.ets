import { BreakpointState, BreakpointSystem } from '../../common/breakpointsystem';
import { McLineChart, Options } from '@mcui/mccharts'
import { CardTitle } from './CardTitleBuilder';
import { MarginGenerate } from '../../common/Constants';
import { AppFlowingState, getLast } from '../../entryability/AppState';
import { JSON } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { convertDataArray } from '../../utils/DataUnitConvertUtils';


@Component
struct Speed {
  @State DownloadSpeed: string = ""
  @State UploadSpeed: string = ""
  // 卡片内边距
  @Consume('breakPointStateHomeCardPadding')  private cardPadding: BreakpointState<MarginGenerate>
  //主页卡片内容网络测速字体大小
  @Consume('SpeedfontSize12_14_14_16') private SpeedfontSize12_14_14_16: BreakpointState<number>
  /* 当前设备`height`是否符合(320vp< height <= 500vp) */
  @StorageProp('isLandscapePhone') private isLandscapePhone: boolean = false
  @StorageProp("appFlowingState") appFlowingState: AppFlowingState = new AppFlowingState()
  @Consume
  @Watch('proxyEnabledChanged') proxyEnabled: boolean
  @State chartdata: number[] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  //初始化图表数据
  @State defOption: Options = new Options({
    //图例
    legend: {
      show: false,
      selectAble: false,
    },
    //图表位置
    grid: {
      top: 0,
      left: 17,
      right: 17,
    },
    //X轴
    xAxis: {
      data: ['', '', '', '', '', '', '', '', '', '', '', ''],
      axisLine: {
        // 轴线样式
        show: true, // 是否显示
      },
      axisTick: {
        show: false,
        interval: 2
      },
      //坐标轴两侧是否留白
      boundaryGap: false
    },
    //Y轴
    yAxis:
    {
      min: 0,
      max: 1300,
      //刻度线
      axisTick: {
        show: false
      },
      //轴线
      axisLine: {
        show: false
      },
      //Y轴分割线
      splitLine: {
        show: false
      },
      axisLabel: {
        show: false
      }
    },
    //动画
    animation: false,
    //初始折线
    series: [
      {
        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        lineStyle: {
          width: 3,
          color: '#ff759bf5'
        },
        label: {
          show: false
        }
      },
    ]
  })
  /* 主题色 */
  @Consume('icon_emphasize')
  icon_emphasize: ResourceColor
  // 定时器ID，用于清除定时器
  private timerId: number = 0;

  onSpeedData() {
    this.DownloadSpeed = this.appFlowingState.traffics.getLast()?.down?.toString() ?? "0 kb"
    this.UploadSpeed = this.appFlowingState.traffics.getLast()?.up?.toString() ?? "0 kb"
    //图表
    // 使用Option实例对象的setVal方法来实现，修改什么属性就传什么
    // Tip 如果是一条曲线 合成一个 up + down
    let data = this.proxyEnabled ? convertDataArray(this.appFlowingState.traffics.getData()) : this.chartdata
    hilog.info(0xFF00, "HomeSpeedTestTag", "data: %{public}s", JSON.stringify(data))
    this.defOption.setVal({
      series: [
          /*{
             smooth: false, //平滑曲线
             name: '上行速度(Kb/s)',
             data: this.appFlowingState.traffics.map((d) => d.up.value),
             label: {
               show: false,
               color: '#FFF7980A',
               offset: [-10, -10]//线条标签偏移量
             },
             //折线拐点配置
             itemStyle: {
               symbol: 'solidCircle',
               symbolSize: 2,
               borderWidth: 1
             },
             lineStyle: {
               width: 3,
               color: '#FFF7980A'
             },
             // 区域颜色，线性渐变
             areaStyle: {
               show: true,
               gradient: ['#99f7980a']
             },
           },*/
        {
          smooth: true, //平滑曲线
          name: '',
          data: data,
          label: {
            show: false,
            color: '#ff759bf5',
            offset: [0, 0]
          },
          //折线拐点配置
          itemStyle: {
            symbol: 'solidCircle',
            symbolSize: 2,
            borderWidth: 1
          },
          lineStyle: {
            width: 3,
            color: '#ff759bf5'
          },
          // 区域颜色，线性渐变
          areaStyle: {
            show: true,
            gradient: ['#ff759bf5']
          },
        }
      ]
    })
  }

  /**
   * @Watch监听事件：开启代理时启动定时器
   */
  proxyEnabledChanged() {
    if(this.proxyEnabled) {
      // 设置定时器，每秒调用一次 onSpeedData 函数
      this.timerId = setInterval(() => {
        this.onSpeedData()
      }, 1000)
    } else {
      // 清除定时器
      clearInterval(this.timerId)
    }
  }

  aboutToAppear() {

  }

  aboutToDisappear() {
    // 清除定时器
    clearInterval(this.timerId);

  }

  build() {
    Column() {
      Flex() {
        CardTitle({title: $r('app.string.Speed')})

        Column() {
          Row({space:5}) {
            Text(this.DownloadSpeed.toString())
              .fontSize(this.isLandscapePhone ? 12:this.SpeedfontSize12_14_14_16.value)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.End)

            SymbolGlyph($r('sys.symbol.chevron_up'))
              .fontColor([$r('sys.color.font_primary')])

          }.width('100%').justifyContent(FlexAlign.End)

          Row({space:5}) {
            Text(this.UploadSpeed.toString())
              .fontSize(this.isLandscapePhone ? 12:this.SpeedfontSize12_14_14_16.value)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.End)

            SymbolGlyph($r('sys.symbol.chevron_down'))
              .fontColor([$r('sys.color.font_primary')])

          }.width('100%').justifyContent(FlexAlign.End)
        }
      }
      .width('100%')

      //图表
        McLineChart({
          options: this.defOption
        })
    }
    .padding(this.cardPadding.value)
    .width('100%')
    .height('100%')
    .id('SpeedId')
  }
}

export default Speed