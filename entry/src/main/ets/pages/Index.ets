//Index 媒体查询
import { BreakpointSystem, BreakpointState } from '../common/breakpointsystem'
import { mediaquery, window } from '@kit.ArkUI'
import Home from './HomePage'
import ProxyPage  from './ProxyPage'
import ConfigurationPage from './ConfigurationPage'
import MorePage from './MorePage'
import { hilog } from '@kit.PerformanceAnalysisKit'

//import { ThemeControl } from '@ohos.arkui.theme'
//import { gAppTheme } from './AppTheme'

// 在页面build前执行ThemeControl，就可以改变主题颜色
//ThemeControl.setDefaultTheme(gAppTheme)

//
interface marginGenerate {
  top: number, bottom: number,
  left:number, right: number
}

@Entry
@Component
struct Index {

  private componentName: string = 'Index'

  //系统颜色调用
  @State icon_emphasize: ResourceColor = $r('sys.color.icon_emphasize')//高亮图标，蓝色
  @State icon_tertiary: ResourceColor = $r('sys.color.icon_tertiary')//三级图标色，浅灰色

  /* 预留自定义主题，颜色在AppTheme里面修改
   onWillApplyTheme(theme: Theme) {
      this.backgroundPrimary = theme.colors.backgroundPrimary;
      this.fontPrimary = theme.colors.fontPrimary;
      this.iconOnPrimary = theme.colors.iconOnPrimary;
      this.iconFourth = theme.colors.iconFourth;
   } */
    //tabs图标文字颜色，修改resources/base(dark)/element/color.json中tabs_icon_text配置选中图标文字深浅模式颜色
    // app.color.tabs_icon_text1配置非选中图标和文字深浅模式颜色
  //  @State fontColorValue:ResourceColor = ($r('app.color.tabs_icon_text'));
  //  @State fontColorValue1:ResourceColor = ($r('app.color.tabs_icon_text1'));
    @State currentIndex: number = 0
    @State isLandscape:boolean = false
    @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;// 读取导航条区域的高度
    @StorageProp('topRectHeight') topRectHeight: number = 0;
    @State compStr: BreakpointState<string> = BreakpointState.of({ sm: "sm", md: "md", lg: "lg", xl: "xl" })
    @State compDirection: BreakpointState<FlexDirection> = BreakpointState.of({
      sm: FlexDirection.Column,
      md: FlexDirection.Column,
      lg: FlexDirection.Column,
      xl: FlexDirection.Column
    });
    @State compBarPose: BreakpointState<BarPosition> = BreakpointState.of({
      sm: BarPosition.End,
      md: BarPosition.End,
      lg: BarPosition.End,
      xl: BarPosition.Start
    });
    @State compVertical: BreakpointState<boolean> = BreakpointState.of({
      sm: false,
      md: false,
      lg: false,
      xl: true
    });
    @State compBarWidth: BreakpointState<string> = BreakpointState.of({
      sm: '100%', md: '100%', lg: '100%', xl: '60vp'
    });
    @State compBarHeight: BreakpointState<string> = BreakpointState.of({
      sm: '55vp', md: '55vp', lg: '55vp', xl: '100%'
    });
    @State TabIconfontSize: BreakpointState<number> = BreakpointState.of({
      sm: 24, md: 29, lg: 29, xl: 29
    });
    @State TabTitlefontSize: BreakpointState<number> = BreakpointState.of({
      sm: 12, md: 16, lg: 16, xl: 16
    });
    @State compMargin: BreakpointState<marginGenerate> = BreakpointState.of({
      sm: ({ top: 4, bottom: 5 } as marginGenerate),
      md: ({ top: 4, bottom: 5  } as marginGenerate),
      lg: ({ top: 5 } as marginGenerate),
      xl: ({ top: 5 } as marginGenerate)
    });

    @Builder TabBarBuilder(title: ResourceStr, index: number, TabIcon: Resource) {

      Flex({
        direction: this.compDirection.value,
        justifyContent: FlexAlign.Center,
        alignItems: ItemAlign.Center
      }) {
        Column() {
          SymbolGlyph(TabIcon)
            .fontColor([this.currentIndex === index ? this.icon_emphasize : this.icon_tertiary])
            .fontSize(this.isLandscape ? 24 : this.TabIconfontSize.value)
            .margin({top: 5})
            .effectStrategy(SymbolEffectStrategy.SCALE)

          Text(title)
            .fontColor(this.currentIndex === index ? this.icon_emphasize : this.icon_tertiary)
            .fontWeight(FontWeight.Medium)
            .margin(this.compMargin.value)
            .fontSize(this.isLandscape ? 12 : this.TabTitlefontSize.value)
        }
        .margin(this.isLandscape ? {left: 39 } : '0vp')
      }
      .width('100%')
      .height('100%')
    }


