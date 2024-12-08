
export class moreData {
  icons: Resource;
  name?: string;
  title: string | Resource;
  isCheck: boolean

  constructor( icons: Resource, name: string, title: ResourceStr, isCheck:boolean) {
    this.icons = icons
    this.name = name
    this.title = title
    this.isCheck = isCheck
  }
}

//MoreListItem
export  const ListMoreData = (): moreData[] => {
  let result: moreData[] = new Array()
  result = [
    new moreData($r('sys.symbol.doc_text_fill'), 'Log', $r('app.string.Log'),  false),
    new moreData($r('sys.symbol.externaldrive_fill_3'), 'Resources', $r('app.string.Resources'), false),
    new moreData($r('sys.symbol.list_bullet'), 'Request', $r('app.string.Request'), false),
    new moreData($r('sys.symbol.swap'), 'Connect', $r('app.string.Connect'), false),
    new moreData($r('sys.symbol.pencil_line'), 'Overwrite', $r('app.string.Overwrite'), false),
    //new moreData($r('sys.symbol.gearshape'), 'Settings', $r('app.string.Settings'), false),
  ]
  return result
}

// 主页 -> 代理启动按钮内计时器的初始值
export const PROXY_STARTED_DURATION_INIT_VALUE: string = '00:00:00'

// 组件animation duration值: 300
export const ANIMATION_DURATION_300: number = 300