
// xxx.ets
import { CustomColors, CustomTheme } from '@ohos.arkui.theme'

export class AppColors implements CustomColors {
  fontPrimary: ResourceColor = '#ff032dff'
  fontOnPrimary: ResourceColor = '#FDECFF'
  font_secondary: ResourceColor = '#99000000'
  iconOnPrimary: ResourceColor = '#0A59F7'
  iconFourth: ResourceColor = '#999'
  compBackgroundTertiary: ResourceColor = '#Oc9162A8'
  compBackgroundEmphasize: ResourceColor = '#FF75D9'
  backgroundEmphasize: ResourceColor = '#FF75D9'
  interactiveFocus: ResourceColor = '#FF75D9'
  compBackgroundPrimary: ResourceColor = '#F1F3F5'
  compBackgroundSecondary: ResourceColor = '#199162A8'
}

export class CustomTheme1 implements CustomTheme {
}

export let gCustomTheme1: CustomTheme = new CustomTheme1()

export class AppTheme implements CustomTheme {
  public colors: AppColors = new AppColors()
}

export let gAppTheme: CustomTheme = new AppTheme()
