import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/Pages/MemberPage/member_page.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

class MembersRecord extends StatelessWidget {
  String _teamName;
  String _adminEmail;
  // ポップアップメニューボタンの選択肢リスト
  var _States = ['管理者の譲渡', 'メンバーを追放'];

  MembersRecord(this._teamName, this._adminEmail);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(child: getMembers(context)),
    );
  }

  //メンバー一覧を表示する
  Widget getMembers(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        //表示したいFiresotreの保存先を指定
        stream: Firestore.instance.collection('teams').document(_teamName).collection('users').snapshots(),
        //streamが更新されるたびに呼ばれる
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //データが取れていない時の処理
          if (!snapshot.hasData)
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          ;
          final Size size = MediaQuery.of(context).size;

          //チームの目標の取得
          return FutureBuilder(
            future: getGoal(),
            builder: (BuildContext context, AsyncSnapshot<int> goalSnapshot) {
              if (goalSnapshot.hasData) {
                // 個人の記録の取得
                return FutureBuilder(
                    future: getMemberRecord(snapshot.data, goalSnapshot.data, context),
                    builder: (BuildContext context, AsyncSnapshot<Map> memberSnapshot) {
                      if (memberSnapshot.hasData) {
                        int achievementNum = 0;
                        memberSnapshot.data.forEach((dynamic key, dynamic value) {
                          if (value[0] as bool) {
                            achievementNum++;
                          }
                        });
                        return Column(
                          children: [
                            Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20.0, 0, 0, 0),
                                  child: Text(
                                    'メンバー',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, int index) {
                                  String userEmail = snapshot.data.documents[index].documentID.toString();
                                  String userName = "Guest";
                                  if (memberSnapshot.data[userEmail][1] != "null") {
                                    userName = memberSnapshot.data[userEmail][1] as String;
                                  }
                                  return ListTile(
                                    leading: memberSnapshot.data[userEmail][2] as Widget,
                                    trailing: Visibility(
                                      visible: memberSnapshot.data[userEmail][0] as bool,
                                      child: Image.asset(
                                        'images/flag-icon.png',
                                        height: 30.0,
                                        width: 30.0,
                                      ),
                                    ),
                                    title: Row(
                                      children: <Widget>[
                                        Text(userName),
                                        Spacer(),
                                        // 管理者に星アイコンを表示する
                                        Visibility(
                                          visible: userEmail == _adminEmail,
                                          child: Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                        ),
                                        // 自分以外のメンバーにポップアップメニューを表示する
                                        Visibility(
                                            visible: userEmail != _adminEmail && userData.userEmail == _adminEmail,
                                            child: PopupMenuButton<String>(
                                              icon: Icon(Icons.more_horiz),
                                              onSelected: (String s) {
                                                // ダイアログを表示する
                                                showDialog<dynamic>(
                                                  context: context,
                                                  builder: (context) {
                                                    if (s == '管理者の譲渡') {
                                                      return showChangeAdminDialog(context, userEmail, userName);
                                                    } else if (s == 'メンバーを追放') {
                                                      return showBanDialog(context, userEmail, userName);
                                                    } else {
                                                      return null;
                                                    }
                                                  },
                                                );
                                                print(userEmail);
                                              },
                                              itemBuilder: (BuildContext context) {
                                                return _States.map((String s) {
                                                  return PopupMenuItem(
                                                    child: Text(s),
                                                    value: s,
                                                  );
                                                }).toList();
                                              },
                                            )),
                                      ],
                                    ),
                                    onTap: () => Navigator.push<dynamic>(
                                        context,
                                        MaterialPageRoute<dynamic>(
                                          builder: (context) => MemberPage(userEmail, userName),
                                        )),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                    });
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          );
        });
  }

  Future<int> getGoal() async {
    var snapshot = await Firestore.instance.collection('teams').document((_teamName)).get();
    return snapshot.data['goal'] as int;
  }

  Future<Map> getMemberRecord(QuerySnapshot data, int goal, BuildContext context) async {
    // マップの初期化
    Map<String, List> userMap = {};
    for (int i = 0; i < data.documents.length; i++) {
      List<dynamic> hasMemberAchieved = List<dynamic>();
      double totalDistance = 0.0;
      QuerySnapshot recordSnapshots = await Firestore.instance
          .collection('users')
          .document(data.documents[i].documentID)
          .collection('records')
          .where("timestamp", isGreaterThanOrEqualTo: Timestamp.fromDate(getLastSundayDataTime()))
          .getDocuments();
      DocumentSnapshot userSnapshot =
          await Firestore.instance.collection('users').document(data.documents[i].documentID).get();
      for (int j = 0; j < recordSnapshots.documents.length; j++) {
        totalDistance += recordSnapshots.documents[j].data['distance'] as double;
      }
      // 目標を達成しているかの確認
      if (((totalDistance / 100.0).round() / 10) >= goal) {
        hasMemberAchieved.add(true);
      } else {
        hasMemberAchieved.add(false);
      }
      hasMemberAchieved.add(userSnapshot.data['name'].toString()); //0にbool,1にname
      if (userSnapshot.data['icon_url'].toString() != 'null') {
        hasMemberAchieved.add(CircleAvatar(
          radius: 25,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          backgroundImage: NetworkImage(userSnapshot.data['icon_url'].toString()),
        ));
      } else {
        hasMemberAchieved.add(CircleAvatar(
          radius: 25,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          backgroundImage: AssetImage('images/account_circle.png'),
        ));
      }
      userMap[data.documents[i].documentID] = hasMemberAchieved;
    }
    return userMap;
  }

  // 直近の日曜日の日付を算出し、その日付を返す
  DateTime getLastSundayDataTime() {
    DateTime dResult = DateTime.now();

    // 当日が日曜日ではないならば、
    // 直前の日曜日まで日付を戻していく
    if (dResult.weekday != DateTime.sunday) {
      for (int i = 0; i < 7; ++i) {
        dResult = dResult.subtract(Duration(days: 1));
        if (dResult.weekday == DateTime.sunday) {
          break;
        }
      }
    }
    // 直近の日曜日の0時を返す
    int year = dResult.year;
    int month = dResult.month;
    int day = dResult.day;
    return (DateTime(year, month, day));
  }

  Widget showChangeAdminDialog(BuildContext context, String userEmail, String userName) {
    return AlertDialog(
      content: Text(userName + 'に管理者権限を渡しますか？'),
      actions: <Widget>[
        FlatButton(
            child: Text("はい"),
            onPressed: () {
              changeAdmin(userEmail);
              Navigator.pop(context);
            }),
        FlatButton(
          child: Text("キャンセル"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget showBanDialog(BuildContext context, String userEmail, String userName) {
    return AlertDialog(
      content: Text(userName + 'を追放しますか？'),
      actions: <Widget>[
        FlatButton(
            child: Text("はい"),
            onPressed: () {
              banMember(userEmail);
              Navigator.pop(context);
            }),
        FlatButton(
          child: Text("キャンセル"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  void changeAdmin(String userEmail) {
    Firestore.instance.collection('teams').document(_teamName).updateData(<String, String>{'admin': userEmail});
  }

  void banMember(String userEmail) {
    // teamNameの中のUsersからuserEmailを削除
    Firestore.instance.collection('teams').document(_teamName).collection('users').document(userEmail).delete();
    // userEmailの中のTeamsからteamNameを削除
    Firestore.instance.collection('users').document(userEmail).collection('teams').document(_teamName).delete();
  }
}
