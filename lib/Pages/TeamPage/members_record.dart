import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:the4thdayofmikkabozu/Pages/MemberPage/member_page.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:the4thdayofmikkabozu/hex_color.dart' as hex;

class MembersRecord extends StatelessWidget {
  String _teamName;

  MembersRecord(this._teamName);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: getMembers(context),
    );
  }

  //メンバー一覧を表示する
  Widget getMembers(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        //表示したいFiresotreの保存先を指定
        stream: Firestore.instance
            .collection('teams')
            .document(_teamName)
            .collection('users')
            .snapshots(),
        //streamが更新されるたびに呼ばれる
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //データが取れていない時の処理
          if (!snapshot.hasData) return const Text('Loading...');
          final Size size = MediaQuery.of(context).size;
          int achievementNum = 0;

          //チームの目標の取得
          return FutureBuilder(
            future: getGoal(),
            builder: (BuildContext context, AsyncSnapshot<int> goalSnapshot) {
              if (goalSnapshot.hasData) {
                // 個人の記録の取得
                return FutureBuilder(
                  future: getMemberRecord(snapshot.data, goalSnapshot.data),
                  builder: (BuildContext context, AsyncSnapshot<Map> memberSnapshot) {
                    if (memberSnapshot.hasData) {
                      print(memberSnapshot.data);
                      int achievedMemberNum = 0;
                      memberSnapshot.data.forEach((dynamic key, dynamic value) {
                        if(value[0] as bool){
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
                                  percent: achievementNum/snapshot.data.documents.length,
//                                  center: Text(achievementNum.toString() + "/" + snapshot.data.documents.length.toString()),
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
                          Text(
                            'メンバー',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Container(
                            height: size.height * (1 / 3),
                            child: Scrollbar(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, int index) {
                                  String userEmail =
                                      snapshot.data.documents[index].documentID.toString();
                                  String userName = "Guest";
                                  print(memberSnapshot.data[userEmail][1]);
                                  if(memberSnapshot.data[userEmail][1] != "null") {
                                    userName = memberSnapshot.data[userEmail][1] as String;
                                  }
                                  if(memberSnapshot.data[userEmail][0] as bool){
                                    return ListTile(
                                      leading: Icon(
                                        Icons.account_circle,
                                        size: 50,
                                      ),
                                      trailing: Image.asset(
                                        'images/flag-icon.png',
                                        height: 30.0,
                                        width: 30.0,
                                      ),
                                      title: Text(userName),
                                      onTap: () => Navigator.push<dynamic>(
                                          context,
                                          MaterialPageRoute<dynamic>(
                                            builder: (context) => MemberPage(userEmail, userName),
                                          )),
                                    );
                                  } else{
                                    return ListTile(
                                      leading: Icon(
                                        Icons.account_circle,
                                        size: 50,
                                      ),
                                      title: Text(userName),
                                      onTap: () => Navigator.push<dynamic>(
                                          context,
                                          MaterialPageRoute<dynamic>(
                                            builder: (context) => MemberPage(userEmail, userName),
                                          )),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Text("record loading...");
                    }
                  });
              } else{
                return Text("goal loading...");
              }
            },
          );
        });
  }

  Future<int> getGoal() async{
    var snapshot = await Firestore.instance
        .collection('teams')
        .document((_teamName))
        .get();
    return snapshot.data['goal'] as int;
  }

  Future<Map> getMemberRecord(QuerySnapshot data, int goal) async{
    // マップの初期化
    Map<String, List> userMap = {};
    for(int i=0; i<data.documents.length; i++){
      List<dynamic> hasMemberAchieved = List<dynamic>();
      double totalDistance = 0.0;
      QuerySnapshot recordSnapshots = await Firestore.instance
          .collection('users')
          .document(data.documents[i].documentID)
          .collection('records')
          .where("timestamp", isGreaterThanOrEqualTo: Timestamp.fromDate(getLastSundayDataTime()))
          .getDocuments();
      DocumentSnapshot userSnapshot = await Firestore.instance
          .collection('users')
          .document(data.documents[i].documentID)
          .get();
      for(int j=0; j<recordSnapshots.documents.length; j++){
        totalDistance += recordSnapshots.documents[j].data['distance'] as double;
      }
      // 目標を達成しているかの確認
      if(((totalDistance / 100.0).round() / 10) >= goal){
        hasMemberAchieved.add(true);
      } else{
        hasMemberAchieved.add(false);
      }
      hasMemberAchieved.add(userSnapshot.data['name'].toString());//0にbool,1にname
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
        dResult = dResult.subtract(Duration(days : 1));
        if (dResult.weekday == DateTime.sunday) {
          break;
        }
      }
    }

    return (dResult);
  }
}
