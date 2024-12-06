import { BreakpointState, BreakpointSystem } from '../../common/breakpointsystem';
import { chartInterface, McLineChart, Options } from '@mcui/mccharts'
import json from '@ohos.util.json';
import { ThemeControl } from '@ohos.arkui.theme'
import { gAppTheme } from '../../common/AppTheme'

// 在页面build前执行ThemeControl，就可以改变主题颜色
//ThemeControl.setDefaultTheme(gAppTheme)

let downloadData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
let uploadData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
let DownloadData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
let UploadData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
let DownloadSpeed = 0
let UploadSpeed = 0

// 使用 async/await 来等待 Promise 解决
async function updateDownloadData() {
  DownloadSpeed = Math.floor(Math.random() * 1200)
  UploadSpeed = Math.floor(Math.random() * 1200)
  downloadData.push(DownloadSpeed);
  downloadData.shift();
  uploadData.push(UploadSpeed);
  uploadData.shift();
}

function printData() {
  //console.log('downloadData: ' + JSON.stringify(downloadData));
  DownloadData = downloadData
  //console.log('uploadData: ' + JSON.stringify(uploadData));
  UploadData = uploadData
  //console.log('UploadData: ' + JSON.stringify(UploadData));
}

setInterval(async () => {
  await updateDownloadData(); // 调用更新数据的函数
  printData();

}, 1000);



@Component
struct Speed {
  /*
  @State backgroundPrimary: ResourceColor = $r('sys.color.background_primary')
  @State fontPrimary: ResourceColor = $r('sys.color.font_primary')
  @State iconOnPrimary: ResourceColor = $r('sys.color.icon_on_primary')
  @State iconFourth: ResourceColor = $r('sys.color.icon_fourth')

  onWillApplyTheme(theme: Theme) {
    this.backgroundPrimary = theme.colors.backgroundPrimary;
    this.fontPrimary = theme.colors.fontPrimary;
    this.iconOnPrimary = theme.colors.iconOnPrimary;
    this.iconFourth = theme.colors.iconFourth;
  }
*/
  //设置speed图标颜色，修改resources/base(dark)/element/color.json中speed_up_icon和app.color.speed_down_icon配置浅色和深色模式分别颜色
  @State fontColorValue:ResourceColor = ($r('app.color.speed_up_icon'));
  @State fontColorValue1:ResourceColor = ($r('app.color.speed_down_icon'));
  @State DownloadSpeed: number = 0
  @State UploadSpeed: number = 0
  // 定时器ID，用于清除定时器
  private timerId: number = 0;
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
  //初始化图表数据
  @State defOption: Options = new Options({
    //图例
    legend: {
      show: false,
      selectAble: false,
    },
    //图表位置
    grid: {
      top: 15,
      left: 31,
      right: 31,
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
      axisTick:{
        show: false
    },
      //轴线
      axisLine:{
        show: false
      },
      //Y轴分割线
      splitLine: {
        show: false
      },
      axisLabel:{
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
          color: '#ff0a59f7'
        },
        label: {
          show: false
        }
      },
    ]
  })

  onSpeedData() {
    this.DownloadSpeed = DownloadSpeed
    this.UploadSpeed = UploadSpeed
    //图表
    // 使用Option实例对象的setVal方法来实现，修改什么属性就传什么
    this.defOption.setVal({
      series: [
        {
          smooth: false, //平滑曲线
          name: '上行速度(Kb/s)',
          data: UploadData,
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
          }
        },
        {
          smooth: false, //平滑曲线
          name: '下行速度(Kb/s)',
          data: DownloadData,
          label: {
            show: false,
            color: '#ff0a59f7',
            offset: [-10, -10]
          },
          //折线拐点配置
          itemStyle: {
            symbol: 'solidCircle',
            symbolSize: 2,
            borderWidth: 1
          },
          lineStyle: {
            width: 3,
            color: '#ff0a59f7'
          }
        }
      ]
    })
  }

  aboutToAppear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.speedfontSize)
    BreakpointSystem.getInstance().start()
    // 设置定时器，每秒调用一次 onSpeedData 函数
    this.timerId = setInterval(() => {
      this.onSpeedData();
    }, 1000);

  }

  aboutToDisappear() {

    BreakpointSystem.getInstance().attach(this.compStr)
    BreakpointSystem.getInstance().attach(this.fontSize)
    BreakpointSystem.getInstance().attach(this.speedfontSize)
    BreakpointSystem.getInstance().stop()

    // 清除定时器
    clearInterval(this.timerId);
    //this.phonelistener.off('change');
  }

  build() {
    Column() {
      Row() {
        Row() {
          //网络速率
          Text($r('app.string.Speed'))
            .fontSize(this.fontSize.value)
        }
        .width('145vp')

        //.margin({ top: 10, left: 20 })
        Row() {
        }
        .flexGrow(1)

        Column() {
          Row() {
            Text(this.DownloadSpeed.toString())
              .width(40)
              //.margin({ right: 3 })
              .fontSize(this.speedfontSize.value)
              .fontColor($r('app.color.speed_up_icon'))
            Text(' B/s')
              .fontColor(this.fontColorValue)
            Text() {
              SymbolSpan($r('sys.symbol.chevron_up'))
                .fontSize(this.speedfontSize.value)
                .fontColor([this.fontColorValue])
            }

          }

          Row() {
            Text(this.UploadSpeed.toString())
              .width(40)
              //.margin({ right: 3 })
              .fontSize(this.speedfontSize.value)
              .fontColor($r('app.color.speed_down_icon'))
            Text(' B/s')
              .fontColor(this.fontColorValue1)
            Text() {
              SymbolSpan($r('sys.symbol.chevron_down'))
                .fontSize(this.speedfontSize.value)
                .fontColor([this.fontColorValue1])
            }

          }
        }
        .width('100vp')

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

export default Speed