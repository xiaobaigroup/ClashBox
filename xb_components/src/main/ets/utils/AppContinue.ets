import { AbilityConstant, common, Want, wantConstant } from '@kit.AbilityKit';
import { promptAction, window } from '@kit.ArkUI';
import { AppContinueNavInfo } from '../entity/Common';
import { Xb_ToastUtil } from './ToastUtils';

/**
 * 软件多设备续接
 * 需在EntryAbility.ets内先导入UIAbilityContext和storage
 * 分别在EntryAbility.ets内OnCreat、OnContinue等对应的地方放相关带Use名字的回调
 * OnNewWant属于单实例应用使用，若为多单实例应用则无需使用
 * 默认为不可迁移状态
 * 下列为主动设置为可迁移状态即可续接
this.context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE, (result) => {
console.info('setMissionContinueState ACTIVE result: ', JSON.stringify(result));
});
 * module.json5文件中增加continuable为true
"module": {
"abilities": [{ "continuable": true, }]
}
 */
@ObservedV2
class AppContinue{
  storage: LocalStorage = new LocalStorage()
  ctx?: common.UIAbilityContext
  want?: Want
  @Trace pageParams?: AppContinueNavInfo
  @Trace startMode: string = '冷启动'//冷启动需要每次触发启动回调，目标端设备才会出现续接图标；热启动则只需触发一次后面会自动出现

  //TODO 还没写完，需要导入数据部分未写入pageParams

  InputInfo(storage: LocalStorage, ctx: common.UIAbilityContext, startMode: string, want: Want){
    this.want = want
    this.startMode = startMode
    this.storage = storage
    if (ctx) {
      this.ctx = ctx
    }
  }

  OnCreatUse(want: Want, launchParam: AbilityConstant.LaunchParam){
    this.OnNewWantUse(want, launchParam)

    //默认设置为不可迁移状态，冷启动
    //if (this.startMode === '冷启动') {
      if (this.ctx) {
        this.ctx.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE, (result) => {
          console.info(`分享数据#setMissionContinueState: ${JSON.stringify(result)}`);
        });
      }
   // }
  }

  OnContinueUse(wantParam: Record<string, Object>, page: string){
    const targetVersion  = wantParam.version;  // 获取迁移对端应用的版本号
    // 应用可根据源端版本号设置支持接续的最小兼容版本号，源端版本号可从app.json5文件中的versionCode字段获取；防止目标端版本号过低导致不兼容。
    const versionThreshold: number = 0; // 替换为应用自己支持兼容的最小版本号
    // 兼容性校验
    if (targetVersion < versionThreshold) {
      // 建议在校验版本兼容性失败后，提示用户拒绝迁移的原因
      promptAction.showToast({
        message: '目标端应用版本号过低，不支持接续，请您升级应用版本后再试',
        duration: 2000
      })
      // 在兼容性校验不通过时返回MISMATCH
      return AbilityConstant.OnContinueResult.MISMATCH;
    }
    console.info(`onContinue version = ${wantParam.version}, targetDevice: ${wantParam.targetDevice}`);
    wantParam[wantConstant.Params.SUPPORT_CONTINUE_PAGE_STACK_KEY] = false;

    wantParam['targetPage'] = page
    wantParam['pageParams'] = this.pageParams!

    // 迁移数据保存
    const continueInput = '迁移的数据';
    if (continueInput) {
      // 将要迁移的数据保存在wantParam的自定义字段（如：data）中;
      wantParam["data"] = continueInput;
    }
    return AbilityConstant.OnContinueResult.AGREE;
  }

  OnNewWantUse(want: Want, launchParam: AbilityConstant.LaunchParam){
    console.info(`EntryAbility onNewWant ${AbilityConstant.LaunchReason.CONTINUATION}`)
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      // 将上述的保存的数据取出恢复
      let continueInput = '';
      if (want.parameters !== undefined) {
        continueInput = JSON.stringify(want.parameters.data);
        console.info(`continue input ${continueInput}`);
      }
      this.ctx!.restoreWindowStage(this.storage);
      // 迁移热启动时，设置状态为可迁移
      if (this.ctx) {
        this.ctx.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE, (result) => {
          console.info(`分享数据#setMissionContinueState: ${JSON.stringify(result)}`);
        });
      }
    }
  }

  /**
   说明
   当前仅支持router路由的页面栈信息自动恢复，暂不支持navigation路由的页面栈自动恢复。
   如果应用使用navigation路由，可以设置不进行页面栈迁移，并将需要接续的页面（或页面栈）信息保存在want中传递，然后在目标端手动加载指定页面。
   */
  onWindowStageRestoreUse(windowStage: window.WindowStage, navPath:NavPathStack) {
    const targetPage = JSON.stringify(this.want!.parameters!.targetPage)
    const pageParams = JSON.stringify(this.want!.parameters!.pageParams)
    // 若不需要自动迁移页面栈信息，则需要在此处设置应用迁移后进入的页面
    windowStage.loadContent('pages/Index', (err, data) => {
      navPath.pushPath({name: targetPage, param: pageParams})
      if (err.code) {
        console.error('Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      console.info('Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }


  // 使用applink来续接保存uri数据
  continuePut(wantParam: Record<string, Object>, uri: string, isOn: boolean = true){
    const targetVersion  = wantParam.version;  // 获取迁移对端应用的版本号
    // 应用可根据源端版本号设置支持接续的最小兼容版本号，源端版本号可从app.json5文件中的versionCode字段获取；防止目标端版本号过低导致不兼容。
    const versionThreshold: number = 0; // 替换为应用自己支持兼容的最小版本号
    // 兼容性校验
    if (targetVersion < versionThreshold) {
      // 建议在校验版本兼容性失败后，提示用户拒绝迁移的原因
      Xb_ToastUtil.showToast({
        message: '目标端应用版本号过低，不支持接续，请您升级应用版本后再试',
        duration: 2000
      })
      // 在兼容性校验不通过时返回MISMATCH
      return AbilityConstant.OnContinueResult.MISMATCH;
    }
    console.info(`分享数据#onContinue version = ${wantParam.version}, targetDevice: ${wantParam.targetDevice}`);

    // 迁移数据保存
    if (uri) {
      // 将要迁移的数据保存在wantParam的自定义字段（如：data）中;
      wantParam["uri"] = uri;
      console.info(`分享数据#onContinue url: = ${wantParam["uri"]}`);
    }

    if (!isOn) {
      Xb_ToastUtil.showToast({
        message: '请在应用设置开启续接功能',
        duration: 2000
      })
    }
   return isOn ? AbilityConstant.OnContinueResult.AGREE : AbilityConstant.OnContinueResult.REJECT;
  }

  // 使用applink来续接获取uri数据
  continueGet(want: Want, launchParam: AbilityConstant.LaunchParam, ctx: common.UIAbilityContext){
    this.ctx = ctx
    try {
      if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
        // 将上述的保存的数据取出恢复
        if (want.parameters !== undefined) {
          want.uri = want.parameters.uri as string
          console.info(`分享数据#continue input ${want.uri}`)
        }
      }
      if (this.ctx) {
        this.ctx.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE, (result) => {
          console.info(`分享数据#setMissionContinueState: ${JSON.stringify(result)}`);
        });
        this.ctx.restoreWindowStage(this.storage)
      }
    }catch (e){
      console.error(`分享数据#continue error ${e}`)
    }
  }
}

export const Xb_AppContinue: AppContinue = new AppContinue()