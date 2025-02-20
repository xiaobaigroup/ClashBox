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
import { AppConfig, AppState, ClashCore, getPackageInfo } from "./AppState";
import  fs from  "@ohos.file.fs"
import { sleep } from "./EntryAbility";
import { JSON } from "@kit.ArkTS";
import { ProxyItem } from "../common/ProxyData";

export interface DelayInfo{
    name: string
    delay: number
}

export class ClashViewModel {
  profileRepo = new ProfileRepo()
  socketProxy = new SocketProxyService()
  context: Context | undefined
  async init(context: Context) {
    const packageInfo = await getPackageInfo()
    AppState.versionName = packageInfo.versionName
    AppState.globalUA =  "ClashNext/v" + packageInfo.versionName
    this.context = context
    await this.profileRepo.init(context)
    this.socketProxy.init(context)
    await this.initGeoIp()
    await this.ChangeCore(undefined, false)
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
    await profile.checkAndUpdate((c)=>this.VailConfig(c))
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
    profile.name = decodeURIComponent(path.substring(path.lastIndexOf('/') + 1))
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
    const ua = AppStorage.get<ClashConfig>("clashConfig")?.["global-ua"]
    if(id){
      const profile = await this.getProfile(id)
      if(profile && profile.type == ProfileType.Url){
        profile.loadContext(this.context, ua)
        await profile.update((c)=> this.VailConfig(c))
        await this.profileRepo.addOrUpdate(profile)
      }
    } else {
      const list = (await this.getProfiles()).filter(d => d.type == ProfileType.Url)
      for(let p of list){
        p.loadContext(this.context, ua)
        await p.update((c)=>this.VailConfig(c))
        await this.profileRepo.addOrUpdate(p)
      }
    }
    EventHub.sendEvent(EventKey.FetchProfile, null)
  }
  async VailConfig(config: string): Promise<string>{
    return this.socketProxy.vailConfig(config)
  }
  async changeProxy(profile: Profile, g:string, p: string){
    try {
      profile.proxySelected?.set(g, p)
      await this.profileRepo.addOrUpdate(profile)
      await this.socketProxy.changeProxy(g, p)
      EventHub.sendEvent(EventKey.checkIpInfo)
    } catch (e) {
      promptAction.showToast({message: e.message, duration:3000})
    }
  }
  delayMap: Map<string, DelayInfo> = new Map()

  async testDelay(proxyName: string): Promise<number>{
    try {
      EventHub.sendEvent(EventKey.TestDelay, { name: proxyName, delay: 0 } as DelayInfo)
      let delay = await this.socketProxy.healthCheck(proxyName)
      EventHub.sendEvent(EventKey.TestDelay, { name: proxyName, delay: delay } as DelayInfo)
      this.delayMap.set(proxyName, { name: proxyName, delay: delay } as DelayInfo)
      return delay;
    } catch (e) {
      promptAction.showToast({message: e.message, duration: 3000})
    }
    return -1;
  }
  async testAllDelay(list: ProxyItem[]): Promise<number[]>{
    const result = await Promise.all(list.map((l)=> this.testDelay(l.name)))
    EventHub.sendEvent(EventKey.FetchProxyGroup)
    return result;
  }

  async updateGeoData( geoType: string, geoName: string): Promise<string>{
    return this.socketProxy.updateGeoData(geoType, geoName)
  }
  async getTraffic(){
    return await this.socketProxy.queryTrafficNow()
  }
  async getTotalTraffic(){
    return await this.socketProxy.queryTrafficTotal()
  }
  async getProviders(): Promise<Provider[]>{
    return await this.socketProxy.queryProviders()
  }
  async checkIpInfo(){
    return await this.socketProxy.checkIpInfo()
  }
  async queryProviders(){
    return this.socketProxy.queryProviders()
  }
  async updateProvider(provider: Provider){
    let result = await this.socketProxy.updateProvider(provider)
    if(result && result != ""){
      promptAction.showToast({message: provider.name + ":" + result})
    }
  }
  async upLoadProvider(provider: Provider, fileUri: string) {
    if(!fileUri){
      return
    }
    let result = await this.socketProxy.upLoadProvider(provider, fileUri)
    if (result && result != ""){
      promptAction.showToast({message: provider.name + ":" + result})
    }
  }

