import { McLineChart, Options } from '@mcui/mccharts'
import { CardTitle } from './CardTitleBuilder';
import { CHART_NUMBER } from '../../common/entity/Constants';
import { AppFlowingState, UIConfig } from '../../entryability/AppState';
import { JSON } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {
  convertDataArray,
  ConvertedUnit,
  NormalizedDataResult,
  normalizeChartData
} from '../../common/utils/DataUnitConvertUtils';
import { customAnimationUtil } from '../../common/utils/Animation';
import { HomeCardPadding, HomeCardSpeedFontSize } from '../../common/breakpoint/BreakPoint';
import { LengthMetrics } from '@kit.ArkUI';
import { Xb_ResourceColorUtil } from 'xb_components';
import { getResourceString } from '../../common/utils/ResourceStringUtil';
import { number2Time } from '../../common/utils/TimeConvertUtil';


@Component
struct Speed {
  @StorageProp("appFlowingState") appFlowingState: AppFlowingState = new AppFlowingState()
  @StorageLink('uiConfig') @Watch('colorTheme') uiConfig: UIConfig = new UIConfig()
  // 高度断点
  @StorageLink('currentHeightBreakpoint') heightBp: HeightBreakpoint = 0
  // 宽度断点
  @StorageLink('currentWidthBreakpoint') widthBp: WidthBreakpoint = 1
  @Consume @Watch('proxyEnabledChanged') proxyEnabled: boolean
  /* 主题色 */
  @Consume('icon_emphasize') icon_emphasize: ResourceColor
  // 前台判断变量
  @StorageProp('ForwardState') @Watch('proxyEnabledChanged') isForward: boolean = true
  @Consume ChartData: number[] | ConvertedUnit[]
  @Consume DownloadSpeed: string
  @Consume UploadSpeed: string
  // 是否在主页
  @Consume isHomePage: boolean
  // 定时器ID，用于清除定时器
  private timerId: number = 0
  // 代理启动持续的时间
  @Consume proxyTime:number
  // 初始化图表数据
  @State defOption: Options = new Options({
    // 图例
    legend: {
      show: false,
      selectAble: false,
    },
    // 图表位置
    grid: {
      top: 0,
      left: 17,
      right: 17,
    },
    // X轴
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
      // 坐标轴两侧是否留白
      boundaryGap: false
    },
    // Y轴
    yAxis:
    {
      min: 0,
      max: 1500,
      // 刻度线
      axisTick: {
        show: false
      },
      // 轴线
      axisLine: {
        show: false
      },
      // Y轴分割线
      splitLine: {
        show: false
      },
      axisLabel: {
        show: false
      }
    },
    // 动画
    animation: false,
    // 初始折线
    series: [
      {
        data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        lineStyle: {
          width: 3,
          color: this.colorTheme()
        },
        label: {
          show: false
        }
      },
    ]
  })

  build() {
    RelativeContainer() {
      CardTitle({
        title: $r('app.string.Speed'),
        subtitle: (getResourceString($r('app.string.px_sec_screen_use_time'), this) + number2Time(Number(this.proxyTime), true))
      })
        .id('title')
        .alignRules({
          top: { anchor: "__container__", align: VerticalAlign.Top },
          left: { anchor: "__container__", align: HorizontalAlign.Start }
        })

      // 速率
      Column() {
        // 上行流量
        Flex({
          alignItems: ItemAlign.Center,
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.End,
          space: { main: LengthMetrics.vp(5) }
        })
        {
          Text(this.UploadSpeed.toString())
            .fontSize(HomeCardSpeedFontSize(this.widthBp, this.heightBp))
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.End)
          SymbolGlyph($r('sys.symbol.chevron_up'))
            .fontColor([$r('sys.color.font_primary')])
        }
        // 下行流量
        Flex({
          alignItems: ItemAlign.Center,
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.End,
          space: { main: LengthMetrics.vp(5) }
        })
        {
          Text(this.DownloadSpeed.toString())
            .fontSize(HomeCardSpeedFontSize(this.widthBp, this.heightBp))
            .fontColor($r('sys.color.font_primary'))
            .textAlign(TextAlign.End)
          SymbolGlyph($r('sys.symbol.chevron_down'))
            .fontColor([$r('sys.color.font_primary')])
        }
      }
      .id("speed")
      .justifyContent(FlexAlign.End)
      .alignRules({
        top: { anchor: "__container__", align: VerticalAlign.Top },
        right: { anchor: "__container__", align: HorizontalAlign.End }
      })

      // 图表
      if (!this.proxyEnabled) {
        Row()
          .id('chart_0')
          .width('92%').height(3)
          .backgroundColor(this.colorTheme())
          .margin({ left: 17, right: 17, bottom: /*28.5*/0 })
          .transition(customAnimationUtil.isOpacity(this.uiConfig))
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom } // 底部对齐父容器底部
          })
      } else {
        McLineChart({ options: this.defOption })
          .id('chart_1')
          .offset({ y: 28.5 })
          .transition(customAnimationUtil.isOpacity(this.uiConfig))
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom } // 底部对齐父容器底部
          })
      }

    }
    .padding(HomeCardPadding(this.widthBp, this.heightBp))
    .width('100%').height('100%')
    .id('SpeedId')
