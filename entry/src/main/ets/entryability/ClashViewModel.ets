import { ProfileRepo } from "proxy_core/src/main/ets/ProfileRepo";
import { Context } from "@kit.AbilityKit";
import { SocketProxyService, Profile, ProfileType, UpdateConfigParams, ClashConfig } from "proxy_core";
import { vpnExtension } from "@kit.NetworkKit";
import { ConfigData } from "../common/PageArgumentEntity";
import { promptAction } from "@kit.ArkUI";
import { ProxyGroup } from "proxy_core/src/main/ets/models/Common";
import { ConfigExtendedParams } from "proxy_core/src/main/ets/models/ClashConfig";
import { EventHub, EventKey } from "../common/EventHub";
import { AppConfig } from "./AppState";

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
  async addOrUpdateProfileByUrl(data: ConfigData, id: string | null){
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
    EventHub.sendEvent(EventKey.FetchProfile, null)
  }
  async addOrUpdateProfileByFile(path: string, id: string | null){
    let profile = new Profile(ProfileType.File, path)
    if (id) {
      const old = await this.profileRepo.query(id)
      if (old)
        profile = old
    }
    profile.loadContext(this.context)
    profile.name = decodeURIComponent( path.substring(path.lastIndexOf('/') + 1))
    await profile.saveByUri(path);
    const isExists = await profile.check();
    if (isExists) {
      await this.profileRepo.addOrUpdate(profile)
    }else{
      promptAction.showToast({message: "文件保存失败！"})
    }
    EventHub.sendEvent(EventKey.FetchProfile, null)
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
    EventHub.sendEvent(EventKey.FetchProfile, null)
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
    EventHub.sendEvent(EventKey.FetchProfile, null)
  }
  async getProxyGroups(): Promise<ProxyGroup[]>{
    console.log("FetchProxyGroup", )
    let list =  await this.socketProxy.queryProxyGroups()
    console.log("FetchProxyGroup", list)
    return list
  }
  async loadProfileAndConfig(id: string, config: ClashConfig | null = null, params: ConfigExtendedParams | null= null){
    let result = await this.socketProxy.loadConfig({
      "profile-id": id,
      config: config ?? new ClashConfig(),
      params: params ?? {} as ConfigExtendedParams
    } as UpdateConfigParams)
    if (result != ""){
      promptAction.showToast({message: result, duration: 3000})
    }
    EventHub.sendEvent(EventKey.FetchProxyGroup, null)
  }

  async StartVpn(){
    this.socketProxy.startClash()
  }

  async StopVpn(){
    this.socketProxy.stopClash()
  }

  initProfile(){
    let appConfig = AppStorage.get<AppConfig>("appConfig")
    let clashConfig = AppStorage.get<ClashConfig>("clashConfig")
    if (appConfig?.currentProfileId){
      this.loadProfileAndConfig(appConfig?.currentProfileId, clashConfig)
    }
  }
}

export default new ClashViewModel()