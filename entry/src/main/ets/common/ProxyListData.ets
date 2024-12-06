
//代理列表数据类
export class ProxyData {

  flag: Resource
  name: string
  passage: string
  latency: number
  isCheck: boolean

  constructor( flag: Resource, name: string, passage: string, latency: number,  isCheck:boolean) {
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
    new ProxyData($r('sys.symbol.gearshape'), '越南①', 'Vmess', 20, false),
    new ProxyData($r('sys.symbol.gearshape'), '越南②', 'Shadowsocks', 500, false),
    new ProxyData($r('sys.symbol.gearshape'), '北朝鲜①', 'Vmess', 501, false),
    new ProxyData($r('sys.symbol.gearshape'), '北朝鲜②', 'Shadowsocks', 1001, false),
  ]
  return result
}