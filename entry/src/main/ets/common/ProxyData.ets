import { ProxyGroup } from "proxy_core"

// 定义一个接口来描述列表项的数据结构
export interface ProxyItem {
  readonly name: string
  latency: number
  type: string
  id?: string
  g?: string
  isShowFavoriteProxy?: boolean
}

// 节点假数据组
export class ProxyData {
  private static items: ProxyItem[] = [
  // ...你的items数据...
  ]

//延迟颜色设定
  public static ProxyItems(): ProxyItem[] {
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


//懒加载节点分组使用class
export class proxyGroupsLazyData implements IDataSource  {
  public list: ProxyGroup[] = []

  constructor(list: ProxyGroup[]) {
    this.list = list
  }

  totalCount(): number {
    return this.list.length
  }

  getData(index: number): ProxyGroup {
    return this.list[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
  }

  unregisterDataChangeListener() {
  }
}

//懒加载节点使用class
export class proxyListLazyData implements IDataSource  {
  public list: ProxyItem[] = []

  constructor(list: ProxyItem[]) {
    this.list = list
  }

  totalCount(): number {
    return this.list.length
  }

  getData(index: number): ProxyItem {
    return this.list[index]
  }

  registerDataChangeListener(listener: DataChangeListener): void {
  }

  unregisterDataChangeListener() {
  }
}