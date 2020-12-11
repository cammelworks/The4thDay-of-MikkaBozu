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
//                      center: Text("90.0%"),
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
                      if (userEmail == userData.userEmail) {
                        return Container();
                      }
                      return ListTile(
                        leading: Icon(
                          Icons.account_circle,
                          size: 50,
                        ),
                        title: Text(userEmail),
                        onTap: () => Navigator.push<dynamic>(
                            context,
                            MaterialPageRoute<dynamic>(
                              builder: (context) => MemberPage(snapshot
                                  .data.documents[index].documentID
                                  .toString()),
                            )),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        });
  }
}
