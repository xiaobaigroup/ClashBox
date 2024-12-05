import { ThemeControl } from '@ohos.arkui.theme'
import { gAppTheme } from '../common/AppTheme'

// 在页面build前执行ThemeControl，就可以改变主题颜色
//ThemeControl.setDefaultTheme(gAppTheme)

@Entry
@Component
struct ConfigurationPage {


  build() {
    Column() {
      Text('配置')

    }
    .width('100%')

    .border({ color: '#880606', width: 2 })
  }

}
export default ConfigurationPage