import { ProfileRepo } from "proxy_core/src/main/ets/ProfileRepo";
import { Context } from "@kit.AbilityKit";
import { SocketProxyService, Profile, ProfileType, UpdateConfigParams } from "proxy_core";
import { vpnExtension } from "@kit.NetworkKit";
import { ConfigData } from "../common/PageArgumentEntity";
import { promptAction } from "@kit.ArkUI";
import { ClashConfig, ProxyGroup } from "proxy_core/src/main/ets/models/Common";
import { ConfigExtendedParams } from "proxy_core/src/main/ets/models/ClashConfig";

export class ClashViewModel{
  profileRepo = new ProfileRepo()
  socketProxy = new SocketProxyService()
  context: Context | undefined
  async init(context: Context) {
    this.context = context
    await this.profileRepo.init(context)
    this.socketProxy.init(context)
    try {
      await vpnExtension.startVpnExtensionAbility({
        deviceId: "",
        bundleName: "org.xbgroup.clashnext",
        abilityName: "ClashVpnAbility",
      });
    } catch (e) {
      // TODO 用户点取消
      // 是否退出程序
    }
  }
  // 添加配置 url
  async addOrUpdateProfile(data: ConfigData, id: string | null){
    let profile = new Profile(ProfileType.Url, data.configUrl)
    if(id){
      const old = await this.profileRepo.query(id)
      if(old)
        profile = old
    }
    profile.loadContext(this.context)
    profile.name = data.configName
    profile.autoUpdate = data.isConfigAutoUpdate
    profile.autoUpdateDuration = data.configAutoUpdateTimeGapValue ?? 10
    await profile.checkAndUpdate()
    const isExists = await profile.check();
    if (isExists) {
      await this.profileRepo.addOrUpdate(profile)
    }else{
      promptAction.showToast({message: "文件保存失败！"})
    }
  }
  async updateProfileConfig(id: string | null): Promise<void>{
    if(id){
      const profile = await this.getProfile(id)
      if(profile){
        profile.loadContext(this.context)
        await profile.update()
        await this.profileRepo.addOrUpdate(profile)
      }
    } else {
      const list = (await this.getProfiles()).filter(d => d.type == ProfileType.Url)
      for(let p of list){
        p.loadContext(this.context)
        await p.update()
        await this.profileRepo.addOrUpdate(p)
      }
    }

  }
  async getProfiles(): Promise<Profile[]>{
    return await this.profileRepo.queryAll()
  }
  async getProfile(id: string): Promise<Profile | null>{
    return await this.profileRepo.query(id)
  }
  async deleteProfile(id: string): Promise<void>{
    let p = await this.getProfile(id)
    p?.delete()
    await this.profileRepo.delete(id)
  }
  async getProxyGroups(): Promise<ProxyGroup[]>{
      return this.socketProxy.queryProxyGroups()
  }
  async loadProfileAndConfig(id: string){
    let result = await this.socketProxy.loadConfig({
      "profile-id": id,
      config: new ClashConfig(),
      params: {} as ConfigExtendedParams
    } as UpdateConfigParams)
    promptAction.showToast({message: result, duration: 3000})
  }
}

export default new ClashViewModel()