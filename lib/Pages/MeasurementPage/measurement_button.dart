import 'package:flutter/material.dart';

typedef UserCallback = void Function();

class MeasurementButton extends StatelessWidget {
  final List<Icon> buttonStateList = [
    Icon(
      Icons.directions_run,
      size: 60,
    ),
    Icon(
      Icons.stop,
      size: 60,
    ),
    Icon(
      Icons.home,
      size: 60,
    )
  ];
  int _value;
  final UserCallback callback;

  MeasurementButton(this._value, this.callback) : super();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return ButtonTheme(
      // minWidth: size.width / 2,
      height: 100,
      child: RaisedButton(
        child: buttonStateList[_value],
        color: Colors.white,
        shape: CircleBorder(
          side: BorderSide(
            color: Colors.white,
            style: BorderStyle.solid,
          ),
        ),
        onPressed: () {
          //スタート、ストップ
          if (_value < 2) {
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
