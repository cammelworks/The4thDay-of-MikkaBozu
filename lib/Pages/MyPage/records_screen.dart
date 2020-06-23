import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecordsScreen extends StatelessWidget {
  String _email;

  RecordsScreen(this._email);
  @override
  Widget build(BuildContext context) {
    //画面サイズを取得
    final Size size = MediaQuery.of(context).size;
    return ConstrainedBox(
      //表示できる最大範囲を画面の縦3分の1に指定
      constraints: BoxConstraints(maxHeight: size.height/3),
      child: Center(
            child: Container(
              alignment: Alignment.center,
              child: getRecords(),
            ),
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
            .orderBy("timestamp",descending: true)
            .snapshots(),
        //streamが更新されるたびに呼ばれる
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          //データが取れていない時の処理
          if (!snapshot.hasData) return const Text('Loading...');

          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, int index) {
              return Container(
                padding: const EdgeInsets.all(6),
                alignment: Alignment.center,
                child: Text(
                  snapshot.data.documents[index]["distance"].toString(),
                ),
              );
            },
          );
        });
  }
}
