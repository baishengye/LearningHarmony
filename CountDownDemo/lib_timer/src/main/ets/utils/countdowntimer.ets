
export enum TimerState{
  Idle = 0x01,
  Running = 0x02,
  Paused = 0x03,
  Stoped = 0x04
}


export interface Timer{
  /**
   * 启动值*/
  _from:number
  /**
   * 目标值*/
  _to:number
  /**
   * 当前状态*/
  _state:TimerState
  /**
   * 状态和值变化时的回调*/
  _change?:((count:number,state:TimerState)=>void) | null

  /**
   * 获取当前值*/
  countDown():number
  /**
   * @returns 是否开启成功
   * 开启任务*/
  start(from:number,to:number):boolean
  /**
   * 暂停*/
  pause():void
  /**
   * 恢复*/
  resume():void
  /**
   * 停止*/
  stop():void
  /**
   * 注册回调*/
  registerChange(callback:((count:number,state:TimerState)=>void)):void
  /**
   * 解注册*/
  unregisterChange():void
}

export class CountdownTimer implements Timer{
  _state: TimerState = TimerState.Idle

  _change?: ((count: number, state: TimerState) => void) | null
  _from: number = 10
  _to: number = 0

  // 信号量控制
  private pauseResolve?: (() => void) | null;
  private isStopRequested: boolean = false;

  private set from(value:number){
    this._from = value
  }
  get from():number{
    return this._from
  }

  set state(value:TimerState){
    this._state = value
  }
  get state():TimerState{
    return this._state
  }

  countDown(): number {
    return this.from
  }

  registerChange(callback: (count: number, state: TimerState) => void): void {
    this._change = callback
  }

  unregisterChange(): void {
    this._change = null
  }

  start(newFrom: number = 10, newTo: number = 0): boolean {
    if(this.state !== TimerState.Idle){
      console.info("timer已经开启，请先调用stop")
      return false
    }
    if(newFrom <= newTo){
      console.info("请确保开始值比结束值要大")
      return false
    }
    this.state = TimerState.Idle
    this.from = newFrom
    if(this._change != null){
      this._change(this.from,this._state)
    }
    this.isStopRequested = false;

    this.runLoop(newTo)
    return true
  }

  async runLoop(target:number): Promise<void>{
    this.state = TimerState.Running
    while (this._from >= target) {
      // 中断检查
      if (this.isStopRequested){
        this.state = TimerState.Stoped
        if(this._change != null){
          this._change(this.from,this._state)
        }
        break
      }

      // 暂停检查 (信号量模式)
      if (this._state === TimerState.Paused) {
        await new Promise<void>(resolve => {
          this.pauseResolve = resolve;
        });
      }
      // 中断检查
      if (this.isStopRequested){
        this.state = TimerState.Stoped
        if(this._change != null){
          this._change(this.from,this._state)
        }
        break
      }

      if (this._from === target) break;

      // 真正的异步等待
      await new Promise<void>((resolve) => {
        setTimeout(resolve, 1000);
      });
      this.from--;
      if(this._change != null){
        this._change(this.from,this._state)
      }
    }

    // 任务结束清理
    this.state = TimerState.Idle;
    this.from = 0

    if(this._change != null){
      this._change(this.from,this._state)
    }
  }

  pause(): void {
    if(this.state == TimerState.Running){
      this.state = TimerState.Paused

      if(this._change != null){
        this._change(this.from,this._state)
      }
    }else {
      console.info("请确保Timer已经处于Running再stop")
    }
  }

  resume(): void {
    // 1. 只有在暂停状态下才需要恢复
    if (this._state === TimerState.Paused) {
      this.state = TimerState.Running;

      if(this._change != null){
        this._change(this.from,this._state)
      }

      // 2. 检查是否有存下的“钥匙” (resolve 函数)
      if (this.pauseResolve != null) {
        this.pauseResolve(); // 这一步会让 runLoop 里的 await 结束
        this.pauseResolve = null; // 【重要】用完即置空，防止逻辑污染或重复执行
      }
    }else {
      console.info("请确保Timer已经处于Paused再Resume")
    }
  }

  stop(): void {
    if(this._state == TimerState.Running || this._state == TimerState.Paused){
      this.isStopRequested = true

      // 2. 检查是否有存下的“钥匙” (resolve 函数)
      if (this.pauseResolve != null) {
        this.pauseResolve(); // 这一步会让 runLoop 里的 await 结束
        this.pauseResolve = null; // 【重要】用完即置空，防止逻辑污染或重复执行
      }
    }else {
      console.info("请确保Timer已经处于Running或者Paused再Resume")
    }
  }
}