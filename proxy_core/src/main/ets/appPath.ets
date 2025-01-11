import { Context } from '@kit.AbilityKit';

const profilesDirectoryName = "/profiles";

export function getProfilesPath(context: Context | undefined): string {
  return context?.filesDir + profilesDirectoryName
}
export async function getProfilePath(context: Context | undefined, id: string) {
  const directory = getProfilesPath(context);
  return directory + `/${id}.yaml`
}