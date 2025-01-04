
// 定义一个接口来描述列表项的数据结构
export interface Item {
  text: string
  latency: number
  type: string
  index: number
}


// todo 节点假数据组后期可改可删
export class ProxyData {
  private static items: Item[] = [
  // ...你的items数据...
    {
      text: '越南①',
      latency: 20,
      type: 'Vmess',
      index: 1,
    },
    {
      text: '越南②',
      latency: 500,
      type: 'Shadowsocks',
      index: 2
    },
    {
      text: '北朝鲜①',
      latency: 501,
      type: 'Vmess',
      index: 3
    },
    {
      text: '中国香港①',
      latency: 20,
      type: 'Trojan',
      index: 4
    },
    {
      text: '中国香港②',
      latency: 1001,
      type: 'Vmess',
      index: 5
    },
    {
      text: '中国台湾①',
      latency: 501,
      type: 'Shadowsocks',
      index: 6
    },
    {
      text: '中国台湾②',
      latency: 20,
      type: 'Vmess',
      index: 7
    },
    {
      text: '越南②',
      latency: 500,
      type: 'Trojan',
      index: 8
    },
    {
      text: '美国①',
      latency: 1001,
      type: 'Shadowsocks',
      index: 9
    },
    {
      text: '美国②',
      latency: 102,
      type: 'Shadowsocks',
      index: 10
    },
  ]

  public static ProxyItems(): Item[] {
    return ProxyData.items;
  }
}

