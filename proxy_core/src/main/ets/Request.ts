import { ipInfoSources } from "./models/Common";
import { rcp } from "@kit.RemoteCommunicationKit";


export async function checkIp() {
  for (let source of ipInfoSources) {
    try {
      const session = rcp.createSession();

      const resp = await session.get(source)
      if (resp.statusCode != 200 || resp.body == null) {
        continue;
      }
      if (resp.body) {
        return resp.toString()
      }else{
        continue;
      }
    } catch (e) {
      console.error("checkIp error ===> $e");
    }
  }
  return ""
}