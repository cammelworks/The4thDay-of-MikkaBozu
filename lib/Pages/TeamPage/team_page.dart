import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/Pages/ChatPage/char_page.dart';
import 'package:the4thdayofmikkabozu/Pages/TeamPage/goal_manager.dart';
import 'package:the4thdayofmikkabozu/Pages/TeamPage/members_record.dart';
import 'package:the4thdayofmikkabozu/Pages/TeamPage/overview_manager.dart';

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
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                OverviewManager(_teamName),
                GoalManager(_teamName),
                Container(
                  height: 10.0,
                ),
                MembersRecord(_teamName),
              ]),
        ),
      ),
        floatingActionButton:FloatingActionButton(
          onPressed: () async {
            await Navigator.push<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                  builder: (context) => ChatPage(),
                ));
          },
          child: Icon(Icons.chat),
          backgroundColor: Colors.blue,
        ),
    );
  }
}
