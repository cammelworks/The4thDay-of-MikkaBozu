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
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog<dynamic>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: Text("「" + _teamName + "」" + "を抜けますか?"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("はい"),
                        onPressed: () => Navigator.pop(context),
                      ),
                      FlatButton(
                        child: Text("キャンセル"),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
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
                  builder: (context) => ChatPage(_teamName),
                ));
          },
          child: Icon(Icons.chat),
          backgroundColor: Colors.blue,
        ),
    );
  }
}
