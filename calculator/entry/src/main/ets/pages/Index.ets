import List from '@ohos.util.List'
import { ArrayList } from '@kit.ArkTS'
import { CalculatorEngine } from './CalculatorEngine';

// 颜色常量定义
const COLOR_FUNC = '#A5A5A5'; // 顶部功能键（AC, +/-, %）
const COLOR_OP = '#FF9F0A'; // 右侧运算符（/, *, -, +, =）
const COLOR_NUM = '#333333'; // 数字键

@Entry
@Component
struct Index {
  // 在 Index 组件内初始化
  @State buttonList: ArrayList<CalculatorButtonData> = new ArrayList<CalculatorButtonData>()
  @State calculatorText: string = ""
  @State resultText: string = ""

  aboutToAppear() {
    const data: CalculatorButtonData[] = [
      // 第一行
      new CalculatorButtonData(CalculatorButtonType.Delete, "⌫", "⌫", COLOR_FUNC, 'app.media.icon_delete',
        'app.media.icon_delete'),
      new CalculatorButtonData(CalculatorButtonType.Clear, "C", "AC", COLOR_FUNC),
      new CalculatorButtonData(CalculatorButtonType.Percent, "%", "%", COLOR_FUNC),
      new CalculatorButtonData(CalculatorButtonType.Divide, "÷", "÷", COLOR_OP),

      // 第二行
      new CalculatorButtonData(CalculatorButtonType.Seven, "7", "7", COLOR_NUM),
      new CalculatorButtonData(CalculatorButtonType.Eight, "8", "8", COLOR_NUM),
      new CalculatorButtonData(CalculatorButtonType.Nine, "9", "9", COLOR_NUM),
      new CalculatorButtonData(CalculatorButtonType.Multiply, "×", "×", COLOR_OP),

      // 第三行
      new CalculatorButtonData(CalculatorButtonType.Four, "4", "4", COLOR_NUM),
      new CalculatorButtonData(CalculatorButtonType.Five, "5", "5", COLOR_NUM),
      new CalculatorButtonData(CalculatorButtonType.Six, "6", "6", COLOR_NUM),
      new CalculatorButtonData(CalculatorButtonType.Subtract, "-", "-", COLOR_OP),

      // 第四行
      new CalculatorButtonData(CalculatorButtonType.One, "1", "1", COLOR_NUM),
      new CalculatorButtonData(CalculatorButtonType.Two, "2", "2", COLOR_NUM),
      new CalculatorButtonData(CalculatorButtonType.Three, "3", "3", COLOR_NUM),
      new CalculatorButtonData(CalculatorButtonType.Add, "+", "+", COLOR_OP),

      // 第五行
      new CalculatorButtonData(CalculatorButtonType.Sign, "±", "±", COLOR_NUM),
      new CalculatorButtonData(CalculatorButtonType.Zero, "0", "0", COLOR_NUM),
      new CalculatorButtonData(CalculatorButtonType.Decimal, ".", ".", COLOR_NUM),
      new CalculatorButtonData(CalculatorButtonType.Equals, "=", "=", COLOR_OP)
    ];

    data.forEach(item => this.buttonList.add(item));
  }

  build() {
    RelativeContainer() {
      Column() {
        Scroll() {
          Text( this.calculatorText) // 为空时显示0占位
            .fontSize(40)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .textAlign(TextAlign.End) // 文字右对齐
        }
        .width('100%')
        .height('20%')
        .scrollable(ScrollDirection.Horizontal) // 设置为水平滚动
        .scrollBar(BarState.Off)                // 隐藏滚动条让界面更整洁
        .edgeEffect(EdgeEffect.Spring)          // 添加回弹效果
        .backgroundColor('#1C1C1E')             // 深色背景符合计算器风格
        .align(Alignment.End).padding({
          left: '5fp',
          right: '5fp',
          top: '0fp', // 可选：添加上边距
          bottom: '0fp'  // 可选：添加下边距
        })

        // 第二部分 (20%)
        Text(this.resultText)
          .width('100%')
          .height('10%')
          .fontSize(24)
          .backgroundColor('#1C1C1E')             // 深色背景符合计算器风格
          .textAlign(TextAlign.End).padding({
          left: '5fp',
          right: '5fp',
          top: '0fp', // 可选：添加上边距
          bottom: '0fp'  // 可选：添加下边距
        })

        // 第三部分 (60%) - 网格布局
        Grid() {
          ForEach(this.buttonList.convertToArray(), (item: CalculatorButtonData) => {
            GridItem() {
              // 使用你定义的自定义组件
              CalculatorButton({
                buttonData: item,
                calculatorText: this.calculatorText,
                resultText: this.resultText,
                // 4. 接收子组件传回来的数据
                onButtonClick: (data: CalculatorButtonData) => {
                  this.handleCalculatorInput(data);
                }
              })
            }
          }, (item: CalculatorButtonData) => item.type.toString())
        }
        .width('100%')
        .height('70%')
        .columnsTemplate('1fr 1fr 1fr 1fr') // 4列等宽
        .rowsTemplate('1fr 1fr 1fr 1fr 1fr') // 5行等高
        .columnsGap(12)
        .rowsGap(12).padding({
          left: '5fp',
          right: '5fp',
          top: '10fp', // 可选：添加上边距
          bottom: '10fp'  // 可选：添加下边距
        })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center) // 水平居中
      .justifyContent(FlexAlign.Center) // 垂直居中 // 列间距

    }
    .height('100%')
    .width('100%')
    .background(Color.Black)
  }

