## CountDownTimer

下载[Timer依赖](../libs/lib_timer.har)使用CountDownTimer

```ets
const timer:Timer = new CountDownTime()
timer.start(10,0)
timer.pause()
timer.resume()
timer.stop()
timer.countdown()
timer.registerChange((count: number, state: TimerState) => {})
timer.unregisterChange()
```