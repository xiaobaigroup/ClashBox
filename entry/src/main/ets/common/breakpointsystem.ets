// 对通过媒体查询监听断点的功能的简单封装
import { mediaquery } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'

export type BreakpointType = 'xs' | 'sm' | 'md' | 'lg' | 'xl' | 'xxl'

export interface Breakpoint {
  name: BreakpointType
  size: number
  mediaQueryListener?: mediaquery.MediaQueryListener
}

export class BreakpointSystem {
  private static instance: BreakpointSystem
  private readonly breakpoints: Breakpoint[] = [
    { name: 'xs', size: 0 },
    { name: 'sm', size: 310 },
    { name: 'md', size: 600 },
    { name: 'lg', size: 840 },
    { name: 'xl', size: 1000 },
    { name: 'xxl', size: 1600 }
  ]
  private states: Set<BreakpointState<Object>>

  private constructor() {
    this.states = new Set()
  }

  public static getInstance(): BreakpointSystem {
    if (!BreakpointSystem.instance) {
      BreakpointSystem.instance = new BreakpointSystem();
    }
    return BreakpointSystem.instance
  }

  public attach(state: BreakpointState<Object>): void {
    this.states.add(state)
  }

  public detach(state: BreakpointState<Object>): void {
    this.states.delete(state)
  }

  public start() {

    this.breakpoints.forEach((breakpoint: Breakpoint, index) => {
      let condition: string
      if (index === this.breakpoints.length - 1) {
        condition = `(${breakpoint.size}vp<=width)`
      } else {
        condition = `(${breakpoint.size}vp<=width<${this.breakpoints[index + 1].size}vp)`
      }
      breakpoint.mediaQueryListener = mediaquery.matchMediaSync(condition)
      if (breakpoint.mediaQueryListener.matches) {
        hilog.info(0x1000, 'breakpointsystem', `#媒体查询#初始断点改变#${condition}#current Breakpoint.name: [${breakpoint.name}]`)
        this.updateAllState(breakpoint.name)
      }
      breakpoint.mediaQueryListener.on('change', (mediaQueryResult) => {
        if (mediaQueryResult.matches) {
          this.updateAllState(breakpoint.name)
          hilog.info(0x1000, 'breakpointsystem', `#媒体查询#断点改变#${condition}#current Breakpoint.name: [${breakpoint.name}]`)
        }
      })
    })
  }

  private updateAllState(type: BreakpointType): void {
    this.states.forEach(state => state.update(type))
  }

  public stop() {
    this.breakpoints.forEach((breakpoint: Breakpoint, index) => {
      if (breakpoint.mediaQueryListener) {
        breakpoint.mediaQueryListener.off('change')
      }
    })
    this.states.clear()
  }
}

export interface BreakpointOptions<T> {
  xs?: T
  sm: T
  md: T
  lg: T
  xl: T
  xxl?: T
}

export class BreakpointState<T extends Object> {
  public value: T | undefined = undefined;
  private options: BreakpointOptions<T>

  constructor(options: BreakpointOptions<T>) {
    this.options = options
  }

  static of<T extends Object>(options: BreakpointOptions<T>): BreakpointState<T> {
    return new BreakpointState(options)
  }

  public update(type: BreakpointType): void {
    if (type === 'xs') {
      this.value = this.options.xs
    } else if (type === 'sm') {
      this.value = this.options.sm
    } else if (type === 'md') {
      this.value = this.options.md
    } else if (type === 'lg') {
      this.value = this.options.lg
    } else if (type === 'xl') {
      this.value = this.options.xl
    } else if (type === 'xxl') {
      if (this.options?.xxl === undefined){
        this.value = this.options.xl
      } else {
        this.value = this.options.xxl
      }
    } else {
      this.value = this.options.xl
      hilog.info(0x1000, 'breakpointsystem', `#update(): 当前系统断点[${type}]没有匹配到对应的断点数据，默认使用xl断点数据`)
    }
  }
}