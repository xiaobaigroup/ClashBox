/* 贡献者list详情 */
import { RightStyle, SettingsItem } from "./SettingsCommonOp";
import { Xb_GoToWeb } from "../utils/JumpTo";

//注意，数组中写的变量无法变化，只能从外面组件处写变量
@ObservedV2
class ContributorList{
  @Trace contributorList1: Array<SettingsItem> = [
    { id: 'xb',
      icon: $rawfile('xiaobai.jpg'),
      contentL: '小白', contentSecL: $r("app.string.xb_developer"), contentR: 'Github', rightStyle: RightStyle.BUTTON,
      onClick: () => {
        Xb_GoToWeb('https://github.com/likuai2010')
      }},
    { id: 'ya',
      icon: $rawfile('ya.jfif'),
      contentL: '小雅', contentSecL: $r("app.string.xb_developer"), contentR: 'Github', rightStyle: RightStyle.BUTTON,
      onClick: () => {
        Xb_GoToWeb('https://github.com/XHXYT')
      }},
    { id: 'luyuan',
      icon: $rawfile('crazypig321.png'),
      contentL: 'crazypig321', contentSecL: $r("app.string.xb_developer"), contentR: 'Github', rightStyle: RightStyle.BUTTON,
      onClick: () => {
        Xb_GoToWeb('https://github.com/crazypig321')
      }},
    { id: 'chuanz',
      icon: $rawfile('chuanzhang.png'),
      contentL: '船长', contentSecL: $r("app.string.xb_planner"), contentR: 'Github', rightStyle: RightStyle.BUTTON,
      onClick: () => {
        Xb_GoToWeb('https://github.com/xfz347/')
      }},
    { id: 'kl',
      icon: $rawfile('kl.png'),
      contentL: '科蓝', contentSecL: $r("app.string.xb_designer"), contentR: 'Github', rightStyle: RightStyle.BUTTON,
      onClick: () => {
        Xb_GoToWeb('https://github.com/kelanKL')
      }},
  ]
  @Trace contributorList2: Array<SettingsItem> = [
    { id: 'hmtool',
      icon: $rawfile('HomoToolkit.svg'),
      contentL: 'HomoToolkit', contentSecL: '', contentR: 'Github', rightStyle: RightStyle.BUTTON,
      onClick: () => {

      }},
    { id: 'clashbox',
      icon: $rawfile('ClashBox.png'),
      contentL: 'ClashBox', contentSecL: '', contentR: '应用市场', rightStyle: RightStyle.BUTTON,
      onClick: () => {
        Xb_GoToWeb('https://appgallery.huawei.com/app/detail?id=org.xbgroup.clashbox&channelId=SHARE')
      }},
    { id: 'gitstore',
      icon: $rawfile('GitStore.png'),
      contentL: 'GitStore', contentSecL: '', contentR: '应用市场', rightStyle: RightStyle.BUTTON,
      onClick: () => {
        Xb_GoToWeb('https://appgallery.huawei.com/app/detail?id=org.xbstudio.gitstorebox&channelId=SHARE')
      }},
    { id: 'moonlight',
      icon: $rawfile('Moonlight.png'),
      contentL: 'Moonlight', contentSecL: '', contentR: '应用市场', rightStyle: RightStyle.BUTTON,
      onClick: () => {
        Xb_GoToWeb('https://appgallery.huawei.com/app/detail?id=com.xiaobai.moonlight&channelId=SHARE')
      }},
    { id: 'zerotierbox',
      icon: $rawfile('ZeroTierBox.png'),
      contentL: 'ZeroTierBox', contentSecL: '', contentR: '应用市场', rightStyle: RightStyle.BUTTON,
      onClick: () => {
        Xb_GoToWeb('https://appgallery.huawei.com/app/detail?id=org.xbstudio.zerotierbox&channelId=SHARE')
      }},
    { id: 'openvpn',
      icon: $rawfile('OpenVPN_Box.png'),
      contentL: 'OpenVPN Box', contentSecL: '', contentR: '应用市场', rightStyle: RightStyle.BUTTON,
      onClick: () => {
        Xb_GoToWeb('https://appgallery.huawei.com/app/detail?id=org.xbstudio.openvpn&channelId=SHARE&source=appshare')
      }},
    { id: 'homl',
      icon: $rawfile('HOML.png'),
      contentL: 'HomoLauncher', contentSecL: '', contentR: 'Github', rightStyle: RightStyle.BUTTON,
      onClick: () => {
        Xb_GoToWeb('https://github.com/xiaobaigroup/HOML')
      }},
  ]

  @Trace contributorList3: Array<SettingsItem> = [
  /*  { id: 'sponsors',
      icon: $rawfile('group.jpg'),
      contentL: '赞助者们', contentSecL: '感谢您的支持', contentR: '赞助者名单', rightStyle: RightStyle.BUTTON,
      onClick: () => {

      }},*/
    { id: 'sponsor',
      icon: $r("sys.symbol.hand_thumbsup_fill"),
      contentL: $r("app.string.xb_sponsor"), contentSecL: '', rightStyle: RightStyle.JUMP,
      onClick: () => {
        Xb_GoToWeb('https://afdian.com/a/xiaobaigroup')
      }},
    { id: 'group1',
      icon: $r("sys.symbol.message_on_message_fill"),
      contentL: $r("app.string.xb_contact1"), contentSecL: '', rightStyle: RightStyle.JUMP,
      onClick: () => {
        Xb_GoToWeb('mqqapi://card/show_pslcard?src_type=internal&version=1&uin=693903194&card_type=group&source=qrcode')
      }},
    { id: 'group2',
      icon: $r("sys.symbol.message_on_message_fill"),
      contentL: $r("app.string.xb_contact2"), contentSecL: '', rightStyle: RightStyle.JUMP,
      onClick: () => {
        Xb_GoToWeb('mqqapi://card/show_pslcard?src_type=internal&version=1&uin=2160023660&card_type=group&source=qrcode')
      }},
  ]


}

export const contributorList: ContributorList = new ContributorList()


