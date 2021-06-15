import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/Pages/ChatPage/chat_page.dart';
import 'package:the4thdayofmikkabozu/Pages/TeamPage/achievement_bar.dart';
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
      stream: Firestore.instance.collection('teams').document(_teamName).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> adminSnapshot) {
        if (!adminSnapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
          ;
        }

        bool isAdmin = userData.userEmail == adminSnapshot.data['admin'].toString();
        int _userNum = adminSnapshot.data['user_num'] as int;

        return Scaffold(
          appBar: AppBar(
            title: Text(_teamName),
            actions: <Widget>[
              Visibility(
                visible: isAdmin,
                child: IconButton(
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    showDialog<dynamic>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text("「" + _teamName + "」" + "を削除しますか?"),
                          actions: <Widget>[
                            FlatButton(
                                child: Text("はい"),
                                onPressed: () {
                                  DeleteTeam();
                                  int count = 0;
                                  Navigator.of(context).popUntil((_) => count++ >= 2);
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
              ),
              IconButton(
                icon: Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                ),
                onPressed: () async {
                  showDialog<dynamic>(
                    context: context,
                    builder: (context) {
                      if (_userNum == 1) {
                        return AlertDialog(
                          content: Text('あなたがチームを抜けると「' + _teamName + '」が削除されます。\n よろしいですか？'),
                          actions: <Widget>[
                            FlatButton(
                                child: Text("はい"),
                                onPressed: () {
                                  DeleteTeam();
                                  int count = 0;
                                  Navigator.of(context).popUntil((_) => count++ >= 2);
                                }),
                            FlatButton(
                              child: Text('キャンセル'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      } else {
                        if (isAdmin) {
                          return AlertDialog(
                            title: Text('管理者はチームから抜けられません'),
                            content: Text('チームメンバーに管理者権限を渡してください'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('はい'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          );
                        } else {
                          return AlertDialog(
                            content: Text("「" + _teamName + "」" + "を抜けますか?"),
                            actions: <Widget>[
                              FlatButton(
                                  child: Text("はい"),
                                  onPressed: () {
                                    LeaveTeam();
                                    int count = 0;
                                    Navigator.of(context).popUntil((_) => count++ >= 2);
                                  }),
                              FlatButton(
                                child: Text("キャンセル"),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          );
                        }
                      }
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  OverviewManager(_teamName, isAdmin),
                  Card(
                      child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                            child: Text(
                              '到達度',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset(
                              'images/road.png',
                              width: 70.0,
                            ),
                          ),
                          GoalManager(_teamName, isAdmin),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset(
                              'images/icon_111860_256.png',
                              width: 70.0,
                            ),
                          ),
                          AchivementBar(_teamName, adminSnapshot.data['admin'].toString()),
                        ],
                      ),
                    ],
                  )),
                  Card(child: MembersRecord(_teamName, adminSnapshot.data['admin'].toString())),
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
    DocumentSnapshot snapshot = await Firestore.instance.collection('teams').document(_teamName).get();

    // チームの参加人数を1減らしてプッシュ
    int userNum = (snapshot.data['user_num'] as int) - 1;
    Firestore.instance.collection('teams').document(_teamName).updateData(<String, num>{'user_num': userNum});
  }

  Future<String> getAdmin() async {
    var snapshot = await Firestore.instance.collection('teams').document((_teamName)).get();
    return snapshot.data['admin'].toString();
  }

  Future<void> DeleteTeam() async {
    var membersEmails = <String>[];

    //teamからusersサブコレクションを削除
    await Firestore.instance
        .collection('teams')
        .document(_teamName)
        .collection('users')
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        var test = ds.data['email'].toString();
        print(test);
        membersEmails.add(ds.data['email'].toString());
        ds.reference.delete();
      }
    });
    //teamからchatsサブコレクションを削除
    await Firestore.instance
        .collection('teams')
        .document(_teamName)
        .collection('chats')
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        ds.reference.delete();
      }
    });
    //teamsからチームを削除
    Firestore.instance.collection('teams').document(_teamName).delete();

    //該当ユーザーからチームを消す
    membersEmails.forEach((var memberEmail) {
      Firestore.instance.collection('users').document(memberEmail).collection('teams').document(_teamName).delete();
    });
  }

  Future<bool> CheckIsLastmenber() async {
    // チームの参加人数を取得
    QuerySnapshot snapshot =
        await Firestore.instance.collection('teams').document(_teamName).collection('users').getDocuments();

    return snapshot.documents.length == 1;
  }
}
