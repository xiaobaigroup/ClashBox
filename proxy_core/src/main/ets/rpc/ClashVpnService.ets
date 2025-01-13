import { vpnExtension } from '@kit.NetworkKit';
import { common, Context } from '@kit.AbilityKit';
import {
  startTun, stopTun, setFdMap, getVpnOptions
} from 'libflclash.so';

class Address {
  address: string;
  family: number;
  constructor(address: string, family: number) {
    this.address = address;
    this.family = family;
  }
}
class AddressWithPrefix {
  address: Address;
  prefixLength: number;
  constructor(address: Address, prefixLength: number) {
    this.address = address;
    this.prefixLength = prefixLength;
  }
}
class Config {
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
interface AccessControl{
  mode:              string
  acceptList:        string[]
  rejectList:        string[]
  isFilterSystemApp: boolean
}
interface VpnOptions{
  enable: boolean,
  port: number,
  ipv4Address: string,
  ipv6Address: string,
  accessControl: AccessControl,
  systemProxy: string,
  allowBypass: boolean,
  routeAddress: string[],
  bypassDomain: string[],
  dnsServerAddress: string,
}

export class ClashVpnService{
  noVpn: boolean = false // 模拟器开启
  running: boolean = false
  vpnConnection : vpnExtension.VpnConnection | undefined
  public configPath: string = ""
  protectSocketPath: string = ""
  context?: Context
  constructor() {

  }
  init(context: Context){
    this.context = context;
  }
  ParseConfig(): Config {
    let vpnConfig = new Config();
    let option = JSON.parse(getVpnOptions()) as VpnOptions
    console.debug("ParseConfig", JSON.stringify(option))
    if (option.ipv4Address != "") {
      vpnConfig.addresses[0].address = new Address(option.ipv4Address.split("/")[0], 1)
      option.routeAddress?.filter(a => isIpv4(a)).map(f=>f.split("/")[0])
    }
    if (option.ipv6Address != ""){
      vpnConfig.addresses[0].address = new Address(option.ipv6Address.split("/")[0], 2)
      option.routeAddress?.filter(a => isIpv6(a)).map(f=>f.split("/")[0])
    }
    let packageName = ""
    if(option.accessControl?.mode){
      if(option.accessControl?.mode == "AcceptSelected"){
        vpnConfig.trustedApplications = option.accessControl?.acceptList
      }else{
        vpnConfig.blockedApplications = option.accessControl?.rejectList
      }
    }
    if(option.systemProxy || option.allowBypass){
      // TODO ohos 不支持
      // not use option.bypassDomain option.port
    }
    console.debug("vpnConfig", JSON.stringify(vpnConfig))
    return vpnConfig;
  }
  async StartVpn(): Promise<boolean> {
    let config = this.ParseConfig();
    let tunFd = -1
    try {
      this.vpnConnection = vpnExtension.createVpnConnection(this.context as common.VpnExtensionContext);
      tunFd = await this.vpnConnection.create(config)
      console.log("ClashVPN", `获取tunFd: ${tunFd}`)
      startTun(tunFd, async (id: number, fd: number) => {
        await this.vpnConnection?.protect(fd)
        setFdMap(id)
      })
      return true;
    } catch (error) {
      console.log("ClashVPN", `Clash启动失败 ${error.message} => ${error.stack}` )
      this.vpnConnection?.destroy()
      return false
    }
  }
  stopVpn(){
    stopTun()
    this.vpnConnection?.destroy()
  }
}


function isIpv4(ip: string): Boolean {
  let parts = ip.split("/")
  if (parts.length != 2) {
    return false
  }
  // TODO
  return ip.length == 4
}

function isIpv6(ip: string): Boolean {
  let parts = ip.split("/")
  if (parts.length != 2) {
    return false
  }
  // TODO
  return ip.length == 16
}

