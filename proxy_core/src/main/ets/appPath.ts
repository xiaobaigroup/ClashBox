import { Context } from '@kit.AbilityKit';
import fs from '@ohos.file.fs';

const profilesDirectoryName = "/profiles";


export async function getHome(context: Context | undefined): Promise<string>{
  let home = context?.filesDir + "/ClashNext"
  if (!await fs.access(home, fs.AccessModeType.EXIST)){
    fs.mkdir(home)
  }
  return home
}
export async function getProfilesPath(context: Context | undefined): Promise<string> {
  let dir = await getHome(context) + profilesDirectoryName
  if(!await fs.access(dir, fs.AccessModeType.EXIST)){
    await fs.mkdir(dir)
  }
  return dir
}
export async function getProfilePath(context: Context | undefined, id: string) {
  return await getProfileDir(context, id) + `/config.yaml`
}
export async function getProfileDir(context: Context | undefined, id: string) {
  const directory = await getProfilesPath(context);
  // 兼容ClashMeta 核心的文件目录
  if(!await fs.access(directory + `/${id}`, fs.AccessModeType.EXIST)){
    fs.mkdir(directory + `/${id}`)
  }
  return directory + `/${id}`
}