  // 在 Index 类中增加逻辑处理
  handleCalculatorInput(data: CalculatorButtonData) {
    const type = data.type;
    const text = data.text;
    const lastChar = this.calculatorText.slice(-1);

    // 逻辑判断：当前是否显示的是计算结果？
    // 场景：如果 calculatorText 等于 resultText 且不为空，说明刚点过“=”
    const isShowingResult = this.calculatorText !== "" && this.calculatorText === this.resultText;

    switch (type) {
      case CalculatorButtonType.Clear:
        this.calculatorText = "";
        this.resultText = "";
        break;

      case CalculatorButtonType.Delete:
        this.calculatorText = this.calculatorText.slice(0, -1);
        // 需求：表达式为空，结果也清空
        if (this.calculatorText === "") {
          this.resultText = "";
        }
        break;

      case CalculatorButtonType.Equals:
        if (this.calculatorText && !['+', '-', '×', '÷'].includes(lastChar)) {
          const res = CalculatorEngine.evaluate(this.calculatorText);
          this.resultText = res;
          this.calculatorText = res; // 让表达式显示结果，进入“显示结果”状态
        }
        break;

      default: // 数字与运算符
        if (type >= CalculatorButtonType.Zero && type <= CalculatorButtonType.Nine) {
          // --- 处理数字输入 ---

          // 1. 如果当前是计算结果，点击数字直接覆盖（开启新运算）
          if (isShowingResult) {
            this.calculatorText = text;
            this.resultText = ""; // 清空旧结果
            return;
          }

          // 2. 防止“0”开头：如果当前只有"0"，输入新数字则替换它
          if (this.calculatorText === "0") {
            this.calculatorText = text;
          } else {
            this.calculatorText += text;
          }

        } else {
          // --- 处理运算符 (+ - * /) ---

          if (this.calculatorText === "" || this.calculatorText === "0") {
            // 运算符不能作为开头（除非是负号，此处暂不展开）
            return;
          }

          if (['+', '-', '×', '÷'].includes(lastChar)) {
            // 替换末尾重复运算符
            this.calculatorText = this.calculatorText.slice(0, -1) + text;
          } else {
            this.calculatorText += text;
          }
        }
        break;
    }
  }
}

enum CalculatorButtonType {
  Zero = 0x00,
  One = 0x01,
  Two = 0x02,
  Three = 0x03,
  Four = 0x04, // 数字4
  Five = 0x05, // 数字5
  Six = 0x06, // 数字6
  Seven = 0x07, // 数字7
  Eight = 0x08, // 数字8
  Nine = 0x09, // 数字9
  Equals = 0x0A, // 等于 =
  Divide = 0x0B, // 除 /
  Multiply = 0x0C, // 乘 *
  Add = 0x0D, // 加 +
  Subtract = 0x0E, // 减 -
  Delete = 0x0F, // 删除
  Clear = 0x10, // 清除
  Percent = 0x11, // 百分号 %
  Decimal = 0x12, // 小数点 .
  Sign = 0x13 // 正负号 ±
}

class CalculatorButtonData {
  // 按钮功能类型（必选）
  type: CalculatorButtonType;
  // 图标资源路径（可选）
  src?: string;
  otherSrc?: string;
  // 按钮显示文本（必选）
  text: string;
  otherText: string;
  background: string;

  /**
   * 计算器按钮数据构造函数
   * @param type - 按钮功能类型，使用预定义的CalculatorButtonType枚举
   * @param text - 按钮显示的文本标签
   * @param src - 可选参数，图标资源路径（用于图形按钮）
   * @param background 必选参数，按钮背景
   */
  constructor(type: CalculatorButtonType, text: string, otherText: string, background: string, src?: string,
    otherSrc?: string) {
    this.type = type;
    this.text = text;
    this.otherText = otherText
    this.src = src;
    this.otherSrc = otherSrc
    this.background = background
  }
}


@Component
struct CalculatorButton {
  // 按钮数据源
  @Prop buttonData: CalculatorButtonData;
  @Prop calculatorText: string;
  @Prop resultText: string;
  // 1. 定义回调函数，接收一个 CalculatorButtonData 参数
  // 这样父组件就能知道具体是哪个按钮被点了
  onButtonClick?: (data: CalculatorButtonData) => void;

  getCalculatorText(): string {
    let result = this.buttonData.otherText;
    if (this.buttonData.type == CalculatorButtonType.Clear) {
      if (this.calculatorText != "") {
        result = this.buttonData.text
      }
    }
    return result;
  }

  build() {
    Button() {
      // 条件渲染：有图片资源时显示图片，否则显示文本
      if (this.buttonData.src) {
        // 显示图片按钮
        Image($r(this.buttonData.src))
          .width(40)
          .height(40)
          .objectFit(ImageFit.Contain)
      } else {
        // 显示文本按钮
        Text(this.getCalculatorText())
          .fontSize(24)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
    }
    .onClick(()=>{
      if(this.onButtonClick){
        this.onButtonClick(this.buttonData)
      }
    })
    .align(Alignment.Center)
    // 按钮基础样式
    .width('100%')
    .height('100%')
    .borderRadius(40)
    .backgroundColor(this.buttonData.background)
  }
}
