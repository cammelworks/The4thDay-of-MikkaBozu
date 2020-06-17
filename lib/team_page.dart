import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


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
    );
  }

}
