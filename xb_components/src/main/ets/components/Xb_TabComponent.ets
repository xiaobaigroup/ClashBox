import { Xb_TabBarPosition, Xb_TabBarVertical, Xb_WindowTabBarWidth, Xb_TabBarHeight, Xb_TabBarAvoidHeight,
  Xb_TabBarWidth,
  Xb_TabBarJustifyContent,
  Xb_TabBarAlignItems,
  Xb_TabTitleFontSize,
  Xb_TabIconFontSize} from "../utils/breakpoint/BreakPoint";
import { LengthMetrics } from "@kit.ArkUI";
import { Xb_AnimationStyle } from "../utils/Animation";


@ComponentV2
export struct Xb_TabComponent {
  // 配置参数
  @Param @Require config: Xb_TabComponentConfig

  @Param widthBp: number = 0
  @Param heightBp: number = 0
  @Param topSafeArea: number = 0
  @Param bottomSafeArea: number = 0
  @Param themeColor: ResourceColor = 0
  @Param windowMode: boolean = false

  @Local private currentIndex: number = 0
  @Local private tabController: TabsController = new TabsController()

  // 传入的内容渲染函数
  @BuilderParam TabContentBuilder: (index: number) => void = this.deafultTabContentBuilder

  build() {
    Tabs({
      barPosition: this.config.barPosition ??
      Xb_TabBarPosition(this.widthBp, this.heightBp),
     // index: this.currentIndex,
      controller: this.tabController
    }) {
      ForEach(this.config.tabs, (item: Xb_TabBuild, index: number) => {
        TabContent() {
          // 使用内部构建器渲染内容
          this.TabContentBuilder(index)
        }
        .padding({ top: this.topSafeArea })
        .tabBar(this.TabBarBuilder(item.name, index, item.icon))
      })
    }
    .vertical(this.config.vertical ??
    Xb_TabBarVertical(this.widthBp, this.heightBp))
    .barWidth(this.config.barWidth ??
      (this.windowMode ? Xb_WindowTabBarWidth(this.widthBp, this.heightBp) :
      Xb_TabBarWidth(this.widthBp, this.heightBp)))
    .barHeight(this.config.barHeight ??
      (this.bottomSafeArea > 0 ? Xb_TabBarAvoidHeight(this.widthBp, this.heightBp) :
      Xb_TabBarHeight(this.widthBp, this.heightBp)))
    .backgroundColor(this.config.backgroundColor)
    .barOverlap(this.config.barOverlap ?? false)
    .scrollable(this.config.scrollable ?? false)
   // .onTabBarClick((index: number)=>{
    //  this.currentIndex = index;
     // this.config.onTabChange?.(index); // 触发回调
  //  })
    .onChange((index)=>{
      Xb_AnimationStyle.animToAPI18(()=>{
        this.currentIndex = index
      }, 0)
    })
    .onAnimationStart((i: number, targetI: number)=>{
      if (i === targetI) {
        return
      }
      Xb_AnimationStyle.animToAPI18(()=>{
        this.currentIndex = targetI
        this.config.onTabChange?.(targetI)
      }, 0)
    })
  }

  // 标签栏构建器
  @Builder
  private TabBarBuilder(title: ResourceStr, index: number, icon: Resource) {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: Xb_TabBarJustifyContent(this.widthBp, this.heightBp),
      alignItems: this.config.tabBarAlignItems ??
        (this.windowMode ? ItemAlign.Center :
        Xb_TabBarAlignItems(this.widthBp, this.heightBp)),
      space: { main: LengthMetrics.vp(this.config.iconTextSpace) }
    }) {
      SymbolGlyph(icon)
        .fontSize(this.config.iconFontSize ?? Xb_TabIconFontSize(this.widthBp, this.heightBp))
        .fontColor([this.currentIndex === index ? this.themeColor : this.config.inactiveColor])
        .renderingStrategy(SymbolRenderingStrategy.MULTIPLE_OPACITY)
        .translate({ y: this.currentIndex == index ? this.config.activeIconOffset : 0 })
        .animation(Xb_AnimationStyle.animNormalUtils(0))

      Text(title)
        .fontColor(this.currentIndex === index ? this.themeColor : this.config.inactiveColor)
        .fontWeight(this.config.fontWeight)
        .fontSize(this.config.fontSize ?? Xb_TabTitleFontSize(this.widthBp, this.heightBp))
    }
    .width('100%')
    .height('100%')
    .padding({ top: this.config.tabBarPaddingTop })
  }

  // 内容构建器 - 根据索引渲染不同页面
  @Builder
  private deafultTabContentBuilder(index: number) {
  }

}


export interface Xb_TabComponentConfig {
  // 必需参数
  tabs: Xb_TabBuild[];

  // 可选样式参数
  inactiveColor?: ResourceColor;  // 非激活状态颜色
  backgroundColor?: ResourceColor; // 标签栏背景色
  fontSize?: number;              // 文字大小
  fontWeight?: number;            // 文字粗细
  iconFontSize?: Length;              // 文字大小
  iconTextSpace?: number;         // 图标文字间距
  tabBarPaddingTop?: number;      // 标签栏内上边距
  activeIconOffset?: number;      // 激活图标Y轴偏移

  // 布局参数
  barPosition?: BarPosition;
  vertical?: boolean;
  barWidth?: Length;
  barHeight?: Length;
  barOverlap?: boolean;
  scrollable?: boolean;

  // 回调函数
  onTabChange?: (index: number) => void; // 标签切换回调

  // 对齐方式
  tabBarJustifyContent?: FlexAlign;
  tabBarAlignItems?: ItemAlign;
}

export interface Xb_TabBuild {
  name: ResourceStr;
  icon: Resource;
}
