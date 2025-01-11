import fs from '@ohos.file.fs';
import { getProfilePath, getProfilesPath } from './appPath';
import { rcp } from '@kit.RemoteCommunicationKit';
import { Context } from '@kit.AbilityKit';

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
export class SubscriptionInfo{
  upload = 0
  download = 0
  total = 0
  expire = 0
  static formHString(info: string | undefined): SubscriptionInfo{
    const si = new SubscriptionInfo()
    if (!info)
      return si
    const list = info.split(";");
    const map = {} as  Record<string, number>;
    for (let i of list) {
      const keyValue = i.trim().split("=");
      map[keyValue[0]] = parseInt(keyValue[1]);
    }
    si.upload = map["upload"] ?? 0
    si.download = map["download"] ?? 0
    si.total = map["total"] ?? 0
    si.expire = map["expire"] ?? 0
    return si
  }
}



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
  async checkAndUpdate(): Promise<void>{
    const isExists = await this.check();
    if (!isExists) {
      if (this.url != "") {
        await this.update();
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
  async update(): Promise<boolean>{
    const session = rcp.createSession();
    const resp = await session.get(this.url)
    const disposition = resp.headers["content-disposition"] as string
    const userinfo = resp.headers["subscription-userinfo"] as string
    if (!this.name) {
      this.name = getFileNameForDisposition(disposition) ?? this.id
      this.subscriptionInfo = SubscriptionInfo.formHString(userinfo)
    }
    if (resp.body) {
      await this.save(new Uint8Array(resp.body))
    }
    return true
  }
  async save(bytes: Uint8Array): Promise<Profile>{
    let profilePath =  getProfilesPath(this.context);
    if(!await fs.access(profilePath, fs.AccessModeType.EXIST)){
      fs.mkdir(profilePath)
    }
    const filePath = await getProfilePath(this.context, this.id)
    const file = await fs.open(filePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC)
    await fs.write(file.fd, bytes.buffer)
    await fs.fsync(file.fd)
    await fs.close(file.fd)
    this.lastUpdateDate = new Date().getTime()
    return this
  }
}


function getFileNameForDisposition(disposition: string | undefined): string | null {
  if (disposition == null) return null;
  const parseValue = JSON.parse(disposition) as Record<string, string>;
  const parameters = parseValue["parameters"];
  // const fileNamePointKey = parameters.
  //   .firstWhere((key) => key == "filename*", orElse: () => "");
  // if (fileNamePointKey.isNotEmpty) {
  //   const res = parameters[fileNamePointKey]?.split("''") ?? [];
  //   if (res.length >= 2) {
  //     return Uri.decodeComponent(res[1]);
  //   }
  // }
  // const fileNameKey = parameters.keys
  //   .firstWhere((key) => key == "filename", orElse: () => "");
  // if (fileNameKey.isEmpty) return null;
  return null;
}