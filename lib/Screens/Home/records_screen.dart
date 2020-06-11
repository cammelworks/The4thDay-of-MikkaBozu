import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecordsScreen extends StatelessWidget {
  String _email;

  RecordsScreen(this._email);
  @override
  Widget build(BuildContext context) {
    return Center(
          child: Container(
            alignment: Alignment.center,
            child: getRecords(),
          ),
        );
  }

  //走った距離を取得する関数
  Widget getRecords() {
    String userDocId;
    getData() async {
      return await Firestore.instance
          .collection('users')
          .where('email', isEqualTo: _email)
          .getDocuments();
    }
    getData().then((val) {
      if (val.documents.length > 0) {
        userDocId = val.documents[0].documentID;
        final Stream<QuerySnapshot> stream = Firestore.instance
          .collection('users')
          .document(userDocId)
          .collection('records')
          .snapshots();
      }
    });
    return StreamBuilder<QuerySnapshot>(
      //表示したいFiresotreの保存先を指定
        stream: Firestore.instance
            .collection('users')
            .document(userDocId)
            .collection('records')
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
                  snapshot.data.documents[index].documentID,
                ),
              );
            },
          );
        });
  }
}
