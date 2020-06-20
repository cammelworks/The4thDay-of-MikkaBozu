import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the4thdayofmikkabozu/Screens/TeamPage/goal_manager.dart';

class TeamPage extends StatefulWidget {
  String _teamName;
  //コンストラクタ
  TeamPage(this._teamName);
  @override
  State<StatefulWidget> createState() => TeamPageState(_teamName);
}

class TeamPageState extends State<TeamPage> {
  String _teamName;
  //コンストラクタ
  TeamPageState(this._teamName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_teamName),
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
              GoalManager(_teamName),
            ]),
      ),
    );
  }
}
