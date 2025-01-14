import { Context } from '@kit.AbilityKit';
import fs from '@ohos.file.fs';

const profilesDirectoryName = "/profiles";


export async function getHome(context: Context | undefined): Promise<string>{
  let home = context?.filesDir + "/flClash"
  if (!await fs.access(home, fs.AccessModeType.EXIST)){
    fs.mkdir(home)
  }
  return home
}
export async function getProfilesPath(context: Context | undefined): Promise<string> {
  let dir = await getHome(context) + profilesDirectoryName
  if(!await fs.access(dir, fs.AccessModeType.EXIST)){
    fs.mkdir(dir)
  }
  return dir
}
export async function getProfilePath(context: Context | undefined, id: string) {
  const directory = await getProfilesPath(context);
  return directory + `/${id}.yaml`
}