import { getResourceString } from '../../utils/ResourceStringUtil'

const icon_emphasize: ResourceColor = $r('app.color.theme_color_main_yellow')

/**
 * 引导气泡资源目录
 */
export const PopTips: Resource[] = [
  $r('app.string.start_pop'),
  $r( 'app.string.config_pop'),
  $r( 'app.string.proxy_pop'),
  $r( 'app.string.proxy_delay_pop'),
]

/**
 *  引导提示气泡
 */
@Builder
export function PopupBuilder(__this: object, resourceId: Resource, onCheck: () => void) {
  Column({ space: 2 }) {
    // 使用传入的资源ID来构建不同文本
    Text(`${getResourceString($r('app.string.tips'), __this)}: ${getResourceString(resourceId, __this)}`)
    Text(getResourceString($r('app.string.know'), __this))
      .fontColor(icon_emphasize)
      .onClick(() => {
        onCheck()
      })
  }
  .padding(12)
  .alignItems(HorizontalAlign.Start);
}