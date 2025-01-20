import { ProfileRepo } from "proxy_core/src/main/ets/ProfileRepo";
import { Context, Want } from "@kit.AbilityKit";
import { SocketProxyService, Profile, ProfileType, UpdateConfigParams, ClashConfig, getHome,
  LogInfo,
  Provider,
  ProxyMode} from "proxy_core";
import { vpnExtension } from "@kit.NetworkKit";
import { ConfigData } from "../common/PageArgumentEntity";
import { promptAction } from "@kit.ArkUI";
import { ProxyGroup } from "proxy_core/src/main/ets/models/Common";
import { ConfigExtendedParams } from "proxy_core/src/main/ets/models/ClashConfig";
import { EventHub, EventKey } from "../common/EventHub";
import { AppConfig, ClashCore } from "./AppState";
import  fs from  "@ohos.file.fs"

export class ClashViewModel {
  profileRepo = new ProfileRepo()
  socketProxy = new SocketProxyService()
  context: Context | undefined
  async init(context: Context, core: ClashCore) {
    this.context = context
    await this.profileRepo.init(context)
    this.socketProxy.init(context)
    await this.initGeoIp()
    await this.ChangeCore(core)
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
    } else{
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
  async changeProxy(profile: Profile, g:string, p: string){
    try {
      console.log("changeProxy", g, p);
      profile.proxySelected?.set(g, p)
      await this.profileRepo.addOrUpdate(profile)
      await this.socketProxy.patchSelector(g, p)
    } catch (e) {
      promptAction.showToast({message: e.message, duration:3000})
    }
  }
  async testDelay(proxyName: string): Promise<number>{
    try {
      let delay = await this.socketProxy.healthCheck(proxyName)
      return delay;
    } catch (e) {
      promptAction.showToast({message: e.message, duration: 3000})
    }
    return -1;
  }
  async updateGeoData(geoName: string, geoType: string): Promise<string>{
    return this.socketProxy.updateGeoData(geoName, geoType)
  }
  async getTraffic(){
    return await this.socketProxy.queryTrafficNow()
  }
  async getTotalTraffic(){
    return await this.socketProxy.queryTrafficTotal()
  }
  async queryProviders(){
    return this.socketProxy.queryProviders()
  }
  async updateProvider(provider: Provider){
    return this.socketProxy.updateProvider(provider.type, provider.name)
  }

  job?: (()=>void)
  async startLog(enable: boolean, callback: (d: LogInfo) => void){
      if(enable){
        this.job = await this.socketProxy.setLogObserver((message)=>{
          callback(JSON.parse(message) as LogInfo)
        })
      }else{
        this.job?.()
      }
  }

  async updateProfile(profile: Profile){
    await this.profileRepo.addOrUpdate(profile)
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
  async getProxyGroups(model: ProxyMode): Promise<ProxyGroup[]>{
    console.log("FetchProxyGroup", model)
    let list = await this.socketProxy.queryProxyGroups(model)
    let favoriteProxys = AppStorage.get<Map<string, string>>("favoriteProxys")
    const groups = list.map((g)=>{
      g.proxies = g.proxies.map((p) => {
        p.isShowFavoriteProxy = favoriteProxys?.get(g.name + "|" + p.text) != null
        p.latency = -1
        p.g = g.name
        return p
      })
      return g
    })
    AppStorage.setOrCreate("proxyGroups", groups)
    console.log("FetchProxyGroup", groups)
    return groups
  }
  async ChangeCore(coreType: ClashCore){
    try {
      const vpnWant = {
        deviceId: "",
        bundleName: "org.xbgroup.clashnext",
        abilityName: "ClashVpnAbility",
        parameters: { "ClashCore" : coreType}
      } as Want
      vpnExtension.stopVpnExtensionAbility(vpnWant)
      await vpnExtension.startVpnExtensionAbility(vpnWant);
    } catch (e) {
      // TODO 用户点取消
      // 是否退出程序
      this.context?.getApplicationContext().killAllProcesses()
    }
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
    if(appConfig?.enableLogger){
      EventHub.sendEvent(EventKey.StartLog)
    }
  }
  async initGeoIp(){
    let geoIp = await readFile(this.context?.resourceDir + "/geoip.metadb")
    writeFile(await getHome(this.context) + "/geoip.metadb", geoIp)
    let geoip = await readFile(this.context?.resourceDir + "/GeoIP.dat")
    writeFile(await getHome(this.context) + "/GeoIP.dat", geoip)

    let geoSite = await readFile(this.context?.resourceDir + "/GeoSite.dat")
    writeFile(await getHome(this.context) + "/GeoSite.dat", geoSite)
    let Country = await readFile(this.context?.resourceDir + "/ASN.mmdb")
    writeFile(await getHome(this.context) + "/ASN.mmdb", Country)

  }
}
export async  function readFile(filePath: string): Promise<Uint8Array | null> {
  if(!await fs.access(filePath))
    return null;
  const file = await fs.open(filePath)
  const stats = await fs.stat(filePath)
  let bufSize = stats.size;
  let buf = new ArrayBuffer(bufSize);
  await fs.read(file.fd, buf, { offset: 0, length: bufSize });
  await fs.close(file);
  return new Uint8Array(buf);
}
export function writeFile(filePath: string, data: Uint8Array | null) {
  if(data != null && data.byteLength > 0){
    const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE)
    fs.writeSync(file.fd, data.buffer);
    fs.fsyncSync(file.fd)
    fs.closeSync(file);
  }
}

export default new ClashViewModel()