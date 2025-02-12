import fs from '@ohos.file.fs';
import { getProfilePath, getProfilesPath } from './appPath';
import { rcp } from '@kit.RemoteCommunicationKit';
import { Context } from '@kit.AbilityKit';
import { fileUri } from '@kit.CoreFileKit';
import { ProxyGroup, ProxyType, SubscriptionInfo } from './models/Common';
import { JSON, uri, util } from '@kit.ArkTS';

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

let utf8 = new util.TextDecoder()

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
  loadContext(context: Context | undefined){
    this.context = context
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
    let profilePath = await getProfilePath(this.context, this.id);
    fs.unlink(profilePath)
  }
  async update(vailConfig: (config: string) =>Promise<string>): Promise<boolean>{
    const session = rcp.createSession();
    const resp = await session.get(this.url)
    const disposition = resp.headers["content-disposition"] as string
    const userinfo = resp.headers["subscription-userinfo"] as string
    if (!this.name || this.name == "") {
      this.name = getFileNameForDisposition(disposition) ?? this.id
      this.subscriptionInfo = SubscriptionInfo.formHString(userinfo)
    }
    if (resp.body) {
      await this.save(new Uint8Array(resp.body), vailConfig)
    }
    return true
  }
  async save(bytes: Uint8Array, vailConfig:(config: string)=> Promise<string>): Promise<Profile>{
    let result = utf8.decodeToString(bytes)
    let message = await vailConfig(result);
    if (message != "") {
      throw new Error(message);
    }
    const filePath = await getProfilePath(this.context, this.id)
    const file = await fs.open(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC)
    await fs.write(file.fd, bytes.buffer)
    await fs.fsync(file.fd)
    await fs.close(file.fd)
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
    console.log("getSelectedProxy", dd)
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