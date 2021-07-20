import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as user_data;

import '../ChatPage/chat_page.dart';
import 'achievement_card.dart';
import 'members_record.dart';
import 'overview_manager.dart';

class TeamPage extends StatefulWidget {
  final String _teamName;
  //コンストラクタ
  const TeamPage(this._teamName);
  @override
  State<StatefulWidget> createState() => TeamPageState(_teamName);
}

class TeamPageState extends State<TeamPage> {
  final String _teamName;
  //コンストラクタ
  TeamPageState(this._teamName);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('teams').document(_teamName).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> adminSnapshot) {
        if (!adminSnapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final bool isAdmin = user_data.userEmail == adminSnapshot.data['admin'].toString();
        final int _userNum = adminSnapshot.data['user_num'] as int;

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
                          content: Text('「' + _teamName + '」' + 'を削除しますか?'),
                          actions: <Widget>[
                            FlatButton(
                                child: const Text('はい'),
                                onPressed: () {
                                  DeleteTeam();
                                  int count = 0;
                                  Navigator.of(context).popUntil((_) => count++ >= 2);
                                }),
                            FlatButton(
                              child: const Text('キャンセル'),
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
                                child: const Text('はい'),
                                onPressed: () {
                                  DeleteTeam();
                                  int count = 0;
                                  Navigator.of(context).popUntil((_) => count++ >= 2);
                                }),
                            FlatButton(
                              child: const Text('キャンセル'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      } else {
                        if (isAdmin) {
                          return AlertDialog(
                            title: const Text('管理者はチームから抜けられません'),
                            content: const Text('チームメンバーに管理者権限を渡してください'),
                            actions: <Widget>[
                              FlatButton(
                                child: const Text('はい'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          );
                        } else {
                          return AlertDialog(
                            content: Text('「' + _teamName + '」を抜けますか?'),
                            actions: <Widget>[
                              FlatButton(
                                  child: const Text('はい'),
                                  onPressed: () {
                                    LeaveTeam();
                                    int count = 0;
                                    Navigator.of(context).popUntil((_) => count++ >= 2);
                                  }),
                              FlatButton(
                                child: const Text('キャンセル'),
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
            child: Column(children: <Widget>[
              OverviewManager(_teamName, isAdmin),
              AchievementCard(
                teamName: _teamName,
                isAdmin: isAdmin,
                adminEmail: adminSnapshot.data['admin'].toString(),
              ),
              MembersRecord(_teamName, adminSnapshot.data['admin'].toString()),
            ]),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (context) => ChatPage(_teamName),
                  ));
              setState(() {});
            },
            child: Stack(overflow: Overflow.visible, children: [
              Icon(Icons.chat),
              Positioned(
                top: -15,
                right: -15,
                child: Visibility(
                  visible: user_data.hasNewChat[_teamName],
                  child: Icon(
                    Icons.brightness_1,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              )
            ]),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }

  Future<void> LeaveTeam() async {
    //チームからユーザ情報を削除
    Firestore.instance
        .collection('teams')
        .document(_teamName)
        .collection('users')
        .document(user_data.userEmail)
        .delete();

    //ユーザからチーム情報を削除
    Firestore.instance
        .collection('users')
        .document(user_data.userEmail)
        .collection('teams')
        .document(_teamName)
        .delete();

    // チームの参加人数を取得
    final DocumentSnapshot snapshot = await Firestore.instance.collection('teams').document(_teamName).get();

    // チームの参加人数を1減らしてプッシュ
    final int userNum = (snapshot.data['user_num'] as int) - 1;
    Firestore.instance.collection('teams').document(_teamName).updateData(<String, num>{'user_num': userNum});
  }

  Future<String> getAdmin() async {
    final snapshot = await Firestore.instance.collection('teams').document(_teamName).get();
    return snapshot.data['admin'].toString();
  }

  Future<void> DeleteTeam() async {
    final membersEmails = <String>[];

    //teamからusersサブコレクションを削除
    await Firestore.instance
        .collection('teams')
        .document(_teamName)
        .collection('users')
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents) {
        final test = ds.data['email'].toString();
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

  Future<bool> CheckIsLastMember() async {
    // チームの参加人数を取得
    final QuerySnapshot snapshot =
        await Firestore.instance.collection('teams').document(_teamName).collection('users').getDocuments();

    return snapshot.documents.length == 1;
  }
}
