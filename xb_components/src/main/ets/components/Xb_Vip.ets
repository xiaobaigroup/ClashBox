// vip铭牌标志
@ComponentV2
export struct Xb_Vip{
  @Param textContent: ResourceStr = ''
  @Param textSize: string | number | Resource = 16
  @Param vipIcon: Resource = $r('sys.symbol.vip_rectangle_fill')
  @Param vipSize: string | number | Resource = 20
  @Param vipColor: ResourceColor[] = [$r('sys.color.multi_color_10'), Color.White]

  build() {
    Row({space: 3}){
      Text(this.textContent).fontSize(this.textSize)
      SymbolGlyph(this.vipIcon).fontSize(this.vipSize).fontColor(this.vipColor)
        .fontWeight(FontWeight.Medium).renderingStrategy(SymbolRenderingStrategy.MULTIPLE_COLOR)
    }
  }
}