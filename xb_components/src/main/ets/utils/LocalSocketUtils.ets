import { common } from '@kit.AbilityKit'
import { socket } from '@kit.NetworkKit'
import { util } from '@kit.ArkTS'
import { RpcRequest, RpcResult } from './RpcRequest'

export class LocalSocketUtils {
  context: common.Context | undefined
  clientPool: Map<number, socket.LocalSocketConnection> = new Map()
  server: socket.LocalSocketServer = socket.constructLocalSocketServerInstance();

  async sendClient(client: socket.LocalSocketConnection, message: string){
    await client.send({data: message, encoding:"utf-8", })
  }
  async StartSocket(socketPath: string, onRemoteMessageRequest: (client:socket.LocalSocketConnection, value: RpcRequest) => void){
    await this.server.listen({ address: socketPath})
    this.server.on('connect', (client: socket.LocalSocketConnection) => {
      this.clientPool.set(client.clientId, client);
      client.on("message", (value: socket.LocalSocketMessageInfo) => {
        const decoder = new util.TextDecoder()
        const request = JSON.parse(decoder.decodeToString(new Uint8Array(value.message))) as RpcRequest
        onRemoteMessageRequest(client, request)
      })
      client.on('close', () => {
        client.off("message")
        client.off("close")
        this.clientPool.delete(client.clientId);
      });
    })
  }
  IsClosed(client:socket.LocalSocketConnection){
    return !this.clientPool.has(client.clientId)
  }
  async SubMessage(
    socketPath: string,
    method: number,
    params: (string | number | boolean) [] = [],
    callBack: (message: string) => void
  ): Promise<() => void> {
    return new Promise(async (resolve, reject)=>{
      let tcp: socket.LocalSocket = socket.constructLocalSocketInstance();
      tcp.on('message', (value: socket.LocalSocketMessageInfo) => {
        let text = new util.TextDecoder()
        let dd = text.decodeToString(new Uint8Array(value.message))
        let list = dd.split("EOF")
        for (let index = 0; index < list.length; index++) {
          const element = list[index];
          try {
            if (element != ""){
              callBack(element)
            }
          }catch (e) {
            console.error("LocalSocket LocalSocket  error", e.message, element)
          }
        }
      })
      tcp.on('error', (e: Error) => {
        reject("LocalSocket 失败")
      });
      tcp.connect({address: { address: socketPath }, timeout:3000}).then(()=>{
        tcp.send({ data: JSON.stringify({method, params}) });
        resolve(()=>{
          tcp.close()
        })
      }).catch((e: Error)=>{
        console.log("LocalSocket error", e.message)
        reject(e)
      });
    })
  }

}