import { BreakpointState, BreakpointSystem } from '../common/breakpointsystem';
import { chartInterface, McLineChart, Options } from '@mcui/mccharts'

@Component
struct Start {
  //设置speed图标颜色，修改resources/base(dark)/element/color.json中speed_up_icon和app.color.speed_down_icon配置浅色和深色模式分别颜色
  @State fontColorValue:ResourceColor = ($r('app.color.speed_up_icon'));
  @State fontColorValue1:ResourceColor = ($r('app.color.speed_down_icon'));
  @State DownloadSpeed: number = 0
  @State UploadSpeed: number = 0
  @State compStr: BreakpointState<string> = BreakpointState.of({
    sm: "sm",
    md: "md",
    lg: "lg",
    xl: "xl"
  })
  @State fontSize: BreakpointState<number> = BreakpointState.of({
    sm: 28,
    md: 30,
    lg: 35,
    xl: 36
  });
  @State speedfontSize: BreakpointState<number> = BreakpointState.of({
    sm: 16,
    md: 20,
    lg: 21,
    xl: 21
  });
  //图表
  @State defOption: Options = new Options({
    //图例
    legend: {
      show: false,
      selectAble: false,
    },
    //图表位置
    grid: {
      top: 15
    },
    //X轴
    xAxis: {
      data: ['', '', '', '', '', '', ''],
      axisLine: {
        // 轴线样式
        show: true, // 是否显示
      },
      axisTick: {
        show: true,
        interval: 2
      },
    },
    //Y轴
    yAxis:
    {
      name: '单位(Kb/s)',
      min: 0,
      max: 1024
    },
    //初始折线
    series: [
      {
        data: [0, 0, 0, 0, 0, 0, 0]
      },
    ]
  })

  aboutToAppear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.speedfontSize)
    BreakpointSystem.getInstance().start()

    //图表
    setTimeout(() => {
      // 使用Option实例对象的setVal方法来实现，修改什么属性就传什么
      this.defOption.setVal({
        series: [
          {
            smooth: true, //平滑曲线
            name: '上行速度(Kb/s)',
            data: [11, 300, 50, 900, 210, 600, 250],
            label: {
              color: '#ffffa200',
              offset: [-10, -10]//线条标签偏移量
            },
            //折线拐点配置
            itemStyle: {
              symbol: 'solidCircle',
              symbolSize: 2,
              borderWidth: 1
            },
            lineStyle: {
              width: 2,
              color: '#ffffa200'
            }
          },
          {
            smooth: true, //平滑曲线
            name: '下行速度(Kb/s)',
            data: [0, 500, 156, 700, 120, 900, 300],
            label: {
              color: '#ff00aeff',
              offset: [-10, -10]
            },
            //折线拐点配置
            itemStyle: {
              symbol: 'solidCircle',
              symbolSize: 2,
              borderWidth: 1
            },
            lineStyle: {
              width: 2,
              color: '#ff00aeff'
            }
          }
        ]
      })
    }, 2000)
  }

  aboutToDisappear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.speedfontSize)
    BreakpointSystem.getInstance().stop()
    //this.phonelistener.off('change');
  }

  build() {
    Column() {
      Row() {
        Row() {
          Text() {
            SymbolSpan($r('sys.symbol.play_fill'))
          }
          .fontSize(this.fontSize.value)
          .fontColor('green')

          Text($r('app.string.Start'))
            .fontSize(this.fontSize.value)
        }
        .width('145vp')

        //.margin({ top: 10, left: 20 })
        Row() {
        }
        .flexGrow(1)

        Column() {
          Row() {
            Text(this.DownloadSpeed.toString() + ' B/s')
              .margin({ right: 3 })
              .fontSize(this.speedfontSize.value)
              .fontColor($r('app.color.speed_up_icon'))
            Text() {
              SymbolSpan($r('sys.symbol.chevron_up'))
                .fontSize(this.speedfontSize.value)
                .fontColor([this.fontColorValue])
            }

          }

          Row() {
            Text(this.UploadSpeed.toString() + ' B/s')
              .margin({ right: 3 })
              .fontSize(this.speedfontSize.value)
              .fontColor($r('app.color.speed_down_icon'))
            Text() {
              SymbolSpan($r('sys.symbol.chevron_down'))
                .fontSize(this.speedfontSize.value)
                .fontColor([this.fontColorValue1])
            }

          }
        }
        .width('67vp')

      }
      .height(40)
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Row() {

      }
      .justifyContent(FlexAlign.Center)
      .width('100%')

      //图表
      Row() {
        McLineChart({
          options: this.defOption
        })
      }
      .height('85%')

    }
    .padding({
      top: 12,
      bottom: 12,
      left: 10,
      right: 10
    })
    .width('100%')
    .height('100%')
  }
}

export default Start