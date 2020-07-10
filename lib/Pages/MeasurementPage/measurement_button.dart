import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef UserCallback = void Function();

class MeasurementButton extends StatelessWidget {
  List<String> buttonStateList = ['START', 'STOP', 'My Page'];
  int _value;
  final UserCallback callback;

  MeasurementButton(this._value, this.callback) : super();

  static const platform = const MethodChannel("Java.Foreground");

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return ButtonTheme(
      minWidth: size.width / 2,
      height: size.height / 4,
      child: RaisedButton(
        child: Text(buttonStateList[_value]),
        color: Colors.white,
        shape: CircleBorder(
          side: BorderSide(
            color: Colors.black,
            style: BorderStyle.solid,
          ),
        ),
        onPressed: () {
          //スタート、ストップ
          if (_value < 2) {
            if(_value == 0)
              platform.invokeMethod("ON");
            if(_value == 1)
              platform.invokeMethod("OFF");
            callback();
          }
          //マイページに戻る
          else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
