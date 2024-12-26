/**
 * RemoteCommunicationKit 工具类
 */

import { rcp } from '@kit.RemoteCommunicationKit';


const componentName = 'HttpUtils'


export async function httpGet(url: rcp.URLOrString): Promise<rcp.Response>{
  const method: rcp.HttpMethod = 'GET'
  const req = new rcp.Request(url, method);
  const session = rcp.createSession();
  return session.fetch(req)
}