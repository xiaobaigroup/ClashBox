import { socket, vpnExtension } from "@kit.NetworkKit";
import { common } from "@kit.AbilityKit";

export class Address {
  address: string;
  family: number;
  port: number;
  constructor(address: string, family: number, port: number = 0) {
    this.address = address;
    this.family = family;
    this.port = port;
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
export interface RouteInfo {
  "interface": string;
  destination: AddressWithPrefix;
  gateway: Address;
  hasGateway: boolean;
  isDefaultRoute: boolean;
  isExcludedRoute?: boolean;
}
export class VpnConfig {
  addresses: AddressWithPrefix[];
  routes: RouteInfo[];
  mtu: number;
  dnsAddresses: string[];
  isIPv4Accepted: boolean = true
  isIPv6Accepted: boolean = false
  trustedApplications: string[] = []
  blockedApplications: string[] = []
  constructor(
    tunIp: Address = new Address("172.19.0.1", 1),
    dnsAddresses: string[] = ["172.19.0.2"]
  ) {
    this.addresses = [
      new AddressWithPrefix(tunIp, 30)
    ];
    this.routes = [];
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
  let address = ip.split("/")[0].trim()
  return address.split(".").length == 4 && address.indexOf(":") == -1
}

export function isIpv6(ip: string): Boolean {
  let parts = ip.split("/")
  let address = parts[0].trim()
  return address.indexOf(":") >= 0
}

export function cidrToAddressWithPrefix(cidr: string): AddressWithPrefix | null {
  let parts = cidr.split("/")
  if (parts.length != 2) {
    return null
  }
  let address = parts[0].trim()
  let prefixLength = parseInt(parts[1])
  if (Number.isNaN(prefixLength)) {
    return null
  }
  if (isIpv4(cidr)) {
    return new AddressWithPrefix(new Address(address, 1), prefixLength)
  }
  if (isIpv6(cidr)) {
    return new AddressWithPrefix(new Address(address, 2), prefixLength)
  }
  return null
}

export function cidrToRoute(cidr: string): RouteInfo | null {
  let destination = cidrToAddressWithPrefix(cidr)
  if (destination == null) {
    return null
  }
  let family = destination.address.family
  let gateway = family == 2 ? "fe80::" : "172.19.0.1"
  return {
    "interface": "vpn-tun",
    destination: destination,
    gateway: new Address(gateway, family),
    hasGateway: false,
    isDefaultRoute: cidr == "0.0.0.0/0" || cidr == "::/0",
  }
}

