import 'package:flutter/material.dart';
import 'dart:math' as math; // Sadece Dart'ın yerleşik matematik kütüphanesi

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hesap Makinesi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _displayText = "0";

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _displayText = "0";
      } else if (buttonText == "⌫") {
        if (_displayText.length > 1) {
          _displayText = _displayText.substring(0, _displayText.length - 1);
        } else {
          _displayText = "0";
        }
      } else if (buttonText == "=") {
        _calculateResult();
      } else {
        if (_displayText == "0" && buttonText != ".") {
          _displayText = buttonText;
        } else {
          _displayText += buttonText;
        }
      }
    });
  }

  void _calculateResult() {
    try {
   
      String expression = _displayText.replaceAll('×', '*').replaceAll('÷', '/');
     
      double eval = Parser(expression).parse();
      
      _displayText = eval.toString();
      
      if (_displayText.endsWith(".0")) {
        _displayText = _displayText.substring(0, _displayText.length - 2);
      }
    } catch (e) {
      _displayText = "Hata";
    }
  }

  Widget _buildButton(String text, Color bgColor, {int flex = 1, Color textColor = Colors.white}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 22.0),
          ),
          onPressed: () => _onButtonPressed(text),
          child: text == "⌫" 
              ? Icon(Icons.backspace_outlined, color: textColor, size: 20)
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color funcColor = Colors.blueGrey.shade400;
    final Color numColor = Colors.grey.shade800;
    final Color opColor = Colors.orange.shade400;
    final Color redColor = Colors.redAccent.shade400;
    final Color greenColor = Colors.green.shade500;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  _displayText,
                  style: const TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Row(children: [
                    _buildButton("sin(", funcColor),
                    _buildButton("cos(", funcColor),
                    _buildButton("tan(", funcColor),
                    _buildButton("log(", funcColor),
                  ]),
                  Row(children: [
                    _buildButton("sqrt(", funcColor),
                    _buildButton("^", funcColor),
                    _buildButton("(", funcColor),
                    _buildButton(")", funcColor),
                  ]),
                  Row(children: [
                    _buildButton("7", numColor),
                    _buildButton("8", numColor),
                    _buildButton("9", numColor),
                    _buildButton("÷", opColor),
                  ]),
                  Row(children: [
                    _buildButton("4", numColor),
                    _buildButton("5", numColor),
                    _buildButton("6", numColor),
                    _buildButton("×", opColor),
                  ]),
                  Row(children: [
                    _buildButton("1", numColor),
                    _buildButton("2", numColor),
                    _buildButton("3", numColor),
                    _buildButton("-", opColor),
                  ]),
                  Row(children: [
                    _buildButton("0", numColor),
                    _buildButton(".", numColor),
                    _buildButton("⌫", redColor),
                    _buildButton("+", opColor),
                  ]),
                  Row(children: [
                    _buildButton("C", redColor, flex: 1),
                    _buildButton("=", greenColor, flex: 1),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Parser {
  final String expr;
  int pos = -1;
  int ch = 0;

  Parser(this.expr);

  void nextChar() {
    pos++;
    ch = (pos < expr.length) ? expr.codeUnitAt(pos) : -1;
  }

  bool eat(int charToEat) {
    while (ch == 32) nextChar(); // Boşlukları atla
    if (ch == charToEat) {
      nextChar();
      return true;
    }
    return false;
  }

  double parse() {
    nextChar();
    double x = parseExpression();
    if (pos < expr.length) throw Exception("Beklenmeyen karakter");
    return x;
  }

  double parseExpression() {
    double x = parseTerm();
    for (;;) {
      if (eat(43)) x += parseTerm(); // Toplama '+'
      else if (eat(45)) x -= parseTerm(); // Çıkarma '-'
      else return x;
    }
  }

  double parseTerm() {
    double x = parseFactor();
    for (;;) {
      if (eat(42)) x *= parseFactor(); // Çarpma '*'
      else if (eat(47)) x /= parseFactor(); // Bölme '/'
      else return x;
    }
  }

  double parseFactor() {
    if (eat(43)) return parseFactor(); // Pozitif işaret
    if (eat(45)) return -parseFactor(); // Negatif işaret

    double x = 0;
    int startPos = pos;
    if (eat(40)) { // Parantez aç '('
      x = parseExpression();
      eat(41); // Parantez kapa ')'
    } else if ((ch >= 48 && ch <= 57) || ch == 46) { 
      while ((ch >= 48 && ch <= 57) || ch == 46) nextChar();
      x = double.parse(expr.substring(startPos, pos));
    } else if (ch >= 97 && ch <= 122) { // Fonksiyonlar (sin, cos vb.)
      while (ch >= 97 && ch <= 122) nextChar();
      String func = expr.substring(startPos, pos);
      x = parseFactor();
      if (func == "sqrt") x = math.sqrt(x);
      else if (func == "sin") x = math.sin(x); 
      else if (func == "cos") x = math.cos(x);
      else if (func == "tan") x = math.tan(x);
      else if (func == "log") x = math.log(x); 
      else throw Exception("Bilinmeyen fonksiyon: $func");
    } else {
      throw Exception("Beklenmeyen karakter");
    }

    if (eat(94)) x = math.pow(x, parseFactor()).toDouble(); 

    return x;
  }
}
