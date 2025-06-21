import { socket, vpnExtension } from "@kit.NetworkKit";
import { common } from "@kit.AbilityKit";

export class Address {
  address: string;
  family: number;
  constructor(address: string, family: number) {
    this.address = address;
    this.family = family;
  }
}
export  class AddressWithPrefix {
  address: Address;
  prefixLength: number;
  constructor(address: Address, prefixLength: number) {
    this.address = address;
    this.prefixLength = prefixLength;
  }
}
export class VpnConfig {
  addresses: AddressWithPrefix[];
  mtu: number;
  dnsAddresses: string[];
  trustedApplications: string[] = []
  blockedApplications: string[] = []
  constructor(
    tunIp: Address = new Address("172.19.0.1", 1),
    dnsAddresses: string[] = ["172.19.0.2"]
  ) {
    this.addresses = [
      new AddressWithPrefix(tunIp, 24)
    ];
    this.mtu = 1400;
    this.dnsAddresses = dnsAddresses;
  }
}


export abstract class CommonVpnService{
  context: common.Context
  vpnConnection : vpnExtension.VpnConnection | undefined
  constructor(context: common.Context) {
    this.context = context
  }
  async sendClient(client: socket.LocalSocketConnection, message: string){
    await client.send({data: message, encoding:"utf-8", })
  }
  abstract onRemoteMessageRequest(client: socket.LocalSocketConnection, message: socket.LocalSocketMessageInfo): Promise<void>
  abstract init()
  async getTunFd(config: VpnConfig): Promise<number> {
    let tunFd = -1
    try {
      this.vpnConnection = vpnExtension.createVpnConnection(this.context as common.VpnExtensionContext);
      tunFd = await this.vpnConnection.create(config)
      console.log("ClashVPN", `获取tunFd: ${tunFd}`)
      return tunFd;
    } catch (error) {
      console.log("ClashVPN", `Clash启动失败 ${error.message} => ${error.stack}` )
      this.vpnConnection?.destroy()
      return -1
    }
  }
  async protect(fd: number){
    await this.vpnConnection?.protect(fd)
  }
  abstract startVpn(): Promise<boolean>
  stopVpn(){
    if(!this.vpnConnection){
      this.vpnConnection = vpnExtension.createVpnConnection(this.context as common.VpnExtensionContext);
    }
    this.vpnConnection?.destroy()
  }
}

export function isIpv4(ip: string): Boolean {
  let parts = ip.split("/")
  if (parts.length != 2) {
    return false
  }
  // TODO
  return ip.length == 4
}

export function isIpv6(ip: string): Boolean {
  let parts = ip.split("/")
  if (parts.length != 2) {
    return false
  }
  // TODO
  return ip.length == 16
}


