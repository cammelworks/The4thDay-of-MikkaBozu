import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/Pages/ChatPage/chat_page.dart';
import 'package:the4thdayofmikkabozu/Pages/TeamPage/goal_manager.dart';
import 'package:the4thdayofmikkabozu/Pages/TeamPage/members_record.dart';
import 'package:the4thdayofmikkabozu/Pages/TeamPage/overview_manager.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

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
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection('teams')
          .document(_teamName)
          .snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot> adminSnapshot) {
        if (!adminSnapshot.hasData) {
          return Text('Loading...');
        }
        bool isAdmin =
            userData.userEmail == adminSnapshot.data['admin'].toString();
        return Scaffold(
          appBar: AppBar(
            title: Text(_teamName),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ),
                onPressed: () async {
                  showDialog<dynamic>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Text("「" + _teamName + "」" + "を抜けますか?"),
                        actions: <Widget>[
                          FlatButton(
                              child: Text("はい"),
                              onPressed: () {
                                LeaveTeam();
                                int count = 0;
                                Navigator.of(context)
                                    .popUntil((_) => count++ >= 2);
                              }),
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
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      OverviewManager(_teamName, isAdmin),
                      GoalManager(_teamName, isAdmin),
                      Container(
                        height: 10.0,
                      ),
                      MembersRecord(
                          _teamName, adminSnapshot.data['admin'].toString()),
                    ]),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
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
      },
    );
  }

  void LeaveTeam() async {
    //チームからユーザ情報を削除
    Firestore.instance
        .collection('teams')
        .document(_teamName)
        .collection("users")
        .document(userData.userEmail)
        .delete();

    //ユーザからチーム情報を削除
    Firestore.instance
        .collection('users')
        .document(userData.userEmail)
        .collection("teams")
        .document(_teamName)
        .delete();

    // チームの参加人数を取得
    DocumentSnapshot snapshot =
        await Firestore.instance.collection('teams').document(_teamName).get();

    // チームの参加人数を1減らしてプッシュ
    int userNum = (snapshot.data['user_num'] as int) - 1;
    Firestore.instance
        .collection('teams')
        .document(_teamName)
        .updateData(<String, num>{'user_num': userNum});
  }

  Future<String> getAdmin() async {
    var snapshot = await Firestore.instance
        .collection('teams')
        .document((_teamName))
        .get();
    return snapshot.data['admin'].toString();
  }
}
