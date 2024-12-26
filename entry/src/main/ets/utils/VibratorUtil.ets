/**
 * 传感器：震动器的使用工具类
 *    前提条件：声明权限使用`ohos.permission.VIBRATE`
 *    使用方法：async (state) => { sound.playAudio("audio.mp3") }
 *
 * @author Enlin
 */
import { vibrator } from '@kit.SensorServiceKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { hilog } from '@kit.PerformanceAnalysisKit'


const componentName: string = 'VibratorUtil'

class VibratorUtil{

  public isAvailable(){
    // hilog.error(0x6100, componentName, `ERROR: #isAvailable#canIUse('SystemCapability.Sensors.MiscDevice') result is ${canIUse('SystemCapability.Sensors.MiscDevice')}`)
    return canIUse('SystemCapability.Sensors.MiscDevice')
  }

  /**
   * 触发预设震动：调整计时器时的振动效果 `haptic.clock.timer`
   */
  public vibratorTriggerOfHapticClockTimer(){

    // 查询是否支持预设`haptic.clock.timer`
    try {
      if (!vibrator.isSupportEffectSync(vibrator.EffectId.EFFECT_CLOCK_TIMER)) {
        hilog.info(0x6100, componentName,
          `#hapticClockTimerTrigger#isSupportEffectSync('${vibrator.EffectId.EFFECT_CLOCK_TIMER}')结果为false`)
        return
      }
      // 触发马达振动
      vibrator.startVibration(
        {
          type: 'preset',
          effectId: vibrator.EffectId.EFFECT_CLOCK_TIMER,
          count: 1,
          // intensity: 50
        },
        {
          // id: 0,
          usage: 'physicalFeedback'
        }
      )
    } catch (error) {
      let e: BusinessError = error as BusinessError
      hilog.error(0x6100, componentName, `ERROR: #hapticClockTimerTrigger#startVibration(): code: ${e.code}, message: ${e.message}`)
    }
  }

}


export const customVibrator = new VibratorUtil()
