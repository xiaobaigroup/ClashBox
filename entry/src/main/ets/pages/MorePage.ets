import { ThemeControl } from '@ohos.arkui.theme'
import { gAppTheme } from './AppTheme'

// 在页面build前执行ThemeControl，就可以改变主题颜色
//ThemeControl.setDefaultTheme(gAppTheme)

@Entry
@Component
struct MorePage {
  //系统颜色调用
  /*  @State icon_emphasize: ResourceColor = $r('sys.color.icon_emphasize')//高亮图标，蓝色
    @State icon_tertiary: ResourceColor = $r('sys.color.icon_tertiary')//三级图标色，浅灰色

     预留自定义主题，颜色在AppTheme里面修改
     onWillApplyTheme(theme: Theme) {
        this.backgroundPrimary = theme.colors.backgroundPrimary;
        this.fontPrimary = theme.colors.fontPrimary;
        this.iconOnPrimary = theme.colors.iconOnPrimary;
        this.iconFourth = theme.colors.iconFourth;
     }
 */



  build() {
    Column() {
      Text('更多')

    }
    .width('100%')

    .border({ color: '#880606', width: 2 })
  }

}
export default MorePage