import { ProxyGroup } from "proxy_core"
import { BaseDataSource } from "./BaseDataSource"
import { intl } from "@kit.LocalizationKit"

// 定义一个接口来描述列表项的数据结构
export interface ProxyItem {
  readonly name: string
  latency: number
  type: string
  id?: string
  g?: string
  isShowFavoriteProxy?: boolean
}

@Observed
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

/**
 * 代理页分组数据源
 */
@Observed
export class ProxyGroupItemDataSource extends BaseDataSource<ProxyGroup> {
  private dataArray: ProxyGroup[] = []

  public totalCount(): number {
    return this.dataArray.length
  }

  public getData(index: number): ProxyGroup {
    return this.dataArray[index]
  }

  public addData(index: number, data: ProxyGroup): void {
    this.dataArray.splice(index, 0, data)
    this.notifyDataAdd(index)
  }

  public pushData(data: ProxyGroup[]): void {
    this.dataArray = data
    this.notifyDataAdd(this.dataArray.length - 1)
  }

  //删除全部数据
  public clear(): void {
    this.empty()
    this.refresh()
  }

  public empty(): void {
    this.dataArray = []
  }
  public refresh(): void {
    this.notifyDataReload()
  }
}

/**
 * 代理页节点数据源
 */
@Observed
export class ProxyItemDataSource extends BaseDataSource<ProxyItem> {
  private dataArray: ProxyItem[] = []

  public totalCount(): number {
    return this.dataArray.length
  }

  public getData(index: number): ProxyItem {
    return this.dataArray[index]
  }

  public addData(index: number, data: ProxyItem): void {
    this.dataArray.splice(index, 0, data)
    this.notifyDataAdd(index)
  }

  public pushData(data: ProxyItem[]): void {
    this.dataArray = data
    this.notifyDataAdd(this.dataArray.length - 1)
  }
  //删除全部数据
  public clear(): void {
    this.empty()
    this.refresh()
  }

  public empty(): void {
    this.dataArray = []
  }
  public refresh(): void {
    this.notifyDataReload()
  }

  // 延迟排序
  public async LatencySortItems(data:ProxyItem[]) {
    data.sort((a, b) => (a.latency ?? 0) - (b.latency ?? 0));
    this.dataArray = data;
    this.pushData(data)
  }

  //按名称排序
  public async NameSortItems(data:ProxyItem[]) {
    data.sort((a, b) => ProxyCollator.compare(a.name, b.name));
    this.dataArray = data;
    this.pushData(data)
  }

  //默认排序
  public async DefaultSortItems(data:ProxyItem[]) {
    data.sort((a, b) => ProxyCollator.compare(a.id, b.id));
    this.dataArray = data
    this.pushData(data)
  }
}

//中文排序
let ProxyCollator = new intl.Collator("zh-CN");

