import { BusinessError } from '@kit.BasicServicesKit';
import { Xb_CircleButton } from './Xb_Button';
import { window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

/**
 * 窗口控制按钮
 */
@ComponentV2
export struct Xb_WindowDecor {

  @Local WindowMaximize: boolean = false

  @Param context: common.UIAbilityContext | undefined = undefined
  @Param WindowClass: window.Window | undefined = undefined

  @Event onMaxOrReChange: () => void
  @Event onMinChange: () => void
  @Event onExitChange: () => void

  build() {
    Row() {
      ForEach(this.WindowDecor(), (item: DecorInfo, index: number) => {
        Xb_CircleButton({
          icon: item.icon,
          iconBackgroundColor: undefined,
          iconSize: index == 0 && !this.WindowMaximize ? 15 : 18,
          iconColor: $r('sys.color.icon_primary'),
          iconWeight: index != 0 || this.WindowMaximize ? FontWeight.Bold : FontWeight.Regular,
          theBackgroundColor: Color.Transparent,
          onCheck: item.onClick
        })
      })
    }
  }

  private WindowDecor(): DecorInfo[] {
    return [
      {
        icon: this.WindowMaximize ? $r('sys.symbol.arrow_down_right_and_arrow_up_left') : $r('sys.symbol.arrowshape_up_left_and_arrowshape_down_right'),
        onClick: () => {
          console.log(`#Xb_WindowDecorModel 点击最大&复原按钮`)
          if (this.WindowClass) {
            if (this.WindowMaximize) {
              console.log(`#Xb_WindowDecorModel 即将复原`)
              let promise = this.WindowClass.recover().catch((err: BusinessError) => {
                console.error(`#Xb_WindowDecorModel 复原失败：${err.code}, message: ${err.message}`)
              })
              promise.then(() => {
                this.WindowMaximize = false
                console.info(`#Xb_WindowDecorModel Succeeded in recover the window. ${this.WindowMaximize}`)
              })
            } else {
              console.log(`#Xb_WindowDecorModel 即将最大化`)
              let promise = this.WindowClass.maximize().catch((err: BusinessError) => {
                console.error(`#Xb_WindowDecorModel 最大化失败：${err.code}, message: ${err.message}`)
              })
              promise.then(() => {
                this.WindowMaximize = true
                console.info(`#Xb_WindowDecorModel Succeeded in maximizing the window. ${this.WindowMaximize}`)
              })
            }
          } else {
            this.onMaxOrReChange()
          }
        }
      },
      {
        icon: $r('sys.symbol.minus'),
        onClick: () => {
          if (this.WindowClass) {
            this.WindowClass.minimize().catch((err: BusinessError) => {
              console.error(`#Xb_WindowDecorModel 最小化失败：${err.code}, message: ${err.message}`)
            })
          } else {
            this.onMinChange()
          }
        }
      },
      {
        icon: $r('sys.symbol.xmark'),
        onClick: () => {
          if (this.context) {
            this.context.terminateSelf().catch(() => {
              console.error(`#Xb_WindowDecorModel 窗口关闭失败`)
            })
          } else {
            this.onExitChange()
          }
        }
      }
    ]
  }

}

interface DecorInfo {
  icon: Resource
  onClick: () => void
}
