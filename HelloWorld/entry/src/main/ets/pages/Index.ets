@Entry
@Component
struct Index {
  @State message: string = '你好世界';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message = '欢迎';
        })
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#123456')
  }
}