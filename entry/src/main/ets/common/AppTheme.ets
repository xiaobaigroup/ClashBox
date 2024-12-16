
// xxx.ets
import { CustomColors, CustomTheme } from '@ohos.arkui.theme'

export class AppColors implements CustomColors {
  iconEmphasize: ResourceColor = $r('sys.color.alert')  //高亮图标色
}

export class CustomTheme1 implements CustomTheme {
}

export let gCustomTheme1: CustomTheme = new CustomTheme1()

export class AppTheme implements CustomTheme {
  public colors: AppColors = new AppColors()
}

export let gAppTheme: CustomTheme = new AppTheme()
