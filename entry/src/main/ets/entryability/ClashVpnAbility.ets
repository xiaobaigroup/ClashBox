import {  VpnExtensionAbility } from '@kit.NetworkKit';
import { Want } from '@kit.AbilityKit';
import { SocketStubService } from 'proxy_core';


export default class ClashVpnAbility extends VpnExtensionAbility {
  clashStubService = new SocketStubService()
  constructor() {
    super();
  }
  async onCreate(want: Want) {
    try {
      await this.clashStubService.startService(this.context)
    } catch (e) {
      console.log("ClashNext", `启用VPN失败 ${e.message} ${e.stack}`);
    }
  }
  onDestroy(){
    console.log("ClashNext", `后台vpn服务(ClashVpnAbility) 退出`);
    this.clashStubService?.stopVpn();
  }
};




