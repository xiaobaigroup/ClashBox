
// 定义一个接口来描述列表项的数据结构
export interface Item {
  text: string
  latency: number
  type: string
  id: number
  isShowFavoriteProxy: boolean
}

// todo 节点假数据组后期可改可删
export class ProxyData {
  private static items: Item[] = [
  // ...你的items数据...
    {
      text: '越南①',
      latency: 20,
      type: 'Vmess',
      id: 1,
      isShowFavoriteProxy:false
    },
    {
      text: '越南②',
      latency: 500,
      type: 'Shadowsocks',
      id: 2,
      isShowFavoriteProxy:false
    },
    {
      text: '北朝鲜①',
      latency: 501,
      type: 'Vmess',
      id: 3,
      isShowFavoriteProxy:false
    },
    {
      text: '中国香港①',
      latency: 20,
      type: 'Trojan',
      id: 4,
      isShowFavoriteProxy:false
    },
    {
      text: '中国香港②',
      latency: 1001,
      type: 'Vmess',
      id: 5,
      isShowFavoriteProxy:false
    },
    {
      text: '中国台湾①',
      latency: 501,
      type: 'Shadowsocks',
      id: 6,
      isShowFavoriteProxy:false
    },
    {
      text: '中国台湾②',
      latency: 20,
      type: 'Vmess',
      id: 7,
      isShowFavoriteProxy:false
    },
    {
      text: '越南②',
      latency: 500,
      type: 'Trojan',
      id: 8,
      isShowFavoriteProxy:false
    },
    {
      text: '美国①',
      latency: 1001,
      type: 'Shadowsocks',
      id: 9,
      isShowFavoriteProxy:false
    },
    {
      text: '美国②',
      latency: 102,
      type: 'Shadowsocks',
      id: 10,
      isShowFavoriteProxy:false
    },
  ]

//延迟颜色设定
  public static ProxyItems(): Item[] {
    return ProxyData.items;
  }

  public static getColorForLatency(latency: number): string | ResourceColor {
    if (latency >= 0 && latency <= 500) {
      return '#64BB5C'; // 绿色，表示低延迟
    }

    if (latency > 500 && latency <= 1000) {
      return '#f7ce00'; // 黄色，表示中等延迟
    }

    if (latency > 1000) {
      return '#e84026'; // 红色，表示高延迟
    }

    // 默认情况下，返回系统定义的次要字体颜色，适用于无效或未知的延迟值
    return $r('sys.color.font_secondary');
  }


  // 使用鸿蒙系统提供的响应式机制
  private static selectedItems: Item[] = [];

  // 如果鸿蒙系统提供了类似Vue的computed属性，可以这样做
  public static get getSelectedTexts(): string {
    return ProxyData.selectedItems.map(item => item.text).join(', ');
  }

  // 方法用于添加选中的项
  public static selectItem(item: Item): void {
    if (ProxyData.selectedItems.length < 3 && !ProxyData.selectedItems.some(selected => selected.id === item.id)) {
      ProxyData.selectedItems.push(item);
    }
  }

  // 清空选中的项
  public static clearSelection(): void {
    ProxyData.selectedItems.splice(0, ProxyData.selectedItems.length);
  }
}



