
export class BaseDataSource<T> implements IDataSource {
  private readonly listeners: DataChangeListener[] = [];
  protected dataset: T[];

  constructor(dataset?: T[]) {
    this.dataset = dataset ?? [];
  }

  public resetDataset(dataset: T[]) {
    this.dataset = dataset;
    this.notifyDataReload();
  }

  public updateDataAt(index: number, data: T) {
    if (index >= 0 && index < this.dataset.length) {
      this.dataset[index] = data;
      this.notifyDataChange(index);
    }
  }

  public getDataset() {
    return this.dataset;
  }

  public totalCount(): number {
    return this.dataset.length;
  }

  public getData(index: number): T {
    return this.dataset[index];
  }

  /**
   * 通知LazyForEach组件需要重载所有子组件
   */
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  /**
   * 通知LazyForEach组件需要在index对应索引处添加子组件
   * @param index
   */
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  /**
   * 通知LazyForEach组件在index对应索引处数据有变化，需要重建该子组件
   * @param index
   */
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  /**
   * 通知LazyForEach组件需要在index对应索引处删除该子组件
   * @param index
   */
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  /**
   * 通知LazyForEach组件将from索引和to索引处的子组件进行交换
   * @param from
   * @param to
   */
  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }

  //----------------------------------------------------------------------------------------------------
  // 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  // 该方法为框架侧调用，为对应的LazyForEach组件在数据源处去除listener监听
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }
}