
//代理列表数据类
export class ProxyData {

  flag: Resource
  name: string
  passage: string
  latency: ResourceStr
  isCheck: boolean

  constructor( flag: Resource, name: string, passage: string, latency: ResourceStr,  isCheck:boolean) {
    this.flag = flag
    this.passage = passage
    this.name = name
    this.latency = latency
    this.isCheck = isCheck
  }
}

//临时数据
export  const createGroup1Data = (): ProxyData[] => {
  let result: ProxyData[] = new Array()
  result = [
    new ProxyData($r('sys.symbol.gearshape'), '越南①', 'Vmess', '20ms', false),
    new ProxyData($r('sys.symbol.gearshape'), '越南②', 'Shadowsocks', '500ms', false),
    new ProxyData($r('sys.symbol.gearshape'), '北朝鲜①', 'Vmess', '501ms', false),
    new ProxyData($r('sys.symbol.gearshape'), '北朝鲜②', 'Shadowsocks', '1001ms', false),
  ]
  return result
}