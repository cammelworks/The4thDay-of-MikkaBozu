import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the4thdayofmikkabozu/user_data.dart' as userData;

class RecordsScreen extends StatelessWidget {
  String _email = userData.userEmail;

  @override
  Widget build(BuildContext context) {
    //画面サイズを取得
    final Size size = MediaQuery.of(context).size;
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(size.width / 4, 20, 6, 20),
                width: size.width / 2,
                alignment: Alignment.centerLeft,
                child: Text(
                  '日付',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                width: size.width / 2,
                padding: EdgeInsets.fromLTRB(6, 6, size.width / 4, 6),
                alignment: Alignment.centerRight,
                child: Text(
                  '距離',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: size.height*(7/10),
            child: getRecords(),
          ),
        ],
      ),
    );
  }

  //走った距離を取得する関数
  Widget getRecords() {
    return StreamBuilder<QuerySnapshot>(
      //表示したいFiresotreの保存先を指定
        stream: Firestore.instance
            .collection('users')
            .document(_email)
            .collection('records')
            .orderBy("timestamp", descending: true)
            .snapshots(),
        //streamが更新されるたびに呼ばれる
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //データが取れていない時の処理
          if (!snapshot.hasData) return const Text('Loading...');

          return Scrollbar(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, int index) {
                Size size = MediaQuery.of(context).size;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: size.width / 4),
                      width: size.width / 2,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _timestampToString(
                            snapshot.data.documents[index]["timestamp"]),
                      ),
                    ),
                    Container(
                      width: size.width / 2,
                      padding: EdgeInsets.fromLTRB(6, 6, size.width / 4, 6),
                      alignment: Alignment.centerRight,
                      child: Text(
                        _convertUnit(snapshot.data.documents[index]["distance"]),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        });
  }

  String _convertUnit(double distance) {
    // _distanceはメートル
    // 距離をkmで表示する
    //表示するときに丸め誤差が生じるため、小数点2位以下を切り捨てる
    double km_distance = distance / 1000.0;
    return "${(km_distance * 10).round() / 10}" + "km";
  }

  //Timestamp型の時間情報を日にちに変換する
  String _timestampToString(Timestamp timeStamp) {
    DateTime time = timeStamp.toDate();
    int month = time.month;
    int day = time.day;
    return month.toString() + "/" + day.toString();
  }
}
