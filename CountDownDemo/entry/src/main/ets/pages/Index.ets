import { CountdownTimer, Timer, TimerState } from 'lib_timer/src/main/ets/utils/countdowntimer';
import { promptAction } from '@kit.ArkUI'; // API 9+ 推荐写法

@Entry
@Component
struct Index {
  // 1. 定义状态变量，UI 会根据这两个变量的变化自动刷新

  // 2. 实例化 Timer
  private timer: CountdownTimer = new CountdownTimer();

  @State displayCount: number = this.timer.countDown();
  @State timerStatus: string = this.getStateTips(this.timer.state);


  aboutToAppear() {
    // 3. 注册回调：将 Timer 的内部数据同步到页面的 @State 变量中
    this.timer.registerChange((count: number, state: TimerState) => {
      this.displayCount = count;

      this.timerStatus = this.getStateTips(state)

      console.info(`CountDownDemo#状态: ${this.timerStatus} 倒计时:${this.displayCount}`)

      if(state === TimerState.Stoped){
        console.info("CountDownDemo#倒计时结束！")
        this.showToast("倒计时结束！")
      }
    });
  }

  getStateTips(state:TimerState):string{
		switch (state) {
      case TimerState.Running:
        return  '运行中';
        break;
      case TimerState.Paused:
        return  '已暂停';
        break;
      case TimerState.Idle:
        return  '待机';
        break;
      case TimerState.Stoped:
        return  '已停止';
        break;
    };
	}

  aboutToDisappear(): void {
    this.timer.unregisterChange()
  }

  showToast(text:string):void{
    // 1. 获取当前 UI 上下文
    const uiContext = this.getUIContext();

    // 2. 获取 PromptAction 对象
    const prompt = uiContext.getPromptAction();

    // 3. 执行弹出
    try {
      prompt.showToast({
        message: text,
        duration: 2000,
        bottom: 60 // 也可以是 string 形式如 '60vp'
      });
    } catch (error) {
      console.error(`CountDownDemo#ErrorCode: ${error.code}, Message: ${error.message}`);
    }
  }

  build() {
    RelativeContainer() {
        Column(){
          Row({ space: 10 }){
            Button("开启Timer")
              .id('StartTimer')
              .fontSize('24fp')
              .fontWeight(FontWeight.Bold)
              .alignRules({
                center: { anchor: '__container__', align: VerticalAlign.Center },
                middle: { anchor: '__container__', align: HorizontalAlign.Center }
              })
              .onClick(() => {
                this.timer.start(10,0)
              });
            Button("关闭Timer")
              .id('CloseTimer')
              .fontSize('24fp')
              .fontWeight(FontWeight.Bold)
              .alignRules({
                center: { anchor: '__container__', align: VerticalAlign.Center },
                middle: { anchor: '__container__', align: HorizontalAlign.Center }
              })
              .onClick(() => {
                this.timer.stop()
              })
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceEvenly)
          .margin({ top: 20 })

          Row({ space: 10 }){
            Button("暂停Timer")
              .id('CloseTimer')
              .fontSize('24fp')
              .fontWeight(FontWeight.Bold)
              .alignRules({
                center: { anchor: '__container__', align: VerticalAlign.Center },
                middle: { anchor: '__container__', align: HorizontalAlign.Center }
              })
              .onClick(() => {
                this.timer.pause()
              })
            Button("恢复Timer")
              .id('ResumeTimer')
              .fontSize('24fp')
              .fontWeight(FontWeight.Bold)
              .alignRules({
                center: { anchor: '__container__', align: VerticalAlign.Center },
                middle: { anchor: '__container__', align: HorizontalAlign.Center }
              })
              .onClick(() => {
                this.timer.resume()
              })
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.SpaceEvenly)
          .margin({ top: 20 })

          Stack() {
            Text(`状态: ${this.timerStatus} 倒计时:${this.displayCount}`)
          }
          .width('100%')
          .layoutWeight(1) // 核心代码：分配剩余空间的所有权重
          .backgroundColor(Color.Orange)
        }
        .height('100%')
        .width('100%')
    }
    .height('100%')
    .width('100%')
  }
}