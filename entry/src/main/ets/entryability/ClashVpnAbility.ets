import {  VpnExtensionAbility } from '@kit.NetworkKit';
import { Want } from '@kit.AbilityKit';
import { SocketStubService } from 'proxy_core';
import { ClashCore } from './AppState';


export default class ClashVpnAbility extends VpnExtensionAbility {
  clashStubService: SocketStubService | undefined
  constructor() {
    super();
  }
  async onCreate(want: Want) {
    try {
      let core = want.parameters?.["ClashCore"] as ClashCore ?? ClashCore.FlClash
      if(core == ClashCore.FlClash){
        console.log("ClashNext", `启用核心 FlClash`);
        this.clashStubService = new SocketStubService( this.context)
        await this.clashStubService.startService()
        console.log("ClashNext", `启用核心 FlClash 成功`);
      }else{
        console.log("ClashNext", `前台模式`);
      }
    } catch (e) {
      console.log("ClashNext", `启用VPN失败 ${e.message} ${e.stack}`);
    }
  }
  onDestroy(){
    console.log("ClashNext", `后台vpn服务(ClashVpnAbility) 退出`);
    this.clashStubService?.stopVpn();
  }
};




