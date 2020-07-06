import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MembersRecord extends StatelessWidget{
  String _teamName;

  MembersRecord(this._teamName);

  @override
  Widget build(BuildContext context) {
    return getMembers();
  }

  //メンバー一覧を表示する
  Widget getMembers() {
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

          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, int index) {
              return Container(
                padding: const EdgeInsets.all(6),
                alignment: Alignment.center,
                child: Text(
                  snapshot.data.documents[index].documentID.toString(),
                ),
              );
            },
          );
        });
  }
}
