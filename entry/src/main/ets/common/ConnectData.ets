import { ConnectionInfo } from "proxy_core"
import { universalSearch } from "../utils/SmartSearchUtil"
import { BaseDataSource } from "./BaseDataSource"

/**
 * 连接数据源
 */
@Observed
export class ConnectItemDataSource extends BaseDataSource<ConnectionInfo> {
  private dataArray: ConnectionInfo[] = []
  private lastDataArray: ConnectionInfo[] = []

  public totalCount(): number {
    return this.dataArray.length
  }

  public getData(index: number): ConnectionInfo {
    return this.dataArray[index]
  }

  public getTotslData(): ConnectionInfo[] {
    return this.dataArray
  }

  public addData(index: number, data: ConnectionInfo): void {
    this.dataArray.splice(index, 0, data)
    this.notifyDataAdd(index)
  }

  public pushData(data: ConnectionInfo[]): void {
    this.dataArray = data
    // 缓存数组
    this.lastDataArray = this.dataArray
    this.notifyDataAdd(this.dataArray.length - 1)
  }

  public searchData(keyword: string) {
    this.dataArray = universalSearch(this.dataArray, keyword, {
      fields: [
        'metadata.network',
        'metadata.host',
        'metadata.destinationIP',
      ],
      matchMode: 'all'
    })
  }

  public restoreData() {
    this.dataArray = this.lastDataArray
  }

  // 删除全部数据
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