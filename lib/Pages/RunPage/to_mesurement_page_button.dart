import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/Pages/MeasurementPage/measurement_page.dart';

class ToMeasurementPageButton extends StatelessWidget {
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
              child: const Text('走る',
                style: TextStyle(
                  fontSize: 18
                ),
              ),
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
              onPressed: () async {
                  await Navigator.push<dynamic>(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (context) => MeasurementPage(),
                      ));
              }),
        ),
      ),
    );
  }
}