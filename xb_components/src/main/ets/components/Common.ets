
// 要让Builder全局组件能传入变量，变量需要写入类里
@ObservedV2
export class ColorChange {
  color1:ResourceColor = $r("app.color.home_title_icon_background")
  @Trace color2: ResourceColor = $r("app.color.home_title_icon_background")
  @Trace color3: ResourceColor = $r("sys.color.icon_emphasize")
}

export const colorChange: ColorChange = new ColorChange()