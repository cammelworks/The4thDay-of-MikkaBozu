import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MeasurementPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MeasurementPageState();
}

class MeasurementPageState extends State<MeasurementPage> {
  List<String> buttonStateList = ['START', 'STOP', 'My Page'];
  int _value = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('時間・距離計測ページ'),
      ),
      body: Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: ButtonTheme(
                  minWidth: 100,
                  height: 100,
                  child: RaisedButton(
                    child: Text(buttonStateList[_value]),
                    color: Colors.white,
                    shape: CircleBorder(
                      side: BorderSide(
                        color: Colors.black,
                        width: 1.0,
                        style: BorderStyle.solid,
                      ),
                    ),
                    onPressed: () {
                      if(_value < 2) {
                        setState(() {
                          _value++;
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}
