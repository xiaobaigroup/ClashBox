
// 简易播放器实现
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';

export class AVPlayer {
  private avPlayer?: media.AVPlayer;
  surfaceID: string = '';

  setAVPlayerCallback() {
    this.avPlayer?.on('seekDone', (seekDoneTime: number) => {
      console.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    })
    this.avPlayer?.on('stateChange', async (state, reason) => {
      if (!this.avPlayer) {
        return;
      }
      switch (state) {
        case 'idle':
          this.avPlayer.release();
          break;
        case 'initialized':
          this.avPlayer.surfaceId = this.surfaceID;
          this.avPlayer.prepare().then(() => {
            console.info('AVPlayer prepare succeeded.');
          }, (err: BusinessError) => {
            console.error(`Invoke prepare failed, code is ${err.code}, message is ${err.message}`);
          });
          break;
        case 'prepared':
          this.avPlayer.play();
          break;
        case 'stopped':
          this.avPlayer.reset();
          break;
        default:
          break;
      }
    })
  }

  async avPlayerFdSrc() {
    this.avPlayer = await media.createAVPlayer();
    this.setAVPlayerCallback();
    let context = getContext(this) as common.UIAbilityContext;
    let fileDescriptor = await context.resourceManager.getRawFd('app_icon.png');
    this.avPlayer.fdSrc = fileDescriptor;
  }
}