  job?: (()=>void)
  async startLog(enable: boolean, callback: (d: LogInfo) => void){
      if(enable){
        this.job = await this.socketProxy.setLogObserver((message)=>{
          callback(message)
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
  async getConnections(){
     return await this.socketProxy.queryConnections()
  }
  async closeConnection(id:string){
    return await this.socketProxy.closeConnection(id)
  }
  async clearConnections(){
    return await this.socketProxy.clearConnections()
  }
  async getRequestList(){
    return await this.socketProxy.getRequestList()
  }
  async clearRequestList(){
    return await this.socketProxy.clearRequestList()
  }
  async getProxyGroups(model: ProxyMode): Promise<ProxyGroup[]>{
    try {
      let list = await this.socketProxy.queryProxyGroups(model)
      let favoriteProxys = AppStorage.get<Map<string, string>>("favoriteProxys")
      const groups = list.map((g)=>{
        g.proxies = g.proxies.map((p) => {
          p.isShowFavoriteProxy = favoriteProxys?.get(g.name + "|" + p.name) != null
          p.latency = -1
          p.g = g.name
          return p
        })
        return g
      })
      return groups
    } catch (e) {
      promptAction.showToast({message: "获取代理失败: " + (e.message || e)})
    }
    return []
  }
  //BUG 第一次启动，参数传不过去
  // 第一次要权限弹窗
  async ChangeCore(coreType: ClashCore | undefined = undefined, restart: boolean = true){
    try {
      const vpnWant = {
        deviceId: "",
        bundleName: "org.xbgroup.clashnext",
        abilityName: "ClashVpnAbility",
        parameters: { "ClashCore" : coreType}
      } as Want
      // 若vpn进程没启动直接停止，会导致卡死或闪退， 不同系统不同现象
      if(restart){
        // 停止vpn进程
        await vpnExtension.stopVpnExtensionAbility(vpnWant)
          .then(() => {
            console.log("#VPN停止成功")
          })
          .catch((error: Error) => {
            console.log("#VPN停止失败")
          })
      }
      // 启动vpn进程
      // bug： 用户点取消，pad最新系统可能导致卡死在这里， 无解等系统修复
      await vpnExtension.startVpnExtensionAbility(vpnWant)
      await sleep(500)
      // Bug
      // this.socketProxy.registerMessage(()=>{
      //
      // })
    } catch (err) {
      console.log("#VPN try失败")
      console.error("ChangeCore", err.message || JSON.stringify(err))
      // 用户点取消，会走这里
      // 可能导致显现闪退
      // this.context?.getApplicationContext().killAllProcesses()
    }
  }

  async loadProfileAndConfig(id: string, config: ClashConfig | null = null, params: ConfigExtendedParams | null= null){
    let result = await this.socketProxy.loadConfig({
      "profile-id": id,
      config: config ?? new ClashConfig(),
      params: params ?? {} as ConfigExtendedParams
    } as UpdateConfigParams)
    if (result != ""){
      promptAction.showToast({message: result, duration: 3000 })
    }
    EventHub.sendEvent(EventKey.FetchProxyGroup, null)
  }
  async ReStartVpn(){
    if(this.vpnStarted){
      await this.loadConfig(false)
      await this.socketProxy.stopClash()
      // 核心崩溃 小钥匙一直在，要重启两量变
      await this.socketProxy.startClash()
    }
  }
  vpnStarted = false
  async StartVpn(){
    this.vpnStarted = true
    let result = await this.socketProxy.startClash()
    // 核心崩溃 小钥匙一直在，要重启两量变
    if (!result){
      result = await this.socketProxy.startClash()
    }
    if (result){
      EventHub.sendEvent(EventKey.StartedClash)
      EventHub.sendEvent(EventKey.checkIpInfo)
    }
  }

  async StopVpn(){
    this.vpnStarted = false
    this.socketProxy.stopClash()
    EventHub.sendEvent(EventKey.StopedClash)
    EventHub.sendEvent(EventKey.checkIpInfo)
  }

  async initProfile(){
    let appConfig = AppStorage.get<AppConfig>("appConfig")
    EventHub.sendEvent(EventKey.StartLog, appConfig?.enableLogger)
    await this.loadConfig(false)
    EventHub.sendEvent(EventKey.FetchProxyGroup)
  }

  proxyGroups :ProxyGroup[] = []
  async loadConfig(patch: boolean = true){
    let appConfig = AppStorage.get<AppConfig>("appConfig")
    let clashConfig = AppStorage.get<ClashConfig>("clashConfig")
    const profile = await this.profileRepo.query(appConfig?.currentProfileId)
    await this.loadProfileAndConfig(appConfig?.currentProfileId ?? "", clashConfig, {
      "is-patch": patch,
      "is-compatible": true,
      "override-dns": appConfig?.overrideDns,
      "selected-map": profile?.getSelectedMap()
    } as ConfigExtendedParams)
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