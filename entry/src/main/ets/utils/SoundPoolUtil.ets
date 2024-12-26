/**
 * 使用`SoundPool`播放短时音频工具类(例如`TextPicker`选择器每触发一次`onChange`事件时就会播放一次短时音频)
 *    XXX 目前快速滑动`TextPicker`组件之后触发的播放，还是没达到NEXT时钟APP内计时器的效果
 *    前提条件：将文件存储在该`module`下面的`rawfile`文件夹里面
 *    使用方法：
 *      0. import { sound } from "../../utils/SoundPoolUtil"
 *      1. sound.initSoundPool(最大播放的流数, '音频文件名.后缀名')
 *      2. sound.playAudioForSoundPool()
 *      3. sound.destroySoundPool()
 *
 * @author Enlin
 */
import { media } from '@kit.MediaKit'
import { audio } from '@kit.AudioKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { resourceManager } from '@kit.LocalizationKit'


const componentName: string = 'SoundPoolUtil'
let soundPool: media.SoundPool
let streamId: number = -1
let soundId: number = -1
let rawFileDescriptor: resourceManager.RawFileDescriptor

class SoundManager {

  /**
   * 初始化`SoundPool`
   * @param maxStreams    soundPool实例的最大播放的流数
   * @param audioFileName 短时音频在`rawfile`文件夹下面的名字
   */
  public async initSoundPool(maxStreams: number, audioFileName: string) {
    if (audioFileName && canIUse('SystemCapability.Multimedia.Media.SoundPool')) {
      try {
        await this.createSoundPool(maxStreams, audioFileName)
        hilog.info(0x61A0, componentName, `#initSoundPool#初始化短时音频: audioFileName is ${audioFileName}`)
      } catch (error) {
        let e: BusinessError = error as BusinessError
        hilog.error(0x61A0, componentName, `ERROR:#playAudio#创建短时音频发生错误: code: ${e.code}, message: ${e.message}`)
      }
    }
  }
  /**
   * 播放指定短时音频
   * @param audioFileName 短时音频在`rawfile`文件夹下面的名字
   */
  public async playAudioForSoundPool() {
    try {
      this.play()
    } catch (error) {
      let e: BusinessError = error as BusinessError
      hilog.error(0x61A1, componentName, `ERROR:#playAudioForSoundPool#播放短时音频发生错误: code: ${e.code}, message: ${e.message}`)
    }
  }
  /**
   * 创建`SoundPool`，获取待播放音频
   *
   * @param maxStreams    soundPool实例的最大播放的流数
   * @param audioFileName 短时音频在`rawfile`文件夹下面的名字
   */
  private async createSoundPool(maxStreams: number, audioFileName: string){
    soundPool = await media.createSoundPool(
      maxStreams,
      {
        usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
        rendererFlags: 0
      }
    )
    // 获取音频文件的资源描述符
    await getContext().resourceManager.getRawFd(audioFileName)
      .then((fileDescriptor: resourceManager.RawFileDescriptor) => {
        rawFileDescriptor = fileDescriptor
      })
      .catch((error: BusinessError) => {
        hilog.error(0x61A2, componentName, `ERROR:#resourceManager.getRawFd('${audioFileName}')#获取资源文件时发生错误: code: ${error.code}, message: ${error.message}`)
      })
    // 绑定事件
    /*soundPool.on("loadComplete", async () => {
      // load()完成之后的回调
      // this.play()
    })
    soundPool.on("playFinished", async () => {

    })*/
    // 加载要播放的音频 会返回加载音频的id
    soundId = await soundPool.load(rawFileDescriptor.fd, rawFileDescriptor.offset, rawFileDescriptor.length)
  }

  /**
   * 播放音频
   */
  private async play(){
    streamId = await soundPool.play(soundId)
  }

  /**
   * 销毁`SoundPool`
   */
  public async destroySoundPool(){
    hilog.info(0x61A0, componentName, `#destroySoundPool#销毁短时音频`)
    // 终止播放
    soundPool.stop(streamId)
    // 卸载资源
    soundPool.unload(soundId)
    // 释放内存
    soundPool.release()
    soundPool.off('loadComplete')
    soundPool.off('playFinished')
    soundPool.off('error')
    streamId = -1
    soundId = -1
  }

}


export const customSound = new SoundManager()