

// CalculatorEngine.ets
export class CalculatorEngine {
  // 定义优先级
  private static priority(op: string): number {
    if (op === '+' || op === '-') return 1;
    if (op === '*' || op === '/') return 2;
    return 0;
  }

  // 执行基础运算
  private static applyOp(a: number, b: number, op: string): number {
    switch (op) {
      case '+': return a + b;
      case '-': return a - b;
      case '*': return a * b;
      case '/': return b === 0 ? 0 : a / b; // 处理除零
    }
    return 0;
  }

  // 核心解析逻辑：中缀表达式转后缀并计算
  public static evaluate(exp: string): string {
    try {
      // 预处理字符串：替换符号，处理负数
      let s = exp.replace(/×/g, '*').replace(/÷/g, '/');
      let values: number[] = [];
      let ops: string[] = [];

      for (let i = 0; i < s.length; i++) {
        if (s[i] === ' ') continue;

        // 处理多位数字和小数点
        if ((s[i] >= '0' && s[i] <= '9') || s[i] === '.') {
          let val = "";
          while (i < s.length && ((s[i] >= '0' && s[i] <= '9') || s[i] === '.')) {
            val += s[i++];
          }
          values.push(parseFloat(val));
          i--;
        }
        else {
          // 处理运算符
          while (ops.length > 0 && CalculatorEngine.priority(ops[ops.length - 1]) >= CalculatorEngine.priority(s[i])) {
            let val2 = values.pop();
            let val1 = values.pop();
            let op = ops.pop();
            if (val1 !== undefined && val2 !== undefined && op !== undefined) {
              values.push(CalculatorEngine.applyOp(val1, val2, op));
            }
          }
          ops.push(s[i]);
        }
      }

      while (ops.length > 0) {
        let val2 = values.pop();
        let val1 = values.pop();
        let op = ops.pop();
        if (val1 !== undefined && val2 !== undefined && op !== undefined) {
          values.push(CalculatorEngine.applyOp(val1, val2, op));
        }
      }

      let result = values.pop();
      // 处理浮点数精度问题，保留10位并去掉末尾多余的0
      return result !== undefined ? parseFloat(result.toFixed(10)).toString() : "0";
    } catch (e) {
      return "错误";
    }
  }
}