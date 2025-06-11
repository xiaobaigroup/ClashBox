import { McLineChart, Options } from '@mcui/mccharts'
import { CardTitle } from './CardTitleBuilder';
import { CHART_NUMBER } from '../../common/entity/Constants';
import { AppFlowingState, UIConfig } from '../../entryability/AppState';
import { JSON } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { convertDataArray, ConvertedUnit } from '../../common/utils/DataUnitConvertUtils';
import { customAnimationUtil } from '../../common/utils/Animation';
import { HomeCardPadding, HomeCardSpeedFontSize } from '../../common/breakpoint/BreakPoint';


@Component
struct Speed {

  @StorageProp("appFlowingState") appFlowingState: AppFlowingState = new AppFlowingState()
  @StorageLink('uiConfig') @Watch('colorTheme') uiConfig: UIConfig = new UIConfig()
  // 高度断点
  @StorageLink ('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink ('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @Consume @Watch('proxyEnabledChanged') proxyEnabled: boolean
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  @Consume ChartData: number[] | ConvertedUnit[]
  @State lineStart: boolean = true
  @Consume DownloadSpeed: string
  @Consume UploadSpeed: string
  // 前台判断变量
  @Consume isForeward: boolean
  // 是否在主页
  @Consume isHomePage: boolean
  // 定时器ID，用于清除定时器
  timerId: number = 0
  // 初始化图表数据
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
      max: 1500,
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
          width: 2,
          color: this.uiConfig.lineColor
        },
        label: {
          show: false
        }
      },
    ]
  })

  build() {
    Column() {
      Flex() {
        CardTitle({title: $r('app.string.Speed')})

        Column() {
          Row({space:5}) {
            Text(this.UploadSpeed.toString())
              .fontSize(HomeCardSpeedFontSize(this.widthBp, this.heightBp))
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.End)

            SymbolGlyph($r('sys.symbol.chevron_up'))
              .fontColor([$r('sys.color.font_primary')])

          }.width('100%').justifyContent(FlexAlign.End)

          Row({space:5}) {
            Text(this.DownloadSpeed.toString())
              .fontSize(HomeCardSpeedFontSize(this.widthBp, this.heightBp))
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.End)

            SymbolGlyph($r('sys.symbol.chevron_down'))
              .fontColor([$r('sys.color.font_primary')])

          }.width('100%').justifyContent(FlexAlign.End)
        }
      }
      .width('100%')

      // 图表
      Stack(){
        if (this.lineStart){
          Row().width('92%').height(3).backgroundColor(this.uiConfig.lineColor).margin({left:17,right:17,bottom:28.5})
            .transition(customAnimationUtil.isOpacity(this.uiConfig))
        }else {
          McLineChart({
            options: this.defOption
          }).transition(customAnimationUtil.isOpacity(this.uiConfig))
        }
      }.width('100%').height('100%').alignContent(Alignment.Bottom)
    }
    .padding(HomeCardPadding(this.widthBp, this.heightBp))
    .width('100%')
    .height('100%')
    .id('SpeedId')
  }

  onSpeedData() {
    this.DownloadSpeed = this.appFlowingState.traffics.getLast()?.down?.toString() ?? "0 kb"
    this.UploadSpeed = this.appFlowingState.traffics.getLast()?.up?.toString() ?? "0 kb"
    //图表
    // 使用Option实例对象的setVal方法来实现，修改什么属性就传什么
    // Tip 如果是一条曲线 合成一个 up + down
    this.ChartData = this.proxyEnabled ? convertDataArray(this.appFlowingState.traffics.getData()) : CHART_NUMBER
    hilog.info(0xFF00, "HomeSpeedTestTag", "data: %{public}s", JSON.stringify(this.ChartData))
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
          data: this.ChartData,
          label: {
            show: false,
            color: this.uiConfig.lineColor,
            offset: [0, 0]
          },
          endLabel:{
            show:false
          },
          //折线拐点配置
          itemStyle: {
            symbol: this.uiConfig.lineColor,
            symbolSize: 2,
            borderWidth: 1
          },
          lineStyle: {
            width: 3,
            color: this.uiConfig.lineColor
          },
          // 区域颜色，线性渐变
          areaStyle: {
            show: true,
            gradient: [this.uiConfig.lineColor]
          },
        }
      ]
    })
  }

  /**@Watch监听事件：开启代理时启动定时器*/
  proxyEnabledChanged() {
    // 只有主页显示的时候启动
    animateTo({
      duration: this.uiConfig.animationSpeed,
      iterations: 1,
      playMode: PlayMode.Normal,
      curve:Curve.Ease,
    }, () => {
      hilog.info(0xFF00, "HomeSpeedTestTag", `代理启用状态：${this.proxyEnabled} 是否前台：${this.isForeward} 是否位于主页: ${this.isHomePage}`)
      if (this.proxyEnabled && this.isForeward && this.isHomePage) {
        // 设置定时器，每秒调用一次 onSpeedData 函数
        this.timerId = setInterval( () => {
          this.onSpeedData()
          this.lineStart = false
        }, 1000)
      } else {
        // 清除定时器
        clearInterval(this.timerId)
        this.lineStart = true
        this.defOption = new Options({
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
            max: 1500,
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
                color: this.uiConfig.lineColor
              },
              label: {
                show: false
              }
            },
          ]
        })
      }
    })
  }

  aboutToAppear() {
    this.colorTheme()
  }

  aboutToDisappear() {
    // 清除定时器
    clearInterval(this.timerId);
  }
  
  colorTheme(){
    if (this.uiConfig.themeColor == 'yellowAppTheme') {
      this.uiConfig.lineColor = '#ff9926'
    }else if (this.uiConfig.themeColor == 'blueAppTheme'){
      this.uiConfig.lineColor = '#ff759bf5'
    }else if (this.uiConfig.themeColor == 'catBlueAppTheme'){
      this.uiConfig.lineColor = '#E61E4377'
    }else if (this.uiConfig.themeColor == 'redAppTheme'){
      this.uiConfig.lineColor = '#E6D41C26'
    }else if (this.uiConfig.themeColor == 'purpleAppTheme'){
      this.uiConfig.lineColor = '#E6722ED1'
    }else if (this.uiConfig.themeColor == 'pinkAppTheme'){
      this.uiConfig.lineColor = '#E6FB7299'
    }else if (this.uiConfig.themeColor == 'greenAppTheme'){
      this.uiConfig.lineColor = '#E682D41C'
    }
  }

}

export default Speed