/*    Column() {

      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.SpaceBetween
      }) {
      }
      .width('100%')


    }*/

    /*.onAppear(() => {
      hilog.info(0xFF00, "HomeSpeedTestTag", "Speed Card onAppear")
      // 后台切回前台 -> 代理开启时，折线图显示
      if (this.proxyEnabled && this.isForward && this.isHomePage) {
        // 延迟 0.5 秒启动折线图渲染
        setTimeout(() => {
          this.lineRenderStart();
        }, 500)
      }
    })
    .onDisAppear(() => {
      hilog.info(0xFF00, "HomeSpeedTestTag", "Speed Card onDisAppear")
      // 停止渲染折线图
      this.lineRenderStop();
    })*/
  }

  onSpeedData() {
    this.DownloadSpeed = this.appFlowingState.traffics.getLast()?.down?.toString() ?? "0 kb"
    this.UploadSpeed = this.appFlowingState.traffics.getLast()?.up?.toString() ?? "0 kb"
    // 图表
    // 使用Option实例对象的setVal方法来实现，修改什么属性就传什么
    // Tip 如果是一条曲线 合成一个 up + down
    this.ChartData = this.proxyEnabled ? convertDataArray(this.appFlowingState.traffics.getData()) : CHART_NUMBER
    hilog.info(0xFF00, "HomeSpeedTestTag", "data: %{public}s", JSON.stringify(this.ChartData))

    // 将带单位的数据转换为统一单位的数字数组
    const result: NormalizedDataResult = normalizeChartData(this.ChartData)
    const normalizedData: number[] = result.normalizedData
    const maxValue: number = result.maxValue

    // 更新图表配置
    this.defOption.setVal({
      yAxis: {
        min: 0,
        max: Math.max(maxValue * 1.2, 10), // 最大值增加 20% 作为上限，最小为 10
        axisTick: {
          show: false
        },
        axisLine: {
          show: false
        },
        splitLine: {
          show: false
        },
        axisLabel: {
          show: false
        }
      },
      series: [
        {
          smooth: true, //平滑曲线
          name: '',
          data: normalizedData, // 使用转换后的纯数字数组
          label: {
            show: false,
            color: this.colorTheme(),
            offset: [0, 0]
          },
          endLabel:{
            show:false
          },
          //折线拐点配置
          itemStyle: {
            symbol: this.colorTheme(),
            symbolSize: 2,
            borderWidth: 1
          },
          lineStyle: {
            width: 3,
            color: this.colorTheme()
          },
          // 区域颜色，线性渐变
          areaStyle: {
            show: true,
            gradient: [this.colorTheme()]
          },
        }
      ]
    })

    /*this.defOption.setVal({
     series: [
      {
        smooth: true, //平滑曲线
        name: '',
        data: this.ChartData,
        label: {
          show: false,
          color: this.colorTheme(),
          offset: [0, 0]
        },
        endLabel:{
          show:false
        },
        //折线拐点配置
        itemStyle: {
          symbol: this.colorTheme(),
          symbolSize: 2,
          borderWidth: 1
        },
        lineStyle: {
          width: 3,
          color: this.colorTheme()
        },
        // 区域颜色，线性渐变
        areaStyle: {
          show: true,
          gradient: [this.colorTheme()]
        },
      }
    ]
  })*/
  }

  /**@Watch监听事件：开启代理时启动定时器*/
  proxyEnabledChanged() {
    // 只有主页显示的时候启动
    // TODO 待测试 -> 此处动画会造成 UI 卡顿
    /*this.getUIContext().animateTo({
      duration: this.uiConfig.animationSpeed,
      iterations: 1,
      playMode: PlayMode.Normal,
      curve:Curve.Ease,
    }, () => {*/
      hilog.info(0xFF00, "HomeSpeedTestTag", `代理启用状态：${this.proxyEnabled} 是否前台：${this.isForward} 是否位于主页: ${this.isHomePage}`)
      if (this.proxyEnabled && this.isForward && this.isHomePage) {
        this.lineRenderStart();
      } else {
        this.lineRenderStop();
      }
    // })
  }

  /** @description 停止渲染折线图 */
  private lineRenderStop() {
    // 清除定时器
    clearInterval(this.timerId);
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
      yAxis: {
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
            color: this.colorTheme()
          },
          label: {
            show: false
          }
        },
      ]
    });
  }

  /** @description 开始渲染折线图 */
  private lineRenderStart() {
    // 设置定时器，每秒调用一次 onSpeedData 函数
    this.timerId = setInterval(() => {
      this.onSpeedData();
    }, 1000);
  }

  aboutToAppear() {
    console.log(`Speed 网络速率卡片已注册`)
  }

  aboutToDisappear() {
    // 清除定时器
    clearInterval(this.timerId);
    console.log(`Speed 网络速率卡片已销毁`)
  }

  colorTheme() {
    let colorValue = Xb_ResourceColorUtil(this.icon_emphasize, this.getUIContext().getHostContext()!)
    return colorValue
  }

}

export default Speed