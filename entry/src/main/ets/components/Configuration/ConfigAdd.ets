import { BreakpointState } from "../../common/breakpointsystem";

interface ConfigAddType {
  symbolStart? : Resource,
  text?: ResourceStr,
  symbolEnd?: Resource
}

@Component
struct ConfigAdd {
  private componentName: string = 'ConfigAdd';
  @Prop
  breakPointStateTabContentTitleMargin: BreakpointState<number>

  private configAddTypeArray: Array<ConfigAddType> = [
    // TODO 国际化
    { symbolStart: $r('sys.symbol.paperclip'), text: '从URL(链接)导入', symbolEnd: $r('sys.symbol.chevron_right')},
    { symbolStart: $r('sys.symbol.qrcode'), text: '从二维码导入', symbolEnd: $r('sys.symbol.chevron_right')},
    { symbolStart: $r('sys.symbol.doc_text_fill'), text: '从文件导入', symbolEnd: $r('sys.symbol.chevron_right')},
    { symbolStart: $r('sys.symbol.doc'), text: '新建空白配置', symbolEnd: $r('sys.symbol.chevron_right')},
  ]

  build() {
    Column(){
      List({ space: 10 }){
        ForEach( this.configAddTypeArray, (item: ConfigAddType, index: number)=> {
          ListItem(){
            Row(){
              SymbolGlyph(item.symbolStart).fontSize(24).fontColor([$r('app.color.settings_icon')]).margin({ right: 20 })
              Text(item.text).fontSize(16).fontColor($r('sys.color.font_primary'))
              Blank()
              SymbolGlyph(item.symbolEnd).fontSize(24).fontColor([$r('app.color.settings_icon')])
            }
            .width('100%')
            .padding({ left: 12, right: 12 })
            .alignItems(VerticalAlign.Center)
          }
          .backgroundColor($r('app.color.container_background'))
          .width('100%')
          .height(56)
          .clickEffect({ level: ClickEffectLevel.MIDDLE })
          .borderRadius(20)
        })
      }
      .height('100%')
      .width('100%')
      .padding({
        left: this.breakPointStateTabContentTitleMargin.value,
        right: this.breakPointStateTabContentTitleMargin.value
      })
      .edgeEffect(EdgeEffect.Spring)
    }
    .height('100%')
  }
}


export default ConfigAdd