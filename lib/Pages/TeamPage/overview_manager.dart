import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';

class OverviewManager extends StatelessWidget {
  String _teamName;

  OverviewManager(this._teamName);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              '概要',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
        Center(child: _showOverview()),
      ],
    );
  }

  Widget _showOverview() {
    //Firestoreから目標を取得して表示
    return StreamBuilder<DocumentSnapshot>(
      //表示したいFiresotreの保存先を指定
        stream: Firestore.instance
            .collection('teams')
            .document((_teamName))
            .snapshots(),
        //streamが更新されるたびに呼ばれる
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          //データが取れていない時の処理
          if (!snapshot.hasData) return const Text('Loading...');
          if (snapshot.data["team_overview"] != null) {
            return Text(
              snapshot.data["team_overview"].toString(),
              style: TextStyle(
                fontSize: 20,
              ),
            );
          } else {
            return Container();
          }
        });
  }
}