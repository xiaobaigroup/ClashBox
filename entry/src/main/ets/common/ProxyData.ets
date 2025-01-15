
// 定义一个接口来描述列表项的数据结构
export interface Item {
  text: string
  latency: number
  type: string
  id: string
  isShowFavoriteProxy: boolean
}

// todo 节点假数据组后期可改可删
export class ProxyData {
  private static items: Item[] = [
  // ...你的items数据...
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
}



