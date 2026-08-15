import { socket } from '@kit.NetworkKit';
import { common } from '@kit.AbilityKit';
import { CommonVpnService } from './CommonVpnService';
import { FlClashVpnService } from './FlClashVpnService';
import { startIpc } from 'libflclash.so';
import { fileIo } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { writeFile } from '../fileUtils';


export class SocketStubService {
  server: socket.LocalSocketServer = socket.constructLocalSocketServerInstance();
  clientPool: Map<number, socket.LocalSocketConnection>
  vpnService: CommonVpnService
  constructor( context: common.Context) {
    this.clientPool = new Map()
    this.vpnService = new FlClashVpnService(context)
    this.vpnService.init()
  }

  async startService(requestId: number){
    try {
      const socketPath = this.vpnService.context.filesDir + '/ClashBox.sock'
      const goPath = this.vpnService.context.filesDir + '/clash_go.sock'
      // 清理上次进程残留的 socket 文件(强杀/异常退出时 onDestroy 未执行)，
      // 避免 startIpc bind 失败或 UI 侧误判就绪后连接被拒(connection refused)
      for (let path of [socketPath, goPath]) {
        try {
          if (await fileIo.access(path)) {
            await fileIo.unlink(path)
            console.log("SocketStubService 清理残留 socket 文件: " + path)
          }
        } catch (e) {
          console.warn(`SocketStubService 清理残留 socket 文件失败: ${path} ${e.message}`)
        }
      }
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
      await this.lockVpn(requestId)
    } catch (e) {
      console.error("socket failure", e.message)
      // 启动失败也清理残留文件, 避免下一次 startService 同样被旧文件阻塞
      try {
        const socketPath = this.vpnService.context.filesDir + '/ClashBox.sock'
        const goPath = this.vpnService.context.filesDir + '/clash_go.sock'
        for (let path of [socketPath, goPath]) {
          if (await fileIo.access(path)) {
            await fileIo.unlink(path)
          }
        }
      } catch (cleanErr) {
        console.warn(`SocketStubService 失败后清理 socket 文件异常: ${cleanErr.message}`)
      }
    }
  }
  async lockVpn(local: number) {
    let lockPath = this.vpnService.context.filesDir + '/vpn_ipc.lock';
    let encoder = new util.TextEncoder()
    writeFile(lockPath, encoder.encodeInto(local + ""))
  }
  startVpn(){
    this.vpnService.startVpn()
  }
  stopVpn(){
    this.vpnService.stopVpn()
  }
  async destroy(){
    this.clientPool.forEach((client) => {
      client.off("message")
      client.off("close")
      client.close()
    })
    this.clientPool.clear()
    this.server.off('connect')
    this.vpnService.stopVpn()
    const socketPath = this.vpnService.context.filesDir + '/ClashBox.sock'
    const goPath = this.vpnService.context.filesDir + '/clash_go.sock'
    let lockPath = this.vpnService.context.filesDir + '/vpn_ipc.lock';
    for (let path of [socketPath, goPath, lockPath]){
      if (await fileIo.access(path)) {
        await fileIo.unlink(path)
      }
    }
  }
}
function sleepTime(timeout = 100): Promise<void>{
  return new Promise((resolve)=>{
    setTimeout(resolve, timeout)
  })
}