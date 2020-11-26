import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TeamDetails extends StatelessWidget {
  String _teamName;

  TeamDetails(this._teamName);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              "チーム概要",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: _showDetails()),
            IconButton(
                icon: Icon(Icons.mode_edit),
                onPressed: () async {
                  //todo 概要変更
                }),
          ],
        ),
      ],
    );
  }

  void _setDetails() {
    //Firebaseのteamsに概要を設定する
    //todo firebase
  }

  Widget _showDetails() {
    //Firestoreから目標を取得して表示
    return StreamBuilder<DocumentSnapshot>(
        //表示したいFiresotreの保存先を指定
//        stream: Firestore.instance
//            .collection('teams')
//            .document((_teamName))
//            .snapshots(),
        //streamが更新されるたびに呼ばれる
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      return Text("チーム概要");
    });
  }
}
