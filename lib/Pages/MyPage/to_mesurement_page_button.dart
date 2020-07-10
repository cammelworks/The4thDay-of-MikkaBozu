import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/Pages/MeasurementPage/measurement_page.dart';
import 'package:flutter/services.dart';

class ToMeasurementPageButton extends StatelessWidget {
//  static const platform = const MethodChannel("com.tasogarei.test/web");
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
        child: ButtonTheme(
          minWidth: 200.0,
          height: 50.0,
          buttonColor: Colors.white,
          child: RaisedButton(
              child: const Text('運動をする'),
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              onPressed: () async {
                  //kotlinのメソッドを呼ぶ
//                await platform.invokeMethod("web");

                  final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MeasurementPage(),
                      ));
              }),
        ),
      ),
    );
  }
}