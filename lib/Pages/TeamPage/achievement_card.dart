import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:the4thdayofmikkabozu/hex_color.dart' as hex;

import 'members_record.dart';

class AchievementCard extends StatelessWidget {
  const AchievementCard({
    Key key,
    @required String teamName,
    @required this.isAdmin,
    @required String adminEmail,
  })  : _teamName = teamName,
        _adminEmail = adminEmail,
        super(key: key);

  final String _teamName;
  final bool isAdmin;
  final String _adminEmail;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '到達度',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Visibility(
                  visible: true,
                  child: OutlineButton(
                      color: Theme.of(context).primaryColor,
                      shape: const StadiumBorder(),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.edit,
                            size: 16,
                          ),
                          const Text('編集')
                        ],
                      ),
                      onPressed: () async {
                        showPickerNumber(context);
                      }))
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 16.0, 0),
                child: Image.asset(
                  'images/road.png',
                  width: 70.0,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '目標',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  _showGoal(),
                ],
              )
            ],
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 16.0, 0),
                child: Image.asset(
                  'images/icon_111860_256.png',
                  width: 70.0,
                ),
              ),
              // AchievementBar(_teamName, adminSnapshot.data['admin'].toString()),
              StreamBuilder(
                  //表示したいFirestoreの保存先を指定
                  stream: Firestore.instance.collection('teams').document(_teamName).collection('users').snapshots(),
                  //streamが更新されるたびに呼ばれる
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    //データが取れていない時の処理
                    if (!snapshot.hasData)
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: CircularProgressIndicator()),
                      );

                    return FutureBuilder(
                      future: MembersRecord(_teamName, _adminEmail).getGoal(),
                      builder: (BuildContext context, AsyncSnapshot<int> goalSnapshot) {
                        if (goalSnapshot.hasData) {
                          // 個人の記録の取得
                          return FutureBuilder(
                              future: MembersRecord(_teamName, _adminEmail)
                                  .getMemberRecord(snapshot.data, goalSnapshot.data),
                              builder: (BuildContext context, AsyncSnapshot<Map> memberSnapshot) {
                                if (memberSnapshot.hasData) {
                                  int achievementNum = 0;
                                  memberSnapshot.data.forEach((dynamic key, dynamic value) {
                                    if (value[0] as bool) {
                                      achievementNum++;
                                    }
                                  });
                                  return Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '到達人数',
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          achievementNum.toString() + '/' + snapshot.data.documents.length.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 40,
                                          ),
                                        ),
                                        LinearPercentIndicator(
                                          animation: true,
                                          lineHeight: 20.0,
                                          animationDuration: 2000,
                                          percent: achievementNum / snapshot.data.documents.length,
                                          linearStrokeCap: LinearStrokeCap.roundAll,
                                          progressColor: hex.HexColor('f17300'),
                                          trailing: Image.asset(
                                            'images/flag-icon.png',
                                            height: 30,
                                            width: 30,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                              });
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                      },
                    );
                  })
            ],
          ),
        ],
      ),
    ));
  }

  void showPickerNumber(BuildContext context) {
    Picker(
        adapter: NumberPickerAdapter(data: [
          const NumberPickerColumn(begin: 0, end: 9, jump: 1),
          const NumberPickerColumn(begin: 0, end: 9, jump: 1),
        ]),
        hideHeader: true,
        title: const Text('チーム目標を設定してください'),
        selectedTextStyle: TextStyle(color: Theme.of(context).primaryColor),
        confirmText: '決定',
        cancelText: 'キャンセル',
        onConfirm: (Picker picker, List values) {
          _setGoal(values[0] * 10 + values[1]);
        }).showDialog(context);
  }

  void _setGoal(dynamic goal) {
    //Firebaseのteamsに目標を設定する
    Firestore.instance.collection('teams').document(_teamName).updateData(<String, dynamic>{'goal': goal});
  }

  Widget _showGoal() {
    //Firestoreから目標を取得して表示
    return StreamBuilder<DocumentSnapshot>(
        //表示したいFirestoreの保存先を指定
        stream: Firestore.instance.collection('teams').document(_teamName).snapshots(),
        //streamが更新されるたびに呼ばれる
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          //データが取れていない時の処理
          if (!snapshot.hasData)
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          if (snapshot.data['goal'] != null) {
            return Text(
              '週' + snapshot.data['goal'].toString() + 'km',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            );
          } else {
            return const Text(
              '週0km',
              style: TextStyle(
                fontSize: 40,
              ),
            );
          }
        });
  }
}