    // 当设备横屏时条件成立 ps:现在用于判定是否手机横屏
    deviceHeightListener:mediaquery.MediaQueryListener = this.getUIContext().getMediaQuery().matchMediaSync('(320vp< height <= 500vp)');

    aboutToAppear() {

      // 开启change监听
      this.deviceHeightListener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
        AppStorage.setOrCreate('isLandscapePhone', mediaQueryResult.matches)
        hilog.info(0x1000, this.componentName, `#媒体查询#设备高度改变#(320vp< height <= 500vp)结果: ${mediaQueryResult.matches}`)
      });

      BreakpointSystem.getInstance().attach(this.compStr)
      BreakpointSystem.getInstance().attach(this.compDirection)
      BreakpointSystem.getInstance().attach(this.compBarPose)
      BreakpointSystem.getInstance().attach(this.compVertical)
      BreakpointSystem.getInstance().attach(this.compBarWidth)
      BreakpointSystem.getInstance().attach(this.compBarHeight)
      BreakpointSystem.getInstance().attach(this.compMargin)
      BreakpointSystem.getInstance().attach(this.TabIconfontSize)
      BreakpointSystem.getInstance().attach(this.TabTitlefontSize)
      BreakpointSystem.getInstance().start()
    }

    aboutToDisappear() {

      BreakpointSystem.getInstance().detach(this.compStr)
      BreakpointSystem.getInstance().detach(this.compDirection)
      BreakpointSystem.getInstance().detach(this.compBarPose)
      BreakpointSystem.getInstance().detach(this.compVertical)
      BreakpointSystem.getInstance().detach(this.compBarWidth)
      BreakpointSystem.getInstance().detach(this.compBarHeight)
      BreakpointSystem.getInstance().detach(this.compMargin)
      BreakpointSystem.getInstance().attach(this.TabIconfontSize)
      BreakpointSystem.getInstance().attach(this.TabTitlefontSize)
      BreakpointSystem.getInstance().stop()

      // 解绑listener中注册的回调函数
      this.deviceHeightListener.off('change');
    }


    // 改变设备横竖屏状态函数
    /*private changeOrientation(isLandscape: boolean) {
      // 获取UIAbility实例的上下文信息
      let context:common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      // 调用该接口手动改变设备横竖屏状态
      window.getLastWindow(context).then((lastWindow) => {
        lastWindow.setPreferredOrientation(isLandscape ? window.Orientation.LANDSCAPE : window.Orientation.PORTRAIT)
      });
    }*/

  build() {
    Column() {
      Tabs({
        barPosition:this.isLandscape ? BarPosition.Start : this.compBarPose.value
      }) {
        TabContent() {
          Home()
        }
        .tabBar(this.TabBarBuilder($r('app.string.Home'), 0, $r('sys.symbol.house_fill')))

        TabContent() {
          ProxyPage()
        }
        .tabBar(this.TabBarBuilder( $r('app.string.Proxy'), 1, $r('sys.symbol.list_bullet_square_fill')))
        TabContent() {
          ConfigurationPage()
        }
        .tabBar(this.TabBarBuilder( $r('app.string.Configuration'), 2, $r('sys.symbol.folder_fill')))
        TabContent() {
          MorePage()
        }
        .tabBar(this.TabBarBuilder( $r('app.string.More'), 3, $r('sys.symbol.square_fill_grid_2x2')))
      }
      //.barOverlap(true)
      /*.backgroundBrightness({
        rate: 0.5,
        lightUpDegree: 0.5 })*/
      //.blur(50)
      .backgroundColor($r('app.color.background'))
      .backdropBlur(60)
      .vertical(this.isLandscape ? true : this.compVertical.value)/**/
      .barWidth(this.isLandscape ? '63vp' : this.compBarWidth.value)/**/
      .barHeight(this.isLandscape ? '100%' : this.compBarHeight.value)/**/
      .margin(this.compMargin.value)
      .animationDuration(200)
      .onChange((index: number) => {
        this.currentIndex = index

      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.background'))
    .padding({ top: px2vp(this.topRectHeight)-5, bottom: px2vp(this.bottomRectHeight) })
  }
}
