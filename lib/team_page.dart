import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class TeamPage extends StatefulWidget {
  String _TeamName;
  //コンストラクタ
  TeamPage(this._TeamName);
  @override
  State<StatefulWidget> createState() => TeamPageState(_TeamName);
}

class TeamPageState extends State<TeamPage> {
  String _TeamName;
  //コンストラクタ
  TeamPageState(this._TeamName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_TeamName),
      ),
      body: Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    '目標',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              Center(
                  child: NumberPicker.integer(
                initialValue: 50,
                minValue: 0,
                maxValue: 100,
              )),
            ]),
      ),
    );
  }
}
