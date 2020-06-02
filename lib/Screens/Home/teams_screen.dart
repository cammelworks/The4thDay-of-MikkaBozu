import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamsScreen extends StatelessWidget {
  String _email;

  TeamsScreen(this._email);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          child: Container(
            padding: const EdgeInsets.all(6),
            alignment: Alignment.center,
            child: Text(_email),
          ),
        ),
        Center(
          child: Container(
            alignment: Alignment.center,
            child: getTeamID(),
          ),
        ),
      ],
    );
  }

  //チームIDを取得する関数
  Widget getTeamID() {
    return StreamBuilder<QuerySnapshot>(

        //表示したいFiresotreの保存先を指定
        stream: Firestore.instance
            .collection("teams")
            .where("email", isEqualTo: _email)
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
