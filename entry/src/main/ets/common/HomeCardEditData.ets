export interface IsShowHomeCard {
  isShowSpeed? :boolean,
  isShowSwitchMode? :boolean,
  isShowCellularData? :boolean,
  isShowCurrentNode? :boolean,
  isShowPublicNetwork? :boolean,
  isShowFavoriteProxy? :boolean,
  isShowFavoriteConfiguration? :boolean,
  isShowProxyINFO? :boolean,
  isShowCurrentConfiguration? :boolean,
  isShowShortcuts? :boolean,
}

export class  isShowHomeCardConfig {
  isShowSpeed? :boolean=true
  isShowSwitchMode? :boolean=true
  isShowCellularData? :boolean=true
  isShowCurrentNode? :boolean=true
  isShowPublicNetwork? :boolean=true
  isShowFavoriteProxy? :boolean=true
  isShowFavoriteConfiguration? :boolean=true
  isShowProxyINFO? :boolean=false
  isShowCurrentConfiguration? :boolean=false
  isShowShortcuts? :boolean=false
  constructor() {
  }
}



