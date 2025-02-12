import fs from '@ohos.file.fs';
import { getProfilePath, getProfilesPath } from './appPath';
import { Context } from '@kit.AbilityKit';
import { fileUri } from '@kit.CoreFileKit';
import { ProxyGroup, ProxyType, SubscriptionInfo } from './models/Common';
import {  util } from '@kit.ArkTS';
import { http } from '@kit.NetworkKit';

export function generateUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

export enum ProfileType {
  File,
  Url,
  External
}

let utf8e = new util.TextEncoder()
export class Profile {
  id: string
  name: string | null
  type: ProfileType
  url: string = ""
  currentGroupName: string | null = null
  isUpdating: boolean = false
  autoUpdate: boolean = true
  lastUpdateDate: number
  autoUpdateDuration: number
  subscriptionInfo: SubscriptionInfo | null
  proxySelected: Map<string, string> = new Map()
  context?: Context

  constructor(type = ProfileType.Url, url: string) {
    this.id = generateUUID()
    this.name = null
    this.type = type // 0 url
    this.url = url
    this.autoUpdateDuration = 0
    this.lastUpdateDate = new Date().getTime()
    this.subscriptionInfo = null
  }
  private globalUa: string = "ClashNext/v2.0.0"
  loadContext(context: Context | undefined, globalUa: string | undefined = "ClashNext/v2.0.0"){
    this.context = context
    this.globalUa = globalUa
  }
  async checkAndUpdate(vailConfig: (config: string) =>Promise<string>): Promise<void>{
    const isExists = await this.check();
    if (!isExists) {
      if (this.url != "") {
        await this.update(vailConfig);
      }
    }
  }
  async check(): Promise<boolean>{
    let profilePath = await getProfilePath(this.context, this.id);
    return await fs.access(profilePath, fs.AccessModeType.EXIST)
  }
  async delete(): Promise<void>{
    if(!await this.check())
      return
    let profileDir = await getProfilesPath(this.context)
    let profilePath = await getProfilePath(this.context, this.id);
    fs.unlink(profilePath)
    fs.unlink(profileDir)

  }
  async update(vailConfig: (config: string) =>Promise<string>): Promise<boolean>{
    let httpRequest = http.createHttp()
    const resp = await httpRequest.request(this.url, { header: {
      "User-Agent": this.globalUa ?? "ClashNext/v2.0.0"
    },connectTimeout: 5000, readTimeout: 5000})
    const disposition = resp.header["content-disposition"] as string
    const userinfo = resp.header["subscription-userinfo"] as string
    if (!this.name || this.name == "") {
      this.name = getFileNameForDisposition(disposition) ?? this.id
      this.subscriptionInfo = SubscriptionInfo.formHString(userinfo)
    }
    if (resp.result) {
      await this.save(resp.result as string | ArrayBuffer, vailConfig)
    }
    return true
  }
  async save(raw: string | ArrayBuffer, vailConfig:(config: string)=> Promise<string>): Promise<Profile>{
    let bytes = new Uint8Array()
    if(typeof raw == "string"){
      bytes= utf8e.encodeInto(raw)
    }else{
      bytes = new Uint8Array(raw)
    }
    const filePath = await getProfilePath(this.context, this.id)
    const file = await fs.open(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC)
    await fs.write(file.fd, bytes.buffer)
    await fs.fsync(file.fd)
    await fs.close(file.fd)
    let message = await vailConfig(this.id);
    if (message != "") {
      this.delete()
      throw new Error(message);
    }
    this.lastUpdateDate = new Date().getTime()
    return this
  }
  async saveByUri(uri: string): Promise<Profile>{
    const filePath = await getProfilePath(this.context, this.id)
    await fs.copy(uri, fileUri.getUriFromPath(filePath))
    return this
  }
  getSelectedProxy(g: ProxyGroup): string | undefined{
    if (g.type !== ProxyType.Selector)
      return g.now
    let dd = this.proxySelected.get(g.name) ?? g.now
    return dd
  }
}


function getFileNameForDisposition(disposition: string | undefined): string | null {
  if (disposition == null) return null;
  console.log("disposition", disposition)
  const match = disposition.match(/filename="?(.+)"?/)
  if(match){
    const filename = decodeURIComponent(match[1]);
    return filename
  }else{
    return null;
  }
}