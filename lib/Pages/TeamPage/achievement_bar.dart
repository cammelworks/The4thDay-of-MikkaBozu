import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:the4thdayofmikkabozu/Pages/TeamPage/members_record.dart';
import 'package:the4thdayofmikkabozu/hex_color.dart' as hex;

class AchivementBar extends StatelessWidget {
  String _teamName;
  String _adminEmail;

  AchivementBar(this._teamName, this._adminEmail);

  @override
  Widget build(BuildContext context) {
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

          return FutureBuilder(
            future: MembersRecord(_teamName, _adminEmail).getGoal(),
            builder: (BuildContext context, AsyncSnapshot<int> goalSnapshot) {
              if (goalSnapshot.hasData) {
                // 個人の記録の取得
                return FutureBuilder(
                    future: MembersRecord(_teamName, _adminEmail).getMemberRecord(snapshot.data, goalSnapshot.data),
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
                            Text(
                              '到達人数',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              achievementNum.toString() + "/" + snapshot.data.documents.length.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(5.0),
                                  child: new LinearPercentIndicator(
                                    width: MediaQuery.of(context).size.width - 50,
                                    animation: true,
                                    lineHeight: 20.0,
                                    animationDuration: 2000,
                                    percent: achievementNum / snapshot.data.documents.length,
                                    linearStrokeCap: LinearStrokeCap.roundAll,
                                    progressColor: hex.HexColor("f17300"),
                                    trailing: Image.asset(
                                      'images/flag-icon.png',
                                      height: 30.0,
                                      width: 30.0,
                                    ),
                                  ),
                                ),
                              ],
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
}
