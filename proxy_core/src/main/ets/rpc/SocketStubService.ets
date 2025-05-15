import { socket } from '@kit.NetworkKit';
import { common } from '@kit.AbilityKit';
import { CommonVpnService } from './CommonVpnService';
import { FlClashVpnService } from './FlClashVpnService';
import { startIpc } from 'libflclash.so';


export class SocketStubService {
  server: socket.LocalSocketServer = socket.constructLocalSocketServerInstance();
  clientPool: Map<number, socket.LocalSocketConnection>
  vpnService: CommonVpnService
  constructor( context: common.Context) {
    this.clientPool = new Map()
    this.vpnService = new FlClashVpnService(context)
    this.vpnService.init()
  }

  async startService(){
    try {
      const socketPath = this.vpnService.context.filesDir + '/clashNext.sock'
      const goPath = this.vpnService.context.filesDir + '/clash_go.sock'
      startIpc(goPath)
      await this.server.listen({ address: socketPath})
      this.server.on('connect', (client: socket.LocalSocketConnection) => {
          this.clientPool.set(client.clientId, client);
          client.on("message", (value: socket.LocalSocketMessageInfo) => {
            this.vpnService.onRemoteMessageRequest(client, value)
          })
          client.on('close', () => {
            client.off("message")
            client.off("close")
            this.clientPool.delete(client.clientId);
          });
      })
    } catch (e) {
      console.error("socket failure", e.message)
    }
  }
  startVpn(){
    this.vpnService.startVpn()
  }
  stopVpn(){
    this.vpnService.stopVpn()
  }
}
function sleepTime(timeout = 100): Promise<void>{
  return new Promise((resolve)=>{
    setTimeout(resolve, timeout)
  })
}